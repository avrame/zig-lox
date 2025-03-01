const std = @import("std");
const stdin = std.io.getStdIn().reader();

const chunk = @import("chunk.zig");
pub const Chunk = chunk.Chunk;
pub const OpCode = chunk.OpCode;

const vm = @import("vm.zig");
pub const VM = vm.VM;
pub const InterpretResult = vm.InterpretResult;

pub const Value = @import("value.zig").Value;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var vm = try VM.init(allocator);
    defer vm.deinit();

    const args = std.os.argv;

    std.debug.print("There are {d} args:\n", .{args.len});
    for (args) |arg| {
        std.debug.print(" {s}\n", .{arg});
    }

    if (args.len == 1) {
        try repl();
    } else if (args.len == 2) {
        // runFile(args[1]);
    } else {
        std.debug.print("Usage: lox [path]\n", .{});
        std.process.exit(64);
    }
}

fn repl() !void {
    while (true) {
        std.debug.print("> ", .{});
        var buf: [1024]u8 = undefined;
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
            interpret(line);
        } else {
            std.debug.print("\n", .{});
            break;
        }
    }
}

fn runFile(path: []u8) !void {
    const source: []u8 = readFile(path);
    const result: InterpretResult = interpret(source);

    if (result == InterpretResult.COMPILE_ERROR) {
        std.process.exit(65);
    }
    if (result == InterpretResult.RUNTIME_ERROR) {
        std.process.exit(70);
    }
}

fn readFile(path: []u8) []u8 {
    // Get an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    // Open a file
    const file = std.fs.cwd().openFile(path, .{ .read = true }) catch {
        std.debug.print("Could not open file \"{s}\".\n", .{path});
        std.process.exit(74);
    };
    defer file.close();

    // Read the file into a buffer
    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    return buffer;
}
