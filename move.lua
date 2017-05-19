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
Move.doorcooldown = 0 -- steps since we last transitioned areas


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
	

	
	joypad.set(Move.buttons)
	
end


-- choose an arbitrary spot on the map to try to navigate to
function Move.choosebgoal()
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnumber = Ram.get(Ram.addr.mapnumber)
	local width = Ram.get(Ram.addr.mapwidth) * 2
	local height = Ram.get(Ram.addr.mapheight) * 2
	local goalx = 0
	local goaly = 0
	
	-- will pick either a known good spot or a 0xff spot
	while true do
		goalx = math.random(0,width-1)
		goaly = math.random(0,height-1)
		if(Map.iswalkable(Map.maps[mapbank][mapnumber][goalx][goaly]) or 
		Map.isdoor(Map.maps[mapbank][mapnumber][goalx][goaly])) then
			break
		end
	end
	Map.hasbgoal = true
	Map.bgoalx = goalx
	Map.bgoaly = goaly
end

-- take a step towards a goal
function Move.routetogoal(x, y)
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	local mapbank = Ram.get(Ram.addr.mapbank)
	local mapnumber = Ram.get(Ram.addr.mapnumber)
	
	Move.clearbuttons()
	if human then
		return false
	end
	
	-- I don't know why this happened but it clearly did
	if((x == xpos) and (y == ypos)) then
		return false
	end
	
	-- horizontal movement first, vertical movement second
	-- try to move in correct direction first, then parallel plane,
	-- backwards last
	
	-- left
	if (x < xpos) then
		if(Map.iswalkable(Map.maps[mapbank][mapnumber][math.max(0,xpos-1)][ypos])) then
			Move.buttons.Left = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][xpos][math.max(0,ypos-1)])) then
			Move.buttons.Up = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][xpos][math.min(255,ypos+1)])) then
			Move.buttons.Down = true
		else
			Move.buttons.Right = true
		end
		joypad.set(Move.buttons)
		return true
	end
	
	-- right
	if (x > xpos) then
		if(Map.iswalkable(Map.maps[mapbank][mapnumber][math.min(255,xpos+1)][ypos])) then
			Move.buttons.Right = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][xpos][math.max(0,ypos-1)])) then
			Move.buttons.Up = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][xpos][math.min(255,ypos+1)])) then
			Move.buttons.Down = true
		else
			Move.buttons.Left = true
		end
		joypad.set(Move.buttons)
		return true
	end
	
	-- up
	if (y < ypos) then
		if(Map.iswalkable(Map.maps[mapbank][mapnumber][xpos][math.max(0,ypos-1)])) then
			Move.buttons.Up = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][math.max(0,xpos-1)][ypos])) then
			Move.buttons.Left = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][math.min(255,xpos+1)][ypos])) then
			Move.buttons.Right = true
		else
			Move.buttons.Down = true
		end
		joypad.set(Move.buttons)
		return true
	end
	
	-- down
	if (y > ypos) then
		if(Map.iswalkable(Map.maps[mapbank][mapnumber][xpos][math.min(255,ypos+1)])) then
			Move.buttons.Down = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][math.max(0,xpos-1)][ypos])) then
			Move.buttons.Left = true
		elseif(Map.iswalkable(Map.maps[mapbank][mapnumber][math.min(255,xpos+1)][ypos])) then
			Move.buttons.Right = true
		else
			Move.buttons.Up = true
		end
		joypad.set(Move.buttons)
		return true
	end
	
	-- this *shouldn't* ever happen lol
	print("error: reached false in routetogoal")
	return false
end

return Move
