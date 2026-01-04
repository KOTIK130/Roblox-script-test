-- [[ KOTIK130 Hub Loader ]] --
-- Этот файл лежит в корне репозитория и запускает всё остальное.

local User = "KOTIK130"
local Repo = "Roblox-script-test"
local Branch = "main"

-- Функция для формирования ссылок на другие файлы в этом же репо
local function GetURL(path)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", User, Repo, Branch, path)
end

-- Делаем эти функции доступными глобально для всех остальных модулей
getgenv().RepoURL = GetURL

getgenv().Import = function(path)
    local url = GetURL(path)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("[Loader] Failed to fetch module: " .. path)
        return function() end 
    end
    
    local func, err = loadstring(result)
    if not func then
        warn("[Loader] Syntax error in module: " .. path .. " | Error: " .. tostring(err))
        return function() end
    end
    
    return func()
end

-- Теперь, когда функции Import готовы, запускаем Main.lua
-- Main.lua уже будет использовать этот же Import для загрузки вкладок
local mainUrl = GetURL("Main.lua")
local success, err = pcall(function()
    loadstring(game:HttpGet(mainUrl))()
end)

if not success then
    warn("[Loader] Critical Error loading Main.lua: " .. tostring(err))
end
