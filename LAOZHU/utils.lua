function LZ_formatTime(time)
	local minute = time / 60
	local second= time % 60
	local str = string.format("%02d:%02d", minute, second)
	return str
end
function LZ_formatDateTime(dateTime)
	return string.format("%02d:%02d:%02d", dateTime["hour"], dateTime["min"], dateTime["sec"])
end

function LZ_formatTimeStamp(time)
	local secondsInDay = (time % (24*60*60))
	local hour = math.floor(secondsInDay/60/60)
	local secondsInHour = secondsInDay % (60*60) 
	local minute = math.floor(secondsInHour/60)
	local second = secondsInHour % 60
	local str = string.format("%02d:%02d:%02d", hour, minute, second)
	return str
end

function getTelemetryId(name)
	
	local field = getFieldInfo(name)
	if field then
		return field.id
	else
		return -1
	end
end

function LZ_playNumber(value, flag)
	local t = math.floor(getTime()/90)
	if t == lz_lastPlayNumberTime then
		return
	end
	lz_lastPlayNumberTime = t
	playNumber(value, flag)
end


function LZ_playTime(time, withoutUnit)
	local t = math.floor(getTime()/90)
	if t == lz_lastPlayNumberTime then
		return
	end

	lz_lastPlayNumberTime = t
	local minute = math.floor(time / 60)
	if minute ~= 0 then
		if not withoutUnit then
			playNumber(minute, 36)
		else
			playNumber(minute, 0)
		end
	end
	local second = time % 60
	if second ~= 0 then
		if not withoutUnit then
			playNumber(second, 37)
		else
			playNumber(second, 0)
		end
	end

end

function LZ_clearTable(t)
    if type(t) == "table" then
        for i, v in pairs(t) do
            if type(v) == "table" then
                LZ_clearTable(v)
            end
            t[i] = nil
        end
    end
    return t
end

function LZ_getOutputName(index)
    local output = model.getOutput(index)
    if not output then
        return nil
    end
    if output.name == "" then
        return "ch" .. (index + 1)
    end
    return output.name
end

function LZ_getCurveName(index)
    if (not index) or index == -1 then
        return "-"
    end
    local curve = model.getCurve(index)
    if not curve then
        return nil
    end
    if curve.name == "" then
        return "cur" .. (index + 1)
    end
    return curve.name
end

function LZ_error(message)
	if message == nil then
		assert(false)
		return
	end
	local dateTime = getDateTime()
	local dateStr = string.format("%04d%02d%02d", dateTime["year"], dateTime["mon"], dateTime["day"])
	local timeStr = LZ_formatDateTime(dateTime)
    local errLogFilePath = gScriptDir .. "err_" .. dateStr .. ".log"
    local errLogFile = io.open(errLogFilePath, 'a')
    if errLogFile == nil then
		assert(false, message)
        return
    end
	local modelName = model.getInfo().name
	io.write(errLogFile, timeStr, " ", modelName, " ", message, "\r\n")
    io.close(errLogFile)
	assert(false, message)
	return 
end

function LZ_isNeedCompile()
    local flgFilePath = gScriptDir .. "lzinstall.flag"
    local flgFile = io.open(flgFilePath, 'r')
	if flgFile == nil then
		return false
	end
    local content = io.read(flgFile, 200)
	io.close(flgFile)
	flgFile = nil
	if string.sub(content, 1, 8) == "not init" then
		return true
	end
	return false
end

function LZ_markCompiled()
    local flgFilePath = gScriptDir .. "lzinstall.flag"
	local flgFile = io.open(flgFilePath, 'w')
	if flgFile ~= nil then
		io.close(flgFile)
	end
	flgFile = nil
end

function LZ_getGVValue(index, mode)
    local value = model.getGlobalVariable(index, mode)
    if value >= 1025 then
        local m = value - 1025
        if m >= mode then
            m = m + 1
        end
        value = model.getGlobalVariable(index, m)
        if value > 1024 then
            LZ_error("invalid gv value, index:" .. index .. ", mode:" .. mode .. ", value:" .. value)
        end
    end
    return value
end

function LZ_setGVValue(index, mode, value)
    local curValue = model.getGlobalVariable(index, mode)
    if curValue >= 1025 then
        local m = curValue - 1025
        if m >= mode then
            m = m + 1
        end
        model.setGlobalVariable(index, m, value)
    else
        model.setGlobalVariable(index, mode, value)
    end
end

