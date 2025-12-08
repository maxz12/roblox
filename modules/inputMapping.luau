local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
--make gui buttons work
local m = {}
m.__index = m

local actions = {}

function m:Bind(action: string)
	local self = setmetatable({}, m)
	
	self._name = action
	self._trove = Trove.new()
	
	actions[action] = self
	return self
end

function m:Unbind(actionName: string)
	local action = actions[actionName]
	if action and action._trove then
		action._trove:Clean()
	end
end

function m:ToKey(key)
	if not getmetatable(self) then
		warn("must use bind first on object")
	end
	
	self._trove:Connect(UserInputService.InputBegan,function(input, gpe)
		if gpe then return end

		if input.KeyCode == key then
			print(`did {self._name}`)
		end
	end)
end

function m:ToButton(btn: TextButton)
	if not getmetatable(self) then
		warn("must use bind first on object")
	end
	
	if not btn:IsA("TextButton") then
		warn("invalid button")
		return
	end
	
	self._trove:Connect(btn.Activated,function()
		print(`did {self._name}`)
	end)
end

function m:Pressed(action, callback): RBXScriptSignal
	local a = actions[action]
	if a then
		return a._trove:Connect(UserInputService.InputBegan, function(input, gpe)
			if gpe then return end
			callback()
		end)
	end
end

function m:ToKeys(...: string)
	local keys = {...}
	
	for _, key in keys do
		self._trove:Connect(UserInputService.InputBegan, function(input, gpe)
			if gpe then return end

			if input.KeyCode == key then
				print(`did {self._name}`)
			end
		end)
	end
end

return m
