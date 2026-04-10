const std = @import("std");
const builtin = @import("builtin");
const net = @import("net");
const url = @import("url");
const nio = @import("nio");
const extras = @import("extras");
const nfs = @import("nfs");

pub const Method = enum {
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
    CONNECT,
    OPTIONS,
    TRACE,
    PATCH,
};

pub const Status = enum(u10) {
    @"continue" = 100, // RFC7231, Section 6.2.1
    switching_protocols = 101, // RFC7231, Section 6.2.2
    processing = 102, // RFC2518
    early_hints = 103, // RFC8297

    ok = 200, // RFC7231, Section 6.3.1
    created = 201, // RFC7231, Section 6.3.2
    accepted = 202, // RFC7231, Section 6.3.3
    non_authoritative_info = 203, // RFC7231, Section 6.3.4
    no_content = 204, // RFC7231, Section 6.3.5
    reset_content = 205, // RFC7231, Section 6.3.6
    partial_content = 206, // RFC7233, Section 4.1
    multi_status = 207, // RFC4918
    already_reported = 208, // RFC5842
    im_used = 226, // RFC3229

    multiple_choice = 300, // RFC7231, Section 6.4.1
    moved_permanently = 301, // RFC7231, Section 6.4.2
    found = 302, // RFC7231, Section 6.4.3
    see_other = 303, // RFC7231, Section 6.4.4
    not_modified = 304, // RFC7232, Section 4.1
    use_proxy = 305, // RFC7231, Section 6.4.5
    temporary_redirect = 307, // RFC7231, Section 6.4.7
    permanent_redirect = 308, // RFC7538

    bad_request = 400, // RFC7231, Section 6.5.1
    unauthorized = 401, // RFC7235, Section 3.1
    payment_required = 402, // RFC7231, Section 6.5.2
    forbidden = 403, // RFC7231, Section 6.5.3
    not_found = 404, // RFC7231, Section 6.5.4
    method_not_allowed = 405, // RFC7231, Section 6.5.5
    not_acceptable = 406, // RFC7231, Section 6.5.6
    proxy_auth_required = 407, // RFC7235, Section 3.2
    request_timeout = 408, // RFC7231, Section 6.5.7
    conflict = 409, // RFC7231, Section 6.5.8
    gone = 410, // RFC7231, Section 6.5.9
    length_required = 411, // RFC7231, Section 6.5.10
    precondition_failed = 412, // RFC7232, Section 4.2][RFC8144, Section 3.2
    payload_too_large = 413, // RFC7231, Section 6.5.11
    uri_too_long = 414, // RFC7231, Section 6.5.12
    unsupported_media_type = 415, // RFC7231, Section 6.5.13][RFC7694, Section 3
    range_not_satisfiable = 416, // RFC7233, Section 4.4
    expectation_failed = 417, // RFC7231, Section 6.5.14
    teapot = 418, // RFC 7168, 2.3.3
    misdirected_request = 421, // RFC7540, Section 9.1.2
    unprocessable_entity = 422, // RFC4918
    locked = 423, // RFC4918
    failed_dependency = 424, // RFC4918
    too_early = 425, // RFC8470
    upgrade_required = 426, // RFC7231, Section 6.5.15
    precondition_required = 428, // RFC6585
    too_many_requests = 429, // RFC6585
    request_header_fields_too_large = 431, // RFC6585
    unavailable_for_legal_reasons = 451, // RFC7725

    internal_server_error = 500, // RFC7231, Section 6.6.1
    not_implemented = 501, // RFC7231, Section 6.6.2
    bad_gateway = 502, // RFC7231, Section 6.6.3
    service_unavailable = 503, // RFC7231, Section 6.6.4
    gateway_timeout = 504, // RFC7231, Section 6.6.5
    http_version_not_supported = 505, // RFC7231, Section 6.6.6
    variant_also_negotiates = 506, // RFC2295
    insufficient_storage = 507, // RFC4918
    loop_detected = 508, // RFC5842
    not_extended = 510, // RFC2774
    network_authentication_required = 511, // RFC6585

    pub fn phrase(self: Status) []const u8 {
        return switch (self) {
            // 1xx statuses
            .@"continue" => "Continue",
            .switching_protocols => "Switching Protocols",
            .processing => "Processing",
            .early_hints => "Early Hints",

            // 2xx statuses
            .ok => "OK",
            .created => "Created",
            .accepted => "Accepted",
            .non_authoritative_info => "Non-Authoritative Information",
            .no_content => "No Content",
            .reset_content => "Reset Content",
            .partial_content => "Partial Content",
            .multi_status => "Multi-Status",
            .already_reported => "Already Reported",
            .im_used => "IM Used",

            // 3xx statuses
            .multiple_choice => "Multiple Choice",
            .moved_permanently => "Moved Permanently",
            .found => "Found",
            .see_other => "See Other",
            .not_modified => "Not Modified",
            .use_proxy => "Use Proxy",
            .temporary_redirect => "Temporary Redirect",
            .permanent_redirect => "Permanent Redirect",

            // 4xx statuses
            .bad_request => "Bad Request",
            .unauthorized => "Unauthorized",
            .payment_required => "Payment Required",
            .forbidden => "Forbidden",
            .not_found => "Not Found",
            .method_not_allowed => "Method Not Allowed",
            .not_acceptable => "Not Acceptable",
            .proxy_auth_required => "Proxy Authentication Required",
            .request_timeout => "Request Timeout",
            .conflict => "Conflict",
            .gone => "Gone",
            .length_required => "Length Required",
            .precondition_failed => "Precondition Failed",
            .payload_too_large => "Payload Too Large",
            .uri_too_long => "URI Too Long",
            .unsupported_media_type => "Unsupported Media Type",
            .range_not_satisfiable => "Range Not Satisfiable",
            .expectation_failed => "Expectation Failed",
            .teapot => "I'm a teapot",
            .misdirected_request => "Misdirected Request",
            .unprocessable_entity => "Unprocessable Entity",
            .locked => "Locked",
            .failed_dependency => "Failed Dependency",
            .too_early => "Too Early",
            .upgrade_required => "Upgrade Required",
            .precondition_required => "Precondition Required",
            .too_many_requests => "Too Many Requests",
            .request_header_fields_too_large => "Request Header Fields Too Large",
            .unavailable_for_legal_reasons => "Unavailable For Legal Reasons",

            // 5xx statuses
            .internal_server_error => "Internal Server Error",
            .not_implemented => "Not Implemented",
            .bad_gateway => "Bad Gateway",
            .service_unavailable => "Service Unavailable",
            .gateway_timeout => "Gateway Timeout",
            .http_version_not_supported => "HTTP Version Not Supported",
            .variant_also_negotiates => "Variant Also Negotiates",
            .insufficient_storage => "Insufficient Storage",
            .loop_detected => "Loop Detected",
            .not_extended => "Not Extended",
            .network_authentication_required => "Network Authentication Required",
        };
    }

    pub fn digits(self: Status) [3]u8 {
        var result: [3]u8 = undefined;
        result[0] = @intCast((@intFromEnum(self) / 100) + '0');
        result[1] = @intCast((@intFromEnum(self) / 10 % 10) + '0');
        result[2] = @intCast((@intFromEnum(self) % 10) + '0');
        return result;
    }
};

pub fn open(allocator: std.mem.Allocator, method: Method, input: []const u8) !ClientRequest {
    const u = try url.URL.parse(allocator, input, null);
    defer allocator.free(u.href);

    const addr: net.Address = .fromUrl(&u, allocator);

    const conn = try addr.tcpConnect();
    errdefer conn.close();

    var bufw: nio.BufferedWriter(4096, net.Stream) = .init(conn);

    try bufw.writeAll(@tagName(method));
    try bufw.writeAll(" ");
    try bufw.writeAll(u.pathname);
    try bufw.writeAll(" ");
    try bufw.writeAll("HTTP/1.1");
    try bufw.writeAll("\r\n");

    try bufw.writeAll("Host: ");
    try bufw.writeAll(u.hostname);
    try bufw.writeAll("\r\n");

    try bufw.writeAll("Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n");

    try bufw.writeAll("Connection: close\r\n");

    return .{
        .allocator = allocator,
        .stream = conn,
        .writer = bufw,
        .reader = .init(conn),
        .status = @enumFromInt(0),
        .headers = .init(allocator),
    };
}

pub const ClientRequest = struct {
    allocator: std.mem.Allocator,
    stream: net.Stream,
    writer: nio.BufferedWriter(4096, net.Stream),
    reader: nio.BufferedReader(4096, net.Stream),
    status: Status,
    headers: HeadersMap,

    pub fn close(req: *ClientRequest) void {
        req.stream.close();
        req.headers.deinit();
    }

    pub fn writeHeader(req: *ClientRequest, name: []const u8, value: []const u8) !void {
        try req.writer.writeAll(name);
        try req.writer.writeAll(": ");
        try req.writer.writeAll(value);
        try req.writer.writeAll("\r\n");
    }

    pub fn writeUA(req: *ClientRequest) !void {
        return req.writeHeader(
            "User-Agent",
            (if (builtin.is_test) "WIP " else "") ++ "https://github.com/nektro/zig-net-http",
        );
    }

    pub fn send(req: *ClientRequest) !void {
        try req.writer.writeAll("\r\n");
        try req.writer.flush();

        // HTTP/1.1 200 OK
        if (!std.mem.eql(u8, &try req.readArray(9), "HTTP/1.1 ")) return error.Bad;
        const status_int = extras.parseDigits(u16, &try req.readArray(3), 10) catch return error.Bad;
        const status = std.meta.intToEnum(Status, status_int) catch return error.Bad;
        if (!std.mem.eql(u8, &try req.readArray(1), " ")) return error.Bad;
        var phrase_buf: [64]u8 = undefined;
        _ = try req.readUntilDelimitersBuf(&phrase_buf, "\r\n");
        req.status = status;

        var headers_list = req.headers.data.list.toManaged(req.allocator);
        defer req.headers.data.list = headers_list.moveToUnmanaged();
        while (true) {
            const header_line = try req.readUntilDelimitersArrayList(&headers_list, "\r\n", 1024);
            if (header_line.len == 0) break;
            const colon_pos = std.mem.indexOfScalar(u8, header_line, ':') orelse return error.Bad;
            const name = header_line[0..colon_pos];
            if (!extras.matchesAll(u8, name, std.ascii.isAscii)) return error.Bad;
            for (name) |*c| c.* = std.ascii.toLower(c.*);
            if (header_line.len == colon_pos or header_line[colon_pos + 1] != ' ') return error.Bad;
            const value = header_line[colon_pos + 2 ..];
            try req.headers.data.lengths.appendSlice(req.allocator, &.{ name.len, 2, value.len, 2 });
        }
    }

    pub const ReadError = net.Stream.ReadError;
    pub usingnamespace nio.Readable(@This(), ._var);
    pub fn read(req: *ClientRequest, buffer: []u8) ReadError!usize {
        return req.reader.read(buffer);
    }
    pub fn anyReadable(self: *ClientRequest) nio.AnyReadable {
        const S = struct {
            fn read(s: *allowzero anyopaque, buffer: []u8) anyerror!usize {
                const req: *ClientRequest = @ptrCast(@alignCast(s));
                return req.read(buffer);
            }
        };
        return .{
            .vtable = &.{ .read = S.read },
            .state = @ptrCast(self),
        };
    }
};

pub const HeadersMap = struct {
    data: extras.ManyArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) HeadersMap {
        return .{
            .data = .init(allocator),
        };
    }

    pub fn deinit(map: *HeadersMap) void {
        map.data.deinit();
    }

    fn findIndex(map: *const HeadersMap, n: []const u8) ?usize {
        for (n) |c| switch (c) {
            'a'...'z', '-' => {},
            else => unreachable,
        };
        for (0..map.count()) |i| {
            if (std.mem.eql(u8, map.name(i), n)) {
                return i;
            }
        }
        return null;
    }

    pub fn append(map: *HeadersMap, n: []const u8, v: []const u8) !void {
        if (map.findIndex(n)) |i| {
            try map.data.appendSlice(i * 4 + 2, ", ");
            try map.data.appendSlice(i * 4 + 2, v);
            return;
        }
        try map.data.appendSlice(try map.data.add(), n);
        try map.data.appendSlice(try map.data.add(), ": ");
        try map.data.appendSlice(try map.data.add(), v);
        try map.data.appendSlice(try map.data.add(), "\r\n");
    }

    pub fn set(map: *HeadersMap, n: []const u8, v: []const u8) !void {
        if (map.findIndex(n)) |i| {
            try map.data.set(i * 4 + 2, v);
            return;
        }
        try map.data.appendSlice(try map.data.add(), n);
        try map.data.appendSlice(try map.data.add(), ": ");
        try map.data.appendSlice(try map.data.add(), v);
        try map.data.appendSlice(try map.data.add(), "\r\n");
    }

    pub fn remove(map: *HeadersMap, n: []const u8) void {
        const i = map.findIndex(n) orelse return;
        map.data.remove(i * 4);
        map.data.remove(i * 4);
        map.data.remove(i * 4);
        map.data.remove(i * 4);
    }

    pub fn count(map: *const HeadersMap) usize {
        return map.data.lengths.items.len / 4;
    }

    pub fn name(map: *const HeadersMap, idx: usize) []const u8 {
        return map.data.items(idx * 4 + 0);
    }

    pub fn value(map: *const HeadersMap, idx: usize) []const u8 {
        return map.data.items(idx * 4 + 2);
    }

    pub fn find(map: *const HeadersMap, needle: []const u8) ?[]const u8 {
        for (0..map.count()) |i| {
            if (std.mem.eql(u8, map.name(i), needle)) {
                return map.value(i);
            }
        }
        return null;
    }
};

pub const Server = struct {
    conn: net.Server.Connection,
    reader: nio.BufferedReader(4096, net.Stream),
    writer: nio.BufferedWriter(4096, net.Stream),
    state: enum {
        ready,
        receiving_head,
        received_head,
    },

    pub fn init(conn: net.Server.Connection) Server {
        return .{
            .conn = conn,
            .reader = .init(conn.stream),
            .writer = .init(conn.stream),
            .state = .ready,
        };
    }

    pub fn receiveHead(server: *Server, allocator: std.mem.Allocator) !ServerRequest {
        std.debug.assert(server.state == .ready);
        server.state = .receiving_head;
        var scratch_buffer: [8192]u8 = undefined;

        const method_s = try server.reader.readUntilDelimitersBuf(&scratch_buffer, " ");
        const method = std.meta.stringToEnum(Method, method_s) orelse return error.InvalidRequest;

        const target_s = try server.reader.readUntilDelimitersBuf(&scratch_buffer, " ");
        const target_url_root: url.URL = .{
            .href = "file:///",
            .protocol = "file:",
            .username = "",
            .password = "",
            .hostname = "",
            .hostname_kind = .unset,
            .port = "",
            .host = "",
            .pathname = "/",
            .search = "",
            .hash = "",
            .has_opaque_path = false,
        };
        const target_url = try url.URL.parseBasic(allocator, target_s, &target_url_root, null);
        errdefer allocator.free(target_url.href);

        const version_s = try server.reader.readUntilDelimitersBuf(&scratch_buffer, "\r\n");
        if (version_s.len != 8) return error.InvalidRequest;
        if (std.mem.bytesToValue(u64, version_s[0..8]) != comptime std.mem.bytesToValue(u64, "HTTP/1.1")) return error.InvalidRequest;

        var headers: HeadersMap = .init(allocator);
        errdefer headers.deinit();
        try headers.data.list.ensureUnusedCapacity(allocator, 512);
        try headers.data.lengths.ensureUnusedCapacity(allocator, 40);

        while (true) {
            const line = try server.reader.readUntilDelimitersBuf(&scratch_buffer, "\r\n");
            if (line.len == 0) break;
            const name_end = std.mem.indexOfScalar(u8, line, ':') orelse return error.InvalidRequest;
            const name = line[0..name_end];
            for (name) |*c| {
                switch (c.*) {
                    'A'...'Z' => {},
                    'a'...'z' => {},
                    '0'...'9' => {},
                    '-' => {},
                    else => return error.InvalidRequest,
                }
                switch (c.*) {
                    'A'...'Z' => c.* = c.* - 'A' + 'a',
                    else => {},
                }
            }
            const value = std.mem.trim(u8, line[name_end + 1 ..], " ");
            try headers.append(name, value);
        }
        server.state = .received_head;

        return .{
            .server = server,
            .method = method,
            .target = target_url,
            .headers = headers,
        };
    }
};

pub const ServerRequest = struct {
    server: *Server,
    method: Method,
    target: url.URL,
    headers: HeadersMap,

    pub fn deinit(req: *ServerRequest, allocator: std.mem.Allocator) void {
        allocator.free(req.target.href);
        req.headers.deinit();
    }

    pub fn readAllAlloc(req: *ServerRequest, allocator: std.mem.Allocator, max_size: usize) ![]u8 {
        if (req.headers.find("content-length")) |s| {
            const content_length = try extras.parseDigits(u64, s, 10);
            if (content_length > max_size) return error.StreamTooLong;
            var list: std.ArrayListUnmanaged(u8) = .{};
            try list.ensureUnusedCapacity(allocator, content_length);
            var total: usize = 0;
            while (total < content_length) {
                const len = try req.server.reader.read(list.items.ptr[total..list.capacity]);
                if (len == 0) break;
                total += len;
                list.items.len += len;
            }
            return list.toOwnedSlice(allocator);
        }
        if (req.headers.find("transfer-encoding")) |s| {
            if (std.mem.eql(u8, s, "chunked")) {
                return error.TEChunked;
            }
            return error.TE;
        }
        return "";
    }

    pub fn pipeTo(req: *ServerRequest, writable: anytype, max_size: ?usize) !void {
        if (req.headers.find("content-length")) |s| {
            const content_length = try extras.parseDigits(u64, s, 10);
            if (max_size) |max| if (content_length > max) return error.StreamTooLong;
            var total: usize = 0;
            var scratch_buffer: [4096]u8 = undefined;
            while (total < content_length) {
                const len = try req.server.reader.read(&scratch_buffer);
                if (len == 0) break;
                total += len;
                try writable.writeAll(scratch_buffer[0..len]);
            }
            return;
        }
        if (req.headers.find("transfer-encoding")) |s| {
            if (std.mem.eql(u8, s, "chunked")) {
                return error.TEChunked;
            }
            return error.TE;
        }
    }

    pub fn respondFull(req: *ServerRequest, status: Status, headers: *HeadersMap, body: []const u8) !void {
        try req.server.writer.writevAll(&.{ "HTTP/1.1", " ", &status.digits(), " ", status.phrase(), "\r\n" });

        try headers.set("connection", "close");
        headers.remove("content-length");
        try req.server.writer.writeAll(headers.data.list.items);
        try req.server.writer.writeAll("content-length: ");
        try req.server.writer.writeIntPretty(body.len, 10, .lower);
        try req.server.writer.writeAll("\r\n");

        try req.server.writer.writeAll("\r\n");
        try req.server.writer.writeAll(body);
    }

    pub fn respondStreaming(req: *ServerRequest, status: Status, headers: *HeadersMap, body_length: ?u64) !void {
        try req.server.writer.writevAll(&.{ "HTTP/1.1", " ", &status.digits(), " ", status.phrase(), "\r\n" });

        headers.remove("connection");
        headers.remove("content-length");
        headers.remove("transfer-encoding");
        try req.server.writer.writeAll(headers.data.list.items);
        try req.server.writer.writeAll("connection: close\r\n");
        if (body_length) |len| {
            try req.server.writer.writeAll("content-length: ");
            try req.server.writer.writeIntPretty(len, 10, .lower);
            try req.server.writer.writeAll("\r\n");
        } else {
            try req.server.writer.writeAll("transfer-encoding: chunked\r\n");
        }

        try req.server.writer.writeAll("\r\n");
    }

    pub fn sendfile(req: *ServerRequest, file: nfs.File, offset: net.off_t, count: ?usize) !void {
        return req.server.conn.stream.sendfile(file, offset, count);
    }
};
