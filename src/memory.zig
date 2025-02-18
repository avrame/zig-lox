const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn DynamicArray(comptime T: type) type {
    return struct {
        count: usize,
        allocator: Allocator,
        items: []T,

        const Self = @This();

        pub fn init(allocator: Allocator) !Self {
            // Allocate an initial capacity of 8 elements
            const initial_capacity = 8;
            const items = try allocator.alloc(T, initial_capacity);
            return .{
                .count = 0,
                .allocator = allocator,
                .items = items,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, item: T) !void {
            const count = self.count;
            const capacity = self.items.len;

            if (count >= capacity) {
                // Create a new slice that's twice as large
                const new_capacity = if (capacity < 8) 8 else capacity * 2;
                var larger = try self.allocator.alloc(T, new_capacity);

                // Copy the items we previously added to our new space
                @memcpy(larger[0..count], self.items);

                // Free the old array
                self.allocator.free(self.items);

                self.items = larger;
            }

            self.items[count] = item;
            self.count += 1;
        }

        pub fn pop(self: *Self) !T {
            if (self.count == 0) {
                return error.EmptyArray;
            }
            self.count -= 1;
            return self.items[self.count];
        }

        pub fn len(self: *Self) usize {
            return self.count;
        }
    };
}

fn growCapacity(oldCapacity: usize) usize {
    if (oldCapacity < 8) {
        return 8;
    } else {
        return oldCapacity * 2;
    }
}
