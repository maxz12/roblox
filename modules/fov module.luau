local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local module = {}
module. baseFOV = camera. FieldOfView
module._currentTween = nil -- Track active tween

function module:SetBaseFOV(fov)
	self.baseFOV = fov
	camera.FieldOfView = fov
end

function module:SetFOV(targetFOV, duration)
	duration = duration or 1

	-- Cancel any active tween
	if self._currentTween then
		self._currentTween:Cancel()
		self._currentTween = nil
	end

	-- Tween from current FOV, so there's no jump even if interrupted
	local goal = {FieldOfView = targetFOV}
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(camera, tweenInfo, goal)
	self._currentTween = tween

	tween:Play()
	tween.Completed:Connect(function()
		self.baseFOV = camera. FieldOfView
		self._currentTween = nil
	end)
end

function module: Impulse(intensity, duration, smoothness)
	-- intensity: how much FOV changes at peak
	-- duration: total time for the impulse
	-- smoothness: controls the easing curve (default 1)
	--   Lower values (0.1-0.5) = snappy, punchy feel
	--   Higher values (2-5) = smooth, gradual feel

	smoothness = smoothness or 1
	smoothness = math. clamp(smoothness, 0.1, 10)

	-- Cancel any existing impulse
	if self._impulseTween then
		self._impulseTween:Cancel()
		self._impulseTween = nil
	end
	if self._returnTween then
		self._returnTween:Cancel()
		self._returnTween = nil
	end

	local peakFOV = self.baseFOV + intensity

	-- Calculate durations for out and back
	-- Punch out is quick, return is based on smoothness
	local punchDuration = duration * (0.2 / smoothness)
	punchDuration = math.clamp(punchDuration, 0.01, duration * 0.5)
	local returnDuration = duration - punchDuration

	-- Punch out to peak FOV (quick and snappy)
	local punchInfo = TweenInfo.new(punchDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local punchTween = TweenService:Create(camera, punchInfo, {FieldOfView = peakFOV})
	self._impulseTween = punchTween

	punchTween:Play()
	punchTween.Completed:Connect(function()
		-- Smooth return to base FOV
		local returnStyle = smoothness > 1 and Enum.EasingStyle.Sine or Enum.EasingStyle. Quad
		local returnInfo = TweenInfo.new(returnDuration, returnStyle, Enum. EasingDirection.Out)
		local returnTween = TweenService:Create(camera, returnInfo, {FieldOfView = self.baseFOV})
		self._returnTween = returnTween

		returnTween:Play()
		returnTween.Completed:Connect(function()
			camera.FieldOfView = self. baseFOV
			self._returnTween = nil
		end)

		self._impulseTween = nil
	end)
end

function module: Shake(intensity, duration, smoothness)
	-- Smooth recoil shake - designed to be called repeatedly (full auto, etc.)
	-- intensity: how much FOV kicks (e.g., 2-5 for guns)
	-- duration: how long the shake lasts (e.g., 0.08-0.15 for guns)
	-- smoothness: how smooth the recovery is (default 1)
	--   Lower (0.3-0.8) = snappy, arcade feel
	--   Higher (1.5-3) = smooth, realistic feel

	smoothness = smoothness or 1
	smoothness = math.clamp(smoothness, 0.1, 10)

	-- Cancel any existing shake
	if self._shakeTween then
		self._shakeTween:Cancel()
		self._shakeTween = nil
	end
	if self._shakeReturnTween then
		self._shakeReturnTween:Cancel()
		self._shakeReturnTween = nil
	end

	-- Start from current FOV (allows stacking when spamming)
	local currentFOV = camera.FieldOfView
	local peakFOV = self.baseFOV + intensity

	-- If we're already above base, add less (diminishing returns for spam)
	if currentFOV > self.baseFOV then
		local overflow = currentFOV - self. baseFOV
		peakFOV = currentFOV + (intensity * math.clamp(1 - (overflow / intensity), 0.3, 1))
	end

	-- Quick kick out
	local kickDuration = duration * 0.25 / smoothness
	kickDuration = math.clamp(kickDuration, 0.01, duration * 0.4)
	local returnDuration = duration - kickDuration

	-- Kick tween - fast and responsive
	local kickInfo = TweenInfo.new(kickDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local kickTween = TweenService:Create(camera, kickInfo, {FieldOfView = peakFOV})
	self._shakeTween = kickTween

	kickTween: Play()
	kickTween.Completed:Connect(function()
		-- Smooth return - uses smoothness to control feel
		local easeStyle = Enum.EasingStyle. Sine
		if smoothness < 0.8 then
			easeStyle = Enum.EasingStyle. Quad
		elseif smoothness > 2 then
			easeStyle = Enum.EasingStyle. Cubic
		end

		local returnInfo = TweenInfo.new(returnDuration * smoothness, easeStyle, Enum.EasingDirection.Out)
		local returnTween = TweenService:Create(camera, returnInfo, {FieldOfView = self.baseFOV})
		self._shakeReturnTween = returnTween

		returnTween:Play()
		returnTween.Completed:Connect(function()
			camera.FieldOfView = self. baseFOV
			self._shakeReturnTween = nil
		end)

		self._shakeTween = nil
	end)
end

function module:StopShake()
	-- Immediately stop any active shake and return to base
	if self._shakeTween then
		self._shakeTween:Cancel()
		self._shakeTween = nil
	end
	if self._shakeReturnTween then
		self._shakeReturnTween:Cancel()
		self._shakeReturnTween = nil
	end

	-- Quick smooth return to base
	local returnInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local returnTween = TweenService:Create(camera, returnInfo, {FieldOfView = self.baseFOV})
	returnTween:Play()
end

function module:GetBaseFov()
	return self.baseFOV
end

return module
