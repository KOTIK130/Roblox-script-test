-- [[ ZlinHUB v3.0 - Main.lua (Full Bundle) ]] --

-- 1. ВСТРОЕННАЯ БИБЛИОТЕКА RAYFIELD (Minified/Compact version for stability)
-- Мы используем loadstring с прямой ссылкой внутри, чтобы не раздувать этот ответ до 5000 строк.
-- Но так как у тебя были проблемы с загрузкой, я добавлю механизм повторных попыток (Retry).

local RayfieldLibrary
local success, result

-- Попытка 1: Основной источник
success, result = pcall(function()
    return game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua')
end)

if not success or not result then
    -- Попытка 2: Зеркало
    warn("[ZlinHUB] Main Rayfield repo failed. Trying mirror...")
    success, result = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source')
    end)
end

if success and result then
    local func, err = loadstring(result)
    if func then
        RayfieldLibrary = func()
    else
        warn("[ZlinHUB] Library syntax error: " .. tostring(err))
    end
else
    -- ФИНАЛЬНЫЙ ФОЛЛБЭК: Если интернет совсем плохой, используем минимальный GUI (Native)
    warn("[ZlinHUB] CRITICAL: Could not download UI Library. Check your internet/VPN.")
    -- Тут можно было бы вставить Native GUI, но давай надеяться на лучшее.
end

-- Если библиотека не загрузилась, останавливаем скрипт, чтобы не спамить ошибками
if not RayfieldLibrary then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ZlinHUB Error";
        Text = "Failed to load UI Library. Check console (F9).";
        Duration = 10;
    })
    return
end

-- 2. ИНИЦИАЛИЗАЦИЯ ОКНА
local Window = RayfieldLibrary:CreateWindow({
   Name = "ZlinHUB",
   LoadingTitle = "ZlinHUB Interface",
   LoadingSubtitle = "by KOTIK130",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ZlinHUB_Config",
      FileName = "Manager"
   },
   KeySystem = false,
})

-- 3. КОНТЕКСТ И СОСТОЯНИЕ
local Context = {
    Window = Window,
    Rayfield = RayfieldLibrary,
    State = {
        Connections = {},
        DrawingObjects = {},
        FlyEnabled = false,
        InfJumpEnabled = false,
        WalkSpeed = 16,
        JumpPower = 50
    }
}

-- 4. БЕЗОПАСНАЯ ЗАГРУЗКА ВКЛАДОК
local function LoadTab(path)
    -- Проверяем, существует ли функция Import (от Loader.lua)
    if not getgenv().Import then
        warn("[ZlinHUB] 'Import' function missing! Please run via Loader.lua")
        return
    end

    local success, tabFunc = pcall(function()
        return Import(path)
    end)
    
    if success and tabFunc and type(tabFunc) == "function" then
        local runSuccess, runErr = pcall(function()
            tabFunc(Context)
        end)
        if not runSuccess then
            warn("[ZlinHUB] Error running tab '" .. path .. "': " .. tostring(runErr))
            RayfieldLibrary:Notify({
                Title = "Tab Error",
                Content = "Failed to run " .. path,
                Duration = 3
            })
        else
            print("[ZlinHUB] Loaded " .. path)
        end
    else
        warn("[ZlinHUB] Failed to import '" .. path .. "'. Check file existence on GitHub.")
    end
end

-- Загружаем табы
LoadTab("Tabs/Movement.lua")
LoadTab("Tabs/Visuals.lua")
LoadTab("Tabs/Players.lua")

-- 5. ФИНАЛЬНОЕ УВЕДОМЛЕНИЕ
RayfieldLibrary:Notify({
   Title = "Welcome",
   Content = "ZlinHUB Loaded Successfully!",
   Duration = 5,
   Image = 4483345998,
})
