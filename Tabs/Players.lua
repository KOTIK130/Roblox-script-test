-- [[ Tabs/Players.lua ]] --
return function(Context)
    local Window = Context.Window
    local OrionLib = Context.OrionLib
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:MakeTab({
        Name = "Players & Utils",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- 3. Teleport to Player
    Tab:AddSection({ Name = "Teleport" })
    
    local selectedPlayer = nil
    
    -- Получаем список имен игроков
    local function GetPlayerList()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        return list
    end

    local PlayerDropdown = Tab:AddDropdown({
        Name = "Select Player",
        Default = "",
        Options = GetPlayerList(),
        Callback = function(Value)
            selectedPlayer = Players:FindFirstChild(Value)
        end    
    })
    
    -- Кнопка обновления списка (если кто-то зашел/вышел)
    Tab:AddButton({
        Name = "Refresh Player List",
        Callback = function()
            PlayerDropdown:Refresh(GetPlayerList(), true)
        end    
    })
    
    Tab:AddButton({
        Name = "Teleport to Player",
        Callback = function()
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = selectedPlayer.Character.HumanoidRootPart.CFrame
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos + Vector3.new(0, 3, 0) -- Чуть выше, чтобы не застрять
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Player not found or character missing.",
                    Time = 3
                })
            end
        end    
    })

    -- 4. Anti-Lag (FPS Boost)
    Tab:AddSection({ Name = "Performance" })
    
    Tab:AddButton({
        Name = "Anti-Lag (Remove Textures)",
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
            
            -- Удаляем текстуры со всех MeshPart и Part
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy() -- Удаляем наклейки и текстуры
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
            
            OrionLib:MakeNotification({
                Name = "Anti-Lag",
                Content = "Textures removed. FPS should increase.",
                Time = 3
            })
        end    
    })
end
