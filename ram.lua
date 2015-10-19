-- accessing the ram of pokemon crystal
-- huge thanks to iimarkus and pokecrystal disasm :)
-- wram addresses given with a leading C or D are changed to
-- 0 and 1 respectively here

local Ram = {}

print("inside ram.lua")

Ram.addr = {
	-- currently playing music (per channel)
	song		= 0x0101,
	song2		= 0x0133,
	song3		= 0x0165,
	song4		= 0x0197,
	-- current sound effect (per channel)
	sfx			= 0x01c9,
	sfx2		= 0x01fb,
	sfx3		= 0x022d,
	sfx4		= 0x025f,
	-- last sfx played (doesn't go to 0)
	lastsfx		= 0x02bf,
	
	-- game time (not wall clock time)
	-- fixme: hours, seconds?
	gameminute	= 0x14c6,
	
	-- type of adjacent tiles
	tiledown	= 0x02fa,
	tileup		= 0x02fb,
	tileleft	= 0x02fc,
	tileright	= 0x02fd,
	
	-- current map
	mapbank		= 0x1cb5,
	mapnumber	= 0x1cb6,
	ypos		= 0x1cb7,
	xpos		= 0x1cb8,
	mapwidth	= 0x119f, -- multiply by 2
	mapheight	= 0x119e, -- multiply by 2
	mapconns	= 0x11a8, -- 8 north 4 south 2 west 1 east
	-- (note this is for outdoors-to-outdoors only)
	
	-- player movement type
	movement	= 0x14e1, -- 1 still 2 walking 3 bumping
	facing		= 0x1044, -- NESW 4, 1, 8, 2
	-- (this is only on while walking)
	
	-- lower left corner of screen
	corner		= 0x05f4
	
}

function Ram.get(address)
	return memory.readbyte(address)
end


return Ram