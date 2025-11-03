-- Required scripts
local pokemonParts = require("lib.GroupIndex")(models.SerperiorTaur)
local squapi       = require("lib.SquAPI")
local pose         = require("scripts.Posing")

-- Animation setup
local anims = animations.SerperiorTaur

-- Parts table setup
local squapiParts = {}

-- Create tables of child parts
local function children(m, t, n)
	
	if n == nil then n = 0 end
	n = n + 1
	
	if squapiParts[t] == nil then
		squapiParts[t] = {}
	end
	
	table.insert(squapiParts[t], m)
	
	local c = m:getChildren()
	
	for _, p in ipairs(c) do
		if p:getName() == t..tostring(n+1) then
			children(p, t, n)
		end
	end
	
end

-- Call function
function events.ENTITY_INIT()
	
	children(pokemonParts.NeckLeavesLeft1,  "NeckLeavesLeft")
	children(pokemonParts.NeckLeavesRight1, "NeckLeavesRight")
	children(pokemonParts.LeftEar1,         "LeftEar")
	children(pokemonParts.RightEar1,        "RightEar")
	
end

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Squishy smooth Head + Neck
squapi.smoothHeadNeck(
	pokemonParts.UpperBody,
	pokemonParts.Neck,
	nil,
	0.4,
	false
)

-- Lerp shift table
local water = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

local rot = {
	curr = vec(0, 0),
	prev = vec(0, 0),
	diff = vec(0, 0)
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = player:getRot()
	for k, v in pairs(rot) do
		rot[k] = apply
	end
	
end

-- Ticks lerps
function events.TICK()
	
	-- Target
	water.target = player:isInWater() and 1 or 0
	
	-- Tick lerp
	water.current  = water.nextTick
	water.nextTick = math.lerp(water.nextTick,  water.target,  0.05)
	
end

-- Leaf physics
squapi.leavesY = squapi.bounceObject:new()
squapi.leavesZ = squapi.bounceObject:new()
squapi.ears    = squapi.bounceObject:new()
squapi.headY   = squapi.bounceObject:new()

function events.RENDER(delta, context)
	
	-- Render lerp
	water.currentPos = math.lerp(water.current, water.nextTick, delta)
	
	-- Head rot calcs
	rot.curr = player:getRot(delta)
	rot.diff = rot.prev - rot.curr
	rot.prev = rot.curr
	
	-- Variables
	local vel     = player:getVelocity(delta)
	local dir     = player:getLookDir()
	local fbVel   = player:getVelocity():dot((dir.x_z):normalize())
	local yvel    = squapi.yvel()
	local extend  = pose.swim or pose.elytra or pose.crawl
	local stiff   = math.lerp(0.01, 0.001, water.currentPos)
	local bounce  = math.lerp(0.05, 0.025,  water.currentPos)
	
	-- Rotations
	local leavesRotY = squapi.leavesY.pos
	local leavesRotZ = squapi.leavesZ.pos
	local earsRot    = squapi.ears.pos
	local headYRot   = squapi.headY.pos

	-- Apply
	for _, part in ipairs(squapiParts.NeckLeavesLeft) do
		part:offsetRot(0, (leavesRotY - headYRot) / #squapiParts.NeckLeavesLeft, leavesRotZ / #squapiParts.NeckLeavesLeft)
	end
	for _, part in ipairs(squapiParts.NeckLeavesRight) do
		part:offsetRot(0, (-leavesRotY - headYRot) / #squapiParts.NeckLeavesLeft, -leavesRotZ / #squapiParts.NeckLeavesLeft)
	end
	for _, part in ipairs(squapiParts.LeftEar) do
		part:offsetRot((earsRot - headYRot) / #squapiParts.LeftEar, 0, 0)
	end
	for _, part in ipairs(squapiParts.RightEar) do
		part:offsetRot((earsRot + headYRot) / #squapiParts.RightEar, 0, 0)
	end
	
	-- Targets
	local leavesYTarget = math.clamp((not extend and fbVel or -yvel) * 100, not extend and -90 * math.map(rot.curr.x, -90, 90, -1, 1) or -90, 90)
	local leavesZTarget = math.clamp((extend and fbVel or yvel) * 100, -90, 90)
	local earsTarget    = math.clamp((fbVel * 75) + math.max(yvel * 75, -30) + (-rot.diff.x * 20), -90, 90)
	local headYTarget   = math.clamp(rot.diff.y * 4, -90, 90)
	
	-- Do bounce
	squapi.leavesY:doBounce(leavesYTarget, stiff, bounce)
	squapi.leavesZ:doBounce(leavesZTarget, stiff, bounce)
	squapi.ears:doBounce(earsTarget,       stiff, bounce)
	squapi.headY:doBounce(headYTarget,     stiff, bounce)
	
end

function events.RENDER(delta, context)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `pokemonParts.body` and when sleeping
	for _, group in ipairs(pokemonParts.UpperBody:getChildren()) do
		if group ~= pokemonParts.Body and not pose.sleep then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
end