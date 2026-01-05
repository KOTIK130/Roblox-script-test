-- [[ Loader.lua ]] --
local User = "KOTIK130"
local Repo = "Roblox-script-test"
local Branch = "main"

local function GetURL(path)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s?t=%d", User, Repo, Branch, path, os.time())
end

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

local mainUrl = GetURL("Main.lua")
loadstring(game:HttpGet(mainUrl))()
