-- 单格 NumEdit 页。按键由 simu-cli 送进 run(event)，经 keymap.cfg 再交给 ViewMatrix。
local edit
local vm
local called
local keyMap

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	keyMap = KMgetKeyMap()
	KMunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")

	called = 0
	edit = NumEdit:new()
	edit.num = 5
	edit.step = 1
	edit:setRange(1, 10)
	edit:setOnChange(function(self)
		if self ~= edit then
			error("onChange self")
		end
		called = called + 1
	end)

	vm = ViewMatrix:new()
	vm.matrix[1] = {edit}
	vm:updateCurIVFocus()
	DBG_dbg("num", edit.num, "chg", called)
end

local function run(event)
	local wasEditing = vm.editingIv ~= nil
	local prevNum = edit.num
	local prevChg = called
	if event ~= nil and event ~= 0 then
		local mapped = keyMap[event] or event
		vm:doKey(mapped)
	end
	lcd.clear()
	edit:draw(1, 1, true, 0)
	if vm.editingIv ~= nil and not wasEditing then
		DBG_dbg("editing")
	end
	if edit.num ~= prevNum or called ~= prevChg then
		DBG_dbg("num", edit.num, "chg", called)
	end
end

return {init = init, run = run}
