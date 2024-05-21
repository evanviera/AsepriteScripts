local spr = app.activeSprite
if not spr then
  app.alert("There is no active sprite")
  return
end

local function getPixel(image, x, y)
  if x < 0 or x >= image.width or y < 0 or y >= image.height then
    return 0
  else
    return image:getPixel(x, y)
  end
end

local function createNormalMapLayer(heightMap, layerName, scaleFactor, tileable, tileWidth, tileHeight)
  local normalMap = Image(heightMap.width, heightMap.height, ColorMode.RGB)
  local layer = spr:newLayer()
  layer.name = layerName .. "_Normals"
  local cel = spr:newCel(layer, 1, normalMap)

  for y = 0, heightMap.height - 1 do
    for x = 0, heightMap.width - 1 do
      local pixel = getPixel(heightMap, x, y)
      local alpha = app.pixelColor.rgbaA(pixel)
      if alpha == 0 then
        normalMap:putPixel(x, y, app.pixelColor.rgba(0, 0, 0, 0))
      else
        local hC = app.pixelColor.rgbaR(pixel) / 255.0
        local hL = app.pixelColor.rgbaR(getPixel(heightMap, (x - 1 + tileWidth) % tileWidth, y)) / 255.0
        local hR = app.pixelColor.rgbaR(getPixel(heightMap, (x + 1) % tileWidth, y)) / 255.0
        local hU = app.pixelColor.rgbaR(getPixel(heightMap, x, (y - 1 + tileHeight) % tileHeight)) / 255.0
        local hD = app.pixelColor.rgbaR(getPixel(heightMap, x, (y + 1) % tileHeight)) / 255.0

        local dx = (hR - hL) * 0.5 * scaleFactor
        local dy = (hD - hU) * 0.5 * scaleFactor

        local nx = dx
        local ny = dy
        local nz = 1.0

        local len = math.sqrt(nx * nx + ny * ny + nz * nz)
        nx, ny, nz = nx / len, ny / len, nz / len

        -- Convert to color (0 to 255 range and shift to 128 base)
        local r = math.floor((nx * 127.5) + 127.5)
        local g = math.floor((ny * 127.5) + 127.5)
        local b = math.floor((nz * 127.5) + 127.5)

        normalMap:putPixel(x, y, app.pixelColor.rgba(r, g, b, alpha))
      end
    end
  end

  cel.image = normalMap
  app.refresh()
end

local function main()
  if app.range.type ~= RangeType.LAYERS then
    app.alert("You need to select a layer")
    return
  end

  local srcLayer = app.activeLayer
  if srcLayer.isGroup then
    app.alert("Please select a non-group layer")
    return
  end

  local cel = app.activeCel
  if not cel then
    app.alert("The selected layer has no image")
    return
  end

  -- Prompt the user for the scale factor and tileable option
  local dlg = Dialog("Normal Map Settings")
  dlg:number{ id="scaleFactor", label="Scale Factor", text="1.0" }
  dlg:check{ id="tileable", label="Tileable", selected=false }
  dlg:number{ id="tileWidth", label="Tile Width", text=tostring(cel.image.width) }
  dlg:number{ id="tileHeight", label="Tile Height", text=tostring(cel.image.height) }
  dlg:button{ id="ok", text="OK" }
  dlg:button{ id="cancel", text="Cancel" }
  dlg:show()

  local data = dlg.data
  if not data.ok then
    return
  end

  local scaleFactor = data.scaleFactor
  if scaleFactor <= 0 then
    app.alert("Scale factor must be greater than 0")
    return
  end

  local tileable = data.tileable
  local tileWidth = data.tileWidth
  local tileHeight = data.tileHeight

  if tileWidth <= 0 or tileHeight <= 0 then
    app.alert("Tile width and height must be greater than 0")
    return
  end

  local srcImage = cel.image:clone()

  createNormalMapLayer(srcImage, srcLayer.name, scaleFactor, tileable, tileWidth, tileHeight)
end

do
  main()
end
