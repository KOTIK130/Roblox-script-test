-- [[ Tesavek Public Loader ]] --
local User = "KOTIK130" -- Твой ник на GitHub
local Repo = "Roblox-script-test"   -- Название репозитория
local Branch = "main"     -- Ветка (обычно main)

local function GetURL(path)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", User, Repo, Branch, path)
end

-- Глобальная переменная для базы URL, чтобы модули тоже могли её использовать
getgenv().RepoURL = function(path)
    return GetURL(path)
end

-- Глобальная функция импорта для модулей
getgenv().Import = function(path)
    return loadstring(game:HttpGet(GetURL(path)))()
end

-- Запуск
loadstring(game:HttpGet(GetURL("Main.lua")))()
