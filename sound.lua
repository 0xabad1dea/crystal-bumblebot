-- the names of the songs
-- bless iimarkus for these tables

local Ram = require "ram"

local Sound = {}

Sound.songs = {}
	Sound.songs[0x00] = "silence"
	Sound.songs[0x01] = "title screen (old?)"
	Sound.songs[0x02] = "route 1"
	Sound.songs[0x03] = "route 3"
	Sound.songs[0x04] = "route 12"
	Sound.songs[0x05] = "train ride"
	Sound.songs[0x06] = "kanto gym leader fight"
	Sound.songs[0x07] = "kanto trainer fight"
	Sound.songs[0x08] = "kanto wild fight"
	Sound.songs[0x09]= "pokemon center"
	Sound.songs[0x0a]= "hiker"
	Sound.songs[0x0b]= "lass"
	Sound.songs[0x0c]= "officer"
	Sound.songs[0x0d]= "heal"
	Sound.songs[0x0e]= "lavender"
	Sound.songs[0x0f]= "route 2"
	Sound.songs[0x10]= "mount moon"
	Sound.songs[0x11]= "showing around"
	Sound.songs[0x12]= "game corner"
	Sound.songs[0x13]= "bicycle"
	Sound.songs[0x14]= "hall of fame"
	Sound.songs[0x15]= "viridian"
	Sound.songs[0x16]= "celadon"
	Sound.songs[0x17]= "trainer victory"
	Sound.songs[0x18]= "wild victory"
	Sound.songs[0x19]= "gym leader victory"
	Sound.songs[0x1a]= "mount moon square"
	Sound.songs[0x1b]= "gym"
	Sound.songs[0x1c]= "pallet town"
	Sound.songs[0x1d]= "professor oak talk"
	Sound.songs[0x1e]= "professor oak"
	Sound.songs[0x1f]= "rival greet"
	Sound.songs[0x20]= "rival leave"
	Sound.songs[0x21]= "bicycle 2"
	Sound.songs[0x22]= "evolution"
	Sound.songs[0x23]= "national park"
	Sound.songs[0x24]= "credits"
	Sound.songs[0x25]= "azalea"
	Sound.songs[0x26]= "cherrygrove"
	Sound.songs[0x27]= "kimono girl"
	Sound.songs[0x28]= "union cave"
	Sound.songs[0x29]= "johto wild fight"
	Sound.songs[0x2a]= "johto trainer fight"
	Sound.songs[0x2b]= "route 30"
	Sound.songs[0x2c]= "ecruteak"
	Sound.songs[0x2d]= "violet"
	Sound.songs[0x2e]= "johto gym fight"
	Sound.songs[0x2f]= "champion fight"
	Sound.songs[0x30]= "rival fight"
	Sound.songs[0x31]= "rocket fight"
	Sound.songs[0x32]= "elm's lab"
	Sound.songs[0x33]= "slowpoke well"
	Sound.songs[0x34]= "route 29"
	Sound.songs[0x35]= "route 36"
	Sound.songs[0x36]= "s.s. aqua"
	Sound.songs[0x37]= "youngster"
	Sound.songs[0x38]= "beauty"
	Sound.songs[0x39]= "rocket"
	Sound.songs[0x3a]= "pokemaniac"
	Sound.songs[0x3b]= "sage"
	Sound.songs[0x3c]= "new bark"
	Sound.songs[0x3d]= "goldenrod"
	Sound.songs[0x3e]= "vermilion"
	Sound.songs[0x3f]= "pokemon channel"
	Sound.songs[0x40]= "pokeflute channel"
	Sound.songs[0x41]= "tin tower"
	Sound.songs[0x42]= "sprout tower"
	Sound.songs[0x43]= "burned tower"
	Sound.songs[0x44]= "lighthouse"
	Sound.songs[0x45]= "lake of rage"
	Sound.songs[0x46]= "indigo plateau"
	Sound.songs[0x47]= "route 37"
	Sound.songs[0x48]= "rocket hideout"
	Sound.songs[0x49]= "dragon's den"
	Sound.songs[0x4a]= "johto wild fight night"
	Sound.songs[0x4b]= "ruins of alph radio"
	Sound.songs[0x4c]= "pokemon caught"
	Sound.songs[0x4d]= "route 26"
	Sound.songs[0x4e]= "mom"
	Sound.songs[0x4f]= "victory road"
	Sound.songs[0x50]= "lullaby"
	Sound.songs[0x51]= "pokemon march"
	Sound.songs[0x52]= "gold/silver opening 1"
	Sound.songs[0x53]= "gold/silver opening 2"
	Sound.songs[0x54]= "new game continue"
	Sound.songs[0x55]= "ruins of alph"
	Sound.songs[0x56]= "rocket map"
	Sound.songs[0x57]= "dance hall"
	Sound.songs[0x58]= "contest results"
	Sound.songs[0x59]= "bug-catching contest"
	Sound.songs[0x5a]= "lake of rage"
	Sound.songs[0x5b]= "printer"
	Sound.songs[0x5c]= "post-credits"
	Sound.songs[0x5d]= "clair"
	Sound.songs[0x5e]= "unknown beta"
	Sound.songs[0x5f]= "mobile adapter"
	Sound.songs[0x60]= "buena"
	Sound.songs[0x61]= "mysticalman"
	Sound.songs[0x62]= "crystal opening 2"
	Sound.songs[0x63]= "battle tower"
	Sound.songs[0x64]= "legendary dog fight"
	Sound.songs[0x65]= "battle tower lobby"
	Sound.songs[0x66]= "pokemon center beta"

Sound.effects = {}
	Sound.effects[0x00]= "pokedex fanfare 50-79" -- nidoran m maybe??
	Sound.effects[0x01]= "item get" -- nidoran f
	Sound.effects[0x02]= "pokemon caught (sfx)"
	Sound.effects[0x03]= "pokeball placed"
	Sound.effects[0x04]= "potion"
	Sound.effects[0x05]= "full heal"
	Sound.effects[0x06]= "menu"
	Sound.effects[0x07]= "read beep (7)"
	Sound.effects[0x08]= "read beep"
	Sound.effects[0x09]= "pokedex fanfare 20-49"
	Sound.effects[0x0a]= "pokedex fanfare 80-109"
	Sound.effects[0x0b]= "poison"
	Sound.effects[0x0c]= "safari ball get"
	Sound.effects[0x0d]= "pc boot"
	Sound.effects[0x0e]= "pc shutdown" -- pidgey, poliwag
	Sound.effects[0x0f]= "pc select"
	Sound.effects[0x10]= "bide" -- spearow
	Sound.effects[0x11]= "button push"
	Sound.effects[0x12]= "nurse joy ball/itemfinder"
	Sound.effects[0x13]= "warp to"
	Sound.effects[0x14]= "warp" -- pidgeotto
	Sound.effects[0x15]= "ball close/pokedex mode" -- weedle
	Sound.effects[0x16]= "ledge jump" -- caterpie, goldeen
	Sound.effects[0x17]= "rustle grass" -- ekans, magikarp, onix
	Sound.effects[0x18]= "flee or fly"
	Sound.effects[0x19]= "wrong"
	Sound.effects[0x1a]= "squeak"
	Sound.effects[0x1b]= "strength"
	Sound.effects[0x1c]= "boat" -- gastly
	Sound.effects[0x1d]= "wall open" -- zubat
	Sound.effects[0x1e]= "place puzzle piece"
	Sound.effects[0x1f]= "enter door"
	Sound.effects[0x20]= "switch pokemon"
	Sound.effects[0x21]= "unnamed sound 0x21" -- bellsprout
	Sound.effects[0x22]= "buy/sell" -- rattata
	Sound.effects[0x23]= "exit building"
	Sound.effects[0x24]= "bump" -- geodude
	Sound.effects[0x25]= "saved game"
	Sound.effects[0x26]= "pokeflute"
	Sound.effects[0x27]= "elevator end"
	Sound.effects[0x28]= "throw pokeball"
	Sound.effects[0x29]= "smokescreen/ball open"
	Sound.effects[0x2a]= "faint"
	Sound.effects[0x2b]= "run away"
	Sound.effects[0x2c]= "slot machine start"
	Sound.effects[0x2d]= "fanfare" -- hoothoot
	Sound.effects[0x2e]= "peck" -- sentret
	Sound.effects[0x2f]= "kinesis"
	Sound.effects[0x30]= "lick"  -- cynaquil, quilava
	Sound.effects[0x31]= "pound"
	Sound.effects[0x32]= "move puzzle piece" -- totodile
	Sound.effects[0x33]= "comet punch"
	Sound.effects[0x34]= "mega punch" -- hoppip
	Sound.effects[0x33]= "scratch"
	Sound.effects[0x36]= "vicegrip"
	Sound.effects[0x37]= "razor wind"
	Sound.effects[0x38]= "cut" -- wooper
	Sound.effects[0x39]= "wing attack"
	Sound.effects[0x3a]= "whirlwind"
	Sound.effects[0x3b]= "bind"
	Sound.effects[0x3c]= "vine whip"
	Sound.effects[0x3d]= "double kick"
	Sound.effects[0x3e]= "mega kick"
	Sound.effects[0x3f]= "headbutt"
	Sound.effects[0x40]= "horn attack"
	Sound.effects[0x41]= "tackle"
	Sound.effects[0x42]= "poison sting"
	Sound.effects[0x43]= "poisonpowder"
	Sound.effects[0x44]= "doubleslap"
	Sound.effects[0x45]= "bite"
	Sound.effects[0x46]= "jump kick"
	Sound.effects[0x47]= "stomp"
	Sound.effects[0x48]= "tail whip"
	Sound.effects[0x49]= "karate chop"
	Sound.effects[0x4a]= "submission"
	Sound.effects[0x4b]= "water gun"
	Sound.effects[0x4c]= "swords dance"
	Sound.effects[0x4d]= "thunder"
	Sound.effects[0x4e]= "supersonic"
	Sound.effects[0x4f]= "leer"
	Sound.effects[0x50]= "ember"
	Sound.effects[0x51]= "bubblebeam"
	Sound.effects[0x52]= "hydro pump"
	Sound.effects[0x53]= "surf"
	Sound.effects[0x54]= "psybeam"
	Sound.effects[0x55]= "leech seed"
	Sound.effects[0x56]= "thundershock"
	Sound.effects[0x57]= "psychic"
	Sound.effects[0x58]= "screech"
	Sound.effects[0x59]= "bone club"
	Sound.effects[0x5a]= "sharpen"
	Sound.effects[0x5b]= "egg bomb"
	Sound.effects[0x5c]= "sing"
	Sound.effects[0x5d]= "sky attack"
	Sound.effects[0x5e]= "ice beam/trainer glint"
	Sound.effects[0x62]= "tap"
	Sound.effects[0x63]= "tap 2"
	Sound.effects[0x64]= "burn"
	Sound.effects[0x67]= "win coins"
	Sound.effects[0x68]= "pay day"
	Sound.effects[0x69]= "metronome"
	Sound.effects[0x6a]= "phone ring"
	Sound.effects[0x6b]= "end call"
	Sound.effects[0x6c]= "no signal"
	Sound.effects[0x6d]= "sandstorm"
	Sound.effects[0x6e]= "elevator"
	Sound.effects[0x6f]= "protect"
	Sound.effects[0x70]= "sketch"
	Sound.effects[0x71]= "rain dance"
	Sound.effects[0x72]= "aeroblast"
	Sound.effects[0x73]= "spark"
	Sound.effects[0x74]= "curse"
	Sound.effects[0x75]= "rage"
	Sound.effects[0x76]= "thief"
	Sound.effects[0x77]= "thief 2"
	Sound.effects[0x78]= "spider web"
	Sound.effects[0x79]= "mind reader"
	Sound.effects[0x7a]= "nightmare"
	Sound.effects[0x7b]= "snore"
	Sound.effects[0x7c]= "sweet kiss"
	Sound.effects[0x7d]= "sweet kiss 2"
	Sound.effects[0x7e]= "belly drum"
	Sound.effects[0x7f]= "unnamed sound 0x7f"
	Sound.effects[0x80]= "sludge bomb"
	Sound.effects[0x81]= "foresight"
	Sound.effects[0x82]= "spite"
	Sound.effects[0x83]= "outrage"
	Sound.effects[0x84]= "perish song"
	Sound.effects[0x85]= "giga drain"
	Sound.effects[0x86]= "attract"
	Sound.effects[0x87]= "kinesis"
	Sound.effects[0x88]= "zap cannon"
	Sound.effects[0x89]= "mean look"
	Sound.effects[0x8a]= "heal bell"
	Sound.effects[0x8b]= "return"
	Sound.effects[0x8c]= "exp bar fill"
	Sound.effects[0x8d]= "milk drink"
	Sound.effects[0x8e]= "present"
	Sound.effects[0x8f]= "morning sun"
	Sound.effects[0x90]= "level up"
	Sound.effects[0x91]= "key item get"
	Sound.effects[0x92]= "fanfare"
	Sound.effects[0x93]= "register number"
	Sound.effects[0x94]= "bug catch third place"
	Sound.effects[0x95]= "day care egg get"
	Sound.effects[0x96]= "day care egg get 2"
	Sound.effects[0x97]= "move deleted by deleter"
	Sound.effects[0x98]= "bug catch second place"
	Sound.effects[0x99]= "bug catch first place"
	Sound.effects[0x9a]= "card game guess"
	Sound.effects[0x9b]= "tm get"
	Sound.effects[0x9c]= "badge get"
	Sound.effects[0x9d]= "quit slots"
	Sound.effects[0x9e]= "egg wobble"
	Sound.effects[0x9f]= "pokedex fanfare < 20"
	Sound.effects[0xa0]= "pokedex fanfare 140–169"
	Sound.effects[0xa1]= "pokedex fanfare 170–199"
	Sound.effects[0xa2]= "pokedex fanfare 200–229"
	Sound.effects[0xa3]= "pokedex fanfare >= 230"
	Sound.effects[0xa4]= "evolved"
	Sound.effects[0xa5]= "master ball"
	Sound.effects[0xa6]= "egg cracks"
	Sound.effects[0xa7]= "charizard (g/s intro)"
	Sound.effects[0xa8]= "pokemon appears (g/s intro)"
	Sound.effects[0xa9]= "flash"
	Sound.effects[0xaa]= "gamefreak logo"
	Sound.effects[0xab]= "not very effective damage"
	Sound.effects[0xac]= "normal damage"
	Sound.effects[0xad]= "super effective damage"
	Sound.effects[0xae]= "pokeball bounce"
	Sound.effects[0xaf]= "moonlight"
	Sound.effects[0xb0]= "encore"
	Sound.effects[0xb1]= "beat up"
	Sound.effects[0xb2]= "baton pass"
	Sound.effects[0xb3]= "pokemon struggles in ball"
	Sound.effects[0xb4]= "sweet scent"
	Sound.effects[0xb5]= "sweet scent 2"
	Sound.effects[0xb6]= "exp bar fills"
	Sound.effects[0xb7]= "trade away pokemon"
	Sound.effects[0xb8]= "trade get pokemon"
	Sound.effects[0xb9]= "train arrives"
	Sound.effects[0xba]= "slot machine halt"
	Sound.effects[0xbb]= "two boops"
	Sound.effects[0xbc]= "glass ting"
	Sound.effects[0xbd]= "two glass tings"
	Sound.effects[0xbe]= "intro unown 1"
	Sound.effects[0xbf]= "intro unown 2"
	Sound.effects[0xc0]= "intro unown 3"
	Sound.effects[0xc1]= "boop"
	Sound.effects[0xc2]= "game freak ditto transform"
	Sound.effects[0xc3]= "intro suicune 1"
	Sound.effects[0xc4]= "intro pichu"
	Sound.effects[0xc5]= "intro suicune 2"
	Sound.effects[0xc6]= "intro suicune 3"
	Sound.effects[0xc7]= "game freak ditto bounce"
	Sound.effects[0xc8]= "intro suicune 4"
	Sound.effects[0xc9]= "game freak presents"
	Sound.effects[0xca]= "tingle"
	Sound.effects[0xcb]= "sand?"
	Sound.effects[0xcc]= "two computer beeps"
	Sound.effects[0xcd]= "short ditty"
	Sound.effects[0xce]= "twinkle"
	Sound.effects[0xff]= "not a sfx (prolly a cry)"
	


function Sound.currentsong()
	-- some songs do not use all channels hence this weirdness
	-- fixme does not handle invalid songs :')
	local song = Ram.get(Ram.addr.song)
	if song ~= 0 then
		return song
	end
	song = Ram.get(Ram.addr.song2)
	if song ~= 0 then
		return song
	end
	song = Ram.get(Ram.addr.song3)
	if song ~= 0 then
		return song
	end
	song = Ram.get(Ram.addr.song4)
	if song ~= 0 then
		return song
	end
	
	return 0
end

function Sound.currentsfx()
	-- most sfx do not use all the channels
	-- dunno if there's a multiplex situation?, if so it will
	-- get whichever one comes first channely.
	local effect = Ram.get(Ram.addr.sfx)
	if effect > 0xce then
		return 0xff
	end
	if effect ~= 0 then
		return effect
	end
	effect = Ram.get(Ram.addr.sfx2)
	if effect > 0xce then
		return 0xff
	end
	if effect ~= 0 then
		return effect
	end
	effect = Ram.get(Ram.addr.sfx3)
	if effect > 0xce then
		return 0xff
	end
	if effect ~= 0 then
		return effect
	end
	effect = Ram.get(Ram.addr.sfx4)
	if effect > 0xce then
		return 0xff
	end
	if effect ~= 0 then
		return effect
	end
	
	return 0
end

return Sound