const curl = @import("curl");
const std = @import("std");
const prettizy = @import("prettizy");
const jwt = @import("jwt.zig");

fn get() []const u8 {
    return 
    \\ {"name": "Apple MacBook Pro 16","data": {"year": 2019,"price": 1849.99,"CPU model": "Intel Core i9","Hard disk size": "1 TB"}}
    ;
}

pub const ArgumentsBuilder = struct {
    arguments: Arguments = .{},

    pub fn init(arg_it: *std.process.ArgIterator) !Arguments {
        var arguments: Arguments = .{};
        _ = arg_it.next();
        while (arg_it.next()) |arg| {
            std.debug.print("arg {s}\n", .{arg});
            if (std.mem.eql(u8, arg, "-t")) {
                const value = try std.fmt.parseInt(usize, arg_it.next().?, 10);
                arguments.timeout = value * 1_000;
            } else if (std.mem.eql(u8, arg, "-m")) {
                arguments.method = Arguments.methodFromString(arg_it.next().?);
            } else if (std.mem.eql(u8, arg, "-u")) {
                arguments.url = arg_it.next().?;
            } else {
                break;
            }
        }
        return arguments;
    }

    pub fn timeout(self: *ArgumentsBuilder, time: usize) ArgumentsBuilder {
        self.arguments.timeout = time * 1_000;
        return self.*;
    }

    pub fn url(self: *ArgumentsBuilder, url_param: []const u8) ArgumentsBuilder {
        self.arguments.url = url_param;
        return self.*;
    }

    pub fn build(self: ArgumentsBuilder) Arguments {
        return self.arguments;
    }
};

pub const Arguments = struct {
    timeout: usize = 30_000,
    url: []const u8 = undefined,
    method: curl.Easy.Method = .GET,
    body: ?[]const u8 = null,

    pub fn methodFromString(str: []const u8) curl.Easy.Method {
        if (std.mem.eql(u8, str, "GET")) {
            return .GET;
        }
        if (std.mem.eql(u8, str, "POST")) {
            return .POST;
        }
        if (std.mem.eql(u8, str, "PUT")) {
            return .PUT;
        }
        if (std.mem.eql(u8, str, "DELETE")) {
            return .DELETE;
        }
        if (std.mem.eql(u8, str, "HEAD")) {
            return .HEAD;
        }
        return .PATCH;
    }
};

pub fn call(allocator: std.mem.Allocator, arguments: Arguments) !void {
    const easy = try curl.Easy.init(allocator, .{ .default_timeout_ms = arguments.timeout });
    defer easy.deinit();

    const headers = blk: {
        var h = try easy.createHeaders();
        errdefer h.deinit();
        try h.add("content-type", "application/json");
        try h.add("my-head", "charkuils");
        break :blk h;
    };
    defer headers.deinit();

    try easy.setUrl(try std.fmt.allocPrintZ(allocator, "{s}", .{arguments.url}));
    try easy.setPostFields(get());
    try easy.setMethod(arguments.method);
    try easy.setHeaders(headers);
    var buf = curl.Buffer.init(allocator);
    try easy.setWritedata(&buf);
    try easy.setWritefunction(curl.bufferWriteCallback);

    var resp = try easy.perform();
    resp.body = buf;
    defer resp.deinit();

    std.debug.print("{s}\nfomatted {any}\n", .{
        try prettizy.json.prettify(allocator, resp.body.?.items, .{}),
        prettizy.json.isFormatted(resp.body.?.items),
    });

    std.debug.print("Iterating all headers...\n", .{});
    {
        var iter = try resp.iterateHeaders(.{});
        while (try iter.next()) |header| {
            std.debug.print("{s}: {s}\n", .{ header.name, header.get() });
        }
    }
}
