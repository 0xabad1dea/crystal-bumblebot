--[[--
Crystal Bumble Bot by 0xabad1dea
May 21 2015

An artificial friend who plays Pokemon Crystal

inspired by, but not a fork of, thepokebot
--]]--

local Ram = require "ram"
local Sound = require "sound"

print("--------Bot booting--------");


local lastsong = 0
local cursong = 0
local lastsfx = 0
local cursfx = 0
while true do

	-- hearing
	cursong = Sound.currentsong()
	cursfx = Sound.currentsfx()
	if cursong ~= lastsong then
		print("Song changed to " .. Sound.songs[cursong])
		lastsong = cursong
	end
	if cursfx ~= lastsfx and cursfx ~= 0 then
		print("Heard sound: " .. Sound.effects[cursfx])
		lastsfx = cursfx
	end
	if cursfx == 0 then
		lastsfx = 0
	end
	emu.frameadvance()
end