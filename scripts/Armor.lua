-- Required scripts
local pokemonParts   = require("lib.GroupIndex")(models.SerperiorTaur)
local serperiorArmor = require("lib.KattArmor")()
local itemCheck      = require("lib.ItemCheck")
local color          = require("scripts.ColorProperties")

-- Setting the leggings to layer 1
serperiorArmor.Armor.Leggings:setLayer(1)

-- Armor parts
serperiorArmor.Armor.Helmet
	:addParts(pokemonParts.headArmorHelmet.Helmet)
	:addTrimParts(pokemonParts.headArmorHelmet.Trim)
serperiorArmor.Armor.Chestplate
	:addParts(
		pokemonParts.bodyArmorChestplate.Chestplate,
		pokemonParts.leftArmArmorChestplate.Chestplate,
		pokemonParts.rightArmArmorChestplate.Chestplate,
		pokemonParts.leftArmArmorChestplateFP.Chestplate,
		pokemonParts.rightArmArmorChestplateFP.Chestplate
	)
	:addTrimParts(
		pokemonParts.bodyArmorChestplate.Trim,
		pokemonParts.leftArmArmorChestplate.Trim,
		pokemonParts.rightArmArmorChestplate.Trim,
		pokemonParts.leftArmArmorChestplateFP.Trim,
		pokemonParts.rightArmArmorChestplateFP.Trim
	)
serperiorArmor.Armor.Leggings
	:addParts(
		pokemonParts.NeckArmorLeggings.Leggings,
		pokemonParts.Tail1ArmorLeggings.Leggings,
		pokemonParts.Tail2ArmorLeggings.Leggings,
		pokemonParts.Tail3ArmorLeggings.Leggings,
		pokemonParts.Tail4ArmorLeggings.Leggings,
		pokemonParts.Tail5ArmorLeggings.Leggings,
		pokemonParts.Tail6ArmorLeggings.Leggings
	)
	:addTrimParts(
		pokemonParts.NeckArmorLeggings.Trim,
		pokemonParts.Tail1ArmorLeggings.Trim,
		pokemonParts.Tail2ArmorLeggings.Trim,
		pokemonParts.Tail3ArmorLeggings.Trim,
		pokemonParts.Tail4ArmorLeggings.Trim,
		pokemonParts.Tail5ArmorLeggings.Trim,
		pokemonParts.Tail6ArmorLeggings.Trim
	)
serperiorArmor.Armor.Boots
	:addParts(
		pokemonParts.Tail7ArmorBoot.Boot,
		pokemonParts.Tail8ArmorBoot.Boot,
		pokemonParts.Tail9ArmorBoot.Boot
	)
	:addTrimParts(
		pokemonParts.Tail7ArmorBoot.Trim,
		pokemonParts.Tail8ArmorBoot.Trim,
		pokemonParts.Tail9ArmorBoot.Trim
	)

-- Leather armor
serperiorArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"] or textures["models.SerperiorTaur.leatherArmor"])
	:addParts(serperiorArmor.Armor.Helmet,
		pokemonParts.headArmorHelmet.Leather
	)
	:addParts(serperiorArmor.Armor.Chestplate,
		pokemonParts.bodyArmorChestplate.Leather,
		pokemonParts.leftArmArmorChestplate.Leather,
		pokemonParts.rightArmArmorChestplate.Leather,
		
		pokemonParts.leftArmArmorChestplateFP.Leather,
		pokemonParts.rightArmArmorChestplateFP.Leather
	)
	:addParts(serperiorArmor.Armor.Leggings,
		pokemonParts.NeckArmorLeggings.Leather,
		pokemonParts.Tail1ArmorLeggings.Leather,
		pokemonParts.Tail2ArmorLeggings.Leather,
		pokemonParts.Tail3ArmorLeggings.Leather,
		pokemonParts.Tail4ArmorLeggings.Leather,
		pokemonParts.Tail5ArmorLeggings.Leather,
		pokemonParts.Tail6ArmorLeggings.Leather
	)
	:addParts(serperiorArmor.Armor.Boots,
		pokemonParts.Tail7ArmorBoot.Leather,
		pokemonParts.Tail8ArmorBoot.Leather,
		pokemonParts.Tail9ArmorBoot.Leather
	)

-- Chainmail armor
serperiorArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"] or textures["models.SerperiorTaur.chainmailArmor"])

-- Iron armor
serperiorArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"] or textures["models.SerperiorTaur.ironArmor"])

-- Golden armor
serperiorArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"] or textures["models.SerperiorTaur.goldenArmor"])

-- Diamond armor
serperiorArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"] or textures["models.SerperiorTaur.diamondArmor"])

-- Netherite armor
serperiorArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"] or textures["models.SerperiorTaur.netheriteArmor"])

-- Turtle helmet
serperiorArmor.Materials.turtle
	:setTexture(textures["textures.armor.turtleHelmet"] or textures["models.SerperiorTaur.turtleHelmet"])

-- Trims
-- Bolt
serperiorArmor.TrimPatterns.bolt
	:setTexture(textures["textures.armor.trims.boltTrim"] or textures["models.SerperiorTaur.boltTrim"])

-- Coast
serperiorArmor.TrimPatterns.coast
	:setTexture(textures["textures.armor.trims.coastTrim"] or textures["models.SerperiorTaur.coastTrim"])

-- Dune
serperiorArmor.TrimPatterns.dune
	:setTexture(textures["textures.armor.trims.duneTrim"] or textures["models.SerperiorTaur.duneTrim"])

-- Eye
serperiorArmor.TrimPatterns.eye
	:setTexture(textures["textures.armor.trims.eyeTrim"] or textures["models.SerperiorTaur.eyeTrim"])

-- Flow
serperiorArmor.TrimPatterns.flow
	:setTexture(textures["textures.armor.trims.flowTrim"] or textures["models.SerperiorTaur.flowTrim"])

-- Host
serperiorArmor.TrimPatterns.host
	:setTexture(textures["textures.armor.trims.hostTrim"] or textures["models.SerperiorTaur.hostTrim"])

-- Raiser
serperiorArmor.TrimPatterns.raiser
	:setTexture(textures["textures.armor.trims.raiserTrim"] or textures["models.SerperiorTaur.raiserTrim"])

-- Rib
serperiorArmor.TrimPatterns.rib
	:setTexture(textures["textures.armor.trims.ribTrim"] or textures["models.SerperiorTaur.ribTrim"])

-- Sentry
serperiorArmor.TrimPatterns.sentry
	:setTexture(textures["textures.armor.trims.sentryTrim"] or textures["models.SerperiorTaur.sentryTrim"])

-- Shaper
serperiorArmor.TrimPatterns.shaper
	:setTexture(textures["textures.armor.trims.shaperTrim"] or textures["models.SerperiorTaur.shaperTrim"])

-- Silence
serperiorArmor.TrimPatterns.silence
	:setTexture(textures["textures.armor.trims.silenceTrim"] or textures["models.SerperiorTaur.silenceTrim"])

-- Snout
serperiorArmor.TrimPatterns.snout
	:setTexture(textures["textures.armor.trims.snoutTrim"] or textures["models.SerperiorTaur.snoutTrim"])

-- Spire
serperiorArmor.TrimPatterns.spire
	:setTexture(textures["textures.armor.trims.spireTrim"] or textures["models.SerperiorTaur.spireTrim"])

-- Tide
serperiorArmor.TrimPatterns.tide
	:setTexture(textures["textures.armor.trims.tideTrim"] or textures["models.SerperiorTaur.tideTrim"])

-- Vex
serperiorArmor.TrimPatterns.vex
	:setTexture(textures["textures.armor.trims.vexTrim"] or textures["models.SerperiorTaur.vexTrim"])

-- Ward
serperiorArmor.TrimPatterns.ward
	:setTexture(textures["textures.armor.trims.wardTrim"] or textures["models.SerperiorTaur.wardTrim"])

-- Wayfinder
serperiorArmor.TrimPatterns.wayfinder
	:setTexture(textures["textures.armor.trims.wayfinderTrim"] or textures["models.SerperiorTaur.wayfinderTrim"])

-- Wild
serperiorArmor.TrimPatterns.wild
	:setTexture(textures["textures.armor.trims.wildTrim"] or textures["models.SerperiorTaur.wildTrim"])

-- Config setup
config:name("SerperiorTaur")
local helmet     = config:load("ArmorHelmet")
local chestplate = config:load("ArmorChestplate")
local leggings   = config:load("ArmorLeggings")
local boots      = config:load("ArmorBoots")
if helmet     == nil then helmet     = true end
if chestplate == nil then chestplate = true end
if leggings   == nil then leggings   = true end
if boots      == nil then boots      = true end

-- All helmet parts
local helmetGroups = {
	
	pokemonParts.headArmorHelmet,
	pokemonParts.HelmetItemPivot
	
}

-- All chestplate parts
local chestplateGroups = {
	
	pokemonParts.bodyArmorChestplate,
	pokemonParts.leftArmArmorChestplate,
	pokemonParts.rightArmArmorChestplate,
	
	pokemonParts.leftArmArmorChestplateFP,
	pokemonParts.rightArmArmorChestplateFP
}

-- All leggings parts
local leggingsGroups = {
	
	pokemonParts.NeckArmorLeggings,
	pokemonParts.Tail1ArmorLeggings,
	pokemonParts.Tail2ArmorLeggings,
	pokemonParts.Tail3ArmorLeggings,
	pokemonParts.Tail4ArmorLeggings,
	pokemonParts.Tail5ArmorLeggings,
	pokemonParts.Tail6ArmorLeggings
	
}

-- All boots parts
local bootsGroups = {
	
	pokemonParts.Tail7ArmorBoot,
	pokemonParts.Tail8ArmorBoot,
	pokemonParts.Tail9ArmorBoot
	
}

function events.TICK()
	
	for _, part in ipairs(helmetGroups) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(chestplateGroups) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(leggingsGroups) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(bootsGroups) do
		part:visible(boots)
	end
	
end

-- Armor all toggle
local function setAll(boolean)
	
	helmet     = boolean
	chestplate = boolean
	leggings   = boolean
	boots      = boolean
	config:save("ArmorHelmet", helmet)
	config:save("ArmorChestplate", chestplate)
	config:save("ArmorLeggings", leggings)
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor helmet toggle
local function setHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
local function setChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
local function setLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
local function setBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
local function syncArmor(a, b, c, d)
	
	helmet     = a
	chestplate = b
	leggings   = c
	boots      = d
	
end

-- Pings setup
pings.setArmorAll        = setAll
pings.setArmorHelmet     = setHelmet
pings.setArmorChestplate = setChestplate
pings.setArmorLeggings   = setLeggings
pings.setArmorBoots      = setBoots
pings.syncArmor          = syncArmor

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncArmor(helmet, chestplate, leggings, boots)
		end
		
	end
end

-- Activate actions
setHelmet(helmet)
setChestplate(chestplate)
setLeggings(leggings)
setBoots(boots)

-- Setup table
local t = {}

-- Action wheel pages
t.allPage = action_wheel:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("netherite_chestplate"))
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction()
	:item(itemCheck("iron_helmet"))
	:toggleItem(itemCheck("diamond_helmet"))
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction()
	:item(itemCheck("iron_chestplate"))
	:toggleItem(itemCheck("diamond_chestplate"))
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction()
	:item(itemCheck("iron_leggings"))
	:toggleItem(itemCheck("diamond_leggings"))
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction()
	:item(itemCheck("iron_boots"))
	:toggleItem(itemCheck("diamond_boots"))
	:onToggle(pings.setArmorBoots)

-- Update action page info
function events.TICK()
	
	t.allPage
		:title(toJson(
			{
				"",
				{text = "Toggle All Armor\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of all armor parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(helmet and chestplate and leggings and boots)
	
	t.helmetPage
		:title(toJson(
			{
				"",
				{text = "Toggle Helmet\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of helmet parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(helmet)
	
	t.chestplatePage
		:title(toJson(
			{
				"",
				{text = "Toggle Chestplate\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of chestplate parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(chestplate)
	
	t.leggingsPage
		:title(toJson(
			{
				"",
				{text = "Toggle Leggings\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of leggings parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(leggings)
	
	t.bootsPage
		:title(toJson(
			{
				"",
				{text = "Toggle Boots\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of boots.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(boots)
	
end

-- Return action wheel pages
return t