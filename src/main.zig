const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var chunk = Chunk.init(allocator);
    defer chunk.deinit();

    try chunk.write(@intFromEnum(OpCode.Return));
    chunk.disassemble("test chunk");
}
