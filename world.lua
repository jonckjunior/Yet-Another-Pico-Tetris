---@enum WorldState
local WORLD_STATE = {
    PLAYING = "playing",
    GAME_OVER = "game_over"
}

---@class World
---@field grid table
---@field piece_bag table
---@field active_piece TetrisPiece
---@field drop_timer integer
---@field drop_interval integer
---@field block_size integer
---@field mode WorldState
---@field score integer
---@field level integer
---@field lines_cleared integer
---@field board_x integer
---@field board_y integer
local World = {}

---Initialize a new world. Sets up the grid and creates the first active piece.
function World:new()
    local w = {}

    -- Set up metatable FIRST
    self.__index = self
    setmetatable(w, self)

    -- Initialize grid
    w.grid = {}
    for i = 1, 22 do
        w.grid[i] = {}
        for j = 1, 10 do
            if DEBUG and i > 19 and j <= 9 then
                w.grid[i][j] = 7
            else
                w.grid[i][j] = 0
            end
        end
    end

    -- Now initialize other fields (piece_bag is initialized in create_new_active_piece)
    w.piece_bag = {}
    w:create_new_active_piece()
    w.drop_timer = 0
    w.drop_interval = 30
    w.block_size = 6
    w.state = WORLD_STATE.PLAYING
    w.score = 0
    w.level = 1
    w.lines_cleared = 0
    w.board_x = 25
    w.board_y = -w.block_size * 1
    return w
end

---Main gameplay loop for the world.
function World:update_world()
    self.drop_timer = self.drop_timer + 1
    if self.state == WORLD_STATE.PLAYING then
        self:handle_input_playing()
        self:handle_auto_drop()
    else
        self:update_game_over()
    end
end

function World:update_game_over()
    -- TODO: add game over screen
    if btnp(4) then World:new() end
end

---Source of truth for player input during gameplay. For player input during other game states, see other functions.
function World:handle_input_playing()
    if btnp(0) then
        if self:can_move(0, -1) then
            self.active_piece.column = self.active_piece.column - 1
        end
    end

    if btnp(1) then
        if self:can_move(0, 1) then
            self.active_piece.column = self.active_piece.column + 1
        end
    end

    if btnp(2) then
        self:handle_rotation()
    end

    if btnp(3) then
        self:update_score("soft_drop", 1)
        self:try_move_piece_down()
    end

    if btnp(4) then
        -- It starts at 1 because the piece will move down at least 1 row
        local drop_distance = 1
        while self:can_move(1, 0) do
            self.active_piece.row = self.active_piece.row + 1
            drop_distance = drop_distance + 1
        end
        self:update_score("hard_drop", drop_distance)
        self:try_move_piece_down()
    end
end

---Handles rotation input. If the piece can't rotate because of a collision, it will try wall kicks. If it still can't rotate, it will revert the rotation.
function World:handle_rotation()
    local old_rotation = self.active_piece.rotation
    local old_shape = self.active_piece.shape
    self.active_piece:rotate()

    if not self:can_move(0, 0) then
        local wall_kicks = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 0, 2 }, { 0, -2 }, { -1, -1 }, { -1, 1 } }
        local kicked = false

        for _, kick in pairs(wall_kicks) do
            if self:can_move(kick[1], kick[2]) then
                self.active_piece.row = self.active_piece.row + kick[1]
                self.active_piece.column = self.active_piece.column + kick[2]
                kicked = true
                break
            end
        end

        if not kicked then
            -- revert rotation
            self.active_piece.rotation = old_rotation
            self.active_piece.shape = old_shape
        end
    end
end

---Every so often the game will force the active piece down. This is the function that handles that.
function World:handle_auto_drop()
    if self.drop_timer == self.drop_interval then
        self:try_move_piece_down()
    end
end

---Tries to move the piece down. If it can't it will lock the piece on the board.
function World:try_move_piece_down()
    self.drop_timer = 0
    if self:can_move(1, 0) then
        self.active_piece.row = self.active_piece.row + 1
    else
        self:lock_active_piece()
        self:check_line_completion()
        self:create_new_active_piece()
        if not self:can_move(0, 0) then
            self.state = WORLD_STATE.GAME_OVER
            return
        end
    end
end

---Checks for completed lines.
function World:check_line_completion()
    local lines_completed = 0
    local rows = #self.grid
    local columns = #self.grid[1]
    local write_row = rows
    for read_row = rows, 1, -1 do
        local full = true
        for column = 1, columns do
            if self.grid[read_row][column] == 0 then
                full = false
                break
            end
        end
        if full then
            lines_completed += 1
        else
            -- Copy non-full row to bottom
            if write_row ~= read_row then
                for column = 1, columns do
                    self.grid[write_row][column] = self.grid[read_row][column]
                end
            end
            write_row = write_row - 1
        end
    end
    -- Clear top rows (now empty space)
    for row = 1, lines_completed do
        for column = 1, columns do
            self.grid[row][column] = 0
        end
    end
    if lines_completed > 0 then
        self:update_score("lines", lines_completed)
    end
end

---Updates the player's score.
---@param score_type string
---@param amount integer
function World:update_score(score_type, amount)
    if score_type == "lines" then
        local points = { [1] = 100, [2] = 300, [3] = 500, [4] = 800 }
        self.lines_cleared = self.lines_cleared + amount
        self.level = flr(self.lines_cleared / 10) + 1
        self.drop_interval = max(5, 30 - (self.level - 1))
        self.score = self.score + points[amount] * self.level
    elseif score_type == "soft_drop" then
        self.score = self.score + amount
    elseif score_type == "hard_drop" then
        self.score = self.score + amount * 2
    end
end

---Replenishes the piece bag.
function World:refresh_piece_bag()
    self.piece_bag = { "I", "O", "T", "S", "Z", "J", "L" }
    ---Shuffles the piece bag so that pieces come in random order.
    for i = #self.piece_bag, 2, -1 do
        local j = flr(rnd(i)) + 1
        self.piece_bag[i], self.piece_bag[j] = self.piece_bag[j], self.piece_bag[i]
    end
end

---Assigns a new active piece to the world. If the bag is empty, it replenishes the bag.
function World:create_new_active_piece()
    -- when the game starts the bag is empty, so we need to refresh it
    if #self.piece_bag == 0 then
        self:refresh_piece_bag()
    end

    local piece_type = deli(self.piece_bag, 1) -- Take from front
    self.active_piece = TetrisPiece:new(piece_type, 1, 1, 5)

    if #self.piece_bag == 0 then
        self:refresh_piece_bag()
    end
end

---Places the active piece in the grid.
function World:lock_active_piece()
    for _, block in pairs(self.active_piece.shape) do
        local block_row = self.active_piece.row + block[1]
        local block_column = self.active_piece.column + block[2]
        self.grid[block_row][block_column] = self.active_piece.color
    end
end

---Check if we can move the active piece to a new row or column
---@param delta_row integer
---@param delta_column integer
---@return boolean
function World:can_move(delta_row, delta_column)
    for _, block in pairs(self.active_piece.shape) do
        local block_row = self.active_piece.row + delta_row + block[1]
        local block_column = self.active_piece.column + delta_column + block[2]

        -- check if the block is out of bounds
        if not self:is_position_valid(block_row, block_column) then
            return false
        end

        -- check if the block collides with existing blocks in the grid
        if self.grid[block_row][block_column] ~= 0 then
            return false
        end
    end

    return true
end

---Checks if a given position is valid in the grid
---@param row integer
---@param column integer
---@return boolean
function World:is_position_valid(row, column)
    return row >= 1 and row <= #self.grid and column >= 1 and column <= #self.grid[1]
end

---Draw everything in the world
function World:draw_world()
    self:draw_grid()
    -- print score
    print("score: " .. self.score, 90, 10)

    -- let's just print a game over message for now
    if self.state == WORLD_STATE.GAME_OVER then
        print("\f7\^o0ffgame over", 20, 60)
    else
        self:draw_ghost_piece()
        self:draw_active_piece()
    end
end

---Draws the grid on the screen
function World:draw_grid()
    --We skip the first two rows
    for row = 3, #self.grid do
        for column = 1, #self.grid[row] do
            self:draw_block(row, column, self.grid[row][column] or 1)
        end
    end
end

---Draws the active piece on the screen
function World:draw_active_piece()
    -- we don't draw the active piece if the game is over
    if self.state == WORLD_STATE.GAME_OVER then
        return
    end
    for _, block in pairs(self.active_piece.shape) do
        local block_row = self.active_piece.row + block[1]
        local block_column = self.active_piece.column + block[2]
        self:draw_block(block_row, block_column, self.active_piece.color)
    end
end

---Draws the ghost piece on the screen
function World:draw_ghost_piece()
    local ghost_row = self.active_piece.row
    while self:can_move(ghost_row - self.active_piece.row + 1, 0) do
        ghost_row = ghost_row + 1
    end

    for _, block in pairs(self.active_piece.shape) do
        local block_row = ghost_row + block[1]
        local block_column = self.active_piece.column + block[2]
        self:draw_block(block_row, block_column, 5)
    end
end

---Draw the block at (row, column)
---@param row integer
---@param column integer
---@param color integer
function World:draw_block(row, column, color)
    -- block
    rectfill(
        self.board_x + (column - 1) * self.block_size, self.board_y + (row - 1) * self.block_size,
        self.board_x + column * self.block_size - 1, self.board_y + row * self.block_size - 1, color)
    -- outline
    rect(
        self.board_x + (column - 1) * self.block_size, self.board_y + (row - 1) * self.block_size,
        self.board_x + column * self.block_size - 1, self.board_y + row * self.block_size - 1, color + 1)
end
