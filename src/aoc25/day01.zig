const std = @import("std");
const example = @embedFile("./day01/example.txt");
const input = @embedFile("./day01/input.txt");

const Counter = struct {
    value: u64,
    stop_zero: u64,
    cross_zero: u64,

    pub fn click(self: *Counter, c: u8, num: u64) void {
        if (c == 'L') {
            self.left(num);
        } else if (c == 'R') {
            self.right(num);
        }
    }

    fn right(self: *Counter, n: u64) void {
        const q = n / 100;
        const value = (self.value + n % 100) % 100;
        self.stop_zero += if (value == 0) 1 else 0;
        self.cross_zero += if (value < self.value) q + 1 else q;
        self.value = value;
    }

    fn left(self: *Counter, n: u64) void {
        const q = n / 100;
        const value = ((self.value + 100) - n % 100) % 100;
        self.stop_zero += if (value == 0) 1 else 0;
        self.cross_zero += q;
        self.cross_zero += if (value == 0) 1 else 0;
        // don't count if we are currently at zero
        self.cross_zero += if (self.value == 0) 0 else if (value > self.value) 1 else 0;
        self.value = value;
    }
};

pub fn part1(data: []const u8) !u64 {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var cnt = Counter{ .value = 50, .cross_zero = 0, .stop_zero = 0 };

    while (lines.next()) |line| {
        const steps = try std.fmt.parseInt(u64, line[1..], 10);
        cnt.click(line[0], steps);
    }

    return cnt.stop_zero;
}

pub fn part2(data: []const u8) !u64 {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var cnt = Counter{ .value = 50, .cross_zero = 0, .stop_zero = 0 };

    while (lines.next()) |line| {
        const steps = try std.fmt.parseInt(u64, line[1..], 10);
        cnt.click(line[0], steps);
    }

    return cnt.cross_zero;
}

test "example part 1" {
    try std.testing.expectEqual(3, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(1064, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(6, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(6122, part2(input));
}
