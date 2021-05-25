function testCompetitionWFNormalFlow()
    local wf = dofile(HOME_DIR .. "LAOZHU/F3kWF/F3kCompetitionWF.lua")
    dofile(HOME_DIR .. "LAOZHU/comm/TestSound.lua")
    wf.setCompetitionParam(0, 0, 0, 2, false, 2, false)
    local task1 = {}
    task1.id = 'A'
    local task2 = {}
    task2.id = 'B'

    wf.addTask(task1)
    wf.addTask(task2)

    local time = 100

    wf.start(time)
    wf.run(time)
    local competitionState, round, group, roundWF = wf.getCurStep()
    luaunit.assertEquals(roundWF.getState(), 4) --task time, flight time
 
    luaunit.assertEquals(round, 1)
    luaunit.assertEquals(group, 1)

    --flight time
    time = time + 7 * 6000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, landing time
 
    --landing time
    time = time + 3000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 5) --end

    --next round
    time = time + 1
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, flight time
 
    time = time + 7 * 6000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, landing time

    time = time + 3000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 5) --end

    --next round
    time = time + 1
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, flight time
 
    time = time + 10 * 6000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, landing time

    time = time + 3000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 5) --end

    --next round
    time = time + 1
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, flight time
 
    time = time + 10 * 6000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 4) --task time, landing time

    time = time + 3000
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 5) --end

    time = time + 1
    wf.run(time)
    luaunit.assertEquals(roundWF.getState(), 5) --end
    competitionState, round, group, roundWF = wf.getCurStep()
    luaunit.assertEquals(competitionState, 3)
end



HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")