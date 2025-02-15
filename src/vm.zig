const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const chunkModule = @import("chunk.zig");
const Chunk = chunkModule.Chunk;
const OpCode = chunkModule.OpCode;
const printValue = chunkModule.printValue;
const Value = @import("value.zig").Value;
const debug = @import("debug.zig");

pub const InterpretResult = enum {
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
};

pub const VM = struct {
    chunk: *Chunk,
    ip: usize,
    allocator: std.mem.Allocator,
    stack: ArrayList(Value),

    pub fn init(allocator: std.mem.Allocator) VM {
        return VM{ .chunk = undefined, .ip = 0, .allocator = allocator, .stack = ArrayList(Value).init(allocator) };
    }

    pub fn deinit(vm: *VM) void {
        vm.ip = undefined;
        vm.stack.deinit();
    }

    fn push(vm: *VM, value: Value) !void {
        try vm.stack.append(value);
    }

    fn pop(vm: *VM) Value {
        return vm.stack.pop();
    }

    fn readByte(vm: *VM) u8 {
        const byte = vm.chunk.code.items[vm.ip];
        vm.ip += 1;
        return byte;
    }

    fn readConstant(vm: *VM) Value {
        return vm.chunk.constants.items[vm.readByte()];
    }

    fn run(vm: *VM) !InterpretResult {
        var instruction: u8 = undefined;
        while (true) {
            if (debug.TRACE_EXECUTION) {
                print("          ", .{});
                for (vm.stack.items) |value| {
                    print("[ ", .{});
                    printValue(value);
                    print(" ]", .{});
                }
                print("\n", .{});
                _ = vm.chunk.disassembleInstruction(vm.ip);
            }
            instruction = vm.readByte();
            switch (@as(OpCode, @enumFromInt(instruction))) {
                .CONSTANT => {
                    const constant = vm.readConstant();
                    try vm.push(constant);
                },
                .NEGATE => try vm.push(Value{ .Number = -vm.pop().Number }),
                .RETURN => {
                    printValue(vm.pop());
                    print("\n", .{});
                    return .OK;
                },
                else => return .RUNTIME_ERROR,
            }
        }
    }

    pub fn interpret(vm: *VM, chunk: *Chunk) !InterpretResult {
        vm.chunk = chunk;
        return vm.run();
    }
};
