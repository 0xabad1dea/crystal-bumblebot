--[[--
Crystal Bumble Bot by 0xabad1dea
May 21 2015

An artificial friend who plays Pokemon Crystal

inspired by, but not a fork of, thepokebot
--]]--

local Ram = require "Ram"
local Sound = require "Sound"
local Mode = require "Mode"
local Map = require "Map"
local Move = require "Move"
local Goal = require "Goal"

---- debug functions ----
function showexits()
	print("-----Known exits:-----")
	exits = Map.getexits()
	
	if table.getn(exits) == 0 then
		print("None! D:")
		--return
	end
	for i, v in pairs(exits) do
			print(bizstring.hex(v[1]) .. "," ..
			bizstring.hex(v[2]))
	end
end

function dumpmap()
	return Map.textdump()
end

function dumpsprites()
	return Map.spritedump()
end

print("--------Bot booting--------");
math.randomseed(os.time())
memory.usememorydomain("WRAM")
-- BIZHAWK CHANGED WHICH MEMORY DOMAIN WAS DEFAULT AND RUINED.
-- E. V. E. R. Y. T. H. I. N. G.
-- I WASTED HOURS OF MY LIFE IN A STEAMING HOT ROOM DIAGNOSING THIS.
-- I'M SO MAD YOU HAVE NO IDEA
-- yes it's technically my fault ssh

-- config
-- type "human = true" into the console at any time
-- for ASSUMING DIRECT CONTROL
human = false
-- goalfail countdown size. will use this for indoors and 2x for outdoors
failmax = 64
-- maximum radius of bumbleroute goal (rec: 20 to 32)
-- FIXME this should no longer be used
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
local prevxpos = 0
local prevypos = 0


-- move
local chosemove = true
local nocgoalcount = 0
local curfacing = 0
local movement = 0



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
	prevxpos = Map.prevxpos
	prexypos = Map.prevypos -- why do I have to do this?!
	-- why can't I use Map.whatever in if... comparisons?! I don't understand

	-- seeing
	--if((prevxpos ~= xpos) or (prevypos ~= ypos)) then
	-- bracketed because we were getting weird race conditions
	--	Map.update()
	--end

	-- okay let's try a new way: only update the map when we're standing still
	movement = Ram.get(Ram.addr.movement)
	if (movement == 1) or (movement == 3) then -- still or bump
		Map.update()
	end
	
	if (mapbank ~= Map.prevmapbank) or (mapnum ~= Map.prevmapnum) then
		-- we found a map connection
		-- reset bumblecount
		--Move.bumblecount = 0
		--Move.doorcooldown = 0 -- moved downhill
		
		-- note: when she crosses a connection, she does not infer the
		-- opposite direction connection exists, she'll see it when she
		-- bumbles back over it.
		
		-- scrap.lua codeword APPLE
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
		if Sound.songs[cursong] == nil then -- ugly kludge
			--print("Invalid song: 0x" .. bizstring.hex(cursfx))
			-- this was going off every frame at "..." in Oak's opening
			-- (also why I had to if/else this at all - I must not understand
			-- lua's short circuiting right or something b/c putting it in the
			-- above if... with an and... wasn't working
		else
			print("Song changed to " .. Sound.songs[cursong])
			gui.addmessage("Song: " .. Sound.songs[cursong])
			lastsong = cursong
		end
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
	
	-- actually moving-moving
	if(movement == 3) and (chosemove == false) then -- bumping
		Move.bumble()
		chosemove = true
	end
	
	if (movement == 1) and (chosemove == false) then -- standing still
		
		if(Map.hasbgoal == true) then
			-- detecting that our goal has been seen to be solid
			if(Map.isthing(Map.maps[mapbank][mapnum][Map.bgoalx][Map.bgoaly])) then
				gui.addmessage("bgoal is solid")
				print("+++ bgoal is solid")
				Map.hasbgoal = false
				Map.bgoalx = 0
				Map.bgoaly = 0
				Move.goalfail = 0
			else -- actually route, occasionally bumble to maybe escape local traps
				if(math.random(1,100) < 10) then
					Move.bumble()
				else
					Move.routetogoal(Map.bgoalx, Map.bgoaly)
				end
				-- occasionally interact
				if(math.random(1,100) < 25) then
					Move.fidget()
				end
			end
		else
			Move.bumble()
		end
		
		
		
		chosemove = true
	end
	
	
	-------- picking goals --------
	--local r = 0 -- random
	--local g = false -- goal routing result
	
	-- scrap.lua codeword BANANA
	
	-- movement == 1 is to avoid a race condition with map creation
	if((movement == 1) and (Map.hasbgoal == false)) then
		Move.choosebgoal()
	end

			
	
	
	-------- end movement decisions --------
	
	-- todo: moved downhill, right place?
	-- on tile transition or bump 
	if((xpos ~= Map.prevxpos) or (ypos ~= Map.prevypos) or (movement == 3) ) then
		Move.doorcooldown = Move.doorcooldown + 1
		if((xpos == Map.bgoalx) and (ypos == Map.bgoaly)) then
			-- standing on bgoal
			gui.addmessage("bumble goal reached!")
			print("++ bumble goal reached")
			Map.hasbgoal = false
			Map.bgoalx = 0
			Map.bgoaly = 0
			Move.goalfail = 0
		else
			Move.goalfail = Move.goalfail + 1
			-- check for exceeding goalfail
			if(((Move.goalfail >= failmax) and (Map.isindoors() == true)) or
				((Move.goalfail >= (failmax*2))) ) then
				gui.addmessage("failed bumble goal")
				print("+++ failed bumble goal")
				Map.hasbgoal = false
				Map.bgoalx = 0
				Map.bgoaly = 0
				Move.goalfail = 0
			end
		end

	end
	
	-- on map transition
	if((mapbank ~= Map.prevmapbank) or (mapnum ~= Map.prevmapnum)) then
		Map.hasbgoal = false
		Map.bgoalx = 0
		Map.bgoaly = 0
		Move.goalfail = 0
		Move.doorcooldown = 0
	end
	
	Map.prevmapbank = mapbank
	Map.prevmapnum = mapnum
	Map.prevxpos = xpos
	Map.prevypos = ypos
	
	
	-- hud display
	
	gui.cleartext()
	
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
		-- scrap.lua keyword CAT
		
		-- bumble goal
		if Map.hasbgoal == true then
			gui.text(1, 20,
			"bg " ..
			bizstring.hex(mapbank) ..
			":" .. bizstring.hex(mapnum) ..
			"::" .. bizstring.hex(Map.bgoalx) ..
			":" .. bizstring.hex(Map.bgoaly) ..
			" " .. Move.bumblecount)
		else
			gui.text(1, 20, "bg none")
		end
			
		-- goalfail
		gui.text(1,40, "goalfail " .. Move.goalfail)
		-- doorcooldown
		gui.text(1,60, "doorcd " .. Move.doorcooldown)
	end
	
	gui.DrawFinish()
	-- resume breathing
	emu.frameadvance()
end

