const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const Value = @import("value.zig").Value;
const VM = @import("vm.zig").VM;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var vm = try VM.init(allocator);
    defer vm.deinit();

    var chunk = try Chunk.init(allocator);
    defer chunk.deinit();

    try chunk.writeConstant(Value{ .Number = 1.2 }, 1);
    try chunk.writeConstant(Value{ .Number = 3.4 }, 1);
    try chunk.write(@intFromEnum(OpCode.ADD), 1);
    try chunk.writeConstant(Value{ .Number = 5.6 }, 1);
    try chunk.write(@intFromEnum(OpCode.DIVIDE), 1);
    try chunk.write(@intFromEnum(OpCode.NEGATE), 1);
    try chunk.write(@intFromEnum(OpCode.RETURN), 1);

    const result = vm.interpret(&chunk) catch .RUNTIME_ERROR;
    switch (result) {
        .OK => {},
        .COMPILE_ERROR => {
            std.debug.print("Compile error!\n", .{});
            return error.CompileError;
        },
        .RUNTIME_ERROR => {
            std.debug.print("Runtime error!\n", .{});
            return error.RuntimeError;
        },
    }

    // chunk.disassemble("test chunk");
}
