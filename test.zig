const std = @import("std");
const http = @import("http");
const json = @import("json");
const expect = @import("expect").expect;
const extras = @import("extras");
const Scheme = enum { http };

test {
    const allocator = std.testing.allocator;
    var req = try http.open(allocator, .GET, "http://he.net/");
    defer req.close(allocator);
    try req.writeUA();
    try req.send();
}

// zig fmt: off
test { try httpbinMethod(.http, .GET); }
test { try httpbinMethod(.http, .POST); }
test { try httpbinMethod(.http, .PUT); }
test { try httpbinMethod(.http, .PATCH); }
test { try httpbinMethod(.http, .DELETE); }
// zig fmt: on

fn httpbinMethod(comptime scheme: Scheme, comptime method: http.Method) !void {
    const allocator = std.testing.allocator;
    const url = @tagName(scheme) ++ "://httpbin.org/" ++ comptime extras.asciiLowerComptime(@tagName(method));
    var req = try http.open(allocator, method, url);
    defer req.close(allocator);
    try req.writeUA();
    try req.send();
    try expect(req.status).toEqual(.ok);
    const doc = try json.parse(allocator, "httpbinMethod", &req, .{ .support_trailing_commas = false, .maximum_depth = 2 });
    defer doc.deinit(allocator);
    doc.acquire();
    defer doc.release();
    try expect(doc.root.object().getS("url")).toEqualString(url);
}
