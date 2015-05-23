-- oh no here be maps and mapping and other messy things

local Map = {}
local Ram = require "ram"


-- [mapbank][mapnumber][x][y] + connections{ {x, y, -> b, n} }
-- we do NOT store the x,y of the destination of the connection,
-- because I had a race condition problem and decided it would be
-- easier to not actually care.
Map.maps = {}


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


return Map