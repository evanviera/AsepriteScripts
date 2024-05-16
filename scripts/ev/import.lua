-- Import PNG files into an open Aseprite file as new layers, spaced out based on the defined grid size without cropping smaller images.

-- Function to import PNG files
local function importPNGFiles(sprite, directory)
  local files = app.fs.listFiles(directory)
  local gridWidth, gridHeight = sprite.gridBounds.width, sprite.gridBounds.height
  local col, row = 0, 0

  for i, file in ipairs(files) do
      if file:match("%.png$") then
          local filePath = app.fs.joinPath(directory, file)
          local newSprite = Sprite{ fromFile = filePath }
          if newSprite then
              local newLayer = sprite:newLayer()
              newLayer.name = app.fs.fileTitle(filePath)

              -- Determine the position to center the image within the grid cell
              local xOffset = math.max(0, math.floor((gridWidth - newSprite.width) / 2))
              local yOffset = math.max(0, math.floor((gridHeight - newSprite.height) / 2))

              -- Add the new image to the sprite
              local cel = sprite:newCel(newLayer, 1)
              cel.image = newSprite.cels[1].image
              cel.position = Point(col * gridWidth + xOffset, row * gridHeight + yOffset)

              newSprite:close()

              -- Update column and row for the next image
              col = col + 1
              if col * gridWidth >= sprite.width then
                  col = 0
                  row = row + 1
              end
          else
              app.alert("Error loading file: " .. filePath)
          end
      end
  end
end

-- Function to start the import process
local function startImport()
  local sprite = app.activeSprite
  if sprite then
      local directory = app.fs.filePath(sprite.filename)
      app.transaction(function()
          importPNGFiles(sprite, directory)
      end)
      app.alert("Import completed successfully!")
  else
      app.alert("No active sprite.")
  end
end

-- Start the import process directly
startImport()
