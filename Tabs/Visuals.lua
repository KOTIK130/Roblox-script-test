-- [[ Tabs/Visuals.lua ]] --
return function(Context)
    local Window = Context.Window
    local OrionLib = Context.OrionLib
    local State = Context.State
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local Tab = Window:MakeTab({
        Name = "Visuals",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local EspConfig = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Tracers = false,
        Color = Color3.fromRGB(255, 60, 60),
        TextSize = 13
    }

    Tab:AddToggle({
        Name = "Enable ESP",
        Default = false,
        Callback = function(Value)
            EspConfig.Enabled = Value
        end    
    })

    Tab:AddToggle({
        Name = "Show Boxes",
        Default = true,
        Callback = function(Value) EspConfig.Boxes = Value end    
    })
    
    Tab:AddToggle({
        Name = "Show Names",
        Default = true,
        Callback = function(Value) EspConfig.Names = Value end    
    })
    
    Tab:AddToggle({
        Name = "Show Tracers",
        Default = false,
        Callback = function(Value) EspConfig.Tracers = Value end    
    })

    Tab:AddColorpicker({
        Name = "ESP Color",
        Default = Color3.fromRGB(255, 60, 60),
        Callback = function(Value)
            EspConfig.Color = Value
        end    
    })

    -- Логика отрисовки
    local function CreateDrawing(type)
        local obj = Drawing.new(type)
        obj.Visible = false
        return obj
    end

    local function AddEsp(player)
        if player == LocalPlayer then return end
        
        local objects = {
            BoxOutline = CreateDrawing("Square"),
            Box = CreateDrawing("Square"),
            Name = CreateDrawing("Text"),
            Tracer = CreateDrawing("Line")
        }
        
        -- Настройка стилей
        objects.BoxOutline.Color = Color3.new(0,0,0) -- Черная обводка для контраста
        objects.BoxOutline.Thickness = 3
        objects.BoxOutline.Filled = false
        
        objects.Box.Thickness = 1
        objects.Box.Filled = false
        
        objects.Name.Center = true
        objects.Name.Outline = true
        objects.Name.OutlineColor = Color3.new(0,0,0)
        objects.Name.Font = 2 -- 0=UI, 1=System, 2=Plex, 3=Monospace (Plex выглядит аккуратно)
        objects.Name.Size = EspConfig.TextSize
        
        objects.Tracer.Thickness = 1
        
        State.DrawingObjects[player] = objects
    end

    local function RemoveEsp(player)
        if State.DrawingObjects[player] then
            for _, obj in pairs(State.DrawingObjects[player]) do
                obj:Remove()
            end
            State.DrawingObjects[player] = nil
        end
    end

    -- Обновление
    local espLoop = RunService.RenderStepped:Connect(function()
        if not EspConfig.Enabled then
            for _, pData in pairs(State.DrawingObjects) do
                for _, obj in pairs(pData) do obj.Visible = false end
            end
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not State.DrawingObjects[player] then
                    AddEsp(player)
                end
                
                local char = player.Character
                local objs = State.DrawingObjects[player]
                
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local root = char.HumanoidRootPart
                    local head = char:FindFirstChild("Head")
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        local color = EspConfig.Color
                        
                        -- Расчет размеров бокса
                        local rootPos = root.Position
                        local headPos = head and head.Position or (rootPos + Vector3.new(0,2,0))
                        local legPos = rootPos - Vector3.new(0,3,0)
                        
                        local top, _ = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.5, 0))
                        local bottom, _ = Camera:WorldToViewportPoint(legPos)
                        
                        local height = math.abs(top.Y - bottom.Y)
                        local width = height / 1.6 -- Стандартное соотношение
                        
                        -- BOX
                        if EspConfig.Boxes then
                            local boxPos = Vector2.new(pos.X - width/2, pos.Y - height/2)
                            
                            -- Черная обводка
                            objs.BoxOutline.Size = Vector2.new(width, height)
                            objs.BoxOutline.Position = boxPos
                            objs.BoxOutline.Visible = true
                            
                            -- Цветной бокс
                            objs.Box.Size = Vector2.new(width, height)
                            objs.Box.Position = boxPos
                            objs.Box.Color = color
                            objs.Box.Visible = true
                        else
                            objs.BoxOutline.Visible = false
                            objs.Box.Visible = false
                        end
                        
                        -- NAME
                        if EspConfig.Names then
                            objs.Name.Text = player.Name .. " [" .. math.floor(char.Humanoid.Health) .. " HP]"
                            objs.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                            objs.Name.Color = color
                            objs.Name.Visible = true
                        else
                            objs.Name.Visible = false
                        end
                        
                        -- TRACER
                        if EspConfig.Tracers then
                            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            objs.Tracer.To = Vector2.new(pos.X, pos.Y + height/2) -- К ногам
                            objs.Tracer.Color = color
                            objs.Tracer.Visible = true
                        else
                            objs.Tracer.Visible = false
                        end
                    else
                         for _, obj in pairs(objs) do obj.Visible = false end
                    end
                else
                    for _, obj in pairs(objs) do obj.Visible = false end
                end
            end
        end
    end)
    table.insert(State.Connections, espLoop)
    
    Players.PlayerRemoving:Connect(RemoveEsp)
end
