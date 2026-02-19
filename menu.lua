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
    menu_network:draw()
    local logo_width = 62
    local logo_height = 38
    local x = (127 - logo_width) / 2
    local y = (127 - logo_height) / 2 - 20
    local t = time()
    local offset = sin(t * 1.2) * 2 -- speed * amplitude

    spr(16, x, y + offset, logo_width, logo_height)
    local t = sin(time() * 4)
    local col = (t > 0) and 7 or 6
    print("press x to start", 30, 76, col)
end
