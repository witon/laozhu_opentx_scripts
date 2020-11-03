local function fun1()
    return 10, 1
end

local function fun2()
    return 20, 2
end

local function fun3()
    return 30, 3
end

local function fun4()
    return 40, 4
end


function testDoReadVar()
    local readVar = dofile(HOME_DIR .. "LAOZHU/readVar.lua")
    local varMap = {fun1, fun2, fun3, fun4}
    readVar.setVarMap(varMap)

    playNumber = Mock()
 
    playNumber:whenCalled{with={10, 1}, thenReturn = {}}
    playNumber:whenCalled{with={20, 2}, thenReturn = {}}
    playNumber:whenCalled{with={30, 3}, thenReturn = {}}
    playNumber:whenCalled{with={40, 4}, thenReturn = {}}

    readVar.doReadVar(-1000, -1000)
    playNumber:assertAnyCallMatches{arguments={10, 1}}

    readVar.doReadVar(-740, -1000)
    playNumber:assertAnyCallMatches{arguments={20, 2}}

    readVar.doReadVar(500, -1000)
    playNumber:assertAnyCallMatches{arguments={30, 3}}

    readVar.doReadVar(1000, -1000)
    playNumber:assertAnyCallMatches{arguments={40, 4}}
end



HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")