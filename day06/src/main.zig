const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(partOne(example), 288);
    const part1 = try partOne(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn partOne(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n\r");
    const time_line = lines.next().?;
    const distance_line = lines.next().?;

    var colon_iterator = std.mem.tokenizeScalar(u8, time_line, ':');
    _ = colon_iterator.next().?;
    const time_input = colon_iterator.next().?;
    const times = try getNumbers(time_input);

    colon_iterator = std.mem.tokenizeScalar(u8, distance_line, ':');
    _ = colon_iterator.next().?;
    const distance_input = colon_iterator.next().?;
    const distances = try getNumbers(distance_input);

    var sum: usize = 1;
    for (times, distances) |time, distance| {
        std.debug.print("t = {d} d = {d}\n", .{ time, distance });
        var count: usize = 0;
        for (1..time) |t| {
            const d = t * (time - t);
            if (d > distance) {
                count += 1;
                std.debug.print("t = {d}, d = {d}, count = {d}\n", .{ t, d, count });
            }
        }
        sum *= count;
    }

    return sum;
}

fn getNumbers(line: []const u8) ![]usize {
    var num_iterator = std.mem.tokenizeScalar(u8, line, ' ');
    var num_array = std.ArrayList(usize).init(allocator);
    while (num_iterator.next()) |num_text| {
        const num = try std.fmt.parseInt(usize, num_text, 10);
        try num_array.append(num);
    }

    var output = num_array.toOwnedSlice();
    return output;
}
