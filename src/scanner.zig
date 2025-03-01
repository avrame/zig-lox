const scanner: Scanner = undefined;

const Token = struct {
    type: TokenType,
    start: *u8,
    length: usize,
    line: usize,
};

const TokenType = enum {
    // Single-character tokens.
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,

    // One or two character tokens.
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals.
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords.
    AND,
    CLASS,
    ELSE,
    FALSE,
    FOR,
    FUN,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    ERROR,
    EOF,
};

const Scanner = struct {
    start: *u8,
    current: *u8,
    line: usize,

    pub fn init(source: *[]u8) Scanner {
        return .{
            .start = source,
            .current = source,
            .line = 1,
        };
    }

    pub fn scanToken(scanner: *Scanner) Token {
        scanner.start = scanner.current;

        if (isAtEnd()) return makeToken(Token.EOF);

        return errorToken("Unexpected character.");
    }
};
