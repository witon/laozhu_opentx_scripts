require "iuplua"

gScriptDir = "./"
    local fun = loadfile(gScriptDir .. "LAOZHU/comm/PCLoadModule.lua")
fun()
LZ_runModule("LAOZHU/Queue.lua")
local logQueue = QUEnewQueue(20)
local broadcast = LZ_runModule("CompetitionBroadcast/CompetitionBroadcastCore.lua")

if not broadcast.init() then
    return
end


local labelRound = iup.label{title="r", expand="HORIZONTAL", ALIGNMENT="ALEFT", font="a, 18"}
local labelGroup = iup.label{title="1", expand="HORIZONTAL", ALIGNMENT="ALEFT", font="a, 18"}
local labelTask = iup.label{title="t", expand="HORIZONTAL", ALIGNMENT="ALEFT", font="a, 18"}
local labelState = iup.label{title="s", expand="HORIZONTAL", ALIGNMENT="ARIGHT", font="a, 25"}
local labelTime = iup.label{title="time", expand="HORIZONTAL", ALIGNMENT="ARIGHT", font="Arial, -100"}
local btnPrev = iup.button{title="Previous", id="btnPrev", expand="HORIZONTAL", font="a, 15"}
local btnNext = iup.button{title="Next", id="btnNext", expand="HORIZONTAL", font="a, 15"}
local btnQuit = iup.button{title="Quit", id="btnQuit", expand="HORIZONTAL", font="a, 15"}
local textLog = iup.multiline{text="log", expand="YES", size="x1", readonly="YES", multiline="YES"}
local timer = iup.timer{time=100}
dlg = iup.dialog
{
    MENUBOX=NO, MAXBOX=NO ,MINBOX=NO;
    iup.vbox
    {
        iup.backgroundbox
        {
            iup.vbox
            {
                iup.hbox
                {
                    iup.label{title="Round: ", ALIGNMENT="ALEFT", expand="HORIZONTAL", font="a, 18"},
                        labelRound,
                        iup.fill{},
                        iup.fill{},
                        iup.label{title="Group: ", ALIGNMENT="ALEFT", expand="HORIZONTAL", font="a, 18"},
                        labelGroup;
                        expand="HORIZONTAL"
                },
                iup.hbox
                {
                    iup.label{title="Task: ", ALIGNMENT="ALEFT", expand="NO", font="a, 18"},
                    labelTask;
                    expand="HORIZONTAL"
                }

            };
            expand="HORIZONTAL",
            border="YES"
        },

        iup.backgroundbox
        {
            iup.vbox
            {
                labelState,
                labelTime
            };
            bgcolor="255 255 255"

        },

        iup.hbox
        {
            btnPrev,
            btnNext,
            btnQuit;
            expand="HORIZONTAL"
        },
        textLog;
        alignment="atop"
    };
    title="Glider Competiton Broadcast", clientsize="325x510", margin="10x10", CHILDOFFSET="0x25" , font="a, 15"
}

function btnQuit:action()
    r = iup.Alarm("Confirm", "Quit broadcast now?", "Yes", "No")
    if r == 1 then
        return iup.CLOSE
    else
        return iup.IGNORE
    end
end

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
    textLog.value = str
end

local function formatTime(time)
    local minute = math.floor(time / 60)
    local second= time % 60
    local str = string.format("%02d:%02d", minute, second)
    return str
end

function timer:action_cb()
    local ret = broadcast.run()
    local competitionState, curRound, curGroup, remainTime, stateDesc, taskName = broadcast.getRoundInfo()
    local timeStr = formatTime(remainTime)
    labelTime.title = timeStr
    labelGroup.title = curGroup
    labelRound.title = curRound
    labelState.title = stateDesc
    labelTask.title = taskName
end

function btnPrev:action ()
    local competitionState, curRound, curGroup, remainTime, stateDesc, taskName = broadcast.getRoundInfo()
    if competitionState == 2 then
        broadcast.backward()
    end
end

function btnNext:action ()
    local competitionState, curRound, curGroup, remainTime, stateDesc, taskName = broadcast.getRoundInfo()
    if competitionState == 2 then
        broadcast.forward()
    end
end


timer.run = "YES"
dlg:show()
iup.MainLoop()
