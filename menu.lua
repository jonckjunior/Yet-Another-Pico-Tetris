---@class Menu
---@field items table
---@field selected integer
---@field selected_challenge integer
---@field dark_map table
local Menu = {}

---Creates a new menu
---@return Menu
function Menu:new()
    local m = {}

    m.items = {
        "start",
        "mode",
        "options"
    }

    m.selected = 1
    m.selected_challenge = 1

    m.dark_map = {
        [7] = 6,
        [6] = 6,
        [5] = 1,
        [1] = 5,
        [12] = 13,
        [13] = 1
    }

    self.__index = self
    setmetatable(m, self)
    return m
end

---Returns the currently selected Challenge object
function Menu:current_challenge()
    return CHALLENGES[self.selected_challenge]
end

---Update menu state and handle input
function Menu:update_menu()
    if transition:blocks_input() then
        return
    end

    if btnp(2) then -- up
        self.selected -= 1
        -- print("\asfcdefg \asfefgab")
        sfx(1)
    end
    if btnp(3) then -- down
        self.selected += 1
        sfx(0)
    end

    if self.selected == 2 then
        if btnp(1) then
            sfx(1)
            self.selected_challenge = (self.selected_challenge % #CHALLENGES) + 1
        elseif btnp(0) then
            sfx(0)
            self.selected_challenge = ((self.selected_challenge - 2) % #CHALLENGES) + 1
        end
    end

    self.selected = mid(1, self.selected, #self.items)

    if btnp(5) or btnp(4) then
        if self.selected == 1 then
            sfx(2)
            transition:start("menu", "playing")
        elseif self.selected == 2 then
            -- cycle through challenges
        elseif self.selected == 3 then
            -- change_mode("options")
        end
    end
end

---Darken a pixel at given coordinates
---@param x integer
---@param y integer
function Menu:darken_pixel(x, y)
    local c = pget(x, y)
    local mapped = self.dark_map[c]
    if mapped then
        pset(x, y, mapped)
    else
        pset(x, y, 1)
    end
end

---Draw a beveled box
---@param x integer
---@param y integer
---@param w integer
---@param h integer
function Menu:bevel_box(x, y, w, h)
    -- white border
    rect(x - 1, y - 1, x + w, y + h, 7)
    -- black border
    rect(x - 2, y - 2, x + w + 1, y + h + 1, 0)
    for dx = 0, w - 1 do
        for dy = 0, h - 1 do
            self:darken_pixel(x + dx, y + dy)
        end
    end
end

---Draw diagonal lines background
function Menu:draw_diagonal_lines()
    pal(6, 129, 1)
    local scroll = (time() * 20) % 16
    for i = -128, 128, 8 do
        local x1 = i + scroll
        local x2 = i + 128 + scroll
        line(x1, 128, x2, 0, 6)
    end
end

---Draw cursor at given position
---@param x integer
---@param y integer
---@param sign integer
function Menu:draw_cursor(x, y, sign)
    sign = sign or 1
    local height = 6
    local width = { 2, 3, 4, 5, 4, 3, 2 }
    for dy = 0, height do
        for dx = 1, width[dy + 1] - 2 do
            pset(x + dx * sign, y + dy, 7)
        end
    end
end

---Draw menu items in a box
---@param box_x integer
---@param box_y integer
---@param box_w integer
---@param box_h integer
function Menu:draw_menu_items(box_x, box_y, box_w, box_h)
    self:bevel_box(box_x, box_y, box_w, box_h)
    local n = #self.items
    local item_h = box_h / n

    for i = 1, n do
        local slice_y = box_y + (i - 1) * item_h

        -- highlight full slice if selected
        if i == self.selected then
            rectfill(
                box_x,
                slice_y,
                box_x + box_w - 1,
                slice_y + item_h,
                1
            )
        end

        -- build display text (mode item shows current challenge label)
        local text = self.items[i]
        if i == 2 then
            text = "mode: " .. self:current_challenge().name
        end

        local text_w = #text * 4
        local text_x = box_x + (box_w - text_w) / 2
        local text_y = slice_y + (item_h - 6) / 2 + 1 -- 6px font height

        local col = (i == self.selected) and 7 or 5
        print(text, text_x, text_y, col)

        if i == self.selected and i == 2 then
            self:draw_cursor(text_x + text_w + 1, text_y - 1, 1)
            self:draw_cursor(text_x - 3, text_y - 1, -1)
        end
    end
    self:draw_challenge_description(box_y, box_h)
end

---Draws the description for the current selected challenge
---@param box_y integer
---@param box_h integer
function Menu:draw_challenge_description(box_y, box_h)
    local description = self:current_challenge().label
    local lines = split(description)

    -- Draw each line centered
    local y = box_y + box_h + 5
    for line in all(lines) do
        local line_w = #line * 4
        print(line, (127 - line_w) / 2, y, 5)
        y += 6 -- Move down for next line
    end
end

---Draw the complete menu
function Menu:draw_menu()
    self:draw_diagonal_lines()
    local logo_width = 62
    local logo_height = 38

    local x = (127 - logo_width) / 2
    local y = (127 - logo_height) / 2 - 30
    local t = time()
    local offset = sin(t * 0.5) * 2 -- speed * amplitude

    circfill(x + logo_width / 2, y + offset + logo_height / 2, 30 + 1, 0)
    circfill(x + logo_width / 2, y + offset + logo_height / 2, 30, 1)

    for i = 1, 15 do
        pal(i, drk[i])
    end
    spr(16, x + 2, y + offset + 2, logo_width, logo_height)
    pal(0)
    spr(16, x, y + offset, logo_width, logo_height)

    local box_y = 72
    local box_w = 70
    local box_h = 37
    local box_x = (127 - box_w) / 2
    self:draw_menu_items(box_x, box_y, box_w, box_h)
end
