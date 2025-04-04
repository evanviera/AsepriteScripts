--[[

Description:
This script takes all frames of the current document and creates a new document
where those frames are arranged horizontally (side by side) in a single frame.

Usage:
1. Open a sprite with multiple frames
2. Run this script
3. A new document will be created with all frames arranged horizontally

Author: Evan Viera
--]]

function framesToRow()
    -- Get the active sprite
    local sourceSprite = app.activeSprite
    if not sourceSprite then
        app.alert("No active sprite. Please open a sprite with frames first.")
        return
    end
    
    -- Get frame count and dimensions
    local frameCount = #sourceSprite.frames
    if frameCount <= 1 then
        app.alert("The sprite needs at least 2 frames to create a row.")
        return
    end
    
    -- Calculate dimensions for the new sprite
    local frameWidth = sourceSprite.width
    local frameHeight = sourceSprite.height
    local totalWidth = frameWidth * frameCount
    
    -- Create a new sprite with the calculated dimensions
    local newSprite = Sprite{
        width = totalWidth,
        height = frameHeight,
        colorMode = sourceSprite.colorMode
    }
    
    -- Copy the palette if needed
    if sourceSprite.colorMode ~= ColorMode.RGB then
        for i=0,#sourceSprite.palettes[1]-1 do
            newSprite.palettes[1]:setColor(i, sourceSprite.palettes[1]:getColor(i))
        end
    end
    
    -- Create single image for the result
    local resultImage = Image(totalWidth, frameHeight, sourceSprite.colorMode)
    
    app.transaction(function()
        -- For each frame in the source sprite
        for i, frame in ipairs(sourceSprite.frames) do
            -- Calculate where to place this frame
            local xOffset = (i - 1) * frameWidth
            
            -- Create a blank image for this frame
            local frameImage = Image(frameWidth, frameHeight, sourceSprite.colorMode)
            
            -- Render all visible layers at this frame to the frame image
            for _, layer in ipairs(sourceSprite.layers) do
                -- Only process visible layers
                if layer.isVisible then
                    -- Get the cel at this frame
                    local cel = layer:cel(frame.frameNumber)
                    
                    -- If there's content on this layer at this frame
                    if cel then
                        -- Draw the cel to our frame image
                        frameImage:drawImage(cel.image, cel.position.x, cel.position.y)
                    end
                end
            end
            
            -- Copy this frame to the result image
            resultImage:drawImage(frameImage, xOffset, 0)
        end
        
        -- Add the image to the destination sprite
        local layer = newSprite.layers[1]
        local cel = newSprite:newCel(layer, 1)
        cel.image = resultImage
    end)
    
    -- Show the new sprite
    app.activeSprite = newSprite
    app.refresh()
    app.alert("Created new sprite with frames arranged horizontally.")
end

-- Start the process
framesToRow() 