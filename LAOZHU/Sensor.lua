function SENSnewSensor(name, size, shouldSmall)
    local sensor = {}
    sensor.dataQueue = QUEnewQueue(size)
    sensor.fluctuateThreshold = 0
    sensor.lastTime = 0
    sensor.curValue = 0
    sensor.name = name
    sensor.fluctuateRuleArray = {}
    sensor.shouldSmall = shouldSmall

    return sensor
end

function SENSaddFluctuateRule(sensor, initValue, seconds, threshold, callback)
    local rule = {}
    rule.seconds = seconds
    rule.threshold = threshold
    rule.averageValue = initValue
    rule.averageCount = 0
    rule.callback = callback
    sensor.fluctuateRuleArray[#(sensor.fluctuateRuleArray) + 1] = rule
    return rule
end

function SENScheckOneRule(sensor, index, time, value)
    local rule = sensor.fluctuateRuleArray[index]

    if rule.callback ~= nil then
        if sensor.shouldSmall then
            if rule.averageValue - value < rule.threshold then
                rule.callback(sensor, rule, time, value)
            end
       else
            if rule.averageValue - value > rule.threshold then
                rule.callback(sensor, rule, time, value)
            end
        end
    end
end

function SENScalcOneRule(sensor, index, value)
    local rule = sensor.fluctuateRuleArray[index]
    if rule.averageCount == rule.seconds then
        local earliestValue = QUEget(sensor.dataQueue, QUEcount(sensor.dataQueue) - rule.seconds)
        local sum = rule.averageCount * rule.averageValue - earliestValue
        sum = sum + value
        rule.averageValue = sum / rule.averageCount
    else
        local sum = rule.averageCount * rule.averageValue + value
        rule.averageCount = rule.averageCount + 1
        rule.averageValue = sum / rule.averageCount
    end
end

function SENSrun(sensor, time, value)
    if sensor.lastTime == time then
        if sensor.shouldSmall then
            if value > sensor.curValue then
                sensor.curValue = value
            end
       else
            if sensor.curValue > value then
                sensor.curValue = value
            end
       end
    else
        if sensor.lastTime ~= 0 then
            QUEadd(sensor.dataQueue, sensor.curValue)
            for i=1, #(sensor.fluctuateRuleArray), 1 do
                SENScheckOneRule(sensor, i, sensor.lastTime, sensor.curValue)
                SENScalcOneRule(sensor, 1, sensor.curValue)
            end
        end
        sensor.lastTime = time
        sensor.curValue = value
    end
end

function SENSunload()
    SENSnewSensor = nil
    SENSrun = nil
    SENSaddFluctuateRule = nil
    SENScheckOneRule = nil
    SENScalcOneRule = nil
    SENSunload = nil
end