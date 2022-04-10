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


text_location = iup.text{expand="HORIZONTAL", id="text_location"}
label_round = iup.label{title="r"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"}
label_group = iup.label{title="1"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"}
label_task = iup.label{title="t"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"}
label_state = iup.label{title="s"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"}
label_time = iup.label{title="time"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"}
btn_browse = iup.button{title="Browse", rastersize="x22",id="btn_browse"}
btn_prev = iup.button{title="Previous", rastersize="x22",id="btn_prev", expand="HORIZONTAL"}
btn_next = iup.button{title="Next", rastersize="x22",id="btn_next", expand="HORIZONTAL"}
text_log = iup.multiline{text="log"; expand="HORIZONTAL"; readonly="YES"}
timer = iup.timer{time=100}
dlg = iup.dialog
{
    iup.vbox
    {
        iup.hbox
        {
            iup.hbox
            {
                iup.label{title="Round:";expand="HORIZONTAL"; ALIGNMENT="ARIGHT"},
                label_round;
                expand="HORIZONTAL"
            },
            iup.hbox
            {
                iup.label{title="Group:"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"},
                label_group;
                expand="HORIZONTAL"
 
            },
            iup.hbox
            {
                iup.label{title="Task:"; expand="HORIZONTAL"; ALIGNMENT="ARIGHT"},
                label_task;
                expand="HORIZONTAL"
            };
            expandchildren="YES";
            expand="HORIZONTAL"
        },
        iup.hbox
        {
            label_state,
            label_time;
            expand="HORIZONTAL"
        },
        iup.hbox
        {
            btn_prev,
            btn_next;
            expand="HORIZONTAL"
        },
        iup.label{title="log:"},
        text_log,
        expandchildren="YES"
    }
    ;title="Glider Competiton Broadcast", size="200x200", margin="10x10"
}

function btn_browse:action()
    local dlg = iup.filedlg{dialogtype="DIR"}
    dlg:popup()
    if dlg.status == "0" then
        text_location.value = dlg.value
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
    text_log.value = str
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
    label_time.title = timeStr
    label_group.title = curGroup
    label_round.title = curRound
    label_state.title = stateDesc
    label_task.title = taskName
end

function btn_prev:action ()
    local competitionState, curRound, curGroup, remainTime, stateDesc, taskName = broadcast.getRoundInfo()
    if competitionState == 2 then
        broadcast.backward()
    end
end

function btn_next:action ()
    local competitionState, curRound, curGroup, remainTime, stateDesc, taskName = broadcast.getRoundInfo()
    if competitionState == 2 then
        broadcast.forward()
    end
end


timer.run = "YES"
dlg:show()
print("hahaha")
iup.MainLoop()