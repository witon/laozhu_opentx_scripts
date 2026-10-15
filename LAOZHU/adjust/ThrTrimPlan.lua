-- EdgeTX 枚举：LS_FUNC_AND=7，FUNC_ADJUST_GVAR=5，IncDec=4，FUNC_PLAY_SOUND=10，TRIM_MODE_NONE=31。
local LS_AND = 7
local FUNC_ADJUST_GVAR = 5
local FUNC_PLAY_SOUND = 10
local MODE_INCDEC = 4
local SND_BP1 = 0
local SND_BP3 = 2
local TRIM_LUA_KEY = 3
local TRIM_MODE_NONE = 31

local function selected(sw)
    return sw and sw ~= 0
end

local function distinct(a, b, c, d)
    return a ~= b and a ~= c and a ~= d and b ~= c and b ~= d and c ~= d
end

local function endsWith(name, ch)
    return name and string.sub(name, -1) == ch
end

-- list 按 idx 升序。第 3 对相邻的「- / +」是油门微调，返回 upIdx, downIdx。
local function throttleTrim(list)
    local n = 0
    for i = 2, #list do
        local lo = list[i - 1]
        local hi = list[i]
        if lo.idx + 1 == hi.idx and endsWith(lo.name, "-") and endsWith(hi.name, "+") then
            n = n + 1
            if n == 3 then
                return hi.idx, lo.idx
            end
        end
    end
    return nil, nil
end

local function apply(api, spec)
    if not selected(spec.swEle) or not selected(spec.swAll) or not selected(spec.swInc) or not selected(spec.swDec) then
        return nil, "no switch"
    end
    local ls = spec.ls
    if not distinct(ls[1], ls[2], ls[3], ls[4]) then
        return nil, "ls dup"
    end
    for i = 1, 4 do
        if not api.getLogicalSwitch(ls[i]) then
            return nil, "ls bad"
        end
    end
    if spec.gvEle == spec.gvAll then
        return nil, "gv dup"
    end
    local src = {}
    for i = 1, 4 do
        src[i] = api.getSwitchIndex(string.format("L%02d", ls[i] + 1))
        if not selected(src[i]) then
            return nil, "ls bad"
        end
    end
    local empty = {}
    local idx = 0
    while #empty < 8 do
        local cfn = api.getCustomFunction(idx)
        if not cfn then
            break
        end
        if not cfn.switch or cfn.switch == 0 then
            empty[#empty + 1] = idx
        end
        idx = idx + 1
    end
    if #empty < 8 then
        return nil, "sf full"
    end
    local fmCount = 0
    while api.getFlightMode(fmCount) do
        fmCount = fmCount + 1
    end

    local v1 = { spec.swEle, spec.swEle, spec.swAll, spec.swAll }
    local v2 = { spec.swInc, spec.swDec, spec.swInc, spec.swDec }
    local gv = { spec.gvEle, spec.gvEle, spec.gvAll, spec.gvAll }
    local delta = { 1, -1, 1, -1 }
    local snd = { SND_BP1, SND_BP1, SND_BP3, SND_BP3 }

    for n = 1, 4 do
        api.setLogicalSwitch(ls[n], {
            func = LS_AND,
            v1 = v1[n],
            v2 = v2[n],
            ["and"] = 0,
            delay = 0,
            duration = 0,
        })
    end
    local slot = 1
    for n = 1, 4 do
        api.setCustomFunction(empty[slot], {
            switch = src[n],
            func = FUNC_ADJUST_GVAR,
            param = gv[n],
            mode = MODE_INCDEC,
            value = delta[n],
            active = 1,
            repetition = 0,
        })
        slot = slot + 1
        api.setCustomFunction(empty[slot], {
            switch = src[n],
            func = FUNC_PLAY_SOUND,
            value = snd[n],
            active = 1,
            repetition = 0,
        })
        slot = slot + 1
    end
    for fm = 0, fmCount - 1 do
        api.setFlightMode(fm, { trimsModes = { [TRIM_LUA_KEY] = TRIM_MODE_NONE } })
    end
    api.setGlobalVariableDetails(spec.gvEle, { name = "ele" })
    api.setGlobalVariableDetails(spec.gvAll, { name = "cmn" })
    return true
end

return { apply = apply, throttleTrim = throttleTrim }
