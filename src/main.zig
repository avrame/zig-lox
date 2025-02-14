const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const Value = @import("value.zig").Value;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var chunk = Chunk.init(allocator);
    defer chunk.deinit();

    const val1 = Value{ .Number = 1.2 };
    const constantIdx1 = chunk.addConstant(val1) catch unreachable;
    try chunk.write(@intFromEnum(OpCode.Constant), 1);
    try chunk.write(constantIdx1, 1);

    const val2 = Value{ .Number = 3.1415 };
    const constantIdx2 = chunk.addConstant(val2) catch unreachable;
    try chunk.write(@intFromEnum(OpCode.Constant), 2);
    try chunk.write(constantIdx2, 2);

    try chunk.write(@intFromEnum(OpCode.Return), 2);
    try chunk.write(@intFromEnum(OpCode.Return), 3);

    chunk.disassemble("test chunk");
}
