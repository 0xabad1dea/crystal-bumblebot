-- oh no here be maps and mapping and other messy things

local Map = {}
local Ram = require "Ram"


-- [mapbank][mapnumber][x][y] + connections{ {x, y, -> b, n} }
-- we do NOT store the x,y of the destination of the connection,
-- because I had a race condition problem and decided it would be
-- easier to not actually care.
Map.maps = {}
-- movement tracking (one of the few things to carry over between frames)
Map.prevmapbank = 0
Map.prevmapnum = 0
Map.prevxpos = 0
Map.prevypos = 0
-- current gamegoal (a gamegoal progresses the story)
Map.hasggoal = false
Map.ggoalmbank = 0
Map.ggoalmnum = 0
Map.ggoalx = 0
Map.ggoaly = 0
-- current connection goal (a door or map transition) 
Map.hascgoal = false
Map.cgoalx = 0
Map.cgoaly = 0
-- current bumblemode goal (when the route timeout happens and it reroutes)
Map.hasbgoal = false
Map.bgoalx = 0
Map.bgoaly = 0

 


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
	
	if type(Map.maps[mapbank]) ~= "table" then
		Map.maps[mapbank] = {}
		print("map: making new mapbank")
	end
	if type(Map.maps[mapbank][mapnumber]) ~= "table" then
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
		-- debug
		--if Map.isdoor(tileup) then
			--print("Door seen at " .. bizstring.hex(xpos) ..
			--"," .. bizstring.hex(ypos-1))
		--end
	end
	if ypos < 255 then
		Map.maps[mapbank][mapnumber][xpos][ypos+1] = tiledown
		-- debug
		if Map.isdoor(tiledown) then
			--print("Door seen at " .. bizstring.hex(xpos) ..
			--"," .. bizstring.hex(ypos+1))
		end
	end
	if xpos > 0 then
		Map.maps[mapbank][mapnumber][xpos-1][ypos] = tileleft
		-- debug
		if Map.isdoor(tileleft) then
			--print("Door seen at " .. bizstring.hex(xpos-1) ..
			--"," .. bizstring.hex(ypos))
		end
	end
	if xpos < 255 then
		Map.maps[mapbank][mapnumber][xpos+1][ypos] = tileright
		-- debug
		if Map.isdoor(tileright) then
			--print("Door seen at " .. bizstring.hex(xpos+1) ..
			--"," .. bizstring.hex(ypos))
		end
	end

end

-- returns if a given tiletype (the value stored in [mapbank][mapnumber[x][y]
-- is usually walkable, for routing attempts.
function Map.iswalkable(tiletype)
	if tiletype == nil then
		return false
	end
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
	elseif tiletype == 0xFF then -- map edge, but needed for this to work
		return true
	end
	return false
end

-- returns true if tile is a solid object
-- does NOT curerntly catch everything, presumably
function Map.isthing(tiletype)
	if tiletype == nil then
		return false
	end
	if tiletype == 0x07 then -- furniture and walls in general
		return true
	elseif tiletype == 0x12 then -- cuttable tree
		return true
	elseif tiletype == 0x15 then -- small tree
		return true
	elseif tiletype == 0x90 then -- counter
		return true
	elseif tiletype == 0x91 then -- bookcase
		return true
	elseif tiletype == 0x93 then -- computer (but not player's computer)
		return true
	elseif tiletype == 0x94 then -- radio (but not player's radio)
		return true
	elseif tiletype == 0x95 then -- map
		return true
	elseif tiletype == 0x96 then -- pokemart shelves
		return true
	elseif tiletype == 0x97 then -- tv
		return true
	elseif tiletype == 0x9d then -- window, but not Elm's window, but it IS Elm's mirror
		return true
	elseif tiletype == 0x9f then -- incense burner
		return true
	elseif tiletype == 0xb2 then -- ?? wall to left of door in dark cave
	end
	return false
end


-- returns true if the current map is indoors,
-- measured by having no map connectors.
function Map.isindoors()
	local conns = Ram.get(Ram.addr.mapconns)
	if conns == 0 then
		return true
	end
	return false
end

-- returns true if is a tile known to contain door triggers
-- note this does not mean there IS a door trigger there
-- note also that 0x72 result depends on indoor/outdoor of current map
function Map.isdoor(tiletype)
	if tiletype == 0x70 then -- exit down
		return true
	elseif tiletype == 0x71 then -- door (exit on)
		return true
	elseif tiletype == 0x72 then -- stairs or dock, wahh
		-- FIXME WARNING this assumption may break on Misty's gym
		-- or possibly other places???
		if Map.isindoors() then
			return true -- stairs
		else
			return false -- dock
		end
	elseif tiletype == 0x76 then -- exit left
		return true
	elseif tiletype == 0x7a then -- stairs
		return true
	elseif tiletype == 0x7b then -- cave door, exit on
		return true
	elseif tiletype == 0x7e then -- exit right
		return true
	end
	return false
end

-- returns Up, Down, Left, Right or false
-- for which way to go to trigger the door
function Map.doordirection(tiletype)
	if Map.isdoor(tiletype) == false then
		return false
	end
	if tiletype == 0x70 then
		return "Down"
	elseif tiletype == 0x71 then
		return "Up"
	elseif tiletype == 0x72 then
		return "Up"
	elseif tiletype == 0x76 then
		return "Left"
	elseif tiletype == 0x7a then
		return "Up"
	elseif tiletype == 0x7b then
		return "Up"
	elseif tiletype == 0x7e then
		return "Right"
	end
	return false
end


-- returns true if a square is *detected* to be blocked on all four sides
-- xpos, ypos of tile in question on current map
function Map.isblocked(xpos, ypos)
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnum = Ram.get(Ram.addr.mapnumber)
	local width = Ram.get(Ram.addr.mapwidth) * 2
	local height = Ram.get(Ram.addr.mapheight) * 2
	local left = false
	local right = false
	local up = false
	local down = false
	
	
	-- things on map edges are unreachable from that side
	-- (ignoring map connections which aren't blocked on three sides!)
	if xpos == 0 then
		left = true
	elseif xpos == width - 1 then
		right = true
	end
	if ypos == 0 then
		up = true
	elseif ypos == height - 1 then
		down = true
	end
	
	if (left == false) and 
	(Map.iswalkable(Map.maps[mapbank][mapnum][xpos-1][ypos]) == false) then
		left = true
	end
	if (right == false) and
	(Map.iswalkable(Map.maps[mapbank][mapnum][xpos+1][ypos]) == false) then
		right = true
	end
	if (up == false) and 
	(Map.iswalkable(Map.maps[mapbank][mapnum][xpos][ypos-1]) == false) then
		up = true
	end
	if (down == false) and
	(Map.iswalkable(Map.maps[mapbank][mapnum][xpos][ypos+1]) == false) then
		down = true
	end
	
	if left == true and right == true and up == true and down == true then
		return true
	end
	
	return false
	
end

-- returns { {y,x} } of currently known possible exit tiles
-- on the current map, for choosing for a connect goal
function Map.getexits()
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnumber = Ram.get(Ram.addr.mapnumber)
	local tile = 0
	local exits = {}
	for i = 0, 255 do
			for j = 0, 255 do
				tile = Map.maps[mapbank][mapnumber][j][i]
				if Map.isdoor(tile) == true then
					table.insert(exits, {j, i})
				end
			end
		end
	-- add in known overworld connections
	for i, v in pairs(Map.maps[mapbank][mapnumber].connections) do
		table.insert(exits, {v.y, v.x})
	end
	return exits
end


-- dumps the map in a roguelike style
-- # void _ walkable D door S solid P player B bgoal
-- this is truncated to the upper left 32x32 for sanity
function Map.textdump()
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnumber = Ram.get(Ram.addr.mapnumber)
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	local tile = 0
	row = {}
	for i = 0, 31 do
		for j = 0, 31 do
			tile = Map.maps[mapbank][mapnumber][j][i]
			-- OH MY GODS WAS I. STORING X AND Y SWAPPED THIS
			-- ENTIRE TIME -- as x/y or i/j when it should be y/x??
			if((Map.hasbgoal == true) and (j == Map.bgoalx) and (i == Map.bgoaly)) then
				row[#row+1] = "B"
			elseif (j == xpos) and (i == ypos) then
				row[#row+1] = "P"
			elseif tile == 0xff then
				row[#row+1] = "#"
			elseif Map.isdoor(tile) then
				row[#row+1] = "D"
			elseif Map.isthing(tile) then
				row[#row+1] = "S"
			elseif Map.iswalkable(tile) then
				row[#row+1] = "_"
			else
				row[#row+1] = "?"
			end
		end
		print(table.concat(row, ""))
		row = {}
	end
end



-- enumerate sprites (ugh I didn't wanna write this lol)
function Map.spritedump()
	memory.usememorydomain("OAM")
	local addr = 0x0
	local x = 0
	local y = 0
	local sprite = 0
	
	for i = 0, 39 do
		print("Sprite " .. i .. ":")
		print("\ty: " .. Ram.get(addr) .. " x: " .. Ram.get(addr+1) ..
		" sprite: " .. Ram.get(addr+2)) -- omits the attr flags byte
		addr = addr + 4
	end
	
	
	-- this is probably important :')
	memory.usememorydomain("WRAM")
end
		

return Map