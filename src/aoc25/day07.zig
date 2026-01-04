const std = @import("std");
const example = @embedFile("./day07/example.txt");
const input = @embedFile("./day07/input.txt");

const Point = struct {
    x: usize,
    y: usize,

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

pub fn part1(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var map = std.AutoHashMap(Point, u8).init(allocator);
    defer map.deinit();

    const start = try build_map(data, &map);

    var beams = std.ArrayList(Point).init(allocator);
    defer beams.deinit();
    try beams.append(start);

    var seen = std.AutoHashMap(Point, bool).init(allocator);
    defer seen.deinit();

    var splited_at = std.AutoHashMap(Point, bool).init(allocator);
    defer splited_at.deinit();

    while (beams.popOrNull()) |b| {
        if (seen.get(b)) |_| continue;

        try seen.put(b, true);
        const beam = b.down();

        if (map.get(beam)) |value| {
            switch (value) {
                '^' => {
                    try splited_at.put(beam, true);
                    try beams.append(beam.left());
                    try beams.append(beam.right());
                },
                '.' => {
                    try beams.append(beam);
                },
                else => {},
            }
        }
    }

    return splited_at.count();
}

pub fn part2(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var map = std.AutoHashMap(Point, u8).init(allocator);
    defer map.deinit();

    const start = try build_map(data, &map);

    var beams = std.AutoHashMap(Point, u64).init(allocator);
    defer beams.deinit();
    try beams.put(start, 1);

    var finished: u64 = 0;
    var changed = true;

    while (changed) {
        changed = false;
        var newPoints = std.AutoHashMap(Point, u64).init(allocator);
        var it = beams.iterator();

        while (it.next()) |entry| {
            const down = entry.key_ptr.down();
            if (map.get(down)) |p| {
                switch (p) {
                    '.' => {
                        changed = true;
                        try increment(down, &newPoints, entry);
                    },
                    '^' => {
                        changed = true;
                        try increment(down.left(), &newPoints, entry);
                        try increment(down.right(), &newPoints, entry);
                    },
                    else => {},
                }
            } else {
                finished += entry.value_ptr.*;
            }
        }

        beams.deinit();
        beams = newPoints;
    }

    return finished;
}

fn build_map(data: []const u8, map: *std.AutoHashMap(Point, u8)) !Point {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    var start: Point = undefined;
    var y: usize = 0;
    while (lines.next()) |line| {
        for (line, 0..) |c, x| {
            if (c == 'S') start = Point{ .x = x, .y = y };

            try map.put(Point{ .x = x, .y = y }, c);
        }
        y += 1;
    }
    return start;
}

fn increment(p: Point, beams: *std.AutoHashMap(Point, u64), entry: std.AutoHashMap(Point, u64).Entry) !void {
    if (beams.getEntry(p)) |d| {
        d.value_ptr.* += entry.value_ptr.*;
    } else {
        try beams.put(p, entry.value_ptr.*);
    }
}

test "example part 1" {
    try std.testing.expectEqual(21, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(1507, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(40, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(1537373473728, part2(input));
}
