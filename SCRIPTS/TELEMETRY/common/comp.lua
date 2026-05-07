local curFileIndex = 1
local this = nil
local compileFiles = nil
--local function init()
    local fun, err = loadScript(gSDCardDir .. "SCRIPTS/TELEMETRY/common/LoadModule.lua", "bt")
    fun()
    compileFiles = LZ_runModule(gSDCardDir .. "SCRIPTS/CompileFiles.lua")
--end

local function bg()
end

local function run(event, time)
    lcd.clear()
    if curFileIndex > #compileFiles then
        lcd.drawText(1, 20, "installation completed.", SMLSIZE+LEFT)
        lcd.drawText(1, 30, "press exit key to start.", SMLSIZE+LEFT)
        --lcd.drawText(1, 30, "you must restart the radio", SMLSIZE+LEFT)
        --lcd.drawText(1, 40, "to use this script.", SMLSIZE+LEFT)
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
    local path = (string.sub(r, 1, 7) == "LAOZHU/") and (gSDCardDir .. r) or (gSDCardDir .. "SCRIPTS/" .. r)
    local fun, err = loadScript(path)
    if fun == nil then
        assert(false, compileFiles[curFileIndex])
    end
    LZ_clearTable(fun)
    fun = nil
    collectgarbage()
    lcd.drawText(1, 20, "compiling", SMLSIZE+LEFT)
    lcd.drawText(1, 30, compileFiles[curFileIndex], SMLSIZE+LEFT)
    curFileIndex = curFileIndex + 1
    if curFileIndex > #compileFiles then
        LZ_markCompiled()
    end
    return true
end

this = {run=run, init=init, bg=bg, pageState=0}

return this
