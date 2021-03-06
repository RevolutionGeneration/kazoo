%%%-------------------------------------------------------------------
%%% @copyright (C) 2013-2015, 2600Hz
%%% @doc
%%% Handle the emulation of the Dial verb
%%% @end
%%% @contributors
%%%   James Aimonetti
%%%-------------------------------------------------------------------
-module(kzt_twiml_dial).

-export([exec/3]).

-ifdef(TEST).
-export([cleanup_dial_me/1]).
-endif.

-include("kzt.hrl").

-spec exec(whapps_call:call(), xml_els() | xml_texts(), xml_attribs()) ->
                  {'ok' | 'stop', whapps_call:call()}.
exec(Call, [#xmlText{type='text'}|_]=DialMeTxts, Attrs) ->
    whapps_call_command:answer(Call),

    case knm_converters:normalize(cleanup_dial_me(kz_xml:texts_to_binary(DialMeTxts))) of
        <<>> ->
            lager:debug("no text to dial, using only xml elements"),
            exec(Call, kz_xml:elements(DialMeTxts), Attrs);
        DialMe -> dial_me(Call, Attrs, DialMe)
    end;
exec(Call
     ,[#xmlElement{name='Number'
                   ,content=Number
                   ,attributes=Attrs
                  }
      ]
     ,Attrs) ->
    lager:debug("single <Number>"),
    case knm_converters:normalize(cleanup_dial_me(kz_xml:texts_to_binary(Number))) of
        <<>> ->
            lager:debug("no dialable Number in tag, continuing"),
            {'ok', Call};
        DialMe ->
            Props = kz_xml:attributes_to_proplist(Attrs),

            SendDigits = props:get_value('sendDigis', Props),
            _Url = props:get_value('url', Props),
            _Method = props:get_value('method', Props),

            lager:debug("maybe sending number ~s: send ~s", [DialMe, SendDigits]),

            dial_me(Call, Attrs, DialMe)
    end;
exec(Call, [#xmlElement{name='Conference'
                        ,content=ConfIdTxts
                        ,attributes=ConfAttrs
                       }], DialAttrs) ->
    whapps_call_command:answer(Call),

    ConfId = conference_id(ConfIdTxts),
    lager:info("dialing into conference '~s'", [ConfId]),

    ConfProps = kz_xml:attributes_to_proplist(ConfAttrs),
    DialProps = kz_xml:attributes_to_proplist(DialAttrs),

    gen_listener:add_binding(kzt_util:get_amqp_listener(Call)
                             ,'conference'
                             ,[{'restrict_to', ['config']}
                               ,{'profile', ConfId}
                              ]),

    ConfDoc = build_conference_doc(ConfId, ConfProps),
    ConfReq = [{<<"Call">>, whapps_call:to_json(Call)}
               ,{<<"Conference-Doc">>, ConfDoc}
               ,{<<"Moderator">>, props:get_is_true('startConferenceOnEnter', ConfProps, 'true')}
               | wh_api:default_headers(?APP_NAME, ?APP_VERSION)
              ],
    wapi_conference:publish_discovery_req(ConfReq),

    lager:debug("published conference request"),

    %% Will need to support fetching media OR TwiML
    _WaitUrl = props:get_value('waitUrl', ConfProps),
    _WaitMethod = kzt_util:http_method(ConfProps),

    {'ok', Call1} = kzt_receiver:wait_for_conference(
                      kzt_util:update_call_status(?STATUS_ANSWERED, setup_call_for_dial(
                                                                      add_conference_profile(Call, ConfProps)
                                                                      ,DialProps
                                                                     ))
                     ),

    lager:debug("waited for offnet, maybe ending dial"),

    _ = maybe_end_dial(Call1, DialProps),
    {'stop', Call1};

exec(Call, [#xmlElement{name='Queue'
                        ,content=QueueIdTxts
                        ,attributes=QueueAttrs
                       }], DialAttrs) ->
    DialProps = kz_xml:attributes_to_proplist(DialAttrs),

    QueueId = kz_xml:texts_to_binary(QueueIdTxts),
    QueueProps = kz_xml:attributes_to_proplist(QueueAttrs),

    %% Fetch TwiML to play to caller before connecting agent
    _Url = props:get_value('url', QueueProps),
    _Method = kzt_util:http_method(QueueProps),

    Call1 = setup_call_for_dial(
              kzt_util:set_queue_sid(QueueId, Call)
              ,DialProps
             ),

    lager:info("dialing into queue ~s, unsupported", [QueueId]),
    {'stop', Call1};

exec(Call, [#xmlElement{}|_]=Endpoints, Attrs) ->
    lager:debug("dialing endpoints"),

    Props = kz_xml:attributes_to_proplist(Attrs),
    Call1 = setup_call_for_dial(Call, Props),

    case xml_elements_to_endpoints(Call1, Endpoints) of
        [] ->
            lager:info("no endpoints were found to dial"),
            {'stop', Call1};
        EPs ->
            lager:debug("endpoints created, sending dial"),
            Timeout = dial_timeout(Props),
            IgnoreEarlyMedia = cf_util:ignore_early_media(EPs),
            Strategy = dial_strategy(Props),

            send_bridge_command(EPs, Timeout, Strategy, IgnoreEarlyMedia, Call1),

            {'ok', Call2} = kzt_receiver:wait_for_offnet(
                              kzt_util:update_call_status(?STATUS_RINGING, Call1)
                              ,Props
                             ),
            maybe_end_dial(Call2, Props)
    end.

dial_me(Call, Attrs, DialMe) ->
    lager:info("dial text DID '~s'", [DialMe]),

    Props = kz_xml:attributes_to_proplist(Attrs),

    Call1 = setup_call_for_dial(whapps_call:set_request(request_id(DialMe, Call), Call)
                                ,Props
                               ),

    OffnetProps = [{<<"Timeout">>, kzt_util:get_call_timeout(Call1)}
                   ,{<<"Media">>, media_processing(Call1)}
                   ,{<<"Force-Outbound">>, force_outbound(Props)}
                   ,{<<"Server-ID">>, whapps_call:controller_queue(Call1)}
                  ],
    'ok' = kzt_util:offnet_req(OffnetProps, Call1),

    {'ok', Call2} = kzt_receiver:wait_for_offnet(
                      kzt_util:update_call_status(?STATUS_RINGING, Call1)
                      ,Props
                     ),
    maybe_end_dial(Call2, Props).

send_bridge_command(EPs, Timeout, Strategy, IgnoreEarlyMedia, Call) ->
    B = [{<<"Application-Name">>, <<"bridge">>}
         ,{<<"Endpoints">>, EPs}
         ,{<<"Timeout">>, Timeout}
         ,{<<"Ignore-Early-Media">>, IgnoreEarlyMedia}
         ,{<<"Dial-Endpoint-Method">>, Strategy}
         | wh_api:default_headers(?APP_NAME, ?APP_VERSION)
        ],
    whapps_call_command:send_command(B, Call).

-spec setup_call_for_dial(whapps_call:call(), wh_proplist()) -> whapps_call:call().
setup_call_for_dial(Call, Props) ->
    Setters = [{fun whapps_call:set_caller_id_number/2, caller_id(Props, Call)}
               ,{fun kzt_util:set_hangup_dtmf/2, hangup_dtmf(Props)}
               ,{fun kzt_util:set_record_call/2, should_record_call(Props)}
               ,{fun kzt_util:set_call_timeout/2, kzt_twiml_util:timeout_s(Props)}
               ,{fun kzt_util:set_call_time_limit/2, timelimit_s(Props)}
              ],
    whapps_call:exec(Setters, Call).

-spec maybe_end_dial(whapps_call:call(), wh_proplist()) ->
                            {'ok' | 'stop' | 'request', whapps_call:call()}.
maybe_end_dial(Call, Props) ->
    maybe_end_dial(Call, Props, kzt_twiml_util:action_url(Props)).

maybe_end_dial(Call, _Props, 'undefined') ->
    lager:debug("a-leg status after bridge: ~s", [kzt_util:get_call_status(Call)]),
    {'ok', Call}; % will progress to next TwiML element
maybe_end_dial(Call, Props, ActionUrl) ->
    CurrentUri = kzt_util:get_voice_uri(Call),
    NewUri = kzt_util:resolve_uri(CurrentUri, ActionUrl),
    lager:debug("sending req to ~s: ~s", [ActionUrl, NewUri]),
    Method = kzt_util:http_method(Props),

    Setters = [{fun kzt_util:set_voice_uri_method/2, Method}
               ,{fun kzt_util:set_voice_uri/2, NewUri}
              ],
    {'request', whapps_call:exec(Setters, Call)}.

-spec cleanup_dial_me(binary()) -> binary().
cleanup_dial_me(<<_/binary>> = Txt) ->
    << <<C>> || <<C>> <= Txt, is_numeric_or_plus(C)>>.

-spec is_numeric_or_plus(pos_integer()) -> boolean().
is_numeric_or_plus(Num) when Num >= $0, Num =< $9 -> 'true';
is_numeric_or_plus($+) -> 'true';
is_numeric_or_plus(_) -> 'false'.

%% To maintain compatibility with Twilo, we force the call offnet (otherwise
%% the redirect onnet steals our callid, and callflow/trunkstore/other could
%% potentially hangup our A-leg. If the B-leg is forced offnet, we can still
%% capture the failed B-leg and continue processing the TwiML (if any).
force_outbound(Props) -> props:get_is_true('continueOnFail', Props, 'true').

-spec xml_elements_to_endpoints(whapps_call:call(), xml_els()) ->
                                       wh_json:objects().
-spec xml_elements_to_endpoints(whapps_call:call(), xml_els(), wh_json:objects()) ->
                                       wh_json:objects().
xml_elements_to_endpoints(Call, EPs) ->
    xml_elements_to_endpoints(Call, EPs, []).

xml_elements_to_endpoints(_, [], Acc) -> Acc;
xml_elements_to_endpoints(Call, [#xmlElement{name='Device'
                                             ,content=DeviceIdTxt
                                             ,attributes=_DeviceAttrs
                                            }
                                 | EPs], Acc
                         ) ->
    DeviceId = kz_xml:texts_to_binary(DeviceIdTxt),
    lager:debug("maybe adding device ~s to ring group", [DeviceId]),
    case cf_endpoint:build(DeviceId, Call) of
        {'ok', DeviceEPs} -> xml_elements_to_endpoints(Call, EPs, DeviceEPs ++ Acc);
        {'error', _E} ->
            lager:debug("failed to add device ~s: ~p", [DeviceId, _E]),
            xml_elements_to_endpoints(Call, EPs, Acc)
    end;
xml_elements_to_endpoints(Call, [#xmlElement{name='User'
                                            ,content=UserIdTxt
                                            ,attributes=_UserAttrs
                                            }
                                | EPs], Acc) ->
    UserId = kz_xml:texts_to_binary(UserIdTxt),
    lager:debug("maybe adding user ~s to ring group", [UserId]),

    case cf_user:get_endpoints(UserId, wh_json:new(), Call) of
        [] ->
            lager:debug("no user endpoints built for ~s, skipping", [UserId]),
            xml_elements_to_endpoints(Call, EPs, Acc);
        UserEPs -> xml_elements_to_endpoints(Call, EPs, UserEPs ++ Acc)
    end;
xml_elements_to_endpoints(Call, [#xmlElement{name='Number'
                                             ,content=Number
                                             ,attributes=Attrs
                                            }
                                 | EPs], Acc) ->
    Props = kz_xml:attributes_to_proplist(Attrs),

    SendDigits = props:get_value('sendDigis', Props),
    _Url = props:get_value('url', Props),
    _Method = props:get_value('method', Props),

    DialMe = knm_converters:normalize(kz_xml:texts_to_binary(Number)),

    lager:debug("maybe add number ~s: send ~s", [DialMe, SendDigits]),

    CallFwd = wh_json:from_list([{<<"number">>, DialMe}
                                 ,{<<"require_keypress">>, 'false'}
                                 ,{<<"substribute">>, 'true'}
                                ]),
    Endpoint = wh_json:from_list([{<<"call_forward">>, CallFwd}]),
    EP = cf_endpoint:create_call_fwd_endpoint(Endpoint, wh_json:new(), Call),

    xml_elements_to_endpoints(Call, EPs, [EP|Acc]);

xml_elements_to_endpoints(Call, [#xmlElement{name='Sip'
                                             ,content=Number
                                             ,attributes=Attrs
                                            }
                                 | EPs], Acc) ->
    _Props = kz_xml:attributes_to_proplist(Attrs),

    try knm_sip:parse(kz_xml:texts_to_binary(Number)) of
        URI ->
            xml_elements_to_endpoints(Call, EPs, [sip_uri(Call, URI)|Acc])
    catch
        'throw':_E ->
            lager:debug("failed to parse SIP uri: ~p", [_E]),
            xml_elements_to_endpoints(Call, EPs, Acc)
    end;

xml_elements_to_endpoints(Call, [_Xml|EPs], Acc) ->
    lager:debug("unknown endpoint, skipping: ~p", [_Xml]),
    xml_elements_to_endpoints(Call, EPs, Acc).

-spec sip_uri(whapps_call:call(), ne_binary()) -> wh_json:object().
sip_uri(Call, URI) ->
    lager:debug("maybe adding SIP endpoint: ~s", [knm_sip:encode(URI)]),
    SIPDevice = sip_device(URI),
    cf_endpoint:create_sip_endpoint(SIPDevice, wh_json:new(), Call).

-spec sip_device(ne_binary()) -> kz_device:doc().
sip_device(URI) ->
    lists:foldl(fun({F, V}, D) -> F(D, V) end
                ,kz_device:new()
                ,[{fun kz_device:set_sip_invite_format/2, <<"route">>}
                  ,{fun kz_device:set_sip_route/2, knm_sip:encode(URI)}
                 ]).

request_id(N, Call) -> iolist_to_binary([N, <<"@">>, whapps_call:from_realm(Call)]).

-spec media_processing(whapps_call:call()) -> ne_binary().
-spec media_processing(boolean(), api_binary()) -> ne_binary().
media_processing(Call) ->
    media_processing(kzt_util:get_record_call(Call), kzt_util:get_hangup_dtmf(Call)).

media_processing('false', 'undefined') -> <<"bypass">>;
media_processing('true', _HangupDTMF) -> <<"process">>.

get_max_participants(Props) when is_list(Props) ->
    get_max_participants(props:get_integer_value('maxParticipants', Props, 40));
get_max_participants(N) when is_integer(N), N =< 40, N > 0 -> N.

-spec dial_timeout(wh_proplist() | pos_integer()) -> pos_integer().
dial_timeout(Props) when is_list(Props) ->
    dial_timeout(props:get_integer_value('timeout', Props, 20));
dial_timeout(T) when is_integer(T), T > 0 -> T.

dial_strategy(Props) ->
    case props:get_value('strategy', Props) of
        'undefined' -> <<"simultaneous">>;
        <<"simultaneous">> -> <<"simultaneous">>;
        <<"single">> -> <<"single">>
    end.

-spec caller_id(wh_proplist(), whapps_call:call()) -> ne_binary().
caller_id(Props, Call) ->
    wh_util:to_binary(
      props:get_value('callerId', Props, whapps_call:caller_id_number(Call))
     ).

-spec hangup_dtmf(wh_proplist() | api_binary()) -> api_binary().
hangup_dtmf(Props) when is_list(Props) ->
    case props:get_value('hangupOnStar', Props) of
        'true' -> <<"*">>;
        _ -> hangup_dtmf(props:get_binary_value('hangupOn', Props))
    end;
hangup_dtmf(DTMF) ->
    case lists:member(DTMF, ?ANY_DIGIT) of
        'true' -> DTMF;
        'false' -> 'undefined'
    end.

should_record_call(Props) -> wh_util:is_true(props:get_value('record', Props, 'false')).
timelimit_s(Props) -> props:get_integer_value('timeLimit', Props, 14400).


-spec build_conference_doc(ne_binary(), wh_proplist()) -> wh_json:object().
build_conference_doc(ConfId, ConfProps) ->
    StartOnEnter = props:is_true('startConferenceOnEnter', ConfProps),

    wh_json:from_list([{<<"name">>, ConfId}
                       ,{<<"play_welcome">>, 'false'}
                       ,{<<"play_entry_tone">>, props:is_true('beep', ConfProps, 'true')}
                       ,{<<"member">>, member_flags(ConfProps, StartOnEnter)}
                       ,{<<"moderator">>, moderator_flags(ConfProps, StartOnEnter)}
                       ,{<<"require_moderator">>, require_moderator(StartOnEnter)}
                       ,{<<"wait_for_moderator">>, 'true'}
                       ,{<<"max_members">>, get_max_participants(ConfProps)}
                       ,{<<"profile">>, ConfId}
                      ]).

require_moderator('undefined') -> 'false';
require_moderator('true') -> 'false';
require_moderator('false') -> 'true'.

member_flags(_, 'true') -> wh_json:new();
member_flags(ConfProps, _) ->
    wh_json:from_list([{<<"join_muted">>, props:is_true('muted', ConfProps, 'false')}
                       ,{<<"join_deaf">>, props:is_true('deaf', ConfProps, 'false')}
                       ,{<<"play_name">>, props:is_true('play_name', ConfProps, 'false')}
                       ,{<<"play_entry_prompt">>, props:is_true('play_entry_prompt', ConfProps, 'true')}
                      ]).

moderator_flags(ConfProps, 'true') ->
    wh_json:from_list([{<<"join_muted">>, props:is_true('muted', ConfProps, 'false')}
                       ,{<<"join_deaf">>, props:is_true('deaf', ConfProps, 'false')}
                       ,{<<"play_name">>, props:is_true('play_name', ConfProps, 'false')}
                       ,{<<"play_entry_prompt">>, props:is_true('play_entry_prompt', ConfProps, 'true')}
                      ]);
moderator_flags(_, _) -> wh_json:new().

conference_id(Txts) ->
    Id = kz_xml:texts_to_binary(Txts),
    MD5 = wh_util:to_hex_binary(erlang:md5(Id)),
    lager:debug("conf name: ~s (~s)", [Id, MD5]),
    MD5.


add_conference_profile(Call, ConfProps) ->
    Profile = wh_json:from_list(
                props:filter_undefined(
                  [{<<"rate">>, props:get_integer_value('rate', ConfProps, 8000)}
                   ,{<<"caller-controls">>, props:get_integer_value('callerControls', ConfProps, 8000)}
                   ,{<<"interval">>, props:get_integer_value('inteval', ConfProps, 20)}
                   ,{<<"energy-level">>, props:get_integer_value('energyLevel', ConfProps, 20)}
                   ,{<<"member-flags">>, conference_member_flags(ConfProps)}
                   ,{<<"conference-flags">>, conference_flags(ConfProps)}
                   ,{<<"tts-engine">>, kzt_twiml_util:get_engine(ConfProps)}
                   ,{<<"tts-voice">>, kzt_twiml_util:get_voice(ConfProps)}
                   ,{<<"max-members">>, get_max_participants(ConfProps)}
                   ,{<<"comfort-noise">>, props:get_integer_value('comfortNoise', ConfProps, 1000)}
                   ,{<<"annouce-count">>, props:get_integer_value('announceCount', ConfProps)}
                   ,{<<"caller-controls">>, props:get_value('callerControls', ConfProps, <<"default">>)}
                   ,{<<"moderator-controls">>, props:get_value('callerControls', ConfProps, <<"default">>)}
                   ,{<<"caller-id-name">>, props:get_value('callerIdName', ConfProps, wh_util:anonymous_caller_id_name())}
                   ,{<<"caller-id-number">>, props:get_value('callerIdNumber', ConfProps, wh_util:anonymous_caller_id_number())}
                   %,{<<"suppress-events">>, <<>>} %% add events to make FS less chatty
                   ,{<<"moh-sound">>, props:get_value('waitUrl', ConfProps, <<"http://com.twilio.music.classical.s3.amazonaws.com/Mellotroniac_-_Flight_Of_Young_Hearts_Flute.mp3">>)}
                  ])),
    kzt_util:set_conference_profile(Profile, Call).

conference_flags(ConfProps) ->
    case props:get_is_true('startConferenceOnEnter', ConfProps, 'true') of
        'true' -> 'undefined';
        'false' -> <<"wait-mod">>
    end.

conference_member_flags(ConfProps) ->
    case props:get_is_true('endConferenceOnExit', ConfProps, 'false') of
        'true' -> <<"endconf">>;
        'false' -> 'undefined'
    end.
