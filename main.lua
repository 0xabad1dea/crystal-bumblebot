--[[--
Crystal Bumble Bot by 0xabad1dea
May 21 2015

An artificial friend who plays Pokemon Crystal

inspired by, but not a fork of, thepokebot
--]]--

local Ram = require "ram"
local Sound = require "sound"
local Mode = require "mode"
local Map = require "map"
local Move = require "move"
local Goal = require "goal"

---- debug functions ----
function showexits()
	print("-----Known exits:-----")
	exits = Map.getexits()
	
	if table.getn(exits) == 0 then
		print("None! D:")
		return
	end
	for i, v in pairs(exits) do
			print(bizstring.hex(v[1]) .. "," ..
			bizstring.hex(v[2]))
	end
end

print("--------Bot booting--------");
math.randomseed(os.time())

-- config
-- type "human = true" into the console at any time
-- for ASSUMING DIRECT CONTROL
human = false
-- how long to route before engaging bumblerouting (rec: 128 to 256)
failmax = 64
-- maximum radius of bumbleroute goal (rec: 20 to 32)
brad = 32

-- TMP DEBUG: fixed goal routing
-- mr. pokemon's house
Map.ggoalmbank = 0x1A
Map.ggoalmnum = 0x01
Map.ggoalx = 0x11
Map.ggoaly = 0x06
--Map.hasggoal = true
Map.hasggoal = false -- TMP


-------- state variables --------


-- sound
local lastsong = 0
local cursong = 0
local lastsfx = 0
local cursfx = 0

-- mode
local indialog = 0 -- tmp

-- map
local mapbank = 0
local mapnum = 0
local xpos = 0
local ypos = 0


-- move
local chosemove = true
local nocgoalcount = 0
local curfacing = 0

---- MASTER LOOP ------------------------------------------------------------------------
while true do

	-- facing (unlike Move.lastdir this will work in human mode)
	-- the ram value is 0 when no change from previous frame
	-- wisdom would be merging lastdir into facing but meh
	curfacing = Ram.get(Ram.addr.facing)
	if(curfacing ~= 0) then
		if curfacing == 4 then
			Move.facing = "Up"
		elseif curfacing == 1 then
			Move.facing = "Right"
		elseif curfacing == 8 then
			Move.facing = "Down"
		else
			Move.facing = "Left"
		end
	end
	
	mapbank = Ram.get(Ram.addr.mapbank)
	mapnum = Ram.get(Ram.addr.mapnumber)
	xpos = Ram.get(Ram.addr.xpos)
	ypos = Ram.get(Ram.addr.ypos)

	-- seeing
	if((Map.prevxpos ~= xpos) or (Map.prevypos ~= ypos)) then
	-- bracketed because we were getting weird race conditions
		Map.update()
	end

	if (mapbank ~= Map.prevmapbank) or (mapnum ~= Map.prevmapnum) then
		-- we found a map connection
		-- reset bumblecount
		Move.bumblecount = 0
		
		-- note: when she crosses a connection, she does not infer the
		-- opposite direction connection exists, she'll see it when she
		-- bumbles back over it.
		
		if Map.prevmapbank ~= 0 then -- 0 being nowhere & the bot's initial state
			local foundthis = 0
			for i, v in pairs(Map.maps[Map.prevmapbank][Map.prevmapnum].connections) do
				if v.bank == mapbank
				and v.num == mapnum then
					foundthis = 1
				end
			end
			if foundthis == 0 then
				-- fixups involving not setting the x,y out of bounds
				local cxpos = Map.prevxpos
				local cypos = Map.prevypos
				
				if Move.facing == "Right" then
					if(cxpos > 0) then
						cxpos = cxpos - 1
					else
						cxpos = 0xff
					end
				elseif Move.facing == "Left" then
					if(cxpos < 0xff) then
						cxpos = cxpos + 1
					else
						cxpos = 0
					end
				elseif Move.facing == "Up" then
					if (cypos < 0xff) then
						cypos = cypos + 1
					else
						cypos = 0
					end
				else -- down
					if(cypos > 0) then
						cypos = cypos - 1
					else
						cypos = 0xff
					end
				end
				
				table.insert(Map.maps[Map.prevmapbank][Map.prevmapnum].connections,
				{ x = cxpos, y = cypos, bank = mapbank, num = mapnum })
			
				print("Connection found: " ..
				bizstring.hex(Map.prevmapbank) .. ":" .. bizstring.hex(Map.prevmapnum)
				.. "::" ..
				bizstring.hex(Map.prevxpos) .. ":" .. bizstring.hex(Map.prevypos)
				.. " to " ..
				bizstring.hex(mapbank) .. ":" .. bizstring.hex(mapnum))
			else
				print("Refound existing connection")
			end
		end
	end
	
	
		
	

	-- hearing
	cursong = Sound.currentsong()
	cursfx = Sound.currentsfx()
	if cursong ~= lastsong then
		print("Song changed to " .. Sound.songs[cursong])
		gui.addmessage("Song: " .. Sound.songs[cursong])
		lastsong = cursong
	end
	if cursfx ~= lastsfx and cursfx ~= 0 then
		if Sound.effects[cursfx] ~= nil then -- ugly kludge
			print("Heard sound: " .. Sound.effects[cursfx])
		else
			print("!!! Heard unknown sound: 0x" .. bizstring.hex(cursfx))
		end
		if cursfx == 0x6a and Mode.isdialog() == false then
			-- (tries to detect incoming call) (is joke haha)
			gui.addmessage("This better not be Joey again shmg")
		end
		lastsfx = cursfx
	end
	if cursfx == 0 then
		lastsfx = 0
	end
	
	-------- movement decisions --------
	chosemove = false
	
	if Mode.isbattle() then
		--Move.spama()
		--Move.fidget()
		Move.battle()
		chosemove = true
	end
		
	
	
	-- detect chatty times
	if Mode.isdialog() then
		if chosemove == false then
			Move.fidget()
			chosemove = true
		end
		if indialog == 0 then
			indialog = 1
			print("+Entered dialog")
			-- detecting com-pu-tar
			local pc = Ram.get(Ram.addr.tileup)
			if pc == 0x93 then
				gui.addmessage("BEEP BEEP I DEMAND SACRIFICE")
				print("!!! COMPUTER PERIL !!!")
			end
			
		end
	else
		if indialog == 1 then
			print("-Left dialog")
		end
		indialog = 0
	end
	
	
	-------- picking goals --------
	local r = 0 -- random
	local g = false -- goal routing result
	
	-- clearing cgoals and bgoals on map transition
	if(Map.prevmapbank ~= mapbank or Map.prevmapnum ~= mapnum) then
		Map.update() -- force an initialization of the map
		Map.hascgoal = false
		Move.goalfail = failmax - 1
		Move.choosebgoal()
		Map.hasbgoal = true
		print("-- Map transition resets")
	end
	
	-- checking if we're on a goal
	if (xpos == Map.ggoalx and ypos == Map.ggoaly 
		and Map.ggoalmbank == mapbank and Map.ggoalmnum == mapnum) then
		-- FIXME do something
		chosemove = true
		Map.hasggoal = false
		Move.goalfail = 0
	end
	if(xpos == Map.cgoalx and ypos == Map.cgoaly) then
		Map.hascgoal = false
		Move.bumble()
		chosemove = true
		Move.goalfail = 0
	end
	if(Map.hasbgoal == true and xpos == Map.bgoalx and ypos == Map.bgoaly) then
		Map.hasbgoal = false
		Move.goalfail = 0
		Move.bumblecount = Move.bumblecount + 1
		print("-- cleared a bgoal")
	end
			
	
	-- establishing our current goals
	
	-- finding the next game goal after completion
	if(Map.hasggoal == false) then
		Map.hasggoal = Move.chooseggoal()
	end
	
	-- finding a connect goal - does not run every frame
	-- for CPU limitation reasons
	if nocgoalcount > 0 then
		nocgoalcount = nocgoalcount - 1
	end
	-- additionally, we only do so once we've bumbled around a bit
	if(Map.hascgoal == false and nocgoalcount == 0
	and Move.bumblecount >= 4) then
		Map.hascgoal = Move.choosecgoal()
		if(Map.hascgoal == false) then
			nocgoalcount = 2048 -- reset cooldown, can lower if you want
			-- (2048 is a bit more than 30 seconds)
		end
	end
	
	-- deleting an expired, unfulfilled bgoal
	if(Map.hasbgoal == true and Move.goalfail == 0) then
		Map.hasbgoal = false
		Move.bumblecount = Move.bumblecount + 1
	end
	
	-- acquiring a bgoal
	if(Map.hasbgoal == false and Move.goalfail >= failmax) then
		Move.choosebgoal()
		Map.hasbgoal = true
		Move.goalfail = math.floor(failmax/2) -- keep bumbles short
	end
	
	-- being completely goalless is just no way for a little bumble to be
	if(Map.hasggoal == false and Map.hascgoal == false and
	Map.hasbgoal == false) then
		Move.choosebgoal()
		Map.hasbgoal = true
		Move.goalfail = math.floor(failmax/2)
	end
	
	
	-- okay maybe now we can actually route somewhere?
	
	if(Map.hasggoal == true and Map.hasbgoal == false 
	and chosemove == false) then
		g = Move.togoal(Map.ggoalx, Map.ggoaly)
		if(g == true) then
			Map.hasggoal = false
		end
		chosemove = true
	end
	
	if(Map.hascgoal == true and Map.hasbgoal == false
	and chosemove == false) then
		g = Move.togoal(Map.cgoalx, Map.cgoaly)
		if(g == true) then
			Map.hascgoal = false
		end
		chosemove = true
	end
	
	if(Map.hasbgoal == true and chosemove == false) then
		g = Move.togoal(Map.bgoalx, Map.bgoaly)
		if(g == true) then
			Map.hasbgoal = false
		end
		chosemove = true
	end
	
	
	-- FIXME: still stalls on some menus
	if chosemove == false then
		-- last resort: just mash buttons
		r = math.random(1,100)
		if r <= 50 then
			Move.bumble()
			Move.goalfail = Move.goalfail + 1
		else
			Move.fidget()
			Move.goalfail = Move.goalfail + 1
		end
	end
	
	-------- end movement decisions --------
	
	-- todo: moved downhill, right place?
	Map.prevmapbank = mapbank
	Map.prevmapnum = mapnum
	Map.prevxpos = xpos
	Map.prevypos = ypos
	
	-- hud display
	
	-- overworld
	if Mode.isbattle() == false then
	-- bank:num::x:y [width:height]
		gui.text(1,1,
		"xy " ..
		bizstring.hex(mapbank) ..
		":" .. bizstring.hex(mapnum) ..
		"::" .. bizstring.hex(xpos) .. 
		":" .. bizstring.hex(ypos) ..
		" [" .. bizstring.hex(Ram.get(Ram.addr.mapwidth) * 2) ..
		"x" .. bizstring.hex(Ram.get(Ram.addr.mapheight) * 2) ..
		"]")
		-- gamegoal
		if Map.hasggoal == true then
			gui.text(1,20,
			"gg " ..
			bizstring.hex(Map.ggoalmbank) ..
			":" .. bizstring.hex(Map.ggoalmnum) ..
			"::" .. bizstring.hex(Map.ggoalx) ..
			":" .. bizstring.hex(Map.ggoaly))
		else
			gui.text(1, 20, "gg none")
		end
		-- connect goal
		if Map.hascgoal == true then
			gui.text(1,40,
			"cg " ..
			bizstring.hex(mapbank) ..
			":" .. bizstring.hex(mapnum) ..
			"::" .. bizstring.hex(Map.cgoalx) ..
			":" .. bizstring.hex(Map.cgoaly))
		else
			gui.text(1, 40, "cg none")
		end
		-- bumble goal
		if Map.hasbgoal == true then
			gui.text(1, 60,
			"bg " ..
			bizstring.hex(mapbank) ..
			":" .. bizstring.hex(mapnum) ..
			"::" .. bizstring.hex(Map.bgoalx) ..
			":" .. bizstring.hex(Map.bgoaly) ..
			" " .. Move.bumblecount)
		else
			gui.text(1, 60, "bg none")
		end
			
		-- goalfail
		gui.text(1,80, "goalfail " .. Move.goalfail)
	end
	
	
	-- resume breathing
	emu.frameadvance()
end

