-- [[ Tabs/Movement.lua ]] --
return function(Context)
    local Window = Context.Window
    local Rayfield = Context.Rayfield
    local State = Context.State
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:CreateTab("Movement", 4483362458) -- Иконка бега

    Tab:CreateSection("Character Stats")

    Tab:CreateSlider({
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

    Tab:CreateSlider({
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

    Tab:CreateSection("Abilities")

    Tab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfJump", 
        Callback = function(Value)
            State.InfJumpEnabled = Value
        end,
    })

    -- Логика InfJump
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if State.InfJumpEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Fly
    local FlySpeed = 50
    Tab:CreateSlider({
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

    Tab:CreateToggle({
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
end
