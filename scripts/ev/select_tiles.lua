-- Lua Script for Aseprite to Select All Tiles of a Specific Tile Index
-- Set the tile index you want to select in the `TARGET_TILE_INDEX` variable

-- Define the target tile index to select
local TARGET_TILE_INDEX = 2  -- Change this to the desired tile index

-- Access the active sprite
local sprite = app.activeSprite
if not sprite then
  app.alert("No active sprite found!")
  return
end

-- Access the active layer
local layer = app.activeLayer
if not layer or not layer.isTilemap then
  app.alert("Please select a tilemap layer!")
  return
end

-- Access the active cel
local cel = layer:cel(app.activeFrame.frameNumber)
if not cel then
  app.alert("No active cel in the selected layer!")
  return
end

-- Get the tilemap and tileset
local tilemap = Image(cel.image)
local tileset = layer.tileset
if not tileset then
  app.alert("No tileset found in the selected tilemap layer!")
  return
end

-- Get tile size from the tileset
local tileWidth = tileset.grid.tileSize.width
local tileHeight = tileset.grid.tileSize.height

-- Get the cel's position offset
local celOffsetX = cel.position.x
local celOffsetY = cel.position.y

-- Create a selection object
local selection = Selection()

-- Iterate through each tile in the tilemap
for y = 0, tilemap.height - 1 do
  for x = 0, tilemap.width - 1 do
    local tileIndex = tilemap:getPixel(x, y)
    if tileIndex == TARGET_TILE_INDEX then
      -- Adjust the selection to account for tile size and cel offset
      local pixelX = x * tileWidth + celOffsetX
      local pixelY = y * tileHeight + celOffsetY
      selection:add(Rectangle(pixelX, pixelY, tileWidth, tileHeight))
    end
  end
end

-- Apply the selection to the sprite
sprite.selection = selection

-- Notify the user
do
  app.alert("Selection of tiles with index " .. TARGET_TILE_INDEX .. " completed.")
end
