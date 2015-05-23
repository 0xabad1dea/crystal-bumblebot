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

print("--------Bot booting--------");

-- debug tmp
print(Map.maps[0][0][0][0])


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

-- MASTER LOOP
while true do

	-- seeing
	Map.update()

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
	
	-- detect chatty times
	if Mode.isdialog() then
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
	-- fixme: use the cached xpos,ypos once they exist
	gui.text(1,1, 
	bizstring.hex(Ram.get(Ram.addr.mapbank)) ..
	":" .. bizstring.hex(Ram.get(Ram.addr.mapnumber)) ..
	"::" .. bizstring.hex(Ram.get(Ram.addr.xpos)) .. 
	":" .. bizstring.hex(Ram.get(Ram.addr.ypos)))
	
	
	-- resume breathing
	emu.frameadvance()
end