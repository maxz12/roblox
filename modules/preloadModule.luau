local ContentProvider = game:GetService("ContentProvider")

local PreloadController = {}

local animIds = {
	1234567,
}


-- preload animations
function PreloadController:Preload(ids)
	-- normallize input into a table
	local idList = {}

	if typeof(ids) == "number" or typeof(ids) == "string" then
		table.insert(idList, ids)
	elseif typeof(ids) == "table" then
		idList = ids
	else
		warn("[PreloadController] Invalid input to Preload()")
		return
	end

	-- create anim instances
	local animations = {}
	for _, id in ipairs(idList) do
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(id)
		table.insert(animations, anim)
	end

	-- preload on the client
	ContentProvider:PreloadAsync(animations)
	print("[Preload] Preloaded", #animations, "animations on client")
end

return PreloadController
