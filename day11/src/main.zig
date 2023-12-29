const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(solve(example, 2), 374);
    const part1 = try solve(input, 2);
    std.log.info("part1 = {d}\n", .{part1});
    try std.testing.expectEqual(solve(example, 10), 1030);
    try std.testing.expectEqual(solve(example, 100), 8410);
    const part2 = try solve(input, 1_000_000);
    std.log.info("part2 = {d}\n", .{part2});
}

fn solve(data: []const u8, expand: usize) !usize {
    var puzzle = try getInput(data);

    var pivotRow = try getPivotRow(puzzle);
    var pivotColumn = try getPivotColumn(puzzle);
    std.log.info("pivot row = {s}\n", .{pivotRow});
    std.log.info("pivot column = {s}\n", .{pivotColumn});

    var galaxies = try getGalaxies(puzzle);
    // std.log.info("Galaxies = {any}\n", .{galaxies});

    var sum: usize = 0;
    const len = galaxies.len;
    for (0..len - 1) |i| {
        for (i + 1..len) |j| {
            const p1 = galaxies[i];
            const p2 = galaxies[j];
            const row_start = if (p1.row < p2.row) p1.row else p2.row;
            const row_end = if (p1.row > p2.row) p1.row else p2.row;
            const col_start = if (p1.column < p2.column) p1.column else p2.column;
            const col_end = if (p1.column > p2.column) p1.column else p2.column;
            const steps = row_end - row_start + col_end - col_start;
            // extra row steps
            const row_slice = pivotRow[row_start..row_end];
            const row_extra_steps = std.mem.count(u8, row_slice, ".");
            // extra column steps
            const col_slice = pivotColumn[col_start..col_end];
            const col_extra_steps = std.mem.count(u8, col_slice, ".");
            // std.log.info("p1 {any} p2 {any}, steps = {d}, extra r{d},c{d}\n", .{ p1, p2, steps, row_extra_steps, col_extra_steps });
            sum += steps + row_extra_steps * (expand - 1) + col_extra_steps * (expand - 1);
        }
    }
    // std.log.info("sum = {d}\n", .{sum});

    return sum;
}

fn getInput(data: []const u8) !([][]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iterator = std.mem.tokenizeAny(u8, data, "\n\r");
    while (iterator.next()) |line| {
        try lines.append(line);
    }

    var puzzle = lines.toOwnedSlice();
    return puzzle;
}

const Point = struct { row: usize, column: usize };

fn getGalaxies(puzzle: [][]const u8) !([]Point) {
    const rows = puzzle.len;
    const columns = puzzle[0].len;

    var galaxies = std.ArrayList(Point).init(allocator);
    defer galaxies.deinit();

    for (0..rows) |r| {
        for (0..columns) |c| {
            if (puzzle[r][c] == '#') {
                try galaxies.append(Point{ .row = r, .column = c });
            }
        }
    }

    return galaxies.toOwnedSlice();
}

fn getPivotColumn(puzzle: [][]const u8) !([]const u8) {
    var pivots = std.ArrayList(u8).init(allocator);
    defer pivots.deinit();

    const rows = puzzle.len;
    const columns = puzzle[0].len;
    for (0..columns) |c| {
        var pivot: u8 = '.';
        for (0..rows) |r| {
            if (puzzle[r][c] == '#') {
                pivot = '#';
                break;
            }
        }
        try pivots.append(pivot);
    }

    return pivots.toOwnedSlice();
}

fn getPivotRow(puzzle: [][]const u8) !([]const u8) {
    var pivots = std.ArrayList(u8).init(allocator);
    defer pivots.deinit();

    const rows = puzzle.len;
    for (0..rows) |r| {
        var pivot: u8 = '.';
        const haveGalaxy = std.mem.indexOf(u8, puzzle[r], "#");
        if (haveGalaxy) |_| {
            pivot = '#';
        }
        try pivots.append(pivot);
    }

    return pivots.toOwnedSlice();
}
