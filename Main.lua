-- [[ Main.lua ]] --
-- ZlinHUB v1.0

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 5. Анимация загрузки (Простая имитация)
-- Можно добавить звук или GUI эффект, но пока сделаем красивое уведомление
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "ZlinHUB",
    Text = "Loading resources...",
    Icon = "rbxassetid://16447990029", -- Можно свою иконку
    Duration = 3
})
task.wait(1)

local Window = Fluent:CreateWindow({
    Title = "ZlinHUB",
    SubTitle = "by KOTIK130",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- 2. Непрозрачный фон
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl -- 4. Правый Ctrl для скрытия
})

local Context = {
    Window = Window,
    Fluent = Fluent,
    SaveManager = SaveManager,
    InterfaceManager = InterfaceManager
}

-- [[ ЗАГРУЗКА МОДУЛЕЙ ]] --
local success, err = pcall(function()
    Import("Tabs/Home.lua")(Context)
    -- Import("Tabs/Farming.lua")(Context) -- Убираем, если не нужно, или оставляем для других функций
    Import("Tabs/Movement.lua")(Context) -- 3. Новая вкладка
    Import("Tabs/Visuals.lua")(Context)  -- 6. Новая вкладка ESP
end)

if not success then
    warn("Error importing tabs: " .. tostring(err))
    Fluent:Notify({
        Title = "Error",
        Content = "Failed to load modules. Check F9 console.",
        Duration = 5
    })
end

-- Настройка менеджеров
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

-- Создаем вкладку Settings автоматически
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })
InterfaceManager:BuildInterfaceSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

Window:SelectTab(1)

Fluent:Notify({
    Title = "ZlinHUB",
    Content = "Successfully Loaded!",
    SubContent = "Press Right Ctrl to toggle menu",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
