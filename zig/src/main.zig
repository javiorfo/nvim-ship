const curl = @import("curl");
const std = @import("std");
const request = @import("request.zig");
const Arguments = @import("arguments.zig").Arguments;

//    -b OPCIONAL body -> format -b "@/home/javier/.local/share/nvim/lazy/nvim-ship/tests/body/request.json" o -b '{"audience": "https://api.bravenewcoin.com","client_id": "oCdQoZoI96ERE9HY3sQ7JmbACfBf55RY","grant_type": "client_credentials"}'
//    -l log file
//
// /home/javier/.local/share/nvim/lazy/nvim-ship/script/ship.sh -t 30 -m POST -u 'https://httpbin.org/post' -h res -c ' -H "test: lala"'' -H "content-type: application/json"' -f /tmp/simple_post.shipo -s false -d output  -l /home/javier/.local/state/nvim/ship.log -i false 2> >( while read line; do echo "[ERROR][$(date '+%D %T')]: ${line}"; done >> /home/javier/.local/state/nvim/ship.log)

// ADICIONALES
// multipart
// form-urlencoded
// jwt decode
// format xml y json
// Handle errors (logs)
// time y http code
//    -c headers -> format 'X-RapidAPI-Key;SIGN-UP-FOR-KEY;X-RapidAPI-Host;bravenewcoin.p.rapidapi.com;content-type;application/json'

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();

    var shipper = try request.Shipper.init(allocator, try Arguments.new(&args));
    defer shipper.deinit();

    try shipper.call();
}
