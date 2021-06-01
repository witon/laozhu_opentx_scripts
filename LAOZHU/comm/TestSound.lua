TEST_lastPlayNumber = -1
TEST_lastPlayFile = ""
TEST_lastPlayTime = -1
TEST_SOUND_DIR = "SOUNDS\\cz\\"
require("sound")

function LZ_playNumber(value, flag)
	TEST_lastPlayNumber = value
	playNumber(value, flag)
end


function LZ_playFile(path, force)
	TEST_lastPlayFile = path
	playFile(path)
end

function LZ_playTime(time, withoutUnit)
	TEST_lastPlayNumber = time
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

function playTone()
	LZ_playFile("LAOZHU/horn.wav", true)
end