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

print("--------Bot booting--------");
math.randomseed(os.time())

-- config
-- type "human = true" into the console at any time
-- for ASSUMING DIRECT CONTROL
human = false
-- how long to route before engaging bumblerouting (rec: 128 to 256)
failmax = 128
-- maximum radius of bumbleroute goal (rec: 20 to 32)
brad = 32

-- TMP DEBUG: fixed goal routing
-- mr. pokemon's house
Map.ggoalmbank = 0x1A
Map.ggoalmnum = 0x01
Map.ggoalx = 0x11
Map.ggoaly = 0x06
Map.hasggoal = true


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

---- MASTER LOOP ------------------------------------------------------------------------
while true do

	-- seeing
	Map.update()
	mapbank = Ram.get(Ram.addr.mapbank)
	mapnum = Ram.get(Ram.addr.mapnumber)
	xpos = Ram.get(Ram.addr.xpos)
	ypos = Ram.get(Ram.addr.ypos)
	if (mapbank ~= Map.prevmapbank) or (mapnum ~= Map.prevmapnum) then
		-- we found a map connection
		if Map.prevmapbank ~= 0 then -- 0 being nowhere & the bot's initial state
			local foundthis = 0
			for i, v in pairs(Map.maps[Map.prevmapbank][Map.prevmapnum].connections) do
				if v.bank == mapbank
				and v.num == mapnum then
					foundthis = 1
				end
			end
			if foundthis == 0 then
				table.insert(Map.maps[Map.prevmapbank][Map.prevmapnum].connections,
				{ x = Map.prevxpos, y = Map.prevypos, bank = mapbank, num = mapnum })
			
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
		print("Heard sound: " .. Sound.effects[cursfx])
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
	
	-- tmp debug: spam only a in battle
	if Mode.isbattle() then
		Move.spama()
		--Move.fidget()
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
		end
	else
		if indialog == 1 then
			print("-Left dialog")
		end
		indialog = 0
	end
	
	
	---- picking goals ----
	local r = 0 -- random
	
	-- resetting bumble goals on map transition
	if (Map.hasbgoal == true) and
	(Map.prevmapbank ~= mapbank or Map.prevmapnum ~= mapnum) 
	and chosemove == false then
		gui.addmessage("Resetting bumblegoal on mapchange")
		print("Resetting bumblegoal on mapchange")
		Move.choosebgoal()
		Move.goalfail = failmax - 1
		Move.togoal(Map.bgoalx, Map.bgoaly)
		chosemove = true
	end
	
	-- no goal: blind bumbling
	-- game goal: wrong map
	-- connect goal: wrong map (needs improvement)
	-- this is the biggest conditional chain I've ever written D:
	if (Map.hasggoal == false and Map.hascgoal == false
	and chosemove == false) or
	(Map.hasggoal == true and (mapbank ~= Map.ggoalmbank or
	mapnum ~= Map.ggoalmnum) and chosemove == false) or
	(Map.hascgoal == true and (mapbank ~= Map.cgoalbank or
	mapnum ~= Map.cgoalnum) and chosemove == false)
	then
		-- tmp: finding new real goals goes here
		-- until then stop when we're at our fixed dest
		if xpos == Map.ggoalx and ypos == Map.ggoaly 
		and Map.ggoalmbank == mapbank and Map.ggoalmnum == mapnum then
			-- do nothing
			chosemove = true
		elseif Map.hasbgoal == true and Move.goalfail > 0 then
			Move.togoal(Map.bgoalx, Map.bgoaly)
			chosemove = true
		elseif Map.hasbgoal == false and Move.goalfail == 0 then
		-- need a new bumblegoal
			gui.addmessage("New blind bumble goal")
			print("New blind bumble goal")
			Move.choosebgoal()
			Move.goalfail = math.floor(failmax/2)
			Map.hasbgoal = true
			Move.togoal(Map.bgoalx, Map.bgoaly)
			chosemove = true
		end
		
	end
	
	-- bumble goaling
	if Map.hasbgoal == true and chosemove == false then
		-- clearing bgoal if it's over
		if Move.goalfail == 0 then
			gui.addmessage("Resuming normal goaling")
			Map.hasbgoal = false
			if Move.hasggoal == true then
				Move.togoal(Map.ggoalx, Map.ggoaly)
				chosemove = true
			elseif Move.hascgoal == true then
				Move.togoal(Map.cgoalx, Map.cgoaly)
				chosemove = true
			end
		else
			Move.togoal(Map.bgoalx, Map.bgoaly)
			chosemove = true
		end
	-- game goaling
	elseif Map.hasggoal == true 
	--and Map.ggoalmbank == mapbank and Map.ggoalmnum == mapnum
	and chosemove == false then
		if Move.goalfail >= failmax then
		-- we done mucked up and got stuck
			gui.addmessage("Trying a bumble goal")
			Move.choosebgoal()
			Map.hasbgoal = true
			Move.togoal(Map.bgoalx, Map.bgoaly)
			chosemove = true
		else
			if mapbank == Map.ggoalmbank and mapnum == Map.ggoalmnum then
				Move.togoal(Map.ggoalx, Map.ggoaly)
				chosemove = true
			end
		end
	-- connection goaling
	elseif Map.hascgoal == true and chosemove == false then
		if Move.goalfail >= failmax then
		-- we done mucked up and got stuck
			gui.addmessage("Trying a bumble goal")
			Map.choosebgoal()
			Map.hasbgoal = true
			Move.togoal(Map.bgoalx, Map.bgoaly)
			chosemove = true
		else
			Move.togoal(Map.cgoalx, Map.cgoaly)
			chosemove = true
		end
	end
	
	-- FIXME: still stalls on some menus
	
	if chosemove == false then
		-- last resort: just mash buttons
		r = math.random(1,100)
		if r <= 50 then
			Move.bumble()
		else
			Move.fidget()
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
	-- bank:num::x:y
		gui.text(1,1,
		"xy " ..
		bizstring.hex(mapbank) ..
		":" .. bizstring.hex(mapnum) ..
		"::" .. bizstring.hex(xpos) .. 
		":" .. bizstring.hex(ypos))
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
			":" .. bizstring.hex(Map.bgoaly))
		else
			gui.text(1, 60, "bg none")
		end
			
		-- goalfail
		gui.text(1,80, "goalfail " .. Move.goalfail)
	end
	
	
	-- resume breathing
	emu.frameadvance()
end