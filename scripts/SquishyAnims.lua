-- Kills script if squAPI or squAssets cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end

-- Required scripts
local parts  = require("lib.PartsAPI")
local sync   = require("lib.LetThatSyncFig")
local lerp   = require("lib.LerpAPI")
local ground = require("lib.GroundCheck")
local pose   = require("scripts.Posing")

-- Synced variables setup
local armsMove = sync.new("AnimsArms", false):config()

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Lerp tables
local leftArmLerp  = lerp.new(armsMove.curr and 1 or 0, 0.5)
local rightArmLerp = lerp.new(armsMove.curr and 1 or 0, 0.5)

-- Head table
local headParts = {
	
	parts.group.UpperBody,
	parts.group.Neck
	
}

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	headParts,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)

-- Squishy vanilla arms
local leftArm = squapi.arm:new(
	parts.group.LeftArm,
	1,     -- Strength (1)
	false, -- Right Arm (false)
	true   -- Keep Position (true)
)

local rightArm = squapi.arm:new(
	parts.group.RightArm,
	1,    -- Strength (1)
	true, -- Right Arm (true)
	true  -- Keep Position (true)
)

-- Arm strength variables
local leftArmStrength  = leftArm.strength
local rightArmStrength = rightArm.strength

-- Rotation inits
local _yaw = 0
local _headRot = vec(0, 0, 0)
function events.ENTITY_INIT()
	
	_yaw = player:getBodyYaw()
	_headRot = vanilla_model.HEAD:getOriginRot()
	
end

-- Bounce Parts
local lEar = lerp.new(0, 0.2, 0.05, 0.5)
local rEar = lerp.new(0, 0.2, 0.05, 0.5)
local lNeck = lerp.new(vec(0, 0, 0), 0.2, 0.05, 0.5)
local rNeck = lerp.new(vec(0, 0, 0), 0.2, 0.05, 0.5)
local _pose = "STANDING"
local _onGround = true

local leftEarParts   = parts:createChain("LeftEar")
local rightEarParts  = parts:createChain("RightEar")
local leftNeckParts  = parts:createChain("NeckLeavesLeft")
local rightNeckParts = parts:createChain("NeckLeavesRight")

function events.TICK()
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftSwing   = player:getSwingArm() == leftActive
	local rightSwing  = player:getSwingArm() == rightActive
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local usingL      = activeness == leftActive and leftItem:getUseAction() or "NONE"
	local usingR      = activeness == rightActive and rightItem:getUseAction() or "NONE"
	local bow         = using and (usingL == "BOW" or usingR == "BOW")
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	-- Arm movement overrides
	local armShouldMove = pose.swim or pose.crawl
	
	-- Control targets based on variables
	leftArmLerp.target  = (armsMove.curr or armShouldMove or leftSwing  or bow or ((crossL or crossR) or (using and usingL ~= "NONE"))) and 1 or 0
	rightArmLerp.target = (armsMove.curr or armShouldMove or rightSwing or bow or ((crossL or crossR) or (using and usingR ~= "NONE"))) and 1 or 0
	
	-- Variables
	local dir = player:getLookDir()
	local yaw = player:getBodyYaw()
	local headRot = vanilla_model.HEAD:getOriginRot()
	local onGround = ground()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local udVel = player:getVelocity().y
	
	-- Set targets
	if onGround and not _onGround then
		lEar.vel = lEar.vel - udVel * 35
		rEar.vel = rEar.vel - udVel * 35
		lNeck.target.z = -lNeck.target.z
		rNeck.target.z = -rNeck.target.z
	else
		lEar.target = math.clamp(math.clamp(fbVel, -0.1, 0.1) + math.max(udVel, 0) / 1.5, -0.3, 0.3) * 100
		rEar.target = math.clamp(math.clamp(fbVel, -0.1, 0.1) + math.max(udVel, 0) / 1.5, -0.3, 0.3) * 100
		lNeck.target.yz = vec(math.clamp(fbVel, -0.2, 0.2) * 50, math.clamp(udVel, -0.4, 0.4) * 50)
		rNeck.target.yz = vec(math.clamp(-fbVel, -0.2, 0.2) * 50, math.clamp(-udVel, -0.4, 0.4) * 50)
	end
	
	-- Velocity adjustments
	local yawOffset = math.clamp((_yaw - yaw) / 4, -7.5, 7.5)
	local headOffset = ((_headRot - headRot) / 4):applyFunc(function(v) return math.clamp(v, -7.5, 7.5) end)
	lEar.vel = lEar.vel + headOffset.x + headOffset.y - yawOffset
	rEar.vel = rEar.vel + headOffset.x - headOffset.y + yawOffset
	lNeck.vel.y = lNeck.vel.y - yawOffset
	rNeck.vel.y = rNeck.vel.y - yawOffset
	
	-- Crouch boost
	if pose.crouch and _pose == "STANDING" then
		lEar.vel    = lEar.vel - 10
		rEar.vel    = rEar.vel - 10
		lNeck.vel.z = lNeck.vel.z - 10
		rNeck.vel.z = rNeck.vel.z + 10
	elseif pose.stand and _pose == "CROUCHING" then
		lEar.vel    = lEar.vel + 10
		rEar.vel    = rEar.vel + 10
		lNeck.vel.z = lNeck.vel.z + 10
		rNeck.vel.z = rNeck.vel.z - 10
	end
	
	-- Store data
	_yaw = yaw
	_headRot = headRot
	_onGround = onGround
	_pose = player:getPose()
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local idleTimer   = world.getTime(delta)
	local idleRot     = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	local firstPerson = context == "FIRST_PERSON"
	
	-- Adjust arm strengths
	leftArm.strength  = leftArmStrength  * leftArmLerp.currPos
	rightArm.strength = rightArmStrength * rightArmLerp.currPos
	
	-- Adjust arm characteristics after applied by squapi
	parts.group.LeftArm
		:offsetRot(
			parts.group.LeftArm:getOffsetRot()
			+ ((-idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(leftArmLerp.currPos, 0, 1, 1, 0))
		)
		:pos(parts.group.LeftArm:getPos() * vec(1, 1, -1))
		:visible(not firstPerson)
	
	parts.group.RightArm
		:offsetRot(
			parts.group.RightArm:getOffsetRot()
			+ ((idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(rightArmLerp.currPos, 0, 1, 1, 0))
		)
		:pos(parts.group.RightArm:getPos() * vec(1, 1, -1))
		:visible(not firstPerson)
	
	-- Set visible if in first person
	parts.group.LeftArmFP:visible(firstPerson)
	parts.group.RightArmFP:visible(firstPerson)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.group.body`
	for _, group in ipairs(parts.group.UpperBody:getChildren()) do
		if group ~= parts.group.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
	-- Apply bounces
	for _, part in ipairs(leftEarParts) do
		part:offsetRot(lEar.currPos, 0, 0)
	end
	for _, part in ipairs(rightEarParts) do
		part:offsetRot(rEar.currPos, 0, 0)
	end
	for _, part in ipairs(leftNeckParts) do
		part:offsetRot(lNeck.currPos)
	end
	for _, part in ipairs(rightNeckParts) do
		part:offsetRot(rNeck.currPos)
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, wheel, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Anims") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Anims")

-- Pages
local parentPage = action_wheel:getPage("Main")
local animsPage  = pageExists or action_wheel:newPage("Anims")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item("jukebox")
		:onLeftClick(function() wheel:descend(animsPage) end)
end

a.armsAct = animsPage:newAction()
	:item("red_dye")
	:toggleItem("rabbit_foot")
	:onToggle(function(bool)
		armsMove:update(bool)
	end)
	:toggled(armsMove.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Animation Settings", bold = true, color = c.primary}
				))
		end
		
		a.armsAct
			:title(toJson(
				{
					"",
					{text = "Arm Movement Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end