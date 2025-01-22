const std = @import("std");
const B64Decoder = std.base64.standard_no_pad.Decoder;
const prettizy = @import("prettizy");

pub fn decoder(token: []const u8, allocator: std.mem.Allocator) !void {
    var it = std.mem.split(u8, token, ".");
    var index: usize = 0;
    const stdout = std.io.getStdOut().writer();
    while (it.next()) |str| : (index += 1) {
        if (index < 2) {
            const decoded_length = try std.base64.standard_no_pad.Decoder.calcSizeForSlice(str);
            const decoded = try allocator.alloc(u8, decoded_length);
            defer allocator.free(decoded);
            try B64Decoder.decode(decoded, str);
            switch (index) {
                0 => {
                    try stdout.print("Header:\n{s}\n", .{try prettizy.json.prettify(allocator, decoded, .{})});
                },
                else => {
                    try stdout.print(" \n", .{});
                    try stdout.print("Payload:\n{s}\n", .{try prettizy.json.prettify(allocator, decoded, .{})});
                },
            }
        }
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();
    _ = args.skip();
    try decoder("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c", allocator);
}
