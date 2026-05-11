local function pickTmpMixSourceId()
    local names = {"s1", "s2", "s3", "ls", "rs", "thr"}
    for i = 1, #names do
        local fi = getFieldInfo(names[i])
        if fi then
            return fi.id
        end
    end
    return nil
end

function replaceMix(channel, reverse)
    local srcId = pickTmpMixSourceId()
    if not srcId then
        return
    end
    local mixesCount = model.getMixesCount(channel)
    local mix = {}
    if reverse then
        mix.weight = -150
    else
        mix.weight = 150
    end
    mix.name = "ad_tmp"
    mix.source = srcId
    mix.multiplex = 2
    mix.flightModes = 0
    model.insertMix(channel, mixesCount, mix)
end

function recoverMix(channel)
    local mixesCount = model.getMixesCount(channel)
    for i=mixesCount-1, 0, -1 do
        local mix = model.getMix(channel, i)
        if mix.name == "ad_tmp" then
            model.deleteMix(channel, i)
        else
            return
        end
    end
end