const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(solve(example), 21);
    const part1 = try solve(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn solve(content: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, content, "\n\r");

    var sum: usize = 0;
    while (lines.next()) |line| {
        var iterator = std.mem.splitScalar(u8, line, ' ');
        const spring_text = iterator.next().?;
        const knowns_count: usize = std.mem.count(u8, spring_text, "#");
        const unknows = try whereUnknowns(spring_text);
        const groups_text = iterator.next().?;
        const groups = try parseGroups(groups_text);
        // std.debug.print("unknows = {any} groups = {any} knowns = {d}\n", .{ unknows, groups, knowns_count });

        const max: usize = std.math.shl(usize, 1, unknows.len);
        // std.debug.print("max = {d}\n", .{max});

        var damaged_count: usize = 0;
        for (groups) |count| {
            damaged_count += count;
        }
        const left = damaged_count - knowns_count;
        // std.debug.print("left = {d}\n", .{left});

        var spring_buffer = std.ArrayList(u8).init(allocator);
        defer spring_buffer.deinit();
        for (spring_text) |c| {
            try spring_buffer.append(c);
        }
        var spring_test = try spring_buffer.toOwnedSlice();
        for (0..max) |mask| {
            if (bitcount(mask) == left) {
                var pos: usize = 1;
                var i: usize = 0;
                while (pos < max) : ({
                    pos <<= 1;
                    i += 1;
                }) {
                    if ((pos & mask) != 0) {
                        spring_test[unknows[i]] = '#';
                    } else {
                        spring_test[unknows[i]] = '.';
                    }
                }
                var testGroups = try getTestGroups(spring_test);
                if (std.mem.eql(usize, testGroups, groups)) {
                    sum += 1;
                }
            }
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});

    return sum;
}

fn getTestGroups(text: []const u8) !([]usize) {
    var iterator = std.mem.tokenizeScalar(u8, text, '.');
    var groups = std.ArrayList(usize).init(allocator);
    defer groups.deinit();

    while (iterator.next()) |count_text| {
        try groups.append(count_text.len);
    }

    return groups.toOwnedSlice();
}

fn whereUnknowns(text: []const u8) !([]usize) {
    var unknowns = std.ArrayList(usize).init(allocator);
    defer unknowns.deinit();

    for (text, 0..) |ch, i| {
        if (ch == '?') {
            try unknowns.append(i);
        }
    }

    return unknowns.toOwnedSlice();
}

fn parseGroups(text: []const u8) !([]usize) {
    var iterator = std.mem.tokenizeScalar(u8, text, ',');
    var groups = std.ArrayList(usize).init(allocator);
    defer groups.deinit();

    while (iterator.next()) |num_text| {
        const num = try std.fmt.parseInt(usize, num_text, 10);
        try groups.append(num);
    }

    return groups.toOwnedSlice();
}

fn bitcount(number: usize) usize {
    var count: usize = 0;
    var n = number;

    while (n > 0) {
        count += 1;
        n = n & (n - 1);
    }

    return count;
}

test "bitcount" {
    try std.testing.expectEqual(bitcount(27834), 9);
    try std.testing.expectEqual(bitcount(3), 2);
}
