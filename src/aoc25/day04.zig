const std = @import("std");
const example = @embedFile("./day04/example.txt");
const input = @embedFile("./day04/input.txt");

pub fn part1(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var map = std.AutoHashMap(Point, u8).init(allocator);

    defer map.deinit();
    var y: i32 = 0;
    while (lines.next()) |line| {
        for (line, 0..) |c, x| {
            try map.put(Point{ .x = @intCast(x), .y = y }, c);
        }
        y += 1;
    }

    var it = map.iterator();
    var removed: u64 = 0;
    while (it.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;

        if (value == '@') {
            if (count_rolls(key, map) < 4) {
                removed += 1;
            }
        }
    }

    return removed;
}

fn count_rolls(key: Point, map: std.AutoHashMap(Point, u8)) u8 {
    var rolls: u8 = 0;
    rolls += if ((map.get(key.up()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.down()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.left()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.right()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.up().left()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.up().right()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.down().left()) orelse '.') == '@') 1 else 0;
    rolls += if ((map.get(key.down().right()) orelse '.') == '@') 1 else 0;
    return rolls;
}

const Point = struct {
    x: i32,
    y: i32,

    pub fn up(self: Point) Point {
        return Point{ .x = self.x, .y = self.y - 1 };
    }
    pub fn down(self: Point) Point {
        return Point{ .x = self.x, .y = self.y + 1 };
    }
    pub fn left(self: Point) Point {
        return Point{ .x = self.x - 1, .y = self.y };
    }
    pub fn right(self: Point) Point {
        return Point{ .x = self.x + 1, .y = self.y };
    }
};

pub fn part2(data: []const u8) !u128 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var map = std.AutoHashMap(Point, u8).init(allocator);

    defer map.deinit();
    var y: i32 = 0;
    while (lines.next()) |line| {
        for (line, 0..) |c, x| {
            try map.put(Point{ .x = @intCast(x), .y = y }, c);
        }
        y += 1;
    }

    var removed: u64 = 0;
    var changed = true;
    while (changed) {
        changed = false;

        var it = map.iterator();

        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;

            if (value == '@') {
                if (count_rolls(key, map) < 4) {
                    changed = true;
                    removed += 1;
                    entry.value_ptr.* = '.';
                }
            }
        }

        if (!changed) break;
    }

    return removed;
}

test "example part 1" {
    try std.testing.expectEqual(13, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(1502, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(43, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(9083, part2(input));
}
