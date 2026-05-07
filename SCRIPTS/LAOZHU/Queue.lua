function QUEnewQueue(size)
    local queue = {}
    queue.array = {}
    queue.size = size
    queue.curReadIndex = size
    queue.curWriteIndex = size
    queue.full = false
    return queue
end

function QUEadd(queue, e)
    queue.curWriteIndex = queue.curWriteIndex + 1
    if queue.curWriteIndex > queue.size then
        queue.curWriteIndex = 1
    end
    queue.array[queue.curWriteIndex] = e
    if queue.full then
        queue.curReadIndex = queue.curWriteIndex
    elseif queue.curWriteIndex == queue.curReadIndex then
        queue.full = true
    end
end

function QUEcount(queue)
    if queue.full then
        return queue.size
    end
    if queue.curWriteIndex >= queue.curReadIndex then
        return queue.curWriteIndex - queue.curReadIndex
    else
        return queue.size - queue.curReadIndex + queue.curWriteIndex
    end
end

function QUEpoll(queue)
    if QUEcount(queue) == 0 then
        return nil
    end
    queue.curReadIndex = queue.curReadIndex + 1
    if queue.curReadIndex > queue.size then
        queue.curReadIndex = 1
    end
    local e = queue.array[queue.curReadIndex]
    if queue.full then
        queue.full = false
    end
    return e
end

function QUEget(queue, index)
    if index > QUEcount(queue) or index < 1 then
        return nil
    end
    local i = queue.curReadIndex + index
    if i > queue.size then
        i = i - queue.size
    end
    return queue.array[i]
end


function QUEunload()
    QUEnewQueue = nil
    QUEadd = nil
    QUEpoll = nil
    QUEcount = nil
    QUEget = nil
    QUEunload = nil
end