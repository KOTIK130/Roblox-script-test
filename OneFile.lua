-- [[ ZlinHUB v6.0 - Custom Cosmic UI ]] --

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

-- 2. СОЗДАНИЕ БАЗОВОГО ИНТЕРФЕЙСА (Твой код + Логика)
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
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui) -- Важно: CoreGui для скрытности

-- Root (square)
local root = create("Frame", {
	Name = "Root",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.52),
	Size = UDim2.fromOffset(520, 520),
	BackgroundColor3 = Color3.fromRGB(18, 18, 24),
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
    Active = true,
    Draggable = true
}, gui)

create("UICorner", {CornerRadius = UDim.new(0, 28)}, root)

-- Fancy border via Stroke + Gradient
local stroke = create("UIStroke", {
	Thickness = 3,
	Transparency = 0.05,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	LineJoinMode = Enum.LineJoinMode.Round
}, root)

local strokeGrad = create("UIGradient", {
	Rotation = 35,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(60, 255, 200)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(90, 140, 255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(220, 90, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 200, 80)),
	})
}, stroke)

-- Анимация градиента рамки
task.spawn(function()
    while root.Parent do
        strokeGrad.Rotation = strokeGrad.Rotation + 1
        task.wait(0.05)
    end
end)

-- Inner inset panel
local inset = create("Frame", {
	Name = "Inset",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.52),
	Size = UDim2.fromScale(0.93, 0.90),
	BackgroundColor3 = Color3.fromRGB(10, 10, 14),
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0
}, root)
create("UICorner", {CornerRadius = UDim.new(0, 22)}, inset)

-- Subtle “glass” overlay
local glass = create("Frame", {
	Name = "Glass",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.92,
	BorderSizePixel = 0
}, inset)
create("UICorner", {CornerRadius = UDim.new(0, 22)}, glass)

-- Big soft highlights
local highlight = create("Frame", {
	Name = "Highlight",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.55, 0.35),
	Size = UDim2.fromScale(1.2, 1.0),
	BackgroundColor3 = Color3.fromRGB(90, 140, 255),
	BackgroundTransparency = 0.86,
	BorderSizePixel = 0
}, inset)
create("UICorner", {CornerRadius = UDim.new(1, 0)}, highlight)
create("UIGradient", {
	Rotation = -25,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 140, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 90, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 255, 200)),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1.0),
	})
}, highlight)

-- Patterns: corner swirls
local function cornerSwirl(parent, side)
	local holder = create("Frame", {
		Name = "Swirl_"..side,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(170, 170),
		ZIndex = 5
	}, parent)

	if side == "BL" then
		holder.Position = UDim2.new(0, 10, 1, -180)
	elseif side == "BR" then
		holder.Position = UDim2.new(1, -180, 1, -180)
	end

	for i = 1, 5 do
		local ring = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(170 - i*22, 170 - i*22),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.94,
			BorderSizePixel = 0
		}, holder)
		create("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)

		local s = create("UIStroke", {
			Thickness = 2,
			Transparency = 0.25 + i*0.08,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, ring)

		create("UIGradient", {
			Rotation = (side == "BL") and (20 + i*14) or (200 + i*14),
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 255, 200)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 90, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 80)),
			})
		}, s)
	end
end

cornerSwirl(inset, "BL")
cornerSwirl(inset, "BR")

-- Top pill tabs bar
local tabsContainer = create("Frame", {
	Name = "Tabs",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 72),
	Position = UDim2.fromOffset(0, 12),
	ZIndex = 20
}, root)

local layout = create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 12),
	SortOrder = Enum.SortOrder.LayoutOrder
}, tabsContainer)

-- Content area
local content = create("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 18, 0, 92),
	Size = UDim2.new(1, -36, 1, -110),
	ZIndex = 10
}, root)

local contentPanel = create("Frame", {
	Name = "ContentPanel",
	BackgroundColor3 = Color3.fromRGB(14, 14, 20),
	BackgroundTransparency = 0.5, -- Чуть прозрачнее, чтобы видеть фон
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 10
}, content)
create("UICorner", {CornerRadius = UDim.new(0, 22)}, contentPanel)

-- Хранилище страниц
local Pages = {}

-- Функция создания кнопки-вкладки
local function createTabBtn(name, colorA, colorB)
    -- Создаем страницу
    local Page = create("ScrollingFrame", {
        Name = name .. "_Page",
        Parent = contentPanel,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 4,
        ZIndex = 15
    })
    create("UIListLayout", {
        Parent = Page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    }, Page)
    create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5)}, Page)
    
    Pages[name] = Page

    -- Создаем кнопку (TextButton вместо Frame)
	local btn = create("TextButton", {
		Size = UDim2.fromOffset(110, 40), -- Чуть уже, чтобы влез текст
		BackgroundColor3 = Color3.fromRGB(30, 30, 38),
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		ZIndex = 21,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 14,
        AutoButtonColor = false
	}, tabsContainer)

	create("UICorner", {CornerRadius = UDim.new(1, 0)}, btn)

	local s = create("UIStroke", {
		Thickness = 2,
		Transparency = 0.05,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, btn)

	create("UIGradient", {
		Rotation = 25,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorA),
			ColorSequenceKeypoint.new(1, colorB),
		})
	}, s)

    -- Логика переключения
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
        
        -- Анимация нажатия
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.fromOffset(100, 35)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.fromOffset(110, 40)}):Play()
    end)

	return btn
end

-- Создаем вкладки
createTabBtn("Movement", Color3.fromRGB(70, 220, 255), Color3.fromRGB(90, 140, 255))
createTabBtn("Visuals", Color3.fromRGB(220, 90, 255), Color3.fromRGB(255, 120, 180))
createTabBtn("Players", Color3.fromRGB(120, 110, 255), Color3.fromRGB(80, 255, 200))
createTabBtn("Settings", Color3.fromRGB(255, 210, 90), Color3.fromRGB(255, 140, 70))

-- Открываем первую
Pages["Movement"].Visible = true

-- [[ ФУНКЦИИ ДЛЯ ЭЛЕМЕНТОВ (ВНУТРИ СТРАНИЦ) ]] --

local function AddElementBox(page)
    local box = create("Frame", {
        Parent = page,
        Size = UDim2.new(0.95, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.3,
        ZIndex = 16
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12)}, box)
    create("UIStroke", {Thickness = 1, Transparency = 0.8, Color = Color3.new(1,1,1)}, box)
    return box
end

local function AddToggle(page, text, callback)
    local box = AddElementBox(page)
    
    local label = create("TextLabel", {
        Parent = box,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 17
    })
    
    local btn = create("TextButton", {
        Parent = box,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -55, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = "",
        ZIndex = 17
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, btn)
    
    local circle = create("Frame", {
        Parent = btn,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1),
        ZIndex = 18
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, circle)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
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
    box.Size = UDim2.new(0.95, 0, 0, 60) -- Чуть выше для слайдера
    
    local label = create("TextLabel", {
        Parent = box,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 5),
        BackgroundTransparency = 1,
        Text = text .. ": " .. default,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 17
    })
    
    local sliderBg = create("TextButton", {
        Parent = box,
        Size = UDim2.new(1, -30, 0, 6),
        Position = UDim2.new(0, 15, 0, 35),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 17
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, sliderBg)
    
    local fill = create("Frame", {
        Parent = sliderBg,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90, 140, 255),
        ZIndex = 18
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
        ZIndex = 17
    })
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(box, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
        task.wait(0.1)
        TweenService:Create(box, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        callback()
    end)
end

-- [[ НАПОЛНЕНИЕ ФУНКЦИОНАЛОМ ]] --

-- Глобальное состояние
local State = {
    FlyEnabled = false,
    InfJumpEnabled = false,
    EspEnabled = false,
    DrawingObjects = {}
}

-- 1. MOVEMENT
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

AddToggle(MovePage, "Infinite Jump", function(val) State.InfJumpEnabled = val end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local FlySpeed = 50
AddSlider(MovePage, "Fly Speed", 10, 300, 50, function(val) FlySpeed = val end)

AddToggle(MovePage, "Fly (WASD)", function(val)
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

-- 2. VISUALS
local VisPage = Pages["Visuals"]

AddToggle(VisPage, "Enable ESP (Names)", function(val)
    State.EspEnabled = val
    if not val then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ZlinESP") then
                p.Character.Head.ZlinESP:Destroy()
            end
        end
    end
end)

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
                        
                        local txt = create("TextLabel", {
                            Parent = bg,
                            Size = UDim2.new(1,0,1,0),
                            BackgroundTransparency = 1,
                            Text = p.Name,
                            TextColor3 = Color3.new(1,0,0),
                            TextStrokeTransparency = 0,
                            Font = Enum.Font.GothamBold
                        })
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- 3. PLAYERS
local PlayPage = Pages["Players"]

local PlayerInput = create("TextBox", {
    Parent = PlayPage,
    Size = UDim2.new(0.95, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    Text = "Type Player Name...",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.Gotham,
    TextSize = 16,
    ZIndex = 16
})
create("UICorner", {CornerRadius = UDim.new(0, 10)}, PlayerInput)

AddButton(PlayPage, "Teleport to Player", function()
    local targetName = PlayerInput.Text
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(p.Name:lower(), 1, #targetName) == targetName:lower() then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

AddButton(PlayPage, "Anti-Lag (Remove Textures)", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
end)

-- 4. SETTINGS
local SetPage = Pages["Settings"]
AddButton(SetPage, "Unload Script", function() gui:Destroy() end)
AddButton(SetPage, "Rejoin Server", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)

-- Bottom mini pills row (Actions)
local bottom = create("Frame", {
	Name = "BottomPills",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.new(1, -90, 0, 44),
	ZIndex = 20
}, root)

create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder
}, bottom)

local function createMiniBtn(text, col, func)
	local p = create("TextButton", {
		Size = UDim2.fromOffset(80, 26),
		BackgroundColor3 = Color3.fromRGB(30, 30, 38),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 21,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 12
	}, bottom)
	create("UICorner", {CornerRadius = UDim.new(1, 0)}, p)
	local ps = create("UIStroke", {Thickness = 2, Transparency = 0.15}, p)
	create("UIGradient", {
		Rotation = 25,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, col),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.05),
			NumberSequenceKeypoint.new(1, 0.55),
		})
	}, ps)
    p.MouseButton1Click:Connect(func)
end

createMiniBtn("Hide", Color3.fromRGB(80, 255, 200), function() gui.Enabled = false end)
createMiniBtn("Unload", Color3.fromRGB(255, 80, 80), function() gui:Destroy() end)

-- Right Ctrl Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        gui.Enabled = not gui.Enabled
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "ZlinHUB Cosmic";
    Text = "Loaded! Press Right Ctrl to toggle.";
    Duration = 5;
})
