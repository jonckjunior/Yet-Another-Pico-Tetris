---@class ParticleNetwork
---@field particles table
---@field max_p integer
---@field connect_dist integer
---@field spd number
ParticleNetwork = {}
ParticleNetwork.__index = ParticleNetwork

function ParticleNetwork:new(max_p, connect_dist, spd)
    local obj = {
        particles = {},
        max_p = max_p or 40,
        connect_dist = connect_dist or 24,
        spd = spd or 0.5
    }
    setmetatable(obj, self)
    obj:init_particles()
    return obj
end

function ParticleNetwork:init_particles()
    for i=1, self.max_p do
        add(self.particles, {
            x = rnd(128),
            y = rnd(128),
            dx = rnd(self.spd) - (self.spd/2),
            dy = rnd(self.spd) - (self.spd/2)
        })
    end
end

function ParticleNetwork:update()
    for p in all(self.particles) do
        p.x += p.dx
        p.y += p.dy

        -- bounce
        if (p.x < 0 or p.x > 127) p.dx = -p.dx
        if (p.y < 0 or p.y > 127) p.dy = -p.dy
    end
end

function ParticleNetwork:draw()
    local thresh_sq = self.connect_dist * self.connect_dist

    for i=1, #self.particles do
        local p1 = self.particles[i]

        for j=i+1, #self.particles do
            local p2 = self.particles[j]

            local dx = p1.x - p2.x
            local dy = p1.y - p2.y
            local dist_sq = dx*dx + dy*dy

            if dist_sq < thresh_sq then
                local col = 1
                if (dist_sq < thresh_sq * 0.3) col = 6
                if (dist_sq < thresh_sq * 0.1) col = 7

                line(p1.x, p1.y, p2.x, p2.y, col)
            end
        end
    end

    -- draw points
    for p in all(self.particles) do
        pset(p.x, p.y, 7)
    end
end
