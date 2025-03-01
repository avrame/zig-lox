const std = @import("std");
const print = std.debug.print;
const DynamicArray = @import("memory.zig").DynamicArray;
const chunkModule = @import("chunk.zig");
const Chunk = chunkModule.Chunk;
const OpCode = chunkModule.OpCode;
const printValue = chunkModule.printValue;
const Value = @import("value.zig").Value;
const debug = @import("debug.zig");
const compile = @import("compiler.zig").compile;

pub const InterpretResult = enum {
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
};

pub const vmError = error{
    InvalidBinaryOpCode,
};

pub const VM = struct {
    chunk: *Chunk,
    ip: usize,
    stack: DynamicArray(Value),

    pub fn init(allocator: std.mem.Allocator) !VM {
        const stack = try DynamicArray(Value).init(allocator);
        return VM{ .chunk = undefined, .ip = 0, .stack = stack };
    }

    pub fn deinit(vm: *VM) void {
        vm.ip = undefined;
        vm.stack.deinit();
    }

    fn push(vm: *VM, value: Value) !void {
        try vm.stack.push(value);
    }

    fn pop(vm: *VM) !Value {
        return try vm.stack.pop();
    }

    fn readByte(vm: *VM) u8 {
        const byte = vm.chunk.code.items[vm.ip];
        vm.ip += 1;
        return byte;
    }

    fn readConstant(vm: *VM) Value {
        return vm.chunk.constants.items[vm.readByte()];
    }

    fn binaryOp(vm: *VM, opCode: OpCode) !void {
        const b = try vm.pop();
        const a = try vm.pop();
        var result: f64 = undefined;
        switch (opCode) {
            .ADD => {
                result = a.Number + b.Number;
            },
            .SUBTRACT => {
                result = a.Number - b.Number;
            },
            .MULTIPLY => {
                result = a.Number * b.Number;
            },
            .DIVIDE => {
                result = a.Number / b.Number;
            },
            else => {
                return vmError.InvalidBinaryOpCode;
            },
        }
        try vm.push(Value{ .Number = result });
    }

    fn run(vm: *VM) !InterpretResult {
        var instruction: u8 = undefined;
        while (true) {
            if (debug.TRACE_EXECUTION) {
                print("          ", .{});
                var i: usize = 0;
                while (i < vm.stack.count) : (i += 1) {
                    print("[ ", .{});
                    printValue(vm.stack.items[i]);
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
                .ADD, .SUBTRACT, .MULTIPLY, .DIVIDE => {
                    try vm.binaryOp(@as(OpCode, @enumFromInt(instruction)));
                },
                .NEGATE => {
                    // const num = try vm.pop();
                    // try vm.push(Value{ .Number = -num.Number });
                    vm.stack.items[vm.stack.count - 1] = Value{ .Number = -vm.stack.items[vm.stack.count - 1].Number };
                },
                .RETURN => {
                    const val = try vm.pop();
                    printValue(val);
                    print("\n", .{});
                    return .OK;
                },
                else => return .RUNTIME_ERROR,
            }
        }
    }

    pub fn interpret(vm: *VM, source: []u8) !InterpretResult {
        compile(source);
        return InterpretResult.OK;
    }
};
