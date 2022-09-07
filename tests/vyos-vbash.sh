#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

set system host-name hoge
commit
save
