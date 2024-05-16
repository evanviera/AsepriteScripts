-- Import PNG files into an open Aseprite file as new layers.

-- Function to import PNG files
local function importPNGFiles(sprite, directory)
  local files = app.fs.listFiles(directory)
  for i, file in ipairs(files) do
      if file:match("%.png$") then
          local filePath = app.fs.joinPath(directory, file)
          local newSprite = Sprite{ fromFile = filePath }
          if newSprite then
              local newLayer = sprite:newLayer()
              newLayer.name = app.fs.fileTitle(filePath)
              app.command.CopyMerged()
              sprite:newCel(newLayer, 1, Image(newSprite))
              newSprite:close()
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
