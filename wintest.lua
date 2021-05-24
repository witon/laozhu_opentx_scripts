require("sound")
setSoundPath("d:\\code\\SOUNDS\\")
for i=1, 1000000, 1 do
    for j=1, 100000000, 1 do
    end
    playDuration(i)
    collectgarbage("collect")
    print("mem:", collectgarbage("count")*1024)
end
