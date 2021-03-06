-ifndef(ANANKE_HRL).
-include_lib("whistle/include/wh_types.hrl").
-include_lib("whistle/include/wh_log.hrl").
-include_lib("whistle/include/wh_databases.hrl").

-define(APP_NAME, <<"ananke">>).
-define(APP_VERSION, <<"0.0.1">> ).
-define(CONFIG_CAT, <<"ananke">>).

-type pos_integers() :: list(pos_integer()).
-type check_fun() :: 'true' | fun(() -> boolean()) | {Module :: atom(), FunName :: atom(), Args :: list()}.

-define(ANANKE_HRL, 'true').
-endif.
