-- [[ Tabs/Movement.lua ]] --
return function(Context)
    local Window = Context.Window
    local Fluent = Context.Fluent
    local Options = Fluent.Options
    
    local Tab = Window:AddTab({ Title = "Movement", Icon = "move" })

    -- Секция персонажа
    Tab:AddSection("Character Stats")

    -- WalkSpeed
    Tab:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Description = "Set your walking speed",
        Default = 16,
        Min = 16,
        Max = 200,
        Rounding = 1,
        Callback = function(Value)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end
    })

    -- JumpPower
    Tab:AddSlider("JumpPower", {
        Title = "Jump Power",
        Description = "Set your jump height",
        Default = 50,
        Min = 50,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.UseJumpPower = true
                char.Humanoid.JumpPower = Value
            end
        end
    })

    -- Секция способностей
    Tab:AddSection("Abilities")

    -- Infinite Jump
    local InfJumpToggle = Tab:AddToggle("InfJump", {Title = "Infinite Jump", Default = false })
    
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if Options.InfJump and Options.InfJump.Value then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Fly (Полет)
    local FlyToggle = Tab:AddToggle("Fly", {Title = "Enable Fly", Default = false })
    local FlySpeed = Tab:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Default = 50,
        Min = 10,
        Max = 200,
        Rounding = 1
    })

    -- Логика полета (CFrame)
    local flying = false
    local speed = 50
    local bv, bg
    
    FlyToggle:OnChanged(function()
        flying = Options.Fly.Value
        local player = game.Players.LocalPlayer
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if flying and root then
            -- Включаем полет
            bv = Instance.new("BodyVelocity")
            bg = Instance.new("BodyGyro")
            
            bv.Parent = root
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            bg.Parent = root
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P = 10000
            bg.D = 1000
            
            task.spawn(function()
                while flying and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 do
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new()
                    
                    -- Управление (WASD)
                    local userInput = game:GetService("UserInputService")
                    if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                    if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                    
                    bg.CFrame = cam.CFrame
                    bv.Velocity = moveDir * Options.FlySpeed.Value
                    task.wait()
                end
                -- Очистка при выключении
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end)
        else
            -- Выключаем полет
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end)
end
