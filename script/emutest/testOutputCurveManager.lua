dofile(gScriptDir .. "TELEMETRY/adjust/OutputCurveManager.lua")

local function testDisableCurve()
    local channels = {1, 2}
    local output = model.getOutput(0)
    output.curve = 1
    model.setOutput(0, output)
    OCMdisableCurve(channels)
    output = model.getOutput(0)
    assert(output.curve == nil)
end

local function testRecoverCurve()
    local channels = {1, 2}
    local output = model.getOutput(0)
    output.curve = 1
    model.setOutput(0, output)
    OCMdisableCurve(channels)
    output = model.getOutput(0)
    assert(output.curve == nil)
    OCMrecoverCurve(channels)
    output = model.getOutput(0)
    assert(output.curve == 1)
end


return {testDisableCurve,
        testRecoverCurve
}
