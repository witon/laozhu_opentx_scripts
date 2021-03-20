
function testQueueAddNormal()
    dofile(HOME_DIR .. "LAOZHU/Queue.lua")
    local queue = QUEnewQueue(4)
    QUEadd(queue, 1)
    QUEadd(queue, 2)
    QUEadd(queue, 3)
    QUEadd(queue, 4)
    local e = QUEpoll(queue)
    luaunit.assertEquals(e, 1)
    e = QUEpoll(queue)
    luaunit.assertEquals(e, 2)
    e = QUEpoll(queue)
    luaunit.assertEquals(e, 3)
    e = QUEpoll(queue)
    luaunit.assertEquals(e, 4)
end

function testQueueAddFull()
    dofile(HOME_DIR .. "LAOZHU/Queue.lua")
    local queue = QUEnewQueue(4)
    QUEadd(queue, 1)
    QUEadd(queue, 2)
    QUEadd(queue, 3)
    QUEadd(queue, 4)
    QUEadd(queue, 5)
 
    local e = QUEpoll(queue)
    luaunit.assertEquals(e, 2)
    e = QUEpoll(queue)
    luaunit.assertEquals(e, 3)
    e = QUEpoll(queue)
    luaunit.assertEquals(e, 4)
    e = QUEpoll(queue)
    luaunit.assertEquals(e, 5)
end

function testQueueAddAndPoll()
    dofile(HOME_DIR .. "LAOZHU/Queue.lua")
    local queue = QUEnewQueue(5)
    for i=1, 10, 1 do
        QUEadd(queue, i)
        local e = QUEpoll(queue)
        luaunit.assertEquals(e, i)
    end
end

function testQueuePollWhileEmpty()
    dofile(HOME_DIR .. "LAOZHU/Queue.lua")
    local queue = QUEnewQueue(5)
    local e = QUEpoll(queue)
    luaunit.assertEquals(e, nil)
end

function testQueueGet()
    dofile(HOME_DIR .. "LAOZHU/Queue.lua")
    local queue = QUEnewQueue(5)
    for i=1, 11, 1 do
        QUEadd(queue, i)
    end
    for i=1, 5, 1 do
        local e = QUEget(queue, i)
        luaunit.assertEquals(e, i + 6)
    end
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")