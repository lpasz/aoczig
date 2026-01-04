const std = @import("std");
const example = @embedFile("./day06/example.txt");
const input = @embedFile("./day06/input.txt");

pub fn part1(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var matrix = std.ArrayList(std.ArrayList(u64)).init(allocator);
    defer {
        for (matrix.items) |*row| row.deinit();
        matrix.deinit();
    }
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var total: u64 = 0;
    while (lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, ' ');
        var row = std.ArrayList(u64).init(allocator);

        var x: usize = 0;
        while (numbers.next()) |n| {
            if (n.len == 0) continue;

            if (std.mem.eql(u8, n, "+")) {
                var sum: u64 = 0;
                for (matrix.items) |r| {
                    sum += r.items[x];
                }
                total += sum;
                x += 1;
            } else if (std.mem.eql(u8, n, "*")) {
                var product: u64 = 1;
                for (matrix.items) |r| {
                    product = product * r.items[x];
                }
                total += product;
                x += 1;
            } else {
                const nums = try std.fmt.parseInt(u64, n, 10);
                x += 1;
                try row.append(nums);
            }
        }
        try matrix.append(row);
    }
    return total;
}

const Op = enum {
    sum,
    multiply,
    pub fn new(c: u8) Op {
        return switch (c) {
            '+' => .sum,
            '*' => .multiply,
            else => unreachable,
        };
    }
    pub fn apply(self: Op, total: u64, n: u64) u64 {
        return switch (self) {
            .sum => total + n,
            .multiply => total * n,
        };
    }
};

pub fn part2(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var matrix = std.ArrayList([]u8).init(allocator);
    defer {
        for (matrix.items) |row| allocator.free(row);
        matrix.deinit();
    }
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    while (lines.next()) |line| {
        const copy = try allocator.dupe(u8, line);
        try matrix.append(copy);
    }

    const row_count = matrix.items.len;
    const col_count = matrix.items[0].len;

    var total: u64 = 0;
    var operation: Op = undefined;
    var curr: u64 = 0;
    for (0..col_count) |x| {
        var buf: [64]u8 = undefined;
        var len: usize = 0;

        for (0..row_count) |y| {
            const c = matrix.items[y][x];
            if (std.ascii.isDigit(c) or c == '*' or c == '+') {
                buf[len] = c;
                len += 1;
            }
        }

        // Empty Col
        if (len == 0) {
            total += curr;
            curr = 0;
            continue;
        }

        // If we found and operator at the end of column.
        // Change operator, and reinit the curr value.
        const last = buf[len - 1];
        if (last == '+' or last == '*') {
            operation = Op.new(last);
            curr = try std.fmt.parseInt(u64, buf[0..(len - 1)], 10);
        } else {
            const num = try std.fmt.parseInt(u64, buf[0..len], 10);
            curr = operation.apply(curr, num);
        }
    }
    total += curr;

    return total;
}

test "example part 1" {
    try std.testing.expectEqual(4277556, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(6417439773370, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(3263827, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(11044319475191, part2(input));
}
