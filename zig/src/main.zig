const curl = @import("curl");
const std = @import("std");
const request = @import("request.zig");
const Arguments = @import("arguments.zig").Arguments;

// x  -h show headers (all, res, none)
//    -c headers -> format ' -H "X-RapidAPI-Key: SIGN-UP-FOR-KEY"'' -H "X-RapidAPI-Host: bravenewcoin.p.rapidapi.com"'' -H "content-type: application/json"'
//    -s save -> booleano (si se guarda el output)
//    -d output folder -> si -s true se crea folder
//    -b OPCIONAL body -> format -b "@/home/javier/.local/share/nvim/lazy/nvim-ship/tests/body/request.json" o -b '{"audience": "https://api.bravenewcoin.com","client_id": "oCdQoZoI96ERE9HY3sQ7JmbACfBf55RY","grant_type": "client_credentials"}'
//    -l log file
//    -i insecure
//curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
//curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
//
// /home/javier/.local/share/nvim/lazy/nvim-ship/script/ship.sh -t 30 -m POST -u 'https://httpbin.org/post' -h res -c ' -H "test: lala"'' -H "content-type: application/json"' -f /tmp/simple_post.shipo -s false -d output  -l /home/javier/.local/state/nvim/ship.log -i false 2> >( while read line; do echo "[ERROR][$(date '+%D %T')]: ${line}"; done >> /home/javier/.local/state/nvim/ship.log)

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();

    const arguments = try Arguments.new(&args);
    try request.call(allocator, arguments);
}
