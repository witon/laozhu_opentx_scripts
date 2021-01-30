local function fun1()
    playNumber(10, 1)
end

local function fun2()
    playNumber(20, 2)
end

local function fun3()
    playNumber(30, 3)
end

local function fun4()
    playNumber(40, 4)
end


function testDoReadVarMoveSlider()
    local readVar = dofile(HOME_DIR .. "LAOZHU/readVar.lua")
    local varMap = {fun1, fun2, fun3, fun4}
    readVar.setVarMap(varMap)

    playNumber = Mock()
 
    playNumber:whenCalled{with={10, 1}, thenReturn = {}}
    playNumber:whenCalled{with={20, 2}, thenReturn = {}}
    playNumber:whenCalled{with={30, 3}, thenReturn = {}}
    playNumber:whenCalled{with={40, 4}, thenReturn = {}}

    readVar.doReadVar(0, 1000, 1000)
    readVar.doReadVar(-1000, 1000, 1000)
    playNumber:assertAnyCallMatches{arguments={10, 1}}
    playNumber:assertCallCount(1)

    readVar.doReadVar(-740, 1000, 1020)
    playNumber:assertAnyCallMatches{arguments={20, 2}}
    playNumber:assertCallCount(2)


    readVar.doReadVar(500, 1000, 1040)
    playNumber:assertAnyCallMatches{arguments={30, 3}}
    playNumber:assertCallCount(3)

    readVar.doReadVar(1000, 1000, 1060)
    playNumber:assertAnyCallMatches{arguments={40, 4}}
    playNumber:assertCallCount(4)
end

function testDoReadVarTriggerSwitch()
    local readVar = dofile(HOME_DIR .. "LAOZHU/readVar.lua")
    local varMap = {fun1, fun2, fun3, fun4}
    readVar.setVarMap(varMap)

    playNumber = Mock()
 
    playNumber:whenCalled{with={10, 1}, thenReturn = {}}
    playNumber:whenCalled{with={20, 2}, thenReturn = {}}
    playNumber:whenCalled{with={30, 3}, thenReturn = {}}
    playNumber:whenCalled{with={40, 4}, thenReturn = {}}

    readVar.doReadVar(-1000, 1000, 1000)
    readVar.doReadVar(-1000, -1000, 1000)
    playNumber:assertAnyCallMatches{arguments={10, 1}}
    readVar.doReadVar(-1000, 1000, 1000)
    readVar.doReadVar(-1000, -1000, 1050)
    playNumber:assertCallCount(2)
    readVar.doReadVar(-1000, 1000, 1050)
    readVar.doReadVar(-1000, -1000, 1050)
    playNumber:assertCallCount(2)

end



HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")