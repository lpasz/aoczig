const std = @import("std");
const example = @embedFile("./day08/example.txt");
const input = @embedFile("./day08/input.txt");

const Distance = struct {
    distance: usize,
    p1: Point,
    p2: Point,
};

const Point = struct {
    x: usize,
    y: usize,
    z: usize,

    pub fn distance(a: Point, b: Point) usize {
        const x = std.math.pow(usize, abs_diff(b.x, a.x), 2);
        const y = std.math.pow(usize, abs_diff(b.y, a.y), 2);
        const z = std.math.pow(usize, abs_diff(b.z, a.z), 2);

        return std.math.sqrt(x + y + z);
    }
    fn abs_diff(a: usize, b: usize) usize {
        return if (a < b) b - a else a - b;
    }
};

pub fn part1(data: []const u8, take: usize) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    while (lines.next()) |line| {
        var xyz = std.mem.splitScalar(u8, line, ',');
        const xc = xyz.next() orelse unreachable;
        const yc = xyz.next() orelse unreachable;
        const zc = xyz.next() orelse unreachable;
        const x = try std.fmt.parseInt(usize, xc, 10);
        const y = try std.fmt.parseInt(usize, yc, 10);
        const z = try std.fmt.parseInt(usize, zc, 10);

        try points.append(Point{ .x = x, .y = y, .z = z });
    }

    var distances = std.ArrayList(Distance).init(allocator);
    defer distances.deinit();
    const len = points.items.len;
    for (0..len) |idx1| {
        for ((idx1 + 1)..len) |idx2| {
            const p1 = points.items[idx1];
            const p2 = points.items[idx2];
            const distance = Distance{ .p1 = p1, .p2 = p2, .distance = p1.distance(p2) };
            try distances.append(distance);
        }
    }

    std.sort.heap(Distance, distances.items, {}, less);

    var i = std.ArrayList(std.AutoHashMap(Point, bool)).init(allocator);
    defer {
        for (i.items) |*u| {
            u.deinit();
        }
        i.deinit();
    }

    for (distances.items[0..take]) |distance| {
        var p1_idx: usize = undefined;
        var p2_idx: usize = undefined;

        var p1: ?*std.AutoHashMap(Point, bool) = null;
        var p2: ?*std.AutoHashMap(Point, bool) = null;

        for (i.items, 0..) |*ps, idx| {
            if (ps.get(distance.p1)) |_| {
                p1_idx = idx;
                p1 = ps;
            }
            if (ps.get(distance.p2)) |_| {
                p2_idx = idx;
                p2 = ps;
            }
        }

        if (p1 == null and p2 == null) {
            var p = std.AutoHashMap(Point, bool).init(allocator);
            try p.put(distance.p1, true);
            try p.put(distance.p2, true);
            try i.append(p);
            continue;
        }

        if (p1 != null and p2 != null) {
            if (p1 == p2) {
                continue;
            }

            var pp1 = p1 orelse unreachable;
            var pp2 = p2 orelse unreachable;

            var it = pp2.iterator();
            while (it.next()) |entry| {
                try pp1.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            var z = i.swapRemove(p2_idx);
            z.deinit();
        }

        if (p1) |p| {
            try p.put(distance.p2, true);
            continue;
        }

        if (p2) |p| {
            try p.put(distance.p1, true);
            continue;
        }
    }

    std.sort.heap(std.AutoHashMap(Point, bool), i.items, {}, less2);

    var m: usize = 1;
    for (i.items[0..3]) |h| {
        m *= h.count();
    }

    return m;
}

fn less2(_: void, h1: std.AutoHashMap(Point, bool), h2: std.AutoHashMap(Point, bool)) bool {
    return h1.count() > h2.count();
}

fn less(_: void, d1: Distance, d2: Distance) bool {
    return d1.distance < d2.distance;
}

pub fn part2(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, '\n');

    while (lines.next()) |line| {
        var xyz = std.mem.splitScalar(u8, line, ',');
        const xc = xyz.next() orelse unreachable;
        const yc = xyz.next() orelse unreachable;
        const zc = xyz.next() orelse unreachable;
        const x = try std.fmt.parseInt(usize, xc, 10);
        const y = try std.fmt.parseInt(usize, yc, 10);
        const z = try std.fmt.parseInt(usize, zc, 10);

        try points.append(Point{ .x = x, .y = y, .z = z });
    }

    var distances = std.ArrayList(Distance).init(allocator);
    defer distances.deinit();
    const len = points.items.len;
    for (0..len) |idx1| {
        for ((idx1 + 1)..len) |idx2| {
            const p1 = points.items[idx1];
            const p2 = points.items[idx2];
            const distance = Distance{ .p1 = p1, .p2 = p2, .distance = p1.distance(p2) };
            try distances.append(distance);
        }
    }

    std.sort.heap(Distance, distances.items, {}, less);

    var i = std.ArrayList(std.AutoHashMap(Point, bool)).init(allocator);
    defer {
        for (i.items) |*u| {
            u.deinit();
        }
        i.deinit();
    }

    var pd: Distance = undefined;
    for (distances.items) |distance| {
        if (i.items.len == 1 and i.items[0].count() == points.items.len) {
            return pd.p1.x * pd.p2.x;
        }
        pd = distance;
        var p1_idx: usize = undefined;
        var p2_idx: usize = undefined;

        var p1: ?*std.AutoHashMap(Point, bool) = null;
        var p2: ?*std.AutoHashMap(Point, bool) = null;

        for (i.items, 0..) |*ps, idx| {
            if (ps.get(distance.p1)) |_| {
                p1_idx = idx;
                p1 = ps;
            }
            if (ps.get(distance.p2)) |_| {
                p2_idx = idx;
                p2 = ps;
            }
        }

        if (p1 == null and p2 == null) {
            var p = std.AutoHashMap(Point, bool).init(allocator);
            try p.put(distance.p1, true);
            try p.put(distance.p2, true);
            try i.append(p);
            continue;
        }

        if (p1 != null and p2 != null) {
            if (p1 == p2) {
                continue;
            }

            var pp1 = p1 orelse unreachable;
            var pp2 = p2 orelse unreachable;

            var it = pp2.iterator();
            while (it.next()) |entry| {
                try pp1.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            var z = i.swapRemove(p2_idx);
            z.deinit();
        }

        if (p1) |p| {
            try p.put(distance.p2, true);
            continue;
        }

        if (p2) |p| {
            try p.put(distance.p1, true);
            continue;
        }
    }
    return 0;
}

test "example part 1" {
    try std.testing.expectEqual(40, part1(example, 10));
}

test "input part 1" {
    try std.testing.expectEqual(52668, part1(input, 1000));
}

test "example part 2" {
    try std.testing.expectEqual(25272, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(1474050600, part2(input));
}
