--Perlin noise what is this even

Terraria = Terraria or {};

local random, randomseed = math.random, math.randomseed
local floor = math.floor
local max, min = math.max, math.min
 
local octaves = 3
local persistence = 0.5
local noised = {}
 
function cos_interpolate(a, b, x)
        local ft = x * math.pi
        local f = (1 - math.cos(ft)) * .5
 
        return  a * (1 - f) + b * f
end
 
function noise_2d(x, y, i, seed)
        local nx = noised[x]
 
        if (nx and nx[y]) then
                return nx[y]
        else
                nx = nx or {}
                randomseed((x * seed + y * i ^ 1.1 + 14) / 789221 + 33 * x + 15731 * y * seed)
        end
 
        random()
 
        noised[x] = nx
        nx[y] = random(-1000, 1000) / 1000
 
        return nx[y]
end
 
function smooth_noise_2d(x, y, i, seed)
        local corners = (noise_2d(x - 1, y - 1, i, seed) + noise_2d(x + 1, y - 1, i, seed) + noise_2d(x - 1, y + 1, i, seed) + noise_2d(x + 1, y + 1, i, seed)) / 16
        local sides = (noise_2d(x - 1, y, i, seed) + noise_2d(x + 1, y, i, seed) + noise_2d(x, y - 1, i, seed) + noise_2d(x, y + 1, i, seed)) / 8
        local center = noise_2d(x, y, i, seed) / 4
        return corners + sides + center
end
 
function interpolate_noise_2d(x, y, i, seed)
        local int_x = floor(x)
        local frac_x = x - int_x
 
        local int_y = floor(y)
        local frac_y = y - int_y
 
        local v1 = smooth_noise_2d(int_x, int_y, i, seed)
        local v2 = smooth_noise_2d(int_x + 1, int_y, i, seed)
        local v3 = smooth_noise_2d(int_x, int_y + 1, i, seed)
        local v4 = smooth_noise_2d(int_x + 1, int_y + 1, i, seed)
 
        local i1 = cos_interpolate(v1, v2, frac_x)
        local i2 = cos_interpolate(v3, v4, frac_x)
 
        return cos_interpolate(i1, i2, frac_y)
end
 
function perlin_2d(x, y, seed)
        local total = 0
        local p = persistence
        local n = octaves - 1
 
        for i = 0, n do
                local frequency = 2 ^ i
                local amplitude = p ^ i
 
                total = total + interpolate_noise_2d(x * frequency, y * frequency, i, seed) * amplitude
        end
 
        return total
end

function makeSomeNoise()
    noise1,noise2,noise3 = perlin(800, {4,10,20}), perlin(800, {10,50,100}), perlin(800, {10,300})
end


function perlin(n, granulation, seed)
    local function lerp(x,y,t) return x+(y-x)*t end     -- Linear interpolation: Faster, but uglier
    local function cerp(x,y,t) local f=(1-math.cos(t*math.pi))*.5 return x*(1-f)+y*f end        -- Cosine interpolation: Slower, but prettier
    if seed then math.randomseed(seed) math.random() end
    granulation = granulation or {2,8,32}
    local noise = {}
    
    for scalei,scale in ipairs(granulation) do  
        local t = {}
        for i=1,n/scale+scale+1 do t[i] = math.random()-.5 end
        
        for i=n,n do
            local x,y,t = t[math.floor(n/scale)+1], t[math.floor(n/scale)+2], (n%scale)/scale
            return (noise[i] or 0) * ((granulation[scalei-1] or 1) / scale) + cerp(x,y,t)
        end
    end
    return noise
end