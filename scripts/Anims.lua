-- Required scripts
local parts  = require("lib.PartsAPI")
local sync   = require("lib.LetThatSyncFig")
local lerp   = require("lib.LerpAPI")
local ground = require("lib.GroundCheck")
local pose   = require("scripts.Posing")

-- Synced variables setup
local armsMove = sync.new("AnimsArms", false):config()

-- Arms setup
local leftArmLerp  = lerp.new(armsMove.curr and 1 or 0, 0.5)
local rightArmLerp = lerp.new(armsMove.curr and 1 or 0, 0.5)

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

-- Gets the origin rotation of a part, clamped
local function getOriginRot(part, delta)
	return (vanilla_model[part]:getOriginRot(delta) + 180) % 360 - 180
end

-- Rotation inits
local _yaw = 0
local _headRot = vec(0, 0, 0)
function events.ENTITY_INIT()
	
	_yaw = player:getBodyYaw()
	_headRot = vanilla_model.HEAD:getOriginRot()
	
end

function events.TICK()
	
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
	
	-- Arm variables
	local handedness = player:isLeftHanded()
	local mainL = not handedness and "OFF_HAND" or "MAIN_HAND"
	local mainR = handedness and "OFF_HAND" or "MAIN_HAND"
	local swingL = player:getSwingArm() == mainL
	local swingR = player:getSwingArm() == mainR
	local using = player:isUsingItem()
	local active = player:getActiveHand()
	local itemL = player:getHeldItem(not handedness)
	local itemR = player:getHeldItem(handedness)
	local usingL = using and active == mainL and itemL:getUseAction()
	local usingR = using and active == mainR and itemR:getUseAction()
	local bow = (usingL or usingR or ""):find("BOW") or (itemL:getTag().Charged or itemR:getTag().Charged) == 1
	
	-- Arm movement overrides
	local armShouldMove = pose.swim or pose.crawl
	
	-- Arms movement targets
	leftArmLerp.target  = (armsMove.curr or armShouldMove or swingL or usingL or bow) and 0 or -1
	rightArmLerp.target = (armsMove.curr or armShouldMove or swingR or usingR or bow) and 0 or -1
	
	-- Store data
	_yaw = yaw
	_headRot = headRot
	_onGround = onGround
	_pose = player:getPose()
	
end

function events.RENDER(delta, context)
	
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
	
	-- Arm idle rotation
	local idleTimer = world.getTime(delta)
	local idleRot   = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	
	-- Apply arm rotations
	parts.group.LeftArm:offsetRot((getOriginRot("LEFT_ARM", delta) + idleRot) * leftArmLerp.currPos)
	parts.group.RightArm:offsetRot((getOriginRot("RIGHT_ARM", delta) - idleRot) * rightArmLerp.currPos)
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local s, pageNav, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

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
		:onLeftClick(function() pageNav.descend(animsPage) end)
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