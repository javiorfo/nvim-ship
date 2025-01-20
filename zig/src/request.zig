const curl = @import("curl");
const std = @import("std");
const prettizy = @import("prettizy");
const jwt = @import("jwt.zig");
const Arguments = @import("arguments.zig").Arguments;
pub const c = @cImport({
    @cInclude("curl/curl.h");
    @cInclude("stdio.h");
});
// {"name": "Apple MacBook Pro 16","data": {"year": 2019,"price": 1849.99,"CPU model": "Intel Core i9","Hard disk size": "1 TB"}}
pub const Shipper = struct {
    allocator: std.mem.Allocator,
    arguments: Arguments,
    easy: curl.Easy,

    const PerformResult = struct {
        response: curl.Easy.Response = undefined,
        error_msg: ?[]const u8 = null,
    };

    pub fn init(allocator: std.mem.Allocator, arguments: Arguments) !Shipper {
        const easy = try curl.Easy.init(allocator, .{ .default_timeout_ms = arguments.timeout });
        return .{
            .allocator = allocator,
            .arguments = arguments,
            .easy = easy,
        };
    }

    pub fn deinit(self: Shipper) void {
        self.easy.deinit();
    }

    fn perform(self: Shipper) !PerformResult {
        try self.easy.setCommonOpts();
        var perform_result = PerformResult{};

        const code_perform = c.curl_easy_perform(self.easy.handle);
        if (code_perform != c.CURLE_OK) {
            perform_result.error_msg = try std.fmt.allocPrint(self.allocator, "ERROR: {s}", .{c.curl_easy_strerror(code_perform)});
        }

        var status_code: c_long = 0;
        const code_info = c.curl_easy_getinfo(self.easy.handle, c.CURLINFO_RESPONSE_CODE, &status_code);
        if (code_info != c.CURLE_OK) {
            perform_result.error_msg = try std.fmt.allocPrint(self.allocator, "ERROR: {s}", .{c.curl_easy_strerror(code_info)});
        }

        perform_result.response = .{
            .status_code = @intCast(status_code),
            .handle = self.easy.handle,
            .body = null,
            .allocator = self.easy.allocator,
        };
        return perform_result;
    }

    pub fn call(self: Shipper) !void {
        if (self.arguments.save) {
            if (std.fs.cwd().makeDir(self.arguments.ship_output_folder)) |_| {
                std.log.debug("Directory created", .{});
            } else |err| {
                switch (err) {
                    error.PathAlreadyExists => {
                        std.log.info("Directory already exists", .{});
                    },
                    else => |e| {
                        return e;
                    },
                }
            }
        }

        var headers = try self.easy.createHeaders();
        defer headers.deinit();
        while (self.arguments.headers.next()) |h| {
            try headers.add(h, self.arguments.headers.next().?);
        }

        const err_file_path = try std.fmt.allocPrintZ(self.allocator, "{s}.err", .{self.arguments.ship_file});
        const err_file: *c.FILE = c.fopen(err_file_path, "wb");
        errdefer _ = c.fclose(err_file);
        _ = c.curl_easy_setopt(self.easy.handle, c.CURLOPT_STDERR, err_file);

        try self.easy.setUrl(try std.fmt.allocPrintZ(self.allocator, "{s}", .{self.arguments.url}));

        if (self.arguments.body) |body| {
            const result = if (std.mem.startsWith(u8, body, "@")) getBodyFromFile(body) else body;
            try self.easy.setPostFields(result);
        }

        if (self.arguments.show_headers == .all) try self.easy.setVerbose(true);
        try self.easy.setInsecure(self.arguments.insecure);
        try self.easy.setMethod(self.arguments.method);
        try self.easy.setHeaders(headers);
        var buf = curl.Buffer.init(self.allocator);
        try self.easy.setWritefunction(curl.bufferWriteCallback);
        try self.easy.setWritedata(&buf);

        var perform_result = try self.perform();
        perform_result.response.body = buf;
        defer perform_result.response.deinit();

        _ = c.fclose(err_file);

        try self.writeToShipFile(err_file_path, perform_result);
    }

    fn writeToShipFile(self: Shipper, err_file_path: []const u8, perform_result: PerformResult) !void {
        var file = try std.fs.openFileAbsolute(err_file_path, .{ .mode = .read_only });
        defer file.close();

        var buffer = std.ArrayList(u8).init(self.allocator);
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
        if (buffer.items.len > 0) try buffer.append('\n');

        if (self.arguments.show_headers == .res) {
            var iter = try perform_result.response.iterateHeaders(.{});
            while (try iter.next()) |header| {
                const line = try std.mem.concat(self.allocator, u8, &.{ header.name, " ", header.get(), "\n" });
                try buffer.appendSlice(line);
            }
            try buffer.append('\n');
        }

        var output_file = try std.fs.createFileAbsolute(self.arguments.ship_file, .{});
        defer output_file.close();

        try output_file.seekTo(0);
        try output_file.writeAll(buffer.items);

        if (perform_result.error_msg) |err| {
            _ = try output_file.write(err);
            return;
        }

        // TODO xml or json
        if (perform_result.response.body) |r| {
            const result = if (prettizy.json.isFormatted(r.items)) r.items else try prettizy.json.prettify(self.allocator, r.items, .{});
            _ = try output_file.write(result);
        }
    }

    fn getBodyFromFile(path: []const u8) ![]const u8 {
        var file = try std.fs.openFileAbsolute(path[1..], .{});
        defer file.close();
        const file_size = (try file.stat()).size;
        var buffer = try std.heap.page_allocator.alloc(u8, file_size);
        _ = try file.reader().readAll(buffer[0..]);
        return buffer;
    }
};
