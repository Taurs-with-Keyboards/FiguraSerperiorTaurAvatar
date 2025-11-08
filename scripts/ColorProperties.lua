-- Avatar color
avatar:color(vectors.hexToRGB("21A64C"))

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("21A64C"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local c = {}

-- Action variables
c.hover     = vectors.hexToRGB("21A64C")
c.active    = vectors.hexToRGB("EFC435")
c.primary   = "#21A64C"
c.secondary = "#EFC435"

-- Return variables
return c