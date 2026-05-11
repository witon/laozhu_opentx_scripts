
function testKMmergeKeyMapFromKvs_appliesNumericKeys()
	dofile(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	local km = { [100] = 50 }
	KMmergeKeyMapFromKvs(km, { ["36"] = 4099, ["35"] = 4100, ["x"] = 1, ["37"] = "bad" })
	luaunit.assertEquals(km[4099], 36)
	luaunit.assertEquals(km[4100], 35)
	luaunit.assertEquals(km[100], 50)
end

function testKMmergeKeyMapFromKvs_nilSafe()
	dofile(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	KMmergeKeyMapFromKvs(nil, { ["36"] = 1 })
	KMmergeKeyMapFromKvs({}, nil)
end
