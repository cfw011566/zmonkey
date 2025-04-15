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

pub fn deinit(self: *Self) void {
    _ = self;
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

const Keyword = struct {
    string: []const u8,
    token_type: TokenType,
};

const keywords = [_]Keyword{
    .{ .string = "fn", .token_type = .FUNCTION },
    .{ .string = "let", .token_type = .LET },
    .{ .string = "true", .token_type = .TRUE },
    .{ .string = "false", .token_type = .FALSE },
    .{ .string = "if", .token_type = .IF },
    .{ .string = "else", .token_type = .ELSE },
    .{ .string = "return", .token_type = .RETURN },
};

pub fn lookupIdentifier(literal: []const u8) TokenType {
    for (keywords) |keyword| {
        if (std.mem.eql(u8, literal, keyword.string)) {
            return keyword.token_type;
        }
    }
    return .IDENT;
}
