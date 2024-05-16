-- Import PNG files into an open Aseprite file as new layers, spaced out based on the defined grid size.

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

              -- Create a new image with the size of the grid cell
              local image = Image(gridWidth, gridHeight)
              image:clear()

              -- Center the newSprite image in the grid cell
              local xOffset = math.floor((gridWidth - newSprite.width) / 2)
              local yOffset = math.floor((gridHeight - newSprite.height) / 2)
              image:drawImage(newSprite.cels[1].image, Point(xOffset, yOffset))

              -- Add the new image to the sprite
              local cel = sprite:newCel(newLayer, 1)
              cel.image = image
              cel.position = Point(col * gridWidth, row * gridHeight)

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

-- Open a dialog to select the directory containing PNG files
local dlg = Dialog("Import PNGs")
dlg:file{
  id = "directory",
  label = "Directory:",
  open = true,
  filename = app.fs.filePath(app.activeSprite.filename)
}
dlg:button{
  id = "ok",
  text = "Import",
  onclick = function()
      local data = dlg.data
      local sprite = app.activeSprite
      if sprite and data.directory then
          app.transaction(function()
              importPNGFiles(sprite, data.directory)
          end)
          app.alert("Import completed successfully!")
      else
          app.alert("No directory selected or no active sprite.")
      end
  end
}
dlg:button{id = "cancel", text = "Cancel"}
dlg:show()
