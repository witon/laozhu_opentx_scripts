-- DBG 非空（如开发前在入口里 `DBG = {}` 或已加载 dbg）时用 "t" 只读 .lua；否则 "bt" 优先较新的 .luac。
local function LZ_scriptLoadMode()
	if DBG ~= nil then
		return "t"
	end
	return "bt"
end

function LZ_loadModule(file)
	local fun, err = loadScript(file, LZ_scriptLoadMode())
	if fun ~= nil then
		return fun
	else
		print(err)
	end
end

function LZ_runModule(file)
	local fun, err = loadScript(file, LZ_scriptLoadMode())
	if fun ~= nil then
		return fun()
	else
		print(err)
	end
end

do
	local root = rawget(_G, "gSDCardDir")
	if type(root) == "string" then
		local pathUi = root .. "LAOZHU/uilib/UiParams.lua"
		local fu, ferr = loadScript(pathUi, LZ_scriptLoadMode())
		if fu ~= nil then
			fu()
			if type(LZ_uiInit) == "function" then
				LZ_uiInit(rawget(_G, "LZ_uiInitMode"))
			end
		elseif ferr ~= nil then
			print(ferr)
		end
	end
end
