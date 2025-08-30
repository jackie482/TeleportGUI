local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
-- GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportCircleGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui
-- Circular BRING button
local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(0, 100, 0, 50)
bringBtn.Position = UDim2.new(0.5, -50, 0.85, -50)
bringBtn.BackgroundColor3 = Color3.fromRGB(180, 255, 180) -- Light green
bringBtn.Text = "Teleport"
bringBtn.TextColor3 = Color3.new(1, 1, 1)
bringBtn.TextScaled = true
bringBtn.Font = Enum.Font.GothamBold
bringBtn.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = bringBtn
-- Drag logic for button
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
listFrame.Size = UDim2.new(0, 260, 0, 260)
listFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
listFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)  -- Dark green
listFrame.Visible = false
listFrame.Parent = screenGui
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 12)
-- Title bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 70, 0)  -- Slightly darker green
titleBar.Parent = listFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Players in Game"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = titleBar
-- Panel dragging logic
local panelDragging = false
local panelDragStart, panelStartPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panelDragging = true
        panelDragStart = input.Position
        panelStartPos = listFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                panelDragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if panelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - panelDragStart
        listFrame.Position = UDim2.new(
            panelStartPos.X.Scale,
            panelStartPos.X.Offset + delta.X,
            panelStartPos.Y.Scale,
            panelStartPos.Y.Offset + delta.Y
        )
    end
end)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 100)  -- Green scrollbar
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = listFrame
-- Refresh player list
local function updatePlayerList()
    scroll:ClearAllChildren()
    local y = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 30)
        label.Position = UDim2.new(0, 5, 0, y)
        label.BackgroundColor3 = Color3.fromRGB(0, 150, 0)  -- Lighter green for player entries
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextScaled = true
        label.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        label.Parent = scroll
        
        -- Add corner radius to player entries
        local entryCorner = Instance.new("UICorner")
        entryCorner.CornerRadius = UDim.new(0, 8)
        entryCorner.Parent = label
        
        y += 35
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
Players.PlayerRemoving:Connect(updatePlayerList)  -- This line was incomplete in your script
