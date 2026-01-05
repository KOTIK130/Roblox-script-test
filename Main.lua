-- [[ Main.lua - ZlinHUB v3.0 Rayfield Fix ]] --

-- Функция безопасной загрузки
local function SecureLoad(url)
    local success, content = pcall(function() return game:HttpGet(url) end)
    if not success or not content then return nil, "HTTP Error" end
    local func, err = loadstring(content)
    if not func then return nil, err end
    return func
end

-- Попытка загрузить Rayfield Interface Suite
local Rayfield = SecureLoad('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua')()

-- Если и это не загрузилось, попробуем зеркало (на случай блокировки)
if not Rayfield then
   warn("Main repo blocked. Trying mirror...")
   Rayfield = SecureLoad('https://raw.githubusercontent.com/shlexware/Rayfield/main/source')()
end

if not Rayfield then
    warn("CRITICAL ERROR: Failed to load UI Library.")
    game.StarterGui:SetCore("SendNotification", {
        Title = "ZlinHUB Error";
        Text = "UI Library blocked. Check connection.";
        Duration = 5;
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "ZlinHUB",
    LoadingTitle = "ZlinHUB Interface",
    LoadingSubtitle = "by KOTIK130",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZlinHUB_Config",
        FileName = "Manager"
    },
    KeySystem = false, -- Можно включить, если нужно
})

local Context = {
    Window = Window,
    Rayfield = Rayfield, -- Передаем Rayfield вместо Fluent/Orion
    State = {
        Connections = {},
        DrawingObjects = {},
    }
}

-- [[ ВНИМАНИЕ ]]
-- Тебе нужно будет обновить Tabs/Movement.lua, Tabs/Visuals.lua и т.д., 
-- так как синтаксис Rayfield отличается от Orion и Fluent.
-- Если загрузятся старые табы с Orion кодом — будет ошибка.
-- ПОКА ДАВАЙ ПРОВЕРИМ, ОТКРОЕТСЯ ЛИ МЕНЮ БЕЗ ВКЛАДОК.

-- Import("Tabs/Movement.lua")(Context) -- ЗАКОММЕНТИРУЙ ЭТИ СТРОКИ ДЛЯ ТЕСТА!
-- Import("Tabs/Visuals.lua")(Context)

Rayfield:Notify({
    Title = "Welcome",
    Content = "UI Library Loaded Successfully!",
    Duration = 6.5,
    Image = 4483345998,
})
