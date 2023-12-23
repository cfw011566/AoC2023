const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    try std.testing.expectEqual(partOne(example), 35);
    const part1 = try partOne(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn partOne(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n\r");

    const seeds_line = lines.next().?;
    var colon_iterator = std.mem.tokenizeScalar(u8, seeds_line, ':');
    _ = colon_iterator.next().?;
    var seeds_input = colon_iterator.next().?;
    var seeds = try getNumbers(seeds_input);
    std.debug.print("seeds: {any}\n", .{seeds});

    var map_nums = std.ArrayList([]usize).init(allocator);
    while (lines.next()) |line| {
        if (line[0] >= '0' and line[0] <= '9') {
            const nums = try getNumbers(line);
            try map_nums.append(nums);
        } else {
            var nums = try map_nums.toOwnedSlice();
            mapSeeds(seeds, nums);
            std.debug.print("{any} {any}\n", .{ nums, seeds });
            map_nums = std.ArrayList([]usize).init(allocator);
        }
    }
    var nums = try map_nums.toOwnedSlice();
    mapSeeds(seeds, nums);
    std.debug.print("{any} {any}\n", .{ nums, seeds });

    std.mem.sort(usize, seeds, {}, comptime std.sort.asc(usize));
    std.debug.print("{any}\n", .{seeds});

    return seeds[0];
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

fn mapSeeds(seeds: []usize, map_nums: [][]const usize) void {
    for (0..seeds.len) |i| {
        var seed = seeds[i];
        for (map_nums) |nums| {
            const dest = nums[0];
            const source = nums[1];
            const source_end = source + nums[2] - 1;
            if (seed >= source and seed <= source_end) {
                seeds[i] = dest + (seed - source);
            }
        }
    }
}
