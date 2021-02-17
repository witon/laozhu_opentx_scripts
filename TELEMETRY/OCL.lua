gScriptDir = "/SCRIPTS/"

local outputCurvePage = nil
local adjustChannels = {1, 2, 3, 4, 5}
local bgFlag = false


local function loadOutputCurvePage()
    if outputCurvePage then
        return
    end
    outputCurvePage = LZ_runModule(gScriptDir .. "TELEMETRY/adjust/OutputCurve.lua")
    outputCurvePage.init()
    outputCurvePage.setSelectedChannels(adjustChannels)
end

local function unloadOutputCurvePage()
    if outputCurvePage == nil then
        return
    end
    LZ_clearTable(outputCurvePage)
    outputCurvePage = nil
end


local function background()
    if outputCurvePage and outputCurvePage.pageState == 1 then
        unloadOutputCurvePage()
    end

    if not bgFlag then
        bgFlag = true
        return
    else
        if outputCurvePage then
            outputCurvePage.bg()
            print("--------bg")
        end
    end
end

local function init()
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
    LZ_runModule(gScriptDir .. "LAOZHU/utils.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
    loadOutputCurvePage()
end

local function run(event)
    bgFlag = false
    lcd.clear()
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    if outputCurvePage == nil then
        loadOutputCurvePage()
    end
    outputCurvePage.run(event, getTime())
end

return {run=run, init=init, background=background}