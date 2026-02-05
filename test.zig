const std = @import("std");
const http = @import("http");
const json = @import("json");
const expect = @import("expect").expect;
const Scheme = enum { http };

test {
    const allocator = std.testing.allocator;
    var req = try http.open(allocator, .GET, "http://he.net/");
    defer req.close(allocator);
    try req.writeUA();
    try req.send();
}

// zig fmt: off
test { try httpbinMethodGet(.http); }
// zig fmt: on

fn httpbinMethodGet(comptime scheme: Scheme) !void {
    const allocator = std.testing.allocator;
    const url = @tagName(scheme) ++ "://httpbin.org/get";
    var req = try http.open(allocator, .GET, url);
    defer req.close(allocator);
    try req.writeUA();
    try req.send();
    const doc = try json.parse(allocator, "httpbinMethodGet", &req, .{ .support_trailing_commas = false, .maximum_depth = 2 });
    defer doc.deinit(allocator);
    doc.acquire();
    defer doc.release();
    try expect(doc.root.object().getS("url")).toEqualString(url);
}
