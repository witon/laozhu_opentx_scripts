local function planMod()
    return dofile(gSDCardDir .. "LAOZHU/adjust/ThrTrimPlan.lua")
end

local function spec()
    return {
        ls = { 7, 8, 9, 10 },
        gvEle = 1,
        gvAll = 7,
        swEle = 11,
        swAll = 12,
        swInc = 13,
        swDec = 14,
    }
end

local function makeApi(opts)
    opts = opts or {}
    local cfnCount = opts.cfnCount or 16
    local occupied = {}
    if opts.occupied then
        for i = 1, #opts.occupied do
            occupied[opts.occupied[i]] = true
        end
    end
    local cfn = {}
    for i = 0, cfnCount - 1 do
        if occupied[i] then
            cfn[i] = { switch = 50 + i, func = 3 }
        else
            cfn[i] = { switch = 0, func = 0 }
        end
    end
    local lsCount = opts.lsCount or 64
    local lsw = {}
    for i = 0, lsCount - 1 do
        lsw[i] = { func = 0 }
    end
    local fmCount = opts.fmCount or 9
    local fm = {}
    for i = 0, fmCount - 1 do
        fm[i] = { trimsModes = { [1] = 1, [2] = 2, [3] = 4, [4] = 8 } }
    end
    local gvd = {}
    local writes = { ls = 0, cfn = 0, fm = 0, gv = 0 }
    local api = {
        getCustomFunction = function(i)
            return cfn[i]
        end,
        setCustomFunction = function(i, data)
            writes.cfn = writes.cfn + 1
            cfn[i] = data
        end,
        getLogicalSwitch = function(i)
            return lsw[i]
        end,
        setLogicalSwitch = function(i, data)
            writes.ls = writes.ls + 1
            lsw[i] = data
        end,
        getFlightMode = function(i)
            return fm[i]
        end,
        setFlightMode = function(i, data)
            writes.fm = writes.fm + 1
            local modes = data.trimsModes
            for k, v in pairs(modes) do
                fm[i].trimsModes[k] = v
            end
        end,
        setGlobalVariableDetails = function(i, data)
            writes.gv = writes.gv + 1
            gvd[i] = data
        end,
        getSwitchIndex = opts.getSwitchIndex or function(name)
            local n = string.match(name, "^L(%d+)$")
            if not n then
                return nil
            end
            return 200 + tonumber(n)
        end,
    }
    return api, { cfn = cfn, lsw = lsw, fm = fm, gvd = gvd, writes = writes }
end

function testThrTrimApplyWritesEightFunctions()
    local plan = planMod()
    local api, st = makeApi({ occupied = { 0, 5 } })
    local s = spec()
    local ok, err = plan.apply(api, s)
    luaunit.assertEquals(ok, true)
    luaunit.assertNil(err)

    local expectV1 = { s.swEle, s.swEle, s.swAll, s.swAll }
    local expectV2 = { s.swInc, s.swDec, s.swInc, s.swDec }
    for i = 1, 4 do
        local ls = st.lsw[s.ls[i]]
        luaunit.assertEquals(ls.func, 7)
        luaunit.assertEquals(ls.v1, expectV1[i])
        luaunit.assertEquals(ls.v2, expectV2[i])
        luaunit.assertEquals(ls["and"], 0)
        luaunit.assertEquals(ls.delay, 0)
        luaunit.assertEquals(ls.duration, 0)
    end

    local slots = { 1, 2, 3, 4, 6, 7, 8, 9 }
    local src = { 208, 208, 209, 209, 210, 210, 211, 211 }
    local func = { 5, 10, 5, 10, 5, 10, 5, 10 }
    local param = { 1, nil, 1, nil, 7, nil, 7, nil }
    local mode = { 4, nil, 4, nil, 4, nil, 4, nil }
    local value = { 1, 0, -1, 0, 1, 2, -1, 2 }
    for i = 1, 8 do
        local cfn = st.cfn[slots[i]]
        luaunit.assertEquals(cfn.switch, src[i])
        luaunit.assertEquals(cfn.func, func[i])
        luaunit.assertEquals(cfn.value, value[i])
        luaunit.assertEquals(cfn.active, 1)
        luaunit.assertEquals(cfn.repetition, 0)
        if param[i] then
            luaunit.assertEquals(cfn.param, param[i])
            luaunit.assertEquals(cfn.mode, mode[i])
        end
    end
    luaunit.assertEquals(st.cfn[0].switch, 50)
    luaunit.assertEquals(st.cfn[5].switch, 55)
    luaunit.assertEquals(st.cfn[10].switch, 0)

    luaunit.assertEquals(st.writes.fm, 9)
    for i = 0, 8 do
        luaunit.assertEquals(st.fm[i].trimsModes[3], 31)
        luaunit.assertEquals(st.fm[i].trimsModes[1], 1)
        luaunit.assertEquals(st.fm[i].trimsModes[2], 2)
        luaunit.assertEquals(st.fm[i].trimsModes[4], 8)
    end
    luaunit.assertEquals(st.gvd[1].name, "ele")
    luaunit.assertEquals(st.gvd[7].name, "cmn")
end

local function assertUntouched(st)
    luaunit.assertEquals(st.writes.ls, 0)
    luaunit.assertEquals(st.writes.cfn, 0)
    luaunit.assertEquals(st.writes.fm, 0)
    luaunit.assertEquals(st.writes.gv, 0)
    luaunit.assertEquals(st.cfn[1].switch, 0)
    luaunit.assertEquals(st.lsw[7].func, 0)
    luaunit.assertEquals(st.fm[0].trimsModes[3], 4)
end

function testThrTrimApplyRejectsDuplicateLs()
    local plan = planMod()
    local api, st = makeApi()
    local s = spec()
    s.ls[2] = s.ls[1]
    local ok, err = plan.apply(api, s)
    luaunit.assertNil(ok)
    luaunit.assertEquals(err, "LS重复")
    assertUntouched(st)
end

function testThrTrimApplyRejectsDuplicateGv()
    local plan = planMod()
    local api, st = makeApi()
    local s = spec()
    s.gvAll = s.gvEle
    local ok, err = plan.apply(api, s)
    luaunit.assertNil(ok)
    luaunit.assertEquals(err, "GV重复")
    assertUntouched(st)
end

function testThrTrimApplyRejectsMissingSwitch()
    local plan = planMod()
    local api, st = makeApi()
    local s = spec()
    s.swInc = 0
    local ok, err = plan.apply(api, s)
    luaunit.assertNil(ok)
    luaunit.assertEquals(err, "开关未选")
    assertUntouched(st)
end

function testThrTrimApplyRejectsInvalidLs()
    local plan = planMod()
    local api, st = makeApi()
    local s = spec()
    s.ls[4] = 80
    local ok, err = plan.apply(api, s)
    luaunit.assertNil(ok)
    luaunit.assertEquals(err, "LS无效")
    assertUntouched(st)
end

function testThrTrimApplyRejectsWhenCustomFunctionsShort()
    local plan = planMod()
    local api, st = makeApi({ cfnCount = 10, occupied = { 0, 1, 2 } })
    local ok, err = plan.apply(api, spec())
    luaunit.assertNil(ok)
    luaunit.assertEquals(err, "SF不足")
    luaunit.assertEquals(st.writes.ls, 0)
    luaunit.assertEquals(st.writes.cfn, 0)
    luaunit.assertEquals(st.writes.fm, 0)
    luaunit.assertEquals(st.writes.gv, 0)
    luaunit.assertEquals(st.cfn[3].switch, 0)
    luaunit.assertEquals(st.fm[0].trimsModes[3], 4)
end

if not LZ_TEST_HARNESS then
    HOME_DIR = os.getenv("HOME_DIR")
    if not HOME_DIR then
        HOME_DIR = "./"
    else
        HOME_DIR = HOME_DIR .. "/"
    end
    dofile(HOME_DIR .. "test/utils4Test.lua")
end
