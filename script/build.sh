#!/usr/bin/env bash

ROOT=$1

## Zig ##
(cd $ROOT/zig && zig build -Doptimize=ReleaseFast)

if [ $? -ne 0 ]; then
    exit 1
fi

BIN=$ROOT/bin
mkdir -p $BIN

mv $ROOT/zig/zig-out/bin/ship $BIN
mv $ROOT/zig/zig-out/bin/jwt $BIN
