const std = @import("std");
const ArrayList = std.ArrayList;
const Value = @import("./value.zig").Value;

pub const OpCode = enum(u8) {
    Constant,
    Return,
};

pub const Chunk = struct {
    allocator: std.mem.Allocator,
    code: ArrayList(u8),
    constants: ArrayList(Value),

    pub fn init(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
            .constants = ArrayList(Value).init(allocator),
        };
    }

    pub fn deinit(chunk: *Chunk) void {
        chunk.code.deinit();
        chunk.constants.deinit();
    }

    pub fn write(chunk: *Chunk, byte: u8) !void {
        try chunk.code.append(byte);
    }

    pub fn addConstant(chunk: *Chunk, value: Value) !u8 {
        const index: u8 = @intCast(chunk.constants.items.len);
        try chunk.constants.append(value);
        return index;
    }

    pub fn disassemble(chunk: *Chunk, name: []const u8) void {
        std.debug.print("== {s} ==\n", .{name});

        var offset: u32 = 0;
        while (offset < chunk.code.items.len) {
            offset = chunk.disassembleInstruction(offset);
        }
    }

    fn disassembleInstruction(chunk: *Chunk, offset: u32) u32 {
        std.debug.print("{d:0>4} ", .{offset});

        const instruction: u8 = chunk.code.items[offset];
        switch (@as(OpCode, @enumFromInt(instruction))) {
            .Constant => return constantInstruction("OP_CONSTANT", chunk, offset),
            .Return => return simpleInstruction("OP_RETURN", offset),
            // else => {
            //     std.debug.print("Unknown opcode %d\n", instruction);
            //     return offset + 1;
            // },
        }
    }
};

fn simpleInstruction(name: []const u8, offset: u32) u32 {
    std.debug.print("{s}\n", .{name});
    return offset + 1;
}

fn constantInstruction(name: []const u8, chunk: *Chunk, offset: u32) u32 {
    const constantIdx: u8 = chunk.code.items[offset + 1];
    std.debug.print("{s} {d:0>4} '", .{ name, constantIdx });
    printValue(chunk.constants.items[constantIdx]);
    std.debug.print("'\n", .{});
    return offset + 2;
}

fn printValue(value: Value) void {
    switch (value) {
        Value.Number => std.debug.print("{d}", .{value.Number}),
    }
}
