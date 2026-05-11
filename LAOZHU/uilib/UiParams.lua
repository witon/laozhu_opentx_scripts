--[[
  全局 LZ_ui。LoadModule 会执行 LZ_uiInit(LZ_uiInitMode)。
  mode 为字符串预设：目前 "bw" | "color1"，后续可并列增加 color2…
]]

LZ_ui = LZ_ui or {}

local function lzPresetFromEnv()
	if lcd ~= nil and type(lcd.sizeText) == "function" then
		return "color1"
	end
	return "bw"
end

function LZ_uiInit(mode)
	if mode ~= "bw" and mode ~= "color1" then
		mode = lzPresetFromEnv()
	end
	if mode == "color1" then
		LZ_ui.font = MIDSIZE or SMLSIZE or 0
		LZ_ui.fontSmall = SMLSIZE or LZ_ui.font
		LZ_ui.fontWidth = 9
		LZ_ui.rowStep = 21
		LZ_ui.rowFillTopPad = 2
		LZ_ui.rowFillBottomPad = 4
		LZ_ui.headFillTopPad = 2
		LZ_ui.headFillBottomPad = 4
		LZ_ui.headerRowHeight = 26
		LZ_ui.headerFont = MIDSIZE or SMLSIZE or 0
		LZ_ui.themeText = COLOR_THEME_PRIMARY1 or 0
	else
		LZ_ui.font = SMLSIZE or 0
		LZ_ui.fontSmall = SMLSIZE or 0
		LZ_ui.fontWidth = 5
		LZ_ui.rowStep = 9
		LZ_ui.rowFillTopPad = 1
		LZ_ui.rowFillBottomPad = 0
		LZ_ui.headFillTopPad = 1
		LZ_ui.headFillBottomPad = 0
		LZ_ui.headerRowHeight = 9
		LZ_ui.headerFont = SMLSIZE or 0
		LZ_ui.themeText = 0
	end
end

function LZ_uiUnload()
	LZ_ui = nil
	LZ_uiInit = nil
	LZ_uiUnload = nil
end
