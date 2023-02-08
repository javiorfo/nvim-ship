##!/usr/bin/env bash
# Author: Javier Orfo

VURL=$HOME/.local/share/nvim/site/pack/packer/start/nvim-vurl/bin/vurl.sh
DEST=/tmp/testing.vurlr

# $VURL -t 30 -m POST -u https://httpbin.org/post -s false -h res -f $DEST; cat $DEST; rm $DEST 

$VURL -t 30 -m POST -u https://httpbin.org/redirect-to -s false -h res -c '-H "Content-Type: application/x-www-form-urlencoded"' -f $DEST; cat $DEST; rm $DEST 
