function LZ_formatTime(time)
	local minute = time / 60
	local second= time % 60
	local str = string.format("%02d:%02d", minute, second)
	return str
end
function LZ_formatDateTime(dateTime)
	return string.format("%02d:%02d:%02d", dateTime["hour"], dateTime["min"], dateTime["sec"])
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
	io.write(errLogFile, timeStr, " ", message, "\r\n")
    io.close(errLogFile)
	assert(false, message)
	return 
end