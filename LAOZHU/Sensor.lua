function SENSnewSensor(name)
    local sensor = {}
    sensor.lastTime = 0
    sensor.name = name
    return sensor
end

function SENSsetRule(sensor, initValue, seconds, threshold, shouldSmall, callback)
    sensor.seconds = seconds
    sensor.threshold = threshold
    sensor.initValue = initValue
    sensor.callback = callback
    sensor.shouldSmall = shouldSmall
end

function SENScheckRule(sensor, time, value)
    if sensor.shouldSmall then
        if value > sensor.value then
            sensor.value = value
        end
        if sensor.callback ~= nil and sensor.shouldSmall and sensor.value > sensor.threshold then
            sensor.callback(sensor, time)
        end

    else
        if value < sensor.value then
            sensor.value = value
        end
        if sensor.callback ~= nil and not sensor.shouldSmall and sensor.value < sensor.threshold then
            sensor.callback(sensor, time)
        end

    end
end

function SENSrun(sensor, time, value)
    if time - sensor.lastTime > sensor.seconds then
        sensor.value = sensor.initValue;
        sensor.lastTime = time
    end 
    if sensor.lastTime ~= 0 then
        SENScheckRule(sensor, sensor.lastTime, value)
    end
end

function SENSunload()
    SENSnewSensor = nil
    SENSrun = nil
    SENSsetRule = nil
    SENScheckRule = nil
    SENSunload = nil
end