
function testSensorUpdateValue()
    dofile(HOME_DIR .. "LAOZHU/Sensor.lua")
    local sensor = SENSnewSensor("test_sensor", 30)
    SENSrun(sensor, 1, 10)
    luaunit.assertEquals(sensor.curValue, 10)
    luaunit.assertEquals(sensor.lastTime, 1)
    SENSrun(sensor, 1, 9)
    luaunit.assertEquals(sensor.lastTime, 1)
    luaunit.assertEquals(sensor.curValue, 9)
    SENSrun(sensor, 2, 10)
    luaunit.assertEquals(sensor.lastTime, 2)
    luaunit.assertEquals(sensor.curValue, 10)
end


function testSensorRuleNormal()
    local haveWarning = false
    local callback  = function() 
        haveWarning = true
    end
    dofile(HOME_DIR .. "LAOZHU/Sensor.lua")
    local sensor = SENSnewSensor("test_sensor", 30)
    SENSaddFluctuateRule(sensor, 0, 5, 1, callback)
    SENSrun(sensor, 1, 10) --average=0
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 2, 10) --average=10
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 3, 8.9) --average=10
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 4, 8.9)
    luaunit.assertTrue(haveWarning) --warn while the second pass
end

function testSensorRuleAverage()
    local haveWarning = false
    local callback  = function() 
        haveWarning = true
    end
    dofile(HOME_DIR .. "LAOZHU/Sensor.lua")
    local sensor = SENSnewSensor("test_sensor", 30)
    local rule = SENSaddFluctuateRule(sensor, 0, 3, 1, callback)
    SENSrun(sensor, 1, 5)
    SENSrun(sensor, 2, 4.9)
    SENSrun(sensor, 3, 4.8)
    SENSrun(sensor, 4, 4.7)
    luaunit.assertAlmostEquals(4.9, rule.averageValue, 0.01)
end


function testSensorRuleShouldSmall()
    local haveWarning = false
    local callback  = function() 
        haveWarning = true
    end
    dofile(HOME_DIR .. "LAOZHU/Sensor.lua")
    local sensor = SENSnewSensor("test_sensor", 30, true)
    SENSaddFluctuateRule(sensor, 100, 5, -1, callback)
    SENSrun(sensor, 1, 98)
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 2, 99.1)
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 3, 99.1)
    luaunit.assertTrue(haveWarning) --warn while the second pass



end


function testSensorRuleFull()
    local haveWarning = false
    local callback  = function() 
        haveWarning = true
    end
    dofile(HOME_DIR .. "LAOZHU/Sensor.lua")
    local sensor = SENSnewSensor("test_sensor", 30)
    SENSaddFluctuateRule(sensor, 0, 3, 0.9, callback)
    SENSrun(sensor, 1, 10)  -- average = 0
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 2, 8) -- average = 10
    luaunit.assertFalse(haveWarning) -- did not warn in the second

    SENSrun(sensor, 3, 8)   -- average = 9
    luaunit.assertTrue(haveWarning) -- warn while the second pass

    haveWarning = false
    SENSrun(sensor, 4, 8) --average = 8.66
    luaunit.assertTrue(haveWarning) --warn while the second pass

    haveWarning = false
    SENSrun(sensor, 5, 8) --average = 8
    luaunit.assertFalse(haveWarning)

    SENSrun(sensor, 6, 8) --average =  8 
    luaunit.assertFalse(haveWarning)
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")