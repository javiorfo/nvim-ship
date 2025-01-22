const curl = @import("curl");
const std = @import("std");
const request = @import("request.zig");
const Arguments = @import("arguments.zig").Arguments;

pub const std_options = .{
    // Debug level to get zig-curl errors
    .log_level = .debug,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();

    const arguments = try Arguments.new(&args);
    var shipper = try request.Shipper.init(allocator, arguments);
    defer shipper.deinit();

    try shipper.call();
}
