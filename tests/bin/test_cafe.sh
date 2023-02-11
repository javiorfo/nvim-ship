##!/usr/bin/env bash
# Author: Mr. Charkuils

CAFE=$HOME/.local/share/nvim/site/pack/packer/start/nvim-cafe/bin/cafe.sh
LOG_FILE=$HOME/.local/state/nvim/cafe.log
DEST=/tmp/testing.cafer

# $CAFE -t 30 -m POS -u https://countries.trevorblades.com/ -s false -h none -c '-H "Content-Type: application/json"' -b '{"query": "{ continents { code name } }"}' -f $DEST -f $LOG_FILE; cat $DEST; rm $DEST 

$CAFE -t 30 -m GET -u https://httpbin.org/get -s false -h none -c '-H "Content-Type: application/json"' -f $DEST \
    -l $LOG_FILE; cat $DEST; rm $DEST 
