##!/usr/bin/env bash
# Author: Javier Orfo

DIAMOND=$HOME/.local/share/nvim/site/pack/packer/start/nvim-diamond/bin/diamond.sh
DEST=/tmp/testing.dmndr

$DIAMOND -t 30 -m POST -u https://countries.trevorblades.com/ -s false -h none -c '-H "Content-Type: application/json"' -b '{"query": "{ continents { code name } }"}' -f $DEST; cat $DEST; rm $DEST 
