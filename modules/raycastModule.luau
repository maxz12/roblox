local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debugModule = require(ReplicatedStorage.modules.debugModule)

local m = {}

type Direction = "left" | "right" | "up" | "down" | "forward" | "backward"

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp: BasePart = char:WaitForChild("HumanoidRootPart")

local params = RaycastParams.new()
params.FilterDescendantsInstances = {char}
params.FilterType = Enum.RaycastFilterType.Exclude

function m:cast(dir: Direction, dist: number, visualize: boolean?)
	dist = dist or 5
	local vecDir = Vector3.new()
	
	if dir == "left" then
		vecDir = -hrp.CFrame.RightVector
	elseif dir == "right" then
		vecDir = hrp.CFrame.RightVector
	elseif dir == "up" then
		vecDir = Vector3.new(0, 1, 0)
	elseif dir == "down" then
		vecDir = Vector3.new(0, -1, 0)
	elseif dir == "forward" then
		vecDir = hrp.CFrame.LookVector
	elseif dir == "backward" then
		vecDir = -hrp.CFrame.LookVector
	end
	
	local origin = hrp.Position
	local finalDir = vecDir * dist
	debugModule:VisualizeRay(origin, finalDir, 1, 0.05)
	return game.Workspace:Raycast(origin, finalDir, params)
end


return m
