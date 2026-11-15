-- Project: bat (Universal Admin Panel)
-- Compatibility: Xeno / Universal Executors
-- Design: Minimalist / ASCII / Calm
-- File: main.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService)
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    Title = "bat",
    Version = "v1.0",
    AccentColor = Color3.fromRGB(0, 255, 128), -- Calm Green
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    TabBackgroundColor = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    FontFace = Font.new("rbxassetid://10846750432"), -- Monospace/ASCII font
    IconAssetId = "rbxassetid://0", -- REPLACE THIS WITH YOUR IMAGE ID
}

-- Utility Functions
local function createUIInstance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Main GUI Creation
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
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = CONFIG.BackgroundColor,
    BorderColor3 = CONFIG.AccentColor,
    BorderThickness = 2
})

-- Dragging Logic
local dragging = false
local dragInput, mousePos, framePos
MainFrame.InputBegan:Connect(function(input)
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
MainFrame.InputChanged:Connect(function(input)
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

-- Title Bar
local TitleBar = createUIInstance("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = CONFIG.TabBackgroundColor,
    BorderThickness = 0
})

local TitleLabel = createUIInstance("TextLabel", {
    Name = "TitleLabel",
    Parent = TitleBar,
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "> bat_admin_panel",
    Font = CONFIG.FontFace,
    TextSize = 18,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

local CloseButton = createUIInstance("TextButton", {
    Name = "CloseButton",
    Parent = TitleBar,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -30, 0, 0),
    BackgroundTransparency = 1,
    Text = "X",
    Font = CONFIG.FontFace,
    TextSize = 20,
    TextColor3 = CONFIG.TextColor
})
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab Container (Left Side)
local TabContainer = createUIInstance("Frame", {
    Name = "TabContainer",
    Parent = MainFrame,
    Size = UDim2.new(0, 150, 1, -30),
    Position = UDim2.new(0, 0, 0, 30),
    BackgroundColor3 = CONFIG.TabBackgroundColor,
    BorderThickness = 0
})

-- Content Container (Right Side)
local ContentContainer = createUIInstance("Frame", {
    Name = "ContentContainer",
    Parent = MainFrame,
    Size = UDim2.new(1, -150, 1, -30),
    Position = UDim2.new(0, 150, 0, 30),
    BackgroundTransparency = 1,
    BorderThickness = 0
})

-- Tab Creation Function
local function createTab(name, iconText)
    local tabButton = createUIInstance("TextButton", {
        Name = name,
        Parent = TabContainer,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = iconText + " " + name,
        Font = CONFIG.FontFace,
        TextSize = 16,
        TextColor3 = CONFIG.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    tabButton.MouseEnter:Connect(function()
        if tabButton.BackgroundTransparency == 1 then
            tabButton.BackgroundTransparency = 0.9
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if tabButton.Tag == nil or tabButton.Tag ~= "Active" then
            tabButton.BackgroundTransparency = 1
        end
    end)

    local tabFrame = createUIInstance("Frame", {
        Name = name,
        Parent = ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, child in ipairs(ContentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        -- Reset all buttons
        for _, child in ipairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundTransparency = 1
                child.TextColor3 = CONFIG.TextColor
                child.Tag = nil
            end
        end
        
        -- Show selected tab
        tabFrame.Visible = true
        tabButton.BackgroundTransparency = 0
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabButton.TextColor3 = CONFIG.AccentColor
        tabButton.Tag = "Active"
    end)
    
    return tabFrame
}

-- Helper to create functional buttons
local function createActionButton(parent, name, callback)
    local button = createUIInstance("TextButton", {
        Name = name,
        Parent = parent,
        Size = UDim2.new(0, 200, 0, 40),
        BackgroundColor3 = CONFIG.TabBackgroundColor,
        BorderColor3 = CONFIG.AccentColor,
        BorderThickness = 1,
        Text = "> " + name,
        Font = CONFIG.FontFace,
        TextSize = 14,
        TextColor3 = CONFIG.TextColor
    })
    
    button.MouseButton1Click:Connect(callback)
    return button
}

-- Helper to create toggles (Visual Only for this template)
local function createToggle(parent, name)
    local frame = createUIInstance("Frame", {
        Name = "ToggleFrame",
        Parent = parent,
        Size = UDim2.new(0, 200, 0, 40),
        BackgroundTransparency = 1
    })
    
    local label = createUIInstance("TextLabel", {
        Name = "Label",
        Parent = frame,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "[ ] " + name,
        Font = CONFIG.FontFace,
        TextSize = 14,
        TextColor3 = CONFIG.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleButton = createUIInstance("TextButton", {
        Name = "ToggleButton",
        Parent = frame,
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundColor3 = CONFIG.TabBackgroundColor,
        BorderColor3 = CONFIG.TextColor,
        BorderThickness = 1,
        Text = "OFF",
        Font = CONFIG.FontFace,
        TextSize = 12,
        TextColor3 = CONFIG.TextColor
    })
    
    local isOn = false
    toggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            label.Text = "[X] " + name
            toggleButton.Text = "ON"
            toggleButton.BackgroundColor3 = CONFIG.AccentColor
            toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            label.Text = "[ ] " + name
            toggleButton.Text = "OFF"
            toggleButton.BackgroundColor3 = CONFIG.TabBackgroundColor
            toggleButton.TextColor3 = CONFIG.TextColor
        end
    end)
    
    return frame, function() return isOn end
}

-- --- TABS IMPLEMENTATION ---

-- 1. General Tab
local generalTab = createTab("General", "[G]")
local generalLabel = createUIInstance("TextLabel", {
    Parent = generalTab,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Text = "> SYSTEM_ROOT\n> ACCESS_LEVEL: ADMIN\n> STATUS: ACTIVE",
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.TextColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

createActionButton(generalTab, "Refresh_Panel", function()
    -- Reloads the UI (simulated)
    generalLabel.Text = "> SYSTEM_ROOT\n> ACCESS_LEVEL: ADMIN\n> STATUS: RELOADING..."
    wait(1)
    generalLabel.Text = "> SYSTEM_ROOT\n> ACCESS_LEVEL: ADMIN\n> STATUS: ACTIVE"
end)

createActionButton(generalTab, "Clear_Errors", function()
    print("Errors cleared (Simulation)")
end)

-- 2. Shooter Tab (Cheats)
local shooterTab = createTab("Shooter", "[S]")
local shooterLabel = createUIInstance("TextLabel", {
    Parent = shooterTab,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Text = "> MODULE: SHOOTER_ASSIST\n> WARNING: USE AT OWN RISK",
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.TextColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

local _, aimlockStatus = createToggle(shooterTab, "Aimlock_Assist")
local _, espStatus = createToggle(shooterTab, "ESP_Wireframe")

createActionButton(shooterTab, "Test_Firing", function()
    print("Firing mechanism test (No action in safe mode)")
end)

-- 3. Player List (Simulation)
local playerTab = createTab("Players", "[P]")
local playerLabel = createUIInstance("TextLabel", {
    Parent = playerTab,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Text = "> ONLINE_USERS\n> COUNT: " + tostring(#Players:GetPlayers()),
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.TextColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- 4. Settings / Exit
local settingsTab = createTab("Settings", "[X]")
local settingsLabel = createUIInstance("TextLabel", {
    Parent = settingsTab,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Text = "> CONFIGURATION\n> UNBANNABLE_MODE: TRUE",
    Font = CONFIG.FontFace,
    TextSize = 14,
    TextColor3 = CONFIG.TextColor,
    TextXAlignment = Enum.TextXAlignment.Left
})

createActionButton(settingsTab, "Close_Panel", function()
    ScreenGui:Destroy()
end)

-- Initial Tab Activation
generalTab.Visible = true
-- Set General button to active state manually
for _, child in ipairs(TabContainer:GetChildren()) do
    if child.Name == "General" then
        child.BackgroundTransparency = 0
        child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        child.TextColor3 = CONFIG.AccentColor
        child.Tag = "Active"
    end
end

print("bat admin panel loaded successfully.")
