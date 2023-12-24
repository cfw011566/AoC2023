const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const allocator = std.heap.page_allocator;

const HandType = enum { highCard, onePair, twoPair, threeOfKind, fullHouse, fourOfKind, fiveOfKind };

const Hand = struct {
    cards: []const u8,
    hand_type: HandType,
    bid: usize,
};

pub fn main() !void {
    try std.testing.expectEqual(partOne(example), 6440);
    const part1 = try partOne(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

fn partOne(puzzle: []const u8) !usize {
    var lines = std.mem.tokenizeAny(u8, puzzle, "\n\r");
    var all_hands = std.ArrayList(Hand).init(allocator);
    defer all_hands.deinit();

    while (lines.next()) |line| {
        var iterator = std.mem.tokenizeScalar(u8, line, ' ');
        const cards = iterator.next().?;
        const bid_text = iterator.next().?;
        const bid = try std.fmt.parseInt(usize, bid_text, 10);
        const hand_type = try handType(cards);
        const hand = Hand{ .bid = bid, .cards = cards, .hand_type = hand_type };
        // std.debug.print("{}\n", .{hand});
        try all_hands.append(hand);
    }
    var hands = try all_hands.toOwnedSlice();
    // std.debug.print("{any}\n", .{hands});
    std.mem.sort(Hand, hands, {}, handCompare);

    var sum: usize = 0;
    for (hands, 1..) |hand, rank| {
        // std.debug.print("{any}\n", .{hand});
        sum += rank * hand.bid;
    }

    return sum;
}

fn cardValue(c: u8) u8 {
    return switch (c) {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => 11,
        'T' => 10,
        '2'...'9' => c - '0',
        else => 0,
    };
}

fn cardsCompare(lcards: []const u8, rcards: []const u8) bool {
    // std.debug.print("{s} {s}\n", .{ lcards, rcards });
    for (lcards, rcards) |l, r| {
        const lvalue = cardValue(l);
        const rvalue = cardValue(r);
        if (lvalue < rvalue) return true;
        if (lvalue > rvalue) return false;
    }
    return false;
}

fn handCompare(context: void, lhs: Hand, rhs: Hand) bool {
    _ = context;
    const lhs_type = @intFromEnum(lhs.hand_type);
    const rhs_type = @intFromEnum(rhs.hand_type);
    if (lhs_type < rhs_type) {
        return true;
    } else if (lhs_type == rhs_type) {
        return cardsCompare(lhs.cards, rhs.cards);
    }
    return false;
}

fn handType(cards: []const u8) !HandType {
    var map = std.AutoHashMap(u8, usize).init(allocator);
    defer map.deinit();

    for (cards) |card| {
        var c = map.get(card) orelse 0;
        c += 1;
        try map.put(card, c);
    }
    var max_count: usize = 0;
    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        // std.debug.print("{c} {},", .{ entry.key_ptr.*, entry.value_ptr.* });
        if (max_count < entry.value_ptr.*) {
            max_count = entry.value_ptr.*;
        }
    }
    switch (map.count()) {
        1 => return .fiveOfKind,
        2 => return if (max_count == 4) .fourOfKind else .fullHouse,
        3 => return if (max_count == 3) .threeOfKind else .twoPair,
        4 => return .onePair,
        5 => return .highCard,
        else => return .highCard,
    }

    return .highCard;
}
