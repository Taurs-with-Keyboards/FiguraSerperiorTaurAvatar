-- Required scripts
local origins      = require("lib.OriginsAPI")
local pokemonParts = require("lib.GroupIndex")(models.SerperiorTaur)

-- Animations setup
local anims = animations.SerperiorTaur

-- Variable setup
local damage = {
	current    = 10,
	nextTick   = 10,
	target     = 10,
	currentPos = 10
}

function events.TICK()
	
	local hasRider = #player:getPassengers() > 0
	
	if hasRider then
		local coiled = player:getPassengers()[1]
		if coiled:getNbt()["HurtTime"] == 9 then
			damage.target = 0
		end
	end
	
	-- Manipulate tick timer
	damage.target = math.clamp(damage.target + 1, 0, 10)
	
	-- Tick lerps
	damage.current  = damage.nextTick
	damage.nextTick = math.lerp(damage.nextTick, damage.target, 0.5)
	
	anims.coil:playing(hasRider)
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	damage.currentPos = math.lerp(damage.current, damage.nextTick, delta)
	
	anims.coil:blend(math.map(damage.currentPos, 0, 10, 1.1, 1))
	
end