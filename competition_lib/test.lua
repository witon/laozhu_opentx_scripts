require("sound")
setSoundPath("/home/witon/code/SOUNDS/")
local ret = initPandoraPort("COM6")
local isPortOpen = ret
print("init ret:", ret)
--for i=1, 1000000, 1 do
local i=1
while true do
    i = i+1
    for j=1, 100, 1 do
    end
    --playDuration(i)
    collectgarbage("collect")
    --print("mem:", collectgarbage("count")*1024)
    local event = getEvent()
    if event > 0 then
	    print("event:", event)
	    if event == 113 then
		break
	    end
	    if not isPortOpen then
		    --isPortOpen = initPandoraPort("/dev/ttyUSB0")
		    isPortOpen = initPandoraPort("com6")
	
		    print("open:", isPortOpen)
	    end
	    local ret = 0
	    if isPortOpen then
		    print("start send");
		    ret = send2Pandora("P|02|01|0|A(2) - L1 5 max in 7m\r\n")
		    print("i:", i, "send ret:", ret)
		    ret = send2Pandora("R02G01T0201WT\r")
		    print("i:", i, "send ret:", ret)
	

	    end
	    if ret == -1 then
		    closePandoraPort()
		    isPortOpen = false
	    end

	    --collectgarbage("collect")
    end
end
