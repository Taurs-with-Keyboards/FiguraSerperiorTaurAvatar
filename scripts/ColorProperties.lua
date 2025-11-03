-- Required scripts
local pokemonParts = require("lib.GroupIndex")(models.SerperiorTaur)
local itemCheck    = require("lib.ItemCheck")

-- Config setup
config:name("SerperiorTaur")
local shiny = config:load("ShinyToggle") == nil and vec(client.uuidToIntArray(avatar:getUUID())).x % 4096 == 0 or config:load("ShinyToggle")

-- All shiny parts
local shinyParts = {
	
	-- Ears
	pokemonParts.Ears,
	pokemonParts.EarsSkull,
	
	-- Accessories
	pokemonParts.NeckLeaves,
	pokemonParts.LeafArms,
	pokemonParts.TailLeaf1,
	pokemonParts.TailLeaf2,
	pokemonParts.TailLeaf3,
	
	-- Tail
	pokemonParts.Neck.Neck,
	pokemonParts.Tail1.Tail,
	pokemonParts.Tail2.Tail,
	pokemonParts.Tail3.Tail,
	pokemonParts.Tail4.Tail,
	pokemonParts.Tail5.Tail,
	pokemonParts.Tail6.Tail,
	pokemonParts.Tail7.Tail,
	pokemonParts.Tail8.Tail,
	pokemonParts.Tail9.Tail
	
}

-- Table setup
local t = {}

function events.TICK()
	
	-- Set colors
	t.hover     = vectors.hexToRGB(shiny and "4C8CA7" or "21A64C")
	t.active    = vectors.hexToRGB(shiny and "DDE791" or "EFC435")
	t.primary   = "#"..(shiny and "4C8CA7" or "21A64C")
	t.secondary = "#"..(shiny and "DDE791" or "EFC435")
	
	-- Shiny textures
	local textureType = shiny and (textures["textures.serperior_shiny"] or textures["models.SerperiorTaur.serperior_shiny"]) or (textures["textures.serperior"] or textures["models.SerperiorTaur.serperior"])
	for _, part in ipairs(shinyParts) do
		--part:primaryTexture("Custom", textureType)
	end
	
	-- Glowing outline
	renderer:outlineColor(vectors.hexToRGB(shiny and "4C8CA7" or "21A64C"))
	
	-- Avatar color
	avatar:color(vectors.hexToRGB(shiny and "4C8CA7" or "21A64C"))
	
end

-- Shiny toggle
local function setShiny(boolean)
	
	shiny = boolean
	config:save("ColorShiny", shiny)
	if player:isLoaded() and shiny then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
	
end

-- Sync variables
local function syncColor(a)
	
	shiny = a
	
end

-- Pings setup
pings.setColorShiny = setShiny
pings.syncColor     = syncColor

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncColor(shiny)
		end
		
	end
end

-- Activate actions
setShiny(shiny)

t.shinyPage = action_wheel:newAction()
	:item(itemCheck("gunpowder"))
	:toggleItem(itemCheck("glowstone_dust"))
	:onToggle(pings.setColorShiny)
	:toggled(shiny)

-- Update action page info
function events.TICK()
	
	t.shinyPage
		:title(toJson(
			{
				"",
				{text = "Toggle Shiny Textures\n\n", bold = true, color = t.primary},
				{text = "Set the lower body to use shiny textures over the default textures.", color = t.secondary}
			}
		))
		:hoverColor(t.hover)
		:toggleColor(t.active)
	
end

-- Return table
return t