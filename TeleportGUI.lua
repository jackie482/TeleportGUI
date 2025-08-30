local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BringCircleGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- Circular BRING button
local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(0, 100, 0, 100)
bringBtn.Position = UDim2.new(0.5, -50, 0.85, -50)
bringBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
bringBtn.Text = "BRING"
bringBtn.TextColor3 = Color3.new(1, 1, 1)
bringBtn.TextScaled = true
bringBtn.Font = Enum.Font.GothamBold
bringBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = bringBtn

-- Drag logic
local dragging = false
local dragStart, startPos
bringBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = bringBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        bringBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Player list popup
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0, 300, 0, 300)
listFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
listFrame.Visible = false
listFrame.Parent = screenGui
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Players in Game"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = listFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = listFrame

-- Teleport success message
local function showTeleportMessage()
    local message = Instance.new("TextLabel")
    message.Name = "TeleportMessage"
    message.Size = UDim2.new(0, 300, 0, 50)
    message.Position = UDim2.new(0.5, -150, 0.4, 0)
    message.BackgroundTransparency = 0.3
    message.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    message.Text = "Teleport Successful!"
    message.TextColor3 = Color3.new(1, 1, 1)
    message.Font = Enum.Font.GothamBold
    message.TextScaled = true
    message.Parent = screenGui
    
    -- Add rounded corners
    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 12)
    msgCorner.Parent = message
    
    -- Fade out animation
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(message, tweenInfo, {
        TextTransparency = 1,
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Remove after animation
    tween.Completed:Connect(function()
        message:Destroy()
    end)
end

-- Refresh player list
local function updatePlayerList()
    scroll:ClearAllChildren()
    local y = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then  -- Exclude local player
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Position = UDim2.new(0, 5, 0, y)
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.Gotham
            button.TextScaled = true
            button.Text = player.DisplayName
            button.Parent = scroll
            
            -- Add corner to buttons
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = button
            
            -- Teleport when clicked
            button.MouseButton1Click:Connect(function()
                local targetChar = player.Character
                local localChar = LocalPlayer.Character
                
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and 
                   localChar and localChar:FindFirstChild("HumanoidRootPart") then
                    -- Teleport player
                    localChar:MoveTo(targetChar.HumanoidRootPart.Position)
                    
                    -- Show success message
                    showTeleportMessage()
                    
                    -- Hide player list
                    listFrame.Visible = false
                end
            end)
            
            y += 35
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Toggle list on button click
bringBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then
        updatePlayerList()
    end
end)

-- Update player list when players join/leave
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Initial update
updatePlayerList()
