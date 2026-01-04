-- [[ Main.lua ]] --
-- Этот файл загружается первым через Loader

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "KOTIK130 Hub",
    SubTitle = "v1.0 Public Build",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Объект контекста для передачи данных в модули
local Context = {
    Window = Window,
    Fluent = Fluent,
    SaveManager = SaveManager,
    InterfaceManager = InterfaceManager
}

-- [[ ЗАГРУЗКА ВКЛАДОК ]] --
-- Используем глобальную функцию Import, созданную Лоадером
local success, err = pcall(function()
    Import("Tabs/Home.lua")(Context)
    Import("Tabs/Farming.lua")(Context)
end)

if not success then
    warn("Error importing tabs: " .. tostring(err))
    Fluent:Notify({
        Title = "Error",
        Content = "Failed to load some tabs. Check console.",
        Duration = 5
    })
end

-- Выбор первой вкладки при запуске
Window:SelectTab(1)

-- Уведомление об успешном запуске
Fluent:Notify({
    Title = "KOTIK130 Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})

-- Настройка менеджеров (сохранение конфигов)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Window.Tabs.Settings) -- Автоматически создаст секцию настроек UI, если вкладка Settings существует
SaveManager:LoadAutoloadConfig()
