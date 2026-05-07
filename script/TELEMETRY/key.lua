gScriptDir = "/SCRIPTS/"

local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()

local eventHistory = {}
local maxHistorySize = 12
local lastEventTime = 0

LZ_runModule("TELEMETRY/common/keyMap.lua")
local keyMap = KMgetKeyMap()
KMunload()

local function addEventToHistory(rawEvent, mappedEvent)
    local currentTime = getTime()
    local timeStr = string.format("%02d:%02d", math.floor(currentTime / 6000) % 60, math.floor(currentTime / 100) % 60)
    
    local eventEntry = {
        raw = rawEvent,
        mapped = mappedEvent,
        time = timeStr
    }
    
    -- 手动向前移动数组元素
    for i = maxHistorySize, 2, -1 do
        eventHistory[i] = eventHistory[i-1]
    end
    eventHistory[1] = eventEntry
    
    -- 确保数组大小不超过限制
    for i = maxHistorySize + 1, #eventHistory do
        eventHistory[i] = nil
    end
end

local function background()
end

local function run(event)
    lcd.clear()
    
    local ver, radio = getVersion()
    lcd.drawText(1, 1, "Ver:" .. string.sub(ver, 1, 4) .. " Radio:" .. radio, SMLSIZE)
    
    lcd.drawText(1, 10, "ENTER:" .. tostring(EVT_ENTER_BREAK) .. " EXIT:" .. tostring(EVT_EXIT_BREAK), SMLSIZE)
    
    if event ~= 0 then
        local mappedEvent = keyMap[event] or event
        addEventToHistory(event, mappedEvent)
    end
    
    lcd.drawText(1, 19, "Raw -> Mapped  Time", SMLSIZE)
    
    for i = 1, math.min(#eventHistory, 10) do
        local entry = eventHistory[i]
        local y = 26 + (i - 1) * 7
        local text = string.format("%d -> %d     %s", entry.raw, entry.mapped, entry.time)
        lcd.drawText(1, y, text, SMLSIZE)
    end
    
    if #eventHistory == 0 then
        lcd.drawText(1, 30, "Press any key...", SMLSIZE)
    end
    
    if event == EVT_EXIT_BREAK then
        return 2
    end
end

return {run=run, background=background}