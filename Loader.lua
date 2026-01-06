-- [[ Loader.lua ]] --
local User = "KOTIK130"
local Repo = "Roblox-script-test"
local Branch = "main"
local FileName = "OneFile.lua" -- Теперь грузим этот файл

local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s?t=%d", User, Repo, Branch, FileName, os.time())

local success, result = pcall(function()
    return game:HttpGet(url)
end)

if success then
    loadstring(result)()
else
    warn("[Loader] Failed to load script: " .. url)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Loader Error";
        Text = "Check console (F9)";
        Duration = 5;
    })
end
