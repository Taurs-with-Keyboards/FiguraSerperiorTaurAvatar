-- Required scripts
local parts     = require("lib.PartsAPI")
local trailTail = require("lib.trail_tail")

-- Apply tail
local tail = trailTail.new(parts.group.Tail1)
tail:setConfig({
	floorFriction = 0.5,
	collisionOffsets = {
		vec(0, -3.5, 0),
		vec(0, -4.5, 0),
		vec(0, -4.5, 0),
		vec(0, -4, 0),
		vec(0, -4, 0),
		vec(0, -3.5, 0),
		vec(0, -2.5, 0),
		vec(0, -2, 0),
		vec(0, -1.5, 0)
	}
})
logTable(tail.config)