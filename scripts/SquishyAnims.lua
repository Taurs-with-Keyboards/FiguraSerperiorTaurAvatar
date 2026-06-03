-- Kills script if squAPI or squAssets cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end

-- Required scripts
local parts  = require("lib.PartsAPI")
local lerp   = require("lib.LerpAPI")
local ground = require("lib.GroundCheck")
local pose   = require("scripts.Posing")

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

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