gScriptDir = "./"
local fun = loadfile(gScriptDir .. "LAOZHU/comm/PCLoadModule.lua")
fun()
LZ_runModule("LAOZHU/Queue.lua")

local logQueue = QUEnewQueue(20)
local ltui        = require("ltui")
local application = ltui.application
local event       = ltui.event
local rect        = ltui.rect
local window      = ltui.window
local label       = ltui.label

local main = application()
local broadcast = LZ_runModule("CompetitionBroadcast/CompetitionBroadcastCore.lua")
local mainWindow = nil

function print(...)
    local line = ""
    for i, v in ipairs{...} do
        if i==1 then
            line = v
        else
            line = line .. "\t" .. v
        end
    end
    QUEadd(logQueue, line)
    local str = ""
    for i=QUEcount(logQueue), 1, -1 do
        str = str .. QUEget(logQueue, i) .. "\n"
    end
    --if main:logLabel() then
    if mainWindow then
        mainWindow:logLabel():text_set(str)
    end
    --end
end


-- init main
function main:init()
    mainWindow = self
    application.init(self, "main")

    self:background_set("black")

    self:insert(self:desktop())
    self:desktop():background_set("black")

    self:desktop():insert(self:roundInfo())
    self:desktop():insert(self:roundState())
    self:desktop():insert(self:logLabel())
    if not broadcast.init() then
        self:send("cm_quit")
        return
    end


end

function main:logLabel()
    if not self._LOG_LABEL then
        self._LOG_LABEL = label:new('main.log', rect {0, 4, 40, 100}, 'this is a test')
    end
    self._LOG_LABEL:textattr_set("white")
    return self._LOG_LABEL
end

function main:roundState()
    if not self._ROUND_STATE then
        self._ROUND_STATE = label:new('main.roundState', rect {0, 1, 40, 2}, 'state')
    end
    self._ROUND_STATE:textattr_set("white")
    return self._ROUND_STATE
end

function main:roundInfo()
    if not self._ROUND_INFO then
        self._ROUND_INFO = label:new('main.round_info', rect {0, 0, 40, 1}, 'round info')
    end
    self._ROUND_INFO:textattr_set("white")
    return self._ROUND_INFO
end


-- on resize
function main:on_resize()
    self:desktop():bounds_set(rect {1, 1, self:width() - 1, self:height() - 1})
    application.on_resize(self)
end

-- on event
local c = 1
local function formatTime(time)
	local minute = math.floor(time / 60)
	local second= time % 60
	local str = string.format("%02d:%02d", minute, second)
	return str
end

function main:on_event(e)
    local ret = broadcast.run()
    local competitionState, curRound, curGroup, remainTime, stateDesc, taskName = broadcast.getRoundInfo()
    local timeStr = formatTime(remainTime)
    local roundInfo = string.format("round: %d  group: %d  task: %s", curRound, curGroup, taskName)
    self:roundInfo():text_set(roundInfo)
    local roundStateStr = string.format("%s: %s", stateDesc, timeStr)
    self:roundState():text_set(roundStateStr)
	
    if e.type < event.ev_max then
        if e.key_name == "Right" then
            if competitionState == 2 then
                broadcast.forward()
            end
        elseif e.key_name == "Left" then
            if competitionState == 2 then
                broadcast.backward()
            end
        elseif e.key_name == "Esc" then
            broadcast.exit()
            self:send("cm_quit")
        end
    end
    application.on_event(self, e)
end

main:run()