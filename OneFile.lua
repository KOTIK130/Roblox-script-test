-- [[ ZlinHUB v7.0 - Neon Fix ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 1. УДАЛЕНИЕ СТАРОГО GUI
if CoreGui:FindFirstChild("CustomScriptUI") then
    CoreGui.CustomScriptUI:Destroy()
end

local function create(inst, props, parent)
	local obj = Instance.new(inst)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	obj.Parent = parent
	return obj
end

local gui = create("ScreenGui", {
	Name = "CustomScriptUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Global -- ВАЖНО: Global ZIndex для правильного наложения
}, CoreGui)

-- Root (Main Frame)
local root = create("Frame", {
	Name = "Root",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(550, 400),
	BackgroundColor3 = Color3.fromRGB(10, 10, 15), -- Почти черный фон
	BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    ZIndex = 1
}, gui)

create("UICorner", {CornerRadius = UDim.new(0, 15)}, root)

-- NEON BORDER (Яркая обводка)
local stroke = create("UIStroke", {
	Thickness = 4,
	Transparency = 0,
    Color = Color3.fromRGB(255, 255, 255), -- Белый, чтобы градиент был ярким
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = root
})

local strokeGrad = create("UIGradient", {
	Rotation = 0,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255)),
	}),
    Parent = stroke
})

-- Анимация радуги
task.spawn(function()
    while root.Parent do
        strokeGrad.Rotation = (strokeGrad.Rotation + 2) % 360
        task.wait(0.02)
    end
end)

-- TABS CONTAINER (Верхняя панель)
local tabsContainer = create("Frame", {
	Name = "Tabs",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -20, 0, 50),
	Position = UDim2.new(0, 10, 0, 10),
	ZIndex = 2
}, root)

local layout = create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = tabsContainer
})

-- CONTENT CONTAINER (Основная часть)
local content = create("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 10, 0, 70),
	Size = UDim2.new(1, -20, 1, -80),
	ZIndex = 2
}, root)

-- Хранилище страниц
local Pages = {}

-- Функция создания кнопки-вкладки
local function createTabBtn(name, color)
    -- Страница
    local Page = create("ScrollingFrame", {
        Name = name .. "_Page",
        Parent = content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = color,
        ZIndex = 5
    })
    create("UIListLayout", {
        Parent = Page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
    
    Pages[name] = Page

    -- Кнопка
	local btn = create("TextButton", {
        Parent = tabsContainer,
		Size = UDim2.fromOffset(100, 35),
		BackgroundColor3 = Color3.fromRGB(30, 30, 40),
		BorderSizePixel = 0,
		ZIndex = 10,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextColor3 = color, -- Цвет текста = цвет вкладки
        TextSize = 14,
        AutoButtonColor = true
	})
	create("UICorner", {CornerRadius = UDim.new(0, 8)}, btn)
    
    -- Обводка кнопки
    create("UIStroke", {
        Parent = btn,
        Thickness = 2,
        Color = color,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
    end)
end

createTabBtn("Movement", Color3.fromRGB(0, 255, 255)) -- Cyan
createTabBtn("Visuals", Color3.fromRGB(255, 0, 255))  -- Magenta
createTabBtn("Players", Color3.fromRGB(100, 255, 100)) -- Green
createTabBtn("Settings", Color3.fromRGB(255, 200, 0)) -- Orange

Pages["Movement"].Visible = true

-- [[ ЭЛЕМЕНТЫ UI ]] --

local function AddElementBox(page)
    local box = create("Frame", {
        Parent = page,
        Size = UDim2.new(0.98, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, box)
    return box
end

local function AddToggle(page, text, callback)
    local box = AddElementBox(page)
    
    create("TextLabel", {
        Parent = box,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11
    })
    
    local btn = create("TextButton", {
        Parent = box,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = "",
        ZIndex = 11
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, btn)
    
    local circle = create("Frame", {
        Parent = btn,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1),
        ZIndex = 12
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, circle)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        callback(state)
    end)
end

local function AddSlider(page, text, min, max, default, callback)
    local box = AddElementBox(page)
    box.Size = UDim2.new(0.98, 0, 0, 50)
    
    local label = create("TextLabel", {
        Parent = box,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text .. ": " .. default,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11
    })
    
    local sliderBg = create("TextButton", {
        Parent = box,
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 11
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, sliderBg)
    
    local fill = create("Frame", {
        Parent = sliderBg,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 180, 255),
        ZIndex = 12
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
    
    sliderBg.MouseButton1Down:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local moveConn, releaseConn
        
        local function update()
            local percent = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. value
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

local function AddButton(page, text, callback)
    local box = AddElementBox(page)
    
    local btn = create("TextButton", {
        Parent = box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 11
    })
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(box, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
        task.wait(0.1)
        TweenService:Create(box, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        callback()
    end)
end

-- [[ ФУНКЦИОНАЛ ]] --

-- Movement
local MovePage = Pages["Movement"]
AddSlider(MovePage, "Walk Speed", 16, 300, 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)
AddSlider(MovePage, "Jump Power", 50, 500, 50, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)
AddToggle(MovePage, "Infinite Jump", function(val) getgenv().InfJump = val end)
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Visuals
local VisPage = Pages["Visuals"]
AddToggle(VisPage, "ESP Enabled", function(val) getgenv().Esp = val end)
task.spawn(function()
    while true do
        if getgenv().Esp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and not p.Character.Head:FindFirstChild("ZlinESP") then
                    local bg = Instance.new("BillboardGui", p.Character.Head)
                    bg.Name = "ZlinESP"; bg.Size = UDim2.new(0,100,0,50); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0,2,0)
                    local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = p.Name; t.TextColor3 = Color3.new(1,0,0); t.TextStrokeTransparency = 0
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ZlinESP") then
                    p.Character.Head.ZlinESP:Destroy()
                end
            end
        end
        task.wait(1)
    end
end)

-- Players
local PlayPage = Pages["Players"]
local PlayerInput = create("TextBox", {
    Parent = PlayPage, Size = UDim2.new(0.98, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    Text = "Player Name...", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 16, ZIndex = 10
})
create("UICorner", {CornerRadius = UDim.new(0, 6)}, PlayerInput)
AddButton(PlayPage, "Teleport", function()
    local target = PlayerInput.Text
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(p.Name:lower(), 1, #target) == target:lower() then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)

-- Settings
local SetPage = Pages["Settings"]
AddButton(SetPage, "Unload Script", function() gui:Destroy() end)

-- Right Ctrl
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then gui.Enabled = not gui.Enabled end
end)

game.StarterGui:SetCore("SendNotification", {Title = "ZlinHUB", Text = "Loaded! Press Right Ctrl", Duration = 5})
