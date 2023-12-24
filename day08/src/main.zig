const std = @import("std");

const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example2.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

const Instruction = struct {
    left: []const u8,
    right: []const u8,
};

pub fn main() !void {
    try std.testing.expectEqual(partOne(example1), 2);
    try std.testing.expectEqual(partOne(example2), 6);
    const part1 = try partOne(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn partOne(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n\r");

    const step = lines.next().?;
    // std.debug.print("step = {s}\n", .{step});

    var map = std.StringHashMap(Instruction).init(allocator);
    defer map.deinit();

    while (lines.next()) |line| {
        //var iterator = std.mem.tokenizeAny(u8, line, " ,()=");
        //const key = iterator.next().?;
        //var left = iterator.next().?;
        //var right = iterator.next().?;
        const key = line[0..3];
        const left = line[7..10];
        const right = line[12..15];
        const value = Instruction{ .left = left, .right = right };
        try map.put(key, value);
    }

    //var iterator = map.iterator();
    //while (iterator.next()) |entry| {
    //    const inst = entry.value_ptr.*;
    //    std.debug.print("k = {s}, {s} {s}\n", .{ entry.key_ptr.*, inst.left, inst.right });
    //}

    var count: usize = 0;
    var node: [3]u8 = "AAA".*;
    //@compileLog(@TypeOf(node));
    while (std.mem.eql(u8, &node, "ZZZ") == false) {
        //std.debug.print("count = {d}, node = {s}\n", .{ count, node });
        const inst = map.get(&node).?;
        const i = count % step.len;
        const char = step[i];
        if (char == 'L') {
            //node[0] = inst.left[0];
            //node[1] = inst.left[1];
            //node[2] = inst.left[2];
            node = inst.left[0..3].*;
        } else {
            //node[0] = inst.right[0];
            //node[1] = inst.right[1];
            //node[2] = inst.right[2];
            node = inst.right[0..3].*;
        }
        count += 1;
    }
    return count;
}
