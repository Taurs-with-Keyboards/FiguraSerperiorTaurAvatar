-- Required scripts
local pokeballParts = require("lib.GroupIndex")(models.models.Pokeball)
local average       = require("lib.Average")

-- Keybind config
config:name("SerperiorTaur")
local bind = config:load("PokemonCryKeybind") or "key.keyboard.keypad.2"

function events.TICK()
	
	-- Hit sound
	if player:getNbt()["HurtTime"] == 10 then
		if average(pokeballParts.Pokeball:getScale():unpack()) >= 0.5 then
			sounds:playSound("cobblemon:poke_ball.open", player:getPos(), 0.4)
		else
			sounds:playSound("cobblemon:pokemon.serperior.cry", player:getPos(), 0.6, math.random()*0.35+0.85)
		end
	end
	
end

-- Keybind cry noise
local cooldown = 0
local function pokemonCry()
	
	sounds:playSound("cobblemon:pokemon.serperior.cry", player:getPos(), 0.6, math.random()*0.35+0.85)
	cooldown = 0
	
end

-- Keybind ping setup
pings.playPokemonCry = pokemonCry

-- Keybind
local kbCry = keybinds:newKeybind("Pokemon Cry"):onPress(function() pings.playPokemonCry() end):key(bind)

function events.TICK()
	
	-- Cooldown timer
	if cooldown < 30 then
		cooldown = cooldown + 1
	end
	
	kbCry:enabled(cooldown == 30 and player:getDeathTime() == 0)
	
	-- Config updater
	local key = kbCry:getKey()
	if key ~= bind then
		bind = key
		config:save("PokemonCryKeybind", key)
	end
	
end