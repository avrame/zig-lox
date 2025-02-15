const std = @import("std");
const ArrayList = std.ArrayList;
const Value = @import("./value.zig").Value;

pub const OpCode = enum(u8) {
    Constant,
    ConstantLong,
    Return,
};

const Line = struct {
    line: u16,
    count: u16,
};

pub const Chunk = struct {
    allocator: std.mem.Allocator,
    code: ArrayList(u8),
    constants: ArrayList(Value),
    lines: ArrayList(Line),
    last_line: u16,
    pub fn init(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
            .constants = ArrayList(Value).init(allocator),
            .lines = ArrayList(Line).init(allocator),
            .last_line = 0,
        };
    }

    pub fn deinit(chunk: *Chunk) void {
        chunk.code.deinit();
        chunk.constants.deinit();
        chunk.lines.deinit();
    }

    pub fn write(chunk: *Chunk, byte: u8, line: u16) !void {
        try chunk.code.append(byte);
        if (chunk.lines.items.len > 0 and chunk.lines.items[chunk.lines.items.len - 1].line == line) {
            chunk.lines.items[chunk.lines.items.len - 1].count += 1;
        } else {
            try chunk.lines.append(Line{ .line = line, .count = 1 });
        }
    }

    pub fn writeConstant(chunk: *Chunk, value: Value, line: u16) !void {
        if (chunk.constants.items.len > std.math.maxInt(u8)) {
            const constIdx = try chunk.addConstantLong(value);
            const constIdxBytes = std.mem.asBytes(&constIdx);
            try chunk.write(@intFromEnum(OpCode.ConstantLong), line);
            for (constIdxBytes) |byte| {
                try chunk.write(byte, line);
            }
        } else {
            const constIdx = try chunk.addConstant(value);
            try chunk.write(@intFromEnum(OpCode.Constant), line);
            try chunk.write(constIdx, line);
        }
    }

    pub fn addConstant(chunk: *Chunk, value: Value) !u8 {
        const index: u8 = @intCast(chunk.constants.items.len);
        try chunk.constants.append(value);
        return index;
    }

    pub fn addConstantLong(chunk: *Chunk, value: Value) !u24 {
        const index: u24 = @intCast(chunk.constants.items.len);
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

        const line: u16 = chunk.getLine(offset);
        if (line != chunk.last_line) {
            std.debug.print("{d: >4} ", .{line});
            chunk.last_line = line;
        } else {
            std.debug.print("   | ", .{});
        }

        const instruction: u8 = chunk.code.items[offset];
        switch (@as(OpCode, @enumFromInt(instruction))) {
            .Constant => return constantInstruction("OP_CONSTANT", chunk, offset),
            .ConstantLong => return constantLongInstruction("OP_CONSTANT_LONG", chunk, offset),
            .Return => return simpleInstruction("OP_RETURN", offset),
            // else => {
            //     std.debug.print("Unknown opcode %d\n", instruction);
            //     return offset + 1;
            // },
        }
    }

    fn getLine(chunk: *Chunk, offset: u32) u16 {
        var offsetVar: u32 = offset;
        for (chunk.lines.items) |line| {
            if (offsetVar < line.count) {
                return line.line;
            }
            offsetVar -= line.count;
        }
        return 0;
    }
};

fn simpleInstruction(name: []const u8, offset: u32) u32 {
    std.debug.print("{s}\n", .{name});
    return offset + 1;
}

fn constantInstruction(name: []const u8, chunk: *Chunk, offset: u32) u32 {
    const constantIdx: u8 = chunk.code.items[offset + 1];
    std.debug.print("{s: <16} {d: >4} '", .{ name, constantIdx });
    printValue(chunk.constants.items[constantIdx]);
    std.debug.print("'\n", .{});
    return offset + 2;
}

fn constantLongInstruction(name: []const u8, chunk: *Chunk, offset: u32) u32 {
    const constantIdxBytes = chunk.code.items[offset + 1 .. offset + 4];
    const constantIdx = combine_u8_to_u24(constantIdxBytes);
    std.debug.print("{s: <16} {d: >4} '", .{ name, constantIdx });
    printValue(chunk.constants.items[constantIdx]);
    std.debug.print("'\n", .{});
    return offset + 4;
}

fn combine_u8_to_u24(bytes: []u8) u24 {
    return (@as(u24, bytes[0]) << 16) | (@as(u24, bytes[1]) << 8) | @as(u24, bytes[2]);
}

fn printValue(value: Value) void {
    switch (value) {
        Value.Number => std.debug.print("{d}", .{value.Number}),
    }
}
