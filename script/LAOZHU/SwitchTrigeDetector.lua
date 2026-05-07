

function STD_run(switchTrigeDetector, switchValue)
    if switchTrigeDetector.lastValue - switchValue > 100 or switchValue - switchTrigeDetector.lastValue > 100 then
        switchTrigeDetector.lastValue = switchValue
        return true
    else
        return false
    end

end

function STD_new(switchValue)
    return {lastValue = switchValue}
end

