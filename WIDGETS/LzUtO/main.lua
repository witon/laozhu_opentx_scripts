-- 彩屏 Widget 版 utO：与 SCRIPTS/TELEMETRY/utO.lua 相同的 emutest 批跑 + 跑完后的 ViewMatrix 控件演练。
-- App 布局下请用「App mode」放置本 widget；需先 **长按 ENTER**（或长按触摸）把输入交给 widget 后，`event` 才非 nil，按键才会进入 ViewMatrix。

local name = "LzUtO"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

-- 调试：见 LAOZHU/DBGTools/dbg.lua；ERROR_LOG 控制 DBG_err，DEBUG_LOG 控制 DBG_dbg；SHOW_LOG_SCREEN 开时对应级别写入缓冲供覆盖层绘制。
local DBG_OPTS = {
	printTag = "[LzUtO]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local function update(widget, newOptions)
	widget.options = newOptions
end

local function background(widget)
end

local function refresh(widget, event, touchState)
	local z = widget.zone
	local ox = z.x
	local oy = z.y
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	local TXT = LZ_ui.font + LEFT + LZ_ui.themeText
	local rowH = LZ_ui.rowStep
	local maxVisLog = DBGLogLVmaxVisForRect(z.w, z.h)

	if not widget.loadOk then
		lcd.drawText(z.x + 2, z.y + 2, "LzUtO: LoadModule失败", LEFT + SMLSIZE)
		return
	end

	widget.framework.run(event, {
		ox = ox,
		oy = oy,
		z = z,
		rowH = rowH,
		TXT = TXT,
		maxVisLog = maxVisLog,
		zoneBg = zoneBg,
	})
end

local function create(zone, options)
	gSDCardDir = "/"
	gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
	local loadOk = false
	if fun then
		fun()
		loadOk = true
		LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
		DBG_init(DBG_OPTS)
		LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/DBGLogListView.lua")
		local ver0, radio0 = getVersion()
		DBG_dbg("create", "fw=" .. string.sub(tostring(ver0), 1, 8), "radio=" .. tostring(radio0), "zone", zone and zone.w or "?", zone and zone.h or "?")
		DBG_dbg("LoadModule ok")
	else
		print("[LzUtO] LoadModule FAIL:", tostring(err))
	end

	local framework = nil
	if loadOk then
		framework = LZ_runModule(gSDCardDir .. "LAOZHU/utO/utOFramework.lua")
		framework.initFramework({ surface = "widget", dbgEnabled = loadOk })
	end

	return {
		zone = zone,
		options = options,
		loadOk = loadOk,
		framework = framework,
	}
end

return {
	name = name,
	options = options,
	create = create,
	update = update,
	background = background,
	refresh = refresh,
}
