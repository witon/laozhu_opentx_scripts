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
