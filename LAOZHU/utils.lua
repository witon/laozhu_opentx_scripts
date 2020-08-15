function LZ_formatTime(time)
	local minute = time / 6000
	local second= time / 100 % 60
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

