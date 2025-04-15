const std = @import("std");
const Allocator = std.mem.Allocator;
const Lexer = @import("Lexer.zig");

const PROMPT = ">> ";

pub fn start(allocator: Allocator, in: std.fs.File, out: std.fs.File) !void {
    const stdout_file = out.writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Hello user! This is the Monkey programming language!\n", .{});
    try stdout.print("Fell free to type in commands\n", .{});
    try bw.flush();
    var buffer: [1024]u8 = undefined;
    while (true) {
        try out.writeAll(PROMPT);
        const line = try in.reader().readUntilDelimiterOrEof(&buffer, '\n');
        if (line == null or line.?.len == 0) {
            break;
        }
        var lexer = Lexer.init(allocator, line.?);
        var iter = lexer.iterator();
        while (iter.next()) |token| {
            try stdout.print("{any}\n", .{token});
            try bw.flush();
        }
    }
}
