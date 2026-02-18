---@enum WorldState
local WORLD_STATE = {
    PLAYING = "playing",
    GAME_OVER = "game_over",
    LINE_CLEAR = "line_clear",
    VICTORY = "victory"
}

---@class Particle
---@field x number
---@field y number
---@field vx number
---@field vy number
---@field color integer
---@field lifetime integer
---@field age integer
local Particle = {}

---Create a new particle
---@param x number
---@param y number
---@param color integer
---@return Particle
function Particle:new(x, y, color)
    local p = {}
    p.x = x
    p.y = y
    p.vx = (rnd(1) - 0.5) * 0.3 -- Random horizontal drift
    p.vy = -0.3 - rnd(0.4)      -- Slower upward velocity (fire rises slowly)
    p.color = color
    p.lifetime = 40 + rnd(20)   -- Random lifetime 40-60 frames
    p.age = 0
    self.__index = self
    setmetatable(p, self)
    return p
end

---Update particle physics
function Particle:update()
    self.age = self.age + 1
    -- Fire-like movement: slow upward drift + horizontal waver
    self.x = self.x + self.vx
    self.y = self.y + self.vy
    -- Horizontal oscillation (fire flicker)
    self.vx = self.vx + (rnd(0.2) - 0.1)
    -- Slow down over time (fire dissipates)
    self.vy = self.vy * 0.98
    self.vx = self.vx * 0.95
end

---Check if particle is still alive
---@return boolean
function Particle:is_alive()
    return self.age < self.lifetime
end

---Draw the particle
function Particle:draw()
    pset(self.x, self.y, self.color)
end

---@class World
---@field grid_spr integer
---@field grid table
---@field piece_queue table
---@field active_piece TetrisPiece
---@field drop_interval integer
---@field block_size integer
---@field mode WorldState
---@field score integer
---@field level integer
---@field lines_cleared integer
---@field board_x integer
---@field board_y integer
---@field timer table
---@field das table
---@field held_piece TetrisPiece
---@field can_hold boolean
---@field is_tspin boolean
---@field is_mini_tspin boolean
---@field last_action string
---@field last_rotation_kick integer
---@field spawn_row integer
---@field spawn_column integer
---@field spawn_rotation integer
---@field animation table
---@field shake integer
---@field preview integer
---@field challenge Challenge
---@field particles table
---@field drop_trails table
local World = {}

---Initialize a new world. Sets up the grid and creates the first active piece.
---Creates a new world
---@param challenge Challenge
---@return World
function World:new(challenge)
    local w = {}

    -- Set up metatable FIRST
    self.__index = self
    setmetatable(w, self)

    w.grid_spr = 8
    -- Initialize grid
    w.grid = {}
    for i = 1, 22 do
        w.grid[i] = {}
        for j = 1, 10 do
            w.grid[i][j] = w.grid_spr
        end
    end

    -- Now initialize other fields
    w.piece_queue = {}
    w.drop_interval = 60
    w.block_size = 6
    w.state = WORLD_STATE.PLAYING
    w.score = 0
    w.level = 1
    w.lines_cleared = 0
    w.board_x = (127 - #w.grid[1] * w.block_size) / 2
    w.board_y = -w.block_size * 1
    w.das = {
        left  = { timer = 0, shift = 0, btn = 0, delta = -1 },
        right = { timer = 0, shift = 0, btn = 1, delta = 1 }
    }

    w.held_piece = nil
    w.can_hold = true
    w.timer = {
        soft = 0,
        drop = 0,
        hard = 0
    }
    w.is_tspin = false
    w.is_mini_tspin = false
    w.last_action = nil
    w.last_rotation_kick = nil
    w.spawn_row = 1
    w.spawn_column = 5
    w.spawn_rotation = 1
    w.animation = {
        type = nil,   -- "line_clear", "tspin"
        timer = 0,    -- Animation frame counter
        lines = {},   -- Array of line numbers being cleared
        duration = 12 -- Animation length in frames
    }
    w.shake = 0
    w.preview = 5
    w.challenge = challenge
    w.particles = {}
    w.drop_trails = {}

    w:refill_queue()
    w:refill_queue()
    w:finish_turn()

    w:setup_tspin_test()

    return w
end

function World:reset_action_state()
    self.last_action = nil
    self.last_rotation_kick = nil
    self.is_tspin = false
    self.is_mini_tspin = false
end

---Main gameplay loop for the world.
function World:update_world()
    if self.state == WORLD_STATE.PLAYING then
        self:handle_input_playing()
        self:handle_auto_drop()
        self:update_particles()
        self:update_drop_trails()
    elseif self.state == WORLD_STATE.LINE_CLEAR then
        self:update_line_clear_animation()
    elseif self.state == WORLD_STATE.GAME_OVER then
        self:update_game_over()
    elseif self.state == WORLD_STATE.VICTORY then
        self:update_victory()
    end
end

function World:update_victory()
    if btnp(5) then
        change_mode("menu")
    end
end

function World:update_line_clear_animation()
    self.animation.timer = self.animation.timer + 1

    if self.animation.timer >= self.animation.duration then
        self.state = WORLD_STATE.PLAYING
        self:clear_completed_lines()
        self:finish_turn()
    end
end

function World:update_game_over()
    if btnp(5) then
        change_mode("menu")
    end
end

function World:update_particles()
    local alive_particles = {}
    for _, particle in ipairs(self.particles) do
        particle:update()
        if particle:is_alive() then
            add(alive_particles, particle)
        end
    end
    self.particles = alive_particles
end

function World:update_drop_trails()
    local active_trails = {}
    for _, trail in ipairs(self.drop_trails) do
        trail.timer = trail.timer + 1

        -- Eased progression (quad ease-out for snappy feel)
        local t = trail.timer / trail.duration
        local eased_t = 1 - (1 - t) * (1 - t)

        -- Shrink from top down
        trail.current_top = trail.start_y + (trail.end_y - trail.start_y) * eased_t

        if trail.timer < trail.duration then
            add(active_trails, trail)
        end
    end
    self.drop_trails = active_trails
end

---Create drop trails for hard drop animation
---@param original_row integer
function World:create_drop_trails(original_row)
    for _, block in pairs(self.active_piece.shape) do
        local block_col = self.active_piece.column + block[2]
        local original_block_row = original_row + block[1]
        local final_block_row = self.active_piece.row + block[1]

        if final_block_row > original_block_row then
            local trail = {
                x = self.board_x + (block_col - 1) * self.block_size + self.block_size / 2,
                start_y = self.board_y + (original_block_row - 1) * self.block_size,
                end_y = self.board_y + (final_block_row - 1) * self.block_size,
                current_top = self.board_y + (original_block_row - 1) * self.block_size,
                color = self.active_piece.spr,
                timer = 0,
                duration = 5
            }
            add(self.drop_trails, trail)
        end
    end
end

---Source of truth for player input during gameplay. For player input during other game states, see other functions.
function World:handle_input_playing()
    for _, dir in pairs(self.das) do
        if btnp(dir.btn) and self:can_move(0, dir.delta) then
            self.active_piece.column += dir.delta
            self.last_action = "movement"
        end

        if btn(dir.btn) then
            dir.timer += 1
            local delay = (dir.shift == 0) and 10 or 2
            if dir.timer >= delay then
                dir.timer = 0
                dir.shift += 1
                if self:can_move(0, dir.delta) then
                    self.active_piece.column += dir.delta
                    self.last_action = "movement"
                end
            end
        else
            dir.timer = 0
            dir.shift = 0
        end
    end

    if btn(3) then
        self.timer.soft = max(0, self.timer.soft - 1)
        if self.timer.soft == 0 then
            self.timer.soft = 3
            self:update_score("soft_drop", 1)
            self:try_move_piece_down()
        end
    else
        self.timer.soft = 0
    end

    -- if the player is holding up and z, we drop
    if btn(2) and btn(4) then
        self.timer.hard = max(0, self.timer.hard - 1)
        if self.timer.hard == 0 then
            self.timer.hard = 10
            local original_row = self.active_piece.row

            -- It starts at 1 because the piece will move down at least 1 row
            local drop_distance = 1
            while self:can_move(1, 0) do
                self.active_piece.row = self.active_piece.row + 1
                drop_distance = drop_distance + 1
            end

            self:create_drop_trails(original_row)
            self:update_score("hard_drop", drop_distance)
            self:try_move_piece_down()
        end
    elseif btnp(4) then
        -- Clockwise rotation
        self:handle_rotation(0)
        self.last_action = "rotation"
    else
        self.timer.hard = 0
    end

    -- if the players is holding up and x, we hold
    if btn(2) and btn(5) and self.can_hold then
        self:handle_hold()
    elseif btnp(5) then
        -- Counterclockwise rotation
        self:handle_rotation(-2)
        self.last_action = "rotation"
    end
end

---Swap between the piece held and the active piece. If no piece held, then just insert active piece in held position.
function World:handle_hold()
    self.can_hold = false
    if self.held_piece == nil then
        -- just store the active piece in the held position
        self.held_piece = self.active_piece
        self:finish_turn()
    else
        -- swap held and active pieces
        local temp = self.active_piece
        self.active_piece = self.held_piece
        self.held_piece = temp
    end
    -- always reset the rotation of the held piece
    self.held_piece:set_rotation(1)

    -- reset position and rotation of the active piece
    self.active_piece.row = self.spawn_row
    self.active_piece.column = self.spawn_column
    self.active_piece.rotation = self.spawn_rotation

    -- reset drop timer so it doesn't drop immediately
    self.timer.drop = 0
end

---Handles rotation input using SRS kick tables
---@param rot integer
function World:handle_rotation(rot)
    local old_rotation = self.active_piece.rotation
    local old_shape = self.active_piece.shape
    local old_row = self.active_piece.row
    local old_col = self.active_piece.column

    self.active_piece:rotate(rot)
    local new_rotation = self.active_piece.rotation

    -- O-piece doesn't need kicks
    if self.active_piece.shapeId == "O" then
        return
    end

    -- Select appropriate kick table
    local kick_table
    if self.active_piece.shapeId == "I" then
        kick_table = SRS_KICKS_I
    else
        kick_table = SRS_KICKS_JLSTZ
    end

    -- Get kicks for this rotation transition
    local kicks = kick_table[old_rotation][new_rotation]

    -- Try each kick in order
    local kicked = false
    for idx, kick in ipairs(kicks) do
        if self:can_move(kick[1], kick[2]) then
            self.active_piece.row = self.active_piece.row + kick[1]
            self.active_piece.column = self.active_piece.column + kick[2]
            self.last_rotation_kick = idx
            kicked = true
            break
        end
    end

    if not kicked then
        -- Revert rotation if no kick worked
        self.active_piece.rotation = old_rotation
        self.active_piece.shape = old_shape
        self.active_piece.row = old_row
        self.active_piece.column = old_col
    end
end

---Every so often the game will force the active piece down. This is the function that handles that.
function World:handle_auto_drop()
    self.timer.drop = self.timer.drop + 1
    if self.timer.drop == self.drop_interval then
        self:try_move_piece_down()
    end
end

---Tries to move the piece down. If it can't it will lock the piece on the board.
function World:try_move_piece_down()
    self.timer.drop = 0
    if self:can_move(1, 0) then
        self.active_piece.row = self.active_piece.row + 1
    else
        self:lock_active_piece()

        local completed_rows, score_type = self:check_line_completion()
        if #completed_rows > 0 then
            assert(score_type)
            self:prepare_line_completion_animation(completed_rows, score_type)
            self.state = WORLD_STATE.LINE_CLEAR
        else
            -- update score if there's a score type
            if score_type then
                self:update_score(score_type, 0)
            end
            self:finish_turn()
        end
    end
end

---Starts the line completion animation with lines_completed lines.
---@param completed_rows table
---@param score_type string
function World:prepare_line_completion_animation(completed_rows, score_type)
    self.animation.type = score_type
    self.animation.timer = 0
    self.animation.lines = completed_rows
    self.animation.lines_count = #completed_rows
    self.shake = 1 + #completed_rows
end

function World:finish_turn()
    self.active_piece = nil
    if self.challenge.is_victory(self) then
        -- set it to victory and do not create another piece
        self.state = WORLD_STATE.VICTORY
        return
    end
    self:spawn_next_piece()
end

function World:spawn_next_piece()
    self:create_new_active_piece()

    -- Check if new piece can fit (game over condition)
    if not self:can_move(0, 0) then
        self.state = WORLD_STATE.GAME_OVER
    end
end

function World:create_particles_for_line_clear()
    local columns = #self.grid[1]
    local particles_per_block = 1 + #self.animation.lines
    for _, cleared_row in ipairs(self.animation.lines) do
        for column = 1, columns do
            local sprite_idx = self.grid[cleared_row][column]
            if sprite_idx ~= self.grid_spr then
                -- Get actual pixel color from the sprite
                -- Sample from center of sprite (3,3 in a 6x6 sprite)
                local sprite_color = sget((sprite_idx % 16) * 8 + 3, flr(sprite_idx / 16) * 8 + 3)

                -- Get block center position
                local block_x = self.board_x + (column - 1) * self.block_size + self.block_size / 2
                local block_y = self.board_y + (cleared_row - 1) * self.block_size + self.block_size / 2

                -- Create particles based on number of lines cleared
                for i = 1, particles_per_block do
                    local px = block_x + (rnd(self.block_size) - self.block_size / 2)
                    local py = block_y + (rnd(self.block_size) - self.block_size / 2)
                    add(self.particles, Particle:new(px, py, sprite_color))
                end
            end
        end
    end
end

function World:clear_completed_lines()
    local rows = #self.grid
    local columns = #self.grid[1]
    local write_row = rows

    self:create_particles_for_line_clear()

    -- Use the stored line numbers from animation
    for read_row = rows, 1, -1 do
        local is_cleared = false
        for _, cleared_row in ipairs(self.animation.lines) do
            if read_row == cleared_row then
                is_cleared = true
                break
            end
        end

        if not is_cleared then
            -- Copy non-cleared row to bottom
            if write_row ~= read_row then
                for column = 1, columns do
                    self.grid[write_row][column] = self.grid[read_row][column]
                end
            end
            write_row = write_row - 1
        end
    end

    -- Clear top rows (now empty space)
    for row = 1, #self.animation.lines do
        for column = 1, columns do
            self.grid[row][column] = self.grid_spr
        end
    end

    -- Score the cleared lines
    self:update_score(self.animation.type, self.animation.lines_count)

    -- Reset animation
    self.animation.type = nil
    self.animation.lines = {}
end

---Returns a table with the lines that are currently completed and need to be cleared and the score type if any.
---@return table, string|nil
function World:check_line_completion()
    local lines_completed = 0
    local completed_rows = {}
    local rows = #self.grid
    local columns = #self.grid[1]

    for row = rows, 1, -1 do
        local full = true
        for column = 1, columns do
            if self.grid[row][column] == self.grid_spr then
                full = false
                break
            end
        end
        if full then
            lines_completed = lines_completed + 1
            add(completed_rows, row)
        end
    end

    -- Determine score type based on lines cleared + tspin status
    local score_type = nil
    if lines_completed > 0 then
        score_type = self.is_tspin and "tspin" or self.is_mini_tspin and "mini_tspin" or "lines"
    elseif self.is_tspin then
        score_type = "tspin"
    elseif self.is_mini_tspin then
        score_type = "mini_tspin"
    end

    return completed_rows, score_type
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
    elseif score_type == "tspin" then
        local points = { [0] = 100, [1] = 400, [2] = 800, [3] = 1200, [4] = 1600 }
        self.lines_cleared = self.lines_cleared + amount
        self.level = flr(self.lines_cleared / 10) + 1
        self.drop_interval = max(5, 30 - (self.level - 1))
        self.score = self.score + (points[amount] or 0) * self.level
    elseif score_type == "mini_tspin" then
        local points = { [0] = 100, [1] = 200, [2] = 400 }
        self.lines_cleared = self.lines_cleared + amount
        self.level = flr(self.lines_cleared / 10) + 1
        self.drop_interval = max(5, 30 - (self.level - 1))
        self.score = self.score + (points[amount] or 0) * self.level
    elseif score_type == "soft_drop" then
        self.score = self.score + amount
    elseif score_type == "hard_drop" then
        self.score = self.score + amount * 2
    end
end

---Replenishes the piece bag.
function World:refill_queue()
    local bag = { "I", "O", "T", "S", "Z", "J", "L" }
    -- Shuffle
    for i = #bag, 2, -1 do
        local j = flr(rnd(i)) + 1
        bag[i], bag[j] = bag[j], bag[i]
    end
    -- Append to queue
    for p in all(bag) do
        add(self.piece_queue, p)
    end
end

---Assigns a new active piece to the world. If the bag is empty, it replenishes the bag.
function World:create_new_active_piece()
    local piece_type = deli(self.piece_queue, 1)
    self.active_piece = TetrisPiece:new(piece_type, self.spawn_rotation, self.spawn_row, self.spawn_column)

    -- Ensure enough for preview
    if #self.piece_queue < self.preview then
        self:refill_queue()
    end

    self:reset_action_state()
end

---Places the active piece in the grid.
function World:lock_active_piece()
    for _, block in pairs(self.active_piece.shape) do
        local block_row = self.active_piece.row + block[1]
        local block_column = self.active_piece.column + block[2]
        self.grid[block_row][block_column] = self.active_piece.spr
    end
    self:check_tspin()
    -- reset hold
    self.can_hold = true
end

function World:check_tspin()
    self.is_tspin = false
    self.is_mini_tspin = false

    if self.active_piece.spr == 3 and self.last_action == "rotation" then -- T-piece only
        local pivot_row = self.active_piece.row + 1
        local pivot_col = self.active_piece.column + 1

        -- Define corners based on rotation (A,B = front; C,D = back)
        local corners_map = {
            -- North (rotation 1): pointing up
            [1] = {
                A = { -1, -1 },
                B = { -1, 1 }, -- Top corners = front
                C = { 1, -1 },
                D = { 1, 1 }   -- Bottom corners = back
            },
            -- East (rotation 2): pointing right
            [2] = {
                A = { -1, 1 },
                B = { 1, 1 }, -- Right corners = front
                C = { -1, -1 },
                D = { 1, -1 } -- Left corners = back
            },
            -- South (rotation 3): pointing down
            [3] = {
                A = { 1, -1 },
                B = { 1, 1 }, -- Bottom corners = front
                C = { -1, -1 },
                D = { -1, 1 } -- Top corners = back
            },
            -- West (rotation 4): pointing left
            [4] = {
                A = { -1, -1 },
                B = { 1, -1 }, -- Left corners = front
                C = { -1, 1 },
                D = { 1, 1 }   -- Right corners = back
            }
        }

        local corners = corners_map[self.active_piece.rotation]

        -- Check which corners are filled
        local filled = { A = false, B = false, C = false, D = false }
        for name, offset in pairs(corners) do
            local c_row = pivot_row + offset[1]
            local c_col = pivot_col + offset[2]
            if not self:is_position_valid(c_row, c_col) or
                self.grid[c_row][c_col] ~= self.grid_spr then
                filled[name] = true
            end
        end

        -- Count total filled corners
        local total_filled = 0
        for _, is_filled in pairs(filled) do
            if is_filled then total_filled += 1 end
        end

        -- T-Spin detection (need at least 3 corners filled or special case)
        if total_filled >= 3 then
            -- Special case: Kick #5 (TST/Fin kick) always counts as full T-spin
            if self.last_rotation_kick == 5 then
                self.is_tspin = true
                -- Full T-Spin: A and B (front) + at least one of C or D (back)
            elseif filled.A and filled.B and (filled.C or filled.D) then
                self.is_tspin = true
                -- Mini T-Spin: C and D (back) + at least one of A or B (front)
            elseif filled.C and filled.D and (filled.A or filled.B) then
                self.is_mini_tspin = true
            end
        end
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
        if self.grid[block_row][block_column] ~= self.grid_spr then
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
    if self.shake > 0 then
        local dx = rnd(self.shake) - self.shake / 2
        local dy = rnd(self.shake) - self.shake / 2
        camera(dx, dy)
        -- Decay the shake value
        self.shake = self.shake * 0.3
        if self.shake < 0.1 then self.shake = 0 end
    else
        camera(0, 0)
    end
    self:draw_grid()
    self:draw_next_piece()
    self:draw_held_piece()
    self:draw_ghost_piece()
    self:draw_drop_trails()
    self:draw_active_piece()
    self:draw_border()
    self:draw_score_and_level()
    self:draw_particles()

    if self.state == WORLD_STATE.LINE_CLEAR then
        self:draw_line_clear_animation()
    elseif self.state == WORLD_STATE.GAME_OVER then
        cls()
        print("\f7\^o0ffgame over", 50, 50)
        print("press x to go back to the menu", 0, 56 + 20)
    elseif self.state == WORLD_STATE.VICTORY then
        print("\f7\^o0ffvictory", 50, 50)
        print("press x to go back to the menu", 0, 56 + 20)
    end
    -- print("score" .. tostring(self.score), 2, 50)
    camera(0, 0)
end

function World:draw_score_and_level()
    local y_offset = 127 - 6 * 5
    local x_offset = 2
    print_centered("level", x_offset, self.board_x - 1, y_offset, 7)
    y_offset += 6
    print_centered(tostring(self.level), x_offset, self.board_x - 1, y_offset, 7)

    y_offset += 12
    print_centered("score", x_offset, self.board_x - 1, y_offset, 7)
    y_offset += 6
    print_centered(tostring(self.score), x_offset, self.board_x - 1, y_offset, 7)
end

function print_centered(text, x_start, x_end, y, col)
    local text_width = #text * 4
    local region_width = x_end - x_start
    local x = x_start + (region_width - text_width) / 2
    print(text, x, y, col)
end

function World:draw_particles()
    for _, particle in ipairs(self.particles) do
        particle:draw()
    end
end

function World:draw_border()
    local right_side_grid = self.board_x + #self.grid[1] * self.block_size
    -- left border
    line(self.board_x - 1, self.board_y, self.board_x - 1, self.board_y + #self.grid * self.block_size, 7)
    -- right border
    line(right_side_grid, self.board_y,
        right_side_grid, self.board_y + #self.grid * self.block_size, 7)
    -- bottom border
    line(self.board_x - 1, 126, right_side_grid, 126, 7)


    local enclosing_height = self.block_size * 2 * 5 + 5 * self.block_size + 5
    -- enclosing right border for next piece
    line(127, 0, 127, enclosing_height - 3, 7)

    -- enclosing top border for next piece
    line(right_side_grid, 0, 127, 0, 7)

    -- enclosing bottom border for the next piece
    line(right_side_grid, enclosing_height, 127 - 3, enclosing_height, 7)

    line(127, enclosing_height - 3, 127 - 3, enclosing_height, 7)


    -- enclosing top border for held piece
    line(0, 0, self.board_x - 1, 0, 7)

    -- enclosing left border for held piece
    line(0, 0, 0, self.block_size * 4 - 3, 7)

    -- enclosing bottom border for held piece
    line(3, self.block_size * 4, self.board_x - 1, self.block_size * 4)

    line(0, self.block_size * 4 - 3, 3, self.block_size * 4, 7)
end

function World:draw_line_clear_animation()
    if self.animation.timer < 5 then
        return
    end
    local progress = self.animation.timer / self.animation.duration
    local shrink_factor = 1 - progress
    local height = self.block_size * shrink_factor
    local width = #self.grid[1] * self.block_size

    -- Disable transparency for color 0
    palt(0, false)

    for row in all(self.animation.lines) do
        -- clean-up the blocks that are already there for the animation
        for column = 1, #self.grid[row] do
            self:draw_block(row, column, self.grid_spr)
        end

        local x = self.board_x
        -- Center the shrinking rectangle in the middle of the original row space
        local y = self.board_y + (row - 1) * self.block_size + (self.block_size - height) / 2

        -- Draw the white shrinking effect
        rectfill(x, y, x + width - 1, y + height - 1, 7)
    end

    -- Re-enable transparency for color 0 so other sprites work
    palt(0, true)
end

function World:draw_held_piece()
    local delta_row = 3
    local delta_column = -3
    if not self.held_piece then return end

    local held = self.held_piece
    if held.shapeId == "I" then
        delta_column = delta_column - 1
    end
    for _, block in pairs(held.shape) do
        self:draw_block(delta_row + block[1], delta_column + block[2], held.spr)
    end
end

function World:draw_next_piece()
    local delta_row = 3
    local delta_column = 12

    for i = 1, self.preview do
        local next = TetrisPiece:new(self.piece_queue[i], 1, delta_row + (i - 1) * 3, delta_column)
        for block in all(next.shape) do
            self:draw_block(next.row + block[1], next.column + block[2], next.spr)
        end
    end
end

---Draws the grid on the screen
function World:draw_grid()
    --We skip the first two rows
    for row = 3, #self.grid do
        for column = 1, #self.grid[row] do
            self:draw_block(row, column, self.grid[row][column] or self.grid_spr)
        end
    end
end

---Draws drop trails for hard drop animation
function World:draw_drop_trails()
    -- fillp(0xa5a5)
    for _, trail in ipairs(self.drop_trails) do
        -- Get actual sprite color instead of sprite index
        local sprite_color = sget((trail.color % 16) * 8 + 3, flr(trail.color / 16) * 8 + 3)

        -- Draw stacked rectangles from current_top down to end_y
        -- Each rectangle is a 6x6 block with 1px darker border
        local y = trail.current_top
        while y < trail.end_y do
            local block_height = min(self.block_size, trail.end_y - y)
            rectfill(trail.x - 3, y, trail.x + 2, y + block_height - 1, sprite_color)
            y += self.block_size
        end
    end
    -- fillp(0)
end

---Draws the active piece on the screen
function World:draw_active_piece()
    -- we don't draw the active piece if there's no piece to be drawn
    if not self.active_piece then
        return
    end
    for _, block in pairs(self.active_piece.shape) do
        local block_row = self.active_piece.row + block[1]
        local block_column = self.active_piece.column + block[2]
        self:draw_block(block_row, block_column, self.active_piece.spr)
    end
end

---Draws the ghost piece on the screen
function World:draw_ghost_piece()
    if not self.active_piece then
        return
    end
    local ghost_row = self.active_piece.row
    while self:can_move(ghost_row - self.active_piece.row + 1, 0) do
        ghost_row = ghost_row + 1
    end

    -- Draw only the perimeter outline
    self:draw_piece_outline(ghost_row, self.active_piece.column, self.active_piece.shape, self.active_piece.spr)
end

---Draw only the perimeter outline of a piece (no internal lines)
---@param piece_row integer
---@param piece_col integer
---@param shape table
---@param sprite_num integer
function World:draw_piece_outline(piece_row, piece_col, shape, sprite_num)
    -- Get the sprite color
    local sprite_color = sget((sprite_num % 16) * 8 + 3, flr(sprite_num / 16) * 8 + 3)

    -- Build a set of occupied positions for fast lookup
    local occupied = {}
    for _, block in pairs(shape) do
        local key = block[1] .. "," .. block[2]
        occupied[key] = true
    end

    -- Helper to check if a position is occupied
    local function is_occupied(r, c)
        return occupied[r .. "," .. c] == true
    end

    -- Draw each block's edges only if they're on the perimeter
    for _, block in pairs(shape) do
        local block_row = piece_row + block[1]
        local block_col = piece_col + block[2]

        -- Skip if off-screen
        if block_row <= 3 then
            goto continue
        end

        local x = self.board_x + (block_col - 1) * self.block_size
        local y = self.board_y + (block_row - 1) * self.block_size

        local has_top = is_occupied(block[1] - 1, block[2])
        local has_bottom = is_occupied(block[1] + 1, block[2])
        local has_left = is_occupied(block[1], block[2] - 1)
        local has_right = is_occupied(block[1], block[2] + 1)

        -- Draw edges only where there's no adjacent block
        -- Top edge
        if not has_top then
            line(x, y, x + self.block_size - 1, y, sprite_color)
        end

        -- Bottom edge
        if not has_bottom then
            line(x, y + self.block_size - 1, x + self.block_size - 1, y + self.block_size - 1, sprite_color)
        end

        -- Left edge
        if not has_left then
            line(x, y, x, y + self.block_size - 1, sprite_color)
        end

        -- Right edge
        if not has_right then
            line(x + self.block_size - 1, y, x + self.block_size - 1, y + self.block_size - 1, sprite_color)
        end

        -- Draw corner pixels for inside corners (where two edges meet at 90°)
        -- Top-left inside corner
        if has_top and has_left and not is_occupied(block[1] - 1, block[2] - 1) then
            pset(x, y, sprite_color)
        end

        -- Top-right inside corner
        if has_top and has_right and not is_occupied(block[1] - 1, block[2] + 1) then
            pset(x + self.block_size - 1, y, sprite_color)
        end

        -- Bottom-left inside corner
        if has_bottom and has_left and not is_occupied(block[1] + 1, block[2] - 1) then
            pset(x, y + self.block_size - 1, sprite_color)
        end

        -- Bottom-right inside corner
        if has_bottom and has_right and not is_occupied(block[1] + 1, block[2] + 1) then
            pset(x + self.block_size - 1, y + self.block_size - 1, sprite_color)
        end

        ::continue::
    end
end

---Draw the block at (row, column)
---@param row integer
---@param column integer
---@param sprite_number integer
function World:draw_block(row, column, sprite_number)
    spr(
        sprite_number,
        self.board_x + (column - 1) * self.block_size,
        self.board_y + (row - 1) * self.block_size
    )
end
