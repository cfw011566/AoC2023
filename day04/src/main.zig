const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(partOne(example), 13);
    var part1 = try partOne(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn partOne(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n");
    var sum: usize = 0;

    while (lines.next()) |line| {
        var card_iterator = std.mem.tokenizeAny(u8, line, ":|");
        const card_text = card_iterator.next().?;
        const win_text = card_iterator.next().?;
        const my_text = card_iterator.next().?;

        var win_numbers = std.ArrayList(usize).init(allocator);
        defer win_numbers.deinit();
        var my_numbers = std.ArrayList(usize).init(allocator);
        defer my_numbers.deinit();

        var num_iterator = std.mem.tokenizeScalar(u8, card_text, ' ');

        _ = num_iterator.next().?;
        const card_id = try std.fmt.parseInt(usize, num_iterator.next().?, 10);
        _ = card_id;
        // std.debug.print("Card {d}\n", .{card_id});

        num_iterator = std.mem.tokenizeScalar(u8, win_text, ' ');
        while (num_iterator.next()) |num_text| {
            const num = try std.fmt.parseInt(usize, num_text, 10);
            try win_numbers.append(num);
        }
        var win_slice = try win_numbers.toOwnedSlice();
        // std.debug.print("{any}\n", .{win_slice});

        num_iterator = std.mem.tokenizeScalar(u8, my_text, ' ');
        while (num_iterator.next()) |num_text| {
            const num = try std.fmt.parseInt(usize, num_text, 10);
            try my_numbers.append(num);
        }
        var my_slice = try my_numbers.toOwnedSlice();
        // std.debug.print("{any}\n", .{my_slice});

        var points: usize = 0;
        for (win_slice) |win| {
            if (findNumber(win, my_slice)) {
                if (points == 0) {
                    points = 1;
                } else {
                    points *= 2;
                }
            }
        }
        sum += points;
    }
    return sum;
}

fn findNumber(num: usize, numbers: []const usize) bool {
    for (numbers) |number| {
        if (num == number) return true;
    }
    return false;
}
