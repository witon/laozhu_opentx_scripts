--[[
  全局 LZ_ui：字号与间距。LoadModule 末尾 LZ_uiInit(LZ_uiInitMode)；nil 时 lzPresetFromEnv()
  按 lcd.sizeText 选 "color1" 否则 "bw"。各字段含义见下方 color1 分支行尾注释；bw 分支为同级对照赋值。
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
		LZ_ui.font = MIDSIZE or SMLSIZE or 0 -- 正文默认（drawText/列表/表单）
		LZ_ui.fontL1 = XXLSIZE or DBLSIZE or MIDSIZE or LZ_ui.font -- 强调大号（计时、主数值）
		LZ_ui.fontWidth = 9 -- 单字符宽约估，output/曲线列宽用
		LZ_ui.rowStep = 21 -- 纵向行距、表单与列表步进
		LZ_ui.rowFillTopPad = 2 -- 数据行填充条相对文字向上扩展
		LZ_ui.rowFillBottomPad = 4 -- 数据行填充条相对文字向下扩展
		LZ_ui.headFillTopPad = 2 -- 表头填充条相对文字向上扩展
		LZ_ui.headFillBottomPad = 4 -- 表头填充条相对文字向下扩展
		LZ_ui.headerRowHeight = 26 -- 表头行高（常作 hh）
		LZ_ui.headerFont = MIDSIZE or SMLSIZE or 0 -- 另一套强调 flags（非「表头行高」）；StaticPage/pando 等
		LZ_ui.themeText = COLOR_THEME_PRIMARY1 or 0 -- 主题文字色；Widget/utO 等与 font 组合
	else
		LZ_ui.font = SMLSIZE or 0
		LZ_ui.fontL1 = DBLSIZE or MIDSIZE or LZ_ui.font
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
