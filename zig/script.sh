#! /bin/bash

# zig build run -- -t 30 -m POST -u 'https://api.restful-api.dev/objects' -f /tmp/prueba.shipo -h res -c 'accept;application/json;Content-Type;application/json' -b '{"name": "Apple MacBook Pro 16","data": {"year": 2019,"price": 1849.99,"CPU model": "Intel Core i9","Hard disk size": "1 TB"}}'

# zig build run -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/prueba.shipo -h none -c 'Content-Type;application/x-www-form-urlencoded' -b 'field1=value1&field2=value2'

zig build run -- -t 30 -m POST -u 'https://postman-echo.com/post' -f /tmp/prueba.shipo -h none -c 'Content-Type;multipart/form-data' -b 'field1=value1&file=@/home/javier/zt.log'

cat /tmp/prueba.shipo

