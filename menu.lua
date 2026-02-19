menu_network = ParticleNetwork:new(40, 24, 1)

function update_menu()
    menu_network:update()
    if btnp(5) then
        change_mode("playing")
    end
end

function draw_menu()
    -- fillp(0b0101010110101010)
    -- rectfill(0, 0, 127, 127, 0)
    -- fillp()
    -- menu_network:draw()
    local logo_width = 62
    local logo_height = 38
    local x = (127 - logo_width) / 2
    local y = (127 - logo_height) / 2 - 20
    local t = time()
    local offset = sin(t * 0.5) * 2 -- speed * amplitude

    circfill(x + logo_width / 2, y + offset + logo_height / 2, 30, 1)
    local drk = { [0] = 0, 0, 1, 1, 2, 1, 5, 6, 2, 4, 9, 3, 1, 1, 2, 5 }
    for i = 1, 15 do
        pal(i, drk[i])
    end
    spr(16, x + 2, y + offset + 2, logo_width, logo_height)
    pal()
    spr(16, x, y + offset, logo_width, logo_height)
    -- local t = sin(time() * 4)
    -- local col = (t > 0) and 7 or 6
    -- print("press x to start", 30, 76, col)
end
