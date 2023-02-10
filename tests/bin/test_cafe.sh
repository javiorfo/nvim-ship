##!/usr/bin/env bash
# Author: Mr. Charkuils

CAFE=$HOME/.local/share/nvim/site/pack/packer/start/nvim-cafe/bin/cafe.sh
DEST=/tmp/testing.cafer

$CAFE -t 30 -m POST -u https://countries.trevorblades.com/ -s false -h none -c '-H "Content-Type: application/json"' -b '{"query": "{ continents { code name } }"}' -f $DEST; cat $DEST; rm $DEST 
