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

    const val = Value{ .Number = 1.2 };
    const constantIdx = chunk.addConstant(val) catch unreachable;
    try chunk.write(@intFromEnum(OpCode.Constant));
    try chunk.write(constantIdx);

    try chunk.write(@intFromEnum(OpCode.Return));

    chunk.disassemble("test chunk");
}
