#! /bin/bash

rm -f /tmp/file.shipo

# zig build run -- -t 30 -m POST -u 'https://api.restful-api.dev/objects' -f /tmp/file.shipo -h res -c 'Accept;application/json;Content-Type;application/json' -b '{"name": "Acme","data": {"year": 2019,"price": 1849.99,"CPU model": "Intel Core i9","Hard disk size": "1 TB"}}'

# zig build run -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/file.shipo -h none -c 'Content-Type;application/x-www-form-urlencoded' -b 'field1=value1&field2=value2'

zig build run -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/file.shipo -h none -c 'Content-Type;multipart/form-data' -b 'field1=value1&file=@/path/to/zt.log' 2> >( while read line; do echo "[ERROR][$(date '+%%D %%T')]: ${line}"; done >> /tmp/ship.log)

# zig build run -- -t 30 -m POST -u 'https://countries.trevorblades.com' -f /tmp/file.shipo -h none -c 'Content-Type;application/json;Accept;application/json' -b '{"query": "{ continents { code name } }"}'

cat /tmp/file.shipo

