-- Required scripts
require("lib.GSAnimBlend")
local pokemonParts = require("lib.GroupIndex")(models.SerperiorTaur)
local ground       = require("lib.GroundCheck")
local average      = require("lib.Average")
local itemCheck    = require("lib.ItemCheck")
local pose         = require("scripts.Posing")
local effects      = require("scripts.SyncedVariables")
local color        = require("scripts.ColorProperties")

-- Animations setup
local anims = animations.SerperiorTaur

-- Config setup
config:name("SerperiorTaur")
local wrap = config:load("AnimsWrap")
local idle = config:load("AnimsIdle")
if wrap == nil then wrap = true end
if idle == nil then idle = true end

-- Variable setup
local maxWrap = 90
local maxRoll = 225

-- Ingame modifying animations
local tailRot = {}

-- Create tables for the tail parts
local function tailSetup(m, n)
	
	if n == nil then n = 0 end
	n = n + 1
	
	tailRot[n] = {
		seg = m,
		rot = {
			prev = vec(0, 0, 0),
			next = vec(0, 0, 0),
			curr = vec(0, 0, 0)
		},
		wrap = {
			wrapped = false,
			dir     = 0,
			speed   = 0
		}
	}
	
	local c = m:getChildren()
	
	for _, p in ipairs(c) do
		if p:getName() == "Tail"..tostring(n+3) then
			tailSetup(p, n)
		end
	end
	
end

-- Call function
function events.ENTITY_INIT()
	
	tailSetup(pokemonParts.Tail3)
	
end

-- Parrot pivots
local parrots = {
	
	--[[
		pokemonParts.LeftParrotPivot,
		pokemonParts.RightParrotPivot
	--]]
	
}

-- Box check
local function inBox(pos, box_min, box_max)
	return pos.x >= box_min.x and pos.x <= box_max.x and
		   pos.y >= box_min.y and pos.y <= box_max.y and
		   pos.z >= box_min.z and pos.z <= box_max.z
end

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Set staticRoll to roll on init
local staticRoll = 0
function events.ENTITY_INIT()
	
	staticRoll = player:getBodyYaw()
	
end

function events.TICK()
	
	-- Player variables
	local vel      = player:getVelocity()
	local bodyRoll = player:getBodyYaw()
	local onGround = player:isOnGround() or ground()
	
	-- Static roll
	if not anims.groundIdle:isPlaying() then
		staticRoll = math.clamp(staticRoll, bodyRoll - maxRoll, bodyRoll + maxRoll)
		staticRoll = math.lerp(staticRoll, bodyRoll, onGround and math.clamp(vel:length(), 0, 1) or 0.25)
	else
		staticRoll = bodyRoll
	end
	
	local fullRoll = bodyRoll - staticRoll
	
	-- Animation variables
	local walking = vel.xz:length() ~= 0
	
	-- Animation states
	local groundIdle = not walking and idle and not anims.coil:isPlaying()
	local groundWalk = (walking or not idle) and not (pose.swim or pose.elytra or pose.crawl) and not anims.coil:isPlaying()
	local swim       = pose.swim or pose.elytra or pose.crawl
	local flatten    = onGround
	local sleep      = pose.sleep
	local breathe    = true
	
	-- Animations
	anims.groundIdle:playing(groundIdle)
	anims.groundWalk:playing(groundWalk)
	anims.swim:playing(swim)
	anims.flatten:playing(flatten)
	--anims.sleep:playing(sleep)
	--anims.breathe:playing(breathe)
	
	-- Apply rots to tail
	for _, tail in ipairs(tailRot) do
		
		-- Tick lerps
		tail.rot.prev.x = tail.rot.next.x
		tail.rot.prev.y = tail.rot.next.y
		tail.rot.prev.z = tail.rot.next.z
		
		-- Pitch rotations
		if not wrap or average(pokemonParts.Pokeball:getScale():unpack()) >= 0.5 or anims.coil:isPlaying() then
			
			-- Stop all movement
			tail.rot.next.x = 0
			
		elseif not(pose.stand or pose.crouch) or effects.cF or vel:length() ~= 0 then
			
			local strength = math.map(_, 1, #tailRot, #tailRot/2, -#tailRot/2)
			if pose.elytra then
				strength = -strength
			elseif anims.groundIdle:isPlaying() then
				strength = 2
			end
			
			tail.rot.next.x = math.lerp(tail.rot.next.x, math.clamp(vel.y * strength * 10, -25, 25), math.clamp(vel:length() == 0 and 0.25 or vel:length() * 2, 0, 1))
			
		elseif onGround then
			
			local groundPos   = tail.seg:partToWorldMatrix():apply(0, -10, 0)
			local blockPos    = groundPos:copy():floor()
			local groundBlock = world.getBlockState(groundPos)
			local groundBoxes = groundBlock:getCollisionShape()
			
			local airPos   = tail.seg:partToWorldMatrix():apply(0, -10, -5)
			local airBlock = world.getBlockState(airPos)
			
			local inGround = false
			local inAir    = false
			if groundBoxes then
				for i = 1, #groundBoxes do
					local box = groundBoxes[i]
					if inBox(groundPos, blockPos + box[1], blockPos + box[2]) then
						
						inGround = true
						break
						
					end
				end
			end
			
			if not airBlock:hasCollision() or airBlock.id == "minecraft:snow" then
				
				inAir = true
				
			end
			
			if inGround or inAir then
				
				-- Confirm status
				tail.wrap.wrapped = false
				
				-- Check to see if segment is already at maximum rot
				local isMaxWrap = tail.rot.next.x == maxWrap
				
				if isMaxWrap and not inGround then
					
					tail.wrap.wrapped = true
					
				elseif tailRot[_-1] and not tailRot[_-1].wrap.wrapped then -- Check parent's status
					
					-- Fold back to offset parent (Helps to eliminate "Unfolding")
					tail.rot.next.x = math.lerp(tail.rot.next.x, -tailRot[_-1].rot.next.x, 0.2)
					
				else
					
					-- Gather rot directions
					local prevDir = tail.wrap.dir
					tail.wrap.dir = inGround and -1 or inAir and 1
					
					-- Increase speed every tick, but reset if changing direction
					tail.wrap.speed = math.clamp(tail.wrap.speed + 1, 0, 20)
					if prevDir ~= tail.wrap.dir then tail.wrap.speed = 0 end
					
					-- Calculate change
					local calc = 0.05 * tail.wrap.speed^2 * tail.wrap.dir
					tail.rot.next.x = math.clamp(tail.rot.next.x + calc, -maxWrap, maxWrap)
					
				end
				
			else
				
				-- Confirm status
				tail.wrap.wrapped = true
				
				-- Reset variables
				tail.wrap.speed = 0
				tail.wrap.dir   = 0
				
			end
			
		end
		
		-- Roll rotations
		if _ ~= 1 then
			
			tail.rot.next.z = fullRoll / #tailRot
			
		end
		
	end
	
end

-- Sleep rotations
local dirRot = {
	north = 0,
	east  = 270,
	south = 180,
	west  = 90
}

function events.RENDER(delta, context)
	
	-- Player variables
	local vel = player:getVelocity()
	local dir = player:getLookDir()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	
	-- Animation speeds
	local moveSpeed = math.clamp(pose.climb and udVel * 4 or (fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) or math.max(fbVel, math.abs(lrVel))) * 4, -2, 2)
	anims.groundWalk:speed(moveSpeed)
	anims.swim:speed(moveSpeed)
	
	-- Apply rots to tail
	for _, tail in pairs(tailRot) do
		
		-- Render lerp
		tail.rot.curr = math.lerp(tail.rot.prev, tail.rot.next, delta)
		
		-- Apply
		tail.seg:offsetRot(tail.rot.curr)
		
	end
	
	-- Sleep rotations
	if pose.sleep then
		
		-- Disable vanilla rotation
		renderer:rootRotationAllowed(false)
		
		-- Find block
		local block = world.getBlockState(player:getPos())
		local sleepRot = dirRot[block.properties["facing"]]
		
		-- Apply
		models:rot(0, sleepRot, 0)
		
	else
		
		-- Enable vanilla rotation
		renderer:rootRotationAllowed(true)
		
		-- Reset
		models:rot(0)
		
	end
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()))
	end
	
	-- Crouch offset
	local bodyRot = vanilla_model.BODY:getOriginRot(delta)
	local crouchPos = vec(0, -math.sin(math.rad(bodyRot.x)) * 2, -math.sin(math.rad(bodyRot.x)) * 12)
	pokemonParts.UpperBody:offsetPivot(crouchPos):pos(-crouchPos.x_z + crouchPos._y_)
	pokemonParts.Player:pos(crouchPos.x_z + crouchPos._y_ * 2)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = {7,7} },
	{ anim = anims.groundWalk, ticks = {7,7} },
	{ anim = anims.swim,       ticks = {7,7} },
	{ anim = anims.coil,       ticks = {7,7} },
	{ anim = anims.flatten,    ticks = {7,7} }
}
	
-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	if blend.anim ~= nil then
		blend.anim:blendTime(table.unpack(blend.ticks)):blendCurve("easeOutQuad")
	end
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	pokemonParts.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Wrap toggle
local function setWrap(boolean)
	
	wrap = boolean
	config:save("AnimsWrap", wrap)
	
end

-- Idle toggle
local function setIdle(boolean)
	
	idle = boolean
	config:save("AnimsIdle", idle)
	
end

-- Sync variables
local function syncAnims(a, b)
	
	wrap = a
	idle = b
	
end

-- Pings setup
pings.setAnimsWrap = setWrap
pings.setAnimsIdle = setIdle
pings.syncAnims    = syncAnims

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncAnims(wrap, idle)
		end
		
	end
end

-- Activate actions
setWrap(wrap)
setIdle(idle)

-- Setup table
local t = {}

t.wrapPage = action_wheel:newAction()
	:item(itemCheck("bamboo"))
	:toggleItem(itemCheck("string"))
	:onToggle(pings.setAnimsWrap)
	:toggled(wrap)
	
t.idlePage = action_wheel:newAction()
	:item(itemCheck("music_disc_11"))
	:toggleItem(itemCheck("music_disc_far"))
	:onToggle(pings.setAnimsIdle)
	:toggled(idle)


-- Update action page info
function events.TICK()
	
	t.wrapPage
		:title(toJson(
			{
				"",
				{text = "Toggle Wrapping\n\n", bold = true, color = color.primary},
				{text = "Toggles the ability for your tail to attempt to \"wrap\" around surfaces.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
	
	t.idlePage
		:title(toJson(
			{
				"",
				{text = "Toggle Idle animation\n\n", bold = true, color = color.primary},
				{text = "Toggles the usage of the animation that plays when you stop moving.\nDisabling this allows you to have more control your tail's positioning.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
	
end

-- Returns animation variables/action wheel pages
return t