local curFileIndex = 1
local this = nil
local compileFiles = nil
--local function init()
    local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
    fun()
    compileFiles = LZ_runModule(gSDCardDir .. "SCRIPTS/CompileFiles.lua")
--end

local function bg()
end

local function run(event, time)
    lcd.clear()
    local rs = LZ_ui.rowStep
    local pathMaxChars = math.max(12, math.floor(LCD_W / 5))
    if curFileIndex > #compileFiles then
        lcd.drawText(1, 2 * rs + 2, "installation completed.", LZ_ui.font+LEFT)
        lcd.drawText(1, 3 * rs + 3, "press exit key to start.", LZ_ui.font+LEFT)
        --lcd.drawText(1, 30, "you must restart the radio", LZ_ui.font+LEFT)
        --lcd.drawText(1, 40, "to use this script.", LZ_ui.font+LEFT)
        if event ~= EVT_EXIT_BREAK then
            return true
        else
            return false
        end
    end
    local rel = compileFiles[curFileIndex]
    local r = rel
    if string.sub(r, 1, 1) == "/" then
        r = string.sub(r, 2)
    end
    local path
    if string.sub(r, 1, 7) == "LAOZHU/" or string.sub(r, 1, 8) == "WIDGETS/" then
        path = gSDCardDir .. r
    else
        path = gSDCardDir .. "SCRIPTS/" .. r
    end
    local fun, err = loadScript(path)
    if fun == nil then
        assert(false, compileFiles[curFileIndex])
    end
    LZ_clearTable(fun)
    fun = nil
    collectgarbage()
    lcd.drawText(1, 2 * rs + 2, "compiling", LZ_ui.font+LEFT)
    lcd.drawText(1, 3 * rs + 3, string.sub(tostring(compileFiles[curFileIndex]), 1, pathMaxChars), LZ_ui.font+LEFT)
    curFileIndex = curFileIndex + 1
    if curFileIndex > #compileFiles then
        LZ_markCompiled()
    end
    return true
end

this = {run=run, init=init, bg=bg, pageState=0}

return this
