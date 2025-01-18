const std = @import("std");
const B64Decoder = std.base64.standard_no_pad.Decoder;
const prettizy = @import("prettizy");

pub fn decoder(token: []const u8, allocator: std.mem.Allocator) !void {
    var it = std.mem.split(u8, token, ".");
    var index: usize = 0;
    while (it.next()) |str| : (index += 1) {
        if (index < 2) {
            const decoded_length = try std.base64.standard_no_pad.Decoder.calcSizeForSlice(str);
            const decoded = try allocator.alloc(u8, decoded_length);
            defer allocator.free(decoded);
            try B64Decoder.decode(decoded, str);
            switch (index) {
                0 => {
                    std.debug.print("Header: {s}\n", .{try prettizy.json.prettify(allocator, decoded, .{})});
                },
                else => {
                    std.debug.print("Payload: {s}\n", .{try prettizy.json.prettify(allocator, decoded, .{})});
                },
            }
        }
    }
}
