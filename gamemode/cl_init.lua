
-- Copyright (C) 2012-2013 Spacebuild Development Team
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local GM = GM

include("shared.lua") --Initialize the shared code first

local BaseClass = GM:GetBaseClass()

CreateConVar("SB_TemperatureScale", "K") -- Set temperature scale, default = K(elvin), other values are C(elcius) and F(ahrenheit)

GM.convars.log = {
	get = function() return GetConVar("SB_TemperatureScale"):GetString() end,
	set = function(val) game.ConsoleCommand("SB_TemperatureScale", tostring(val)) end
}

include("vgui/init.lua")
include("client/init.lua")
include("test.lua")

