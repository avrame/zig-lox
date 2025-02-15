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

    try chunk.writeConstant(Value{ .Number = 1.2 }, 1);
    try chunk.writeConstant(Value{ .Number = 3.1415 }, 2);

    try chunk.write(@intFromEnum(OpCode.Return), 2);
    try chunk.write(@intFromEnum(OpCode.Return), 3);

    chunk.disassemble("test chunk");
}
