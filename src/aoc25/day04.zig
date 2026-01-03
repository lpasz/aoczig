const std = @import("std");
const example = @embedFile("./day04/example.txt");
const input = @embedFile("./day04/input.txt");

pub fn part1(data: []const u8) !u128 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var rows = std.ArrayList([]u8).init(allocator);

    while (lines.next()) |line| {
        try rows.append(line);
    }
}

pub fn part2(data: []const u8) !u128 {
    return 0;
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
