const std = @import("std");
const ArrayList = std.ArrayList;

pub const OpCode = enum(u8) {
    Return,
};

pub const Chunk = struct {
    allocator: std.mem.Allocator,
    code: ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
        };
    }

    pub fn deinit(self: *Chunk) void {
        self.code.deinit();
    }

    pub fn write(self: *Chunk, byte: u8) !void {
        try self.code.append(byte);
    }

    pub fn disassemble(self: *Chunk, name: []const u8) void {
        std.debug.print("== {s} ==\n", .{name});

        var offset: u32 = 0;
        while (offset < self.code.items.len) {
            offset = self.disassembleInstruction(offset);
        }
    }

    fn disassembleInstruction(self: *Chunk, offset: u32) u32 {
        std.debug.print("{d:0>4} ", .{offset});

        const instruction: u8 = self.code.items[offset];
        switch (@as(OpCode, @enumFromInt(instruction))) {
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
