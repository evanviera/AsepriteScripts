local spr = app.activeSprite
if not spr then
  app.alert("There is no active sprite")
  return
end

local function getPixel(image, x, y)
  if x < 0 or x >= image.width or y < 0 or y >= image.height then
    return 0
  else
    return app.pixelColor.rgbaR(image:getPixel(x, y))
  end
end

local function createNormalMapLayer(heightMap)
  local normalMap = Image(heightMap.width, heightMap.height, ColorMode.RGB)
  local layer = spr:newLayer()
  layer.name = "Normal Map"
  local cel = spr:newCel(layer, 1, normalMap)

  for y = 0, heightMap.height - 1 do
    for x = 0, heightMap.width - 1 do
      local hC = getPixel(heightMap, x, y) / 255.0
      local hL = getPixel(heightMap, x - 1, y) / 255.0
      local hR = getPixel(heightMap, x + 1, y) / 255.0
      local hU = getPixel(heightMap, x, y - 1) / 255.0
      local hD = getPixel(heightMap, x, y + 1) / 255.0

      local dx = (hR - hL) * 0.5
      local dy = (hD - hU) * 0.5

      local nx = dx
      local ny = dy
      local nz = 1.0

      local len = math.sqrt(nx * nx + ny * ny + nz * nz)
      nx, ny, nz = nx / len, ny / len, nz / len

      -- Convert to color (0 to 255 range and shift to 128 base)
      local r = math.floor((nx * 127.5) + 127.5)
      local g = math.floor((ny * 127.5) + 127.5)
      local b = math.floor((nz * 127.5) + 127.5)

      normalMap:putPixel(x, y, app.pixelColor.rgba(r, g, b))
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

  local srcImage = cel.image:clone()

  createNormalMapLayer(srcImage)
end

do
  main()
end