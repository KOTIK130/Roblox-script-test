-- [[ Tabs/Home.lua ]] --
return function(Context)
    local Window = Context.Window
    local Fluent = Context.Fluent
    
    local Tab = Window:AddTab({ Title = "Home", Icon = "home" })

    Tab:AddParagraph({
        Title = "Welcome",
        Content = "Welcome to KOTIK130 Hub.\nThis script is loaded dynamically from GitHub."
    })
    
    Tab:AddParagraph({
        Title = "Status",
        Content = "Game ID: " .. tostring(game.GameId) .. "\nPlace ID: " .. tostring(game.PlaceId)
    })
    
    Tab:AddButton({
        Title = "Rejoin Server",
        Description = "Re-connect to the same server",
        Callback = function()
            local ts = game:GetService("TeleportService")
            local p = game:GetService("Players").LocalPlayer
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
        end
    })

    Tab:AddButton({
        Title = "Server Hop",
        Description = "Join a different server",
        Callback = function()
            -- Простой алгоритм ServerHop
            local Http = game:GetService("HttpService")
            local TPS = game:GetService("TeleportService")
            local Api = "https://games.roblox.com/v1/games/"
            local _place = game.PlaceId
            local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
            
            local function ListServers(cursor)
               local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
               return Http:JSONDecode(Raw)
            end
            
            local Server, Next; repeat
               local Servers = ListServers(Next)
               Server = Servers.data[1]
               Next = Servers.nextPageCursor
            until Server
            
            TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)
        end
    })
end
