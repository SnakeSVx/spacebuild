-- Copyright 2016 SB Dev Team (http://github.com/spacebuild)
--
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--
--        http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.


--
-- Created by IntelliJ IDEA.
-- User: Stijn
-- Date: 20/05/2016
-- Time: 19:56
-- To change this template use File | Settings | File Templates.
--

AddCSLuaFile() -- send this file to the client

local version = {
    major = 0,
    minor = 1,
    patch = 1,
    date = 20160613,
    requiredGmodVersion = 160424,
    fullVersion = function(self)
        return self.major .. "." .. self.minor .. ".".. self.patch
    end
}
if VERSION < version.requiredGmodVersion then
    error("SB Loader: Your gmod is out of date: found version ", VERSION, "required ", version.requiredGmodVersion)
end

require("log")
local log = log

SPACEBUILD = {}
local SB = SPACEBUILD
SB.log = log
SB.version = version
SB.core = {}
SB.plugins = {}
SB.constants = {}
SB.config = {}
SB.internal = {}

log.info("Starting up spacebuild " + version.fullVersion());

include("spacebuild/classes/include.lua")
include("spacebuild/shared/include.lua")

if SERVER then
    include("spacebuild/server/include.lua")

    -- We do modules manually to not the ones from other modules!
    AddCSLuaFile("includes/modules/log.lua")
    AddCSLuaFile("includes/modules/luaunit.lua")
    AddCSLuaFile("includes/modules/sbnet.lua")
    -- end modules

    include("spacebuild/shared/send.lua")
    include("spacebuild/classes/send.lua")
    include("spacebuild/client/send.lua")
    include("spacebuild/tests/shared/send.lua")
end

if CLIENT then
    include("spacebuild/client/include.lua")
end

if SERVER then
    concommand.Add("run_sb_server_tests", function()
        require("luaunit")
        local lu = luaunit
        include("spacebuild/tests/shared/include.lua")
        include("spacebuild/tests/server/include.lua")
        MsgN("Tests completed: "..lu.LuaUnit.run('-v'))
    end)
end

if CLIENT then
    concommand.Add("run_sb_client_tests", function()
        require("luaunit")
        local lu = luaunit
        include("spacebuild/tests/shared/include.lua")
        include("spacebuild/tests/client/include.lua")
        MsgN("Tests completed: "..lu.LuaUnit.run('-v'))
    end)
end

-- Prevent outside access to the SB table, to prevent any modifications to it!!
local function createReadOnlyTable(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function(t, k, v)
            error("Attempt to update a read-only table")
            --print(tostring(debug.traceback()))
        end,
        __metatable = false
    })
end

-- Load legacy auto loader files
if SERVER then
    include("caf/autostart/server/sv_caf_autostart.lua")
end

if CLIENT then
    include("caf/autostart/client/cl_caf_autostart.lua")
end
-- End load legacy auto loader files

-- Prevent outside access to internal tables
SB.log = nil
SB.version = nil
SB.core = nil
SB.plugins = nil
SB.constants = createReadOnlyTable(SB.constants)
SB.config = nil
SB.internal = nil

SB = createReadOnlyTable(SB)
SPACEBUILD = SB
