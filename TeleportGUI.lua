local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- Main movable frame (made smaller)
local teleportFrame = Instance.new("Frame")
teleportFrame.Size = UDim2.new(0, 220, 0, 250)  -- Reduced from 300x350 to 220x250
teleportFrame.Position = UDim2.new(0.5, -110, 0, 20)  -- Middle-top position
teleportFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
teleportFrame.Active = true
teleportFrame.Parent = screenGui
Instance.new("UICorner", teleportFrame).CornerRadius = UDim.new(0, 10)  -- Slightly smaller corner

-- Store the last position of the frame
local lastFramePosition = teleportFrame.Position

-- Drag logic for main frame
local dragging = false
local dragStart, startPos
teleportFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = teleportFrame.Position
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
        teleportFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Title label (smaller)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)  -- Reduced from 40 to 30
title.BackgroundTransparency = 1
title.Text = "Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = teleportFrame

-- "Show Players" button (smaller)
local pressBtn = Instance.new("TextButton")
pressBtn.Size = UDim2.new(0.7, 0, 0, 30)  -- Reduced from 40 to 30 height
pressBtn.Position = UDim2.new(0.15, 0, 0, 40)  -- Adjusted position
pressBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
pressBtn.Text = "Show Players"
pressBtn.TextColor3 = Color3.new(1, 1, 1)
pressBtn.TextScaled = true
pressBtn.Font = Enum.Font.GothamBold
pressBtn.Parent = teleportFrame
Instance.new("UICorner", pressBtn).CornerRadius = UDim.new(0, 8)  -- Smaller corner

-- Player list container (smaller)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 0, 150)  -- Reduced from 220 to 150 height
scroll.Position = UDim2.new(0, 8, 0, 80)  -- Adjusted position
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5  -- Thinner scrollbar
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Visible = false
scroll.Parent = teleportFrame

-- Function to teleport local player to target player
local function teleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport the local player to the target player
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
            
            -- Visual feedback - flash the screen
            local flash = Instance.new("Frame")

flash.Size = UDim2.new(1, 0, 1, 0)
            flash.Position = UDim2.new(0, 0, 0, 0)
            flash.BackgroundColor3 = Color3.new(1, 1, 1)
            flash.BackgroundTransparency = 1
            flash.Parent = screenGui
            
            -- Animate the flash
            local tween = TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 0})
            tween:Play()
            tween.Completed:Connect(function()
                TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                game:GetService("Debris"):AddItem(flash, 0.6)
            end)
        end
    end
end

-- Function to update player list
local function updatePlayerList()
    scroll:ClearAllChildren()
    local y = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip the local player
        if player ~= LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, -8, 0, 25)  -- Reduced from 30 to 25 height
            playerButton.Position = UDim2.new(0, 4, 0, y)
            playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
            playerButton.TextColor3 = Color3.new(1, 1, 1)
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextScaled = true
            playerButton.Text = player.DisplayName
            playerButton.Parent = scroll
            
            -- Add corner to buttons
            Instance.new("UICorner", playerButton).CornerRadius = UDim.new(0, 5)  -- Smaller corner
            
            -- Add hover effect
            playerButton.MouseEnter:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(90, 90, 140)
            end)
            
            playerButton.MouseLeave:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
            end)
            
            -- Add click functionality - TELEPORT TO PLAYER
            playerButton.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
            
            y += 28  -- Reduced spacing from 35 to 28
        end
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Toggle list on button click
pressBtn.MouseButton1Click:Connect(function()
    scroll.Visible = not scroll.Visible
    if scroll.Visible then
        updatePlayerList()
    end
end)

-- Auto-refresh using a more efficient method
local lastRefresh = nil
local refreshConnection
local function startAutoRefresh()
    if refreshConnection then
        refreshConnection:Disconnect()
    end
    
    refreshConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if scroll.Visible then
            -- Only update every 10 seconds
            if not lastRefresh or os.time() - lastRefresh >= 10 then
                updatePlayerList()
                lastRefresh = os.time()
            end
        end
    end)
end
startAutoRefresh()

-- Toggle button (smaller)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 25, 0, 25)  -- Reduced from 30x30 to 25x25
toggleBtn.Position = UDim2.new(0, 4, 0, 4)  -- Adjusted position
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
toggleBtn.Text = "🔽"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = teleportFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local expanded = true
toggleBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    scroll.Visible = expanded
    toggleBtn.Text = expanded and "🔽" or "▶"
end)

-- Close button (smaller)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)  -- Reduced from 30x30 to 25x25

closeBtn.Position = UDim2.new(1, -29, 0, 4)  -- Adjusted position
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = teleportFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Open button (appears when main panel is closed)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0.5, -20, 0, 20)  -- Middle-top position
openBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
openBtn.Text = ">>"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false  -- Initially hidden
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- Drag logic for open button
local openDragging = false
local openDragStart, openStartPos
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openDragging = true
        openDragStart = input.Position
        openStartPos = openBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                openDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if openDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - openDragStart
        openBtn.Position = UDim2.new(
            openStartPos.X.Scale,
            openStartPos.X.Offset + delta.X,
            openStartPos.Y.Scale,
            openStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Close button functionality
closeBtn.MouseButton1Click:Connect(function()
    -- Reset both the main frame and open button to middle-top
    lastFramePosition = UDim2.new(0.5, -110, 0, 20)  -- Middle-top position for main frame
    teleportFrame.Position = lastFramePosition
    openBtn.Position = UDim2.new(0.5, -20, 0, 20)  -- Middle-top position for open button
    
    teleportFrame.Visible = false
    openBtn.Visible = true
end)

-- Open button functionality
openBtn.MouseButton1Click:Connect(function()
    -- Restore the frame to its last position (which is now middle-top)
    teleportFrame.Position = lastFramePosition
    teleportFrame.Visible = true
    openBtn.Visible = false
end)

-- Update player list when players join or leave
Players.PlayerAdded:Connect(function()
    if scroll.Visible then
        updatePlayerList()
    end
end)

Players.PlayerRemoving:Connect(function()
    if scroll.Visible then
        updatePlayerList()
    end
end)
