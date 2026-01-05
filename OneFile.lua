-- [[ ZlinHUB v4.0 - One File Edition ]] --

-- 1. ЗАГРУЗКА БИБЛИОТЕКИ RAYFIELD
local RayfieldLibrary
local success, result = pcall(function()
    return game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua')
end)

if not success or not result then
    success, result = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source')
    end)
end

if success and result then
    local func = loadstring(result)
    if func then RayfieldLibrary = func() end
end

if not RayfieldLibrary then
    warn("CRITICAL: Failed to load Rayfield Library.")
    return
end

-- 2. СОЗДАНИЕ ОКНА
local Window = RayfieldLibrary:CreateWindow({
   Name = "ZlinHUB",
   LoadingTitle = "ZlinHUB Interface",
   LoadingSubtitle = "by KOTIK130",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ZlinHUB_Config",
      FileName = "Manager"
   },
   KeySystem = false,
})

-- 3. ГЛОБАЛЬНОЕ СОСТОЯНИЕ
local State = {
    Connections = {},
    DrawingObjects = {},
    FlyEnabled = false,
    InfJumpEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 4. ВКЛАДКА MOVEMENT (ВСТРОЕНА)
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSection("Character Stats")

MoveTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed", 
    Callback = function(Value)
        State.WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPower", 
    Callback = function(Value)
        State.JumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

MoveTab:CreateSection("Abilities")

MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump", 
    Callback = function(Value)
        State.InfJumpEnabled = Value
    end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if State.InfJumpEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local FlySpeed = 50
MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "FlySpeed", 
    Callback = function(Value)
        FlySpeed = Value
    end,
})

MoveTab:CreateToggle({
    Name = "Enable Fly (WASD)",
    CurrentValue = false,
    Flag = "FlyEnabled", 
    Callback = function(Value)
        State.FlyEnabled = Value
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if Value and root then
            local bv = Instance.new("BodyVelocity", root)
            bv.Name = "ZlinFlyV"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            
            local bg = Instance.new("BodyGyro", root)
            bg.Name = "ZlinFlyG"
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P = 10000
            bg.D = 1000
            
            task.spawn(function()
                while State.FlyEnabled and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 do
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new()
                    local uis = game:GetService("UserInputService")
                    
                    if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    
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
    end,
})

-- 5. ВКЛАДКА VISUALS (ВСТРОЕНА)
local VisTab = Window:CreateTab("Visuals", 4483362458)

local EspConfig = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Color = Color3.fromRGB(255, 0, 0)
}

VisTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value) EspConfig.Enabled = Value end,
})

VisTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Callback = function(Value) EspConfig.Boxes = Value end,
})

VisTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Callback = function(Value) EspConfig.Names = Value end,
})

local function AddEsp(player)
    if player == LocalPlayer then return end
    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
    }
    objects.Box.Visible = false
    objects.Box.Color = EspConfig.Color
    objects.Box.Thickness = 1
    objects.Box.Filled = false
    
    objects.Name.Visible = false
    objects.Name.Color = EspConfig.Color
    objects.Name.Size = 14
    objects.Name.Center = true
    objects.Name.Outline = true
    
    State.DrawingObjects[player] = objects
end

local function RemoveEsp(player)
    if State.DrawingObjects[player] then
        for _, obj in pairs(State.DrawingObjects[player]) do obj:Remove() end
        State.DrawingObjects[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not EspConfig.Enabled then
        for _, pData in pairs(State.DrawingObjects) do
            for _, obj in pairs(pData) do obj.Visible = false end
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not State.DrawingObjects[player] then AddEsp(player) end
            
            local char = player.Character
            local objs = State.DrawingObjects[player]
            local Camera = workspace.CurrentCamera
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local size = 2500 / pos.Z
                    local boxSize = Vector2.new(size * 0.6, size)
                    local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
                    
                    if EspConfig.Boxes then
                        objs.Box.Size = boxSize
                        objs.Box.Position = boxPos
                        objs.Box.Visible = true
                    else
                        objs.Box.Visible = false
                    end
                    
                    if EspConfig.Names then
                        objs.Name.Text = player.Name
                        objs.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y/2 - 15)
                        objs.Name.Visible = true
                    else
                        objs.Name.Visible = false
                    end
                else
                    objs.Box.Visible = false
                    objs.Name.Visible = false
                end
            else
                objs.Box.Visible = false
                objs.Name.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveEsp)

-- 6. ВКЛАДКА PLAYERS (ВСТРОЕНА)
local PlayerTab = Window:CreateTab("Players", 4483362458)

local selectedPlayer = nil
local playerNames = {}

local function UpdatePlayerList()
    playerNames = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
    end
end
UpdatePlayerList()

local Dropdown = PlayerTab:CreateDropdown({
    Name = "Select Player",
    Options = playerNames,
    CurrentOption = "",
    Flag = "PlayerSelect", 
    Callback = function(Option)
        selectedPlayer = Players:FindFirstChild(Option[1])
    end,
})

PlayerTab:CreateButton({
    Name = "Refresh List",
    Callback = function()
        UpdatePlayerList()
        Dropdown:Refresh(playerNames, true)
    end,
})

PlayerTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        else
            RayfieldLibrary:Notify({Title = "Error", Content = "Player not found!", Duration = 3})
        end
    end,
})

PlayerTab:CreateSection("Performance")

PlayerTab:CreateButton({
    Name = "Anti-Lag (Boost FPS)",
    Callback = function()
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
        RayfieldLibrary:Notify({Title = "Success", Content = "Textures removed!", Duration = 3})
    end,
})

RayfieldLibrary:Notify({
   Title = "Welcome",
   Content = "ZlinHUB Loaded Successfully!",
   Duration = 5,
   Image = 4483345998,
})
