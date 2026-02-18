local m = {}
m.__index = m

export type state = {
	onStart: (() -> ())?,
	onExit: (() -> ())?,
	onUpdate: ((dt: number) -> ())?,
	allowedTransitions: {[string]: true}
}
type stateMachine = typeof(setmetatable({} :: {
	states: {state},
	currentState: state?,
	model: Model,
}, m))

function m.new(model: Model, initialSate: string): stateMachine
	local self = setmetatable({}, m)
	self.states = {}
	self.currentState = nil
	self.allowedTransitions = {}
	self.model = model
	
	return self
end

function m:AddState(name, stateDefinition: state)
	self.states[name] = stateDefinition
end

function m:GetState(): state
	return self.currentState
end

function m:SetState(name)
	local state: state = self.states[name]
	if not state then return end
	
	--allow intial state transition
	if not self.currentState then
		self.currentState = name
		local state = self.states[name]
		if state and state.onStart then
			state.onStart()
		end
		return
	end
	
	if not self:CanTransition(self.currentState, name) then return end
	
	if self.currentState and self.states[self.currentState].OnExit then
		self.states[self.currentState].onExit()
	end
	
	self.currentState = name
	if state and state.OnStart then
		state.onStart()
	end
end

function m:OnUpdate(dt: number)
	if self.currentState then
		local state = self.states[self.currentState]
		if state.onUpdate then
			state.onUpdate(dt)
		end
	end
end

function m.AllowTransition(self: stateMachine, from: string, to: string, allow: boolean?)
	local state = self.states[from]
	if not state or not self.states[to] then return end
	
	state.allowedTransitions = state.allowedTransitions or {}
	state.allowedTransitions[to] = allow or true
end

function m:CanTransition(from, to)
	local state = self.states[from]
	if not state or not state.allowedTransitions then
		return false
	end
	return state.allowedTransitions[to] == true 
end

function m:IsInState(name): boolean
	return self.currentState == name
end

return m
