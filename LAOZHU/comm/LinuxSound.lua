function LZ_playNumber(value, flag)
	local t = math.floor(getTime()/90)
	if t == lz_lastPlayNumberTime then
		return
	end
	lz_lastPlayNumberTime = t
	playNumber(value, flag)
end

function LZ_playFile(path, force)
	local t = math.floor(getTime()/90)
	if force then
		playFile(path)
		lz_lastPlayNumberTime = t
	else
		if t == lz_lastPlayNumberTime then
			return
		end
		lz_lastPlayNumberTime = t
		playFile(path)
	end
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