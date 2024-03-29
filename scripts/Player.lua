-- Required scripts
local parts = require("lib.GroupIndex")(models)

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("21A64C"))

-- Config setup
config:name("SerperiorTaur")
local vanillaSkin = config:load("AvatarVanillaSkin")
local slim        = config:load("AvatarSlim") or false
local shiny       = config:load("AvatarShiny") or false
if vanillaSkin == nil then vanillaSkin = true end

-- Set skull and portrait groups to visible (incase disabled in blockbench)
parts.Skull   :visible(true)
parts.Portrait:visible(true)

-- All vanilla skin parts
local skin = {
	
	parts.Head.Head,
	parts.Head.Layer,
	
	parts.Body.Body,
	parts.Body.Layer,
	
	parts.leftArmDefault,
	parts.leftArmSlim,
	parts.leftArmDefaultFP,
	parts.leftArmSlimFP,
	
	parts.rightArmDefault,
	parts.rightArmSlim,
	parts.rightArmDefaultFP,
	parts.rightArmSlimFP,
	
	parts.Portrait.Head,
	parts.Portrait.Layer,
	
	parts.Skull.Head,
	parts.Skull.Layer
	
}

-- All layer parts
local layer = {
	
	HAT = {
		parts.Head.Layer
	},
	JACKET = {
		parts.Body.Layer
	},
	LEFT_SLEEVE = {
		parts.leftArmDefault.Layer,
		parts.leftArmSlim.Layer,
		parts.leftArmDefaultFP.Layer,
		parts.leftArmSlimFP.Layer
	},
	RIGHT_SLEEVE = {
		parts.rightArmDefault.Layer,
		parts.rightArmSlim.Layer,
		parts.rightArmDefaultFP.Layer,
		parts.rightArmSlimFP.Layer
	},
	CAPE = {
		parts.Cape
	},
	LOWER_BODY = {
		
	}
}

-- All shiny parts
local shinyParts = {
	
	
	
}

--[[
	
	Because flat parts in the model are 2 faces directly on top
	of eachother, and have 0 inflate, the two faces will z-fight.
	This prevents z-fighting, as well as z-fighting at a distance,
	as well as translucent stacking.
	
	Please add plane/flat parts with 2 faces to the table below.
	0.01 works, but this works much better :)
	
--]]

-- All plane parts
local planes = {
	
	-- Ears
	parts.Ears,
	parts.EarsSkull,
	
	-- Merge Leaves
	parts.MergeLeaves,
	
	-- Leaf Arms
	parts.LeafArms,
	
	-- Tail Leaves
	parts.TailLeaf1,
	parts.TailLeaf2,
	parts.TailLeaf3
	
}

-- Apply
for _, part in ipairs(planes) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Determine vanilla player type on init
local vanillaAvatarType
function events.ENTITY_INIT()
	
	vanillaAvatarType = player:getModelType()
	
end

-- Misc tick required events
function events.TICK()
	
	-- Model shape
	local slimShape = (vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not vanillaSkin)
	
	parts.leftArmDefault:visible(not slimShape)
	parts.rightArmDefault:visible(not slimShape)
	parts.leftArmDefaultFP:visible(not slimShape)
	parts.rightArmDefaultFP:visible(not slimShape)
	
	parts.leftArmSlim:visible(slimShape)
	parts.rightArmSlim:visible(slimShape)
	parts.leftArmSlimFP:visible(slimShape)
	parts.rightArmSlimFP:visible(slimShape)
	
	-- Skin textures
	local skinType = vanillaSkin and "SKIN" or "PRIMARY"
	for _, part in ipairs(skin) do
		part:primaryTexture(skinType)
	end
	
	-- Shiny textures
	local textureType = shiny and textures["textures.serperior_shiny"] or textures["textures.serperior"]
	for _, part in ipairs(shinyParts) do
		part:primaryTexture("Custom", textureType)
	end
	
	-- Cape/Elytra textures
	parts.Cape:primaryTexture(vanillaSkin and "CAPE" or "PRIMARY")
	parts.Elytra:primaryTexture(vanillaSkin and player:hasCape() and (player:isSkinLayerVisible("CAPE") and "CAPE" or "ELYTRA") or "PRIMARY")
		:secondaryRenderType(player:getItem(5):hasGlint() and "GLINT" or "NONE")
	
	-- Layer toggling
	for layerType, parts in pairs(layer) do
		local enabled = enabled
		if layerType == "LOWER_BODY" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(layerType)
		end
		for _, part in ipairs(parts) do
			part:visible(enabled)
		end
	end
	
end

function events.RENDER(delta, context)
	
	-- Scales models to fit GUIs better
	if context == "FIGURA_GUI" or context == "MINECRAFT_GUI" or context == "PAPERDOLL" then
		-- parts.Player:scale(0.6)	-- CHANGE
		-- parts.Ball:scale(0.6)	-- ME
	end
	
	renderer:shadowRadius(1)	-- THIS IS TEMP! PLEASE MOVE!
	
end

function events.POST_RENDER(delta, context)
	
	-- After scaling models to fit GUIs, immediately scale back
	parts.Player:scale(1)
	parts.Ball:scale(1)
	
end

-- Vanilla skin toggle
local function setVanillaSkin(boolean)
	
	vanillaSkin = boolean
	config:save("AvatarVanillaSkin", vanillaSkin)
	
end

-- Model type toggle
local function setModelType(boolean)
	
	slim = boolean
	config:save("AvatarSlim", slim)
	
end

-- Shiny toggle
local function setShiny(boolean)
	
	shiny = boolean
	config:save("AvatarShiny", shiny)
	if player:isLoaded() and shiny then
		sounds:playSound("block.amethyst_block.chime", player:getPos(), 1)
	end
	
end

-- Sync variables
local function syncPlayer(a, b, c)
	
	vanillaSkin = a
	slim        = b
	shiny       = c
	
end

-- Pings setup
pings.setAvatarVanillaSkin = setVanillaSkin
pings.setAvatarModelType   = setModelType
pings.setAvatarShiny       = setShiny
pings.syncPlayer           = syncPlayer

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncPlayer(vanillaSkin, slim, shiny)
		end
		
	end
end

-- Activate actions
setVanillaSkin(vanillaSkin)
setModelType(slim)
setShiny(shiny)

-- Setup table
local t = {}

-- Action wheel pages
t.vanillaSkinPage = action_wheel:newAction("VanillaSkin")
	:title("§2§lToggle Vanilla Texture\n\n§eToggles the usage of your vanilla skin for the upper body.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item('minecraft:player_head{"SkullOwner":"'..avatar:getEntityName()..'"}')
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction("ModelShape")
	:title("§2§lToggle Model Shape\n\n§eAdjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item('minecraft:player_head')
	:toggleItem('minecraft:player_head{"SkullOwner":"MHF_Alex"}')
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

t.shinyPage = action_wheel:newAction("ModelShiny")
	:title("§2§lToggle Shiny Textures\n\n§eSet the lower body to use shiny textures over the default textures.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item('minecraft:gunpowder')
	:toggleItem("minecraft:glowstone_dust")
	:onToggle(pings.setAvatarShiny)
	:toggled(shiny)

-- Return action wheel pages
return t