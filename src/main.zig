const std = @import("std");
const Allocator = std.mem.Allocator;
const Repl = @import("Repl.zig");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const in = std.io.getStdIn();
    const out = std.io.getStdOut();

    Repl.start(allocator, in, out) catch {
        std.debug.print("Error\n", .{});
    };
}
