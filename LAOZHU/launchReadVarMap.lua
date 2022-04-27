local this = {}

local function readLaunchAlt()
    playNumber(this.f3kState.getLaunchAlt(), 9)
end

this[1] = readLaunchAlt
this[2] = readLaunchAlt
this[3] = readLaunchAlt
this[4] = readLaunchAlt
this.f3kState = nil

return this

