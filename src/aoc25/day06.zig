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

        var x: u64 = 0;
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

    const transp = try transpose(allocator, matrix.items);
    defer {
        for (transp.items) |row| allocator.free(row);
        transp.deinit();
    }

    var total: u64 = 0;
    var operation: u8 = '+';
    var curr: u64 = 0;
    for (transp.items) |tt| {
        const t = std.mem.trim(u8, tt, " ");

        if (t.len == 0) {
            total += curr;
            continue;
        }
        if (t[t.len - 1] == '*') {
            operation = '*';
            const n = std.mem.trim(u8, t[0..(t.len - 1)], " ");
            curr = try std.fmt.parseInt(u64, n, 10);
            continue;
        }
        if (t[t.len - 1] == '+') {
            operation = '+';
            const n = std.mem.trim(u8, t[0..(t.len - 1)], " ");
            curr = try std.fmt.parseInt(u64, n, 10);
            continue;
        }

        const n = try std.fmt.parseInt(u64, t, 10);

        if (operation == '*') curr *= n;
        if (operation == '+') curr += n;
    }
    total += curr;
    return total;
}

fn transpose(
    alloc: std.mem.Allocator,
    rows: []const []const u8,
) !std.ArrayList([]u8) {
    if (rows.len == 0) return error.EmptyInput;

    const row_count = rows.len;
    const col_count = rows[0].len;

    var cols = std.ArrayList([]u8).init(alloc);
    try cols.ensureTotalCapacity(col_count);

    for (0..col_count) |c| {
        var col = try alloc.alloc(u8, row_count);
        for (0..row_count) |r| {
            col[r] = rows[r][c];
        }
        cols.appendAssumeCapacity(col);
    }

    return cols;
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
