-- [[ Tabs/Farming.lua ]] --
return function(Context)
    local Window = Context.Window
    local Fluent = Context.Fluent
    local Options = Fluent.Options
    
    local Tab = Window:AddTab({ Title = "Farming", Icon = "leaf" })

    local MainSection = Tab:AddSection("Main Features")

    local AutoClick = Tab:AddToggle("AutoClick", {Title = "Auto Click / Tool", Default = false })

    AutoClick:OnChanged(function()
        task.spawn(function()
            while Options.AutoClick.Value do
                -- Пытаемся активировать инструмент в руке
                pcall(function()
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local tool = character:FindFirstChildOfClass("Tool")
                    
                    if tool then
                        tool:Activate()
                    else
                        -- Если инструмента нет, просто кликаем мышкой (виртуально)
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                    end
                end)
                task.wait(0.1) -- Задержка между кликами
            end
        end)
    end)
    
    local SpeedSlider = Tab:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Description = "Изменить скорость бега",
        Default = 16,
        Min = 16,
        Max = 150,
        Rounding = 1,
        Callback = function(Value)
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = Value
            end
        end
    })

    -- Обновляем скорость при респавне, иначе она сбросится
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        task.wait(0.5)
        if Options.WalkSpeed then
            char.Humanoid.WalkSpeed = Options.WalkSpeed.Value
        end
    end)
    
    Tab:AddToggle("NoClip", {Title = "Noclip (Walk Through Walls)", Default = false }):OnChanged(function()
        local state = Options.NoClip.Value
        local character = game.Players.LocalPlayer.Character
        
        if state then
            -- Включаем цикл Noclip
            task.spawn(function()
                while Options.NoClip.Value do
                    if character then
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end)
end
