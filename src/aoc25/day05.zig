const std = @import("std");
const example = @embedFile("./day05/example.txt");
const input = @embedFile("./day05/input.txt");

pub fn part1(data: []const u8) !u128 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var list = std.ArrayList(Range).init(allocator);
    defer list.deinit();
    const trim = std.mem.trim(u8, data, "\n");
    var range_and_ids = std.mem.split(u8, trim, "\n\n");

    const ranges = range_and_ids.next() orelse unreachable;
    var lines = std.mem.splitScalar(u8, ranges, '\n');

    while (lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, '-');
        const s1 = numbers.next() orelse unreachable;
        const s2 = numbers.next() orelse unreachable;

        const n1 = try std.fmt.parseInt(u128, s1, 10);
        const n2 = try std.fmt.parseInt(u128, s2, 10);

        try list.append(Range.new(n1, n2));
    }

    const ids_str = range_and_ids.next() orelse unreachable;
    var ids = std.mem.splitScalar(u8, ids_str, '\n');
    var count: u128 = 0;
    while (ids.next()) |id_str| {
        const id = try std.fmt.parseInt(u128, id_str, 10);
        for (list.items) |range| {
            if (range.in(id)) {
                count += 1;
                break;
            }
        }
    }
    return count;
}
const Range = struct {
    start: u128,
    end: u128,

    pub fn new(n1: u128, n2: u128) Range {
        if (n1 < n2) {
            return Range{ .start = n1, .end = n2 };
        } else {
            return Range{ .start = n2, .end = n1 };
        }
    }
    pub fn in(self: Range, n: u128) bool {
        return (self.start <= n and n <= self.end);
    }
    pub fn merge(self: *Range, other: Range) void {
        if (self.end < other.end) {
            self.end = other.end;
        }
    }
    pub fn len(self: Range) u128 {
        return self.end - self.start + 1;
    }
};

pub fn part2(data: []const u8) !u128 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var list = std.ArrayList(Range).init(allocator);
    defer list.deinit();
    const trim = std.mem.trim(u8, data, "\n");
    var range_and_ids = std.mem.split(u8, trim, "\n\n");

    const ranges = range_and_ids.next() orelse unreachable;
    var lines = std.mem.splitScalar(u8, ranges, '\n');

    while (lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, '-');
        const s1 = numbers.next() orelse unreachable;
        const s2 = numbers.next() orelse unreachable;

        const n1 = try std.fmt.parseInt(u128, s1, 10);
        const n2 = try std.fmt.parseInt(u128, s2, 10);

        try list.append(Range.new(n1, n2));
    }

    std.sort.heap(Range, list.items, {}, less);

    var n: Range = list.items[0];
    var count: u128 = 0;
    for (list.items[1..]) |item| {
        if (n.in(item.start)) {
            n.merge(item);
        } else {
            count += n.len();
            n = item;
        }
    }

    count += n.len();

    return count;
}

fn less(_: void, a: Range, b: Range) bool {
    return a.start < b.start;
}

test "example part 1" {
    try std.testing.expectEqual(3, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(733, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(14, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(345821388687084, part2(input));
}
