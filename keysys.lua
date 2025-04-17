local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration (EDIT THESE)
local VALID_KEYS = {
    "epickey20251"
    -- Add more keys here
}
local DISCORD_INVITE = "https://discord.gg/FshKeQQ5" -- Your Discord invite

-- UI Colors and Style
local THEME = {
    Background = Color3.fromRGB(32, 34, 37), -- Discord dark theme
    Header = Color3.fromRGB(47, 49, 54),     -- Discord channel header
    Button = Color3.fromRGB(114, 137, 218),  -- Discord blurple
    ButtonHover = Color3.fromRGB(103, 123, 196),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(185, 187, 190),
    InputBackground = Color3.fromRGB(64, 68, 75),
    Success = Color3.fromRGB(67, 181, 129),  -- Discord green
    Error = Color3.fromRGB(240, 71, 71),     -- Discord red
    Warning = Color3.fromRGB(250, 166, 26)   -- Discord yellow
}

-- Create the key system UI with improved design
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystemGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

-- Main container with drop shadow effect
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 340, 0, 240)
container.Position = UDim2.new(0.5, -170, 0.5, -120)
container.BackgroundTransparency = 1
container.Parent = gui

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 24, 1, 24)
shadow.Position = UDim2.new(0, -12, 0, -12)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993" -- Shadow asset
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.Parent = container

-- Main frame with rounded corners
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1.1, 0)
mainFrame.BackgroundColor3 = THEME.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = container

-- Rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = THEME.Header
header.BorderSizePixel = 0
header.Parent = mainFrame

-- Header corner rounding (just top corners)
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- Fix corners (make only top corners rounded)
local headerBottomFrame = Instance.new("Frame")
headerBottomFrame.Name = "BottomFrame"
headerBottomFrame.Size = UDim2.new(1, 0, 0.5, 0)
headerBottomFrame.Position = UDim2.new(0, 0, 0.5, 0)
headerBottomFrame.BackgroundColor3 = THEME.Header
headerBottomFrame.BorderSizePixel = 0
headerBottomFrame.ZIndex = 0
headerBottomFrame.Parent = header

-- Key icon
local keyIcon = Instance.new("ImageLabel")
keyIcon.Name = "KeyIcon"
keyIcon.Size = UDim2.new(0, 20, 0, 20)
keyIcon.Position = UDim2.new(0, 15, 0.5, -10)
keyIcon.BackgroundTransparency = 1
keyIcon.Image = "rbxassetid://7733715400" -- Key icon
keyIcon.ImageColor3 = THEME.Button
keyIcon.Parent = header

-- Title text
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 45, 0, 0)
title.Text = "Key Verification"
title.TextColor3 = THEME.TextPrimary
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

-- Close button
local closeButton = Instance.new("ImageButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 16, 0, 16)
closeButton.Position = UDim2.new(1, -30, 0.5, -8)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://9113926039" -- X icon
closeButton.ImageColor3 = THEME.TextSecondary
closeButton.Parent = header

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(0.9, 0, 0, 16)
subtitle.Position = UDim2.new(0.05, 0, 0, 50)
subtitle.Text = "Enter your key below to activate"
subtitle.TextColor3 = THEME.TextSecondary
subtitle.TextSize = 14
subtitle.Font = Enum.Font.Gotham
subtitle.BackgroundTransparency = 1
subtitle.Parent = mainFrame

-- Key input
local keyInput = Instance.new("TextBox")
keyInput.Name = "KeyInput"
keyInput.Size = UDim2.new(0.85, 0, 0, 36)
keyInput.Position = UDim2.new(0.5, 0, 0, 75)
keyInput.AnchorPoint = Vector2.new(0.5, 0)
keyInput.PlaceholderText = "Enter your key here..."
keyInput.Text = ""
keyInput.TextColor3 = THEME.TextPrimary
keyInput.PlaceholderColor3 = THEME.TextSecondary
keyInput.BackgroundColor3 = THEME.InputBackground
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 14
keyInput.ClearTextOnFocus = false
keyInput.Parent = mainFrame

-- Input rounded corners
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = keyInput

-- Submit button
local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(0.7, 0, 0, 36)
submitButton.Position = UDim2.new(0.5, 0, 0, 125)
submitButton.AnchorPoint = Vector2.new(0.5, 0)
submitButton.Text = "Submit Key"
submitButton.TextColor3 = THEME.TextPrimary
submitButton.BackgroundColor3 = THEME.Button
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 16
submitButton.AutoButtonColor = false
submitButton.Parent = mainFrame

-- Submit button rounded corners
local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 6)
submitCorner.Parent = submitButton

-- Discord free key section
local separator = Instance.new("Frame")
separator.Name = "Separator"
separator.Size = UDim2.new(0.8, 0, 0, 1)
separator.Position = UDim2.new(0.1, 0, 0, 175)
separator.BackgroundColor3 = THEME.Header
separator.BorderSizePixel = 0
separator.Parent = mainFrame

-- Free key text
local freeKeyText = Instance.new("TextLabel")
freeKeyText.Name = "FreeKeyText"
freeKeyText.Size = UDim2.new(0.9, 0, 0, 16)
freeKeyText.Position = UDim2.new(0.05, 0, 0, 185)
freeKeyText.Text = "Join our Discord for a FREE key!"
freeKeyText.TextColor3 = THEME.TextPrimary
freeKeyText.TextSize = 14
freeKeyText.Font = Enum.Font.GothamBold
freeKeyText.BackgroundTransparency = 1
freeKeyText.Parent = mainFrame

-- Discord button
local discordButton = Instance.new("TextButton")
discordButton.Name = "DiscordButton"
discordButton.Size = UDim2.new(0.7, 0, 0, 36)
discordButton.Position = UDim2.new(0.5, 0, 0, 205)
discordButton.AnchorPoint = Vector2.new(0.5, 0)
discordButton.Text = "Copy Discord Invite"
discordButton.TextColor3 = THEME.TextPrimary
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Discord color
discordButton.Font = Enum.Font.GothamBold
discordButton.TextSize = 16
discordButton.AutoButtonColor = false
discordButton.Parent = mainFrame

-- Discord icon
local discordIcon = Instance.new("ImageLabel")
discordIcon.Name = "DiscordIcon"
discordIcon.Size = UDim2.new(0, 20, 0, 20)
discordIcon.Position = UDim2.new(0, 10, 0.5, -10)
discordIcon.BackgroundTransparency = 1
discordIcon.Image = "rbxassetid://7733658504" -- Discord icon
discordIcon.Parent = discordButton

-- Adjust text position for icon
discordButton.TextXAlignment = Enum.TextXAlignment.Center

-- Discord button rounded corners
local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = discordButton

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.85, 0, 0, 18)
statusLabel.Position = UDim2.new(0.5, 0, 0, 165)
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.Text = ""
statusLabel.TextColor3 = THEME.TextSecondary
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

-- Entry animation
mainFrame.Position = UDim2.new(0, 0, 1, 0)
local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
openTween:Play()

-- Make the frame draggable
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function update(input)
    local delta = input.Position - dragStart
    container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = container.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Button hover effects
local function createButtonEffect(button)
    local originalColor = button.BackgroundColor3

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = THEME.ButtonHover}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = originalColor}):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset - 2)}):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset + 2)}):Play()
    end)
end

createButtonEffect(submitButton)
createButtonEffect(discordButton)

-- Close button hover effect
closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.3), {ImageColor3 = THEME.Error}):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.3), {ImageColor3 = THEME.TextSecondary}):Play()
end)

-- Function to check if a key is valid
local function isKeyValid(key)
    for _, validKey in ipairs(VALID_KEYS) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- Set status with animation
local function setStatus(message, color)
    statusLabel.Text = message
    statusLabel.TextColor3 = color or THEME.TextSecondary

    -- Subtle popup animation
    statusLabel.Position = UDim2.new(0.5, 0, 0, 170)
    statusLabel.TextTransparency = 0.2
    TweenService:Create(statusLabel, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, 0, 0, 165),
        TextTransparency = 0
    }):Play()
end

-- Close UI with animation
local function closeUI()
    local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 1, 0)})
    closeTween:Play()

    closeTween.Completed:Connect(function()
        gui:Destroy()
    end)
end

-- Button functionality
closeButton.MouseButton1Click:Connect(closeUI)

submitButton.MouseButton1Click:Connect(function()
    local key = keyInput.Text

    if key == "" then
        setStatus("Please enter a key!", THEME.Error)
        return
    end

    -- Animate button press
    TweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.ButtonHover}):Play()

    if isKeyValid(key) then
        setStatus("Key verified successfully!", THEME.Success)

        -- Success animation
        wait(1)

        -- Close with animation
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 1, 0)})
        closeTween:Play()

        closeTween.Completed:Connect(function()
            gui:Destroy()

            -- Example action upon successful verification
            print("Hello World") -- This is your example action

            -- You can put your actual script execution here
            -- For example:
            -- loadstring(game:HttpGet("https://your-script-url.com"))()
        end)
    else
        setStatus("Invalid key!", THEME.Error)

        -- Shake animation for invalid key
        local originalPos = keyInput.Position
        local shake = TweenService:Create(keyInput, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 5, originalPos.Y.Scale, originalPos.Y.Offset)})
        shake:Play()

        shake.Completed:Connect(function()
            local shakeBack = TweenService:Create(keyInput, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 10, originalPos.Y.Scale, originalPos.Y.Offset)})
            shakeBack:Play()

            shakeBack.Completed:Connect(function()
                local shakeCenter = TweenService:Create(keyInput, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = originalPos})
                shakeCenter:Play()
            end)
        end)
    end
end)

-- Also verify when pressing Enter in the text box
keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        submitButton.MouseButton1Click:Fire()
    end
end)

discordButton.MouseButton1Click:Connect(function()
    -- Copy Discord invite to clipboard
    setclipboard(DISCORD_INVITE)
    setStatus("Discord invite copied!", THEME.Success)

    -- Animate button press
    TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 80, 180)}):Play()
    wait(0.2)
    TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()

    wait(2)
    setStatus("", THEME.TextSecondary)
end)