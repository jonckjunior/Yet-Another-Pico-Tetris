menu_items = {
    "start",
    "mode: classic",
    "options"
}

selected = 1

function update_menu()
    if btnp(2) then selected -= 1 end -- up
    if btnp(3) then selected += 1 end -- down

    selected = mid(1, selected, #menu_items)

    if btnp(5) then
        if selected == 1 then
            change_mode("playing")
        elseif selected == 2 then
            -- cycle mode
        elseif selected == 3 then
            change_mode("options")
        end
    end
end

dark_map = {
    [7] = 6,
    [6] = 6,
    [5] = 1,
    [1] = 5,
    [12] = 13,
    [13] = 1
}

function darken_pixel(x, y)
    local c = pget(x, y)
    local mapped = dark_map[c]
    if mapped then
        pset(x, y, mapped)
    else
        pset(x, y, 1)
    end
end

function bevel_box(x, y, w, h)
    -- white border
    rect(x - 1, y - 1, x + w, y + h, 7)
    -- black border
    rect(x - 2, y - 2, x + w + 1, y + h + 1, 0)
    for dx = 0, w - 1 do
        for dy = 0, h - 1 do
            darken_pixel(x + dx, y + dy)
        end
    end
end

function draw_diagonal_lines()
    pal(6, 129, 1)
    local scroll = (time() * 20) % 16
    for i = -128, 128, 8 do
        local x1 = i + scroll
        local x2 = i + 128 + scroll
        line(x1, 128, x2, 0, 6)
    end
end

function draw_cursor(x, y)
    local height = 6
    local width = { 2, 3, 4, 5, 4, 3, 2 }
    for dy = 0, height do
        for dx = 0, width[dy + 1] - 1 do
            local c = (dx == 0 or dx == width[dy + 1] - 1) and 0 or 7
            pset(x + dx, y + dy, c)
        end
    end
end

function draw_menu_items(box_x, box_y, box_w, box_h)
    bevel_box(box_x, box_y, box_w, box_h)
    local n = #menu_items
    local item_h = box_h / n

    for i = 1, n do
        local slice_y = box_y + (i - 1) * item_h

        -- highlight full slice if selected
        if i == selected then
            rectfill(
                box_x,
                slice_y,
                box_x + box_w - 1,
                slice_y + item_h,
                1
            )
            -- line(box_x, slice_y - 1, box_x + box_w - 1, slice_y - 1, 6)
            -- line(box_x, slice_y + item_h + 1, box_x + box_w - 1, slice_y + item_h + 1, 6)
        end

        -- center text inside its slice
        local text = menu_items[i]
        local text_w = #text * 4
        local text_x = box_x + (box_w - text_w) / 2
        local text_y = slice_y + (item_h - 6) / 2 + 1 -- 6px font height

        local col = (i == selected) and 7 or 5
        print(text, text_x, text_y, col)
    end
end

function draw_menu()
    draw_diagonal_lines()
    local logo_width = 62
    local logo_height = 38

    local x = (127 - logo_width) / 2
    local y = (127 - logo_height) / 2 - 20
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

    local box_y = 82
    local box_w = 60
    local box_h = 37
    local box_x = (127 - box_w) / 2
    draw_menu_items(box_x, box_y, box_w, box_h)
end
