const std = @import("std");

const Tictactoe = @import("Tictactoe.zig");
const Point = Tictactoe.Point;

fn handleInput(game: *Tictactoe, input: []const u8, writer: anytype) !void {
    const trimmed = std.mem.trim(u8, input, "\x0a ");

    const help_message =
        \\  Commands:
        \\    help              Print this message
        \\    print             Print the state of the board
        \\    play [abc][123]   Make a play at a given coord, such as "b2"
        \\    forfeit           Forfeit the game
    ;

    if (std.mem.eql(u8, trimmed, "help")) {
        try writer.print(help_message, .{});
    } else if (std.mem.eql(u8, trimmed, "print")) {
        try writer.print("\n\n", .{});
        try printBoard(game.*, writer);
    } else if (std.mem.eql(u8, trimmed, "forfeit")) {
        game.forfeit(game.player);
    } else {
        if (std.mem.startsWith(u8, trimmed, "play ")) {
            const arg = std.mem.trim(u8, trimmed["play ".len..], " ");
            const x = arg[0] -% 'a';
            const y = '3' -% arg[1];

            if (arg.len != 2 or x > 2 or y > 2)
                try writer.print("\nInvalid coordinates!\n", .{})
            else if (!game.play(.{ .x = x, .y = y }))
                try writer.print("\nThe coordinate is already occupied!\n", .{});
        } else try writer.print("Invalid command, type \"help\" for a list of commands", .{});
    }

    try writer.print("\n\n", .{});
}

fn printBoard(game: Tictactoe, writer: anytype) !void {
    try writer.print("     a   b   c\n", .{});

    for (0..3) |i| {
        const c = '3' - @intCast(u8, i);

        try writer.print("   {s}-\n", .{"----" ** 3});

        try writer.print(" {c} ", .{c});
        for (game.board[3 * i .. 3 * i + 3]) |point| {
            try writer.print("| {c} ", .{pointToChar(point)});
        }

        try writer.print("| {c}\n", .{c});
    }

    try writer.print("   {s}-\n", .{"----" ** 3});
    try writer.print("     a   b   c\n", .{});
}

fn pointToChar(point: Point) u8 {
    return switch (point) {
        .empty => ' ',
        .cross => 'X',
        .circle => 'O',
    };
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stderr = std.io.getStdErr().writer();

    var buffer: [std.mem.page_size]u8 = undefined;

    var game = Tictactoe{};
    while (!game.over) {
        std.debug.print("{c}'s turn: ", .{pointToChar(game.player)});
        const len = try stdin.read(&buffer);

        try handleInput(&game, buffer[0..len], stderr);
    }

    try printBoard(game, stderr);
    std.debug.print("\n\n{c} won the game!\n", .{pointToChar(game.player)});
}
