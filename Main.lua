-- [[ ZlinHUB v5.0 - Cosmic Neon Edition ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 1. УДАЛЕНИЕ СТАРОГО GUI
if CoreGui:FindFirstChild("ZlinCosmic") then
    CoreGui.ZlinCosmic:Destroy()
end

-- 2. СОЗДАНИЕ GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZlinCosmic"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Глобальное состояние
local State = {
    Tabs = {},
    CurrentTab = nil,
    FlyEnabled = false,
    InfJumpEnabled = false,
    EspEnabled = false,
    DrawingObjects = {}
}

-- [[ ФУНКЦИИ ДИЗАЙНА ]] --

-- Функция для создания "Глянцевой" кнопки
local function CreateGlossyButton(parent, color, size, position, text, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.Size = size
    Button.Position = position
    Button.BackgroundColor3 = color
    Button.Text = ""
    Button.AutoButtonColor = false
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.5, 0) -- Полностью круглые края
    Corner.Parent = Button
    
    -- Градиент для объема
    local Gradient = Instance.new("UIGradient")
    Gradient.Rotation = 90
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), -- Светлый верх
        ColorSequenceKeypoint.new(0.5, color),           -- Основной цвет
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0))  -- Темный низ
    }
    Gradient.Parent = Button
    
    -- Блик (Gloss)
    local Gloss = Instance.new("Frame")
    Gloss.Parent = Button
    Gloss.Size = UDim2.new(0.8, 0, 0.4, 0)
    Gloss.Position = UDim2.new(0.1, 0, 0.05, 0)
    Gloss.BackgroundColor3 = Color3.new(1,1,1)
    Gloss.BackgroundTransparency = 0.6
    Gloss.BorderSizePixel = 0
    local GlossCorner = Instance.new("UICorner")
    GlossCorner.CornerRadius = UDim.new(1, 0)
    GlossCorner.Parent = Gloss
    
    -- Текст (Иконка или название)
    local Label = Instance.new("TextLabel")
    Label.Parent = Button
    Label.Size = UDim2.new(1,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.FredokaOne
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextSize = 14
    Label.TextStrokeTransparency = 0.5
    
    -- Анимация нажатия
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(size.X.Scale, size.X.Offset*0.9, size.Y.Scale, size.Y.Offset*0.9)}):Play()
    end)
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = size}):Play()
        if callback then callback() end
    end)
    
    return Button
end

-- [[ ОСНОВНОЙ ФРЕЙМ ]] --

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 30)
MainCorner.Parent = MainFrame

-- Радужная обводка (Stroke + Gradient)
local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Thickness = 6
Stroke.Color = Color3.new(1,1,1)

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
}
StrokeGradient.Parent = Stroke

-- Анимация радуги
task.spawn(function()
    while MainFrame.Parent do
        StrokeGradient.Rotation = StrokeGradient.Rotation + 1
        if StrokeGradient.Rotation >= 360 then StrokeGradient.Rotation = 0 end
        task.wait(0.02)
    end
end)

-- Внутренний фон (Космос)
local InnerBg = Instance.new("Frame")
InnerBg.Parent = MainFrame
InnerBg.Size = UDim2.new(1, -20, 1, -20)
InnerBg.Position = UDim2.new(0, 10, 0, 10)
InnerBg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
InnerBg.BorderSizePixel = 0
local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 20)
InnerCorner.Parent = InnerBg

-- Контейнер для контента (Центр)
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = InnerBg
ContentContainer.Size = UDim2.new(1, -20, 0.7, 0) -- 70% высоты
ContentContainer.Position = UDim2.new(0, 10, 0.15, 0) -- Отступ сверху под кнопки
ContentContainer.BackgroundTransparency = 1

-- [[ ВЕРХНИЕ КНОПКИ (ВКЛАДКИ) ]] --
local TopBar = Instance.new("Frame")
TopBar.Parent = InnerBg
TopBar.Size = UDim2.new(1, 0, 0.15, 0)
TopBar.BackgroundTransparency = 1

-- Создаем 4 вкладки как на картинке
local Tabs = {
    {Name = "Main", Color = Color3.fromRGB(0, 180, 255)}, -- Голубая
    {Name = "Visuals", Color = Color3.fromRGB(255, 0, 150)}, -- Розовая
    {Name = "Players", Color = Color3.fromRGB(150, 0, 255)}, -- Фиолетовая
    {Name = "Settings", Color = Color3.fromRGB(255, 200, 0)}  -- Желтая
}

local tabPages = {}

for i, tabData in ipairs(Tabs) do
    -- Расчет позиции
    local width = 100
    local gap = 15
    local startX = (480 - (width * 4 + gap * 3)) / 2
    local xPos = startX + (i-1) * (width + gap)
    
    -- Страница для вкладки
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabData.Name
    Page.Parent = ContentContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1) -- Показываем только первую
    Page.ScrollBarThickness = 4
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = Page
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local pad = Instance.new("UIPadding")
    pad.Parent = Page
    pad.PaddingTop = UDim.new(0, 10)
    
    tabPages[tabData.Name] = Page
    
    -- Кнопка вкладки
    CreateGlossyButton(TopBar, tabData.Color, UDim2.new(0, width, 0, 40), UDim2.new(0, xPos, 0, 10), tabData.Name, function()
        -- Переключение вкладок
        for _, p in pairs(tabPages) do p.Visible = false end
        tabPages[tabData.Name].Visible = true
    end)
end

-- [[ НИЖНИЕ КНОПКИ (БЫСТРЫЕ ДЕЙСТВИЯ) ]] --
local BottomBar = Instance.new("Frame")
BottomBar.Parent = InnerBg
BottomBar.Size = UDim2.new(1, 0, 0.15, 0)
BottomBar.Position = UDim2.new(0, 0, 0.85, 0)
BottomBar.BackgroundTransparency = 1

local Actions = {
    {Text = "Hide", Color = Color3.fromRGB(0, 150, 100), Func = function() ScreenGui.Enabled = false end},
    {Text = "Rejoin", Color = Color3.fromRGB(50, 50, 50), Func = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end},
    {Text = "Reset", Color = Color3.fromRGB(0, 100, 200), Func = function() LocalPlayer.Character:BreakJoints() end},
    {Text = "Unload", Color = Color3.fromRGB(150, 50, 200), Func = function() ScreenGui:Destroy() end},
}

for i, action in ipairs(Actions) do
    local width = 80
    local gap = 10
    local startX = (480 - (width * #Actions + gap * (#Actions-1))) / 2
    local xPos = startX + (i-1) * (width + gap)
    
    CreateGlossyButton(BottomBar, action.Color, UDim2.new(0, width, 0, 30), UDim2.new(0, xPos, 0, 15), action.Text, action.Func)
end

-- [[ ФУНКЦИИ ДЛЯ ЭЛЕМЕНТОВ UI ]] --

local function AddToggle(page, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = page
    Frame.Size = UDim2.new(0, 400, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 10); fc.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Frame
    ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -65, 0.5, -13)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.Text = ""
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = ToggleBtn
    
    local Circle = Instance.new("Frame")
    Circle.Parent = ToggleBtn
    Circle.Size = UDim2.new(0, 22, 0, 22)
    Circle.Position = UDim2.new(0, 2, 0.5, -11)
    Circle.BackgroundColor3 = Color3.new(1,1,1)
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = Circle
    
    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -24, 0.5, -11)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -11)}):Play()
        end
        callback(state)
    end)
end

local function AddSlider(page, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = page
    Frame.Size = UDim2.new(0, 400, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 10); fc.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBar = Instance.new("TextButton")
    SliderBar.Parent = Frame
    SliderBar.Size = UDim2.new(1, -30, 0, 6)
    SliderBar.Position = UDim2.new(0, 15, 0, 35)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Text = ""
    SliderBar.AutoButtonColor = false
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1, 0); sc.Parent = SliderBar
    
    local Fill = Instance.new("Frame")
    Fill.Parent = SliderBar
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    local fic = Instance.new("UICorner"); fic.CornerRadius = UDim.new(1, 0); fic.Parent = Fill
    
    SliderBar.MouseButton1Down:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local moveConn, releaseConn
        
        local function update()
            local percent = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Label.Text = text .. ": " .. value
            callback(value)
        end
        update()
        moveConn = mouse.Move:Connect(update)
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
end

-- [[ НАПОЛНЕНИЕ ВКЛАДОК ]] --

-- 1. MAIN TAB (Movement)
local MainTab = tabPages["Main"]

AddSlider(MainTab, "Walk Speed", 16, 300, 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

AddSlider(MainTab, "Jump Power", 50, 500, 50, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

AddToggle(MainTab, "Infinite Jump", function(val)
    State.InfJumpEnabled = val
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local FlySpeed = 50
AddSlider(MainTab, "Fly Speed", 10, 300, 50, function(val) FlySpeed = val end)

AddToggle(MainTab, "Fly (WASD)", function(val)
    State.FlyEnabled = val
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if val and root then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "ZlinFlyV"; bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "ZlinFlyG"; bg.MaxTorque = Vector3.new(1e9,1e9,1e9); bg.P = 10000; bg.D = 1000
        
        task.spawn(function()
            while State.FlyEnabled and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 do
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                bg.CFrame = cam.CFrame
                bv.Velocity = moveDir * FlySpeed
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    else
        for _, v in pairs(root:GetChildren()) do
            if v.Name == "ZlinFlyV" or v.Name == "ZlinFlyG" then v:Destroy() end
        end
    end
end)

-- 2. VISUALS TAB
local VisTab = tabPages["Visuals"]

AddToggle(VisTab, "Enable ESP", function(val)
    State.EspEnabled = val
    if not val then
        for _, pData in pairs(State.DrawingObjects) do
            for _, obj in pairs(pData) do obj.Visible = false end
        end
    end
end)

-- Простой ESP (BillboardGui для надежности)
task.spawn(function()
    while true do
        if State.EspEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    if not p.Character.Head:FindFirstChild("ZlinESP") then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "ZlinESP"
                        bg.Adornee = p.Character.Head
                        bg.Size = UDim2.new(0, 100, 0, 50)
                        bg.StudsOffset = Vector3.new(0, 2, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = p.Character.Head
                        
                        local txt = Instance.new("TextLabel")
                        txt.Parent = bg
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.Text = p.Name
                        txt.TextColor3 = Color3.new(1,0,0)
                        txt.TextStrokeTransparency = 0
                        txt.Font = Enum.Font.GothamBold
                    end
                end
            end
        else
            -- Очистка
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ZlinESP") then
                    p.Character.Head.ZlinESP:Destroy()
                end
            end
        end
        task.wait(1)
    end
end)

-- 3. PLAYERS TAB
local PlayTab = tabPages["Players"]

local PlayerInput = Instance.new("TextBox")
PlayerInput.Parent = PlayTab
PlayerInput.Size = UDim2.new(0, 400, 0, 40)
PlayerInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
PlayerInput.Text = "Type Player Name..."
PlayerInput.TextColor3 = Color3.new(1,1,1)
PlayerInput.Font = Enum.Font.Gotham
PlayerInput.TextSize = 16
local pic = Instance.new("UICorner"); pic.CornerRadius = UDim.new(0, 10); pic.Parent = PlayerInput

local TpBtn = CreateGlossyButton(PlayTab, Color3.fromRGB(150, 0, 255), UDim2.new(0, 200, 0, 40), UDim2.new(0, 0, 0, 0), "Teleport", function()
    local targetName = PlayerInput.Text
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(p.Name:lower(), 1, #targetName) == targetName:lower() then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

-- 4. SETTINGS TAB
local SetTab = tabPages["Settings"]
AddToggle(SetTab, "Show Menu (Right Ctrl)", function(val) end) -- Заглушка, логика ниже

-- Скрытие по Right Ctrl
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Приветствие
game.StarterGui:SetCore("SendNotification", {
    Title = "ZlinHUB Cosmic";
    Text = "Welcome, " .. LocalPlayer.Name;
    Duration = 5;
})
