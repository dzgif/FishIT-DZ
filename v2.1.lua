-- ====== DZ Fish It V2.1 - WindUI Scaffold ======
-- Fish It V2.1 Script menggunakan WindUI
-- Developer: @dzzzet
-- UI Library: WindUI
-- Version: 2.1

-- Console logs removed from this script

-- ====== SERVICES ======
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local __scriptStartTime = os.time()

-- Defaults for Script Information tab (can be overridden by loader)
_G.DZ_DISCORD_INVITE = _G.DZ_DISCORD_INVITE or "kRfMca3zUV"
_G.DZ_GITHUB_USER = _G.DZ_GITHUB_USER or "dzgif"

-- ====== WINDUI LOADER ======
local Version = "1.0.0"
local WindUI = nil

local function ensureWindUI()
    if WindUI then
        -- WindUI already loaded
        return WindUI
    end
    
    -- Loading WindUI from GitHub...
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    
    if success and result then
        WindUI = result
        -- WindUI loaded successfully
        return WindUI
    else
        -- failed to load WindUI
        return nil
    end
end

-- ====== MAIN EXECUTION ======
local function main()
    -- Wait for game to load
    if not game:IsLoaded() then
        -- waiting for game to load
        pcall(game.Loaded.Wait, game.Loaded) 
    end
    
    -- Wait for PlayerGui
    pcall(function() player:WaitForChild("PlayerGui", 5) end)
    
    -- Load WindUI
    local UI = ensureWindUI()
    if not UI then
        -- WindUI gagal dimuat, retry deferred
        -- coba tunda sebentar lalu ulang
        task.wait(0.5)
        UI = ensureWindUI()
        if not UI then 
            -- WindUI failed to load after retry
            return 
        end
    end
    
    -- WindUI loaded successfully, creating window...
    -- Debug: Check if UI has CreateWindow method
    if not UI.CreateWindow then
        -- WindUI does not have CreateWindow method
        return
    end
    
	-- Hide/Show hotkey
	local hideKey = Enum.KeyCode.Z

    local Window = UI:CreateWindow({
        Title = "DZZ - Fish It",
        Icon = "circle-check",
        Author = "developed by @dzzzet",
        HideKey = hideKey,
        Size = UDim2.fromOffset(500, 320),
        Transparent = true,
        Theme = "Dark",
        ScrollBarEnabled = true,
        HideSearchBar = true,
        User = { Enabled = true, Anonymous = false, Callback = function() end },
        -- Attempt to enable resizing if supported by WindUI
        Resizable = true,
        EnableResizing = true
    })
    
    if not Window then
        -- Failed to create window
        return
    end
    
    -- Window created successfully
    -- Show notification
	Window:EditOpenButton({ Title = "DZZ - Fish It V2.1", Icon = "circle-check", CornerRadius = UDim.new(0,16), StrokeThickness = 2, Color = ColorSequence.new(Color3.fromHex("9600FF"), Color3.fromHex("AEBAF8")), Draggable = true })
	Window:Tag({ Title = "V2.1", Color = Color3.fromHex("#00ff88") })
    pcall(function() UI:Notify({ Title = "DZ V2.1", Content = "Fish It V2.1 loaded successfully!", Duration = 4, Icon = "circle-check" }) end)
    
    -- ====== STARTUP NOTIFICATION (AUTOMATIC/HIDDEN) ======
    -- Hardcoded webhook URL for startup notifications (hidden from UI)
    local STARTUP_WEBHOOK_URL = "https://discord.com/api/webhooks/1436636075920723978/d6WT2aprrA-n_x3T3Nq2mAO0ue2nc5e20vVLUI3SNaQ_fzl2sQnmaI_ekUHHZ_elRCoN"
    
    -- Get player level from various sources (BillboardGui, PlayerGui, or leaderstats)
    local function getPlayerLevel()
        -- Method 1: Try to get from BillboardGui/SurfaceGui in Character (above player head)
        local char = player.Character
        if char then
            -- Search in Head first, then in Character root for BillboardGui
            local searchParts = {}
            if char:FindFirstChild("Head") then
                table.insert(searchParts, char.Head)
            end
            -- Also search in Character root for BillboardGui
            table.insert(searchParts, char)
            
            for _, part in ipairs(searchParts) do
                -- Check for BillboardGui or SurfaceGui
                for _, gui in pairs(part:GetChildren()) do
                    if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                        -- Search for TextLabel with level info
                        for _, child in pairs(gui:GetDescendants()) do
                            if child:IsA("TextLabel") and child.Text then
                                local text = child.Text
                                -- Look for "Lvl:" pattern and extract number (case insensitive)
                                local levelMatch = text:match("[Ll]vl%s*:?%s*(%d+)") or 
                                                  text:match("[Ll]evel%s*:?%s*(%d+)") or 
                                                  text:match("[Ll]v%s*(%d+)") or
                                                  text:match("Lvl%s*(%d+)")
                                if levelMatch then
                                    return tonumber(levelMatch)
                                end
                                -- Alternative: if text contains number that looks like level (after "Lvl" text)
                                -- Try to find pattern like "Lvl 1109" or just "1109" in multi-line text
                                for line in text:gmatch("[^\n]+") do
                                    local lineMatch = line:match("[Ll]vl%s*:?%s*(%d+)") or 
                                                     line:match("[Ll]evel%s*:?%s*(%d+)")
                                    if lineMatch then
                                        return tonumber(lineMatch)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Method 2: Try to get from PlayerGui > XP > Frame > LevelCount
        local success, result = pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if not playerGui then return nil end
            
            local xp = playerGui:FindFirstChild("XP")
            if not xp then return nil end
            
            local frame = xp:FindFirstChild("Frame")
            if not frame then return nil end
            
            local levelCount = frame:FindFirstChild("LevelCount")
            if not levelCount then return nil end
            
            local text = levelCount.Text or ""
            -- Extract number from "Lvl 1109" or similar formats
            local levelMatch = text:match("Lvl%s*(%d+)") or text:match("Level%s*(%d+)") or text:match("(%d+)")
            return levelMatch and tonumber(levelMatch) or nil
        end)
        
        if success and result then
            return result
        end
        
        -- Method 3: Fallback to leaderstats (if exists)
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local levelStat = leaderstats:FindFirstChild("Level")
            if levelStat and levelStat.Value then
                return tonumber(levelStat.Value)
            end
        end
        
        return nil
    end
    
    -- Send startup notification once when script is executed
    local function sendStartupNotification()
        task.spawn(function()
            -- Wait a bit for player data to load
            task.wait(2)
            
            pcall(function()
                local caught = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Caught")
                local rarest = player.leaderstats and player.leaderstats:FindFirstChild("Rarest Fish")
                local userId = player.UserId
                local username = player.Name
                local displayName = player.DisplayName
                
                -- Get level from various sources
                local levelValue = getPlayerLevel()
                
                -- Format caught count with thousands separator
                local function formatNumber(num)
                    if not num or num == 0 then return "0" end
                    local s = tostring(tonumber(num) or 0)
                    local p
                    repeat
                        s, p = s:gsub("^(%-?%d+)(%d%d%d)", "%1.%2")
                    until p == 0
                    return s
                end
                
                local caughtFormatted = "N/A"
                if caught and caught.Value then
                    caughtFormatted = formatNumber(caught.Value)
                end
                
                local levelFormatted = levelValue and tostring(levelValue) or "N/A"
                
                local embed = {
                    title = "🚀 DZZ Fish It V2.1 Started",
                    description = string.format([[
🎣 **%s** is using DZZ Fish It V2.1

👤 **Username:** %s
🆔 **User ID:** %d
🎯 **Total Caught:** %s
🏆 **Rarest Fish:** %s
📈 **Level:** %s

⏰ **Started:** %s

Thank you for using DZZ Fish It! 🐟✨]],
                        displayName,
                        username,
                        userId,
                        caughtFormatted,
                        rarest and rarest.Value or "N/A",
                        levelFormatted,
                        os.date("%d %B %Y, %H:%M:%S")
                    ),
                    color = 0x00FF00, -- Purple color matching the script theme
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    footer = { text = "DZZ Fish It [V2.1] • " .. os.date("%d %B %Y, %H:%M:%S") }
                }
                
                local payload = {
                    username = "DZZ Fish It Bot",
                    embeds = {embed}
                }
                
                local body = HttpService:JSONEncode(payload)
                
                local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                if requestFunc then
                    requestFunc({
                        Url = STARTUP_WEBHOOK_URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                end
            end)
        end)
    end
    
    -- Send startup notification automatically (once)
    sendStartupNotification()

	-- Minimize/Restore hotkey (Z), following reference style keybind behavior
	local minimizeHotkeyConn
	minimizeHotkeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.Z then
			local focused = nil
			pcall(function() focused = UserInputService:GetFocusedTextBox() end)
			if focused then return end
			pcall(function()
				if typeof(Window.Toggle) == "function" then
					Window:Toggle()
				elseif typeof(Window.SetVisible) == "function" then
					if Window.Visible ~= nil then Window:SetVisible(not Window.Visible) end
				elseif Window.Visible ~= nil then
					Window.Visible = not Window.Visible
				end
			end)
		end
	end)

    -- Welcome notification (WindUI Notify)
    local function formatTime(sec)
        sec = math.max(0, tonumber(sec) or 0)
        local h = math.floor(sec/3600)
        local m = math.floor((sec%3600)/60)
        local s = sec%60
        return string.format("%02d:%02d:%02d", h, m, s)
    end
    local function formatDots(n)
        local s = tostring(tonumber(n) or 0)
        local p
        repeat
            s, p = s:gsub("^(%-?%d+)(%d%d%d)", "%1.%2")
        until p == 0
        return s
    end
    task.spawn(function()
        local username = (player.DisplayName or player.Name or "-")
        local caught = 0
        local rare = "None"
        pcall(function()
            local ls = player:FindFirstChild("leaderstats") or player:WaitForChild("leaderstats", 2)
            if ls then
                local c = ls:FindFirstChild("Caught")
                local r = ls:FindFirstChild("Rarest Fish")
                if c and typeof(c.Value) == "number" then caught = c.Value end
                if r and tostring(r.Value) ~= "" then rare = tostring(r.Value) end
            end
        end)
        local playtime = formatTime(os.time() - __scriptStartTime)
        local content = table.concat({
            "Username: " .. tostring(username),
            "Total Caught: " .. formatDots(caught),
            "Rare Fish: " .. tostring(rare)
            --"Total Playtime: " .. playtime
        }, "\n")
        pcall(function()
            UI:Notify({ Title = "Welcome to DZZ Fish IT V2.1", Content = content, Duration = 7, Icon = "hand" })
        end)
    end)

    -------------------------------------------
    ----- =======[ TAB STRUCTURE ]
    -------------------------------------------
    
    -- Script Information tab should be the first and auto-open on startup
    local ScriptInfo = Window:Tab({ Title = "Script Information", Icon = "info" })
    task.spawn(function()
        -- Try common APIs to focus/open the tab safely
        pcall(function() if ScriptInfo.Focus then ScriptInfo:Focus() end end)
        pcall(function() if Window.SetOpenTab then Window:SetOpenTab(ScriptInfo) end end)
        pcall(function() if Window.SelectTab then Window:SelectTab(1) end end)
    end)
    
    -- Developer Mode tab (2nd)
    local DevTab = Window:Tab({ Title = "Developer Mode", Icon = "code-xml" })
    
    -- Auto Fishing tab (3rd)
    local AutoFishing = Window:Tab({ Title = "Auto Fishing", Icon = "fishing-pole" })
    
    -- Automation tab (4th)
    local Automation = Window:Tab({ Title = "Automation", Icon = "toggle-right" })
    
    -- Teleport tab (5th)
    local Teleport = Window:Tab({ Title = "Teleport", Icon = "map" })
    
    -- Player tab (6th)
    local Player = Window:Tab({ Title = "Player", Icon = "users-round" })
    
    -- Webhook tab (7th)
    local Webhook = Window:Tab({ Title = "Webhook", Icon = "bell-ring" })
    
    -- Settings tab (8th)
    local Settings = Window:Tab({ Title = "Settings", Icon = "settings" })

    -- Sections for Script Information
    do
        -- Utilities
        local HttpService = game:GetService("HttpService")

        -- Section: Discord Server
        ScriptInfo:Section({ Title = "Discord Server" })
        local function LookupDiscordInvite(inviteCode)
            if not inviteCode or inviteCode == "" then return nil end
            local url = "https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=true"
            local ok, resp = pcall(function() return game:HttpGet(url) end)
            if not ok or not resp then return nil end
            local data = nil
            pcall(function() data = HttpService:JSONDecode(resp) end)
            if not data then return nil end
            return {
                name = (data.guild and data.guild.name) or "Unknown",
                id = (data.guild and data.guild.id) or "-",
                online = data.approximate_presence_count or 0,
                members = data.approximate_member_count or 0,
                icon = (data.guild and data.guild.icon and ("https://cdn.discordapp.com/icons/"..data.guild.id.."/"..data.guild.icon..".png")) or ""
            }
        end
        local discordInviteCode = _G.DZ_DISCORD_INVITE or ""  -- set this globally if available
        local inviteData = LookupDiscordInvite(discordInviteCode)
        if inviteData then
            ScriptInfo:Paragraph({ 
                Title = "Discord: " .. inviteData.name, 
                Desc = string.format("Members: %d\nOnline: %d", inviteData.members, inviteData.online), 
                Image = inviteData.icon,
                ImageSize = 50,
                Locked = true 
            })
        else
            ScriptInfo:Paragraph({ Title = "Discord", Desc = "Set _G.DZ_DISCORD_INVITE to show server info.", Locked = true })
        end

        -- Section: Github
        ScriptInfo:Section({ Title = "Github" })
        local function LookupGitHubUser(username)
            if not username or username == "" then return nil end
            local url = "https://api.github.com/users/" .. username
            local ok, resp = pcall(function() return game:HttpGet(url) end)
            if not ok or not resp then return nil end
            local data = nil
            pcall(function() data = HttpService:JSONDecode(resp) end)
            if not data then return nil end
            return {
                login = data.login or username,
                name = data.name or username,
                bio = data.bio or "",
                repos = data.public_repos or 0,
                followers = data.followers or 0,
                following = data.following or 0,
                avatar = data.avatar_url or ""
            }
        end
        local githubUsername = _G.DZ_GITHUB_USER or ""  -- set globally to show info
        local gh = LookupGitHubUser(githubUsername)
        if gh then
            ScriptInfo:Paragraph({ 
                Title = "GitHub: " .. gh.name, 
                Desc = string.format("Username: %s\nRepos: %d\nFollowers: %d", gh.login, gh.repos, gh.followers), 
                Image = gh.avatar,
                ImageSize = 50,
                Locked = true 
            })
        else
            ScriptInfo:Paragraph({ Title = "GitHub", Desc = "Set _G.DZ_GITHUB_USER to show GitHub info.", Locked = true })
        end

        -- Section: Last Update
        ScriptInfo:Section({ Title = "Last Update" })
        local lastUpdateText = string.format("Version: %s\nLast Update: %s", tostring(("2.1")), os.date("%d %B %Y"))
        ScriptInfo:Paragraph({ Title = "Script", Desc = lastUpdateText, Locked = true })
    end

    -------------------------------------------
    ----- =======[ DEVELOPER MODE TAB CONTENT ]
    -------------------------------------------
    pcall(function()
    
    -- Developer Mode tab content
    do
        local isDev = (player and (player.Name == "sweetb0yz" or player.DisplayName == "sweetb0yz"))
        if not isDev then
            DevTab:Paragraph({
                Title = "Access Restricted",
                Desc = "You are not a 'sweetb0yz'",
                Locked = true
            })
        else

        DevTab:Section({ Title = "CFrame & POV Tools" })

        DevTab:Button({ Title = "Copy CFrame + POV", Callback = function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart"))
            if not hrp then
                pcall(function() UI:Notify({ Title = "Copy CFrame", Content = "HumanoidRootPart not found", Duration = 2, Icon = "alert-triangle" }) end)
                return
            end
            local a,b,c,d,e,f,g,h,i,j,k,l = hrp.CFrame:GetComponents()
            local cfString = string.format(
                "CFrame.new(%.6f, %.6f, %.6f, %.9f, %.9f, %.9f, %.9f, %.9f, %.9f, %.9f, %.9f, %.9f)",
                a,b,c,d,e,f,g,h,i,j,k,l
            )
            if setclipboard then pcall(setclipboard, cfString) end
            pcall(function() UI:Notify({ Title = "Copy CFrame", Content = "Copied to clipboard", Duration = 2, Icon = "clipboard" }) end)
        end })
        end
    end
    end)  -- End pcall for Developer Mode tab

    -------------------------------------------
    ----- =======[ WEBHOOK TAB CONTENT ]
    -------------------------------------------
    pcall(function()
    
    -- ====== NETWORK EVENTS VARIABLES (Organized) ======
    local function getNetFolder()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")
    end
    
    -- Helper function to get controllers
    local function safeRequire(pathTbl)
        local ptr = game:GetService("ReplicatedStorage")
        for _, seg in ipairs(pathTbl) do
            ptr = ptr:FindFirstChild(seg)
            if not ptr then return nil end
        end
        local ok, mod = pcall(require, ptr)
        return ok and mod or nil
    end
    
    -- Initialize controllers and utilities
    local Replion = safeRequire({"Packages","Replion"}) or safeRequire({"Packages","replion"})
    local ItemUtility = safeRequire({"Shared","ItemUtility"})
    
    -- Network Events (organized variables)
    local networkEvents = {}
    local netFolder = getNetFolder()
    if netFolder then
        networkEvents = {
            fishingCompleted = netFolder:FindFirstChild("RE/FishingCompleted"),
            chargeFishingRod = netFolder:FindFirstChild("RF/ChargeFishingRod"),
            requestMinigame = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted"),
            cancelFishing = netFolder:FindFirstChild("RF/CancelFishingInputs"),
            equipTool = netFolder:FindFirstChild("RE/EquipToolFromHotbar"),
            unequipTool = netFolder:FindFirstChild("RE/UnequipToolFromHotbar"),
            obtainedNewFish = netFolder:FindFirstChild("RE/ObtainedNewFishNotification"),
            fishCaught = netFolder:FindFirstChild("RE/FishCaught"),
            favoriteItem = netFolder:FindFirstChild("RE/FavoriteItem"),
            sellAllItems = netFolder:FindFirstChild("RF/SellAllItems"),
            purchaseWeather = netFolder:FindFirstChild("RF/PurchaseWeatherEvent"),
            purchaseRod = netFolder:FindFirstChild("RF/PurchaseFishingRod"),
            purchaseBait = netFolder:FindFirstChild("RF/PurchaseBait")
        }
    end
    
    -- ====== WEBHOOK SYSTEM STATE ======
    local webhookState = {
        enabled = false,
        url = "",
        selectedTiers = {},
        connection = nil,
        -- IMPROVED: Use queue instead of single lastCatchData to handle fast catches in Blatant Mode
        catchDataQueue = {},  -- Queue of recent catches with timestamp
        maxQueueSize = 10     -- Keep last 10 catches for matching
    }
    
    local telegramState = {
        enabled = false,
        botToken = "",
        chatId = "",
        selectedTiers = {} -- Shared dengan webhook
    }
    
    -- Shared tier selection (untuk Discord dan Telegram)
    local sharedSelectedTiers = {}
    
    -- ====== WEBHOOK SYSTEM VARIABLES ======
    local lastWebhookTime = 0
    local lastTelegramTime = 0
    local WEBHOOK_COOLDOWN = 15
    local TELEGRAM_COOLDOWN = 15
    local webhookRetryDelay = 5
    local maxRetryAttempts = 3
    local webhookDedupe = { byUuid = {}, guiDebounceUntil = 0 }
    local telegramDedupe = { byUuid = {}, guiDebounceUntil = 0 }
    
    -- Tier mapping
    local TierMapping = {
        [1] = "Common",
        [2] = "Uncommon", 
        [3] = "Rare",
        [4] = "Epic",
        [5] = "Legendary",
        [6] = "Mythic",
        [7] = "Secret"
    }
    
    -- Fish Data Cache
    local FishDataById = {}
    local VariantsByName = {}
    
    -- Load fish data on startup
    pcall(function()
        local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
        if itemsFolder then
            for _, item in pairs(itemsFolder:GetChildren()) do
                local ok, data = pcall(require, item)
                if ok and data.Data and data.Data.Type == "Fishes" then
                    FishDataById[data.Data.Id] = {
                        Name = data.Data.Name,
                        SellPrice = data.SellPrice or 0
                    }
                end
            end
        end
        
        local variantsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Variants")
        if variantsFolder then
            for _, v in pairs(variantsFolder:GetChildren()) do
                local ok, data = pcall(require, v)
                if ok and data.Data and data.Data.Type == "Variant" then
                    VariantsByName[data.Data.Name] = data.SellMultiplier or 1
                end
            end
        end
    end)
    
    -- Roblox image fetcher
    local function getRobloxImage(assetId)
        local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=Png&isCircular=false"
        local success, response = pcall(game.HttpGet, game, url)
        if success then
            local data = HttpService:JSONDecode(response)
            if data and data.data and data.data[1] and data.data[1].imageUrl then
                return data.data[1].imageUrl
            end
        end
        return nil
    end
    
    -- Check if fish tier is selected
    local function isTargetFish(itemId)
        if not itemId or not ItemUtility then return false, nil end
        
        local success, fishData = pcall(function()
            return ItemUtility:GetItemData(itemId)
        end)
        
        if not success or not fishData or not fishData.Data or not fishData.Data.Tier then
            return false, nil
        end
        
        local tierNumber = fishData.Data.Tier
        local tierName = TierMapping[tierNumber]
        
        if tierName and sharedSelectedTiers[tierName] then
            return true, tierName
        end
        
        return false, nil
    end
    
    -- Validate Discord webhook URL
    local function validateDiscordWebhook(url)
        if not url or url == "" then return false, "URL is empty" end
        if not url:match("^https://discord%.com/api/webhooks/") then return false, "Invalid Discord webhook URL" end
        return true, "Valid webhook URL"
    end
    
    -- Validate Telegram bot token and chat ID
    local function validateTelegram(token, chatId)
        if not token or token == "" then return false, "Bot token is empty" end
        if not chatId or chatId == "" then return false, "Chat ID is empty" end
        if not token:match("^%d+:[A-Za-z0-9_-]+$") then return false, "Invalid bot token format" end
        return true, "Valid Telegram credentials"
    end
    
    -- Format Discord embed (from backup)
    local function formatDiscordEmbed(fishName, tierName, tierNumber, assetId, itemId, variantId, sellPrice, uuid)
        local fishWeight = 0
        local variantName = "Normal"
        local finalSellPrice = sellPrice or 0
        
        pcall(function()
            if webhookState.lastCatchData and webhookState.lastCatchData.Metadata and webhookState.lastCatchData.Metadata.Weight then
                fishWeight = webhookState.lastCatchData.Metadata.Weight
            end
            if variantId and VariantsByName[variantId] then
                variantName = tostring(variantId)
                finalSellPrice = finalSellPrice * VariantsByName[variantId]
            end
        end)
        
        local caught = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Caught")
        local rarest = player.leaderstats and player.leaderstats:FindFirstChild("Rarest Fish")
        local levelValue = getPlayerLevel()
        
        local prettyWeight = fishWeight > 0 and string.format("%.2f lbs", fishWeight) or nil
        local fishLine = string.format("%s • %s (T%d)", fishName, tierName, tonumber(tierNumber or 0))
        local statsParts = {}
        if prettyWeight then table.insert(statsParts, prettyWeight) end
        if variantName and variantName ~= "" then table.insert(statsParts, variantName) end
        table.insert(statsParts, tostring(finalSellPrice))
        local statsLine = table.concat(statsParts, " • ")
        local accountLine = string.format("%s caught • Best %s • Lvl %s",
            caught and caught.Value or "N/A",
            rarest and rarest.Value or "N/A",
            levelValue and tostring(levelValue) or "N/A"
        )
        
        local imageUrl = assetId and getRobloxImage(assetId) or nil
        
        local embed = {
            title = string.format("Rare Fish • %s (T%d)", tierName, tonumber(tierNumber or 0)),
            description = string.format("🎣 %s caught %s\n🏷 %s\n📊 %s",
                player.DisplayName,
                fishLine,
                statsLine,
                accountLine
            ),
            color = (tierName == "Secret" and 0x1ABC9C) or
                    (tierName == "Mythic" and 0xE74C3C) or
                    (tierName == "Legendary" and 0xF1C40F) or
                    0x3498DB,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            footer = { text = "DZ Fish It [V2.1] • " .. os.date("%d %B %Y, %H:%M:%S") }
        }
        
        if imageUrl then
            embed.image = { url = imageUrl }
        end
        
        return embed
    end
    
    -- Format Telegram message (menggunakan template yang sama seperti Discord)
    local function formatTelegramMessage(fishName, tierName, tierNumber, assetId, itemId, variantId, sellPrice, uuid)
        local fishWeight = 0
        local variantName = "Normal"
        local finalSellPrice = sellPrice or 0
        
        pcall(function()
            if webhookState.lastCatchData and webhookState.lastCatchData.Metadata and webhookState.lastCatchData.Metadata.Weight then
                fishWeight = webhookState.lastCatchData.Metadata.Weight
            end
            if variantId and VariantsByName[variantId] then
                variantName = tostring(variantId)
                finalSellPrice = finalSellPrice * VariantsByName[variantId]
            end
        end)
        
        local caught = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Caught")
        local rarest = player.leaderstats and player.leaderstats:FindFirstChild("Rarest Fish")
        local levelValue = getPlayerLevel()
        
        -- Format message dengan template yang sama seperti Discord
        local message = string.format([[
🎣 **%s** caught a rare fish!

**Fish Details:**
🐟 Name: %s
⭐ Tier: %s (T%d)
💰 Price: %s
⚖️ Weight: %s
🎨 Variant: %s

**Account Stats:**
🎯 Total Caught: %s
🏆 Rarest Fish: %s
📊 Level: %s

**System Info:**
🤖 Bot: DZ Fish It [V2.1]
⏰ Time: %s
        ]],
            player.DisplayName,
            fishName,
            tierName,
            tonumber(tierNumber or 0),
            tostring(finalSellPrice),
            fishWeight > 0 and string.format("%.2f lbs", fishWeight) or "N/A",
            variantName,
            caught and caught.Value or "N/A",
            rarest and rarest.Value or "N/A",
            levelValue and tostring(levelValue) or "N/A",
            os.date("%d %B %Y, %H:%M:%S")
        )
        
        return message
    end
    
    -- Send Discord webhook
    local function sendDiscordWebhook(fishName, tierName, tierNumber, assetId, itemId, variantId, sellPrice, uuid)
        if not webhookState.enabled or not webhookState.url or webhookState.url == "" then
            return
        end
        
        local isTarget, detectedTierName = isTargetFish(itemId)
        if not isTarget then return end
        
        local now = tick()
        if uuid and webhookDedupe.byUuid[uuid] and (now - webhookDedupe.byUuid[uuid] < 3) then
            return
        end
        if now - lastWebhookTime < WEBHOOK_COOLDOWN then
            return
        end
        
        lastWebhookTime = now
        if uuid then webhookDedupe.byUuid[uuid] = now end
        
        local embed = formatDiscordEmbed(fishName, tierName, tierNumber, assetId, itemId, variantId, sellPrice, uuid)
        local payload = {
            username = "DZ Fish It",
            embeds = {embed}
        }
        
        local body = HttpService:JSONEncode(payload)
        
        task.spawn(function()
            local attempt = 1
            local success = false
            
            while attempt <= maxRetryAttempts and not success do
                if attempt > 1 then
                    task.wait(webhookRetryDelay * (2 ^ (attempt - 1)))
                end
                
                success, err = pcall(function()
                    local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                    if requestFunc then
                        requestFunc({
                            Url = webhookState.url,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = body
                        })
                    else
                        error("No HTTP request function available")
                    end
                end)
                
                if success then
                    break
                else
                    attempt = attempt + 1
                end
            end
        end)
    end
    
    -- Send Discord activation notification
    local function sendDiscordActivationNotification()
        if not webhookState.url or webhookState.url == "" then return end
        
        local caught = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Caught")
        local rarest = player.leaderstats and player.leaderstats:FindFirstChild("Rarest Fish")
        local levelValue = getPlayerLevel()
        
        local selectedTiers = {}
        for tierName, _ in pairs(sharedSelectedTiers) do
            table.insert(selectedTiers, tierName)
        end
        local tierText = table.concat(selectedTiers, ", ")
        
        local embed = {
            title = "🔗 Discord Webhook Connected Successfully!",
            description = string.format([[
🎣 **%s** has connected to DZ Fish It webhook system!

====| WEBHOOK SETTINGS |====
📊 **Selected Tiers:** %s

====| PLAYER STATS |====
🎯 **Total Caught:** %s
🏆 **Rarest Fish:** %s
📈 **Level:** %s

====| SYSTEM INFO |====
🤖 **Bot:** DZ Fish It [V2.1]
⏰ **Connected:** %s
🌐 **Status:** Active & Monitoring

You will now receive notifications for rare fish catches! 🐟✨]],
                player.DisplayName,
                tierText,
                caught and caught.Value or "N/A",
                rarest and rarest.Value or "N/A",
                levelValue and tostring(levelValue) or "N/A",
                os.date("%d %B %Y, %H:%M:%S")
            ),
            color = 0x00FF00,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            footer = { text = "DZ Fish It [V2.1] • Discord Webhook Activation • " .. os.date("%d %B %Y, %H:%M:%S") }
        }
        
        local payload = {
            username = "DZ Fish It",
            embeds = {embed}
        }
        
        local body = HttpService:JSONEncode(payload)
        
        task.spawn(function()
            pcall(function()
                local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                if requestFunc then
                    requestFunc({
                        Url = webhookState.url,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                end
            end)
        end)
    end
    
    -- Send Discord deactivation notification
    local function sendDiscordDeactivationNotification()
        if not webhookState.url or webhookState.url == "" then return end
        
        local embed = {
            title = "🔌 Discord Webhook Disconnected",
            description = string.format([[
🎣 **%s** has disconnected from DZ Fish It webhook system.

====| DISCONNECTION INFO |====
⏰ **Disconnected:** %s
🌐 **Status:** Inactive
📊 **Monitoring:** Stopped

You will no longer receive fish catch notifications.
To reconnect, simply enable the webhook again! 🔄]],
                player.DisplayName,
                os.date("%d %B %Y, %H:%M:%S")
            ),
            color = 0xFF0000,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            footer = { text = "DZ Fish It [V2.1] • Discord Webhook Deactivation • " .. os.date("%d %B %Y, %H:%M:%S") }
        }
        
        local payload = {
            username = "DZ Fish It",
            embeds = {embed}
        }
        
        local body = HttpService:JSONEncode(payload)
        
        task.spawn(function()
            pcall(function()
                local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                if requestFunc then
                    requestFunc({
                        Url = webhookState.url,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                end
            end)
        end)
    end
    
    -- Send Telegram activation notification
    local function sendTelegramActivationNotification()
        if not telegramState.botToken or telegramState.botToken == "" or not telegramState.chatId or telegramState.chatId == "" then
            return
        end
        
        local caught = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Caught")
        local rarest = player.leaderstats and player.leaderstats:FindFirstChild("Rarest Fish")
        local levelValue = getPlayerLevel()
        
        local selectedTiers = {}
        for tierName, _ in pairs(sharedSelectedTiers) do
            table.insert(selectedTiers, tierName)
        end
        local tierText = table.concat(selectedTiers, ", ")
        
        local message = string.format([[
🔗 **Telegram Hook Connected Successfully!**

🎣 **%s** has connected to DZ Fish It webhook system!

**Webhook Settings:**
📊 Selected Tiers: %s

**Player Stats:**
🎯 Total Caught: %s
🏆 Rarest Fish: %s
📈 Level: %s

**System Info:**
🤖 Bot: DZ Fish It [V2.1]
⏰ Connected: %s
🌐 Status: Active & Monitoring

You will now receive notifications for rare fish catches! 🐟✨
        ]],
            player.DisplayName,
            tierText,
            caught and caught.Value or "N/A",
            rarest and rarest.Value or "N/A",
            levelValue and tostring(levelValue) or "N/A",
            os.date("%d %B %Y, %H:%M:%S")
        )
        
        local telegramURL = "https://api.telegram.org/bot" .. telegramState.botToken .. "/sendMessage"
        local data = {
            chat_id = telegramState.chatId,
            text = message,
            parse_mode = "Markdown"
        }
        
        local jsonData = HttpService:JSONEncode(data)
        
        task.spawn(function()
            pcall(function()
                local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                if requestFunc then
                    requestFunc({
                        Url = telegramURL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = jsonData
                    })
                end
            end)
        end)
    end
    
    -- Send Telegram deactivation notification
    local function sendTelegramDeactivationNotification()
        if not telegramState.botToken or telegramState.botToken == "" or not telegramState.chatId or telegramState.chatId == "" then
            return
        end
        
        local message = string.format([[
🔌 **Telegram Hook Disconnected**

🎣 **%s** has disconnected from DZ Fish It webhook system.

**Disconnection Info:**
⏰ Disconnected: %s
🌐 Status: Inactive
📊 Monitoring: Stopped

You will no longer receive fish catch notifications.
To reconnect, simply enable the webhook again! 🔄
        ]],
            player.DisplayName,
            os.date("%d %B %Y, %H:%M:%S")
        )
        
        local telegramURL = "https://api.telegram.org/bot" .. telegramState.botToken .. "/sendMessage"
        local data = {
            chat_id = telegramState.chatId,
            text = message,
            parse_mode = "Markdown"
        }
        
        local jsonData = HttpService:JSONEncode(data)
        
        task.spawn(function()
            pcall(function()
                local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                if requestFunc then
                    requestFunc({
                        Url = telegramURL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = jsonData
                    })
                end
            end)
        end)
    end
    
    -- Send Telegram message (dengan support gambar seperti Discord)
    local function sendTelegramMessage(fishName, tierName, tierNumber, assetId, itemId, variantId, sellPrice, uuid)
        if not telegramState.enabled or not telegramState.botToken or telegramState.botToken == "" or not telegramState.chatId or telegramState.chatId == "" then
            return
        end
        
        local isTarget, detectedTierName = isTargetFish(itemId)
        if not isTarget then return end
        
        local now = tick()
        if uuid and telegramDedupe.byUuid[uuid] and (now - telegramDedupe.byUuid[uuid] < 3) then
            return
        end
        if now - lastTelegramTime < TELEGRAM_COOLDOWN then
            return
        end
        
        lastTelegramTime = now
        if uuid then telegramDedupe.byUuid[uuid] = now end
        
        local message = formatTelegramMessage(fishName, tierName, tierNumber, assetId, itemId, variantId, sellPrice, uuid)
        
        -- Get image URL only if assetId is available and valid
        -- IMPORTANT: Only send image if it's actually available, otherwise send text only
        local imageUrl = nil
        if assetId and assetId ~= "" and tonumber(assetId) then
            imageUrl = getRobloxImage(assetId)
            -- Validate imageUrl: must be non-empty string and look like a valid URL
            if imageUrl and imageUrl ~= "" and string.find(imageUrl, "https?://") then
                -- Image URL is valid, will send with photo
            else
                -- Image URL is invalid or missing, send text only
                imageUrl = nil
            end
        end
        
        -- DECISION: Send with photo if imageUrl is valid, otherwise send text only
        local telegramURL
        local data
        
        if imageUrl then
            -- CASE 1: Gambar TERSEDIA → Kirim dengan sendPhoto (gambar + caption sebagai text)
            telegramURL = "https://api.telegram.org/bot" .. telegramState.botToken .. "/sendPhoto"
            data = {
                chat_id = telegramState.chatId,
                photo = imageUrl,
                caption = message,
                parse_mode = "Markdown"
            }
        else
            -- CASE 2: Gambar TIDAK TERSEDIA → Kirim text saja dengan sendMessage (tanpa gambar)
            telegramURL = "https://api.telegram.org/bot" .. telegramState.botToken .. "/sendMessage"
            data = {
                chat_id = telegramState.chatId,
                text = message,
                parse_mode = "Markdown"
            }
        end
        
        local jsonData = HttpService:JSONEncode(data)
        
        task.spawn(function()
            local attempt = 1
            local success = false
            
            while attempt <= maxRetryAttempts and not success do
                if attempt > 1 then
                    task.wait(webhookRetryDelay * (2 ^ (attempt - 1)))
                end
                
                success, err = pcall(function()
                    local requestFunc = syn and syn.request or http_request or request or fluxus and fluxus.request
                    if requestFunc then
                        requestFunc({
                            Url = telegramURL,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = jsonData
                        })
                    else
                        error("No HTTP request function available")
                    end
                end)
                
                if success then
                    break
                else
                    attempt = attempt + 1
                end
            end
        end)
    end
    
    -- Webhook listener connections
    local webhookConnections = {
        eventConnection = nil,
        guiConnection = nil
    }
    
    -- Webhook listener (untuk Discord dan Telegram)
    local function startWebhookListener()
        -- Start listener hanya jika belum running
        if webhookConnections.eventConnection or webhookConnections.guiConnection then
            return
        end
        
        -- Event-based detection (IMPROVED: Store in queue instead of overwriting)
        if netFolder and networkEvents.obtainedNewFish then
            webhookConnections.eventConnection = networkEvents.obtainedNewFish.OnClientEvent:Connect(function(itemId, metadata, data)
                -- Store catch data in queue instead of overwriting (fixes Blatant Mode fast catch issue)
                local catchData = {
                    ItemId = itemId,
                    Metadata = metadata,
                    VariantId = data and data.InventoryItem and data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId,
                    UUID = data and data.InventoryItem and data.InventoryItem.UUID,
                    AssetId = data and data.InventoryItem and data.InventoryItem.AssetId,
                    Timestamp = tick()  -- Add timestamp for matching with GUI
                }
                
                -- Add to queue (FIFO - newest at end)
                table.insert(webhookState.catchDataQueue, catchData)
                
                -- Limit queue size to prevent memory issues
                if #webhookState.catchDataQueue > webhookState.maxQueueSize then
                    table.remove(webhookState.catchDataQueue, 1)  -- Remove oldest entry
                end
            end)
        end
        
        -- GUI Detection
        local function startFishDetection()
            local guiNotif, fishText, rarityText, imageFrame = nil, nil, nil, nil
            
            local guiPaths = {
                function()
                    guiNotif = player.PlayerGui:WaitForChild("Small Notification", 5):WaitForChild("Display", 3):WaitForChild("Container", 3)
                    fishText = guiNotif:WaitForChild("ItemName", 3)
                    rarityText = guiNotif:WaitForChild("Rarity", 3)
                    imageFrame = player.PlayerGui["Small Notification"]:WaitForChild("Display", 3):WaitForChild("VectorFrame", 3):WaitForChild("Vector", 3)
                    return true
                end,
                function()
                    local smallNotif = player.PlayerGui:WaitForChild("Small Notification", 5)
                    local display = smallNotif:FindFirstChild("Display")
                    if display then
                        guiNotif = display:FindFirstChild("Container")
                        if guiNotif then
                            fishText = guiNotif:FindFirstChild("ItemName")
                            rarityText = guiNotif:FindFirstChild("Rarity")
                            imageFrame = display:FindFirstChild("VectorFrame")
                            if imageFrame then
                                imageFrame = imageFrame:FindFirstChild("Vector")
                            end
                            return fishText and rarityText and imageFrame
                        end
                    end
                    return false
                end,
                function()
                    local smallNotif = player.PlayerGui:FindFirstChild("Small Notification")
                    if smallNotif then
                        for _, desc in pairs(smallNotif:GetDescendants()) do
                            if desc.Name == "ItemName" and desc:IsA("TextLabel") then
                                fishText = desc
                            elseif desc.Name == "Rarity" and desc:IsA("TextLabel") then
                                rarityText = desc
                            elseif desc.Name == "Vector" and desc:IsA("ImageLabel") then
                                imageFrame = desc
                            end
                        end
                        return fishText and rarityText and imageFrame
                    end
                    return false
                end
            }
            
            local guiFound = false
            for _, pathFunc in ipairs(guiPaths) do
                local success, result = pcall(pathFunc)
                if success and result then
                    guiFound = true
                    break
                end
            end
            
            if not guiFound then return end
            
            if fishText then
                webhookConnections.guiConnection = fishText:GetPropertyChangedSignal("Text"):Connect(function()
                    local now = tick()
                    if now < (webhookDedupe.guiDebounceUntil or 0) then return end
                    webhookDedupe.guiDebounceUntil = now + 1.0
                    telegramDedupe.guiDebounceUntil = now + 1.0
                    
                    local fishName = fishText.Text
                    if fishName and fishName ~= "" then
                        -- Get assetId from GUI
                        local assetId = nil
                        if imageFrame and imageFrame.Image then
                            assetId = string.match(imageFrame.Image, "%d+")
                        end
                        
                        -- IMPROVED: Match catch data from queue instead of using single lastCatchData
                        -- This fixes the issue where Blatant Mode catches fish so fast that lastCatchData gets overwritten
                        local matchedCatchData = nil
                        
                        -- Strategy 1: Match by assetId (most accurate - GUI image matches catch data)
                        if assetId then
                            for i = #webhookState.catchDataQueue, 1, -1 do  -- Search from newest to oldest
                                local catchData = webhookState.catchDataQueue[i]
                                if catchData.AssetId and tostring(catchData.AssetId) == tostring(assetId) then
                                    -- Verify timestamp is recent (within 5 seconds) to avoid old data
                                    if (now - catchData.Timestamp) < 5 then
                                        matchedCatchData = catchData
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- Strategy 2: Match by fishName + ItemId (if ItemUtility available)
                        if not matchedCatchData and ItemUtility then
                            for i = #webhookState.catchDataQueue, 1, -1 do
                                local catchData = webhookState.catchDataQueue[i]
                                if catchData.ItemId and (now - catchData.Timestamp) < 5 then
                                    local success, fishData = pcall(function()
                                        return ItemUtility:GetItemData(catchData.ItemId)
                                    end)
                                    if success and fishData and fishData.Data and fishData.Data.Name == fishName then
                                        matchedCatchData = catchData
                                        -- Update assetId from catch data if GUI didn't provide it
                                        if not assetId and catchData.AssetId then
                                            assetId = catchData.AssetId
                                        end
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- Strategy 3: Use most recent catch data as fallback (within 5 seconds)
                        if not matchedCatchData and #webhookState.catchDataQueue > 0 then
                            for i = #webhookState.catchDataQueue, 1, -1 do
                                local catchData = webhookState.catchDataQueue[i]
                                if (now - catchData.Timestamp) < 5 then
                                    matchedCatchData = catchData
                                    -- Update assetId from catch data if GUI didn't provide it
                                    if not assetId and catchData.AssetId then
                                        assetId = catchData.AssetId
                                    end
                                    break
                                end
                            end
                        end
                        
                        -- Only send webhook if we found a match
                        if matchedCatchData then
                            local rarity = rarityText and rarityText.Text or "Unknown"
                            local sellPrice = 0
                            if matchedCatchData.ItemId and FishDataById[matchedCatchData.ItemId] then
                                sellPrice = FishDataById[matchedCatchData.ItemId].SellPrice
                            end
                            
                            -- Ensure assetId is set (from GUI or from catch data)
                            if not assetId and matchedCatchData.AssetId then
                                assetId = matchedCatchData.AssetId
                            end
                            
                            -- Extract weight from matched catch data metadata
                            local fishWeight = 0
                            if matchedCatchData.Metadata and matchedCatchData.Metadata.Weight then
                                fishWeight = matchedCatchData.Metadata.Weight
                            end
                            
                            local tierName = nil
                            local tierNumber = nil
                            pcall(function()
                                if ItemUtility and matchedCatchData.ItemId then
                                    local fishData = ItemUtility:GetItemData(matchedCatchData.ItemId)
                                    if fishData and fishData.Data then
                                        tierNumber = fishData.Data.Tier
                                        tierName = TierMapping[tierNumber]
                                    end
                                end
                            end)
                            
                            if tierName and sharedSelectedTiers[tierName] then
                                -- Temporarily store matched catch data for format functions (they need metadata for weight)
                                -- This is safe because format functions are called synchronously
                                local tempLastCatchData = webhookState.lastCatchData
                                webhookState.lastCatchData = matchedCatchData
                                
                                -- Send Discord webhook with matched data
                                sendDiscordWebhook(
                                    fishName,
                                    tierName,
                                    tierNumber,
                                    assetId,
                                    matchedCatchData.ItemId,
                                    matchedCatchData.VariantId,
                                    sellPrice,
                                    matchedCatchData.UUID
                                )
                                
                                -- Send Telegram message with matched data
                                sendTelegramMessage(
                                    fishName,
                                    tierName,
                                    tierNumber,
                                    assetId,
                                    matchedCatchData.ItemId,
                                    matchedCatchData.VariantId,
                                    sellPrice,
                                    matchedCatchData.UUID
                                )
                                
                                -- Restore previous state (though it should be nil)
                                webhookState.lastCatchData = tempLastCatchData
                                
                                -- Remove matched catch data from queue to prevent duplicates
                                -- Search by UUID for exact match
                                if matchedCatchData.UUID then
                                    for i = #webhookState.catchDataQueue, 1, -1 do
                                        if webhookState.catchDataQueue[i].UUID == matchedCatchData.UUID then
                                            table.remove(webhookState.catchDataQueue, i)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
        
        pcall(startFishDetection)
        webhookState.connection = true
    end
    
    local function stopWebhookListener()
        if webhookConnections.eventConnection then
            webhookConnections.eventConnection:Disconnect()
            webhookConnections.eventConnection = nil
        end
        if webhookConnections.guiConnection then
            webhookConnections.guiConnection:Disconnect()
            webhookConnections.guiConnection = nil
        end
        webhookState.connection = nil
        -- Clear queue when stopping webhook listener
        webhookState.catchDataQueue = {}
    end
    
    -- ====== WEBHOOK TAB UI ======
    
    -- Shared Tier Selection (untuk Discord dan Telegram)
    Webhook:Section({ Title = "Tier Selection" })
    
    local tierDropdownInitialized = false
    Webhook:Dropdown({
        Title = "Select Fish Tiers",
        Desc = "Choose which tiers to send notifications for (shared for Discord and Telegram)",
        Values = {"Epic", "Legendary", "Mythic", "Secret"},
        Multi = true,
        Default = {"Mythic", "Secret"},
        Callback = function(selected)
            sharedSelectedTiers = {}
            webhookState.selectedTiers = {}
            telegramState.selectedTiers = {}
            
            for _, tierName in ipairs(selected) do
                sharedSelectedTiers[tierName] = true
                webhookState.selectedTiers[tierName] = true
                telegramState.selectedTiers[tierName] = true
            end
            
            if tierDropdownInitialized then
                local tierText = table.concat(selected, ", ")
                pcall(function() UI:Notify({ Title = "Tier Selection", Content = "Selected tiers: " .. tierText, Duration = 2, Icon = "bell-ring" }) end)
            else
                tierDropdownInitialized = true
            end
        end
    })
    
    -- Discord Webhook Section
    Webhook:Section({ Title = "Discord Webhook" })
    
    Webhook:Paragraph({
        Title = "Discord Webhook",
        Desc = "Get notified in Discord when you catch rare fish!",
        Locked = true
    })
    
    local webhookUrlInput = Webhook:Input({
        Title = "Webhook URL",
        Desc = "Enter your Discord webhook URL",
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(text)
            webhookState.url = text
            -- Only validate and show notification if user entered something
            if text and text ~= "" then
                local isValid, message = validateDiscordWebhook(text)
                if isValid then
                    pcall(function() UI:Notify({ Title = "Discord Webhook", Content = "Webhook URL saved successfully!", Duration = 2, Icon = "circle-check" }) end)
                else
                    pcall(function() UI:Notify({ Title = "Discord Webhook", Content = "Invalid webhook URL: " .. message, Duration = 3, Icon = "alert-triangle" }) end)
                end
            end
            -- If empty, don't show any notification (normal/default state)
        end
    })
    
    local discordWebhookToggle = Webhook:Toggle({
        Title = "Enable Discord Webhook",
        Callback = function(value)
            if value and (not webhookState.url or webhookState.url == "") then
                pcall(function() UI:Notify({ Title = "Discord Webhook", Content = "Please enter a webhook URL first!", Duration = 3, Icon = "alert-triangle" }) end)
                return
            end
            
            local hasSelection = false
            for _, _ in pairs(sharedSelectedTiers) do
                hasSelection = true
                break
            end
            
            if value and not hasSelection then
                pcall(function() UI:Notify({ Title = "Discord Webhook", Content = "Please select at least one tier first!", Duration = 3, Icon = "alert-triangle" }) end)
                return
            end
            
            webhookState.enabled = value
            if value then
                -- Start listener jika belum running dan (Discord atau Telegram enabled)
                if not webhookState.connection then
                    startWebhookListener()
                end
                pcall(function() UI:Notify({ Title = "Discord Webhook", Content = "✅ Discord webhook enabled!", Duration = 3, Icon = "bell-ring" }) end)
                -- Send activation notification (non-blocking)
                task.spawn(function()
                    task.wait(1) -- Small delay to ensure listener is ready
                    sendDiscordActivationNotification()
                end)
            else
                -- Send deactivation notification before stopping (non-blocking)
                task.spawn(function()
                    sendDiscordDeactivationNotification()
                end)
                -- Stop listener hanya jika kedua-duanya disabled
                if not telegramState.enabled then
                    stopWebhookListener()
                end
                pcall(function() UI:Notify({ Title = "Discord Webhook", Content = "❌ Discord webhook disabled", Duration = 2, Icon = "bell" }) end)
            end
        end
    })
    
    -- Telegram Hook Section
    Webhook:Section({ Title = "Telegram Hook" })
    
    Webhook:Paragraph({
        Title = "Telegram Hook",
        Desc = "Get notified in Telegram when you catch rare fish!",
        Locked = true
    })
    
    local telegramBotTokenInput = Webhook:Input({
        Title = "Bot Token",
        Desc = "Enter your Telegram bot token",
        Placeholder = "123456789:ABCdefGHIjklMNOpqrsTUVwxyz",
        Callback = function(text)
            telegramState.botToken = text
            -- Only validate and show notification if user entered something
            if text and text ~= "" then
                local isValid, message = validateTelegram(text, telegramState.chatId)
                if isValid then
                    pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "Bot token saved!", Duration = 2, Icon = "circle-check" }) end)
                elseif telegramState.chatId and telegramState.chatId ~= "" then
                    -- Only show error if chatId is already filled (meaning user is trying to complete setup)
                    pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "Invalid bot token: " .. message, Duration = 3, Icon = "alert-triangle" }) end)
                end
            end
            -- If empty, don't show any notification (normal/default state)
        end
    })
    
    local telegramChatIdInput = Webhook:Input({
        Title = "Chat ID",
        Desc = "Enter your Telegram chat ID",
        Placeholder = "123456789",
        Callback = function(text)
            telegramState.chatId = text
            -- Only validate and show notification if user entered something
            if text and text ~= "" then
                local isValid, message = validateTelegram(telegramState.botToken, text)
                if isValid then
                    pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "Chat ID saved!", Duration = 2, Icon = "circle-check" }) end)
                elseif telegramState.botToken and telegramState.botToken ~= "" then
                    -- Only show error if botToken is already filled (meaning user is trying to complete setup)
                    pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "Invalid chat ID: " .. message, Duration = 3, Icon = "alert-triangle" }) end)
                end
            end
            -- If empty, don't show any notification (normal/default state)
        end
    })
    
    local telegramHookToggle = Webhook:Toggle({
        Title = "Enable Telegram Hook",
        Callback = function(value)
            if value and (not telegramState.botToken or telegramState.botToken == "" or not telegramState.chatId or telegramState.chatId == "") then
                pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "Please enter bot token and chat ID first!", Duration = 3, Icon = "alert-triangle" }) end)
                return
            end
            
            local hasSelection = false
            for _, _ in pairs(sharedSelectedTiers) do
                hasSelection = true
                break
            end
            
            if value and not hasSelection then
                pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "Please select at least one tier first!", Duration = 3, Icon = "alert-triangle" }) end)
                return
            end
            
            telegramState.enabled = value
            if value then
                -- Start listener jika belum running dan (Discord atau Telegram enabled)
                if not webhookState.connection then
                    startWebhookListener()
                end
                pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "✅ Telegram hook enabled!", Duration = 3, Icon = "bell-ring" }) end)
                -- Send activation notification (non-blocking)
                task.spawn(function()
                    task.wait(1) -- Small delay to ensure listener is ready
                    sendTelegramActivationNotification()
                end)
            else
                -- Send deactivation notification before stopping (non-blocking)
                task.spawn(function()
                    sendTelegramDeactivationNotification()
                end)
                -- Stop listener hanya jika kedua-duanya disabled
                if not webhookState.enabled then
                    stopWebhookListener()
                end
                pcall(function() UI:Notify({ Title = "Telegram Hook", Content = "❌ Telegram hook disabled", Duration = 2, Icon = "bell" }) end)
            end
        end
    })
    
    -- Status Info
    Webhook:Section({ Title = "Status" })
    
    Webhook:Paragraph({
        Title = "Notification Status",
        Desc = function()
            local discordStatus = webhookState.enabled and "🟢 ENABLED" or "🔴 DISABLED"
            local telegramStatus = telegramState.enabled and "🟢 ENABLED" or "🔴 DISABLED"
            local tierCount = 0
            for _, _ in pairs(sharedSelectedTiers) do
                tierCount = tierCount + 1
            end
            
            return string.format([[
Discord: %s
Telegram: %s
Tiers: %d selected
Cooldown: 15 seconds
            ]], discordStatus, telegramStatus, tierCount)
        end,
        Locked = true
    })
    
    end)  -- End pcall for Webhook tab

    -------------------------------------------
    ----- =======[ SETTINGS TAB CONTENT ]
    -------------------------------------------
    pcall(function()
    
    -- Section: Performance & Graphic
    Settings:Section({ Title = "Performance & Graphic" })
    
    -- GPU Saver Toggle
    local gpuSaverToggle = Settings:Toggle({ 
        Title = "GPU Saver Mode", 
        Callback = function(v)
            pcall(function()
                if v then
                    -- Enable GPU Saver
                    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                    local Lighting = game:GetService("Lighting")
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 1000
                    Lighting.Brightness = 0
                    if setfpscap then pcall(function() setfpscap(30) end) end
                    pcall(function() UI:Notify({ Title = "GPU Saver", Content = "GPU Saver enabled", Duration = 2, Icon = "gauge" }) end)
                else
                    -- Disable GPU Saver
                    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
                    local Lighting = game:GetService("Lighting")
                    Lighting.GlobalShadows = true
                    Lighting.FogEnd = 100000
                    Lighting.Brightness = 1
                    if setfpscap then pcall(function() setfpscap(0) end) end
                    pcall(function() UI:Notify({ Title = "GPU Saver", Content = "GPU Saver disabled", Duration = 2, Icon = "gauge" }) end)
                end
            end)
        end
    })
    
    -- Low Graphics Button with warning
    Settings:Button({ 
        Title = "Low Graphics (IRREVERSIBLE)", 
        Callback = function()
            pcall(function()
                -- Set to lowest quality
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                local Lighting = game:GetService("Lighting")
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 1000
                Lighting.Brightness = 0
                -- Disable all effects
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") then
                        obj.Enabled = false
                    end
                end
                pcall(function() UI:Notify({ Title = "Low Graphics", Content = "Low graphics enabled (IRREVERSIBLE)", Duration = 3, Icon = "alert-triangle" }) end)
            end)
        end 
    })
    
    -- FPS Control
    Settings:Dropdown({
        Title = "FPS Cap",
        Desc = "Set maximum FPS (0 = Max/Unlimited)",
        Values = {"Max", "120", "90", "75", "60", "30"},
        Value = "Max",
        Callback = function(val)
            pcall(function()
                if setfpscap then
                    local cap = val == "Max" and 0 or tonumber(val) or 0
                    setfpscap(cap)
                    pcall(function() UI:Notify({ Title = "FPS Cap", Content = "FPS cap set to: " .. (cap == 0 and "Max" or tostring(cap)), Duration = 2, Icon = "gauge" }) end)
                else
                    pcall(function() UI:Notify({ Title = "FPS Cap", Content = "setfpscap function not available", Duration = 2, Icon = "alert-triangle" }) end)
                end
            end)
        end
    })
    
    end)  -- End pcall for Settings tab

    -------------------------------------------
    ----- =======[ AUTO FISHING TAB CONTENT ]
    -------------------------------------------
    pcall(function()
    
    -- ====== AUTO FISH STATE ======
    local autoFishState = {
        enabled = false,
        mode = "Normal", -- "Normal" or "Blatant"
        loop = nil,
        isFishing = false, -- Flag untuk prevent overlap
        -- Blatant Mode settings (from script.lua + barulagi.lua combination)
        fishDelay = 0.9, -- Wait for fish to bite (from script.lua)
        catchDelay = 0.2, -- Base catch delay (from script.lua)
        burstCount = 2, -- Number of parallel casts (from script.lua)
        spamReelCount = 5, -- Number of spam reels (from script.lua)
        -- Note: useCancelFishing is automatically enabled for Blatant Mode (not shown in UI)
        autoTune = false, -- Auto-tune delays (from barulagi.lua)
        successCount = 0,
        errorCount = 0,
        -- Normal Mode settings
        recastDelay = 0.05,
        waitDelay = 1.5
    }
    
    -- ====== NETWORK EVENTS FOR AUTO FISH ======
    local function getAutoFishNetFolder()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")
    end
    
    local function getAutoFishNetworkEvents()
        local success, events = pcall(function()
            local netFolder = getAutoFishNetFolder()
            if not netFolder then return nil end
            
            return {
                chargeRod = netFolder:FindFirstChild("RF/ChargeFishingRod"),
                startMinigame = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted"),
                fishingCompleted = netFolder:FindFirstChild("RE/FishingCompleted"),
                cancelFishing = netFolder:FindFirstChild("RF/CancelFishingInputs"),
                equipTool = netFolder:FindFirstChild("RE/EquipToolFromHotbar"),
                fishCaught = netFolder:FindFirstChild("RE/FishCaught")
            }
        end)
        
        if success and events then
            return events
        else
            return nil
        end
    end
    
    local autoFishNetworkEvents = getAutoFishNetworkEvents()
    
    -- ====== BLATANT MODE FUNCTIONS (Combined: script.lua + barulagi.lua) ======
    local function clamp(v, lo, hi)
        return math.clamp(v, lo, hi)
    end
    
    local function equipRodFast()
        if not autoFishNetworkEvents or not autoFishNetworkEvents.equipTool then return end
        pcall(function()
            autoFishNetworkEvents.equipTool:FireServer(1)
        end)
    end
    
    local function tuneBlatantDelay(up)
        if up then
            autoFishState.fishDelay = clamp(autoFishState.fishDelay + 0.1, 0.1, 10)
            autoFishState.catchDelay = clamp(autoFishState.catchDelay + 0.05, 0.1, 10)
        else
            autoFishState.fishDelay = clamp(autoFishState.fishDelay - 0.05, 0.1, 10)
            autoFishState.catchDelay = clamp(autoFishState.catchDelay - 0.03, 0.1, 10)
        end
    end
    
    local function doBlatantFishingCycle()
        if not autoFishNetworkEvents then return false end
        if autoFishState.isFishing then return false end -- Prevent overlap
        
        local ok = pcall(function()
            autoFishState.isFishing = true
            
            -- Step 1: Rapid fire casts (parallel casts based on burstCount) - from script.lua
            equipRodFast()
            task.wait(0.01)
            
            -- Create multiple parallel casts (burst casting)
            for i = 1, autoFishState.burstCount do
                task.spawn(function()
                    if autoFishNetworkEvents.chargeRod and autoFishNetworkEvents.startMinigame then
                        -- Use dynamic timestamp (better than static) - from barulagi.lua
                        local args = { [4] = workspace:GetServerTimeNow() }
                        autoFishNetworkEvents.chargeRod:InvokeServer(unpack(args, 1, table.maxn(args)))
                        task.wait(0.01)
                        -- Use normal minigame values (from script.lua)
                        autoFishNetworkEvents.startMinigame:InvokeServer(1.2854545116425, 1)
                    end
                end)
                
                -- Small delay between parallel casts (only if not last cast)
                if i < autoFishState.burstCount then
                    task.wait(0.05)
                end
            end
            
            -- Step 2: Wait for fish to bite - from script.lua
            task.wait(autoFishState.fishDelay)
            
            -- Step 3: Spam reel 5x to instant catch - from script.lua
            if autoFishNetworkEvents.fishingCompleted then
                for i = 1, autoFishState.spamReelCount do
                    pcall(function()
                        autoFishNetworkEvents.fishingCompleted:FireServer()
                    end)
                    task.wait(0.01)
                end
            end
            
            -- Step 4: Cancel fishing (automatically enabled for Blatant Mode) - from barulagi.lua
            if autoFishNetworkEvents.cancelFishing then
                task.wait(0.01)
                pcall(function()
                    autoFishNetworkEvents.cancelFishing:InvokeServer()
                end)
            end
            
            -- Step 5: Short cooldown (50% faster) - from script.lua
            task.wait(autoFishState.catchDelay * 0.5)
            
            autoFishState.isFishing = false
        end)
        
        if ok then
            autoFishState.successCount = autoFishState.successCount + 1
        else
            autoFishState.errorCount = autoFishState.errorCount + 1
            autoFishState.isFishing = false -- Reset on error
        end
        
        -- Auto-tune logic - from barulagi.lua
        if autoFishState.autoTune then
            if autoFishState.errorCount >= 3 then
                tuneBlatantDelay(true)
                autoFishState.errorCount = 0
                pcall(function() UI:Notify({ 
                    Title = "Auto-Tune", 
                    Content = string.format("Delay increased | Fish: %.2f | Catch: %.2f", autoFishState.fishDelay, autoFishState.catchDelay), 
                    Duration = 2, 
                    Icon = "brain" 
                }) end)
            elseif autoFishState.successCount >= 10 then
                tuneBlatantDelay(false)
                autoFishState.successCount = 0
                pcall(function() UI:Notify({ 
                    Title = "Auto-Tune", 
                    Content = string.format("Delay decreased | Fish: %.2f | Catch: %.2f", autoFishState.fishDelay, autoFishState.catchDelay), 
                    Duration = 2, 
                    Icon = "zap" 
                }) end)
            end
        end
        
        return ok
    end
    
    -- ====== NORMAL MODE FUNCTIONS (from GHOSTFIND.lua) ======
    -- Note: equipRodFast() is already defined in Blatant Mode section above
    
    local function instantRecast()
        if not autoFishNetworkEvents then return end
        
        pcall(function()
            -- Charge rod and start minigame (GHOSTFIND method)
            if autoFishNetworkEvents.chargeRod and autoFishNetworkEvents.startMinigame then
                -- Charge rod (using dynamic timestamp like barulagi but method from GHOSTFIND)
                local chargeArgs = { [4] = workspace:GetServerTimeNow() }
                autoFishNetworkEvents.chargeRod:InvokeServer(unpack(chargeArgs, 1, table.maxn(chargeArgs)))
                
                -- Start minigame with GHOSTFIND huge values
                local hugeValue1 = 999999999999.9999999 + 9999999 * 9999999.9999999
                local hugeValue2 = 9999999.9999999
                autoFishNetworkEvents.startMinigame:InvokeServer(hugeValue1, hugeValue2)
            end
            
            -- Wait delay
            task.wait(autoFishState.waitDelay)
            
            -- Fire fishing completed with same huge values (GHOSTFIND method)
            if autoFishNetworkEvents.fishingCompleted then
                local hugeValue1 = 999999999999.9999999 + 9999999 * 9999999.9999999
                local hugeValue2 = 9999999.9999999
                autoFishNetworkEvents.fishingCompleted:FireServer(hugeValue1, hugeValue2)
            end
        end)
    end
    
    local function doNormalFishingCycle()
        equipRodFast()
        instantRecast()
        task.wait(autoFishState.recastDelay)
    end
    
    -- ====== FISH CAUGHT EVENT (for Normal mode auto-recast) ======
    local fishCaughtConnection = nil
    local function setupFishCaughtEvent()
        if fishCaughtConnection then return end
        
        if autoFishNetworkEvents and autoFishNetworkEvents.fishCaught then
            fishCaughtConnection = autoFishNetworkEvents.fishCaught.OnClientEvent:Connect(function(fishName, fishData)
                if autoFishState.enabled and autoFishState.mode == "Normal" then
                    equipRodFast()
                    instantRecast()
                end
            end)
        end
    end
    
    local function cleanupFishCaughtEvent()
        if fishCaughtConnection then
            fishCaughtConnection:Disconnect()
            fishCaughtConnection = nil
        end
    end
    
    -- ====== MAIN AUTO FISH LOOP ======
    local function startAutoFish()
        if autoFishState.loop then return end
        
        autoFishState.enabled = true
        
        -- Auto equip rod when Auto Fish first starts (for both Blatant and Normal mode)
        equipRodFast()
        task.wait(0.1) -- Small delay to ensure rod is equipped
        
        setupFishCaughtEvent()
        
        autoFishState.loop = task.spawn(function()
            while autoFishState.enabled do
                if autoFishState.mode == "Blatant" then
                    doBlatantFishingCycle()
                else -- Normal mode
                    doNormalFishingCycle()
                end
            end
        end)
    end
    
    local function stopAutoFish()
        autoFishState.enabled = false
        autoFishState.isFishing = false
        if autoFishState.loop then
            task.cancel(autoFishState.loop)
            autoFishState.loop = nil
        end
        cleanupFishCaughtEvent()
        
        -- Cancel fishing on stop (important for cleanup)
        if autoFishNetworkEvents and autoFishNetworkEvents.cancelFishing then
            pcall(function()
                autoFishNetworkEvents.cancelFishing:InvokeServer()
            end)
        end
    end
    
    -- ====== UI ELEMENTS ======
    -- Section: Auto Fish
    AutoFishing:Section({ Title = "Auto Fish" })
    
    -- Mode Selection Dropdown
    AutoFishing:Dropdown({
        Title = "Auto Fish Mode",
        Desc = "Select fishing mode: Blatant (fast with delays) or Normal (instant recast)",
        Values = {"Normal", "Blatant"},
        Value = autoFishState.mode,
        Callback = function(selected)
            if autoFishState.enabled then
                -- Restart auto fish if it's running
                stopAutoFish()
                autoFishState.mode = selected
                startAutoFish()
                pcall(function() UI:Notify({ 
                    Title = "Auto Fish", 
                    Content = "Mode changed to: " .. selected .. " (restarted)", 
                    Duration = 2, 
                    Icon = "fishing-pole" 
                }) end)
            else
                autoFishState.mode = selected
                pcall(function() UI:Notify({ 
                    Title = "Auto Fish", 
                    Content = "Mode set to: " .. selected, 
                    Duration = 2, 
                    Icon = "fishing-pole" 
                }) end)
            end
        end
    })
    
    -- Auto Fish Toggle
    AutoFishing:Toggle({
        Title = "Enable Auto Fish",
        Default = autoFishState.enabled,
        Callback = function(value)
            autoFishState.enabled = value
            if value then
                startAutoFish()
                pcall(function() UI:Notify({ 
                    Title = "Auto Fish", 
                    Content = "Started Auto Fish (" .. autoFishState.mode .. " mode)", 
                    Duration = 3, 
                    Icon = "fishing-pole" 
                }) end)
            else
                stopAutoFish()
                pcall(function() UI:Notify({ 
                    Title = "Auto Fish", 
                    Content = "Stopped Auto Fish", 
                    Duration = 2, 
                    Icon = "fishing-pole" 
                }) end)
            end
        end
    })
    
    -- Section: Blatant Mode Settings
    AutoFishing:Section({ Title = "Blatant Mode Settings" })
    
    -- Fish Delay Slider (Blatant Mode) - Wait for fish to bite
    AutoFishing:Slider({
        Title = "Fish Delay (seconds) - Blatant Mode",
        Desc = "Wait time for fish to bite (Blatant Mode only)",
        Value = { Min = 0.1, Max = 10, Default = autoFishState.fishDelay },
        Step = 0.1,
        Callback = function(val)
            autoFishState.fishDelay = math.clamp(tonumber(val) or 0.9, 0.1, 10)
        end
    })
    
    -- Catch Delay Slider (Blatant Mode) - Base catch delay
    AutoFishing:Slider({
        Title = "Catch Delay (seconds) - Blatant Mode",
        Desc = "Base catch delay (will be 50% faster in cycle) (Blatant Mode only)",
        Value = { Min = 0.1, Max = 10, Default = autoFishState.catchDelay },
        Step = 0.1,
        Callback = function(val)
            autoFishState.catchDelay = math.clamp(tonumber(val) or 0.2, 0.1, 10)
        end
    })
    
    -- Burst Count Slider (Blatant Mode) - Number of parallel casts
    AutoFishing:Slider({
        Title = "Burst Count - Blatant Mode",
        Desc = "Number of parallel casts (2-5 recommended) (Blatant Mode only)",
        Value = { Min = 1, Max = 5, Default = autoFishState.burstCount },
        Step = 1,
        Callback = function(val)
            autoFishState.burstCount = math.clamp(tonumber(val) or 2, 1, 5)
        end
    })
    
    -- Spam Reel Count Slider (Blatant Mode)
    AutoFishing:Slider({
        Title = "Spam Reel Count - Blatant Mode",
        Desc = "Number of spam reels for instant catch (3-10 recommended) (Blatant Mode only)",
        Value = { Min = 1, Max = 10, Default = autoFishState.spamReelCount },
        Step = 1,
        Callback = function(val)
            autoFishState.spamReelCount = math.clamp(tonumber(val) or 5, 1, 10)
        end
    })
    
    -- Auto-Tune Toggle (Blatant Mode only)
    -- Note: Cancel Fishing is automatically enabled for Blatant Mode (not shown in UI)
    AutoFishing:Toggle({
        Title = "🧠 Auto-Tune - Blatant Mode",
        Desc = "Automatically adjust delays based on success/error rate (Blatant Mode only)",
        Default = autoFishState.autoTune,
        Callback = function(value)
            autoFishState.autoTune = value
            autoFishState.successCount = 0
            autoFishState.errorCount = 0
            pcall(function() UI:Notify({ 
                Title = "Auto-Tune", 
                Content = value and "Enabled - Delays will auto-adjust (Blatant Mode)" or "Disabled", 
                Duration = 2, 
                Icon = "brain" 
            }) end)
        end
    })
    
    -- Section: Normal Mode Settings
    AutoFishing:Section({ Title = "Normal Mode Settings" })
    
    -- Recast Delay Slider (Normal Mode)
    AutoFishing:Slider({
        Title = "Recast Delay (seconds) - Normal Mode",
        Value = { Min = 0.01, Max = 5, Default = autoFishState.recastDelay },
        Step = 0.01,
        Callback = function(val)
            autoFishState.recastDelay = math.clamp(tonumber(val) or 0.05, 0.01, 5)
        end
    })
    
    -- Wait Delay Slider (Normal Mode)
    AutoFishing:Slider({
        Title = "Wait Delay (seconds) - Normal Mode",
        Value = { Min = 0.1, Max = 10, Default = autoFishState.waitDelay },
        Step = 0.1,
        Callback = function(val)
            autoFishState.waitDelay = math.clamp(tonumber(val) or 1.5, 0.1, 10)
        end
    })
    
    end)  -- End pcall for Auto Fishing tab
    
    -------------------------------------------
    ----- =======[ AUTOMATION TAB CONTENT ]
    -------------------------------------------
    pcall(function()
    
    -- ====== AUTO SELL (from DZ Fish It [V2].lua) ======
    -- Auto Sell state
    local autoSellState = { enabled = false, minutes = 5, loop = nil }
    
    -- Helper: get SellAllItems RemoteFunction
    local function getSellRemote()
        local ok, rf = pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local packages = rs:WaitForChild("Packages", 8)
            local net = packages:WaitForChild("_Index", 8):WaitForChild("sleitnick_net@0.2.0", 8):WaitForChild("net", 8)
            return net:WaitForChild("RF/SellAllItems", 5)
        end)
        return ok and rf or nil
    end
    
    -- Loop controller
    local function startAutoSell()
        if autoSellState.loop then return end
        autoSellState.loop = task.spawn(function()
            while autoSellState.enabled do
                local rf = getSellRemote()
                if rf then
                    pcall(function()
                        -- Call sell and try to read response for count/value
                        local res = rf:InvokeServer()
                        local soldCount, earned
                        if typeof(res) == "table" then
                            soldCount = res.count or res.items or res.sold or res.Items or res.ItemCount or res.TotalItems or res.itemCount
                            earned = res.money or res.value or res.gold or res.coins or res.total or res.TotalGold or res.TotalValue
                        elseif typeof(res) == "number" then
                            -- Could be either items or money; assume items when small (<1e4)
                            if res > 10000 then earned = res else soldCount = res end
                        end

                        local function fmtMoney(n)
                            n = tonumber(n) or 0
                            if n >= 1e6 then return string.format("$ %.1f M", n/1e6)
                            elseif n >= 1e3 then return string.format("$ %.1f K", n/1e3)
                            else return string.format("$ %d", n) end
                        end

                        local msg
                        if soldCount and earned then
                            msg = string.format("Success sell %s Fish for %s", tostring(soldCount), fmtMoney(earned))
                        elseif soldCount then
                            msg = string.format("Success sell %s Fish", tostring(soldCount))
                        elseif earned then
                            msg = string.format("Success sell Fish for %s", fmtMoney(earned))
                        else
                            msg = "Sold all items"
                        end

                        pcall(function() UI:Notify({ Title = "Auto Sell", Content = msg, Duration = 3, Icon = "circle-check" }) end)
                    end)
                else
                    pcall(function() UI:Notify({ Title = "Auto Sell", Content = "Sell remote not found", Duration = 3, Icon = "alert-triangle" }) end)
                end
                local waitSec = (autoSellState.minutes or 5) * 60
                local t0 = os.clock()
                while autoSellState.enabled and (os.clock() - t0) < waitSec do
                    task.wait(0.5)
                end
            end
        end)
    end

    local function stopAutoSell()
        if autoSellState.loop then task.cancel(autoSellState.loop); autoSellState.loop = nil end
    end
    
    -- ====== UI ELEMENTS ======
    -- Section: Auto Sell
    Automation:Section({ Title = "Auto Sell" })
    
    -- Slider: interval minutes (1..60)
    Automation:Slider({
        Title = "Sell Interval (minutes)",
        Value = { Min = 1, Max = 60, Default = 5 },
        Step = 1,
        Callback = function(val)
            local n = tonumber(val) or 5
            n = math.clamp(n, 1, 60)
            autoSellState.minutes = n
        end
    })
    
    -- Toggle: enable auto sell
    Automation:Toggle({
        Title = "Enable Auto Sell",
        Default = autoSellState.enabled or false,
        Callback = function(v)
            autoSellState.enabled = v
            if v then
                startAutoSell()
                pcall(function() UI:Notify({ Title = "Auto Sell", Content = "Started auto selling every " .. autoSellState.minutes .. " minutes", Duration = 3, Icon = "circle-check" }) end)
            else
                stopAutoSell()
                pcall(function() UI:Notify({ Title = "Auto Sell", Content = "Stopped auto selling", Duration = 2, Icon = "circle-check" }) end)
            end
        end
    })
    
    -- ====== AUTO BUY WEATHER (from DZ Fish It [V2].lua) ======
    -- Helper function to get network folder (if not available in scope)
    local function getAutoBuyWeatherNetFolder()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local packages = replicatedStorage:WaitForChild("Packages", 10)
        if not packages then return nil end
        
        local index = packages:FindFirstChild("_Index")
        if not index then return nil end
        
        for _, child in ipairs(index:GetChildren()) do
            if child.Name:match("^sleitnick_net@") then
                local netFolder = child:FindFirstChild("net")
                if netFolder then
                    return netFolder
                end
            end
        end
        return nil
    end
    
    -- Weather state
    local weatherState = {
        enabled = false,
        selectedList = {},
        lastPurchaseTime = {},
        purchaseCooldown = 30  -- Cooldown in seconds between purchase attempts
    }
    
    -- Weather events from DZv1.lua
    local weatherNames = {"Wind", "Snow", "Cloudy", "Storm", "Shark Hunt"}
    
    -- Weather payload map from DZv1.lua
    local weatherPayloadMap = {
        ["Wind"] = {  "Wind", 1, "wind" },
        ["Snow"] = {  "Snow", 2, "snow" },
        ["Cloudy"] = {  "Cloudy", 3, "cloudy" },
        ["Storm"] = {  "Storm", 4, "storm" },
        ["Shark Hunt"] = { "Shark Hunt", 5, "shark_hunt", "SharkHunt" },
    }
    
    -- Helper: robustly find the RemoteFunction used to purchase weather
    -- Try to use networkEvents.purchaseWeather first, then fallback to manual search
    local function findPurchaseWeatherRF()
        -- Try to use existing networkEvents.purchaseWeather if available (from webhook section)
        if networkEvents and networkEvents.purchaseWeather then
            return networkEvents.purchaseWeather
        end
        
        -- Fallback: manual search using Automation tab's helper function
        local netFolder = getAutoBuyWeatherNetFolder()
        if not netFolder then return nil end
        
        local names = {
            "RF/PurchaseWeatherEvent",
            "RF/PurchaseWeather",
            "RF/WeatherPurchase",
            "RF/BuyWeatherEvent",
        }
        for _, n in ipairs(names) do
            local rf = netFolder:FindFirstChild(n)
            if rf then return rf end
        end
        
        -- Fallback: scan descendants
        for _, d in ipairs(netFolder:GetDescendants()) do
            if typeof(d) == "Instance" and d.ClassName == "RemoteFunction" then
                local nm = string.lower(d.Name)
                if nm:find("weather") and (nm:find("purchase") or nm:find("buy")) then
                    return d
                end
            end
        end
        
        return nil
    end
    
    -- Helper: attempt purchasing a weather by trying multiple payload shapes
    local function attemptPurchaseWeather(weatherName)
        local rf = findPurchaseWeatherRF()
        if not rf then
            pcall(function() UI:Notify({ Title = "Weather", Content = "Purchase remote not found", Duration = 3, Icon = "alert-triangle" }) end)
            return false
        end
        
        local map = weatherPayloadMap[weatherName] or {weatherName}
        local name, id, lower
        for _, v in ipairs(map) do
            if type(v) == "string" then name = name or v; lower = lower or v:lower() end
            if type(v) == "number" then id = id or v end
        end
        
        local attempts = {}
        local function addAttempt(fn) table.insert(attempts, fn) end
        
        if name then addAttempt(function() return rf:InvokeServer(name) end) end
        if id then addAttempt(function() return rf:InvokeServer(id) end) end
        if lower then addAttempt(function() return rf:InvokeServer(lower) end) end
        if name then
            addAttempt(function() return rf:InvokeServer({ Name = name }) end)
            addAttempt(function() return rf:InvokeServer({ name = name }) end)
            addAttempt(function() return rf:InvokeServer({ Weather = name }) end)
            addAttempt(function() return rf:InvokeServer({ weather = name }) end)
        end
        if id then
            addAttempt(function() return rf:InvokeServer({ Id = id }) end)
            addAttempt(function() return rf:InvokeServer({ id = id }) end)
        end
        if name then
            addAttempt(function() return rf:InvokeServer("Purchase", name) end)
            addAttempt(function() return rf:InvokeServer("Purchase", { Name = name }) end)
        end
        
        -- Try all attempts
        for _, attempt in ipairs(attempts) do
            local success, result = pcall(attempt)
            if success and result then
                return true
            end
        end
        
        return false
    end
    
    -- ====== UI ELEMENTS ======
    -- Section: Auto Buy Weather
    Automation:Section({ Title = "Auto Buy Weather" })
    
    -- Weather selection dropdown (multiple choice)
    local weatherDropdownInitialized = false
    Automation:Dropdown({ 
        Title = "Select Weather Events to Buy",
        Values = weatherNames, 
        Multi = true,
        AllowNone = true,
        Default = {},
        Callback = function(selectedWeathers)
            weatherState.selectedList = selectedWeathers or {}
            
            -- Only show notification after initial setup to avoid startup spam
            if weatherDropdownInitialized then
                local count = #weatherState.selectedList
                if count > 0 then
                    local weatherList = table.concat(weatherState.selectedList, ", ")
                    pcall(function() UI:Notify({ 
                        Title = "🔄 Auto Weather List Updated", 
                        Content = "✅ Now monitoring: " .. weatherList .. "\n📋 Total: " .. count .. " weather events\n⚡ Changes applied immediately!", 
                        Duration = 4, 
                        Icon = "cloud" 
                    }) end)
                else
                    pcall(function() UI:Notify({ 
                        Title = "⚠️ Auto Weather List Updated", 
                        Content = "❌ No weather events selected!\n🛑 Auto Weather will not purchase anything\n💡 Please select at least one weather event to continue", 
                        Duration = 4, 
                        Icon = "alert-triangle" 
                    }) end)
                end
            else
                weatherDropdownInitialized = true
            end
        end 
    })
    
    -- Auto buy weather toggle
    Automation:Toggle({
        Title = "Enable Auto Buy Weather",
        Default = weatherState.enabled or false,
        Callback = function(value)
            weatherState.enabled = value
            if value then
                -- Check if any weather is selected
                if #weatherState.selectedList == 0 then
                    pcall(function() UI:Notify({ Title = "No Selection", Content = "Please select at least one weather event first", Duration = 3, Icon = "alert-triangle" }) end)
                    weatherState.enabled = false
                    return
                end
                pcall(function() UI:Notify({ Title = "Auto Weather", Content = "Started monitoring " .. #weatherState.selectedList .. " selected weather events", Duration = 3, Icon = "cloud" }) end)
            else
                pcall(function() UI:Notify({ Title = "Auto Weather", Content = "Stopped auto buying weather events", Duration = 3, Icon = "cloud" }) end)
            end
        end
    })
    
    -- Weather monitoring loop
    task.spawn(function()
        while task.wait(1) do
            if not weatherState.enabled then continue end
            if #weatherState.selectedList == 0 then continue end
            
            local currentTime = os.time()
            
            -- Check each selected weather
            for _, weatherName in ipairs(weatherState.selectedList) do
                if not weatherState.enabled then break end
                
                -- Check cooldown for this specific weather
                local lastTime = weatherState.lastPurchaseTime[weatherName] or 0
                local effectiveCooldown = weatherState.purchaseCooldown
                
                if currentTime - lastTime >= effectiveCooldown then
                    -- Attempt purchase directly; server will reject if not available
                    local ok = attemptPurchaseWeather(weatherName)
                    if ok then
                        weatherState.lastPurchaseTime[weatherName] = currentTime
                        pcall(function() UI:Notify({ Title = "Weather Purchased", Content = "Purchased: " .. weatherName, Duration = 2, Icon = "cloud" }) end)
                    else
                        -- Failed: shorten cooldown slightly to retry soon
                        weatherState.lastPurchaseTime[weatherName] = currentTime - math.floor(effectiveCooldown/3)
                    end
                    task.wait(0.3)
                end
            end
        end
    end)
    
    -- ====== AUTO FAVORITE (from DZ Fish It [V2].lua) ======
    -- Helper function to get network folder (if not available in scope)
    local function getAutoFavoriteNetFolder()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local packages = replicatedStorage:WaitForChild("Packages", 10)
        if not packages then return nil end
        
        local index = packages:FindFirstChild("_Index")
        if not index then return nil end
        
        for _, child in ipairs(index:GetChildren()) do
            if child.Name:match("^sleitnick_net@") then
                local netFolder = child:FindFirstChild("net")
                if netFolder then
                    return netFolder
                end
            end
        end
        return nil
    end
    
    -- Helper function to get controllers (if not available in scope)
    local function getAutoFavoriteSafeRequire(pathTbl)
        local ptr = game:GetService("ReplicatedStorage")
        for _, seg in ipairs(pathTbl) do
            ptr = ptr:FindFirstChild(seg)
            if not ptr then return nil end
        end
        local ok, mod = pcall(require, ptr)
        return ok and mod or nil
    end
    
    -- Initialize controllers and utilities for Auto Favorite
    local autoFavoriteReplion = getAutoFavoriteSafeRequire({"Packages","Replion"}) or getAutoFavoriteSafeRequire({"Packages","replion"})
    local autoFavoriteItemUtility = getAutoFavoriteSafeRequire({"Shared","ItemUtility"})
    
    -- Tier resolution function from DZv1.lua (more accurate than simple mapping)
    local function resolveTier(base)
        if not base or not base.Data then return nil, nil end
        local data = base.Data
        local t = data.Tier
        local name = data.TierName or data.RarityName or data.Rarity or data.RankName or data.Rank

        local num
        if typeof(t) == "number" then
            num = t
        elseif typeof(t) == "string" then
            local lower = string.lower(t)
            if lower == "epic" then num = 4; name = "Epic"
            elseif lower == "legendary" or lower == "legend" then num = 5; name = "Legendary"
            elseif lower == "mythic" then num = 6; name = "Mythic"
            elseif lower == "secret" or lower == "secretfish" or lower == "secret_" then num = 7; name = "Secret"
            else
                local tn = tonumber(t)
                if tn then num = tn end
            end
        end

        -- Normalize name to canonical form
        if name then
            local lower = string.lower(name)
            if lower == "epic" then name = "Epic"
            elseif lower == "legendary" or lower == "legend" then name = "Legendary"
            elseif lower == "mythic" then name = "Mythic"
            elseif lower == "secret" or lower == "secretfish" or lower == "secret_" then name = "Secret"
            end
        end

        return num, name
    end
    
    -- Auto Favorite state
    local autoFavoriteState = {
        enabled = false,
        selectedTiers = {},
        loop = nil
    }
    
    -- Auto Favorite functions (using DZv1.lua tier detection system)
    local function startAutoFavorite()
        if autoFavoriteState.loop then task.cancel(autoFavoriteState.loop) end
        autoFavoriteState.loop = task.spawn(function()
            while autoFavoriteState.enabled do
                pcall(function()
                    if not autoFavoriteReplion or not autoFavoriteItemUtility then 
                        return 
                    end
                    
                    local netFolder = getAutoFavoriteNetFolder()
                    local favoriteRemote = netFolder and netFolder:FindFirstChild("RE/FavoriteItem")
                    if not favoriteRemote then 
                        return 
                    end

                    local DataReplion = autoFavoriteReplion.Client:WaitReplion("Data")
                    local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                    if type(items) ~= "table" then 
                        return 
                    end
                    
                    -- Read current tier configuration from autoFavoriteState (always fresh)
                    local currentFavoriteTiers = { [4]=false, [5]=false, [6]=false, [7]=false }
                    local currentFavoriteTierNames = { Epic=false, Legendary=false, Mythic=false, Secret=false }
                    
                    -- Update from current autoFavoriteState.selectedTiers
                    for tierName, _ in pairs(autoFavoriteState.selectedTiers) do
                        if tierName == "Epic" then 
                            currentFavoriteTiers[4] = true; currentFavoriteTierNames.Epic = true
                        elseif tierName == "Legendary" then 
                            currentFavoriteTiers[5] = true; currentFavoriteTierNames.Legendary = true
                        elseif tierName == "Mythic" then 
                            currentFavoriteTiers[6] = true; currentFavoriteTierNames.Mythic = true
                        elseif tierName == "Secret" then 
                            currentFavoriteTiers[7] = true; currentFavoriteTierNames.Secret = true
                        end
                    end
                    
                    local favoritedCount = 0
                    for _, item in ipairs(items) do
                        local base = autoFavoriteItemUtility:GetItemData(item.Id)
                        local tierOk = false
                        local num, name = resolveTier(base)
                        
                        if num and currentFavoriteTiers[num] then
                            tierOk = true
                        elseif name then
                            -- Case-insensitive check against current configuration
                            if currentFavoriteTierNames[name] then
                                tierOk = true
                            else
                                local lower = string.lower(name)
                                if (lower == "epic" and currentFavoriteTierNames.Epic)
                                    or (lower == "legendary" and currentFavoriteTierNames.Legendary)
                                    or (lower == "mythic" and currentFavoriteTierNames.Mythic)
                                    or (lower == "secret" and currentFavoriteTierNames.Secret) then
                                    tierOk = true
                                end
                            end
                        end

                        if tierOk and not item.Favorited then
                            favoriteRemote:FireServer(item.UUID)
                            item.Favorited = true
                            favoritedCount = favoritedCount + 1
                            
                            -- Show notification for each favorited item
                            pcall(function() 
                                UI:Notify({ 
                                    Title = "❤️ Auto Favorite", 
                                    Content = "Favorited " .. (name or "Tier " .. tostring(num)) .. " fish!", 
                                    Duration = 2, 
                                    Icon = "heart" 
                                }) 
                            end)
                        end
                    end
                end)
                task.wait(5)
            end
        end)
    end

    local function stopAutoFavorite()
        if autoFavoriteState.loop then task.cancel(autoFavoriteState.loop); autoFavoriteState.loop = nil end
    end
    
    -- ====== UI ELEMENTS ======
    -- Section: Auto Favorite
    Automation:Section({ Title = "Auto Favorite" })
    
    -- Auto Favorite dropdown with startup notification prevention
    local autoFavoriteDropdownInitialized = false
    -- Convert autoFavoriteState.selectedTiers dari object ke array untuk Default
    local autoFavoriteDefaultTiers = {}
    for tierName, _ in pairs(autoFavoriteState.selectedTiers) do
        table.insert(autoFavoriteDefaultTiers, tierName)
    end
    if #autoFavoriteDefaultTiers == 0 then
        autoFavoriteDefaultTiers = {"Mythic", "Secret"}  -- Default jika tidak ada yang tersimpan
    end
    Automation:Dropdown({
        Title = "Select Fish Tiers",
        Desc = "Choose which tiers to auto-favorite",
        Values = {"Epic", "Legendary", "Mythic", "Secret"},
        Multi = true,
        Default = autoFavoriteDefaultTiers,
        Callback = function(selected)
            -- Clear previous selections
            autoFavoriteState.selectedTiers = {}
            -- Set new selections
            for _, tierName in ipairs(selected) do
                autoFavoriteState.selectedTiers[tierName] = true
            end
            
            -- Only show notification after initial setup to avoid startup spam
            if autoFavoriteDropdownInitialized then
                local tierText = table.concat(selected, ", ")
                pcall(function() UI:Notify({ Title = "Auto Favorite", Content = string.format("Selected tiers: %s", tierText), Duration = 2, Icon = "heart" }) end)
            else
                autoFavoriteDropdownInitialized = true
            end
        end
    })
    
    local autoFavoriteToggle = Automation:Toggle({
        Title = "Auto Favorite",
        Desc = "Automatically favorite fish of selected tiers in your inventory",
        Default = autoFavoriteState.enabled or false,
        Callback = function(value)
            -- Check if any tiers are selected
            local hasSelection = false
            for _, _ in pairs(autoFavoriteState.selectedTiers) do
                hasSelection = true
                break
            end
            
            if value and not hasSelection then
                pcall(function() UI:Notify({ Title = "Auto Favorite", Content = "Please select at least one tier first!", Duration = 3, Icon = "alert-triangle" }) end)
                return
            end
            
            autoFavoriteState.enabled = value
            if value then
                startAutoFavorite()
                local tierList = {}
                for tierName, _ in pairs(autoFavoriteState.selectedTiers) do
                    table.insert(tierList, tierName)
                end
                local tierText = table.concat(tierList, ", ")
                pcall(function() UI:Notify({ Title = "Auto Favorite", Content = string.format("Started auto-favoriting %s fish", tierText), Duration = 3, Icon = "heart" }) end)
            else
                stopAutoFavorite()
                pcall(function() UI:Notify({ Title = "Auto Favorite", Content = "Stopped auto-favoriting", Duration = 2, Icon = "heart" }) end)
            end
        end
    })
    
    end)  -- End pcall for Automation tab
    
    -------------------------------------------
    ----- =======[ PLAYER TAB CONTENT ]
    -------------------------------------------
    pcall(function()
        local Humanoid
        local function getHumanoid()
            local char = player.Character or player.CharacterAdded:Wait()
            return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
        end
        
        -- Initialize player feature states
        if not playerSettings then
            playerSettings = {}
        end
        playerSettings.walkOnWater = playerSettings.walkOnWater or false
        playerSettings.godMode = playerSettings.godMode or false
        playerSettings.noClip = playerSettings.noClip or false
        playerSettings.flyEnabled = playerSettings.flyEnabled or false
        playerSettings.flySpeed = playerSettings.flySpeed or 50
        playerSettings.infiniteJump = playerSettings.infiniteJump or false
        
        -- ===== GOD MODE =====
        local function GodMode()
            task.spawn(function()
                while playerSettings.godMode do
                    pcall(function()
                        local char = player.Character
                        if char then
                            for _, part in pairs(char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.Health = hum.MaxHealth
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
        
        -- ===== FLY SYSTEM =====
        local flyBodyVelocity = nil
        local function Fly()
            task.spawn(function()
                -- Clean up old BodyVelocity if exists
                if flyBodyVelocity then
                    pcall(function() flyBodyVelocity:Destroy() end)
                    flyBodyVelocity = nil
                end
                
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                flyBodyVelocity.Parent = hrp

                while playerSettings.flyEnabled do
                    pcall(function()
                        char = player.Character
                        if char then
                            hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                -- Recreate BodyVelocity if it was destroyed (e.g., on respawn)
                                if not flyBodyVelocity or not flyBodyVelocity.Parent then
                                    flyBodyVelocity = Instance.new("BodyVelocity")
                                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                                    flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                                    flyBodyVelocity.Parent = hrp
                                end
                                
                                local camera = workspace.CurrentCamera
                                local moveDirection = Vector3.new(0, 0, 0)
                                
                                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                    moveDirection = moveDirection + camera.CFrame.LookVector
                                end
                                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                    moveDirection = moveDirection - camera.CFrame.LookVector
                                end
                                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                    moveDirection = moveDirection - camera.CFrame.RightVector
                                end
                                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                    moveDirection = moveDirection + camera.CFrame.RightVector
                                end
                                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                                end
                                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                                end
                                
                                flyBodyVelocity.Velocity = moveDirection * playerSettings.flySpeed
                            end
                        end
                    end)
                    task.wait()
                end
                
                if flyBodyVelocity then
                    pcall(function() flyBodyVelocity:Destroy() end)
                    flyBodyVelocity = nil
                end
            end)
        end
        
        -- ===== WALK ON WATER =====
        local function WalkOnWater()
            task.spawn(function()
                while playerSettings.walkOnWater do
                    pcall(function()
                        local char = player.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local ray = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
                                local part, position = workspace:FindPartOnRay(ray, char)
                                
                                if part and part.Name == "Water" then
                                    hrp.CFrame = CFrame.new(hrp.Position.X, position.Y + 3, hrp.Position.Z)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
        
        -- ===== NO CLIP =====
        local function NoClip()
            task.spawn(function()
                while playerSettings.noClip do
                    pcall(function()
                        local char = player.Character
                        if char then
                            for _, part in pairs(char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end

        -- Section: Player
        Player:Section({ Title = "Player" })

        -- Walk Speed Slider (default = current Humanoid speed, max 150)
        local defaultSpeed = 20
        pcall(function()
            local h = getHumanoid()
            if h and typeof(h.WalkSpeed) == "number" then
                defaultSpeed = math.clamp(h.WalkSpeed, 10, 150)
            end
        end)
        local walkSpeedSlider = Player:Slider({
            Title = "Walk Speed",
            Value = { Min = 10, Max = 150, Default = defaultSpeed },
            Step = 1,
            Callback = function(value)
                pcall(function()
                    Humanoid = Humanoid or getHumanoid()
                    if Humanoid then Humanoid.WalkSpeed = tonumber(value) or 20 end
                end)
            end
        })
        
        -- Store reference for config sync
        walkSpeedSliderRef = walkSpeedSlider

        -- Sync slider/default when player respawns and restart features
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            pcall(function()
                Humanoid = getHumanoid()
                if Humanoid then
                    local current = math.clamp(Humanoid.WalkSpeed or 20, 10, 150)
                    -- Update UI slider if WindUI returns handle with Set()
                    if walkSpeedSlider and type(walkSpeedSlider) == "table" and walkSpeedSlider.Set then
                        pcall(function() walkSpeedSlider:Set(current) end)
                    end
                end
                
                -- Restart features if enabled
                if playerSettings.walkOnWater then
                    task.wait(0.5)
                    WalkOnWater()
                end
                if playerSettings.godMode then
                    task.wait(0.5)
                    GodMode()
                end
                if playerSettings.noClip then
                    task.wait(0.5)
                    NoClip()
                end
                if playerSettings.flyEnabled then
                    task.wait(0.5)
                    Fly()
                end
            end)
        end)

        -- Infinity Jump (Toggle)
        local infJumpConn
        local function startInfiniteJump()
            if infJumpConn then return end
            local uis = game:GetService("UserInputService")
            infJumpConn = uis.JumpRequest:Connect(function()
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        local function stopInfiniteJump()
            if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
        end
        local infiniteJumpToggle = Player:Toggle({ Title = "Infinity Jump", Callback = function(v)
            playerSettings.infiniteJump = v
            if v then startInfiniteJump() else stopInfiniteJump() end
        end })
        
        -- Store reference for config sync
        infiniteJumpToggleRef = infiniteJumpToggle
        
        -- Walk On Water Toggle
        Player:Toggle({ Title = "Walk On Water", Callback = function(v)
            playerSettings.walkOnWater = v
            if v then
                WalkOnWater()
                pcall(function() UI:Notify({ Title = "Walk On Water", Content = "Enabled", Duration = 2, Icon = "circle-check" }) end)
            else
                pcall(function() UI:Notify({ Title = "Walk On Water", Content = "Disabled", Duration = 2, Icon = "circle-check" }) end)
            end
        end })
        
        -- God Mode Toggle
        Player:Toggle({ Title = "God Mode", Callback = function(v)
            playerSettings.godMode = v
            if v then
                GodMode()
                pcall(function() UI:Notify({ Title = "God Mode", Content = "You are immortal", Duration = 3, Icon = "shield-check" }) end)
            else
                pcall(function() UI:Notify({ Title = "God Mode", Content = "Disabled", Duration = 2, Icon = "shield-off" }) end)
            end
        end })
        
        -- NoClip Toggle
        Player:Toggle({ Title = "NoClip", Callback = function(v)
            playerSettings.noClip = v
            if v then
                NoClip()
                pcall(function() UI:Notify({ Title = "NoClip", Content = "Enabled", Duration = 2, Icon = "circle-check" }) end)
            else
                pcall(function() UI:Notify({ Title = "NoClip", Content = "Disabled", Duration = 2, Icon = "circle-check" }) end)
            end
        end })
        
        -- Fly Toggle
        Player:Toggle({ Title = "Fly Mode", Callback = function(v)
            playerSettings.flyEnabled = v
            if v then
                Fly()
                pcall(function() UI:Notify({ Title = "Fly Enabled", Content = "Use WASD + Space/Shift", Duration = 3, Icon = "wind" }) end)
            else
                pcall(function() UI:Notify({ Title = "Fly Disabled", Content = "Fly mode turned off", Duration = 2, Icon = "wind" }) end)
            end
        end })
        
        -- Fly Speed Slider
        Player:Slider({
            Title = "Fly Speed",
            Value = { Min = 10, Max = 300, Default = playerSettings.flySpeed or 50 },
            Step = 5,
            Callback = function(value)
                playerSettings.flySpeed = tonumber(value) or 50
            end
        })

        -- Infinity Oxygen (Auto Active without toggle)
        do
            local oxyConn, oxyLoop
            local function removeOxygen()
                local char = player.Character or player.CharacterAdded:Wait()
                local oxy = char and char:FindFirstChild("Oxygen")
                if oxy then
                    pcall(function()
                        if oxy:IsA("NumberValue") then
                            oxy.Value = 999
                        end
                        oxy:Destroy()
                    end)
                end
            end
            local function startInfinityOxygen()
                removeOxygen()
                if typeof(hookmetamethod) == "function" and typeof(newcclosure) == "function" and typeof(getnamecallmethod) == "function" then
                    if not _G.__DZ_OXY_HOOK then
                        local old
                        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                            local method = getnamecallmethod()
                            if _G.__DZ_OXY_BLOCK and method == "FireServer" and tostring(self) == "URE/UpdateOxygen" then
                                return nil
                            end
                            return old(self, ...)
                        end))
                        _G.__DZ_OXY_HOOK = true
                    end
                    _G.__DZ_OXY_BLOCK = true
                end
                if not oxyConn then
                    oxyConn = player.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        removeOxygen()
                    end)
                end
                if not oxyLoop then
                    oxyLoop = task.spawn(function()
                        while true do
                            removeOxygen()
                            task.wait(1)
                        end
                    end)
                end
            end
            startInfinityOxygen()
        end
        -- Show auto-active status for Oxygen
        pcall(function()
            Player:Paragraph({ Title = "Infinity Oxygen", Desc = "Auto Active", Locked = true })
        end)

        -- Section: Other
        Player:Section({ Title = "Other" })
        -- Show auto-active status for Anti AFK
        pcall(function()
            Player:Paragraph({ Title = "Anti AFK", Desc = "Auto Active", Locked = true })
        end)

        Player:Button({ Title = "Reload Character", Callback = function()
            local char = player.Character
            if char then char:BreakJoints() end
        end })

        -- Anti AFK (Auto Active) - copied behavior style from DZ v1
        do
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
            end
            startAntiAfk()
        end
    end)  -- End pcall for Player tab

    -------------------------------------------
    ----- =======[ TELEPORT TAB CONTENT ]
    -------------------------------------------
    pcall(function()
    
    -- Section: Teleport to Island
    Teleport:Section({ Title = "Teleport to Island" })
    
    -- Island list from DZv1.lua
    local ISLAND_LIST = {
        ["Spawn"] = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1),
        ["Esoteric Depths"] = CFrame.new(3305.368652, -1302.854858, 1365.837891, -0.511237919, 0.000000011, 0.859439254, -0.000000001, 1.000000000, -0.000000013, -0.859439254, -0.000000007, -0.511237919),
        ["Tropical Grove"] = CFrame.new(-2129.893799, 53.487057, 3637.102783, -0.845159769, 0.000000045, 0.534513772, 0.000000074, 1.000000000, 0.000000033, -0.534513772, 0.000000067, -0.845159769),
        ["Fisherman Island"] = CFrame.new(-125.152237, 41.590912, 2778.003174, -0.032748587, -0.000000028, -0.999463618, 0.000000053, 1.000000000, -0.000000029, 0.999463618, -0.000000054, -0.032748587),
        ["Kohana Volcano"] = CFrame.new(-634.026978, 20.632376, 69.626549, -0.650928199, -0.000000001, 0.759139299, 0.000000087, 1.000000000, 0.000000076, -0.759139299, 0.000000116, -0.650928199),
        ["Coral Reefs"] = CFrame.new(-3023.17, 2.52, 2257.24),
        ["Crater Island"] = CFrame.new(1040.245483, 55.546593, 5130.437012, 0.545946598, -0.000000054, 0.837819993, 0.000000051, 1.000000000, 0.000000032, -0.837819993, 0.000000025, 0.545946598),
        ["Kohana"] = CFrame.new(-661.773926, 17.250059, 528.240417, 0.233442247, 0.000000008, -0.972370684, -0.000000005, 1.000000000, 0.000000007, 0.972370684, 0.000000003, 0.233442247),
        ["Winter Fest"] = CFrame.new(1822.619629, 5.788595, 3305.499756, -0.246590868, 0.000000004, -0.969119668, 0.000000006, 1.000000000, 0.000000003, 0.969119668, -0.000000006, -0.246590868),
        ["Isoteric Island"] = CFrame.new(2006.510620, 66.041183, 1320.606689, 0.306930453, 0.000000004, 0.951731920, -0.000000008, 1.000000000, -0.000000001, -0.951731920, -0.000000008, 0.306930453),
        ["Weather Machine"] = CFrame.new(-1572.540161, 13.189098, 1922.284668, -0.734644592, 0.000000019, -0.678452134, -0.000000026, 1.000000000, 0.000000056, 0.678452134, 0.000000058, -0.734644592),
        ["Lost Isle [Angler Rod Place]"] = CFrame.new(-3791.82, -147.91, -1349.01),
        ["Lost Isle [Sisyphus]"] = CFrame.new(-3740.087646, -135.074417, -1008.828186, -0.978001833, 0.000000010, -0.208596319, -0.000000002, 1.000000000, 0.000000060, 0.208596319, 0.000000059, -0.978001833),
        ["Lost Isle [Treasure Hall]"] = CFrame.new(-3602.10058594, -301.06118774, -1391.27075195, 0.99908674, 0.00000000, 0.04272813, 0.02892785, 0.73596364, -0.67640281, -0.03144635, 0.67702109, 0.73529148),
        ["Lost Isle [Treasure Room]"] = CFrame.new(-3597.357422, -275.690308, -1640.757080, 0.988502026, -0.000000017, -0.151207641, 0.000000013, 1.000000000, -0.000000030, 0.151207641, 0.000000027, 0.988502026),
        -- Ancient Jungle locations
        ["Ancient Jungle"] = CFrame.new(1240.061279, 7.969697, -130.555573, -0.820564866, -0.000000049, 0.571553349, -0.000000036, 1.000000000, 0.000000034, -0.571553349, 0.000000007, -0.820564866),
        ["Ancient Jungle [Underground Cellar]"] = CFrame.new(2135.051514, -91.198586, -699.229248, 0.998994410, -0.000000002, -0.044834353, 0.000000001, 1.000000000, -0.000000027, 0.044834353, 0.000000027, 0.998994410),
        ["Ancient Jungle [Ancient Jungle]"] = CFrame.new(1550.018921, 4.375005, -649.877197, -0.372331232, 0.000000107, 0.928099930, 0.000000028, 1.000000000, -0.000000104, -0.928099930, -0.000000013, -0.372331232),
        ["Ancient Jungle [Temple Guardian]"] = CFrame.new(1481.594238, 127.624969, -573.970886, 0.979235291, -0.000000083, 0.202727064, 0.000000091, 1.000000000, -0.000000029, -0.202727064, 0.000000047, 0.979235291),
        -- Hallowen
        ["Haloween [Mount Hallow]"] = CFrame.new(2164.519531, 79.073654, 3322.441406, 0.730568051, 0.000000071, 0.682839870, -0.000000102, 1.000000000, 0.000000006, -0.682839870, -0.000000074, 0.730568051),
        -- Crystal Cavern
        ["Crystal Cavern"] = CFrame.new(-1956.419556, -440.000519, 7385.981934, 0.017274188, 0.000000071, 0.999850810, 0.000000081, 1.000000000, -0.000000072, -0.999850810, 0.000000083, 0.017274188)
    }
    
    -- Get island names for dropdown
    local islandNames = {}
    for name, _ in pairs(ISLAND_LIST) do
        table.insert(islandNames, name)
    end
    table.sort(islandNames)
    
    -- Flag to prevent auto-teleport on first load
    local isInitializingIslandDropdown = true
    
    Teleport:Dropdown({ 
        Title = "Select Island", 
        Values = islandNames,
        Value = islandNames[1],
        Callback = function(choice)
            -- Skip teleport if still initializing (first load)
            if isInitializingIslandDropdown then
                return
            end
            
            if choice and ISLAND_LIST[choice] then
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = ISLAND_LIST[choice]
                        pcall(function() UI:Notify({ Title = "Teleport", Content = "Teleported to " .. choice, Duration = 2, Icon = "map" }) end)
                    end
                end)
            end
        end 
    })
    
    -- Reset flag after dropdown is created (non-blocking)
    task.spawn(function()
        task.wait(0.1)
        isInitializingIslandDropdown = false
    end)
    
    -- Section: Teleport to Player
    Teleport:Section({ Title = "Teleport to Player" })
    
    local selectedPlayer
    local playerDropdown
    local isInitializingPlayerDropdown = true
    
    -- Function to update player dropdown
    local function updatePlayerDropdown()
        local players = Players:GetPlayers()
        local playerNames = {}
        
        for _, otherPlayer in ipairs(players) do
            if otherPlayer ~= player then
                table.insert(playerNames, otherPlayer.Name)
            end
        end
        
        table.sort(playerNames)
        
        -- Update dropdown if it exists
        if playerDropdown and playerDropdown.SetValues then
            isInitializingPlayerDropdown = true
            playerDropdown:SetValues(playerNames)
            if #playerNames > 0 then
                playerDropdown:Set(playerNames[1])
                selectedPlayer = playerNames[1]
            end
            -- Reset flag after a short delay to allow dropdown to initialize
            task.spawn(function()
                task.wait(0.1)
                isInitializingPlayerDropdown = false
            end)
        end
    end
    
    -- Create player dropdown
    local function createPlayerDropdown()
        local players = Players:GetPlayers()
        local playerNames = {}
        
        for _, otherPlayer in ipairs(players) do
            if otherPlayer ~= player then
                table.insert(playerNames, otherPlayer.Name)
            end
        end
        
        table.sort(playerNames)
        
        if #playerNames > 0 then
            selectedPlayer = playerNames[1]
        end
        
        playerDropdown = Teleport:Dropdown({ 
            Title = "Select Player", 
            Values = playerNames,
            Value = playerNames[1] or "No Players",
            Callback = function(choice)
                selectedPlayer = choice
                -- Skip teleport if still initializing (first load)
                if isInitializingPlayerDropdown then
                    return
                end
                
                if choice and choice ~= "No Players" then
                    pcall(function()
                        local targetPlayer = Players:FindFirstChild(choice)
                        if targetPlayer then
                            local targetChar = targetPlayer.Character
                            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                local char = player.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame
                                    pcall(function() UI:Notify({ Title = "Teleport", Content = "Teleported to " .. choice, Duration = 2, Icon = "map" }) end)
                                end
                            else
                                pcall(function() UI:Notify({ Title = "Teleport", Content = "Player " .. choice .. " character not found", Duration = 2, Icon = "alert-triangle" }) end)
                            end
                        else
                            pcall(function() UI:Notify({ Title = "Teleport", Content = "Player " .. choice .. " not found", Duration = 2, Icon = "alert-triangle" }) end)
                        end
                    end)
                end
            end
        })
    end
    
    -- Reset flag after dropdown is created (non-blocking)
    task.spawn(function()
        task.wait(0.1)
        isInitializingPlayerDropdown = false
    end)
    
    -- Create refresh player list button
    Teleport:Button({ 
        Title = "Refresh Player List", 
        Callback = function()
            updatePlayerDropdown()
            local playerCount = #Players:GetPlayers() - 1 -- Exclude self
            pcall(function() UI:Notify({ Title = "Player List", Content = string.format("Refreshed! Found %d players", playerCount), Duration = 2, Icon = "refresh-cw" }) end)
        end 
    })
    
    -- Update player list when players join/leave
    Players.PlayerAdded:Connect(function()
        task.wait(0.1)
        updatePlayerDropdown()
    end)
    
    Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        updatePlayerDropdown()
    end)
    
    -- Initial player dropdown
    createPlayerDropdown()
    
    end)  -- End pcall for Teleport tab
    
end

-- Start the script
main()

