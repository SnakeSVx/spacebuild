--[[
Copyright (C) 2012-2013 Spacebuild Development Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ]]


local const = sb.core.const
local util = sb.core.util;
local math = math

util.SCOPES = {
    SERVER = "server/",
    CLIENT = "client/",
    SHARED = ""
}

util.createReadOnlyTable = function(t)
    return setmetatable({},{
        __index = t,
        __newindex = function (t,k,v)
            print("Attempt to update a read-only table")
        end,
        __metatable = false
    })
end

util.mergeTable = function(base,ext)

        for k,v in pairs(base) do
            if ext[k] == nil then
                ext[k] = v
            end
        end
        return ext
end

util.calculateOxygenRequired = function(pressure)
    pressure = math.ceil(pressure - const.PRESSURE_SAFE_MAX)
    if pressure < 0 then
       pressure = 0
    end
    return const.BASE_OXYGEN_USE + pressure
end

util.calculateEnergyRequired = function(temperature)
   temperature = math.ceil((const.TEMPERATURE_SAFE_MIN - temperature)/20)
   if temperature < 0 then
       temperature = 0
   end
   return const.BASE_ENERGY_USE + temperature
end

util.calculateCoolantRequired = function(temperature)
    temperature = math.ceil((temperature - const.TEMPERATURE_SAFE_MAX)/20)
    if temperature < 0 then
        temperature = 0
    end
    return const.BASE_COOLANT_USE + temperature
end


