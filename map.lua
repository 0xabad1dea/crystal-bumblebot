-- oh no here be maps and mapping and other messy things

local Map = {}
local Ram = require "ram"


-- [mapbank][mapnumber][x][y] + connections{ {x, y, -> b, n} }
-- we do NOT store the x,y of the destination of the connection,
-- because I had a race condition problem and decided it would be
-- easier to not actually care.
Map.maps = {}
Map.prevmapbank = 0
Map.prevmapnum = 0
Map.prevxpos = 0
Map.prevyos = 0


-- pulls what player can see (adjacent tiles) into our map
function Map.update()
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnumber = Ram.get(Ram.addr.mapnumber)
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	local tileup = Ram.get(Ram.addr.tileup)
	local tiledown = Ram.get(Ram.addr.tiledown)
	local tileleft = Ram.get(Ram.addr.tileleft)
	local tileright = Ram.get(Ram.addr.tileright)
	
	if Map.maps[mapbank] == nil then
		Map.maps[mapbank] = {}
		print("map: making new mapbank")
	end
	if Map.maps[mapbank][mapnumber] == nil then
		Map.maps[mapbank][mapnumber] = {}
		print("map: making new mapnumber")
		-- we go ahead and prefill the maximum size with map-edging (ff)
		for i = 0, 255 do
			Map.maps[mapbank][mapnumber][i] = {}
			for j = 0, 255 do
				Map.maps[mapbank][mapnumber][i][j] = 0xff
			end
		end
		Map.maps[mapbank][mapnumber].connections = {}
	end
	
	-- sometimes what we see is actually on the next map lol
	if ypos > 0 then
		Map.maps[mapbank][mapnumber][xpos][ypos-1] = tileup
	end
	if ypos < 255 then
		Map.maps[mapbank][mapnumber][xpos][ypos+1] = tiledown
	end
	if xpos > 0 then
		Map.maps[mapbank][mapnumber][xpos-1][ypos] = tileleft
	end
	if xpos < 255 then
		Map.maps[mapbank][mapnumber][xpos+1][ypos] = tileright
	end

end

-- returns if a given tiletype (the value stored in [mapbank][mapnumber[x][y]
-- is usually walkable, for routing attempts.
function Map.iswalkable(tiletype)
	if tiletype == 0x00 then -- ground or floor
		return true
	elseif tiletype == 0x18 then -- grass
		return true
	elseif tiletype == 0x29 then -- water, not walkable but this helps
		return true				 -- keep the algorithms generalized
	elseif tiletype == 0x70 then -- exit down
		return true
	elseif tiletype == 0x71 then -- door
		return true
	elseif tiletype == 0x72 then -- stairs or dock(?!)
		return true
	elseif tiletype == 0x76 then -- exit left
		return true
	elseif tiletype == 0x7a then -- different stairs *shrug*
		return true
	elseif tiletype == 0x7b then -- cave entrance
		return true
	elseif tiletype == 0x7e then -- exit right
		return true
	elseif (tiletype >= 0xA0) and (tiletype <= 0xA5) then -- ledge-edges
		return true
	end
	return false
end

return Map