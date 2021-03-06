function OCMdisableCurve(channels)
--    local cfg = LZ_runModule(gScriptDir .. "LAOZHU/Cfg.lua")
--    for i=1, #channels, 1 do
--        local output = model.getOutput(channels[i]-1)
--        if output.curve then
--            cfg.getCfgs()[channels[i]-1] = output.curve
--            output.curve = nil
--            model.setOutput(channels[i]-1, output)
--        end
--    end
--    cfg.writeToFile("OCM_tmp.cfg")
end

function OCMrecoverCurve(channels)
--    local cfg = LZ_runModule(gScriptDir .. "LAOZHU/Cfg.lua")
--    cfg.readFromFile("OCM_tmp.cfg")
--    for i=1, #channels, 1 do
--        local output = model.getOutput(channels[i]-1)
--        local curve = cfg.getCfgs()[tostring(channels[i]-1)]
--        if curve ~= nil then
--            output.curve = curve
--            model.setOutput(channels[i]-1, output)
--        end
--    end
end
