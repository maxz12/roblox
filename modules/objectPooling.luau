local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local objectPooling = {}
objectPooling.__index = objectPooling

export type objectPool = {
	--attributes
	size: number,
	template: Instance,
	_pool: {Instance},
	worldFolder: Folder,
	
	--methods
	new: (config: poolConf) -> objectPool,
	GetObject: (self: objectPool) -> Instance,
	ReturnObject: (self: objectPool, object: Instance) -> (),
	CleanPool: (self: objectPool) -> (),
}

export type poolConf = {
	size: number,
	template: Instance,
	lockedSize: boolean,
	name: string,
	
}

function objectPooling.new(config: poolConf): objectPool
	assert(config.template, "invalid template for pool")
	
	local self = setmetatable({}, objectPooling)
	self.size = config.size or 20
	self.template = config.template
	self.lockedSize = (config.lockedSize == nil) and true or config.lockedSize
	
	local folder = Instance.new("Folder")
	folder.Parent = workspace
	folder.Name = config.name or `pool_{(RunService:IsClient() and "cli") or "serv"}`
	self.worldFolder = folder
	
	self._pool = {}
	
	self:_createPool()
	return self
end

function objectPooling:_createPool()
	for i = 1, self.size do
		local obj: Instance = self.template:Clone()
		obj.Parent = nil
		obj:SetAttribute("Active", false)
		table.insert(self._pool, obj)
	end
end

function objectPooling:_createObject()
	local obj: Instance = self.template:Clone()
	obj:SetAttribute("Active", true)
	
	table.insert(self._pool, obj)
	return obj
end

function objectPooling:GetObject()
	local object = nil
	local index
	for i, obj: Instance in ipairs(self._pool) do
		if obj:GetAttribute("Active") == false then
			obj:SetAttribute("Active", true)
			object = obj	
			index = i
			break
		end
	end
	
	if object == nil then
		if self.lockedSize == false then
			object = self:_createObject()
			index = #self._pool
		else
			warn("no available objects in pool")
			return nil
		end
	end
	
	object.Parent = self.worldFolder
	object.Name = `poolObject_{index}`
	return object
end

function objectPooling:ReturnObject(obj: Instance, delayTime: number?)
	local function retObj()
		obj.Parent = nil
		obj:SetAttribute("Active", false)
	end
	if delayTime then
		task.delay(delayTime, function()
			retObj()
		end)
	else
		retObj()
	end
end

function objectPooling:CleanPool()
	for _, obj in ipairs(self._pool) do
		obj:Destroy()
	end
	self._pool = {}
end
	
return objectPooling
