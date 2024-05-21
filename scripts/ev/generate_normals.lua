----------------------------------------------------------------------
-- Generate Normal Map
--
-- It works only for RGB color mode.
----------------------------------------------------------------------

if app.apiVersion < 1 then
    return app.alert("This script requires Aseprite v1.2.10-beta3")
end

local currentCel = app.activeCel
if not currentCel then
    return app.alert("There is no active image")
end

local function processLayer(layer)
    local sprite = app.activeSprite
    local newLayerName = layer.name .. "_NormalGenerated"
    local newLayer = nil
    for i, layer in ipairs(sprite.layers) do
        if layer.name == newLayerName then
            -- the layer to write normal on is already exists
            newLayer = layer
        end
    end
    if newLayer == nil then
        newLayer = sprite:newLayer()
        newLayer.name = newLayerName
    end
    
    for i, cel in ipairs(layer.cels) do
        local frame = cel.frame
    
        local img = cel.image:clone()
        local position = cel.position
    
        if img.colorMode == ColorMode.RGB then
            local rgba = app.pixelColor.rgba
            local rgbaA = app.pixelColor.rgbaA
            for it in img:pixels() do
                local x = it.x
                local y = it.y
                local top = 2
                local left = 2
                local right = 2
                local bottom = 2
                if rgbaA(it()) < 255 then
                    -- Transparent pixel to ignore
                else
                    -- Pixel to prcess
                    -- explore top
                    if y > 0 then
                        -- possible to explore
                        local topPixel = img:getPixel(x, y - 1)
                        if rgbaA(topPixel) < 255 then
                            top = 0
                        elseif y > 1 then
                            topPixel = img:getPixel(x, y - 2)
                            if rgbaA(topPixel) < 255 then
                                top = 1
                            end
                        else
                            top = 1
                        end
                    else
                        top = 0
                    end
                    -- explore bottom
                    if y < img.height - 1 then
                        -- possible to explore
                        local bottomPixel = img:getPixel(x, y + 1)
                        if rgbaA(bottomPixel) < 255 then
                            bottom = 0
                        elseif y < img.height - 2 then
                            bottomPixel = img:getPixel(x, y + 2)
                            if rgbaA(bottomPixel) < 255 then
                                bottom = 1
                            end
                        else
                            bottom = 1
                        end
                    else
                        bottom = 0
                    end
                    -- explore left
                    if x > 0 then
                        -- possible to explore
                        local leftPixel = img:getPixel(x - 1, y)
                        if rgbaA(leftPixel) < 255 then
                            left = 0
                        elseif x > 1 then
                            leftPixel = img:getPixel(x - 2, y)
                            if rgbaA(leftPixel) < 255 then
                                left = 1
                            end
                        else
                            left = 1
                        end
                    else
                        left = 0
                    end
                    -- explore right
                    if x < img.width - 1 then
                        -- possible to explore
                        local rightPixel = img:getPixel(x + 1, y)
                        if rgbaA(rightPixel) < 255 then
                            right = 0
                        elseif x < img.width - 2 then
                            rightPixel = img:getPixel(x + 2, y)
                            if rgbaA(rightPixel) < 255 then
                                right = 1
                            end
                        else
                            right = 1
                        end
                    else
                        right = 0
                    end
                    local light = 0
    
                    -- -2 ~ +2
                    local y_digit = -top + bottom
                    local y = y_digit * 32 + 128
                    local x_digit = -right + left
                    local x = x_digit * 32 + 128
                    local z_digit = math.max(math.abs(x_digit), math.abs(y_digit))
                    local z = z_digit * -32 + 255
                    local color = rgba(x, y, z, 255)
                    it(color)
                end
            end
        elseif img.colorMode == ColorMode.GRAY then
            return app.alert("This script is only for RGB Color Mode")
        elseif img.colorMode == ColorMode.INDEXED then
            return app.alert("This script is only for RGB Color Mode")
        end
        local newCel = sprite:newCel(newLayer, frame, img, position)
    end
end

for i, layer in ipairs(app.range.layers) do
    processLayer(layer)
end
app.refresh()