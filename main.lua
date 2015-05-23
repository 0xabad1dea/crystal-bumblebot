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

print("--------Bot booting--------");



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
local prevmapbank = 0
local prevmapnum = 0
local prevxpos = 0
local prevyos = 0

---- MASTER LOOP --------------------------------------------
while true do

	-- seeing
	Map.update()
	mapbank = Ram.get(Ram.addr.mapbank)
	mapnum = Ram.get(Ram.addr.mapnumber)
	xpos = Ram.get(Ram.addr.xpos)
	ypos = Ram.get(Ram.addr.ypos)
	if (mapbank ~= prevmapbank) or (mapnum ~= prevmapnum) then
		-- we found a map connection
		if prevmapbank ~= 0 then -- 0 being nowhere & the bot's initial state
			local foundthis = 0
			for i, v in pairs(Map.maps[prevmapbank][prevmapnum].connections) do
				if v.bank == mapbank
				and v.num == mapnum then
					foundthis = 1
				end
			end
			if foundthis == 0 then
				table.insert(Map.maps[prevmapbank][prevmapnum].connections,
				{ x = prevxpos, y = prevypos, bank = mapbank, num = mapnum })
			
				print("Connection found: " ..
				bizstring.hex(prevmapbank) .. ":" .. bizstring.hex(prevmapnum)
				.. "::" ..
				bizstring.hex(prevxpos) .. ":" .. bizstring.hex(prevypos)
				.. " to " ..
				bizstring.hex(mapbank) .. ":" .. bizstring.hex(mapnum))
			else
				print("Refound existing connection")
			end
		end
	end
	
	-- todo: might need to move downhill
	prevmapbank = mapbank
	prevmapnum = mapnum
	prevxpos = xpos
	prevypos = ypos
		
	

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
	
	-- movement decisions
	
	-- detect chatty times
	if Mode.isdialog() then
		Move.fidget()
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
	
	-- hud display
	gui.text(1,1, 
	bizstring.hex(mapbank) ..
	":" .. bizstring.hex(mapnum) ..
	"::" .. bizstring.hex(xpos) .. 
	":" .. bizstring.hex(ypos))
	
	
	-- resume breathing
	emu.frameadvance()
end