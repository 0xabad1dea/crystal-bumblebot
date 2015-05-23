-- detects game modes

local Mode = {}
local Ram = require "ram"

-- returns true if dialog box on screen
function Mode.isdialog()
	local corner = Ram.get(Ram.addr.corner)
	if corner == 0x7d then -- lower left window decoration
		return true
	end
	return false
end


return Mode