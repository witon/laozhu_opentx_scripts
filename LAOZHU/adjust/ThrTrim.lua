local viewMatrix = nil
local this = nil
local plan = nil
local api = nil
local swIdx = {}
local swEd = {}
local lsEd = {}
local gvEd = {}
local lines = {}
local statusText = "cmn: set FM0"
local maxLines = 1
local cfg = nil
local CFG_FILE = "thrtrim.cfg"

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

local function clamp(n, maxN)
    if n < 1 then
        return 1
    end
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

local function saveCfg()
    cfg.kvs.ele = swIdx[swEd[1].num] or 0
    cfg.kvs.cmn = swIdx[swEd[2].num] or 0
    cfg.kvs.inc = swIdx[swEd[3].num] or 0
    cfg.kvs.dec = swIdx[swEd[4].num] or 0
    cfg.kvs.ls1 = lsEd[1].num
    cfg.kvs.ls2 = lsEd[2].num
    cfg.kvs.ls3 = lsEd[3].num
    cfg.kvs.ls4 = lsEd[4].num
    cfg.kvs.gve = gvEd[1].num
    cfg.kvs.gvc = gvEd[2].num
    cfg:writeToFile(CFG_FILE)
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
        statusText = "wrote, set FM0"
        saveCfg()
    else
        statusText = err
    end
end

local function doKey(event)
    local ret = viewMatrix.doKey(viewMatrix, event)
    if not ret and event == EVT_EXIT_BREAK then
        saveCfg()
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
    lcd.drawText(0, 0, "thr trim", LZ_ui.font + LEFT + INVERS)
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
local swList = {}
for i = 1, #swIdx do
    swList[i] = { idx = swIdx[i], name = getSwitchName(swIdx[i]) }
end
local thrUp, thrDown = plan.throttleTrim(swList)
local incFallback = 1
local decFallback = 1
if thrUp then
    incFallback = listPos(thrUp)
    decFallback = listPos(thrDown)
end
local eleFallback = listPos(getSwitchIndex("SH" .. CHAR_UP))
local cmnFallback = listPos(getSwitchIndex("SH" .. CHAR_DOWN))

cfg = CFGC:new()
cfg:readFromFile(CFG_FILE)

local function savedSw(key, fallbackPos)
    local id = cfg:getNumberField(key, swIdx[fallbackPos] or 0)
    if id == 0 then
        return fallbackPos
    end
    for i = 1, #swIdx do
        if swIdx[i] == id then
            return i
        end
    end
    return fallbackPos
end

local function savedNum(key, fallback, maxN)
    local n = cfg:getNumberField(key, fallback)
    if n == 0 then
        n = fallback
    end
    return clamp(n, maxN)
end

viewMatrix = VMnewViewMatrix()
swEd[1] = newNum(1, swMax, savedSw("ele", eleFallback), drawSw)
swEd[2] = newNum(1, swMax, savedSw("cmn", cmnFallback), drawSw)
swEd[3] = newNum(1, swMax, savedSw("inc", incFallback), drawSw)
swEd[4] = newNum(1, swMax, savedSw("dec", decFallback), drawSw)
pushRow("ele sw", swEd[1])
pushRow("cmn sw", swEd[2])
pushRow("inc", swEd[3])
pushRow("dec", swEd[4])
for i = 1, 4 do
    lsEd[i] = newNum(1, maxLs, savedNum("ls" .. i, 7 + i, maxLs), drawLs)
    pushRow("ls" .. i, lsEd[i])
end
gvEd[1] = newNum(1, maxGv, savedNum("gve", 2, maxGv), drawGv)
gvEd[2] = newNum(1, maxGv, savedNum("gvc", 8, maxGv), drawGv)
pushRow("gv ele", gvEd[1])
pushRow("gv cmn", gvEd[2])
local btn = BTnewButton()
btn.text = "write"
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
