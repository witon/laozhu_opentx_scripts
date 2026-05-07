local open = io.open

local function read(file, ...)
    return file:read(...)
end

local function write(file, ...)
    return file:write(...)
end

local function close(file)
    return file:close()
end

io = {open=open, write=write, read=read, close=close}