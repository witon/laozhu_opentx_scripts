local tools = {
    { name = "油门微调", path = "LAOZHU/adjust/ThrTrim.lua" },
}
local focusIndex = 1
local sub = nil
local this

local function closeSub()
    if sub and sub.pageState == 1 then
        LZ_clearTable(sub)
        sub = nil
        collectgarbage()
    end
end

local function run(event, time)
    closeSub()
    if sub then
        sub.run(event, time)
        closeSub()
        return true
    end
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    lcd.drawFilledRectangle(0, 0, LCD_W, hh, FORCE)
    lcd.drawText(0, 0, "model config", LZ_ui.font + LEFT + INVERS)
    for i = 1, #tools do
        local y = hh + 1 + (i - 1) * rs
        local flags = LZ_ui.font
        if focusIndex == i then
            flags = flags + INVERS
        end
        lcd.drawText(2, y, tools[i].name, flags)
    end
    if event == EVT_ENTER_BREAK then
        sub = LZ_runModule(gSDCardDir .. tools[focusIndex].path)
    elseif event == 37 or event == 35 then
        focusIndex = focusIndex + 1
        if focusIndex > #tools then
            focusIndex = 1
        end
    elseif event == 38 or event == 36 then
        focusIndex = focusIndex - 1
        if focusIndex < 1 then
            focusIndex = #tools
        end
    elseif event == EVT_EXIT_BREAK then
        this.pageState = 1
        return false
    end
    return true
end

local function bg()
    closeSub()
    if sub and sub.bg then
        sub.bg()
    end
end

this = { run = run, bg = bg, pageState = 0 }
return this
