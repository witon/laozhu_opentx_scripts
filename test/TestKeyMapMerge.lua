
function testKMmergeKeyMapFromKvs_appliesRawToTarget()
	dofile(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	local km = { [100] = 50 }
	KMmergeKeyMapFromKvs(km, { ["4099"] = 36, ["4100"] = 35, ["x"] = 1, ["bad"] = "x" })
	luaunit.assertEquals(km[4099], 36)
	luaunit.assertEquals(km[4100], 35)
	luaunit.assertEquals(km[100], 50)
end

function testKMmergeKeyMapFromKvs_nilSafe()
	dofile(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	KMmergeKeyMapFromKvs(nil, { ["36"] = 1 })
	KMmergeKeyMapFromKvs({}, nil)
end
