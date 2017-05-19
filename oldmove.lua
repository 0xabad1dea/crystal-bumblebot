-- movement control
-- huuuuuuge amounts of if-else logic, beware

local Move = {}
local Ram = require "Ram"
local Map = require "Map"

-- controller
Move.buttons = {
	A = false,
	B = false,
	Down = false,
	Left = false,
	Power = false, -- hmm don't press this one
	Right = false,
	Select = false,
	Start = false,
	Up = false
	-- look these are the order they're in bizhawk okay
}

-- let go of controller
function Move.clearbuttons()
	Move.buttons.A = false
	Move.buttons.B = false
	Move.buttons.Up = false
	Move.buttons.Down = false
	Move.buttons.Left = false
	Move.buttons.Right = false
	Move.buttons.Select = false
	Move.buttons.Start = false
	Move.buttons.Power = false
end

Move.lastdir = 0
Move.facing = 0
Move.goalfail = 0 -- consecutive non-goal-success steps
Move.bumblemode = false -- for bumble routing to cool down the goalfail
Move.bumblecount = 0 -- how many bumbles we've done on current map
Move.bumpcount = 0 -- number of consecutive bumps


-- spama spams A.
function Move.spama()
	Move.clearbuttons()
	if human then
		return
	end
	local r = math.random(1,100)
	if r <= 50 then
		Move.buttons.A = true
	end
	joypad.set(Move.buttons)
	return
end

-- fidget is default strategy for dialogs and menus
-- 60% A 20% B 5% each arrow
function Move.fidget()
	Move.clearbuttons()
	if human then
		return
	end
	local r = math.random(1,100)
	local pc = Ram.get(Ram.addr.tileup)
	if r <= 60 then
		-- special case added for The Dreaded PC,
		-- inverting the A/B ratio
		if pc == 0x93 then
			Move.buttons.B = true
		else
			Move.buttons.A = true
		end
	elseif r <= 80 then
		if pc == 0x93 then
			Move.buttons.A = true
		else
			Move.buttons.B = true
		end
	elseif r <= 85 then
		Move.buttons.Up = true
	elseif r <= 90 then
		Move.buttons.Down = true
	elseif r <= 95 then
		Move.buttons.Left = true
	else
		Move.buttons.Right = true
	end
	
	joypad.set(Move.buttons)
end

-- strategy for flailing in battle.
--much A, some B, more right than up/down/left
function Move.battle()
	Move.clearbuttons()
	if human then
		return
	end
	local r = math.random(1,100)
	if r <= 50 then
		Move.buttons.A = true
	elseif r <= 75 then
		Move.buttons.B = true
	elseif r <= 80 then
		Move.buttons.Up = true
	elseif r <= 85 then
		Move.buttons.Down = true
	elseif r <= 90 then
		Move.buttons.Left = true
	else
		Move.buttons.Right = true
	end
	
	joypad.set(Move.buttons)
end


-- wander, mostly in direction last wandered
function Move.bumble()
	Move.clearbuttons()
	if human then
		return
	end
	local r = 0
	local skip = 0 -- no goto in lua 5.1 :'(
	-- movement type 3 is bump. works against sprites and tiles.
	local movement = Ram.get(Ram.addr.movement)
	-- starting from a dead stop
	if Move.lastdir == 0 then
		r = math.random(1,100)
		if r <= 25 then
			Move.lastdir = "Up"
		elseif r <= 50 then
			Move.lastdir = "Down"
		elseif r <= 75 then
			Move.lastdir = "Left"
		else
			Move.lastdir = "Right"
		end
	end
	
	-- deflecting on bump detection, clockwise
	if movement == 0x03 then
		--print("BUMP BUMP BUMP")
		if Move.lastdir == "Up" then
			Move.buttons.Right = true
		elseif Move.lastdir == "Right" then
			Move.buttons.Down = true
		elseif Move.lastdir == "Down" then
			Move.buttons.Left = true
		else
			Move.buttons.Up = true
		end
		skip = 1
	end
	
	r = math.random(1,100)
	if skip == 0 then
		if r <= 92 then
			Move.buttons[Move.lastdir] = true
		elseif r <= 94 then
			Move.buttons.Left = true
		elseif r <= 96 then
			Move.buttons.Right = true
		elseif r <= 98 then
			Move.buttons.Up = true
		else
			Move.buttons.Down = true
		end
	end
	
	-- press a or b (interact with ALL the things!)
	-- or occasionally start, hack around weird dialogues
	r = math.random(1,100)
	if r <= 75 then
		Move.buttons.A = true
	elseif r <= 97 then
		Move.buttons.B = true
	else
		Move.buttons.Start = true
	end
	
	-- oh right gotta actually update lastdir
	--if skip == 0 then
		if Move.buttons.Up == true then
			Move.lastdir = "Up"
		elseif Move.buttons.Down == true then
			Move.lastdir = "Down"
		elseif Move.buttons.Left == true then
			Move.lastdir = "Left"
		else
			Move.lastdir = "Right"
		end
	--end
	
	-- handle goalfail
	if(((Map.hasggoal == true) or (Map.hascgoal == true)) and
	(Map.hasbgoal == false)) then
		-- this one deliberately does not check for tilechange
		-- FIXME commented out while refactoring
		--Move.goalfail = Move.goalfail + 1
	elseif Map.hasbgoal == true then -- bumblemode
		if Move.goalfail > 0 then
			if((Map.prevxpos ~= xpos) or (Map.prevypos ~= ypos)) then
				--Move.goalfail = Move.goalfail - 1
			end
		end
		if Move.goalfail == 0 then
			Map.hasbgoal = false
		end
	end
	
	joypad.set(Move.buttons)
	
end


-- attempt to close in on goal on current map.
-- pass co-ords of goal.
-- returns true on reached, false on not reached
function Move.togoal(xgoal, ygoal)
	Move.clearbuttons()
	if human then
		return false
	end
	
	
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnum = Ram.get(Ram.addr.mapnumber)
	local r = 0
	
	if(Move.hascgoal == true and Map.maps[mapbank][mapnum][Map.cgoalx][Map.cgoaly] == 0xff) then
		Move.yfirst(xpos, ypos, Map.cgoalx, Map.cgoaly)
		print("++++CGOAL DESPERADO???+++")
		return true
	end
	
	-- if we've detected that the goal is a solid object,
	-- declare CLOSE ENOUGH victory
	-- FIXME FIXME we had a crash entering a house - maybe fixed?
	if Map.iswalkable(Map.maps[mapbank][mapnum][xgoal][ygoal]) == false then
		print("Determined goal was solid")
		gui.addmessage("Goal is a wall. close enough lol")
		--Move.goalfail = 0 -- FIXME getting an infinite loop here
		return true
	end
	
	-- similarly, if we've detected that the goal is surrounded,
	-- also CLOSE ENOUGH
	if Map.isblocked(xgoal, ygoal) then
		print("Determined goal was blocked off")
		gui.addmessage("Goal is blocked. wahh")
		--Move.goalfail = 0
		return true
	end
	
	-- if we're at goal, stand still and press a
	-- given goal
	if (xgoal == xpos) and (ygoal == ypos) then
		if((Map.prevxpos ~= xpos) or (Map.prevypos ~= ypos)) then
			Move.buttons.A = true
			joypad.set(Move.buttons)
			print("====Goal reached!: " .. 
			bizstring.hex(xgoal) .. "," .. bizstring.hex(ygoal))
			gui.addmessage("Goal reached!")
		end
		Move.goalfail = 0
		
		return true
	end
	

	-- game goal, independent of given goal
	-- (added after watching her bumblegoal over her gamegoal)
	if (Map.hasggoal == true) and (Map.ggoalx == xpos) 
	and (Map.ggoaly == ypos) and (Map.ggoalmbank == mapbank)
	and (Map.ggoalmnum == mapnum) then
		if((Map.prevxpos ~= xpos) or (Map.prevypos ~= ypos)) then
			Move.buttons.A = true
			joypad.set(Move.buttons)
			print("====Goal reached!: " .. 
			bizstring.hex(xgoal) .. "," .. bizstring.hex(ygoal))
			gui.addmessage("Gamegoal reached during non-gg routing")
		end
		Move.goalfail = 0
		
		return true
	end
	
	-- if we're in bump, try something wild
	local movement = Ram.get(Ram.addr.movement)
	if movement == 0x03 then
		Move.bumble()
		return false
	end
	
	-- frequently but not constantly try to interact
	r = math.random(1,100)
	if r <= 40 then
		Move.buttons.A = true
	elseif r <= 70 then
		Move.buttons.B = true
	end
	
	-- this is an attempt to avoid getting stuck in corners
	-- by alternating whether we prefer x or y regularly.
	r = math.random(1,100)
	if r <= 50 then
		Move.xfirst(xpos, ypos, xgoal, ygoal)
		Move.yfirst(xpos, ypos, xgoal, ygoal)
	else
		Move.yfirst(xpos, ypos, xgoal, ygoal)
		Move.xfirst(xpos, ypos, xgoal, ygoal)
	end
	
	-- update lastdir
	if Move.buttons.Up == true then
		Move.lastdir = "Up"
	elseif Move.buttons.Down == true then
		Move.lastdir = "Down"
	elseif Move.buttons.Left == true then
		Move.lastdir = "Left"
	else
		Move.lastdir = "Right"
	end
	
	-- handle goalfail
	if Map.hasbgoal == false then -- not bumblemode
		if((Map.prevxpos ~= xpos) or (Map.prevypos ~= ypos)) then
			-- actual tile transition or bump
			Move.goalfail = Move.goalfail + 1
		end
	else	-- is bumblemode
		if((Map.prevxpos ~= xpos) or (Map.prevypos ~= ypos)) then
			if Move.goalfail > 0 then
				Move.goalfail = Move.goalfail - 1
			end
			if Move.goalfail == 0 then
				Map.hasbgoal = false
			end
		end
	end
	
	return false
	
end

-- note to self: .xfirst and .yfirst have a lot of mirrored code,
-- remember not to update one and not the other! :)
	
-- interior to Move.togoal()
function Move.xfirst(xpos, ypos, xgoal, ygoal)
	local bank = Ram.get(Ram.addr.mapbank)
	local num = Ram.get(Ram.addr.mapnumber)
	
	-- passability of adjacent tiles
	local tleft = false
	if xpos ~= 0x00 then
		tleft = Map.iswalkable(Map.maps[bank][num][xpos-1][ypos])
	end
	local tright = false
	if xpos ~= 0xFF then
		tright = Map.iswalkable(Map.maps[bank][num][xpos+1][ypos])
	end
	local tup = false
	if ypos ~= 0x00 then
		tup = Map.iswalkable(Map.maps[bank][num][xpos][ypos-1])
	end
	local tdown = false
	if ypos ~= 0xFF then
		tdown = Map.iswalkable(Map.maps[bank][num][xpos][ypos+1])
	end
	local tlast = false
	if Move.lastdir == "Up" then
		tlast = tup
	elseif Move.lastdir == "Down" then
		tlast = tdown
	elseif Move.lastdir == "Left" then
		tlast = tleft
	elseif Move.lastdir == "Right" then
		tlast = tright
	end
	
	-- moving right
	if xgoal > xpos then
		r = math.random(1,100)
		if r <= 80 then
			if tright == true then
				Move.buttons.Right = true
			elseif tlast == true then
				Move.buttons[Move.lastdir] = true
			elseif tup == true then
				Move.buttons.Up = true
			elseif tdown == true then
				Move.buttons.Down = true
			else
				Move.buttons.Left = true
			end
		elseif r <= 95 then
			if ygoal < ypos then
				Move.buttons.Up = true
			else
				Move.buttons.Down = true
			end
		else
			if ygoal < ypos then
				Move.buttons.Down = true
			else
				Move.buttons.Up = true
			end
		end
		joypad.set(Move.buttons)
		return false
	end
	
	-- moving left
	if xgoal < xpos then
		r = math.random(1,100)
		if r <= 80 then
			if tleft == true then
				Move.buttons.Left = true
			elseif tlast == true then
				Move.buttons[Move.lastdir] = true
			elseif tup == true then
				Move.buttons.Up = true
			elseif tdown == true then
				Move.buttons.Down = true
			else
				Move.buttons.Right = true
			end
		elseif r <= 95 then
			if ygoal < ypos then
				Move.buttons.Up = true
			else
				Move.buttons.Down = true
			end
		else
			if ygoal < ypos then
				Move.buttons.Down = true
			else
				Move.buttons.Up = true
			end
		end
		joypad.set(Move.buttons)
		return false
	end
	return false
end
	
	
-- interior to Move.togoal()
function Move.yfirst(xpos, ypos, xgoal, ygoal)
	local bank = Ram.get(Ram.addr.mapbank)
	local num = Ram.get(Ram.addr.mapnumber)
	
	-- passability of adjacent tiles
	local tleft = false
	if xpos ~= 0x00 then
		tleft = Map.iswalkable(Map.maps[bank][num][xpos-1][ypos])
	end
	local tright = false
	if xpos ~= 0xFF then
		tright = Map.iswalkable(Map.maps[bank][num][xpos+1][ypos])
	end
	local tup = false
	if ypos ~= 0x00 then
		tup = Map.iswalkable(Map.maps[bank][num][xpos][ypos-1])
	end
	local tdown = false
	if ypos ~= 0xFF then
		tdown = Map.iswalkable(Map.maps[bank][num][xpos][ypos+1])
	end
	local tlast = false
	if Move.lastdir == "Up" then
		tlast = tup
	elseif Move.lastdir == "Down" then
		tlast = tdown
	elseif Move.lastdir == "Left" then
		tlast = tleft
	elseif Move.lastdir == "Right" then
		tlast = tright
	end
	
	-- moving up
	if ygoal < ypos then
		r = math.random(1,100)
		if r <= 80 then
			if tup == true then
				Move.buttons.Up = true
			elseif tlast == true then
				Move.buttons[Move.lastdir] = true
			elseif tleft == true then
				Move.buttons.Left = true
			elseif tright == true then
				Move.buttons.Right = true
			else
				Move.buttons.Down = true
			end
		elseif r <= 95 then
			if xgoal > xpos then
				Move.buttons.Right = true
			else
				Move.buttons.Left = true
			end
		else
			if xgoal > xpos then
				Move.buttons.Left = true
			else
				Move.buttons.Right = true
			end
		end
		joypad.set(Move.buttons)
		return false
	end
	
	-- moving down
	if ygoal > ypos then
		r = math.random(1,100)
		if r <= 80 then
			if tdown == true then
				Move.buttons.Down = true
			elseif tlast == true then
				Move.buttons[Move.lastdir] = true
			elseif tright == true then
				Move.buttons.Right = true
			elseif tleft == true then
				Move.buttons.Left = true
			else
				Move.buttons.Up = true
			end
		elseif r <= 95 then
			if xgoal > xpos then
				Move.buttons.Right = true
			else
				Move.buttons.Left = true
			end
		else
			if xgoal > xpos then
				Move.buttons.Left = true
			else
				Move.buttons.Right = true
			end
		end
		joypad.set(Move.buttons)
		return false
	end
	return false
end


-- picking bumble goals.
function Move.choosebgoal()
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	local width = Ram.get(Ram.addr.mapwidth) * 2
	local height = Ram.get(Ram.addr.mapheight) * 2
	local radius = 0
	
	-- this seems like the right place to do this
	Move.bumblecount = Move.bumblecount + 1
	-- clamping radius to map size
	if brad > math.min(width, height) then
		radius = math.min(width, height)
	elseif Move.bumblecount > 8 then
	-- trying smaller distances if we might be stuck
		radius = math.min(radius, 8)
	else
		radius = brad
	end
	Map.bgoalx = math.random(xpos-radius,xpos+radius)
	Map.bgoaly = math.random(ypos-radius,ypos+radius)
	-- clamping again (we clamp twice because otherwise
	-- we'd *constantly* get the same few goals on small maps)
	if Map.bgoalx < 0 then
		Map.bgoalx = 0
	elseif Map.bgoalx >= width then
		Map.bgoalx = width-1
	end
	if Map.bgoaly < 0 then
		Map.bgoaly = 0
	elseif Map.bgoaly >= height then
		Map.bgoaly = height-1
	end
end

-- picking a connection goal (false if we can't)
function Move.choosecgoal()
	print("++++INSIDE CHOOSECGOAL++++")
	local exits = Map.getexits()
	local num = table.getn(exits)
	local tileup = Ram.get(Ram.addr.tileup)
	local tiledown = Ram.get(Ram.addr.tiledown)
	local tileleft = Ram.get(Ram.addr.tileleft)
	local tileright = Ram.get(Ram.addr.tileright)
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	if num == 0 then
		-- no known exits. we are going to die here
		return false
	end
	-- if we are on worldedge, route off the edge w/ high prio
	-- (we probs cgoal'd onto a doormat)
	if(xpos == Map.cgoalx and ypos == Map.cgoaly) then
		if tiledown == 0xFF then
			Map.cgoalx = xpos
			Map.cgoaly = ypos+1
			Map.hasbgoal = false
			human = true
			return true
		end
		if tileup == 0xFF then
			Map.cgoalx = xpos
			Map.cgoaly = ypos-1
			Map.hasbgoal = false
			return true
		end
		if tileleft == 0xFF then
			Map.cgoalx = xpos-1
			Map.cgoaly = ypos
			Map.hasbgoal = false
			return true
		end
		if tileright == 0xFF then
			Map.cgoalx = xpos+1
			Map.cgoaly = ypos
			Map.hasbgoal = false
			return true
		end
	end
	local r = math.random(1, num)
	Map.cgoalx = exits[r][1]
	Map.cgoaly = exits[r][2]
	
	return true
end

-- picking a game goal (false if we can't)
-- not implemented
function Move.chooseggoal()
	return false
end

return Move
