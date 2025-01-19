const std = @import("std");
const curl = @import("curl");
const Method = curl.Easy.Method;

pub const Arguments = struct {
    timeout: usize = 30_000,
    url: []const u8 = undefined,
    method: Method = .GET,
    body: ?[]const u8 = null,
    ship_file: []const u8 = undefined,
    show_headers: ShowHeaders = .none,

    const ShowHeaders = enum(u3) { all, res, none };

    pub fn new(arg_it: *std.process.ArgIterator) !Arguments {
        var arguments: Arguments = .{};
        _ = arg_it.next();
        while (arg_it.next()) |arg| {
            std.debug.print("arg {s}\n", .{arg});
            if (std.mem.eql(u8, arg, "-t")) {
                const value = try std.fmt.parseInt(usize, arg_it.next().?, 10);
                arguments.timeout = value * 1_000;
            } else if (std.mem.eql(u8, arg, "-m")) {
                arguments.setMethod(arg_it.next().?);
            } else if (std.mem.eql(u8, arg, "-u")) {
                arguments.url = arg_it.next().?;
            } else if (std.mem.eql(u8, arg, "-f")) {
                arguments.ship_file = arg_it.next().?;
            } else if (std.mem.eql(u8, arg, "-h")) {
                arguments.setShowHeaders(arg_it.next().?);
            } else {
                break;
            }
        }
        return arguments;
    }

    fn setMethod(self: *Arguments, str: []const u8) void {
        inline for (std.meta.fields(Method)) |field| {
            if (std.mem.eql(u8, field.name, str)) {
                self.method = @field(Method, field.name);
            }
        }
    }

    fn setShowHeaders(self: *Arguments, str: []const u8) void {
        inline for (std.meta.fields(ShowHeaders)) |field| {
            if (std.mem.eql(u8, field.name, str)) {
                self.show_headers = @field(ShowHeaders, field.name);
            }
        }
    }
};
