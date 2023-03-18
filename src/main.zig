const std = @import("std");

const Tictactoe = @import("Tictactoe.zig");
const Point = Tictactoe.Point;

fn handleInput(game: *Tictactoe, input: []const u8) void {
    const trimmed = std.mem.trim(u8, input, "\x0a ");

    const help_message =
        \\  Commands:
        \\    help              Print this message
        \\    print             Print the state of the board
        \\    play [abc][123]   Make a play at a given coord, such as "b2"
        \\    forfeit           Forfeit the game
    ;

    if (std.mem.eql(u8, trimmed, "help")) {
        std.debug.print(help_message, .{});
    } else if (std.mem.eql(u8, trimmed, "print")) {
        std.debug.print("\n\n", .{});
        printBoard(game.*);
    } else if (std.mem.eql(u8, trimmed, "forfeit")) {
        game.forfeit(game.player);
    } else {
        if (trimmed.len == 7 and std.mem.eql(u8, trimmed[0..5], "play ")) {
            const x = trimmed[5] -% 'a';
            const y = '3' -% trimmed[6];

            if (x > 2 or y > 2)
                std.debug.print("\nInvalid coordinates!\n", .{})
            else if (!game.play(.{ .x = x, .y = y }))
                std.debug.print("\nThe coordinate is already occupied!\n", .{});
        } else std.debug.print("Invalid command, type \"help\" for a list of commands", .{});
    }

    std.debug.print("\n\n", .{});
}

fn printBoard(game: Tictactoe) void {
    std.debug.print("     a   b   c\n", .{});

    var i: u8 = 0;
    while (i < 3) : (i += 1) {
        std.debug.print("   {s}-\n", .{"----" ** 3});

        std.debug.print(" {c} ", .{'3' - i});
        for (game.board[3 * i .. 3 * i + 3]) |point| {
            std.debug.print("| {c} ", .{pointToChar(point)});
        }

        std.debug.print("| {c}\n", .{'3' - i});
    }

    std.debug.print("   {s}-\n", .{"----" ** 3});
    std.debug.print("     a   b   c\n", .{});
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

    var buffer: [std.mem.page_size]u8 = undefined;

    var game = Tictactoe{};
    while (!game.over) {
        std.debug.print("{c}'s turn: ", .{pointToChar(game.player)});
        const len = try stdin.read(&buffer);

        handleInput(&game, buffer[0..len]);
    }

    printBoard(game);
    std.debug.print("\n\n{c} won the game!\n", .{pointToChar(game.player)});
}
