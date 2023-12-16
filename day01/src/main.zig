const std = @import("std");

const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    try std.testing.expectEqual(puzzle1(example), 142);
    const part1 = try puzzle1(input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(puzzle2(example2), 281);
    const part2 = try puzzle2(input);
    std.debug.print("part2 = {d}\n", .{part2});
}

fn puzzle1(puzzle: []const u8) !u32 {
    var lines = std.mem.split(u8, puzzle, "\n");

    var sum: u32 = 0;
    while (lines.next()) |line| {
        var first_digit: ?u32 = null;
        var last_digit: ?u32 = null;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                if (first_digit == null) {
                    first_digit = c - '0';
                    last_digit = first_digit;
                } else {
                    last_digit = c - '0';
                }
            }
        }
        if (first_digit != null and last_digit != null) {
            const num = first_digit.? * 10 + last_digit.?;
            sum += num;
        }
    }
    return sum;
}

fn puzzle2(puzzle: []const u8) !u32 {
    var lines = std.mem.split(u8, puzzle, "\n");
    var sum: u32 = 0;
    while (lines.next()) |line| {
        var first_digit: ?u32 = null;
        var last_digit: ?u32 = null;
        const len = line.len;
        for (line, 0..) |c, i| {
            var char: ?u8 = null;
            if (c >= '0' and c <= '9') {
                char = c;
            } else {
                if (len - i >= 3) {
                    const digit_string = line[i .. i + 3];
                    if (std.mem.eql(u8, digit_string, "one")) {
                        char = '1';
                    } else if (std.mem.eql(u8, digit_string, "two")) {
                        char = '2';
                    } else if (std.mem.eql(u8, digit_string, "six")) {
                        char = '6';
                    }
                }
                if (len - i >= 4) {
                    const digit_string = line[i .. i + 4];
                    if (std.mem.eql(u8, digit_string, "four")) {
                        char = '4';
                    } else if (std.mem.eql(u8, digit_string, "five")) {
                        char = '5';
                    } else if (std.mem.eql(u8, digit_string, "nine")) {
                        char = '9';
                    }
                }
                if (len - i >= 5) {
                    const digit_string = line[i .. i + 5];
                    if (std.mem.eql(u8, digit_string, "three")) {
                        char = '3';
                    } else if (std.mem.eql(u8, digit_string, "seven")) {
                        char = '7';
                    } else if (std.mem.eql(u8, digit_string, "eight")) {
                        char = '8';
                    }
                }
            }
            if (char != null) {
                if (first_digit == null) {
                    first_digit = char.? - '0';
                    last_digit = first_digit;
                } else {
                    last_digit = char.? - '0';
                }
            }
        }
        if (first_digit != null and last_digit != null) {
            const num = first_digit.? * 10 + last_digit.?;
            sum += num;
        }
    }
    return sum;
}
