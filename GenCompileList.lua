-- lua
require "lfs"

local searchPath = "."

local blackList = {
	"GenCompileList.lua",
	"CompileFiles.lua",
    "competition_lib",
    "TELEMETRY\\pando.lua",
	"TELEMETRY\\testf.lua",
	"TELEMETRY\\testo.lua",
	"CompetitionBroadcast",
}
-- get filename
local function checkBlackList(file)
	for i, black in pairs(blackList) do
		if string.find(file, black) then
            print("find", file)
			return true
		end
	end
	return false
end

local function getFileName(str)
    local idx = str:match(".+()%.%w+$")
    if (idx) then
        return str:sub(1, idx - 1)
    else
        return str
    end
end

-- get file postfix
local function getExtension(str)
    return str:match(".+%.(%w+)$")
end

local function fun(rootpath, fileList)
    for entry in lfs.dir(rootpath) do
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath .. '\\' .. entry
            local attr = lfs.attributes(path)
            local filename = getFileName(entry)
            if attr.mode ~= 'directory' then
                local postfix = getExtension(entry)
                if not postfix then
                    postfix = ""
                end
                if postfix == "lua" then
                    local file = string.sub(path, string.len(searchPath) + 2)
		    if not checkBlackList(file) then
			fileList[#fileList + 1] = file
		    end
                end
            else
                fun(path, fileList)
            end
        end
    end
end

local fileList = {}
fun(searchPath, fileList)

local f = io.open("CompileFiles.lua", "w")
io.output(f)

io.write("local files = {\r\n")

for k, v in pairs(fileList) do
	io.write('\t"')
    v = string.gsub(v, "\\", "/")
	io.write(v)
	io.write('",\r\n')
end
io.write("}\r\n")
io.write("return files")


