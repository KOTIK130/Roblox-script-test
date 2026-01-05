-- [[ Main.lua - ZlinHUB v2.0 Orion ]] --

-- Загрузка Orion UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 6. Приветствие и Анимация
-- Orion имеет встроенную систему уведомлений, но мы сделаем кастомное приветствие в консоль или уведомлением
OrionLib:MakeNotification({
    Name = "ZlinHUB",
    Content = "Здравствуйте, Господин " .. LocalPlayer.Name .. "!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Создание окна
local Window = OrionLib:MakeWindow({
    Name = "ZlinHUB",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ZlinHUB_Config",
    IntroEnabled = true, -- Анимация интро Orion
    IntroText = "Welcome, " .. LocalPlayer.Name
})

-- Глобальная таблица для хранения состояния (чтобы можно было всё выключить при закрытии)
getgenv().ZlinState = {
    Connections = {}, -- Для коннектов (RunService и т.д.)
    DrawingObjects = {}, -- Для ESP
    FlyEnabled = false,
    InfJumpEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    OriginalSettings = { -- Сохраняем оригинальные настройки, чтобы вернуть их
        WalkSpeed = 16,
        JumpPower = 50
    }
}

-- Функция полного сброса (Cleanup)
local function Cleanup()
    print("ZlinHUB: Cleaning up...")
    
    -- Отключаем Fly
    getgenv().ZlinState.FlyEnabled = false
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("ZlinFlyVelocity")
        local bg = char.HumanoidRootPart:FindFirstChild("ZlinFlyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
    
    -- Сбрасываем скорость и прыжок
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = getgenv().ZlinState.OriginalSettings.WalkSpeed
        char.Humanoid.JumpPower = getgenv().ZlinState.OriginalSettings.JumpPower
    end
    
    -- Очищаем ESP
    for _, playerObjects in pairs(getgenv().ZlinState.DrawingObjects) do
        for _, obj in pairs(playerObjects) do
            obj:Remove()
        end
    end
    getgenv().ZlinState.DrawingObjects = {}
    
    -- Разрываем все соединения
    for _, conn in pairs(getgenv().ZlinState.Connections) do
        if conn then conn:Disconnect() end
    end
    getgenv().ZlinState.Connections = {}
    
    print("ZlinHUB: Cleanup complete.")
end

-- Хук на закрытие скрипта (Orion позволяет деструктор при уничтожении GUI, но лучше добавить кнопку Unload)
Window:GetTab("Settings"):AddButton({
    Name = "Unload Script & Reset",
    Callback = function()
        Cleanup()
        OrionLib:Destroy()
    end
})


local Context = {
    Window = Window,
    OrionLib = OrionLib,
    State = getgenv().ZlinState
}

-- Загрузка модулей
local success, err = pcall(function()
    Import("Tabs/Movement.lua")(Context)
    Import("Tabs/Visuals.lua")(Context)
    Import("Tabs/Players.lua")(Context) -- Новая вкладка для TP и Anti-Lag
end)

if not success then
    OrionLib:MakeNotification({
        Name = "Error",
        Content = "Failed to load tabs: " .. tostring(err),
        Time = 5
    })
end

OrionLib:Init()
