-- [[ Tabs/Players.lua ]] --
return function(Context)
    local Window = Context.Window
    local Rayfield = Context.Rayfield
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:CreateTab("Players", 4483362458)

    local selectedPlayer = nil
    local playerNames = {}

    local function UpdatePlayerList()
        playerNames = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
        end
    end
    UpdatePlayerList()

    local Dropdown = Tab:CreateDropdown({
        Name = "Select Player",
        Options = playerNames,
        CurrentOption = "",
        Flag = "PlayerSelect", 
        Callback = function(Option)
            selectedPlayer = Players:FindFirstChild(Option[1]) -- Rayfield возвращает таблицу
        end,
    })

    Tab:CreateButton({
        Name = "Refresh List",
        Callback = function()
            UpdatePlayerList()
            Dropdown:Refresh(playerNames, true)
        end,
    })

    Tab:CreateButton({
        Name = "Teleport to Player",
        Callback = function()
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            else
                Rayfield:Notify({Title = "Error", Content = "Player not found!", Duration = 3})
            end
        end,
    })

    Tab:CreateSection("Performance")

    Tab:CreateButton({
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
            Rayfield:Notify({Title = "Success", Content = "Textures removed!", Duration = 3})
        end,
    })
end
