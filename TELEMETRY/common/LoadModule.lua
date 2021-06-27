
function LZ_loadModule(file)
    local fun, err = loadScript(gScriptDir .. file)
    if (fun ~= nil) then
        return fun
    else
        print(err)
    end
end

function LZ_runModule(file)
    local fun, err = loadScript(gScriptDir .. file)
    if (fun ~= nil) then
        return fun()
    else
        print(err)
    end
end

