-- DZv1.lua - Fish It Script dengan WindUI
-- Script ini menggabungkan berbagai fitur untuk Fish It game

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/dzzzet/WindUI/main/source.lua"))()

-- Safe require function
local function safeRequire(module)
    local success, result = pcall(require, module)
    return success and result or nil
end

-- Configuration
local config = {
    autoFish = {
        castDelaySeconds = 0.5,
        catchDelaySeconds = 1.0,
        cooldownDelaySeconds = 0.8,
        safetyTimeoutSeconds = 15,
        stopAfterCatchDelaySeconds = 2
    },
    autoSell = {
        thresholdDelaySeconds = 1.0
    },
    autoFarm = {
        teleportDelaySeconds = 2.0,
        islandCheckDelaySeconds = 1.0,
        minTeleportIntervalSeconds = 5.0
    },
    tpEvent = {
        pollIntervalSeconds = 2.0,
        teleportDelaySeconds = 1.0,
        resumeDelaySeconds = 2.0,
        platformHeight = 10
    },
    weather = {
        pollIntervalSeconds = 3.0,
        baseCooldownSeconds = 30,
        perWeatherCooldownSeconds = {
            ["Wind"] = 25,
            ["Snow"] = 30,
            ["Cloudy"] = 20,
            ["Storm"] = 35,
            ["Shark Hunt"] = 40
        },
        preCheckDelaySeconds = 0.5,
        verifyDelaySeconds = 1.0,
        purchaseRetryCount = 2,
        failedRetryDelaySeconds = 5.0
    }
}

-- State management
local state = {
    AutoFish = false,
    AutoFarm = false,
    AutoSell = false,
    AutoFavourite = false,
    PerfectCast = false,
    InfiniteJump = false,
    InfiniteOxygen = false,
    WalkSpeed = 16,
    AutoRejoin = false,
    LowGraphics = false,
    FPSCap = 60,
    StopAfterCatch = false,
    SellThreshold = 50,
    FavoriteTiers = {},
    AutoTPEvent = false,
    AutoBuyWeather = false
}

-- Global variables
_G.autoFishLoop = nil

-- Get network folder
local function getNetFolder()
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Network", 5)
    end)
    return success and result or nil
end

-- Build main window
local function buildWindow()
    local Window = WindUI:CreateWindow({
        Title = "DZv1 - Fish It Script",
        SubTitle = "Advanced Fishing Automation",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Icon = "circle-check",
        User = { Anonymous = false }
    })
    
    local UI = Window:GetUI()
    
    -- Create tabs
    local Dev = Window:Tab({ Title = "Developer Info", Icon = "code" })
    local MainFeautures = Window:Tab({ Title = "Auto Fish", Icon = "fish" })
    local Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
    local Player = Window:Tab({ Title = "Player", Icon = "user" })
    local SettingsMisc = Window:Tab({ Title = "Settings & Misc", Icon = "settings" })
    local AutoFavorite = Window:Tab({ Title = "Auto Favorite", Icon = "heart" })
    local Weathershop = Window:Tab({ Title = "Weather", Icon = "cloud-rain" })
    local Shop = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
    local Webhook = Window:Tab({ Title = "Webhook", Icon = "message-circle" })
    
    -- Set default tab
    Window:SetTab(Dev)
    
    -------------------------------------------
    ----- =======[ DEVELOPER / CREDITS ]
    -------------------------------------------
    Dev:Paragraph({ Title = "Credits", Desc = "UI: WindUI\nDev: @dzzzet", Locked = true })
    
    -------------------------------------------
    ----- =======[ WEATHER TAB ]
    -------------------------------------------
    Weathershop:Paragraph({
        Title = "🌦️ Weather Features",
        Desc = "Coming Soon",
        Locked = true
    })
    
    -------------------------------------------
    ----- =======[ SHOP TAB ]
    -------------------------------------------
    Shop:Paragraph({
        Title = "🛒 Shop",
        Desc = "Coming Soon",
        Locked = true
    })

    -------------------------------------------
    ----- =======[ AUTO FISH TAB ]
    -------------------------------------------
    MainFeautures:Paragraph({
        Title = "🎣 Auto Fishing Features",
        Desc = "Configure your automated fishing experience with these powerful features.",
        Locked = true
    })
    
    local autoFishToggle
    autoFishToggle = MainFeautures:Toggle({ 
        Title = "Auto Fish (Include Perfect Fish)", 
        Callback = function(Value)
            state.AutoFish = Value
            if Value then startAutoFish() else stopAutoFish() end
        end
    })
    
    MainFeautures:Toggle({
        Title = "Auto Sell (Threshold Based)",
        Callback = function(Value)
            state.AutoSell = Value
            if Value then startAutoSell() end
        end
    })
    
    MainFeautures:Input({
        Title = "Sell Threshold (Fish Count)",
        Placeholder = tostring(state.SellThreshold),
        Callback = function(txt)
            local num = tonumber(txt)
            if num and num >= 10 and num <= 200 then
                state.SellThreshold = num
            end
        end
    })
    
    MainFeautures:Button({
        Title = "Sell All Items Now",
        Callback = function()
            local netFolder = getNetFolder()
            if netFolder then
                local sellFunc = netFolder:FindFirstChild("RF/SellAllItems")
                if sellFunc then
                    sellFunc:InvokeServer()
                    pcall(function() UI:Notify({ Title = "Auto Sell", Content = "Sold all items!", Duration = 3, Icon = "circle-check" }) end)
                end
            end
        end
    })
    
    -------------------------------------------
    ----- =======[ AUTO FAVORITE TAB ]
    -------------------------------------------
    AutoFavorite:Paragraph({
        Title = "❤️ Auto Favorite Features",
        Desc = "Automatically favorite fish based on their tier to prevent accidental selling.",
        Locked = true
    })
    
    -- Tier names for dropdown
    local tierNames = {"Epic", "Legendary", "Mythic", "Secret"}
    
    -- Auto favorite state management
    local favoriteState = {
        selectedList = {}
    }
    
    -- Auto favorite dropdown
    AutoFavorite:Dropdown({
        Title = "Select Fish Tiers to Auto-Favorite",
        Desc = "Choose which fish tiers should be automatically favorited",
        Values = tierNames,
        Multi = true,
        AllowNone = true,
        Callback = function(selectedTiers)
            favoriteState.selectedList = selectedTiers or {}
            -- Update state for compatibility
            state.FavoriteTiers = {}
            for _, tier in ipairs(favoriteState.selectedList) do
                state.FavoriteTiers[tier] = true
            end
        end
    })
    
    -- Auto favorite toggle
    AutoFavorite:Toggle({
        Title = "Enable Auto Favorite",
        Desc = "Automatically favorite fish of selected tiers",
        Callback = function(value)
            state.AutoFavourite = value
            if value then
                if #favoriteState.selectedList == 0 then
                    pcall(function() UI:Notify({ Title = "No Selection", Content = "Please select at least one fish tier first", Duration = 3, Icon = "alert-triangle" }) end)
                    state.AutoFavourite = false
                    return
                end
                pcall(function() UI:Notify({ Title = "Auto Favorite", Content = "Started auto-favoriting " .. #favoriteState.selectedList .. " selected tiers", Duration = 3, Icon = "heart" }) end)
            else
                pcall(function() UI:Notify({ Title = "Auto Favorite", Content = "Stopped auto-favoriting fish", Duration = 3, Icon = "heart" }) end)
            end
        end
    })
    
    -------------------------------------------
    ----- =======[ PLAYER TAB ]
    -------------------------------------------
    Player:Paragraph({
        Title = "👤 Player Controls",
        Desc = "Control your character's movement and abilities.",
        Locked = true
    })
    
    -- WalkSpeed input
    Player:Input({
        Title = "Walk Speed",
        Placeholder = tostring(state.WalkSpeed),
        Callback = function(text)
            local num = tonumber(text)
            if num and num >= 16 and num <= 150 then
                state.WalkSpeed = num
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = num
                end
            end
        end
    })
    
    -- Quick WalkSpeed buttons
    Player:Button({
        Title = "Walk Speed: 16 (Default)",
        Callback = function()
            state.WalkSpeed = 16
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
            end
        end
    })
    
    Player:Button({
        Title = "Walk Speed: 50 (Fast)",
        Callback = function()
            state.WalkSpeed = 50
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 50
            end
        end
    })
    
    Player:Button({
        Title = "Walk Speed: 100 (Very Fast)",
        Callback = function()
            state.WalkSpeed = 100
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 100
            end
        end
    })
    
    -- Infinite Jump toggle
    Player:Toggle({
        Title = "Infinite Jump",
        Callback = function(value)
            state.InfiniteJump = value
            if value then
                startInfiniteJump()
            else
                stopInfiniteJump()
            end
        end
    })
    
    -- Infinite Oxygen toggle
    Player:Toggle({
        Title = "Infinite Oxygen",
        Callback = function(value)
            state.InfiniteOxygen = value
            if value then
                startInfiniteOxygen()
            else
                stopInfiniteOxygen()
            end
        end
    })
    
    -------------------------------------------
    ----- =======[ TELEPORT TAB ]
    -------------------------------------------
    Teleport:Paragraph({
        Title = "📍 Teleport Features",
        Desc = "Teleport to different locations and manage auto-farming.",
        Locked = true
    })
    
    -------------------------------------------
    -- Island list diambil dari main.lua (posisi Vector3 dikonversi ke CFrame)
    local ISLAND_LIST = {
        ["Esoteric Depths"] = { CFrame.new(3157, -1303, 1439) },
        ["Tropical Grove"] = { CFrame.new(-2038, 3, 3650) },
        ["Stingray Shores"] = { CFrame.new(-32, 4, 2773) },
        ["Kohana Volcano"] = { CFrame.new(-519, 24, 189) },
        ["Coral Reefs"] = { CFrame.new(-3095, 1, 2177) },
        ["Crater Island"] = { CFrame.new(968, 1, 4854) },
        ["Kohana"] = { CFrame.new(-658, 3, 719) },
        ["Winter Fest"] = { CFrame.new(1611, 4, 3280) },
        ["Isoteric Island"] = { CFrame.new(1987, 4, 1400) },
        ["Lost Isle"] = { CFrame.new(-3670.30078125, -113.00000762939, -1128.05895996) },
        ["Lost Isle [Lost Shore]"] = { CFrame.new(-3697, 97, -932) },
        ["Lost Isle [Sisyphus]"] = { CFrame.new(-3719.850830078125, -113.00000762939, -958.6303100585938) },
        ["Lost Isle [Treasure Hall]"] = { CFrame.new(-3652, -298.25, -1469) },
        ["Lost Isle [Treasure Room]"] = { CFrame.new(-3652, -283.5, -1651.5) },
    }
    Teleport:Paragraph({
        Title = "🎣 Teleport Information",
        Desc = "Jika ingin memakai auto farm aktifkan ketika sudah memilih pulau/island.\nUntuk teleport biasa silahkan tekan button teleport saja tanpa auto farm.",
        Locked = true
    })
    local selectedIsland
    Teleport:Dropdown({ Title = "Select Island", Values = (function() local t={} for k,_ in pairs(ISLAND_LIST) do table.insert(t,k) end table.sort(t) return t end)(), Callback = function(name)
        selectedIsland = name
    end })
    Teleport:Button({ Title = "Teleport to Selected", Callback = function()
        if selectedIsland then
            local list = ISLAND_LIST[selectedIsland]
            local pos = list and list[math.random(1, #list)]
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
            if hrp and pos then hrp.CFrame = pos end
        end
    end })
    local autoFarmLoop
    Teleport:Toggle({ Title = "Enable Auto Farm (uses selected island)", Callback = function(v)
        if v then
            if autoFarmLoop then task.cancel(autoFarmLoop) end
            -- Validasi island terpilih
            if not selectedIsland then
                pcall(function() UI:Notify({ Title = "Auto Farm", Content = "Please select an island first!", Duration = 3, Icon = "alert-triangle" }) end)
                state.AutoFarm = false
                return
            end
            
            state.AutoFarm = true
            pcall(function() UI:Notify({ Title = "Auto Farm", Content = "Started auto farming at " .. selectedIsland, Duration = 3, Icon = "map-pin" }) end)
            
            -- Auto farm loop
            autoFarmLoop = task.spawn(function()
                while state.AutoFarm do
                    task.wait(config.autoFarm.islandCheckDelaySeconds)
                    
                    if not state.AutoFarm then break end
                    
                    local char = player.Character
                    if not char then continue end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end
                    
                    local islandList = ISLAND_LIST[selectedIsland]
                    if not islandList then continue end
                    
                    local targetPos = islandList[math.random(1, #islandList)]
                    local currentPos = hrp.Position
                    local distance = (currentPos - targetPos.Position).Magnitude
                    
                    -- Jika terlalu jauh dari island target, teleport
                    if distance > 100 then
                        -- Stop auto fish sebelum teleport
                        if state.AutoFish then
                            stopAutoFish()
                            task.wait(1)
                        end
                        
                        hrp.CFrame = targetPos
                        task.wait(config.autoFarm.teleportDelaySeconds)
                        
                        -- Start auto fish setelah teleport
                        if state.AutoFish then
                            startAutoFish()
                        end
                    end
                end
            end)
        else
            state.AutoFarm = false
            if autoFarmLoop then
                task.cancel(autoFarmLoop)
                autoFarmLoop = nil
            end
            pcall(function() UI:Notify({ Title = "Auto Farm", Content = "Stopped auto farming", Duration = 3, Icon = "map-pin" }) end)
        end
    end })
    
    -- Player list untuk teleport
    local playerList = {}
    local function updatePlayerList()
        playerList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(playerList, p.Name)
            end
        end
        table.sort(playerList)
    end
    
    updatePlayerList()
    
    Teleport:Button({
        Title = "🔄 Refresh Player List",
        Callback = function()
            updatePlayerList()
            pcall(function() UI:Notify({ Title = "Player List", Content = "Refreshed player list", Duration = 2, Icon = "refresh-cw" }) end)
        end
    })
    
    local selectedPlayer
    Teleport:Dropdown({
        Title = "Select Player to Teleport",
        Values = playerList,
        Callback = function(playerName)
            selectedPlayer = playerName
        end
    })
    
    Teleport:Button({
        Title = "Teleport to Player",
        Callback = function()
            if selectedPlayer then
                local targetPlayer = Players:FindFirstChild(selectedPlayer)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                        pcall(function() UI:Notify({ Title = "Teleported", Content = "To " .. selectedPlayer, Duration = 3, Icon = "map-pin" }) end)
                    end
                else
                    pcall(function() UI:Notify({ Title = "Error", Content = "Player not found or not loaded", Duration = 3, Icon = "alert-triangle" }) end)
                end
            else
                pcall(function() UI:Notify({ Title = "Error", Content = "Please select a player first", Duration = 3, Icon = "alert-triangle" }) end)
            end
        end
    })
    
    -- Event teleport
    local eventNames = {"Shark Hunt", "Megalodon", "Kraken", "Leviathan", "Sea Serpent"}
    local eventState = {
        selectedList = {},
        isAtEvent = false,
        originalPosition = nil,
        platform = nil,
        wasAutoFishing = false
    }
    
    Teleport:Dropdown({
        Title = "Select Events to Auto-Teleport",
        Desc = "Choose events you want to automatically teleport to",
        Values = eventNames,
        Multi = true,
        AllowNone = true,
        Callback = function(selectedEvents)
            eventState.selectedList = selectedEvents or {}
        end
    })
    
    Teleport:Toggle({
        Title = "Enable Auto TP to Events",
        Desc = "Automatically teleport to selected events when they spawn",
        Callback = function(value)
            state.AutoTPEvent = value
            if value then
                if #eventState.selectedList == 0 then
                    pcall(function() UI:Notify({ Title = "No Selection", Content = "Please select at least one event first", Duration = 3, Icon = "alert-triangle" }) end)
                    state.AutoTPEvent = false
                    return
                end
                pcall(function() UI:Notify({ Title = "Auto TP Event", Content = "Started monitoring " .. #eventState.selectedList .. " selected events", Duration = 3, Icon = "map-pin" }) end)
            else
                pcall(function() UI:Notify({ Title = "Auto TP Event", Content = "Stopped auto teleporting to events", Duration = 3, Icon = "map-pin" }) end)
            end
        end
    })
    
    -- Event monitoring loop
    task.spawn(function()
        while task.wait(config.tpEvent.pollIntervalSeconds) do
            if not state.AutoTPEvent then continue end
            
            local char = player.Character
            if not char then continue end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            -- Check for active events
            local activeEvent = nil
            for _, eventName in ipairs(eventState.selectedList) do
                -- Simple event detection (bisa diperbaiki sesuai game)
                local eventObj = workspace:FindFirstChild(eventName)
                if eventObj then
                    activeEvent = eventName
                    break
                end
            end
            
            if activeEvent and not eventState.isAtEvent then
                -- Event detected, teleport to it
                eventState.wasAutoFishing = state.AutoFish
                if state.AutoFish then
                    stopAutoFish()
                end
                
                eventState.originalPosition = hrp.CFrame
                
                -- Create platform at event location
                local eventObj = workspace:FindFirstChild(activeEvent)
                if eventObj then
                    local platform = Instance.new("Part")
                    platform.Name = "EventPlatform"
                    platform.Size = Vector3.new(20, 1, 20)
                    platform.Position = eventObj.Position + Vector3.new(0, config.tpEvent.platformHeight, 0)
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.BrickColor = BrickColor.new("Bright blue")
                    platform.Parent = workspace
                    eventState.platform = platform
                    
                    hrp.CFrame = platform.CFrame + Vector3.new(0, 5, 0)
                    eventState.isAtEvent = true
                    
                    pcall(function() UI:Notify({ Title = "Event TP", Content = "Teleported to " .. activeEvent, Duration = 3, Icon = "map-pin" }) end)
                    
                    -- Resume auto fish if it was running
                    if eventState.wasAutoFishing then
                        task.wait(config.tpEvent.resumeDelaySeconds)
                        startAutoFish()
                    end
                end
            elseif not activeEvent and eventState.isAtEvent then
                -- Event ended, return to original position
                if state.AutoFish and not eventState.wasAutoFishing then 
                    -- Hanya hentikan jika sebelumnya tidak memancing
                    stopAutoFish() 
                end
                if eventState.platform then 
                    eventState.platform:Destroy()
                    eventState.platform = nil 
                end
                hrp.CFrame = eventState.originalPosition
                
                pcall(function() UI:Notify({ Title = "Event TP", Content = "Event ended, returned to original position", Duration = 3, Icon = "map-pin" }) end)
                
                if eventState.wasAutoFishing then
                    task.wait(config.tpEvent.resumeDelaySeconds)
                    startAutoFish()
                end
                eventState.isAtEvent = false
            end
        end
    end)
    
    -------------------------------------------
    ----- =======[ SETTINGS & MISC ]
    -------------------------------------------
    SettingsMisc:Paragraph({ Title = "Settings", Desc = "Misc options & info.", Locked = true })
    -- Low Graphics toggle
    local function applyLowGraphics(on)
        if on then
            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end
    end
    SettingsMisc:Toggle({ Title = "Low Graphics", Callback = function(v)
        state.LowGraphics = v; applyLowGraphics(v)
    end })
    -- FPS Unlocker (select preset)
    local function setFpsCap(n)
        if typeof(setfpscap) == "function" then setfpscap(n) elseif typeof(setsynmaxfps) == "function" then setsynmaxfps(n) end
    end
    SettingsMisc:Dropdown({ Title = "FPS Cap", Values = {"60","90","120","Max"}, Callback = function(choice)
        local map = { ["60"] = 60, ["90"] = 90, ["120"] = 120, ["Max"] = 0 }
        local cap = map[choice] or 0
        state.FPSCap = cap
        setFpsCap(cap)
    end })
    -- Rejoin server
    SettingsMisc:Button({ Title = "Rejoin Server", Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end })
    -- Server Hop (cari server publik dengan slot kosong)
    SettingsMisc:Button({ Title = "Server Hop (Public)", Callback = function()
        local placeId = game.PlaceId; local servers, cursor = {}, ""
        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
            local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
            if success and result and result.data then
                for _, server in pairs(result.data) do if server.playing < server.maxPlayers and server.id ~= game.JobId then table.insert(servers, server.id) end end
                cursor = result.nextPageCursor or ""
            else break end
        until not cursor or #servers > 0
        if #servers > 0 then TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player) end
    end })
    -- Auto Rejoin on disconnect (sederhana: loop cek flag)
    SettingsMisc:Toggle({ Title = "Auto Rejoin on Disconnect", Callback = function(v)
        state.AutoRejoin = v
    end })
    task.spawn(function()
        while true do
            task.wait(2)
            if state.AutoRejoin and not game:IsLoaded() then
                pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
            end
        end
    end)

     -- Anti AFK (auto-enabled)
     local antiAfkConn
     local function startAntiAfk()
         if antiAfkConn then return end
         local vu = game:FindService("VirtualUser") or game:GetService("VirtualUser")
         antiAfkConn = player.Idled:Connect(function()
             pcall(function()
                 vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
                 task.wait(0.5)
                 vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
             end)
         end)
         pcall(function() UI:Notify({ Title = "Anti AFK", Content = "Enabled", Duration = 2, Icon = "activity" }) end)
     end
     local function stopAntiAfk()
         if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
         pcall(function() UI:Notify({ Title = "Anti AFK", Content = "Disabled", Duration = 2, Icon = "activity" }) end)
     end
     -- Auto start on load
     task.spawn(function()
         task.wait(2)
         startAntiAfk()
     end)

    -------------------------------------------
    ----- =======[ WEBHOOK TAB ]
    -------------------------------------------
    Webhook:Paragraph({
        Title = "🔗 Discord Webhook",
        Desc = "Get notified when you catch rare fish!",
        Locked = true
    })
    
    local webhookState = {
        url = "",
        enabled = false,
        selectedRarities = {},
        compactEmbed = false
    }
    
    -- Validate webhook URL
    local function validateWebhook(url)
        if not url or url == "" then return false end
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url:find("^https://discord%.com/api/webhooks/") then
            return url
        elseif url:find("^%d+/") then
            return "https://discord.com/api/webhooks/" .. url
        end
        return false
    end
    
    -- Webhook URL input
    Webhook:Input({
        Title = "Discord Webhook URL",
        Placeholder = "https://discord.com/api/webhooks/... or ID/TOKEN",
        Callback = function(text)
            local validUrl = validateWebhook(text)
            if validUrl then
                webhookState.url = validUrl
                pcall(function() UI:Notify({ Title = "Webhook", Content = "URL validated successfully", Duration = 2, Icon = "circle-check" }) end)
            else
                pcall(function() UI:Notify({ Title = "Webhook", Content = "Invalid webhook URL format", Duration = 3, Icon = "alert-triangle" }) end)
            end
        end
    })
    
    -- Fish rarity selection
    local rarityNames = {"Epic", "Legendary", "Mythic", "Secret"}
    Webhook:Dropdown({
        Title = "Select Fish Rarities to Notify",
        Desc = "Choose which fish rarities should trigger webhook notifications",
        Values = rarityNames,
        Multi = true,
        AllowNone = true,
        Callback = function(selectedRarities)
            webhookState.selectedRarities = selectedRarities or {}
        end
    })
    
    -- Compact embed toggle
    Webhook:Toggle({
        Title = "Compact Embed",
        Desc = "Use compact embed format for notifications",
        Callback = function(value)
            webhookState.compactEmbed = value
        end
    })
    
    -- Enable webhook toggle
    Webhook:Toggle({
        Title = "Enable Webhook Notifications",
        Desc = "Send Discord notifications for caught fish",
        Callback = function(value)
            webhookState.enabled = value
            if value then
                if webhookState.url == "" then
                    pcall(function() UI:Notify({ Title = "Webhook", Content = "Please enter a webhook URL first", Duration = 3, Icon = "alert-triangle" }) end)
                    webhookState.enabled = false
                    return
                end
                if #webhookState.selectedRarities == 0 then
                    pcall(function() UI:Notify({ Title = "Webhook", Content = "Please select at least one fish rarity", Duration = 3, Icon = "alert-triangle" }) end)
                    webhookState.enabled = false
                    return
                end
                pcall(function() UI:Notify({ Title = "Webhook", Content = "Webhook notifications enabled", Duration = 3, Icon = "message-circle" }) end)
            else
                pcall(function() UI:Notify({ Title = "Webhook", Content = "Webhook notifications disabled", Duration = 3, Icon = "message-circle" }) end)
            end
        end
    })
    
    -- Test webhook button
    Webhook:Button({
        Title = "Test Webhook",
        Callback = function()
            if webhookState.url == "" then
                pcall(function() UI:Notify({ Title = "Webhook", Content = "Please enter a webhook URL first", Duration = 3, Icon = "alert-triangle" }) end)
                return
            end
            
            local testData = {
                username = "DZv1 Fish It Script",
                avatar_url = "https://cdn.discordapp.com/emojis/1234567890123456789.png",
                content = "🎣 **Test Notification**",
                embeds = {{
                    title = "Test Webhook",
                    description = "This is a test notification from DZv1 Fish It Script",
                    color = 3447003,
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    fields = {
                        {
                            name = "Status",
                            value = "✅ Working correctly",
                            inline = true
                        },
                        {
                            name = "Script",
                            value = "DZv1.lua",
                            inline = true
                        }
                    }
                }}
            }
            
            if webhookState.compactEmbed then
                testData.embeds = {{
                    title = "🎣 Test Notification",
                    description = "DZv1 Fish It Script is working correctly!",
                    color = 3447003
                }}
            end
            
            local success, result = pcall(function()
                return HttpService:PostAsync(webhookState.url, HttpService:JSONEncode(testData), Enum.HttpContentType.ApplicationJson)
            end)
            
            if success then
                pcall(function() UI:Notify({ Title = "Webhook", Content = "Test notification sent successfully!", Duration = 3, Icon = "circle-check" }) end)
            else
                pcall(function() UI:Notify({ Title = "Webhook", Content = "Failed to send test notification: " .. tostring(result), Duration = 5, Icon = "alert-triangle" }) end)
            end
        end
    })
    
    return Window, UI
end

-- Auto Fish Functions
local function startAutoFish()
    if _G.autoFishLoop then return end
    
    local netFolder = getNetFolder()
    if not netFolder then
        pcall(function() UI:Notify({ Title = "Auto Fish", Content = "Network folder not found", Duration = 3, Icon = "alert-triangle" }) end)
        return
    end
    
    local equipTool = netFolder:FindFirstChild("RE/EquipToolFromHotbar")
    local chargeRod = netFolder:FindFirstChild("RF/ChargeFishingRod")
    local requestMinigame = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
    local fishingCompleted = netFolder:FindFirstChild("RE/FishingCompleted")
    
    if not equipTool or not chargeRod or not requestMinigame or not fishingCompleted then
        pcall(function() UI:Notify({ Title = "Auto Fish", Content = "Required remotes not found", Duration = 3, Icon = "alert-triangle" }) end)
        return
    end
    
    local isCasting = false
    local gracefulStop = false
    
    _G.autoFishLoop = task.spawn(function()
        while state.AutoFish do
            if gracefulStop then
                -- Wait for current fishing cycle to complete
                if isCasting then
                    task.wait(0.5)
                    continue
                else
                    break
                end
            end
            
            local char = player.Character
            if not char then
                task.wait(1)
                continue
            end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then
                task.wait(1)
                continue
            end
            
            -- Check if we have a fishing rod
            local fishingRod = char:FindFirstChild("FishingRod")
            if not fishingRod then
                -- Try to equip fishing rod
                pcall(function()
                    equipTool:FireServer("FishingRod")
                end)
                task.wait(1)
                continue
            end
            
            -- Start fishing
            isCasting = true
            pcall(function()
                chargeRod:InvokeServer()
            end)
            
            task.wait(config.autoFish.castDelaySeconds)
            
            -- Request minigame
            pcall(function()
                requestMinigame:InvokeServer()
            end)
            
            task.wait(config.autoFish.catchDelaySeconds)
            
            -- Complete fishing
            pcall(function()
                fishingCompleted:FireServer()
            end)
            
            isCasting = false
            
            -- Check if we should stop after catch
            if state.StopAfterCatch then
                gracefulStop = true
                state.AutoFish = false
                pcall(function() UI:Notify({ Title = "Auto Fish", Content = "Stopping after catch...", Duration = 2, Icon = "fish" }) end)
            end
            
            task.wait(config.autoFish.cooldownDelaySeconds)
        end
        
        _G.autoFishLoop = nil
    end)
end

local function stopAutoFish()
    if _G.autoFishLoop then
        task.cancel(_G.autoFishLoop)
        _G.autoFishLoop = nil
    end
end

-- Auto Sell Functions
local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            task.wait(config.autoSell.thresholdDelaySeconds)
            
            local netFolder = getNetFolder()
            if netFolder then
                local sellFunc = netFolder:FindFirstChild("RF/SellAllItems")
                if sellFunc then
                    sellFunc:InvokeServer()
                    pcall(function() UI:Notify({ Title = "Auto Sell", Content = "Sold all items!", Duration = 2, Icon = "circle-check" }) end)
                end
            end
        end
    end)
end

-- Player Control Functions
local function startInfiniteJump()
    task.spawn(function()
        while state.InfiniteJump do
            task.wait()
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                pcall(function()
                    player.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    end)
end

local function stopInfiniteJump()
    -- Function to stop infinite jump (if needed)
end

local function startInfiniteOxygen()
    task.spawn(function()
        while state.InfiniteOxygen do
            task.wait(1)
            local char = player.Character
            if char then
                local oxygen = char:FindFirstChild("Oxygen")
                if oxygen then
                    if oxygen:IsA("NumberValue") then
                        oxygen.Value = 100
                    else
                        oxygen:Destroy()
                    end
                end
            end
        end
    end)
    
    -- Handle respawn
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        local oxygen = char:FindFirstChild("Oxygen")
        if oxygen then
            if oxygen:IsA("NumberValue") then
                oxygen.Value = 100
            else
                oxygen:Destroy()
            end
        end
    end)
end

local function stopInfiniteOxygen()
    -- Function to stop infinite oxygen (if needed)
end

-- Initialize script
local Window, UI = buildWindow()

-- Welcome notification
pcall(function() UI:Notify({ Title = "DZv1 Script", Content = "Welcome! Script loaded successfully.", Duration = 3, Icon = "circle-check" }) end)

-- WalkSpeed guardian loop
task.spawn(function()
    while true do
        task.wait(1)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            if char.Humanoid.WalkSpeed ~= state.WalkSpeed then
                char.Humanoid.WalkSpeed = state.WalkSpeed
            end
        end
    end
end)
end)
