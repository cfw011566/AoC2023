const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(solve(example), 114);
    const part1 = try solve(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn solve(puzzle: []const u8) !isize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n\r");

    var sum: isize = 0;
    while (lines.next()) |line| {
        var list = std.ArrayList(isize).init(allocator);
        defer list.deinit();
        var sequence = std.mem.tokenizeScalar(u8, line, ' ');
        while (sequence.next()) |num| {
            const number = try std.fmt.parseInt(isize, num, 10);
            try list.append(number);
        }
        var numbers = list.items;
        var pivot: usize = numbers.len - 1;
        while (true) {
            var all_zero = true;
            for (0..pivot) |i| {
                const diff = numbers[i + 1] - numbers[i];
                numbers[i] = diff;
                if (diff != 0) all_zero = false;
            }
            pivot -= 1;
            if (all_zero or pivot == 0) {
                break;
            }
        }
        //std.debug.print("pivoi = {d}, {any}\n", .{ pivot, numbers });
        for (numbers) |num| {
            sum += num;
        }
    }

    return sum;
}
