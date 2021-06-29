local isPortOpen = false
--P
--Round
--Group
--Flight
--Task desc
--\r\n

--R07
--G02
--TMMSS
--WindowType P --ST;PT;TT;NF;WT;LT
--\r

local function open(port)
    isPortOpen = initPandoraPort(port)
    return isPortOpen
end


local function close()
    closePandoraPort()
end

local function getSendStr(round, group, roundWF)
    local taskWF = roundWF.getTask()
    local str1 = string.format("P|%02d|%02d|%d|%s\r\n", round, group, 1, taskWF.getTaskName())
    --todo: add flight
    local stateStr = ""
    local roundState = roundWF.getState() --1: begin; 2: preparationTime; 3: testTime; 4: taskTime; 5: end; 6: task nofly; 7: task flight; 8: task land;
    local taskState = taskWF.getState()
    if roundState == 2 then
        stateStr = "PT"
    elseif roundState == 3 then
        stateStr = "TT"
    elseif roundState == 4 then
        if taskState == 1 then
            stateStr = "NF"
        elseif taskState == 2 then
            stateStr = "WT"
        elseif taskState == 3 then
            stateStr = "LT"
        else
            print("not expect task state: " .. taskState)
        end
    else
        stateStr = "ST"
    end
    local timer = roundWF.getTimer()
    local remainTime = timer:getRemainTime()
    local minute = math.floor(remainTime / 60)
    local second = remainTime % 60
    local str2 = string.format("R%02dG%02dT%02d%02d%s\r", round, group, minute, second, stateStr)
    return str1, str2
end

local function send(round, group, roundWF)
    if not isPortOpen then
        return false
    end
    local str1, str2 = getSendStr(round, group, roundWF)
    local ret = send2Pandora(str1)
    if ret == -1 then
        return false
    end
    ret = send2Pandora(str2)
    if ret == -1 then
        return false
    end
    return true, ret
end

return {open=open, close=close, send=send}