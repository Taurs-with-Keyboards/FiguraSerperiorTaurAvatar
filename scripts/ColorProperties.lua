-- Avatar color
avatar:color(vectors.hexToRGB("21A64C"))

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("21A64C"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local colors = {}

-- Action variables
colors.hover     = vectors.hexToRGB("21A64C")
colors.active    = vectors.hexToRGB("EFC435")
colors.primary   = "#21A64C"
colors.secondary = "#EFC435"

-- Return variables
return colors