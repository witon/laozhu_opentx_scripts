
function testKeyPushEventHistoryOne()
	local kfw = dofile(gSDCardDir .. "LAOZHU/key/keyFramework.lua")
	local h = {}
	kfw.pushEventHistory(h, 12, 10, 20, "00:00")
	luaunit.assertEquals(#h, 1)
	luaunit.assertEquals(h[1].raw, 10)
	luaunit.assertEquals(h[1].mapped, 20)
	luaunit.assertEquals(h[1].time, "00:00")
end

function testKeyPushEventHistoryRingMax()
	local kfw = dofile(gSDCardDir .. "LAOZHU/key/keyFramework.lua")
	local h = {}
	local max = 3
	for i = 1, 5 do
		kfw.pushEventHistory(h, max, i, i * 10, "t" .. tostring(i))
	end
	luaunit.assertEquals(#h, 3)
	luaunit.assertEquals(h[1].raw, 5)
	luaunit.assertEquals(h[1].mapped, 50)
	luaunit.assertEquals(h[1].time, "t5")
	luaunit.assertEquals(h[2].raw, 4)
	luaunit.assertEquals(h[3].raw, 3)
end

function testKeyPushEventHistoryFullThenEvict()
	local kfw = dofile(gSDCardDir .. "LAOZHU/key/keyFramework.lua")
	local h = {}
	local max = 12
	for i = 1, max do
		kfw.pushEventHistory(h, max, i, i, "x")
	end
	luaunit.assertEquals(#h, max)
	kfw.pushEventHistory(h, max, 99, 99, "y")
	luaunit.assertEquals(#h, max)
	luaunit.assertEquals(h[1].raw, 99)
	luaunit.assertEquals(h[max].raw, 2)
end
