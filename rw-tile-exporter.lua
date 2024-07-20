local sprite = app.activeSprite
if not sprite then
    return app.alert("No active sprite found!")
end

local tgNms = {}

for i, tg in ipairs(sprite.tags) do
    table.insert(tgNms, tg.name)
end

local dlg = Dialog { title = "Format to Rain World tilesheet" }
    :file { id = "filename", label = "Result File:", open = false, save = true, filename = sprite.filename }
if next(tgNms) ~= nil then
    dlg:combobox { id = "tag", label = "Tag:", options = tgNms }
end
dlg:number { id = "bTiles", label = "Border Tiles:", text = "0", decimals = 0 }
    :check { id = "layers_as_variants", label = "Split layers as variants:", selected = false }
    :check { id = "preview", label = "Add tile preview space", selected = true }
    :button { id = "confirm", text = "Confirm" }
    :button { id = "cancel", text = "Cancel" }
    :show()

local dlgData = dlg.data

if dlgData.confirm then
    local tlWidth = (sprite.width / 20) - (dlgData.bTiles * 2)
    local tlHeight = (sprite.height / 20) - (dlgData.bTiles * 2)

    if sprite.filename == dlgData.filename then
        return app.alert("Please choose a filename different to the source file")
    end

    app.command.ExportSpriteSheet { ui = false, askOverwrite = false, type = SpriteSheetType.COLUMNS, textureFilename =
        dlgData.filename, openGenerated = true, tag = dlgData.tag, splitLayers = dlgData.layers_as_variants }

    sprite = app.activeSprite

    if dlgData.preview then
        app.command.CanvasSize { ui = false, top = 1, bottom = tlHeight * 16 }
    else
        app.command.CanvasSize { ui = false, top = 1 }
    end


    local bkgLayer = sprite:newLayer()
    bkgLayer.name = "bkg"
    bkgLayer.stackIndex = bkgLayer.stackIndex - 1

    local bkgCel = sprite:newCel(bkgLayer, 1)

    local bkgImg = bkgCel.image:clone()


    local rgba = app.pixelColor.rgba
    for it in bkgImg:pixels() do
        if it.x == 0 and it.y == 0 then
            it(rgba(0, 0, 0, 255))
        else
            it(rgba(255, 255, 255, 255))
        end
    end

    bkgCel.image = bkgImg

    app.refresh()

    app.command.GotoPreviousLayer()

    if dlgData.preview then
        local brush = Brush()
        app.useTool { tool = "rectangle", color = rgba(0, 0, 0, 255), bgColor = rgba(0, 0, 0, 0), brush = brush, points = {
            Point(0, sprite.height - tlHeight * 16), Point(tlWidth * 16 - 1, sprite.height - 1) } }
    end
    --if dlgData.preview then
    --    sprite.selection:select(Rectangle(0, sprite.height - tlHeight * 16, tlWidth * 16, tlHeight * 16))
    --end
end
