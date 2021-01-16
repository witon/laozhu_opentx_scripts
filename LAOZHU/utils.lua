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
                clearTable(v)
            end
            t[i] = nil
        end
    end
    return t
end
