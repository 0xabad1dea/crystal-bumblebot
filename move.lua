-- movement control
local Move = {}
local Ram = require "ram"

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


-- fidget is default strategy for dialogs and menus
-- 70% A 10% B 5% each arrow
function Move.fidget()
	Move.clearbuttons()
	if human then
		return
	end
	local r = math.random(1,100)
	if r <= 70 then
		Move.buttons.A = true
	elseif r <= 80 then
		Move.buttons.B = true
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
	r = math.random(1,100)
	if r <= 50 then
		Move.buttons.A = true
	else
		Move.buttons.B = true
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


-- attempt to close in on goal on current map.
-- pass co-ords of goal.
-- returns true on reached, false on not reached
function Move.togoal(xgoal, ygoal)
	Move.clearbuttons()
	if human then
		return
	end
	
	-- if we're in bump, try something wild
	local movement = Ram.get(Ram.addr.movement)
	if movement == 0x03 then
		Move.bumble()
		return
	end
	
	local xpos = Ram.get(Ram.addr.xpos)
	local ypos = Ram.get(Ram.addr.ypos)
	local r = 0
	
	-- if we're at goal, stand still and press a
	if xgoal == xpos and ygoal == ypos then
		Move.buttons.A = true
		joypad.set(Move.buttons)
		print("====Goal reached!: " .. xgoal .. "," .. ygoal)
		return true
	end
	
	-- otherwise we move directly towards goal 80% of time
	-- and possibly tangential to it 20% of time
	
	-- moving right
	if xgoal > xpos then
		r = math.random(1,100)
		if r <= 80 then
			Move.buttons.Right = true
		elseif r <= 90 then
			Move.buttons.Up = true
		else
			Move.buttons.Down = true
		end
		joypad.set(Move.buttons)
		return false
	end
	
	-- moving left
	if xgoal < xpos then
		r = math.random(1,100)
		if r <= 80 then
			Move.buttons.Left = true
		elseif r <= 90 then
			Move.buttons.Up = true
		else
			Move.buttons.Down = true
		end
		joypad.set(Move.buttons)
		return false
	end
	
	-- moving up
	if ygoal < ypos then
		r = math.random(1,100)
		if r <= 80 then
			Move.buttons.Up = true
		elseif r <= 90 then
			Move.buttons.Left = true
		else
			Move.buttons.Right = true
		end
		joypad.set(Move.buttons)
		return false
	end
	
	-- moving down
	if ygoal > ypos then
		r = math.random(1,100)
		if r <= 80 then
			Move.buttons.Down = true
		elseif r <= 90 then
			Move.buttons.Left = true
		else
			Move.buttons.Right = true
		end
		joypad.set(Move.buttons)
		return false
	end
	
	print("!!! Warning: end of Move.togoal")
	return false

end


return Move