-- [[ Tabs/Visuals.lua ]] --
return function(Context)
    local Window = Context.Window
    local Rayfield = Context.Rayfield
    local State = Context.State
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local Tab = Window:CreateTab("Visuals", 4483362458)

    local EspConfig = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Tracers = false,
        Color = Color3.fromRGB(255, 0, 0)
    }

    Tab:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Callback = function(Value) EspConfig.Enabled = Value end,
    })

    Tab:CreateToggle({
        Name = "Show Boxes",
        CurrentValue = true,
        Callback = function(Value) EspConfig.Boxes = Value end,
    })

    Tab:CreateToggle({
        Name = "Show Names",
        CurrentValue = true,
        Callback = function(Value) EspConfig.Names = Value end,
    })
    
    -- Color Picker в Rayfield немного другой, но пока оставим дефолт
    -- (Rayfield ColorPicker сложнее в реализации через код, оставим фиксированный красный или добавим позже)

    -- Логика ESP (та же самая, что и была, она универсальна)
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
end
