const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(solve(example), 8);
    const part1 = try solve(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn getInput(content: []const u8) !([][]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iterator = std.mem.tokenizeAny(u8, content, "\n\r");
    while (iterator.next()) |line| {
        try lines.append(line);
    }

    var puzzle = lines.toOwnedSlice();
    return puzzle;
}

const Node = struct {
    up: bool,
    down: bool,
    right: bool,
    left: bool,
    char: u8,
    score: ?usize,
};

fn createBoard(data: [][]const u8, start: *Pos) !([][]Node) {
    var board: [][]Node = undefined;
    const rows = data.len;
    const cols = data[0].len;
    board = try allocator.alloc([]Node, rows);
    for (board, 0..) |*row, r| {
        row.* = try allocator.alloc(Node, cols);
        for (row.*, 0..) |*node, c| {
            node.*.score = null;
            node.*.char = data[r][c];

            updateDirection(node);
            if (r == 0) {
                node.up = false;
            }
            if (c == 0) {
                node.left = false;
            }
            if (r == rows - 1) {
                node.down = false;
            }
            if (c == cols - 1) {
                node.right = false;
            }

            if (node.char == 'S') {
                start.x = c;
                start.y = r;
                node.score = 0;
            }
        }
    }
    return board;
}

fn updateDirection(node: *Node) void {
    node.up = false;
    node.down = false;
    node.right = false;
    node.left = false;
    switch (node.char) {
        '|' => {
            node.up = true;
            node.down = true;
        },
        '-' => {
            node.right = true;
            node.left = true;
        },
        'L' => {
            node.up = true;
            node.right = true;
        },
        'J' => {
            node.up = true;
            node.left = true;
        },
        '7' => {
            node.left = true;
            node.down = true;
        },
        'F' => {
            node.right = true;
            node.down = true;
        },
        'S' => {
            node.left = true;
            node.up = true;
            node.right = true;
            node.down = true;
        },
        else => {},
    }
    return;
}

fn printBoard(board: [][]Node, origin: bool) void {
    const row_len = board.len;
    const col_len = board[0].len;
    std.debug.print("{d}x{d}\n", .{ row_len, col_len });
    for (board) |row| {
        for (row) |node| {
            if (node.score) |s| {
                std.debug.print("{d}", .{s % 10});
            } else {
                if (origin) {
                    std.debug.print("{c}", .{node.char});
                } else {
                    std.debug.print(".", .{});
                }
            }
        }
        std.debug.print("\n", .{});
    }
}

const Pos = struct { x: usize, y: usize };

fn solve(data: []const u8) !usize {
    var puzzle = try getInput(data);
    defer allocator.free(puzzle);

    var sPos: Pos = undefined;
    var board = try createBoard(puzzle, &sPos);
    printBoard(board, true);

    var max_score: usize = 0;

    var pos_fifo = std.fifo.LinearFifo(Pos, std.fifo.LinearFifoBufferType{ .Dynamic = {} }).init(allocator);
    defer pos_fifo.deinit();
    try pos_fifo.writeItem(sPos);
    while (pos_fifo.count > 0) {
        const position = pos_fifo.readItem();
        if (position) |pos| {
            const node = board[pos.y][pos.x];
            // std.debug.print("({},{}) {?} u = {} d = {} r = {} l = {}\n", .{ pos.y, pos.x, node.score, node.up, node.down, node.right, node.left });
            max_score = node.score.? + 1;
            if (node.up) {
                const up = Pos{ .y = pos.y - 1, .x = pos.x };
                var n = &(board[up.y][up.x]);
                if (n.down and n.score == null) {
                    n.score = max_score;
                    try pos_fifo.writeItem(up);
                }
            }
            if (node.down) {
                const down = Pos{ .y = pos.y + 1, .x = pos.x };
                var n = &(board[down.y][down.x]);
                if (n.up and n.score == null) {
                    n.score = max_score;
                    try pos_fifo.writeItem(down);
                }
            }
            if (node.right) {
                const right = Pos{ .y = pos.y, .x = pos.x + 1 };
                var n = &(board[right.y][right.x]);
                if (n.left and n.score == null) {
                    n.score = max_score;
                    try pos_fifo.writeItem(right);
                }
            }
            if (node.left) {
                const left = Pos{ .y = pos.y, .x = pos.x - 1 };
                var n = &(board[left.y][left.x]);
                if (n.right and n.score == null) {
                    n.score = max_score;
                    try pos_fifo.writeItem(left);
                }
            }
        }
    }

    printBoard(board, false);

    return max_score - 1;
}
