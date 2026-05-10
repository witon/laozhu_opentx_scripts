if not gSDCardDir then
	gSDCardDir = "/"
end

local function testPlayNumber()
	playNumber(42, 0)
end

local function testPlayNumberWithUnit()
	playNumber(120, 9)
end

local function testPlayFileBeLau()
	playFile("LAOZHU/be-lau.wav")
end

return { testPlayNumber, testPlayNumberWithUnit, testPlayFileBeLau }
