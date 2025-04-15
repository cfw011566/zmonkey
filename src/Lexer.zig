const std = @import("std");
const Allocator = std.mem.Allocator;
const Token = @import("Token.zig");

allocator: Allocator,
input: []const u8,
position: usize, // current position in input (points to current char)
read_position: usize, // current reading position in input (after current char)
ch: u8, // current char under examination

const Self = @This();

pub fn init(allocaotr: Allocator, input: []const u8) Self {
    return Self{
        .allocator = allocaotr,
        .input = input,
        .position = 0,
        .read_position = 0,
        .ch = 0,
    };
}

pub const Iterator = struct {
    lexer: *Self,

    pub fn next(it: *Iterator) ?Token {
        const token = it.lexer.nextToken();
        if (token.token_type == .EOF) {
            return null;
        }
        return token;
    }
};

pub fn iterator(self: *Self) Iterator {
    return Iterator{ .lexer = self };
}

pub fn nextToken(self: *Self) Token {
    self.readChar();

    self.skipWhitespace();

    const token_type, const token_literal = switch (self.ch) {
        '=' => blk: {
            if (self.peekChar() == '=') {
                const position = self.position;
                self.readChar();
                break :blk .{ .EQ, self.input[position .. self.position + 1] };
            } else {
                break :blk .{ .ASSIGN, self.input[self.position .. self.position + 1] };
            }
        },
        '+' => .{ .PLUS, self.input[self.position .. self.position + 1] },
        '-' => .{ .MINUS, self.input[self.position .. self.position + 1] },
        '!' => blk: {
            if (self.peekChar() == '=') {
                const position = self.position;
                self.readChar();
                break :blk .{ .NOT_EQ, self.input[position .. self.position + 1] };
            } else {
                break :blk .{ .BANG, self.input[self.position .. self.position + 1] };
            }
        },
        '/' => .{ .SLASH, self.input[self.position .. self.position + 1] },
        '*' => .{ .ASTERISK, self.input[self.position .. self.position + 1] },
        '<' => .{ .LT, self.input[self.position .. self.position + 1] },
        '>' => .{ .GT, self.input[self.position .. self.position + 1] },
        ';' => .{ .SEMICOLON, self.input[self.position .. self.position + 1] },
        ',' => .{ .COMMA, self.input[self.position .. self.position + 1] },
        '(' => .{ .LPAREN, self.input[self.position .. self.position + 1] },
        ')' => .{ .RPAREN, self.input[self.position .. self.position + 1] },
        '{' => .{ .LBRACE, self.input[self.position .. self.position + 1] },
        '}' => .{ .RBRACE, self.input[self.position .. self.position + 1] },
        0 => .{ .EOF, self.input[self.position..self.position] },
        else => blk: {
            if (isLetter(self.ch)) {
                const literal = self.readIdentifier();
                break :blk .{ Token.lookupIdentifier(literal), literal };
            } else if (isDigit(self.ch)) {
                const literal = self.readNumber();
                break :blk .{ .INT, literal };
            } else {
                break :blk .{ .ILLEGAL, self.input[self.position .. self.position + 1] };
            }
        },
    };
    return Token.init(token_type, token_literal);
}

fn readChar(self: *Self) void {
    if (self.read_position >= self.input.len) {
        self.ch = 0;
    } else {
        self.ch = self.input[self.read_position];
    }
    self.position = self.read_position;
    self.read_position += 1;
}

fn peekChar(self: Self) u8 {
    if (self.read_position >= self.input.len) {
        return 0;
    } else {
        return self.input[self.read_position];
    }
}

fn readIdentifier(self: *Self) []const u8 {
    const position = self.position;
    while (isLetter(self.ch)) {
        self.readChar();
    }
    self.read_position -= 1;
    return self.input[position..self.position];
}

fn isLetter(ch: u8) bool {
    return switch (ch) {
        'a'...'z', 'A'...'Z', '_' => true,
        else => false,
    };
}

fn skipWhitespace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\r' or self.ch == '\n' or self.ch == '\t') {
        self.readChar();
    }
}

fn readNumber(self: *Self) []const u8 {
    const position = self.position;
    while (isDigit(self.ch)) {
        self.readChar();
    }
    self.read_position -= 1;
    return self.input[position..self.position];
}

fn isDigit(ch: u8) bool {
    return switch (ch) {
        '0'...'9' => true,
        else => false,
    };
}

test "test next token" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
    ;
    const tests = [_]struct { Token.TokenType, []const u8 }{
        .{ .LET, "let" },
        .{ .IDENT, "five" },
        .{ .ASSIGN, "=" },
        .{ .INT, "5" },
        .{ .SEMICOLON, ";" },
        .{ .LET, "let" },
        .{ .IDENT, "ten" },
        .{ .ASSIGN, "=" },
        .{ .INT, "10" },
        .{ .SEMICOLON, ";" },
        .{ .LET, "let" },
        .{ .IDENT, "add" },
        .{ .ASSIGN, "=" },
        .{ .FUNCTION, "fn" },
        .{ .LPAREN, "(" },
        .{ .IDENT, "x" },
        .{ .COMMA, "," },
        .{ .IDENT, "y" },
        .{ .RPAREN, ")" },
        .{ .LBRACE, "{" },
        .{ .IDENT, "x" },
        .{ .PLUS, "+" },
        .{ .IDENT, "y" },
        .{ .SEMICOLON, ";" },
        .{ .RBRACE, "}" },
        .{ .SEMICOLON, ";" },
        .{ .LET, "let" },
        .{ .IDENT, "result" },
        .{ .ASSIGN, "=" },
        .{ .IDENT, "add" },
        .{ .LPAREN, "(" },
        .{ .IDENT, "five" },
        .{ .COMMA, "," },
        .{ .IDENT, "ten" },
        .{ .RPAREN, ")" },
        .{ .SEMICOLON, ";" },
        .{ .BANG, "!" },
        .{ .MINUS, "-" },
        .{ .SLASH, "/" },
        .{ .ASTERISK, "*" },
        .{ .INT, "5" },
        .{ .SEMICOLON, ";" },
        .{ .INT, "5" },
        .{ .LT, "<" },
        .{ .INT, "10" },
        .{ .GT, ">" },
        .{ .INT, "5" },
        .{ .SEMICOLON, ";" },
        .{ .IF, "if" },
        .{ .LPAREN, "(" },
        .{ .INT, "5" },
        .{ .LT, "<" },
        .{ .INT, "10" },
        .{ .RPAREN, ")" },
        .{ .LBRACE, "{" },
        .{ .RETURN, "return" },
        .{ .TRUE, "true" },
        .{ .SEMICOLON, ";" },
        .{ .RBRACE, "}" },
        .{ .ELSE, "else" },
        .{ .LBRACE, "{" },
        .{ .RETURN, "return" },
        .{ .FALSE, "false" },
        .{ .SEMICOLON, ";" },
        .{ .RBRACE, "}" },
        .{ .INT, "10" },
        .{ .EQ, "==" },
        .{ .INT, "10" },
        .{ .SEMICOLON, ";" },
        .{ .INT, "10" },
        .{ .NOT_EQ, "!=" },
        .{ .INT, "9" },
        .{ .SEMICOLON, ";" },
        .{ .EOF, "" },
    };
    const allocator = std.testing.allocator;
    var lexer = Self.init(allocator, input);
    for (tests, 0..) |tt, i| {
        var tok = lexer.nextToken();
        defer tok.deinit();
        std.debug.print("Test {d}: {}\n", .{ i, tt[0] });
        try std.testing.expectEqual(tt[0], tok.token_type);
        try std.testing.expect(std.mem.eql(u8, tok.literal, tt[1]));
    }
}
