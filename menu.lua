function update_menu()
    if btnp(5) then
        change_mode("playing")
    end
end

function draw_menu()
    print("tetris", 50, 50, 7)
    print("press x to start", 30, 56 + 20, 7)
end
