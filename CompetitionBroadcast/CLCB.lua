gScriptDir = "./"
local fun = loadfile(gScriptDir .. "LAOZHU/comm/PCLoadModule.lua")
fun()
local broadcast = LZ_runModule("CompetitionBroadcast/CompetitionBroadcastCore.lua")
if not broadcast.init() then
    self:send("cm_quit")
    return
end

startKeyReceiver()

while true do
    local ret = broadcast.run()
    if not ret then
        break
    end
    local event = getEvent()
    if event == 77 or event == 67 then
        ret = broadcast.forward()
        if not ret then
            break
        end
    elseif event == 75 or event == 68 then
        broadcast.backward()
    elseif event == 17 or event == 113 then
        broadcast.exit()
        break
    end
end

stopKeyReceiver()