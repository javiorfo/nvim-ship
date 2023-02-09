##!/usr/bin/env bash
# Author: Javier Orfo

VURL=$HOME/.local/share/nvim/site/pack/packer/start/nvim-vurl/bin/vurl.sh
DEST=/tmp/testing.vurlr

# $VURL -t 30 -m POST -u https://httpbin.org/post -s false -h none -f $DEST; cat $DEST; rm $DEST 

$VURL -t 30 -m POST -u https://countries.trevorblades.com/ -s false -h none -c '-H "Content-Type: application/json"' -b '{"query": "{ continents { code name } }"}' -f $DEST; cat $DEST; rm $DEST 
