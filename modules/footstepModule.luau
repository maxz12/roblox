local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local RaycastModule = require(ReplicatedStorage.modules.RaycastModule)

local m = {}

type material = {
	vol: number,
	id: number,
}

export type conf = {
	[string]: material
}

m._trove = Trove.new()
m._currentMat = nil
m._conf = nil
function m:Init(conf: conf)
	self._conf = conf
	
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local hum = char:FindFirstChild("Humanoid")
	
	local interval = 0.3
	local elapsed = 0
	self._trove:Connect(RunService.Heartbeat, function(dt)
		elapsed += dt
		if elapsed < interval then return end
		
		local r = RaycastModule:cast("down", 3, true)
		if r and r.Instance then
			local mat = r.Instance:GetAttribute("Material")
			if conf[mat] ~= nil then
				self._currentMat = mat
			end
		end
		elapsed = 0
	end)
end

function m:GetMaterial(): material
	return self._currentMat
end

function m:GetMaterialData()
	return self._conf[self._currentMat]
end

function m:Cleanup()
	self._trove:Clean()
end

return m
