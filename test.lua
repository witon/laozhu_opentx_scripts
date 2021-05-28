require("sound")
setSoundPath("/home/witon/code/SOUNDS/")
--for i=1, 1000000, 1 do
while true do
    for j=1, 1000, 1 do
    end
    --playDuration(i)
    --collectgarbage("collect")
    --print("mem:", collectgarbage("count")*1024)
    local event = getEvent()
    if event > 0 then
        print("event:", event)
    end
end
