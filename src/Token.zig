const std = @import("std");
const Allocator = std.mem.Allocator;

token_type: TokenType,
literal: []const u8,

const Self = @This();

pub fn init(token_type: TokenType, literal: []const u8) Self {
    return Self{
        .token_type = token_type,
        .literal = literal,
    };
}

//pub fn deinit(self: *Self) void {
//    _ = self;
//}

pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    if (fmt.len != 0) {
        std.fmt.invalidFmtError(fmt, self);
    }

    try writer.print("Token '{s}' : {s} ({d})", .{ self.literal, @tagName(self.token_type), @intFromEnum(self.token_type) });
}

pub const TokenType = enum(u8) {
    ILLEGAL,
    EOF,

    // Identifiers + literals
    IDENT,
    INT,

    // Operators
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,

    LT,
    GT,
    EQ,
    NOT_EQ,

    // Delimiters
    COMMA,
    SEMICOLON,

    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    // Keywords
    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,
};

const keywords = [_]struct { []const u8, TokenType }{
    .{ "fn", .FUNCTION },
    .{ "let", .LET },
    .{ "true", .TRUE },
    .{ "false", .FALSE },
    .{ "if", .IF },
    .{ "else", .ELSE },
    .{ "return", .RETURN },
};

pub fn lookupIdentifier(literal: []const u8) TokenType {
    inline for (keywords) |keyword| {
        if (std.mem.eql(u8, literal, keyword[0])) {
            return keyword[1];
        }
    }
    return .IDENT;
}
