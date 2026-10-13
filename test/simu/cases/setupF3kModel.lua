-- 给 3ktel 全流程用例准备模型：飞行模式名和开关，并打出 sa–sd 的字段 id。
local DOWN = "\194\131"

local function switchDown(prefix)
	local idx = getSwitchIndex(prefix .. DOWN)
	if idx == nil then
		error("no switch pos " .. prefix)
	end
	DBG_dbg("swpos", prefix, getSwitchName(idx))
	return idx
end

local function setMode(index, params)
	local rc = model.setFlightMode(index, params)
	if rc ~= 0 then
		error("setFlightMode " .. index)
	end
end

local function setupF3kModel()
	setMode(0, {name = "cruise", switch = 0})
	setMode(1, {name = "zoom", switch = switchDown("SB")})
	setMode(2, {name = "preset", switch = switchDown("SA")})
	for i = 3, 8 do
		local rc = model.setFlightMode(i, {name = "", switch = 0})
		if rc ~= 0 then
			break
		end
	end

	for _, name in ipairs({"sa", "sb", "sc", "sd"}) do
		local info = getFieldInfo(name)
		if info == nil then
			error("no field " .. name)
		end
		DBG_dbg("sw", name, info.id)
	end

	local fm, fmName = getFlightMode()
	DBG_dbg("fm", fm, fmName)
end

return {setupF3kModel}
