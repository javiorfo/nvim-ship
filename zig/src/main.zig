const curl = @import("curl");
const std = @import("std");
const request = @import("request.zig");
const Arguments = @import("arguments.zig").Arguments;

// ADICIONALES
// Clean code
// jwt decode
// Handle errors (ship_log_file)

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();

    // TODO manage this tries
    const arguments = try Arguments.new(&args);
    var shipper = try request.Shipper.init(allocator, arguments);
    defer shipper.deinit();

    try shipper.call();
}
