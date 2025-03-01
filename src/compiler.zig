const std = @import("std");
const print = std.debug.print;
const Scanner = @import("scanner.zig").Scanner;
const Token = @import("scanner.zig").Token;

pub fn compile(source: []u8) void {
    const scanner = Scanner.init(source);
    var line: usize = -1;
    while (true) {
        const token = scanner.scanToken();
        if (token.line != line) {
            print("{d} ", .{token.line});
            line = token.line;
        } else {
            print("    | ", .{});
        }
        print("{d} ''\n", .{ token.type, token.length, token.start });

        if (token.type == Token.EOF) break;
    }
}
