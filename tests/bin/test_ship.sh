##!/usr/bin/env bash

SHIP=~/.local/share/nvim/lazy/nvim-ship/bin/ship.sh
LOG_FILE=~/.local/state/nvim/ship.log
DEST=/tmp/testing.shipo

# $SHIP -t 30 -m POS -u https://countries.trevorblades.com/ -s false -h none -c '-H "Content-Type: application/json"' -b '{"query": "{ continents { code name } }"}' -f $DEST -f $LOG_FILE; cat $DEST; rm $DEST 

$SHIP -t 30 -m GET -u https://httpbin.org/response-headers?freeform=myqueryparam -s false -h none -c '-H "accept: application/json"' -f $DEST \
    -l $LOG_FILE; cat $DEST; rm $DEST 
