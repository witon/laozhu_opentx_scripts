local function testThrTrimRoundtrip()
	assert(LS_FUNC_AND == 7, "LS_FUNC_AND")
	assert(FUNC_ADJUST_GVAR == 5, "FUNC_ADJUST_GVAR")
	assert(FUNC_PLAY_SOUND == 10, "FUNC_PLAY_SOUND")

	local plan = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/ThrTrimPlan.lua")
	for i = 0, 7 do
		model.setCustomFunction(i, { switch = 0 })
	end
	local plus = {}
	for idx, name in switches() do
		if string.sub(name, -1) == "+" then
			plus[#plus + 1] = idx
		end
	end
	assert(plus[3], "thr+")
	local spec = {
		ls = { 7, 8, 9, 10 },
		gvEle = 1,
		gvAll = 7,
		swEle = getSwitchIndex("SH" .. CHAR_UP),
		swAll = getSwitchIndex("SH" .. CHAR_DOWN),
		swInc = plus[3],
		swDec = plus[3] - 1,
	}
	assert(spec.swEle and spec.swEle ~= 0, "SH up")
	assert(spec.swAll and spec.swAll ~= 0, "SH down")
	local ok, err = plan.apply({
		getCustomFunction = model.getCustomFunction,
		setCustomFunction = model.setCustomFunction,
		getLogicalSwitch = model.getLogicalSwitch,
		setLogicalSwitch = model.setLogicalSwitch,
		getFlightMode = model.getFlightMode,
		setFlightMode = model.setFlightMode,
		setGlobalVariableDetails = model.setGlobalVariableDetails,
		getSwitchIndex = getSwitchIndex,
	}, spec)
	assert(ok, err or "apply")

	local ls = model.getLogicalSwitch(7)
	assert(ls.func == LS_FUNC_AND, "ls func")
	assert(ls.v1 == spec.swEle, "ls v1")
	assert(ls.v2 == spec.swInc, "ls v2")

	local fm = model.getFlightMode(0)
	assert(fm.trimsModes[3] == 31, "trim")

	local ele = model.getGlobalVariableDetails(1)
	assert(ele.name == "ele", "ele")
	local cmn = model.getGlobalVariableDetails(7)
	assert(cmn.name == "cmn", "cmn")

	local l08 = getSwitchIndex("L08")
	local found = false
	local i = 0
	while true do
		local cfn = model.getCustomFunction(i)
		if not cfn then
			break
		end
		if cfn.switch == l08 and cfn.func == FUNC_ADJUST_GVAR then
			assert(cfn.param == spec.gvEle, "param")
			assert(cfn.mode == 4, "mode")
			assert(cfn.value == 1, "value")
			assert(cfn.active == 1, "active")
			found = true
			break
		end
		i = i + 1
	end
	assert(found, "cf")
end

return { testThrTrimRoundtrip }
