gScriptDir = HOME_DIR




function testSinkRateStateNormalProcess()
    dofile(gScriptDir .. "/LAOZHU/SinkRateState.lua")
    local sinkRateState = SRSnewSinkRateState()
    SRSrun(sinkRateState, 100, 50, -1000)
    luaunit.assertFalse(SRSisStart(sinkRateState))
    SRSrun(sinkRateState, 200, 40, 1000)
    luaunit.assertTrue(SRSisStart(sinkRateState))
    local curDur = SRSgetCurDuration(sinkRateState, 300)
    luaunit.assertEquals(curDur, 100)
    local curSinkAlt = SRSgetCurSinkAlt(sinkRateState, 30)
    luaunit.assertEquals(curSinkAlt, 10)
    local curSinkRate = SRSgetCurSinkRate(sinkRateState, 300, 30)
    luaunit.assertEquals(curSinkRate, 0.1)
    SRSrun(sinkRateState, 400, 10, -1000)
    luaunit.assertFalse(SRSisStart(sinkRateState))
    luaunit.assertEquals(SRSgetDuration(sinkRateState), 200)
    luaunit.assertEquals(SRSgetSinkAlt(sinkRateState), 30)
    luaunit.assertEquals(SRSgetSinkRate(sinkRateState), 0.15)
end


function testSinkRateStateOnStateChange()
    local isStart = false
    function onSinkRateStateChange_test(s, state)
        isStart = state
    end

    dofile(gScriptDir .. "/LAOZHU/SinkRateState.lua")
    local sinkRateState = SRSnewSinkRateState()
    SRSsetOnStateChange(sinkRateState, onSinkRateStateChange_test)
    SRSrun(sinkRateState, 100, 50, -1000)
    luaunit.assertFalse(isStart)
    SRSrun(sinkRateState, 100, 50, 1000)
    luaunit.assertTrue(isStart)
    SRSrun(sinkRateState, 100, 50, -1000)
    luaunit.assertFalse(isStart)
end



HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")