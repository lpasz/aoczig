const std = @import("std");
const example = @embedFile("./day03/example.txt");
const input = @embedFile("./day03/input.txt");

fn max(n: u128, m: u128) u128 {
    if (n > m) {
        return n;
    } else {
        return m;
    }
}

fn digits_to_num(digits: []const u8) u128 {
    var n: u128 = 0;
    for (0..digits.len) |idx| {
        n = n * 10 + (digits[idx] - '0');
    }
    return n;
}

fn max_joltage_with_n_batteries(n: usize, line: []const u8) u128 {
    var buf: [64]u8 = undefined;
    var num = buf[0..n];
    std.mem.copyForwards(u8, num[0..n], line[0..n]);
    var prev_num = digits_to_num(&num);

    for (n..line.len) |next_idx| {
        for (0..num.len) |ignore| {
            var curr_num: u128 = 0;
            for (0..num.len) |idx| {
                if (ignore != idx) {
                    curr_num = curr_num * 10 + (num[idx] - '0');
                }
            }
            curr_num = curr_num * 10 + (line[next_idx] - '0');

            prev_num = max(prev_num, curr_num);
        }

        _ = try std.fmt.bufPrint(&num, "{}", .{prev_num});
    }
}

pub fn part1(data: []const u8) !u128 {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var cnt: u128 = 0;

    while (lines.next()) |line| {
        cnt += max_joltage_with_n_batteries(2, line);
    }

    return cnt;
}

pub fn part2(data: []const u8) !u128 {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var cnt: u128 = 0;

    while (lines.next()) |line| {
        cnt += max_joltage_with_n_batteries(12, line);
    }
    return cnt;
}

test "example part 1" {
    try std.testing.expectEqual(357, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(17193, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(3121910778619, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(171297349921310, part2(input));
}
