const std = @import("std");
const lox = @import("lox");

// Get everything from the lox module
const Chunk = lox.Chunk;
const OpCode = lox.OpCode;
const Value = lox.Value;
const VM = lox.VM;

// Avg time per iteration with pop/push: 129726.083ns
// Avg time per iteration without pop/push: 124638.334ns
test "manual benchmark" {
    std.debug.print("\n\nStarting manual benchmark\n", .{});

    const iterations: usize = 1000;
    var timer = try std.time.Timer.start();

    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        var vm = try VM.init(std.testing.allocator);
        defer vm.deinit();

        var chunk = try Chunk.init(std.testing.allocator);
        defer chunk.deinit();

        try chunk.writeConstant(Value{ .Number = 5.6 }, 1);
        try chunk.write(@intFromEnum(OpCode.NEGATE), 1);
        try chunk.write(@intFromEnum(OpCode.RETURN), 1);

        _ = try vm.interpret(&chunk);
    }

    const elapsed = timer.read();
    const avg_ns = @as(f64, @floatFromInt(elapsed)) / @as(f64, @floatFromInt(iterations));

    std.debug.print("Ran {d} iterations\n", .{iterations});
    std.debug.print("Total time: {d}ns\n", .{elapsed});
    std.debug.print("Average time per iteration: {d}ns\n", .{avg_ns});
    std.debug.print("Manual benchmark complete!\n", .{});
}
