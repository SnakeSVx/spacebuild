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
-- Date: 27/12/12
-- Time: 23:30
-- To change this template use File | Settings | File Templates.
--

include("baseenvironment.lua")

-- Class Specific
local C = CLASS

-- Function Refs
local funcRef = {
	isA = C.isA,
	init = C.init,
	sendContent = C._sendContent,
	receiveSignal = C.receive,
	onSave = C.onSave,
	onLoad = C.onLoad
}

local DEFAULT_SUN_POSITION = Vector(0, 0, 0)

--- General class function to check is this class is of a certain type
-- @param className the classname to check against
--
function C:isA(className)
	return funcRef.isA(self, className) or className == "SunEnvironment"
end

function C:getPos()
	return (self:getEntity() and self:getEntity():GetPos()) or DEFAULT_SUN_POSITION
end

