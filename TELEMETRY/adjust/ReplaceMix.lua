
function replaceMix(channel, reverse)
    local mixesCount = model.getMixesCount(channel)
    local mix = {}
    if reverse then
        mix.weight = -150
    else
        mix.weight = 150
    end
    mix.name = "ad_tmp"
    mix.source = getFieldInfo("thr").id
    mix.multiplex = 2
    mix.flightModes = 0
    model.insertMix(channel, mixesCount, mix)
end

function recoverMix(channel)
    local mixesCount = model.getMixesCount(channel)
    local mix = model.getMix(channel, mixesCount-1)
    if mix.name == "ad_tmp" then
        model.deleteMix(channel, mixesCount-1)
    end
end