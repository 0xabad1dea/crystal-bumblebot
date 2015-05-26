-- detects game modes

local Mode = {}
local Ram = require "ram"
local Sound = require "sound"

-- returns true if dialog box on screen
function Mode.isdialog()
	local corner = Ram.get(Ram.addr.corner)
	if corner == 0x7d then -- lower left window decoration
		return true
	end
	if corner == 0x7f then -- status screens
		return true
	end
	-- these were triggering false positives
	--if corner == 0x3b then -- pokedex entry
	--	return true
	--end
	--if corner == 0x60 then -- naming screen
	--	return true
	--end
	return false
end

-- returns true if music suggests a battle
function Mode.isbattle()
	local song = Sound.currentsong()
	
	if song == 0x06 then -- kanto gym leader
		return true
	elseif song == 0x07 then -- kanto trainer
		return true
	elseif song == 0x08 then -- kanto wild
		return true
	elseif song == 0x17 then -- trainer victory
		return true
	elseif song == 0x18 then -- wild victory
		return true
	elseif song == 0x19 then -- gym victory
		return true
	elseif song == 0x29 then -- johto wild
		return true
	elseif song == 0x2a then -- johto trainer
		return true
	elseif song == 0x2e then -- johto gym
		return true
	elseif song == 0x2f then -- champion
		return true
	elseif song == 0x30 then -- rival
		return true
	elseif song == 0x31 then -- rocket
		return true
	elseif song == 0x4a then -- johto wild night
		return true
	elseif song == 0x64 then -- legendary dog
		return true
	end
	-- excludes pokemon caught
	return false
end


return Mode