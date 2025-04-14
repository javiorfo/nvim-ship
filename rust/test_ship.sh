#! /bin/bash

rm -f /tmp/file.shipo

cargo run --bin ship -- -t 30 -m POST -u 'https://api.restful-api.dev/objects' -f /tmp/file.shipo -h all -c 'Accept:application/json;Content-Type:application/json' -b '{"name": "Acme","data": {"year": 2019,"price": 1849.99,"CPU model": "Intel Core i9","Hard disk size": "1 TB"}}'

# cargo run --bin ship -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/file.shipo -h none -c 'Content-Type;application/x-www-form-urlencoded' -b 'field1=value1&field2=value2'

# cargo run --bin ship -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/file.shipo -h none -c 'Content-Type:multipart/form-data' -b 'field1=value1&file=@/home/javier/import.json' 2> >( while read line; do echo "[ERROR][$(date '+%%D %%T')]: ${line}"; done >> /tmp/ship.log)

# cargo run --bin ship -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/file.shipo -h none -c 'Content-Type:multipart/form-data' -b 'field1=value1&file=@/home/javier/import.json'

# cargo run --bin ship -- -t 30 -m POST -u 'https://countries.trevorblades.com' -f /tmp/file.shipo -h none -c 'Content-Type;application/json;Accept;application/json' -b '{"query": "{ continents { code name } }"}'

# cargo run --bin ship -- -t 30 -m GET -u 'https://httpbin.org/xml' -h none -c 'Accept:application/xml'

# cargo run --bin ship -- -t 30 -m POST -u 'https://api.restful-api.dev/objects' -c 'Accept:application/json;content-type:application/json' -b @body.json

cat /tmp/file.shipo
