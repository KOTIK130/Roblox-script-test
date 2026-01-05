-- [[ Main.lua - ZlinHUB v2.1 DEBUG ]] --

local function SafeLoad(url, name)
    print("Loading " .. name .. "...")
    local success, content = pcall(function() return game:HttpGet(url) end)
    if not success then
        warn("Failed to download " .. name .. ": " .. tostring(content))
        return nil
    end
    local func, err = loadstring(content)
    if not func then
        warn("Syntax error in " .. name .. ": " .. tostring(err))
        return nil
    end
    return func()
end

-- Пробуем загрузить Orion (зеркало)
local OrionUrl = 'https://raw.githubusercontent.com/jhelap/Orion/main/source'
local OrionLib = SafeLoad(OrionUrl, "OrionLib")

if not OrionLib then
    warn("CRITICAL: Orion Library failed to load. Aborting.")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

OrionLib:MakeNotification({
    Name = "ZlinHUB",
    Content = "Welcome back, " .. LocalPlayer.Name,
    Image = "rbxassetid://4483345998",
    Time = 5
})

local Window = OrionLib:MakeWindow({
    Name = "ZlinHUB",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ZlinHUB_Config",
    IntroEnabled = true,
    IntroText = "ZlinHUB Loading..."
})

-- State
getgenv().ZlinState = {
    Connections = {},
    DrawingObjects = {},
    FlyEnabled = false,
    InfJumpEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    OriginalSettings = { WalkSpeed = 16, JumpPower = 50 }
}

-- Context
local Context = {
    Window = Window,
    OrionLib = OrionLib,
    State = getgenv().ZlinState
}

-- Импорт вкладок с проверкой
local tabs = {
    "Tabs/Movement.lua",
    "Tabs/Visuals.lua",
    "Tabs/Players.lua"
}

for _, path in ipairs(tabs) do
    if getgenv().Import then
        local success, result = pcall(function()
            local tabFunc = Import(path) -- Функция импорта из Лоадера
            if tabFunc then
                tabFunc(Context)
            else
                warn("Import returned nil for: " .. path)
            end
        end)
        if not success then
            warn("Failed to execute tab: " .. path .. " | Error: " .. tostring(result))
        else
            print("Successfully loaded tab: " .. path)
        end
    else
        warn("Global function 'Import' not found! Are you running via Loader?")
    end
end

OrionLib:Init()
