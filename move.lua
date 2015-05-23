-- movement control
local Move = {}

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


-- fidget is default strategy for dialogs and menus
-- 70% A 10% B 5% each arrow
function Move.fidget()
	print("Reached fidget")
	Move.clearbuttons()
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


return Move