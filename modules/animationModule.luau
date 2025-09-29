local AnimController = {}

local function getAnimator(char: Instance)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Name = "Animator"
        animator.Parent = humanoid
    end

    return animator
end

function AnimController.PlayAnimation(
    char: Instance,
    animId: number,
    looped: boolean?,
    speed: number?,
    onEnd: (() -> ())?,
    markerCallbacks: { [string]: () -> () }?
)
    local animator = getAnimator(char)
    if not animator then return nil end

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animId

    local track = animator:LoadAnimation(animation)
    track.Looped = looped or false

    if speed then
        track:AdjustSpeed(speed)
    end

    -- Hook animation end
    if typeof(onEnd) == "function" then
        track.Stopped:Connect(onEnd)
    end

    -- Hook keyframe markers
    if typeof(markerCallbacks) == "table" then
        for markerName, cb in pairs(markerCallbacks) do
            if typeof(cb) == "function" then
                track:GetMarkerReachedSignal(markerName):Connect(cb)
            end
        end
    end

    track:Play()
    return track
end

-- Set an animation to stop looping or stop it right away
function AnimController.UnloopAnimation(char: Instance, animId: number, stopAfter: boolean?)
    local animator = getAnimator(char)
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Animation.AnimationId == "rbxassetid://" .. tostring(animId) then
            track.Looped = false
            if stopAfter then
                track:Stop()
            end
        end
    end
end

-- Stop all animations on a character
function AnimController.StopAllAnimations(char: Instance)
    local animator = getAnimator(char)
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

return AnimController
