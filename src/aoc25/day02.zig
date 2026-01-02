const std = @import("std");
const example = @embedFile("./day02/example.txt");
const input = @embedFile("./day02/input.txt");

pub fn part1(data: []const u8) !u64 {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, ',');

    var cnt: u64 = 0;
    while (lines.next()) |line| {
        var nums = std.mem.splitScalar(u8, line, '-');
        const s1 = nums.next() orelse unreachable;
        const s2 = nums.next() orelse unreachable;
        const n1 = try std.fmt.parseInt(u64, s1, 10);
        const n2 = try std.fmt.parseInt(u64, s2, 10);
        for (n1..(n2 + 1)) |n| {
            var buf: [20]u8 = undefined;
            const s = std.fmt.bufPrint(&buf, "{}", .{n}) catch unreachable;

            if (s.len % 2 == 0) {
                const half = s.len / 2;

                if (std.mem.eql(u8, s[0..half], s[half..])) {
                    cnt += n;
                }
            }
        }
    }
    return cnt;
}

pub fn part2(data: []const u8) !u64 {
    const trim = std.mem.trim(u8, data, "\n");
    var lines = std.mem.splitScalar(u8, trim, ',');

    var cnt: u64 = 0;
    while (lines.next()) |line| {
        var nums = std.mem.splitScalar(u8, line, '-');
        const s1 = nums.next() orelse unreachable;
        const s2 = nums.next() orelse unreachable;
        const n1 = try std.fmt.parseInt(u64, s1, 10);
        const n2 = try std.fmt.parseInt(u64, s2, 10);
        for (n1..(n2 + 1)) |n| {
            var buf: [20]u8 = undefined;
            const s = std.fmt.bufPrint(&buf, "{}", .{n}) catch unreachable;
            const l = s.len;

            for (2..(l + 1)) |p| {
                var eq = false;

                if (s.len % p == 0) {
                    eq = true;
                    const p_size = l / p;
                    var start: u64 = 0;

                    while ((start + p_size + p_size) <= l) {
                        if (std.mem.eql(u8, s[start .. start + p_size], s[start + p_size .. start + p_size + p_size])) {
                            start += p_size;
                        } else {
                            eq = false;
                            break;
                        }
                    }
                }

                if (eq) {
                    cnt += n;
                    break;
                }
            }
        }
    }
    return cnt;
}

test "example part 1" {
    try std.testing.expectEqual(1227775554, part1(example));
}

test "input part 1" {
    try std.testing.expectEqual(20223751480, part1(input));
}

test "example part 2" {
    try std.testing.expectEqual(4174379265, part2(example));
}

test "input part 2" {
    try std.testing.expectEqual(30260171216, part2(input));
}
