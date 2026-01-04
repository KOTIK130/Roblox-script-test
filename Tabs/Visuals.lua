-- [[ Tabs/Visuals.lua ]] --
return function(Context)
    local Window = Context.Window
    local Fluent = Context.Fluent
    local Options = Fluent.Options
    
    local Tab = Window:AddTab({ Title = "Visuals", Icon = "eye" })

    Tab:AddSection("ESP Settings")

    local ESP_Enabled = Tab:AddToggle("EspEnabled", {Title = "Enable ESP", Default = false })
    local ESP_Boxes = Tab:AddToggle("EspBoxes", {Title = "Show Boxes", Default = true })
    local ESP_Names = Tab:AddToggle("EspNames", {Title = "Show Names", Default = true })
    local ESP_Tracers = Tab:AddToggle("EspTracers", {Title = "Show Tracers", Default = false })
    
    local ESP_Color = Tab:AddColorpicker("EspColor", {
        Title = "ESP Color",
        Default = Color3.fromRGB(255, 0, 0)
    })

    -- Логика ESP
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local drawings = {} -- Хранилище объектов отрисовки

    -- Функция очистки ESP для игрока
    local function removeEsp(player)
        if drawings[player] then
            for _, drawing in pairs(drawings[player]) do
                drawing:Remove()
            end
            drawings[player] = nil
        end
    end

    -- Функция создания ESP для игрока
    local function createEsp(player)
        if player == LocalPlayer then return end
        
        local objects = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Tracer = Drawing.new("Line")
        }
        
        -- Настройка начальных свойств
        objects.Box.Visible = false
        objects.Box.Color = Options.EspColor.Value
        objects.Box.Thickness = 1
        objects.Box.Filled = false
        
        objects.Name.Visible = false
        objects.Name.Color = Options.EspColor.Value
        objects.Name.Size = 14
        objects.Name.Center = true
        objects.Name.Outline = true
        
        objects.Tracer.Visible = false
        objects.Tracer.Color = Options.EspColor.Value
        objects.Tracer.Thickness = 1
        
        drawings[player] = objects
    end

    -- Обновление ESP каждый кадр
    RunService.RenderStepped:Connect(function()
        if not Options.EspEnabled.Value then
            for _, playerDrawings in pairs(drawings) do
                for _, drawing in pairs(playerDrawings) do
                    drawing.Visible = false
                end
            end
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if not drawings[player] then createEsp(player) end
                
                local char = player.Character
                local root = char.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                local objs = drawings[player]
                local color = Options.EspColor.Value

                if onScreen then
                    -- Box
                    if Options.EspBoxes.Value then
                        local size = Vector2.new(2000 / vector.Z, 2500 / vector.Z) -- Размер зависит от дистанции
                        local pos = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                        
                        objs.Box.Size = size
                        objs.Box.Position = pos
                        objs.Box.Color = color
                        objs.Box.Visible = true
                    else
                        objs.Box.Visible = false
                    end

                    -- Name
                    if Options.EspNames.Value then
                        objs.Name.Text = player.Name
                        objs.Name.Position = Vector2.new(vector.X, vector.Y - (2500 / vector.Z) / 2 - 15)
                        objs.Name.Color = color
                        objs.Name.Visible = true
                    else
                        objs.Name.Visible = false
                    end

                    -- Tracer
                    if Options.EspTracers.Value then
                        objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- От низа центра экрана
                        objs.Tracer.To = Vector2.new(vector.X, vector.Y)
                        objs.Tracer.Color = color
                        objs.Tracer.Visible = true
                    else
                        objs.Tracer.Visible = false
                    end
                else
                    objs.Box.Visible = false
                    objs.Name.Visible = false
                    objs.Tracer.Visible = false
                end
            else
                removeEsp(player)
            end
        end
    end)

    Players.PlayerRemoving:Connect(removeEsp)
end
