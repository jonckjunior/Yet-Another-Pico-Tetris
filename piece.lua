-- TetrisPieces are represented by 4x4 matrices, where 1s represent blocks and 0s represent empty space.
--- @class TetrisPiece
--- @field shapeId string
--- @field shape table
--- @field rotation integer
--- @field row integer
--- @field column integer
--- @field spr integer

local TetrisPiece = {}

TETRIS_SHAPES = {
    -- I
    -- rotation 0
    -- ....
    -- xxxx
    -- ....
    -- ....
    -- rotation 1
    -- ..x.
    -- ..x.
    -- ..x.
    -- ..x.
    -- rotation 2
    -- ....
    -- ....
    -- xxxx
    -- ....
    -- rotation 3
    -- .x..
    -- .x..
    -- .x..
    -- .x..

    I = {
        { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 1, 3 } },
        { { 0, 2 }, { 1, 2 }, { 2, 2 }, { 3, 2 } },
        { { 2, 0 }, { 2, 1 }, { 2, 2 }, { 2, 3 } },
        { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 } },
    },
    -- O
    -- rotation 0
    -- .xx.
    -- .xx.
    -- ....
    -- ....
    O = {
        { { 0, 1 }, { 0, 2 }, { 1, 1 }, { 1, 2 } }
    },
    -- T
    -- rotation 0
    -- .x.
    -- xxx
    -- ...
    -- rotation 1
    -- .x.
    -- .xx
    -- .x.
    -- rotation 2
    -- ...
    -- xxx
    -- .x.
    -- rotation 3
    -- .x.
    -- xx.
    -- .x.
    T = {
        { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
        { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
        { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
        { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 1 } }
    },
    -- S
    -- rotation 0
    -- .xx
    -- xx.
    -- ...
    -- rotation 1
    -- .x.
    -- .xx
    -- ..x
    -- rotation 2
    -- ...
    -- .xx
    -- xx.
    -- rotation 3
    -- x..
    -- xx.
    -- .x.

    S = {
        { { 0, 1 }, { 0, 2 }, { 1, 0 }, { 1, 1 } },
        { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 2 } },
        { { 1, 1 }, { 1, 2 }, { 2, 0 }, { 2, 1 } },
        { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } },
    },
    -- Z
    -- rotation 0
    -- xx.
    -- .xx
    -- ...
    -- rotation 1
    -- ..x
    -- .xx
    -- .x.
    -- rotation 2
    -- ...
    -- xx.
    -- .xx
    -- rotation 3
    -- .x.
    -- xx.
    -- x..

    Z = {
        { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 2 } },
        { { 0, 2 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
        { { 1, 0 }, { 1, 1 }, { 2, 1 }, { 2, 2 } },
        { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 0 } }
    },
    -- J
    -- rotation 0
    -- x..
    -- xxx
    -- ...
    -- rotation 1
    -- .xx
    -- .x.
    -- .x.
    -- rotation 2
    -- ...
    -- xxx
    -- ..x
    -- rotation 3
    -- .x.
    -- .x.
    -- xx.
    J = {
        { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
        { { 0, 1 }, { 0, 2 }, { 1, 1 }, { 2, 1 } },
        { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 2 } },
        { { 0, 1 }, { 1, 1 }, { 2, 0 }, { 2, 1 } }
    },
    -- L
    -- rotation 0
    -- ..x.
    -- xxx.
    -- ....
    -- rotation 1
    -- .x.
    -- .x.
    -- .xx
    -- rotation 2
    -- ...
    -- xxx
    -- x..
    -- rotation 3
    -- xx.
    -- .x.
    -- .x.
    L = {
        { { 0, 2 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
        { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 2, 2 } },
        { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 0 } },
        { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } }
    }
}

PIECE_SPR = {
    I = 1, -- cyan
    O = 2, -- yellow
    T = 3, -- purple
    S = 4, -- green
    Z = 5, -- red
    J = 6, -- blue
    L = 7  -- orange
}

---Takes the parameters below to create a TetrisPiece
---@param shapeId string
---@param rotation integer
---@param row integer
---@param column integer
---@return TetrisPiece
function TetrisPiece:new(shapeId, rotation, row, column)
    local p = {}
    p.shapeId = shapeId
    p.shape = TETRIS_SHAPES[shapeId][rotation]
    p.rotation = rotation
    p.row = row
    p.column = column
    p.spr = PIECE_SPR[shapeId]
    self.__index = self
    setmetatable(p, self)
    return p
end

---Rotate a tetris piece 90 degrees
function TetrisPiece:rotate(rot)
    self.rotation = (((self.rotation + rot) % #TETRIS_SHAPES[self.shapeId]) + 1)
    self.shape = TETRIS_SHAPES[self.shapeId][self.rotation]
end
