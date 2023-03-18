const std = @import("std");
const debug = std.debug;

pub const Point = enum {
    empty,
    cross,
    circle,

    fn other(self: Point) Point {
        return switch (self) {
            .cross => .circle,
            .circle => .cross,
            else => unreachable,
        };
    }
};

const Coord = struct {
    x: u8,
    y: u8,

    fn toIdx(self: Coord) u8 {
        return self.x + 3 * self.y;
    }
};

pub const Tictactoe = struct {
    board: [9]Point = .{.empty} ** 9,
    player: Point = .cross,
    over: bool = false,

    /// Returns `false` is the play is illegal
    pub fn play(self: *Tictactoe, coord: Coord) bool {
        const point = &self.board[coord.toIdx()];

        // Move is illegal if the coordinate is already occupied
        if (point.* == .empty) {
            point.* = self.player;

            self.checkIfOver();
            if (!self.over)
                self.player = self.player.other();

            return true;
        }

        return false;
    }

    /// Only checks the points of the turn player
    fn checkIfOver(self: *Tictactoe) void {
        var mask: u9 = 0;
        for (self.board) |point| {
            mask <<= 1;

            if (point == self.player)
                mask += 1;
        }

        if (@popCount(mask & 0b000000111) == 3 or
            @popCount(mask & 0b000111000) == 3 or
            @popCount(mask & 0b111000000) == 3 or
            @popCount(mask & 0b001001001) == 3 or
            @popCount(mask & 0b010010010) == 3 or
            @popCount(mask & 0b100100100) == 3 or
            @popCount(mask & 0b001010100) == 3 or
            @popCount(mask & 0b100010001) == 3)
            self.over = true;
    }

    pub fn forfeit(self: *Tictactoe, player: Point) void {
        debug.assert(player != .empty);

        self.player = player.other();
        self.over = true;
    }
};
