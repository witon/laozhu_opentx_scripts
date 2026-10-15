local viewMatrix = nil
local this = nil
local plan = nil
local api = nil
local swIdx = {}
local swEd = {}
local lsEd = {}
local gvEd = {}
local lines = {}
local statusText = "统一GV请设FM0"
local maxLines = 1

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrix.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Button.lua")
    plan = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/ThrTrimPlan.lua")
end

local function unloadModule()
    IVunload()
    VMunload()
    NEunload()
    BTunload()
end

local function isPhysicalName(name)
    if string.match(name, "^L%d") then
        return false
    end
    local last = string.sub(name, -1)
    if last == "+" or last == "-" then
        return true
    end
    if string.find(name, CHAR_UP, 1, true) or string.find(name, CHAR_DOWN, 1, true) then
        return true
    end
    return false
end

local function collectSwitches()
    for idx, name in switches() do
        if isPhysicalName(name) then
            swIdx[#swIdx + 1] = idx
        end
    end
end

local function countIdx(getFn)
    local n = 0
    while getFn(n) do
        n = n + 1
    end
    if n < 1 then
        return 1
    end
    return n
end

local function listPos(target)
    if target and target ~= 0 then
        for i = 1, #swIdx do
            if swIdx[i] == target then
                return i
            end
        end
    end
    return 1
end

local function defaultIncDec()
    local plus = {}
    for i = 1, #swIdx do
        local name = getSwitchName(swIdx[i])
        if name and string.sub(name, -1) == "+" then
            plus[#plus + 1] = swIdx[i]
        end
    end
    local up = plus[3]
    if not up then
        return 1, 1
    end
    return listPos(up), listPos(up - 1)
end

local function clamp(n, maxN)
    if n > maxN then
        return maxN
    end
    return n
end

local function drawSw(ed, x, y, invers, option)
    local name = ""
    local idx = swIdx[ed.num]
    if idx then
        name = getSwitchName(idx) or ""
    end
    lcd.drawText(x, y, name, option)
end

local function drawLs(ed, x, y, invers, option)
    lcd.drawText(x, y, "L" .. ed.num, option)
end

local function drawGv(ed, x, y, invers, option)
    lcd.drawText(x, y, "GV" .. ed.num, option)
end

local function newNum(minN, maxN, num, draw)
    local ed = NEnewNumEdit()
    NEsetRange(ed, minN, maxN)
    ed.num = num
    ed.draw = draw
    return ed
end

local function pushRow(label, widget)
    local row = VMaddRow(viewMatrix)
    row[1] = widget
    lines[#lines + 1] = { label, widget }
end

local function onWrite()
    local ok, err = plan.apply(api, {
        ls = { lsEd[1].num - 1, lsEd[2].num - 1, lsEd[3].num - 1, lsEd[4].num - 1 },
        gvEle = gvEd[1].num - 1,
        gvAll = gvEd[2].num - 1,
        swEle = swIdx[swEd[1].num],
        swAll = swIdx[swEd[2].num],
        swInc = swIdx[swEd[3].num],
        swDec = swIdx[swEd[4].num],
    })
    if ok then
        statusText = "已写入 设FM0"
    else
        statusText = err
    end
end

local function doKey(event)
    local ret = viewMatrix.doKey(viewMatrix, event)
    if not ret and event == EVT_EXIT_BREAK then
        this.pageState = 1
        unloadModule()
    end
    return true
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    lcd.drawFilledRectangle(0, 0, LCD_W, hh, FORCE)
    lcd.drawText(0, 0, "油门微调", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(0, hh, statusText, LZ_ui.font + LEFT)
    local y = hh + rs
    local last = math.min(#lines, viewMatrix.scrollLine + maxLines)
    for i = viewMatrix.scrollLine + 1, last do
        lcd.drawText(0, y, lines[i][1], LZ_ui.font + LEFT)
        IVdraw(lines[i][2], LCD_W, y, invers, LZ_ui.font + RIGHT)
        y = y + rs
    end
    return doKey(event)
end

local function bg()
end

loadModule()
collectSwitches()
api = {
    getCustomFunction = model.getCustomFunction,
    setCustomFunction = model.setCustomFunction,
    getLogicalSwitch = model.getLogicalSwitch,
    setLogicalSwitch = model.setLogicalSwitch,
    getFlightMode = model.getFlightMode,
    setFlightMode = model.setFlightMode,
    setGlobalVariableDetails = model.setGlobalVariableDetails,
    getSwitchIndex = getSwitchIndex,
}

local swMax = #swIdx
if swMax < 1 then
    swMax = 1
end
local maxLs = countIdx(model.getLogicalSwitch)
local maxGv = countIdx(model.getGlobalVariableDetails)
local incPos, decPos = defaultIncDec()

viewMatrix = VMnewViewMatrix()
swEd[1] = newNum(1, swMax, listPos(getSwitchIndex("SH" .. CHAR_UP)), drawSw)
swEd[2] = newNum(1, swMax, listPos(getSwitchIndex("SH" .. CHAR_DOWN)), drawSw)
swEd[3] = newNum(1, swMax, incPos, drawSw)
swEd[4] = newNum(1, swMax, decPos, drawSw)
pushRow("升降条件", swEd[1])
pushRow("统一条件", swEd[2])
pushRow("加", swEd[3])
pushRow("减", swEd[4])
for i = 1, 4 do
    lsEd[i] = newNum(1, maxLs, clamp(7 + i, maxLs), drawLs)
    pushRow("槽" .. i, lsEd[i])
end
gvEd[1] = newNum(1, maxGv, clamp(2, maxGv), drawGv)
gvEd[2] = newNum(1, maxGv, clamp(8, maxGv), drawGv)
pushRow("GV升降", gvEd[1])
pushRow("GV统一", gvEd[2])
local btn = BTnewButton()
btn.text = "写入"
BTsetOnClick(btn, onWrite)
pushRow("", btn)

local hh = LZ_ui.headerRowHeight
local rs = LZ_ui.rowStep
maxLines = math.max(1, math.floor((LCD_H - hh - rs) / rs))
viewMatrix.visibleRows = maxLines
viewMatrix.selectedRow = 1
viewMatrix.selectedCol = 1
viewMatrix.scrollLine = 0
IVsetFocusState(viewMatrix.matrix[1][1], 1)

this = { run = run, bg = bg, pageState = 0 }
return this
