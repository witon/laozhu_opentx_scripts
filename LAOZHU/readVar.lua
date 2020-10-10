gCurVar = -1
gFlightTime = 0
gCurAlt = 0
gLaunchALT = 0

curReadSwitchState = 0

function doReadVar(varSelect, readSwitch)
        local v = getSelectedVar(varSelect)
        if gCurVar == -1 then
                gCurVar = v
        elseif gCurVar ~= v then
                gCurVar = v
                readVar()
        end

        if readSwitch ~= curReadSwitchState then
                if readSwitch < 0 then
                        readVar()
                end
                curReadSwitchState = readSwitch 
        end
end

function readVar()
        if gCurVar == 0 then --flight time
                playDuration(gFlightTime/100, 0)
        elseif gCurVar == 1 then --cur alt
                playNumber(gCurAlt, 9)
        elseif gCurVar ==2 then --rssi
                local rssi, alarm_low, alarm_crit = getRSSI() 
                playNumber(rssi, 17)
        elseif gCurVar ==3 then --launch alt
                playNumber(gLaunchALT, 9)
        end
end

function getSelectedVar(varSelect)
        local v = 0
        if varSelect < -750 then
                v = 0
        elseif varSelect >= -750 and varSelect < 0 then
                v = 1
        elseif varSelect >=0 and varSelect < 750 then
                v = 2
        elseif varSelect >= 750 then
                v = 3
        end
        return v
end