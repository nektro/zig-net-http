const std = @import("std");
const builtin = @import("builtin");
const net = @import("net");
const url = @import("url");
const nio = @import("nio");

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

    _,

    pub fn phrase(self: Status) ?[]const u8 {
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

            else => return null,
        };
    }
};

pub fn open(allocator: std.mem.Allocator, method: Method, input: []const u8) !ClientRequest {
    const u = try url.URL.parse(allocator, input, null);
    defer allocator.free(u.href);

    const addr: net.Address = switch (u.hostFancy()) {
        .unset => unreachable,
        .ipv4 => |int| .initIp4(@bitCast(int), u.portFancy().?),
        .ipv6 => |int| .initIp6(@bitCast(int), u.portFancy().?),
        .name => |hostname| blk: {
            const hostnamez = try allocator.dupeZ(u8, hostname);
            defer allocator.free(hostnamez);
            const portz = try std.fmt.allocPrintZ(allocator, "{d}", .{u.portFancy().?});
            defer allocator.free(portz);
            const gai = try net.getaddrinfo(hostnamez, portz, null);
            defer net.freeaddrinfo(gai);
            break :blk switch (gai.addr.?.family) {
                .INET => .{ .in = .{ .sa = @as(*net.Ip4Address.SockAddr, @ptrCast(@alignCast(gai.addr.?))).* } },
                .INET6 => .{ .in6 = .{ .sa = @as(*net.Ip6Address.SockAddr, @ptrCast(@alignCast(gai.addr.?))).* } },
                else => @panic("TODO"),
            };
        },
    };

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
        .headers_raw = "",
    };
}

pub const ClientRequest = struct {
    allocator: std.mem.Allocator,
    stream: net.Stream,
    writer: nio.BufferedWriter(4096, net.Stream),
    reader: nio.BufferedReader(4096, net.Stream),
    status: Status,
    headers_raw: []const u8,

    pub fn close(req: *const ClientRequest, allocator: std.mem.Allocator) void {
        req.stream.close();
        allocator.free(req.headers_raw);
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
        const status_int = std.fmt.parseInt(u16, &try req.readArray(3), 10) catch return error.Bad;
        const status = std.meta.intToEnum(Status, status_int) catch return error.Bad;
        if (!std.mem.eql(u8, &try req.readArray(1), " ")) return error.Bad;
        var phrase_buf: [64]u8 = undefined;
        const actual_phrase = try req.readUntilDelimitersBuf(&phrase_buf, "\r\n");
        if (status.phrase()) |phrase|
            if (!std.mem.eql(u8, actual_phrase, phrase))
                return error.Bad;
        req.status = status;

        var headers_list = std.ArrayList(u8).init(req.allocator);
        errdefer headers_list.deinit();
        while (true) {
            const header_len = try req.readUntilDelimitersArrayList(&headers_list, "\r\n", 1024);
            if (header_len == 0) break;
        }
        req.headers_raw = try headers_list.toOwnedSlice();
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
