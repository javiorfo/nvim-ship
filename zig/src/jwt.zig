const std = @import("std");
const B64Decoder = std.base64.standard_no_pad.Decoder;
const prettizy = @import("prettizy");

pub fn decoder(allocator: std.mem.Allocator, token: []const u8, stdout: anytype) !void {
    var clean_token = token;
    if (std.mem.startsWith(u8, token, "Bearer ")) {
        clean_token = token[7..];
    }
    var it = std.mem.split(u8, clean_token, ".");
    var index: usize = 0;
    while (it.next()) |str| : (index += 1) {
        if (index < 2) {
            const decoded_length = try std.base64.standard_no_pad.Decoder.calcSizeForSlice(str);
            const decoded = try allocator.alloc(u8, decoded_length);
            defer allocator.free(decoded);
            try B64Decoder.decode(decoded, str);
            const formatted = try prettizy.json.prettify(allocator, decoded, .{});
            switch (index) {
                0 => {
                    try stdout.print("Header:\n{s}\n", .{formatted});
                },
                else => {
                    try stdout.print(" \n", .{});
                    try stdout.print("Payload:\n{s}\n", .{formatted});
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

    const stdout = std.io.getStdOut().writer();
    const token = args.next() orelse {
        try stdout.print("No token sent!\n", .{});
        return;
    };

    decoder(allocator, token, stdout) catch {
        try stdout.print("ERROR invalid JWT\n", .{});
    };
}

test "jwt" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdout = std.io.getStdOut().writer();
    try decoder(allocator, "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c", stdout);
}
