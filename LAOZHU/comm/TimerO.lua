Timer = {startTime = 0,
        stopTime = 0,
        duration = -1,
        lastReadTime = -1,
        downcountSeconds = -1,
        isForward = true,
        curTime = 0,
        mute = false,
        announceTime = 0,
        announceCallback = nil
}

function Timer:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Timer:setDuration(d)
    self.duration = d
end

function Timer:resetTimer(d)
    self.startTime = 0
    self.stopTime = 0
    self.duration = d
    self.lastReadTime = -1
    self.announceTime = 0
    self.announceCallback = nil
end

function Timer:setCurTime(t)
    self.curTime = t
end

function Timer:setForward(forward)
    self.isForward = forward
end

function Timer:setDowncount(seconds)
    self.downcountSeconds = seconds
end

function Timer:start()
    self.startTime = self.curTime
end

function Timer:isstart()
    if self.startTime > 0 and self.stopTime == 0 then
        return true
    else
        return false
    end
end

function Timer:stop()
    self.stopTime = self.curTime
end

function Timer:getRemainTime()
    if self.startTime == 0 then
        return self.duration
    end
    if self.duration < 0 then
        return self.duration
    end

    if self.stopTime > 0 then
        return self.duration - math.floor((self.stopTime- self.startTime) / 100)
    else
        return self.duration - math.floor((self.curTime - self.startTime) / 100)
    end
end

function Timer:getRunTime()
    if self.startTime == 0 then
        return 0
    end
    if self.stopTime > 0 then
        return math.floor((self.stopTime- self.startTime) / 100)
    else
        return math.floor((self.curTime - self.startTime) / 100)
    end
end

function Timer:getDuration()
    if self.stopTime <= 0 then
        return self:getRunTime(self)
    end
    return math.floor((self.stopTime - self.startTime) / 100)
end

function Timer:readDowncount(time)
    if self.downcountSeconds > 0 and time <= self.downcountSeconds then
        self.lastReadTime = time
        LZ_playNumber(time, 0)
        return
    end
end

function Timer:readIntegralTime(time)
    if self.downcountSeconds ~= -1 and time == 0 then
        return
    end

    if time % 30 == 0 then
        self.lastReadTime = time
        LZ_playTime(time)
    end
end


function Timer:readRemainTime()
    if self.duration <= 0 then
        return
    end
    local remainSeconds = self:getRemainTime(self)
    if remainSeconds == self.lastReadTime then
        return
    end
    if remainSeconds < 0 then
        return
    end

    if remainSeconds == self.duration then
        return
    end
    
    self:readDowncount(remainSeconds)
    self:readIntegralTime(remainSeconds)
end

function Timer:readRunTime()
    local remainSeconds = self:getRemainTime()
    if remainSeconds < self.downcountSeconds and remainSeconds >= 0 then
        if self.duration <= 0 then
            return
        end
        if remainSeconds == self.lastReadTime then
            return
        end
        self:readDowncount(remainSeconds)
        return
    end
    local runSeconds = self:getRunTime()
    if runSeconds == 0 or runSeconds == self.lastReadTime then
        return
    end
    self:readIntegralTime(runSeconds)
end

function Timer:run()
    if self.startTime == 0 then
        return
    end
    if self.announceTime ~= 0 and self.announceCallback then
        if (self.isForward and self.announceTime == self:getRunTime()) or
            ((not self.isForward) and self.announceTime == self:getRemainTime()) then
            self.announceCallback()
            self.announceTime = 0
        end
    end

    if self.mute then
        return
    end
    if self.isForward then
        self:readRunTime()
    else
        self:readRemainTime()
    end
end
