--[[
    GPSModule.lua
    By: Hail12Pink
    Dependencies:
        Modem
        Instrument
    Information:
        The GPSModule is a module that communicates with other supported modules to allow specific locations to be displayed on a map.
]]

local WaypointName = "GPSModule"

local Modem = GetPartFromPort(1, "Modem")
local Instrument = GetPartFromPort(1, "Instrument")

while wait(10) do
    local Position = Instrument:GetReading(6)

    Modem:SendLANMessage({
        WaypointName,
        Position
    })
end