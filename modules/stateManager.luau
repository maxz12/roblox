local stateManager = {}

local states = {}

function stateManager.SetState(plr, stateKey : string, value : boolean, duration : number?)
	--check if plr is nil
	assert(plr, "plr is nil")
	
	if not states[plr] then
		states[plr] = {}
	end
	states[plr][stateKey] = value
	
	--check if duration was set 
	if duration then
		if type(duration) == "number" then
			task.delay(duration,  function()
				if states[plr] then
					states[plr][stateKey] = nil
					
					--if there anrent any player states left, remove the table
					if next(states[plr]) == nil then
						states[plr] = nil
					end
				end
			end)
		end
	end
end

function stateManager.GetState(plr)
	if states[plr] then
		return states[plr]
	else
		return warn(("no state found for %s"):format(plr))
	end
end

function stateManager.ClearState(plr)
	if states[plr] then
		states[plr] = nil
	else
		return warn(("no state found for %s"):format(plr))
	end
end

return stateManager
