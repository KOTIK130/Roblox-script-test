-- [[ Tabs/Movement.lua ]] --
return function(Context)
    local Window = Context.Window
    local OrionLib = Context.OrionLib
    local State = Context.State
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:MakeTab({
        Name = "Movement",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- WalkSpeed
    Tab:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 250,
        Default = 16,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            State.WalkSpeed = Value
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end    
    })
    
    -- JumpPower
    Tab:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 350,
        Default = 50,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "Power",
        Callback = function(Value)
            State.JumpPower = Value
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.UseJumpPower = true
                LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end    
    })
    
    -- Infinite Jump
    Tab:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(Value)
            State.InfJumpEnabled = Value
        end    
    })
    
    -- Коннект для InfJump
    local jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
        if State.InfJumpEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    table.insert(State.Connections, jumpConn)
    
    -- Поддержание скорости при респавне
    local respawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        task.wait(0.5)
        char.Humanoid.WalkSpeed = State.WalkSpeed
        char.Humanoid.JumpPower = State.JumpPower
        char.Humanoid.UseJumpPower = true
    end)
    table.insert(State.Connections, respawnConn)


    -- 2. Улучшенный Fly (WASD only, camera direction)
    local FlySpeed = 50
    
    Tab:AddSlider({
        Name = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Color = Color3.fromRGB(0, 255, 255),
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            FlySpeed = Value
        end    
    })

    Tab:AddToggle({
        Name = "Enable Fly",
        Default = false,
        Callback = function(Value)
            State.FlyEnabled = Value
            
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if Value then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "ZlinFlyVelocity"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                
                local bg = Instance.new("BodyGyro", root)
                bg.Name = "ZlinFlyGyro"
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 10000
                bg.D = 1000
                
                -- Логика полета в цикле
                local flyLoop; flyLoop = RunService.RenderStepped:Connect(function()
                    if not State.FlyEnabled or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                        if bv then bv:Destroy() end
                        if bg then bg:Destroy() end
                        flyLoop:Disconnect()
                        return
                    end
                    
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new(0, 0, 0)
                    local uis = game:GetService("UserInputService")
                    
                    -- Вектора направления камеры (без Y для движения по плоскости, но мы хотим летать за камерой)
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector
                    
                    if uis:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + look
                    end
                    if uis:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - look
                    end
                    if uis:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + right
                    end
                    if uis:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - right
                    end
                    
                    -- Игнорируем Shift/Space для вертикали, летим только туда, куда смотрим + WASD
                    
                    bg.CFrame = cam.CFrame
                    bv.Velocity = moveDir * FlySpeed
                end)
            else
                local bv = root:FindFirstChild("ZlinFlyVelocity")
                local bg = root:FindFirstChild("ZlinFlyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end    
    })
end
