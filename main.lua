-- Project: bat (Universal Admin Panel)
-- Version: 2.0 (Enhanced)
-- Compatibility: Xeno / Universal Executors
-- Design: Minimalist / ASCII / Calm
-- File: main.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService)
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    Title = "bat",
    Version = "v2.0",
    MenuKey = Enum.KeyCode.K, -- Default menu key
    AccentColor = Color3.fromRGB(0, 255, 128), -- Calm Green
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    TabBackgroundColor = Color3.fromRGB(30, 30, 30),
    ElementBackgroundColor = Color3.fromRGB(36, 36, 36),
    TextColor = Color3.fromRGB(255, 255, 255),
    MutedTextColor = Color3.fromRGB(150, 150, 150),
    FontFace = Font.new("rbxassetid://10846750432"), -- Monospace/ASCII font
    IconAssetId = "rbxassetid://0", -- REPLACE THIS WITH YOUR IMAGE ID
}

-- State Variables
local isMenuOpen = true
local noclipEnabled = false
local speedEnabled = false
local speedValue = 16
local aimlockEnabled = false
local aimStrength = 0.15
local maxDistance = 150
local triggerbotEnabled = false
local espEnabled = false
local fovValue = 70
local dashPower = 50
local dashCooldown = false
local targetPlayer = nil
local isLocked = false
local ESPObjects = {}

-- Utility Functions
local function createUIInstance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- GUI Creation
local ScreenGui = createUIInstance("ScreenGui", {
    Name = "bat_admin_panel",
    Parent = LocalPlayer:WaitForChild("PlayerGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 100
})

-- Main Frame
local MainFrame = createUIInstance("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 400, 0, 500),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = CONFIG.BackgroundColor,
    BorderColor3 = CONFIG.AccentColor,
    BorderThickness = 1
})

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = CONFIG.AccentColor
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = createUIInstance("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = CONFIG.TabBackgroundColor,
    BorderThickness = 0
})

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, 0)
TitleFix.BackgroundColor3 = CONFIG.TabBackgroundColor
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = createUIInstance("TextLabel", {
    Name = "TitleLabel",
    Parent = TitleBar,
    Size = UDim2.new(0.5, -50, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "> bat_admin_panel " + CONFIG.Version,
    Font = CONFIG.FontFace,
    TextSize = 16,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

local CloseButton = createUIInstance("TextButton", {
    Name = "CloseButton",
    Parent = TitleBar,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -34, 0, 5),
    BackgroundColor3 = CONFIG.ElementBackgroundColor,
    BorderSizePixel = 0,
    Text = "X",
    Font = CONFIG.FontFace,
    TextSize = 16,
    TextColor3 = CONFIG.MutedTextColor
})

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function() CloseButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
CloseButton.MouseLeave:Connect(function() CloseButton.BackgroundColor3 = CONFIG.ElementBackgroundColor end)
CloseButton.MouseButton1Click:Connect(function()
    isMenuOpen = false
    MainFrame.Visible = false
end)

-- Tab Container
local TabContainer = createUIInstance("Frame", {
    Name = "TabContainer",
    Parent = MainFrame,
    Size = UDim2.new(1, -16, 0, 40),
    Position = UDim2.new(0, 8, 0, 45),
    BackgroundTransparency = 1,
    BorderThickness = 0
})

-- Content Container
local ContentContainer = createUIInstance("Frame", {
    Name = "ContentContainer",
    Parent = MainFrame,
    Size = UDim2.new(1, -16, 1, -95),
    Position = UDim2.new(0, 8, 0, 90),
    BackgroundTransparency = 1,
    BorderThickness = 0
})

local ContentFrame = createUIInstance("ScrollingFrame", {
    Name = "ContentFrame",
    Parent = ContentContainer,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = CONFIG.MutedTextColor,
    ClipsDescendants = true
})

local ContentListLayout = Instance.new("UIListLayout")
ContentListLayout.Padding = UDim.new(0, 6)
ContentListLayout.Parent = ContentFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 4)
ContentPadding.Parent = ContentFrame

-- Tab Creation
local allTabs = {}
local allPages = {}
local currentPage = nil

local function createTab(name, order)
    local tabButton = createUIInstance("TextButton", {
        Name = name,
        Parent = TabContainer,
        Size = UDim2.new(1/3, -5, 0, 30),
        Position = UDim2.new((order-1)/3, 0, 0, 0),
        BackgroundColor3 = CONFIG.ElementBackgroundColor,
        BorderSizePixel = 0,
        Text = name,
        Font = CONFIG.FontFace,
        TextSize = 12,
        TextColor3 = CONFIG.MutedTextColor
    })
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    local pageFrame = createUIInstance("Frame", {
        Name = name,
        Parent = ContentFrame,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    allTabs[#allTabs + 1] = tabButton
    allPages[#allPages + 1] = pageFrame
    
    tabButton.MouseButton1Click:Connect(function()
        for i, tab in ipairs(allTabs) do
            local isActive = tab == tabButton
            tab.BackgroundColor3 = isActive and Color3.fromRGB(42, 42, 42) or CONFIG.ElementBackgroundColor
            tab.TextColor3 = isActive and CONFIG.AccentColor or CONFIG.MutedTextColor
            allPages[i].Visible = isActive
        end
    end)
    
    return pageFrame
}

-- UI Elements
local function createToggle(parent, text, default, callback)
    local frame = createUIInstance("Frame", {
        Name = "ToggleFrame",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CONFIG.ElementBackgroundColor,
        BorderSizePixel = 0
    })
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = createUIInstance("TextLabel", {
        Name = "Label",
        Parent = frame,
        Size = UDim2.new(1, -56, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = CONFIG.FontFace,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local state = default
    local toggle = createUIInstance("TextButton", {
        Name = "Toggle",
        Parent = frame,
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -50, 0.5, -11),
        BackgroundColor3 = state and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 0,
        Text = ""
    })
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = createUIInstance("Frame", {
        Name = "Knob",
        Parent = toggle,
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(65, 65, 65)
        knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        if callback then callback(state) end
    end)
    
    return frame
}

local function createSlider(parent, text, min, max, default, callback)
    local frame = createUIInstance("Frame", {
        Name = "SliderFrame",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = CONFIG.ElementBackgroundColor,
        BorderSizePixel = 0
    })
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = createUIInstance("TextLabel", {
        Name = "Label",
        Parent = frame,
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Text = text,
        Font = CONFIG.FontFace,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valLabel = createUIInstance("TextLabel", {
        Name = "ValueLabel",
        Parent = frame,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -72, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = CONFIG.FontFace,
        TextSize = 13,
        TextColor3 = CONFIG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderBg = createUIInstance("Frame", {
        Name = "SliderBG",
        Parent = frame,
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0
    })
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = createUIInstance("Frame", {
        Name = "SliderFill",
        Parent = sliderBg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 120),
        BorderSizePixel = 0
    })
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderBtn = createUIInstance("TextButton", {
        Name = "SliderBtn",
        Parent = sliderBg,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    local sliding = false
    
    sliderBtn.MouseButton1Down:Connect(function()
        sliding = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    sliderBtn.MouseMoved:Connect(function(x)
        if not sliding then return end
        local relX = math.clamp((x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        local val = min + (max - min) * relX
        valLabel.Text = string.format("%.2f", val)
        if callback then callback(val) end
    end)
    
    sliderBtn.MouseButton1Down:Connect(function()
        local x = UserInputService:GetMouseLocation().X
        local relX = math.clamp((x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        local val = min + (max - min) * relX
        valLabel.Text = string.format("%.2f", val)
        if callback then callback(val) end
    end)
    
    return frame
}

-- Tabs
local homePage = createTab("Home", 1)
local combatPage = createTab("Combat", 2)
local visualsPage = createTab("Visuals", 3)

-- Home Page Content
local homeTitle = createUIInstance("TextLabel", {
    Name = "HomeTitle",
    Parent = homePage,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "-- System Control --",
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

createToggle(homePage, "Noclip", false, function(s)
    noclipEnabled = s
end)

createToggle(homePage, "Speed Hack", false, function(s)
    speedEnabled = s
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = s and speedValue or 16
        end
    end
end)

createSlider(homePage, "Speed Value", 16, 500, 16, function(val)
    speedValue = val
    if speedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speedValue
        end
    end
end)

-- Combat Page Content
local combatTitle = createUIInstance("TextLabel", {
    Name = "CombatTitle",
    Parent = combatPage,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "-- Combat Assistance --",
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

createToggle(combatPage, "Aimlock", false, function(s)
    aimlockEnabled = s
    if not s then
        isLocked = false
        targetPlayer = nil
    end
end)

createSlider(combatPage, "Aim Strength", 0.01, 1, 0.15, function(val)
    aimStrength = val
end)

createSlider(combatPage, "Max Distance", 10, 1000, 150, function(val)
    maxDistance = val
end)

createToggle(combatPage, "Triggerbot", false, function(s)
    triggerbotEnabled = s
end)

createSlider(combatPage, "Dash Power", 10, 500, 50, function(val)
    dashPower = val
end)

-- Visuals Page Content
local visualsTitle = createUIInstance("TextLabel", {
    Name = "VisualsTitle",
    Parent = visualsPage,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "-- Visual Enhancements --",
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

createToggle(visualsPage, "ESP (Highlight)", false, function(s)
    espEnabled = s
    if not s then
        for p, _ in pairs(ESPObjects) do
            if ESPObjects[p].Highlight and ESPObjects[p].Highlight.Parent then
                ESPObjects[p].Highlight:Destroy()
            end
            ESPObjects[p] = nil
        end
    end
end)

createSlider(visualsPage, "FOV Changer", 30, 120, 70, function(val)
    fovValue = val
    Camera.FieldOfView = fovValue
end)

-- Initialize
homePage.Visible = true
for i, tab in ipairs(allTabs) do
    local isActive = i == 1
    tab.BackgroundColor3 = isActive and Color3.fromRGB(42, 42, 42) or CONFIG.ElementBackgroundColor
    tab.TextColor3 = isActive and CONFIG.AccentColor or CONFIG.MutedTextColor
    allPages[i].Visible = isActive
end

-- Dragging Logic
local dragging = false
local dragInput, mousePos, framePos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- Functional Logic
local function applySpeed()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speedEnabled and speedValue or 16
        end
    end
end

local function doDash()
    if dashCooldown or not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    dashCooldown = true
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
    bv.Velocity = Camera.CFrame.LookVector * dashPower
    bv.Parent = hrp
    
    task.wait(0.15)
    bv.Parent = nil
    task.wait(2) -- Cooldown
    dashCooldown = false
end

local function getNearestPlayer()
    local nearest, nearestDist = nil, 300
    local center = Camera.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist3D = (head.Position - Camera.CFrame.Position).Magnitude
                    if dist3D <= maxDistance then
                        local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                        if d < nearestDist then nearestDist = d nearest = p end
                    end
                end
            end
        end
    end
    return nearest
end

local function lockOn()
    if not aimlockEnabled or not isLocked or not targetPlayer or not targetPlayer.Character then return end
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then isLocked = false targetPlayer = nil return end
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then isLocked = false targetPlayer = nil return end
    
    local currentDir = Camera.CFrame.LookVector
    local targetDir = (head.Position - Camera.CFrame.Position).Unit
    local newDir = currentDir:Lerp(targetDir, aimStrength)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newDir)
end

local function checkTriggerbot()
    if not triggerbotEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local mousePos = UserInputService:GetMouseLocation()
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = Camera.CFrame.LookVector.Unit * 1000
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
    if result then
        local hitPart = result.Instance
        local hitChar = hitPart.Parent
        if hitChar then
            local hum = hitChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
                task.wait(0.05)
                vim:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
            end
        end
    end
end

local function removeESP(p)
    if ESPObjects[p] then
        if ESPObjects[p].Highlight and ESPObjects[p].Highlight.Parent then
            ESPObjects[p].Highlight:Destroy()
        end
        ESPObjects[p] = nil
    end
end

local function addESP(p)
    if p == LocalPlayer or not espEnabled or not p.Character then return end
    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        removeESP(p)
        local h = Instance.new("Highlight")
        h.FillTransparency = 0.5
        h.OutlineColor = Color3.fromRGB(0, 255, 170)
        h.FillColor = Color3.fromRGB(0, 255, 170)
        h.Parent = p.Character
        ESPObjects[p] = { Highlight = h }
    end
end

-- Event Connections
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CONFIG.MenuKey then
        isMenuOpen = not isMenuOpen
        MainFrame.Visible = isMenuOpen
    elseif input.KeyCode == Enum.KeyCode.F then -- Dash Key
        doDash()
    end
end)

Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

LocalPlayer.CharacterAdded:Connect(function()
    isLocked = false
    targetPlayer = nil
    Camera.FieldOfView = 70
    if speedEnabled then
        task.wait(0.5)
        applySpeed()
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if aimlockEnabled and isLocked and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            lockOn()
        else
            isLocked = false
            targetPlayer = nil
        end
    else
        if isLocked then
            isLocked = false
            targetPlayer = nil
        end
    end
    
    if triggerbotEnabled then
        checkTriggerbot()
    end
    
    if not espEnabled then
        for p, _ in pairs(ESPObjects) do removeESP(p) end
        return
    end
    
    for p, d in pairs(ESPObjects) do
        if not p or not p.Parent or not d.Highlight or not d.Highlight.Parent or d.Highlight.Parent ~= p.Character or (p.Character and not p.Character:FindFirstChild("HumanoidRootPart")) then
            removeESP(p)
            if p and p.Parent and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then addESP(p) end
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (not ESPObjects[p] or not ESPObjects[p].Highlight or not ESPObjects[p].Highlight.Parent or ESPObjects[p].Highlight.Parent ~= p.Character) then
            addESP(p)
        end
    end
end)

print("bat admin panel loaded successfully.")
