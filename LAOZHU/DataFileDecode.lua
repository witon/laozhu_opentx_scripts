function DFDnewDataFileDecode()
    return {
        buf = "",
        curPoint = 0,
        file = nil,
    }
end

function DFDsetFile(dfd, file)
    dfd.file = file
end

function DFDgetOneField(dfd, char)
    local i = string.find(dfd.buf, char, dfd.curPoint)
    local count = 0
    while i == nil and count < 3 do
        local tmp = io.read(dfd.file, 10)
        if tmp == nil or tmp == "" then
            return nil
        end
        dfd.buf = string.sub(dfd.buf, dfd.curPoint) .. tmp
        dfd.curPoint = 0 
        dfd.bufLen = string.len(dfd.buf)
        i = string.find(dfd.buf, char, dfd.curPoint)
        count = count + 1
    end
    local field = string.sub(dfd.buf, dfd.curPoint, i-1)
    dfd.curPoint = i + 1
    return field
end

function DFDgetOneNumField(dfd, char)
    local field = DFDgetOneField(dfd, char)
    if field == nil then
        return nil
    end
    return tonumber(field)
end


function DFDunload()
    DFDnewDataFileDecode = nil
    DFDsetFile = nil
    DFDgetOneField = nil
    DFDgetOneNumField = nil
    DFDunload = nil
end