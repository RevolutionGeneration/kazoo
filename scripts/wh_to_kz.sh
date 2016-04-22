#!/bin/bash

grep -Rl "whistle" * | grep -v "beam" | grep -v ".*\.log" | grep -v "namefix.sh" | xargs sed -i 's/whistle/kazoo/g'

grep -Rl "whapps" * | grep -v "beam" | grep -v ".*\.log" | grep -v "namefix.sh" | xargs sed -i 's/whapps/kapps/g'

grep -Rl "wapi" * | grep -v "beam" | grep -v ".*\.log" | grep -v "namefix.sh" | xargs sed -i 's/wapi/kapi/g'

find . -name "whistle*" | xargs rename 's/whistle/kazoo/g'

find . -name "whapps*" | xargs rename 's/whapps/kapps/g'

find . -name "wapi*" | xargs rename 's/wapi/kapi/g'
