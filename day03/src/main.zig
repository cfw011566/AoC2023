const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

fn getInput(content: []const u8, allocator: std.mem.Allocator) !([][]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iterator = std.mem.tokenizeSequence(u8, content, "\n");
    while (iterator.next()) |line| {
        try lines.append(line);
    }
    var puzzle = try lines.toOwnedSlice();
    return puzzle;
}

pub fn main() !void {
    try std.testing.expectEqual(puzzle1(example), 4361);
    const test_result = try puzzle1(example);
    std.debug.print("example = {d}\n", .{test_result});
    const part1 = try puzzle1(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn puzzle1(data: []const u8) !usize {
    const allocator = std.heap.page_allocator;
    var puzzle = try getInput(data, allocator);
    defer allocator.free(puzzle);
    var sum: usize = 0;

    for (0..puzzle.len) |row| {
        var line = puzzle[row];
        var first: ?usize = null;
        var last: ?usize = null;
        for (0..line.len) |col| {
            var char = puzzle[row][col];
            if (char >= '0' and char <= '9') {
                if (first == null) {
                    first = col;
                    last = col;
                } else {
                    last = col;
                }
            } else {
                if (first) |f| {
                    if (last) |l| {
                        const number_text = line[f .. l + 1];
                        //std.debug.print("\'{s}\'", .{number_text});
                        if (checkAdjacent(puzzle, row, f, l)) {
                            const number = try std.fmt.parseInt(usize, number_text, 10);
                            // std.debug.print(" {d}\n", .{number});
                            sum += number;
                        } else {
                            // std.debug.print("\n", .{});
                        }
                        first = null;
                        last = null;
                    }
                }
            }
            // std.debug.print("{c}", .{char});
        }
        if (first) |f| {
            if (last) |l| {
                const number_text = line[f .. l + 1];
                if (checkAdjacent(puzzle, row, f, l)) {
                    const number = try std.fmt.parseInt(usize, number_text, 10);
                    sum += number;
                }
            }
        }
        // std.debug.print("\n", .{});
    }
    return sum;
}

fn checkAdjacent(puzzle: [][]const u8, row: usize, start: usize, end: usize) bool {
    var row_start = row;
    var row_end = row;
    var col_start = start;
    var col_end = end;

    if (row_start > 0) {
        row_start -= 1;
    }
    const rows = puzzle.len;
    if (row_end < rows - 1) {
        row_end += 1;
    }
    if (col_start > 0) {
        col_start -= 1;
    }
    const cols = puzzle[row].len;
    if (col_end < cols - 1) {
        col_end += 1;
    }

    for (row_start..row_end + 1) |i| {
        for (col_start..col_end + 1) |j| {
            const char = puzzle[i][j];
            if ((char >= '0' and char <= '9') or char == '.') {
                continue;
            } else {
                return true;
            }
        }
    }

    return false;
}
