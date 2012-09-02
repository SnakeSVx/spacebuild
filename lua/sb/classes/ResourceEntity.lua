---
-- Project: SB Core
-- User: Stijn Vlaes
-- Date: 18/09/11
-- Time: 1:22
-- License: http://creativecommons.org/licenses/by-sa/3.0/
---

include("sb/classes/ResourceContainer.lua")

-- Lua Specific
local type  = type

-- Gmod specific
local Entity    = Entity
local CurTime   = CurTime
local net       = net

-- Class Specific
local C = CLASS
local sb = sb;

-- Function Refs
local funcRef = {
	
	isA = C.isA,
	init = C.init,
	addResource = C.addResource,
	removeResource = C.removeResource,
	supplyResource = C.supplyResource,
	consumeResource = C.consumeResource,
	getResourceAmount = C.getResourceAmount,
	getMaxResourceAmount = C.getMaxResourceAmount,
	sendSignal = C.send, --Less Ambiguous networking functions
	receiveSignal = C.receive

}

function C:isA(className)
	return funcRef.isA(self, className) or className == "ResourceEntity"
end

function C:init(entID)
	if entID and type(entID) ~= "number" then error("You have to supply the entity id or nil to create a ResourceEntity") end
	funcRef.init(self)
	self.entID = entID
	self.network = nil
end

function C:addResource(name, maxAmount, amount)
	funcRef.addResource(self, name, maxAmount, amount)
	if self.network then
		self.network:addResource(name, maxAmount, amount)
	end
end

function C:removeResource(name, maxAmount, amount)
	funcRef.removeResource(self, name, maxAmount, amount)
	if self.network then
		self.network:removeResource(name, maxAmount, amount)
	end
end

function C:supplyResource(name, amount)
	if self.network then
		return self.network:supplyResource(name, amount)
	end
	return funcRef.supplyResource(self, name, amount)
end

function C:consumeResource(name, amount)
	if self.network then
		return self.network:consumeResource(name, amount)
	end
	return funcRef.supplyResource(self, name, amount)
end

function C:getResourceAmount(name)
	if self.network then
		return self.network:getResourceAmount(name)
	end
	return funcRef.getResourceAmount(self, name);
end

function C:getMaxResourceAmount(name, visited)
	if self.network then
		return self.network:getMaxResourceAmount(name, visited)
	end
	return funcRef.getMaxResourceAmount(self, name)
end

function C:link(container, dont_link)
	if not container.isA or not container:isA("ResourceContainer") then error("We can only link ResourceContainer (and derivate) classes") end
	if not container:isA("ResourceNetwork") then
		error("ResourceEntity: We only support links between entities and networks atm!")
	end
	self.network = container;
	if not dont_link then
		container:link(self, true);
	end
	self.modified = CurTime()
end

function C:unlink(container, dont_unlink)
	if not container.isA or not container:isA("ResourceContainer") then error("We can only unlink ResourceContainer (and derivate) classes") end
	if not container:isA("ResourceNetwork") then
		error("ResourceEntity: We only support links between entities and networks atm!")
	end
	self.network = nil
	if not dont_unlink then
		container:unlink(self, true);
	end
	self.modified = CurTime()
end

function C:canLink(container)
	return container.isA and container:isA("ResourceNetwork")
end

function C:getEntity()
	return self.entID and Entity(self.entID);
end

function C:getNetwork()
	return self.network
end

function C:send(modified, ply, partial)
	if not partial then
		net.Start("SBRU")
		net.WriteString("ResourceEntity")
		net.WriteShort(self.syncid)
		net.WriteShort(self.entID)
	end
	funcRef.sendSignal(self, modified, ply, true);
	-- Add specific class code here
	if not partial then
		if ply then
		    net.Send(ply )
			--net.Broadcast()
		else
		    net.Broadcast()
		end
	end
end

function C:receive(um)
	self.entID = net.ReadShort()
	funcRef.receiveSignal(self, um)
end
