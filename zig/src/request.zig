const curl = @import("curl");
const std = @import("std");
const prettizy = @import("prettizy");
const jwt = @import("jwt.zig");
const Arguments = @import("arguments.zig").Arguments;
pub const c = @cImport({
    @cInclude("curl/curl.h");
    @cInclude("stdio.h");
});

fn get() []const u8 {
    return 
    \\ {"name": "Apple MacBook Pro 16","data": {"year": 2019,"price": 1849.99,"CPU model": "Intel Core i9","Hard disk size": "1 TB"}}
    ;
}

pub fn fileWriteCallback(ptr: [*c]c_char, size: c_uint, nmemb: c_uint, user_file: *anyopaque) callconv(.C) c_uint {
    const real_size = size * nmemb;
    var file: *std.fs.File = @alignCast(@ptrCast(user_file));
    var typed_data: [*]u8 = @ptrCast(ptr);
    _ = file.write(typed_data[0..real_size]) catch return 0;
    return real_size;
}

fn editFile(file_path: []const u8) !void {
    var file = try std.fs.openFileAbsolute(file_path, .{ .mode = .read_write });
    defer file.close();

    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer buffer.deinit();

    const reader = file.reader();
    var buffer_reader: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buffer_reader, '\n')) |line| {
        if (std.mem.startsWith(u8, line, "< ") or std.mem.startsWith(u8, line, "> ") or std.mem.startsWith(u8, line, "* ")) {
            try buffer.appendSlice(line[2..]);
        } else {
            try buffer.appendSlice(line);
        }
        try buffer.append('\n');
    }

    try file.seekTo(0);
    try file.writeAll(buffer.items);
    try file.setEndPos(buffer.items.len);
}

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

    var output_file = try std.fs.createFileAbsolute(arguments.ship_file, .{});
    defer output_file.close();
    const err_file = try std.fmt.allocPrintZ(allocator, "{s}.err", .{arguments.ship_file});
    const fil: *c.FILE = c.fopen(err_file, "wb");
    errdefer _ = c.fclose(fil);
    _ = c.curl_easy_setopt(easy.handle, c.CURLOPT_STDERR, fil);

    const param: c_long = @intCast(@intFromBool(true));
    _ = c.curl_easy_setopt(easy.handle, c.CURLOPT_SSL_VERIFYPEER, param);
    _ = c.curl_easy_setopt(easy.handle, c.CURLOPT_SSL_VERIFYHOST, param);

    try easy.setUrl(try std.fmt.allocPrintZ(allocator, "{s}", .{arguments.url}));
    try easy.setPostFields(get());
    try easy.setVerbose(true);
    try easy.setMethod(arguments.method);
    try easy.setHeaders(headers);
    var buf = curl.Buffer.init(allocator);
    try easy.setWritefunction(curl.bufferWriteCallback);
    try easy.setWritedata(&buf);
    //     try easy.setWritedata(&output_file);

    var resp = easy.perform() catch |err| {
        _ = try output_file.write(try std.fmt.allocPrint(allocator, "ERROR {any}", .{err}));
        return;
    };
    resp.body = buf;
    defer resp.deinit();

    _ = c.fclose(fil);
    try editFile(err_file);

    if (resp.body) |r| {
        if (prettizy.json.isFormatted(r.items)) {
            _ = try output_file.write(r.items);
        } else {
            _ = try output_file.write(try prettizy.json.prettify(allocator, r.items, .{}));
        }
    }

    //     std.debug.print("{s}\nfomatted {any}\n", .{
    //         try prettizy.json.prettify(allocator, resp.body.?.items, .{}),
    //         prettizy.json.isFormatted(resp.body.?.items),
    //     });
    //
    //     std.debug.print("Iterating all headers...\n", .{});
    //     var iter = try resp.iterateHeaders(.{});
    //     while (try iter.next()) |header| {
    //         std.debug.print("{s}: {s}\n", .{ header.name, header.get() });
    //     }
}
