-- Lua Script for Aseprite to Select All Tiles of a Specific Tile Index
-- Prompts the user to input the target tile index at runtime

-- Create a dialog to prompt the user for the tile index
local dlg = Dialog("Tile Index Selection")
dlg:label{ text="Enter the tile index to select:" }
dlg:number{ id="tile_index", label="Tile Index:", text="0" }
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }

-- Show dialog and validate input
dlg:show()

-- Ensure the dialog was not closed without proper input
if not dlg.data or dlg.data.tile_index == nil then
  app.alert("Operation cancelled or invalid input. Please enter a valid non-negative integer.")
  return
end

-- Get the data entered by the user
local data = dlg.data
if not data or type(data.tile_index) ~= "number" or data.tile_index < 0 or math.floor(data.tile_index) ~= data.tile_index then
  app.alert("Operation cancelled or invalid input. Please enter a valid non-negative integer.")
  return
end

local TARGET_TILE_INDEX = math.floor(data.tile_index)

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
local tilemap
if cel.image then
  tilemap = cel.image
else
  app.alert("Invalid or null cel image detected!")
  return
end

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

-- Create a new selection object
sprite.selection = Selection()
local selection = sprite.selection

-- Pre-compute constants for optimization
local pixelXBase = celOffsetX
local pixelYBase = celOffsetY
local tilemapWidth = tilemap.width
local tilemapHeight = tilemap.height

-- Initialize rectangles table
local rectangles = {}

-- Batch rectangles to minimize individual operations
local batchStartX, batchEndX = nil, nil
local tileCount = 0
local startTime = os.clock()
for y = 0, tilemapHeight - 1 do
  local pixelY = y * tileHeight + pixelYBase
  batchStartX, batchEndX = nil, nil
  for x = 0, tilemapWidth - 1 do
    local tileIndex = tilemap:getPixel(x, y)
    if tileIndex == TARGET_TILE_INDEX then
      if not batchStartX then
        batchStartX = x
      end
      batchEndX = x
    elseif batchStartX and batchEndX then
      local pixelXStart = batchStartX * tileWidth + pixelXBase
      local pixelXEnd = (batchEndX + 1) * tileWidth + pixelXBase
      table.insert(rectangles, Rectangle(pixelXStart, pixelY, pixelXEnd - pixelXStart, tileHeight))
      tileCount = tileCount + (batchEndX - batchStartX + 1)
      batchStartX, batchEndX = nil, nil
    end
  end
  if batchStartX and batchEndX then
    local pixelXStart = batchStartX * tileWidth + pixelXBase
    local pixelXEnd = (batchEndX + 1) * tileWidth + pixelXBase
    table.insert(rectangles, Rectangle(pixelXStart, pixelY, pixelXEnd - pixelXStart, tileHeight))
    tileCount = tileCount + (batchEndX - batchStartX + 1)
  end
end

-- Add all rectangles to the selection at once
for _, rect in ipairs(rectangles) do
  selection:add(rect)
end

-- Apply the selection to the sprite
sprite.selection = selection

-- Notify the user
local endTime = os.clock()
local elapsedTime = endTime - startTime
if tileCount > 0 then
  app.alert("Selection of tiles with index " .. TARGET_TILE_INDEX .. " completed in " .. string.format("%.2f", elapsedTime) .. " seconds. Total tiles selected: " .. tileCount)
else
  app.alert("No tiles with index " .. TARGET_TILE_INDEX .. " were found. Process completed in " .. string.format("%.2f", elapsedTime) .. " seconds.")
end
