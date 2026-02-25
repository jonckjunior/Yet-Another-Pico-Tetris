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
    self.age += 1
    -- Fire-like movement: slow upward drift + horizontal waver
    self.x += self.vx
    self.y += self.vy
    -- Horizontal oscillation (fire flicker)
    self.vx += (rnd(0.2) - 0.1)
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
---@field shake_x integer
---@field shake_x integer
---@field preview integer
---@field challenge Challenge
---@field particles table
---@field drop_trails table
---@field drop_interval_max integer
---@field ui_color integer
---@field border_color integer
---@field frame_count integer
---@field pieces_used integer
---@field cleared_bottom_row boolean
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

    w.grid_spr = 0
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
    w.drop_interval_max = 60
    w.drop_interval = w.drop_interval_max
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
        hard = 0,
        victory_banner = 0,
        game_over_banner = 0
    }
    w.is_tspin = false
    w.is_mini_tspin = false
    w.last_action = nil
    w.last_rotation_kick = nil
    w.spawn_row = 2
    w.spawn_column = 5
    w.spawn_rotation = 1
    w.animation = {
        type = nil,   -- "line_clear", "tspin"
        timer = 0,    -- Animation frame counter
        lines = {},   -- Array of line numbers being cleared
        duration = 12 -- Animation length in frames
    }
    w.shake_x = 0
    w.shake_y = 0
    w.preview = 5
    w.challenge = challenge
    w.particles = {}
    w.drop_trails = {}

    w.ui_color = 5
    w.border_color = 1
    w.frame_count = 0
    w.pieces_used = 0
    w.cleared_bottom_row = false

    -- Shared end-state animation (victory and defeat both use this)
    w.end_anim = {
        mode         = nil,  -- "victory" or "defeat", set when the state changes
        pops         = {},   -- active pop animations: {row, col, timer, duration, color}
        pop_timer    = 0,    -- counts up; triggers a new pop every pop_interval frames
        pop_interval = 6,    -- current interval (recalculated each frame)
        done         = false -- all blocks cleared and last pop finished
    }
    w.time_remaining = nil
    w.time_mode = "countup"
    w.frame_lo = 0
    w.secs_hi, w.secs_lo = 0, 0
    w.score_hi, w.score_lo = 0, 0

    w:refill_queue()
    w:refill_queue()
    w:finish_turn()

    if w.challenge.on_init then
        w.challenge.on_init(w)
    end

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
    if transition:blocks_input() then
        return
    end

    if self.state == WORLD_STATE.PLAYING then
        self.frame_lo += 1
        if self.frame_lo >= 60 then
            self.frame_lo = 0
            self.secs_hi, self.secs_lo = big_add(self.secs_hi, self.secs_lo, 1, 6000)
        end

        if self.challenge.on_update then
            self.challenge.on_update(self)
        end

        self:handle_input_playing()
        self:handle_auto_drop()
        self:update_particles()
        self:update_drop_trails()
    elseif self.state == WORLD_STATE.LINE_CLEAR then
        self:update_line_clear_animation()
    elseif self.state == WORLD_STATE.GAME_OVER then
        self:update_particles()
        self:update_drop_trails()
        self:update_end_anim()
    elseif self.state == WORLD_STATE.VICTORY then
        self:update_particles()
        self:update_drop_trails()
        self:update_end_anim()
    end

    if self.challenge.is_defeat and self.challenge.is_defeat(self) then
        self.state = WORLD_STATE.GAME_OVER
        self.end_anim.mode = "defeat"
    end
end

---Shared update for both VICTORY and GAME_OVER end-state animations
function World:update_end_anim()
    local ea = self.end_anim
    local is_defeat = (ea.mode == "defeat")

    -- Advance each active pop
    local still_popping = {}
    for _, pop in ipairs(ea.pops) do
        pop.timer += 1
        if pop.timer == pop.duration then
            self:spawn_end_particles(pop)
        end
        if pop.timer < pop.duration then
            add(still_popping, pop)
        end
    end
    ea.pops = still_popping

    local filled = self:end_anim_count_filled()

    if filled > 0 then
        ea.pop_interval = max(2, 6 - flr((1 - filled / 220) * 4))
        ea.pop_timer += 1
        if ea.pop_timer >= ea.pop_interval then
            ea.pop_timer = 0
            self:end_anim_pop_random_block()
        end
    elseif #ea.pops == 0 then
        ea.done = true
    end

    if ea.done and btnp(5) then
        change_mode("menu")
    end
end

---Count non-empty cells visible on the board (rows 3-22)
---@return integer
function World:end_anim_count_filled()
    local count = 0
    for row = 2, #self.grid do
        for col = 1, #self.grid[row] do
            if self.grid[row][col] ~= self.grid_spr then
                count += 1
            end
        end
    end
    return count
end

---Pick a random filled cell, register a pop, and erase it from the grid
function World:end_anim_pop_random_block()
    local filled = {}
    for row = 2, #self.grid do
        for col = 1, #self.grid[row] do
            if self.grid[row][col] ~= self.grid_spr then
                add(filled, { row = row, col = col, spr = self.grid[row][col] })
            end
        end
    end
    if #filled == 0 then return end

    local chosen                      = filled[flr(rnd(#filled)) + 1]
    local spr_idx                     = chosen.spr
    local color                       = sget((spr_idx % 16) * 8 + 3, flr(spr_idx / 16) * 8 + 3)
    local ea                          = self.end_anim

    local flash_col                   = ((ea.mode == "defeat")) and 1 or 7 -- dark blue flash vs white flash

    self.grid[chosen.row][chosen.col] = self.grid_spr
    if ea.mode == "victory" then
        self.shake_x, self.shake_y = 3, 3
    end


    add(ea.pops, {
        row       = chosen.row,
        col       = chosen.col,
        color     = color,
        flash_col = flash_col,
        timer     = 0,
        duration  = 12
    })
end

---Burst particles from the centre of a finished pop
---@param pop table
function World:spawn_end_particles(pop)
    local bx = self.board_x + (pop.col - 1) * self.block_size + self.block_size / 2
    local by = self.board_y + (pop.row - 1) * self.block_size + self.block_size / 2
    local is_defeat = (self.end_anim.mode == "defeat")
    -- Defeat gets 2 dim particles; victory gets 4 bright ones
    local count = is_defeat and 2 or 4
    local color = is_defeat and 1 or pop.color
    for i = 1, count do
        local px = bx + (rnd(self.block_size) - self.block_size / 2)
        local py = by + (rnd(self.block_size) - self.block_size / 2)
        add(self.particles, Particle:new(px, py, color))
    end
end

function World:update_line_clear_animation()
    self.animation.timer += 1

    if self.animation.timer >= self.animation.duration then
        self.state = WORLD_STATE.PLAYING
        self:clear_completed_lines()
        self:finish_turn()
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
        trail.timer += 1

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
            if stat(46 + 3) == -1 then
                sfx(7, 3)
            end
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

                    if stat(46 + 3) == -1 then
                        sfx(7, 3)
                    end
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
            sfx(63, 3)
        end
    else
        self.timer.soft = 0
    end

    -- if the player presses up, we drop
    if btn(2) then
        self.timer.hard = max(0, self.timer.hard - 1)
        if self.timer.hard == 0 then
            self.timer.hard = 20
            local original_row = self.active_piece.row

            -- It starts at 1 because the piece will move down at least 1 row
            local drop_distance = 1
            while self:can_move(1, 0) do
                self.active_piece.row += 1
                drop_distance += 1
            end
            sfx(6, 3)
            self.shake_y += 3
            self:create_drop_trails(original_row)
            self:update_score("hard_drop", drop_distance)
            self:try_move_piece_down()
        end
    else
        self.timer.hard = 0
    end

    -- if the players is holding z and x, we hold
    if btn(4) and btn(5) and self.can_hold then
        self:handle_hold()
        sfx(62, 3)
    elseif btnp(5) then
        -- Counterclockwise rotation
        self:handle_rotation(-2)
        self.last_action = "rotation"
        sfx(5, 3)
    elseif btnp(4) then
        -- Clockwise rotation
        self:handle_rotation(0)
        self.last_action = "rotation"
        sfx(5, 3)
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
    local ap = self.active_piece
    ap.row = self.spawn_row
    ap.column = self.spawn_column
    ap.rotation = self.spawn_rotation

    -- reset drop timer so it doesn't drop immediately
    self.timer.drop = 0
end

---Handles rotation input using SRS kick tables
---@param rot integer
function World:handle_rotation(rot)
    local ap = self.active_piece
    local old_rotation, old_shape, old_row, old_col = ap.rotation, ap.shape, ap.row, ap.column

    ap:rotate(rot)
    local new_rotation = ap.rotation

    -- O-piece doesn't need kicks
    if ap.shapeId == "O" then
        return
    end

    -- Select appropriate kick table
    local kick_table
    if ap.shapeId == "I" then
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
            ap.row += kick[1]
            ap.column += kick[2]
            self.last_rotation_kick = idx
            kicked = true
            break
        end
    end

    if not kicked then
        -- Revert rotation if no kick worked
        ap.rotation, ap.shape, ap.row, ap.column = old_rotation, old_shape, old_row, old_col
    end
end

---Every so often the game will force the active piece down. This is the function that handles that.
function World:handle_auto_drop()
    self.timer.drop += 1
    if self.timer.drop == self.drop_interval then
        self:try_move_piece_down()
    end
end

---Tries to move the piece down. If it can't it will lock the piece on the board.
function World:try_move_piece_down()
    self.timer.drop = 0
    if self:can_move(1, 0) then
        self.active_piece.row += 1
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
    sfx(4, 1)
    self.animation.type = score_type
    self.animation.timer = 0
    self.animation.lines = completed_rows
    self.animation.lines_count = #completed_rows
    self.shake_x += 1 + #completed_rows
    self.shake_y += 1 + #completed_rows
end

function World:finish_turn()
    self.active_piece = nil
    if self.challenge.is_victory(self) then
        self.state = WORLD_STATE.VICTORY
        self.end_anim.mode = "victory"
        return
    end
    self:spawn_next_piece()
end

function World:spawn_next_piece()
    self:create_new_active_piece()

    for column = 1, #self.grid[1] do
        if self.grid[2][column] ~= self.grid_spr then
            self.state = WORLD_STATE.GAME_OVER
            self.end_anim.mode = "defeat"
        end
    end

    if not self:can_move(0, 0) then
        self.state = WORLD_STATE.GAME_OVER
        self.end_anim.mode = "defeat"
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

    for _, cleared_row in ipairs(self.animation.lines) do
        if cleared_row == rows then
            self.cleared_bottom_row = true
            break
        end
    end

    for read_row = rows, 1, -1 do
        local is_cleared = false
        for _, cleared_row in ipairs(self.animation.lines) do
            if read_row == cleared_row then
                is_cleared = true
                break
            end
        end

        if not is_cleared then
            if write_row ~= read_row then
                for column = 1, columns do
                    self.grid[write_row][column] = self.grid[read_row][column]
                end
            end
            write_row -= 1
        end
    end

    for row = 1, #self.animation.lines do
        for column = 1, columns do
            self.grid[row][column] = self.grid_spr
        end
    end

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
            lines_completed += 1
            add(completed_rows, row)
        end
    end

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
        local time_bonus = { [1] = 60 * 3, [2] = 60 * 5, [3] = 60 * 8, [4] = 60 * 12 } -- 3s, 5s, 8s, 12s
        self:update_score_line_clear(points, time_bonus, amount)
    elseif score_type == "tspin" then
        local points = { [0] = 100, [1] = 400, [2] = 800, [3] = 1200, [4] = 1600 }
        local time_bonus = { [1] = 60 * 5, [2] = 60 * 10, [3] = 60 * 15, [4] = 60 * 20 } -- 5s, 10s, 15s, 20s
        self:update_score_line_clear(points, time_bonus, amount)
    elseif score_type == "mini_tspin" then
        local points = { [0] = 100, [1] = 200, [2] = 400 }
        local time_bonus = { [1] = 60 * 3, [2] = 60 * 6 } -- 3s, 6s
        self:update_score_line_clear(points, time_bonus, amount)
    elseif score_type == "soft_drop" then
        self:add_score(amount)
    elseif score_type == "hard_drop" then
        self:add_score(amount * 2)
    end
end

function World:add_score(amount)
    self.score_hi, self.score_lo = big_add(self.score_hi, self.score_lo, amount, 10000)
end

function World:update_score_line_clear(points, time_bonus, amount)
    self.lines_cleared += amount
    self.level = flr(self.lines_cleared / 10) + 1
    self.drop_interval = max(5, self.drop_interval_max - (self.level * 2 - 2))
    self:add_score(points[amount] * self.level)

    if self.challenge.name == "rush" and self.time_remaining and amount > 0 then
        self.time_remaining += time_bonus[amount]
    end
end

---Replenishes the piece bag.
function World:refill_queue()
    local bag = { "I", "O", "T", "S", "Z", "J", "L" }
    for i = #bag, 2, -1 do
        local j = flr(rnd(i)) + 1
        bag[i], bag[j] = bag[j], bag[i]
    end
    for p in all(bag) do
        add(self.piece_queue, p)
    end
end

---Assigns a new active piece to the world. If the bag is empty, it replenishes the bag.
function World:create_new_active_piece()
    local piece_type = deli(self.piece_queue, 1)
    self.active_piece = TetrisPiece:new(piece_type, self.spawn_rotation, self.spawn_row, self.spawn_column)

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
    self.can_hold = true
    self.pieces_used += 1
end

function World:check_tspin()
    self.is_tspin = false
    self.is_mini_tspin = false

    if self.active_piece.spr == 3 and self.last_action == "rotation" then -- T-piece only
        local pivot_row = self.active_piece.row + 1
        local pivot_col = self.active_piece.column + 1
        local corners_map = {
            [1] = {
                A, B, C, D = { -1, -1 }, { -1, 1 }, { 1, -1 }, { 1, 1 }
            },
            [2] = {
                A, B, C, D = { -1, 1 }, { 1, 1 }, { -1, -1 }, { 1, -1 }
            },
            [3] = {
                A, B, C, D = { 1, -1 }, { 1, 1 }, { -1, -1 }, { -1, 1 }
            },
            [4] = {
                A, B, C, D = { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 }
            }
        }

        local corners = corners_map[self.active_piece.rotation]

        local filled = { A = false, B = false, C = false, D = false }
        for name, offset in pairs(corners) do
            local c_row = pivot_row + offset[1]
            local c_col = pivot_col + offset[2]
            if not self:is_position_valid(c_row, c_col) or
                self.grid[c_row][c_col] ~= self.grid_spr then
                filled[name] = true
            end
        end

        local total_filled = 0
        for is_filled in all(filled) do
            if is_filled then total_filled += 1 end
        end

        if total_filled >= 3 then
            if self.last_rotation_kick == 5 then
                self.is_tspin = true
            elseif filled.A and filled.B and (filled.C or filled.D) then
                self.is_tspin = true
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

        if not self:is_position_valid(block_row, block_column) then
            return false
        end

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
    if self.shake_x + self.shake_y > 0 then
        local dx = rnd(self.shake_x) - self.shake_x / 2
        local dy = rnd(self.shake_y) - self.shake_y / 2
        camera(dx, dy)
        self.shake_x = self.shake_x * 0.3
        self.shake_y = self.shake_y * 0.3
        if self.shake_x < 0.1 then self.shake_x = 0 end
        if self.shake_y < 0.1 then self.shake_y = 0 end
    end
    local is_end_game = self.state == WORLD_STATE.GAME_OVER or self.state == WORLD_STATE.VICTORY

    self:draw_diagonal_lines()
    self:draw_grid()
    self:draw_next_piece()
    self:draw_held_piece()
    self:draw_drop_trails()
    self:draw_border()
    self:draw_text_info()
    if not is_end_game then
        self:draw_ghost_piece()
        self:draw_active_piece()
    end
    self:draw_particles()

    if self.state == WORLD_STATE.LINE_CLEAR then
        self:draw_line_clear_animation()
    elseif is_end_game then
        self:draw_end_anim()
    end
    camera(0, 0)
end

---Draw all active pops and, once done, the appropriate banner
function World:draw_end_anim()
    local ea = self.end_anim
    local is_defeat = (ea.mode == "defeat")

    palt(0, false)
    for _, pop in ipairs(ea.pops) do
        local flash_frames = is_defeat and 7 or 4 -- defeat holds the flash longer
        if pop.timer >= flash_frames then
            local progress = (pop.timer - flash_frames) / (pop.duration - flash_frames)
            local height   = self.block_size * (1 - progress)
            local x        = self.board_x + (pop.col - 1) * self.block_size
            local y        = self.board_y + (pop.row - 1) * self.block_size + (self.block_size - height) / 2
            rectfill(x, y, x + self.block_size - 1, y + height - 1, pop.flash_col)
        else
            local x = self.board_x + (pop.col - 1) * self.block_size
            local y = self.board_y + (pop.row - 1) * self.block_size
            rectfill(x, y, x + self.block_size - 1, y + self.block_size - 1, pop.flash_col)
        end
    end
    palt(0, true)

    if ea.done then
        if is_defeat then
            self.timer.game_over_banner += 1
            self:draw_defeat_banner(self.timer.game_over_banner)
        else
            self.timer.victory_banner += 1
            self:draw_victory_banner(self.timer.victory_banner)
        end
    end
end

function World:draw_defeat_banner(t)
    local h = min(16, t)
    if t > 60 then h = min(64, 16 + (t - 60)) end
    local cy = 64
    rectfill(0, cy - h, 127, cy - 1, 0)
    rectfill(0, cy, 127, cy + h - 1, 0)
    if t > 10 then
        print("game over", 44, 60, 1)
    end
end

function World:draw_victory_banner(t)
    local h = min(16, t)
    if t > 60 then h = min(64, 16 + (t - 60)) end
    rectfill(0, 0, 127, h, 0)
    rectfill(0, 127 - h, 127, 127, 0)
    if t > 10 then
        print("victory!", 48, 60, 7)
    end
end

function World:draw_text_info()
    local y_offset = 127 - 6 * 11
    local x_offset = 2

    print_centered("pieces", x_offset, self.board_x - 1, y_offset, self.ui_color)
    y_offset += 6
    print_centered(tostring(self.pieces_used), x_offset, self.board_x - 1, y_offset, self.ui_color)
    y_offset += 12

    print_centered("lines", x_offset, self.board_x - 1, y_offset, self.ui_color)
    y_offset += 6
    print_centered(tostring(self.lines_cleared), x_offset, self.board_x - 1, y_offset, self.ui_color)
    y_offset += 12

    print_centered("level", x_offset, self.board_x - 1, y_offset, self.ui_color)
    y_offset += 6
    print_centered(tostring(self.level), x_offset, self.board_x - 1, y_offset, self.ui_color)

    y_offset += 12
    print_centered("score", x_offset, self.board_x - 1, y_offset, self.ui_color)
    y_offset += 6
    print_centered(self:score_str(), x_offset, self.board_x - 1, y_offset, self.ui_color)

    y_offset = 127 - 6 * 5
    x_offset = self.board_x + self.block_size * #self.grid[1] + 2
    print_centered("mode", x_offset, 127, y_offset, self.ui_color)
    y_offset += 6
    print_centered(tostring(self.challenge.name), x_offset, 127, y_offset, self.ui_color)

    y_offset += 12
    print_centered("timer", x_offset, 127, y_offset, self.ui_color)
    y_offset += 6
    print_centered(self:get_time(), x_offset, 127, y_offset, self.ui_color)
end

function World:score_str()
    if self.score_hi > 0 then
        local lo = tostring(self.score_lo)
        while #lo < 4 do lo = "0" .. lo end
        return tostring(self.score_hi) .. lo
    end
    return tostring(self.score_lo)
end

function World:get_time()
    local total_secs = self.secs_hi * 6000 + self.secs_lo
    local mins = flr(total_secs / 60)
    local secs = total_secs % 60
    local ms = tostring(mins < 10 and "0" .. mins or mins)
    local ss = tostring(secs < 10 and "0" .. secs or secs)
    return ms .. ":" .. ss
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
    line(self.board_x - 1, self.board_y, self.board_x - 1, self.board_y + #self.grid * self.block_size, self
        .border_color)
    -- right border
    line(right_side_grid, self.board_y,
        right_side_grid, self.board_y + #self.grid * self.block_size, self.border_color)
    -- bottom border
    line(self.board_x - 1, 126, right_side_grid, 126, self.border_color)
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
    for row = 1, #self.grid do
        for column = 1, #self.grid[row] do
            self:draw_block(row, column, self.grid[row][column] or self.grid_spr)
        end
    end
    local y0 = self.board_y + self.block_size * 2 - 1
    fillp(0x5a5a)
    line(self.board_x, y0, self.board_x + self.block_size * #self.grid[1], y0, self.border_color)
    fillp()
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
    local sprite_color = sget((sprite_num % 16) * 8 + 3, flr(sprite_num / 16) * 8 + 3)

    local occupied = {}
    for _, block in pairs(shape) do
        local key = block[1] .. "," .. block[2]
        occupied[key] = true
    end

    local function is_occupied(r, c)
        return occupied[r .. "," .. c] == true
    end

    for _, block in pairs(shape) do
        local block_row = piece_row + block[1]
        local block_col = piece_col + block[2]
        if block_row <= 3 then
            goto continue
        end
        local x = self.board_x + (block_col - 1) * self.block_size
        local y = self.board_y + (block_row - 1) * self.block_size
        local has_top = is_occupied(block[1] - 1, block[2])
        local has_bottom = is_occupied(block[1] + 1, block[2])
        local has_left = is_occupied(block[1], block[2] - 1)
        local has_right = is_occupied(block[1], block[2] + 1)
        if not has_top then
            line(x, y, x + self.block_size - 1, y, sprite_color)
        end
        if not has_bottom then
            line(x, y + self.block_size - 1, x + self.block_size - 1, y + self.block_size - 1, sprite_color)
        end
        if not has_left then
            line(x, y, x, y + self.block_size - 1, sprite_color)
        end
        if not has_right then
            line(x + self.block_size - 1, y, x + self.block_size - 1, y + self.block_size - 1, sprite_color)
        end
        if has_top and has_left and not is_occupied(block[1] - 1, block[2] - 1) then
            pset(x, y, sprite_color)
        end
        if has_top and has_right and not is_occupied(block[1] - 1, block[2] + 1) then
            pset(x + self.block_size - 1, y, sprite_color)
        end
        if has_bottom and has_left and not is_occupied(block[1] + 1, block[2] - 1) then
            pset(x, y + self.block_size - 1, sprite_color)
        end
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
    local x0 = self.board_x + (column - 1) * self.block_size
    local y0 = self.board_y + (row - 1) * self.block_size
    if sprite_number == self.grid_spr then
        rectfill(x0, y0, x0 + self.block_size - 1, y0 + self.block_size - 1, 0)
    else
        spr(
            sprite_number,
            x0,
            y0
        )
    end
end

function World:draw_diagonal_lines()
    local c = 11
    pal(c, 129, 1)
    local scroll = (time() * 20) % 16
    for i = -128, 128, 8 do
        local x1 = i + scroll
        local x2 = i + 128 + scroll
        line(x1, 128, x2, 0, c)
    end
end

function big_add(hi, lo, n, base)
    lo += n
    if lo >= base then
        hi += flr(lo / base)
        lo = lo % base
    end
    return hi, lo
end
