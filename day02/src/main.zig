const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

pub fn main() !void {
    try std.testing.expectEqual(puzzle1(example), 8);
    const part1 = try puzzle1(input);
    std.debug.print("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(puzzle2(example), 2286);
    const part2 = try puzzle2(input);
    std.debug.print("part2 = {d}\n", .{part2});
}

// splitAny()
// Returns an iterator that iterates over the slices of buffer that are separated by any item in delimiters.
//
// tokenizeAny()
// Returns an iterator that iterates over the slices of buffer that are not any of the items in delimiters.
//

const CubeColor = struct {
    red: usize = 0,
    green: usize = 0,
    blue: usize = 0,
};

fn checkImpossible(bag: CubeColor) bool {
    if (bag.red > 12) return true;
    if (bag.green > 13) return true;
    if (bag.blue > 14) return true;
    return false;
}

fn puzzle1(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n");

    var sum: usize = 0;
    while (lines.next()) |line| {
        var split_iter = std.mem.splitSequence(u8, line, ": ");
        var game = split_iter.next().?;
        const game_id = try std.fmt.parseInt(usize, game[5..], 10);

        var game_input = split_iter.next().?;
        var game_steps = std.mem.splitSequence(u8, game_input, "; ");
        var impossible = false;
        while (game_steps.next()) |step| {
            var cubes = std.mem.splitSequence(u8, step, ", ");
            var cube_color = CubeColor{ .red = 0, .green = 0, .blue = 0 };
            while (cubes.next()) |cube| {
                var num_color = std.mem.tokenizeScalar(u8, cube, ' ');
                const count_input = num_color.next().?;
                const count = try std.fmt.parseInt(usize, count_input, 10);
                const color = num_color.next().?;
                if (std.mem.eql(u8, color, "red")) {
                    cube_color.red = count;
                } else if (std.mem.eql(u8, color, "green")) {
                    cube_color.green = count;
                } else if (std.mem.eql(u8, color, "blue")) {
                    cube_color.blue = count;
                }
            }
            if (checkImpossible(cube_color)) {
                impossible = true;
                break;
            }
        }
        sum += if (impossible) 0 else game_id;
    }
    return sum;
}

fn cubePower(bag: CubeColor) usize {
    return bag.red * bag.green * bag.blue;
}

fn puzzle2(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n");

    var sum: usize = 0;
    while (lines.next()) |line| {
        var split_iter = std.mem.splitSequence(u8, line, ": ");
        var game = split_iter.next().?;
        const game_id = try std.fmt.parseInt(usize, game[5..], 10);
        _ = game_id;

        var game_input = split_iter.next().?;
        var game_steps = std.mem.splitSequence(u8, game_input, "; ");
        var cube_color = CubeColor{ .red = 0, .green = 0, .blue = 0 };
        while (game_steps.next()) |step| {
            var cubes = std.mem.splitSequence(u8, step, ", ");
            while (cubes.next()) |cube| {
                var num_color = std.mem.tokenizeScalar(u8, cube, ' ');
                const count_input = num_color.next().?;
                const count = try std.fmt.parseInt(usize, count_input, 10);
                const color = num_color.next().?;
                if (std.mem.eql(u8, color, "red") and count > cube_color.red) {
                    cube_color.red = count;
                } else if (std.mem.eql(u8, color, "green") and count > cube_color.green) {
                    cube_color.green = count;
                } else if (std.mem.eql(u8, color, "blue") and count > cube_color.blue) {
                    cube_color.blue = count;
                }
            }
        }
        // std.debug.print("game {d} {}\n", .{ game_id, cube_color });
        sum += cubePower(cube_color);
    }
    return sum;
}
