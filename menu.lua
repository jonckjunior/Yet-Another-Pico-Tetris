menu_network = ParticleNetwork:new(40, 24, 0.5)

function update_menu()
    menu_network:update()
    if btnp(5) then
        change_mode("playing")
    end
end

function draw_menu()
    menu_network:draw()
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
    pal()
    spr(16, x, y + offset, logo_width, logo_height)
    local t = sin(time() * 4)
    local col = (t > 0) and 7 or 6
    -- print("\f7\^o0ffgame over", 50, 50)
    -- print("\f7\^o0ffpress x to start", 30, 76, col)
    print("\^o1ffpress x to start", 30, 76, col)
end
