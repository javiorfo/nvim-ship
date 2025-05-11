const curl = @import("curl");
const std = @import("std");
const prettizy = @import("prettizy");
const jwt = @import("jwt.zig");
const Arguments = @import("arguments.zig").Arguments;
pub const c = @cImport({
    @cInclude("curl/curl.h");
    @cInclude("stdio.h");
});

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

    /// This is an override of the zig-curl easy.perform() because I wanted to manage stderror
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
                        std.log.debug("Directory already exists", .{});
                    },
                    else => |e| {
                        return e;
                    },
                }
            }
        }

        // Set headers
        var headers = try self.easy.createHeaders();
        defer headers.deinit();
        var arg_headers = self.arguments.headers;
        var is_multipart = false;
        while (arg_headers.next()) |h| {
            const value = arg_headers.next().?;
            try headers.add(h, value);
            // Check if is multipart
            if (std.mem.eql(u8, h, "Content-Type") and std.mem.eql(u8, value, "multipart/form-data")) is_multipart = true;
        }

        // Manage verbose to a stderr file
        const err_file_path = try std.fmt.allocPrintZ(self.allocator, "{s}.err", .{self.arguments.ship_file});
        const err_file: *c.FILE = c.fopen(err_file_path, "wb").?;
        errdefer _ = c.fclose(err_file);
        _ = c.curl_easy_setopt(self.easy.handle, c.CURLOPT_STDERR, err_file);

        try self.easy.setUrl(try std.fmt.allocPrintZ(self.allocator, "{s}", .{self.arguments.url}));

        var multi_part: ?curl.Easy.MultiPart = null;
        if (self.arguments.body) |body| {
            if (!is_multipart) {
                // Plain body or from file
                const result = if (std.mem.startsWith(u8, body, "@")) try getBodyFromFile(body) else body;
                try self.easy.setPostFields(result);
            } else {
                // Multipart parser
                var lines = std.mem.splitSequence(u8, body, "&");
                multi_part = try self.easy.createMultiPart();
                while (lines.next()) |line| {
                    var field_value = std.mem.splitSequence(u8, line, "=");
                    const field = try std.fmt.allocPrintZ(self.allocator, "{s}", .{field_value.next().?});
                    const value = field_value.next().?;
                    const data_source: curl.Easy.MultiPart.DataSource = if (std.mem.startsWith(u8, value, "@")) .{ .file = try std.fmt.allocPrintZ(self.allocator, "{s}", .{value[1..]}) } else .{ .data = value };
                    try multi_part.?.addPart(field, data_source);
                    try self.easy.setMultiPart(multi_part.?);
                }
            }
        }
        defer if (multi_part) |m| m.deinit();

        if (self.arguments.show_headers == .all) try self.easy.setVerbose(true);
        try self.easy.setInsecure(self.arguments.insecure);
        try self.easy.setMethod(self.arguments.method);
        try self.easy.setHeaders(headers);
        var buf = curl.Buffer.init(self.allocator);
        try self.easy.setWritefunction(curl.bufferWriteCallback);
        try self.easy.setWritedata(&buf);

        // Start time to perform
        const start_time = std.time.milliTimestamp();

        var perform_result = try self.perform();
        perform_result.response.body = buf;
        defer perform_result.response.deinit();

        // End time to perform
        const end_time = std.time.milliTimestamp();

        // Ship status_code,time to a file
        try self.writeToCodeAndTimeFile(perform_result.response.status_code, start_time, end_time);

        _ = c.fclose(err_file);
        try self.writeToShipFile(err_file_path, perform_result);
    }

    fn writeToCodeAndTimeFile(self: Shipper, status_code: i32, start_time: i64, end_time: i64) !void {
        var file = try std.fs.createFileAbsolute("/tmp/ship_code_time_tmp", .{});
        defer file.close();
        const elapsed_time = end_time - start_time;
        const code_time = try std.fmt.allocPrint(self.allocator, "{d},{d:.4}", .{ status_code, @as(f64, @floatFromInt(elapsed_time)) / 1_000.0 });
        _ = try file.write(code_time);
    }

    fn writeToShipFile(self: Shipper, err_file_path: []const u8, perform_result: PerformResult) !void {
        const response = perform_result.response;
        // Err file read only
        var file = try std.fs.openFileAbsolute(err_file_path, .{ .mode = .read_only });
        defer file.close();

        var buffer = std.ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        // Get verbose or errors from stderr
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

        // Headers if show option es 'res'
        if (self.arguments.show_headers == .res) {
            var iter = try response.iterateHeaders(.{});
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

        // If error
        if (perform_result.error_msg) |err| {
            _ = try output_file.write(err);
            return;
        }

        // If response is good
        if (response.body) |r| {
            var send: []const u8 = r.items;
            if (std.mem.startsWith(u8, send, "{")) {
                send = if (prettizy.json.isFormatted(r.items)) r.items else try prettizy.json.prettify(self.allocator, r.items, .{});
            } else if (std.mem.startsWith(u8, send, "<")) {
                send = if (prettizy.xml.isFormatted(r.items)) r.items else try prettizy.xml.prettify(self.allocator, r.items, .{});
            }
            _ = try output_file.write(send);
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
