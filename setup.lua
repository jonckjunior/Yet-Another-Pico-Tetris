function World:setup_tspin_test()
    for i = 1, 22 do
        for j = 1, 10 do
            self.grid[i][j] = self.grid_spr
        end
    end

    -- fills three bottom rows
    for i = 20, 22 do
        for j = 1, 10 do
            self.grid[i][j] = 5
        end
    end

    self.grid[22][3] = self.grid_spr
    self.grid[21][3] = self.grid_spr
    self.grid[20][3] = self.grid_spr
    self.grid[21][2] = self.grid_spr
    self.grid[20][2] = self.grid_spr

    self.grid[21][4] = self.grid_spr


    -- Force next piece to be T
    self.piece_queue = { "T", "I", "O", "S", "Z", "J", "L" }
    self:create_new_active_piece()
end

function World:setup_mini_tspin_test()
    for i = 1, 22 do
        for j = 1, 10 do
            self.grid[i][j] = self.grid_spr
        end
    end

    -- fills bottom row
    for j = 1, 10 do
        self.grid[22][j] = 5
    end

    self.grid[21][1] = 5
    self.grid[20][1] = 5
    self.grid[22][2] = self.grid_spr

    -- Force next piece to be T
    self.piece_queue = { "T", "I", "O", "S", "Z", "J", "L" }
    self:create_new_active_piece()
end

function World:setup_i_srs_test()
    for i = 22 - 9 + 1, 22 do
        for j = 1, 10 do
            self.grid[i][j] = 5
        end
    end

    self.grid[14][9] = self.grid_spr
    self.grid[15][9] = self.grid_spr
    self.grid[16][9] = self.grid_spr
    self.grid[17][9] = self.grid_spr
    self.grid[18][9] = self.grid_spr


    self.grid[18][9] = self.grid_spr
    self.grid[18][8] = self.grid_spr
    self.grid[18][7] = self.grid_spr
    self.grid[18][6] = self.grid_spr
    self.grid[18][5] = self.grid_spr

    self.grid[18][5] = self.grid_spr
    self.grid[19][5] = self.grid_spr
    self.grid[20][5] = self.grid_spr
    self.grid[21][5] = self.grid_spr
    self.grid[22][5] = self.grid_spr

    self.grid[22][5] = self.grid_spr
    self.grid[22][4] = self.grid_spr
    self.grid[22][3] = self.grid_spr
    self.grid[22][2] = self.grid_spr

    -- Force next piece to be T
    self.piece_queue = { "I", "I", "I", "I", "I", "I", "I" }
    self:create_new_active_piece()
end
