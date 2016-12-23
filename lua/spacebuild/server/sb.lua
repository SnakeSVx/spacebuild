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
-- User: stijn
-- Date: 18/06/2016
-- Time: 21:14
-- To change this template use File | Settings | File Templates.
--

local SB = SPACEBUILD
local log = SB.log
local class = SB.class
local internal = SB.internal
local time_to_next_sb_sync = SB.constants.TIME_TO_NEXT_SB_SYNC
local config = SB.config

local function AllowAdminNoclip(ply)
    if (ply:IsAdmin() or ply:IsSuperAdmin()) and config.adminspacenoclip.get() then return true end
    if ply:IsSuperAdmin() and config.superadminspacenoclip.get() then return true end
    return false
end

--- Players can't get damaged in a jeep, so kick them out
-- TODO filter for jeep entity!!
-- @param ply
--
local function JeepFix(ply)
    if ply:InVehicle() then --Kick them out of the vehicle first
    ply:ExitVehicle()
    end
end

--- Prevent players from noclipping in space if isn't not allowed
-- @param ply
--
local function NoClipCheck(ply)
    if SB.onSBMap() and ply.environment and ply.environment == SB.getSpace() and config.noclip.get() and not AllowAdminNoclip(ply) and config.planetnocliponly.get() and ply:GetMoveType() == MOVETYPE_NOCLIP then -- Now set their movetype to walk if in noclip and only admins allowed noclip.
    ply:SetMoveType(MOVETYPE_WALK)
    end
end

local sun

local function init()
    if not sun then
        sun = class.new("sb/SunEnvironment", nil, SB:getResourceRegistry())
    end
end
hook.Add("Initialize", "spacebuild.init.server.sun", init)

local function addSun(data)
    log.debug("Spawn Sun")
    --TODO spawn sunEntity
    local ent = data.ent
    sun = class.new("SunEnvironment", ent:EntIndex(), data, SB:getResourceRegistry())
end



local function spawnEnvironmentEnt(name, pos, angles)
    local ent = ents.Create(name)
    ent:SetAngles(angles)
    ent:SetPos(pos)
    ent:Spawn()
    return ent
end

local function addLegacyEnvironment(data)
    log.table(data, log.DEBUG, "adding legacy evironment")
    if data[1] == "planet" or data[1] == "planet2" or data[1] == "star" or data[1] == "star2" then
        local ent = spawnEnvironmentEnt("LegacyPlanet", data.ent:GetPos(), data.ent:GetAngles())
        local environment = class.new("sb/LegacyPlanet", ent:EntIndex(), data, SB:getResourceRegistry())
        ent.envobject = environment
        SB:addEnvironment(environment)
        ent:InitEnvironment()
    elseif data[1] == "cube" then
        local ent = spawnEnvironmentEnt("LegacyPlanet", data.ent:GetPos(), data.ent:GetAngles())
        local environment = class.new("sb/LegacyCube", ent:EntIndex(), data, SB:getResourceRegistry())
        ent.envobject = environment
        SB:addEnvironment(environment)
        ent:InitEnvironment()
    elseif data[1] == "planet_color" then
        local colorinfo = class.new("sb/LegacyColorInfo", data)
        SB:addEnvironmentColor(colorinfo)
    elseif data[1] == "planet_bloom" then
        local bloominfo = class.new("sb/LegacyBloomInfo", data)
        SB:addEnvironmentBloom(bloominfo)
    end
end

function SB:getSun()
    return sun
end

local environment_data = {}
local environment_classes = { env_sun = addSun, logic_case = addLegacyEnvironment }

local function getKey(key)
    if key == "Case01" then
        return 1
    elseif key == "Case02" then
        return 2
    elseif key == "Case03" then
        return 3
    elseif key == "Case04" then
        return 4
    elseif key == "Case05" then
        return 5
    elseif key == "Case06" then
        return 6
    elseif key == "Case07" then
        return 7
    elseif key == "Case08" then
        return 8
    elseif key == "Case09" then
        return 9
    elseif key == "Case10" then
        return 10
    elseif key == "Case11" then
        return 11
    elseif key == "Case12" then
        return 12
    elseif key == "Case13" then
        return 13
    elseif key == "Case14" then
        return 14
    elseif key == "Case15" then
        return 15
    elseif key == "Case16" then
        return 16
    else
        return key
    end
end

local function SpawnEnvironments()
    for k, v in pairs(environment_data) do
        environment_classes[v["classname"]](v)
    end
end

local function InitPostEntity( )
    log.debug("Registering environment info")
    local entities
    local data
    local values
    for k, _ in pairs(environment_classes) do
        entities = ents.FindByClass(k)
        for _, ent in ipairs(entities) do
            data = { ent = ent }
            values = ent:GetKeyValues()
            for key, value in pairs(values) do
                data[getKey(key)] = value
            end
            table.insert(environment_data, data)
        end
    end
    SpawnEnvironments()
end
hook.Add("InitPostEntity", "spacebuild.init.server.environments", InitPostEntity)

local ignoredClasses = {}
ignoredClasses["func_door"] = true
ignoredClasses["prop_combine_ball"] = true

function SB:isValidSBEntity(ent)
    return IsValid(ent)
            and not ent:IsWorld()
            and IsValid(ent:GetPhysicsObject()) -- only valid physics
            and not ent.NoGrav -- ignore entities that mentioned they want to be ignored
            and not ignoredClasses[ent:GetClass()] -- ignore certain types of entities
end

function SB:registerIgnoredEntityClass(class)
    ignoredClasses[class] = true
end

local spawned_entities = {}

local function OnEntitySpawn(ent)
    if not table.HasValue(spawned_entities, ent) then
        table.insert(spawned_entities, ent)
        timer.Simple(0.1, function()
            if SB:onSBMap() and not ent.environment and SB:isValidSBEntity(ent) then
                ent.environment = SB:getSpace()
                SB:getSpace():updateEnvironmentOnEntity(ent)
            end
        end)
    end
end
hook.Add("OnEntityCreated", "SB_OnEntitySpawn", OnEntitySpawn)

function internal.getSpawnedEntities()
    return spawned_entities
end

SB.core.sb = {

    player = {
        think = function(ply, time)
            -- SB
            if ply.lastsbupdate and ply.lastsbupdate + time_to_next_sb_sync < time then
                for _, v in pairs(internal.mod_tables) do
                    for _, w in pairs(v) do
                        w:send(ply.lastsbupdate or 0, ply)
                    end
                end
                for _, v in pairs(internal.environments) do
                    v:send(ply.lastsbupdate or 0, ply)
                end
                ply.lastsbupdate = time
            else
                ply.lastsbupdate = (-time_to_next_sb_sync)
            end
            -- Noclip from planets check?
            if ply.environment and ply.environment == SB:getSpace() and ply:Alive() then --Generic check to see if we can get space and they're alive.
            JeepFix(ply)
            NoClipCheck(ply)
            end
        end
    },
    entityRemoved = function(ent)
        if ent.envobject then
            log.debug("Removing SB Environment object pre-hook")
        end
    end

}