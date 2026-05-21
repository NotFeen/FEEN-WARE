print("Featherware Ultimate Loaded!")

local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local cam = workspace.CurrentCamera
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

local ui 
local mainFrame
local kitFrame 

local kitTranslations = {
    ["SPIRIT_GARDENER"] = "Grove", ["BLOOD_ASSASSIN"] = "Caitlyn", ["SHIELDER"] = "Infernal Shielder",
    ["PINATA"] = "Lucia", ["CACTUS"] = "Martin", ["DRAGON_SLAYER"] = "Kaliyah", ["FROST_HAMMER_KIT"] = "Adetunde",
    ["NECROMANCER"] = "Crypt", ["BIGMAN"] = "Eldertree", ["SPIRIT_ASSASSIN"] = "Evelynn", ["ICE_QUEEN"] = "Freiya",
    ["SWORD_SHIELD"] = "Isabel", ["SUMMONER"] = "Kaida", ["COWGIRL"] = "Lassy", ["FLOWER_BEE"] = "Lyla",
    ["DEFENDER"] = "Marcel", ["JELLYFISH"] = "Marina", ["OASIS"] = "Nahla", ["BERSERKER"] = "Ragnar",
    ["REBELLION_LEADER"] = "Silas", ["VOID_HUNTER"] = "Skoll", ["ANGEL"] = "Trinity", ["TRIPLE_SHOT"] = "Vanessa",
    ["OWL"] = "Whisper", ["BLACK_MARKET_TRADER"] = "Wren", ["DASHER"] = "Yuzi", ["DISRUPTOR"] = "Zenith",
    ["WIZARD"] = "Zeno", ["FALCONER"] = "Bekzat", ["BATTERY"] = "Cobalt", ["VESTA"] = "Conqueror",
    ["BEAST"] = "Crocowolf", ["QUEEN_BEE"] = "Flora", ["GHOST_CATCHER"] = "Gompy", ["TINKER"] = "Hepaestus",
    ["PALADIN"] = "Lani", ["MIDNIGHT"] = "Nyx", ["HATTER"] = "Umbra", ["JAILOR"] = "Warden", ["MAGE"] = "Whim",
    ["VOID_DRAGON"] = "Xur'ot", ["SCARAB"] = "Abaddon", ["SPIDER_QUEEN"] = "Arachne", ["SORCERER"] = "Death Adder",
    ["WARLOCK"] = "Eldric", ["GLACIAL_SKATER"] = "Krystal", ["DRAGON_SWORD"] = "Lian", ["SKELETON"] = "Marrow",
    ["MIMIC"] = "Milo", ["AIRBENDER"] = "Ramil", ["SEAHORSE"] = "Sheila", ["ELK_MASTER"] = "Sigrid",
    ["WINTER_LADY"] = "Sophia", ["HARPOON"] = "Triton", ["VOID_WALKER"] = "Trixie", ["SPIRIT_SUMMONER"] = "Uma",
    ["REGENT"] = "Void Regent", ["GUN_BLADE"] = "Zarrah", ["SOUL_BROKER"] = "Zola", ["SPEARMAN"] = "Ares",
    ["STEAM_ENGINEER"] = "Cogsworth", ["CARD"] = "Fortuna", ["OIL_MAN"] = "Jack", ["SLIME_TAMER"] = "Noelle",
    ["BLOCK_KICKER"] = "Terra", ["NINJA"] = "Umeko", ["CAT"] = "Yamini", ["WIND_WALKER"] = "Zephyr"
}

-- STATE TRACKING
local isRunning = true
local tutorialActive = true 
local isDraggingSlider = false
local tracked = {}
local sharedKATarget = nil 

-- DYNAMIC TEAM BED CHECKER
local function isMyTeamBed(bedObj)
    if not bedObj then return false end
    local myTeam = localPlayer.Team
    
    if myTeam and myTeam.TeamColor then
        local myColor = myTeam.TeamColor
        local blanket = bedObj:FindFirstChild("Blanket") or bedObj:FindFirstChild("blanket")
        if not blanket and bedObj.Parent then
            blanket = bedObj.Parent:FindFirstChild("Blanket") or bedObj.Parent:FindFirstChild("blanket")
        end
        if blanket and blanket:IsA("BasePart") then
            if blanket.BrickColor == myColor or blanket.Color == myColor.Color then return true end
        end
    end

    local myTeamId = localPlayer:GetAttribute("Team") or localPlayer:GetAttribute("team")
    if not myTeamId and myTeam then
        myTeamId = myTeam:GetAttribute("id") or myTeam:GetAttribute("TeamId") or myTeam.Name:match("%d+")
    end
    
    if myTeamId then
        local myTeamStr = tostring(myTeamId):lower()
        local attrName = "Team" .. myTeamStr .. "NoBreak"
        if bedObj:GetAttribute(attrName) == true then return true end
        if bedObj.Parent and bedObj.Parent:GetAttribute(attrName) == true then return true end
    end
    
    local bedTeamId = bedObj:GetAttribute("TeamId") or (bedObj.Parent and bedObj.Parent:GetAttribute("TeamId"))
    if not bedTeamId then
        local bedId = bedObj:GetAttribute("Id") or bedObj:GetAttribute("id") or (bedObj.Parent and (bedObj.Parent:GetAttribute("Id") or bedObj.Parent:GetAttribute("id")))
        if bedId then
            local parts = tostring(bedId):split("_")
            bedTeamId = parts[1]
        end
    end
    
    if bedTeamId then
        local cleanTeamId = tostring(bedTeamId):lower()
        if myTeam then
            local myTeamName = myTeam.Name:lower()
            if myTeamName == cleanTeamId or myTeamName:find(cleanTeamId) or cleanTeamId:find(myTeamName) then return true end
        end
        if myTeamId and tostring(myTeamId):lower() == cleanTeamId then return true end
    end
    return false
end

local defaultToggles = {
    ["BoxESP"] = false, ["Chams"] = false, ["ShowName"] = false, ["ShowTeam"] = false, ["ShowKit"] = false, ["ShowHealth"] = false, 
    ["KitRender"] = false, ["KitRenderOwnTeam"] = true, 
    ["MetalESP"] = false, ["StarESP"] = false, ["BeeESP"] = false, ["CrateESP"] = false, ["ElderESP"] = false, ["OreESP"] = false,
    ["FarmESP"] = false, ["BeehiveESP"] = false, ["TaliyahESP"] = false, ["BedESP"] = false,
    ["Trails"] = false, ["TrailRainbow"] = false, ["TrailBall"] = false,
    ["ArmorTrims"] = false, ["TrimType"] = "Trim 1", ["TrimMaterial"] = "Neon", ["TrimTrans"] = 0, ["TrimR"] = 255, ["TrimG"] = 255, ["TrimB"] = 255,
    ["AntiAFK"] = false, ["Freecam"] = false, ["FreecamSpeed"] = 2, 
    ["SpinBot"] = false, ["SpinSpeed"] = 20, ["VoidJump"] = false, 
    ["Fly"] = false, ["FlySpeed"] = 20, ["InfJump"] = false, ["HighJump"] = false, ["Sprint"] = false,
    ["Speed"] = false, ["SpeedValue"] = 23, ["WallClimb"] = false, ["WallClimbSpeed"] = 40,
    ["KA"] = false, ["KASpeed"] = 0.1, ["KARange"] = 28, ["KAAngle"] = 360, ["KAAutoEquip"] = false,
    ["KAWallCheck"] = false, ["KASwingAnim"] = false, ["KASwingSpeed"] = 1.0, ["KASwingRange"] = 43,
    ["KAStrafe"] = false, ["KAStrafeRadius"] = 10, ["KAStrafeSpeed"] = 15, ["KAStrafeMode"] = "Circle",
    ["KAStrafeSafe"] = true,
    ["KATargetPlayer"] = true, ["KATargetNPC"] = false, ["KATargetDummy"] = false, ["KAPriority"] = "Distance",
    ["AimTargetPlayer"] = true, ["AimTargetNPC"] = false, ["AimTargetDummy"] = false, ["AimTrackKA"] = false,
    ["AimAssist"] = false, ["AimSpeed"] = 50, ["AimRange"] = 100, ["AimPart"] = "Head",
    ["AimTeamCheck"] = true, ["AimWallCheck"] = true, ["AimReqSword"] = false,
    ["Velocity"] = false, ["VelocityH"] = 0, ["VelocityV"] = 0,
    ["FastBreak"] = false, ["FastBreakTimer"] = 0.05,
    ["Nuker"] = false, ["NukerTimer"] = 0.1, ["NukerReqPickaxe"] = true, ["NukerReqAxe"] = false, ["NukerReqShears"] = false, ["NukerBed"] = true, ["NukerTesla"] = false, ["NukerTeamTesla"] = false, ["NukerOre"] = false, ["NukerPriority"] = "Bed", ["NukerHighlight"] = false,
    ["AutoBuy"] = false, ["AutoBuyArmor"] = true, ["AutoBuySword"] = true, ["AutoBuyPriority"] = "Balanced", ["AutoBuyRange"] = 30,
    ["AutoHammer"] = false, ["HammerP1"] = "Strength", ["HammerP2"] = "Speed", ["HammerP3"] = "Shield", ["HammerDist"] = "3-2-2 (Max All)",
    ["TimeOfDay"] = false, ["TimeValue"] = 12,
    ["DisableClouds"] = false, ["CloudTransparency"] = 0, ["CloudColorPreset"] = "White",
    ["Spectate"] = false, ["SpectateTarget"] = "",
    ["NoFall"] = false,
    ["ExtendedDrop"] = false, ["ExtendedDropRange"] = 20,
    ["StaffDetect"] = false, ["StaffLeave"] = false, ["StaffDestruct"] = false,
    ["FOVChanger"] = false, ["FOVValue"] = 90, ["Fullbright"] = false,
    ["MenuKey"] = "RightShift", ["MenuTransparency"] = 0.15, ["MenuScale"] = 1.0,
    ["KillMessage"] = false, ["KillMsgText"] = "GG {display}!", ["KillMsgDelay"] = 3.5,
}

local toggles = {}
for k, v in pairs(defaultToggles) do toggles[k] = v end

local hotkeys = {}
local uiVisuals = {} 
local boxTargetMode = "All"
local farmFilter = "Everything"
local expandedTeams = {}
local expandedStates = {} 
local uiVisible = true
local connections = {}
local currentBindName = nil
local flyBodyVel = nil
local lastJumpTick = 0

-- DYNAMIC REMOTE HANDLER
local function fireRemote(remote, ...)
    local args = {...}
    if remote then
        if remote:IsA("RemoteEvent") then 
            remote:FireServer(unpack(args))
        elseif remote:IsA("RemoteFunction") then 
            pcall(function() remote:InvokeServer(unpack(args)) end) 
        end
    end
end

local function getDamageBlockRemote()
    local remote = ReplicatedStorage:FindFirstChild("rbxts_include")
    if remote then remote = remote:FindFirstChild("node_modules") end
    if remote then remote = remote:FindFirstChild("@easy-games") end
    if remote then remote = remote:FindFirstChild("block-engine") end
    if remote then remote = remote:FindFirstChild("node_modules") end
    if remote then remote = remote:FindFirstChild("@rbxts") end
    if remote then remote = remote:FindFirstChild("net") end
    if remote then remote = remote:FindFirstChild("out") end
    if remote then remote = remote:FindFirstChild("_NetManaged") end
    if remote then remote = remote:FindFirstChild("DamageBlock") end
    return remote
end

local function getPurchaseRemote()
    local rem = ReplicatedStorage:FindFirstChild("rbxts_include")
    if rem then rem = rem.node_modules:FindFirstChild("@rbxts") end
    if rem then rem = rem.net.out._NetManaged:FindFirstChild("BedwarsPurchaseItem") end
    return rem
end

local function getEquipRemote()
    local rem = ReplicatedStorage:FindFirstChild("rbxts_include")
    if rem then rem = rem.node_modules:FindFirstChild("@rbxts") end
    if rem then rem = rem.net.out._NetManaged:FindFirstChild("SetArmorInvItem") end
    return rem
end

-- HELPER FOR SWORD GRABBING
local function getSwordFrom(folder)
    if not folder then return nil end
    local priorityWeapons = {"emerald_sword", "diamond_sword", "iron_sword", "stone_sword", "wood_sword", "rageblade", "emerald_dao", "diamond_dao", "iron_dao", "stone_dao", "wood_dao", "emerald_scythe", "diamond_scythe", "iron_scythe", "stone_scythe", "wood_scythe", "emerald_dagger", "diamond_dagger", "iron_dagger", "stone_dagger", "wood_dagger", "frosty_hammer", "katana", "weapon"}
    for _, sName in ipairs(priorityWeapons) do
        local w = folder:FindFirstChild(sName)
        if w then return w end
    end
    for _, item in ipairs(folder:GetChildren()) do
        local n = item.Name:lower()
        if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("hammer") or n:find("katana") or n:find("weapon") then
            return item
        end
    end
    return nil
end

local function updateClouds()
    local cloudsFolder = workspace:FindFirstChild("Clouds")
    if cloudsFolder then
        for _, obj in ipairs(cloudsFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                if toggles.DisableClouds then
                    obj.Transparency = 1
                else
                    obj.Transparency = tonumber(toggles.CloudTransparency) or 0
                end
                local colorPreset = toggles.CloudColorPreset or "White"
                if colorPreset == "White" then obj.Color = Color3.fromRGB(255, 255, 255)
                elseif colorPreset == "Grey" then obj.Color = Color3.fromRGB(120, 120, 120)
                elseif colorPreset == "Pink" then obj.Color = Color3.fromRGB(255, 180, 200)
                elseif colorPreset == "Violet" then obj.Color = Color3.fromRGB(180, 130, 255)
                elseif colorPreset == "Gold" then obj.Color = Color3.fromRGB(255, 215, 0)
                elseif colorPreset == "Red" then obj.Color = Color3.fromRGB(255, 100, 100) end
            end
        end
    end
end

local function applyVelocityMod(v)
    if toggles.Velocity and (v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("BodyModifier")) and v.Name ~= "FlyVelocity" then
        local h = (tonumber(toggles.VelocityH) or 0) / 100
        local y = (tonumber(toggles.VelocityV) or 0) / 100
        if h == 0 and y == 0 then
            task.defer(function() pcall(function() v:Destroy() end) end)
        else
            task.spawn(function()
                task.wait(0.01)
                if v and v.Parent then
                    if v:IsA("BodyVelocity") then v.Velocity = Vector3.new(v.Velocity.X * h, v.Velocity.Y * y, v.Velocity.Z * h)
                    elseif v:IsA("LinearVelocity") then v.VectorVelocity = Vector3.new(v.VectorVelocity.X * h, v.VectorVelocity.Y * y, v.VectorVelocity.Z * h)
                    elseif v:IsA("VectorForce") then v.Force = Vector3.new(v.Force.X * h, v.Force.Y * y, v.Force.Z * h) end
                end
            end)
        end
    end
end

local function hookVelocity(characterRoot)
    if not characterRoot then return end
    characterRoot.ChildAdded:Connect(applyVelocityMod)
end

localPlayer.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    hookVelocity(hrp)

    if toggles.KAAutoEquip then
        task.spawn(function()
            task.wait(1.5)
            local invFolder = ReplicatedStorage:FindFirstChild("Inventories") or ReplicatedStorage:FindFirstChild("inventories")
            local myInv = invFolder and invFolder:FindFirstChild(localPlayer.Name)
            local bestWep = getSwordFrom(myInv)
            if bestWep then
                local net = ReplicatedStorage:FindFirstChild("rbxts_include")
                if net then net = net:FindFirstChild("node_modules") end
                if net then net = net:FindFirstChild("@rbxts") end
                if net then net = net:FindFirstChild("net") end
                if net then net = net:FindFirstChild("out") end
                if net then net = net:FindFirstChild("_NetManaged") end
                local equipRemote = net and net:FindFirstChild("SetInvItem")
                if equipRemote then pcall(function() equipRemote:FireServer({["item"] = bestWep}) end) end
            end
        end)
    end
end)
if character and character:FindFirstChild("HumanoidRootPart") then hookVelocity(character.HumanoidRootPart) end

local currentAccent = Color3.fromRGB(139, 92, 246)
local function saveConfig()
    local cfg = { t = toggles, h = {}, btm = boxTargetMode, ff = farmFilter, acc = {currentAccent.R, currentAccent.G, currentAccent.B}, exp = expandedStates }
    for k, v in pairs(hotkeys) do 
        if v and v.Name then cfg.h[k] = v.Name end 
    end
    if type(writefile) == "function" then pcall(function() writefile("featherware_cfg.json", HttpService:JSONEncode(cfg)) end) end
end

local function loadConfig()
    if type(readfile) == "function" and type(isfile) == "function" and isfile("featherware_cfg.json") then
        local s, res = pcall(function() return HttpService:JSONDecode(readfile("featherware_cfg.json")) end)
        if s and type(res) == "table" then
            if res.t then for k, v in pairs(res.t) do toggles[k] = v end end
            if res.h then 
                for k, v in pairs(res.h) do 
                    pcall(function() hotkeys[k] = Enum.KeyCode[v] end) 
                end 
            end
            if res.btm then boxTargetMode = res.btm end
            if res.ff then farmFilter = res.ff end
            if res.exp then expandedStates = res.exp end
            if res.acc then pcall(function() currentAccent = Color3.new(res.acc[1], res.acc[2], res.acc[3]) end) end
        end
    end
end

table.insert(connections, Players.PlayerRemoving:Connect(function(plr)
    if plr == localPlayer then saveConfig() end
end))

local function leaveParty()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local remote = rs:WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty")
        fireRemote(remote)
    end)
end

local function uninject() 
    isRunning = false
    saveConfig()
    for k, v in pairs(toggles) do if type(v) == "boolean" then toggles[k] = false end end
    for _, c in pairs(connections) do c:Disconnect() end
    for o, _ in pairs(tracked) do 
        if tracked[o] and tracked[o].gui then tracked[o].gui:Destroy() end
        if tracked[o] and tracked[o].info then tracked[o].info:Destroy() end
        if tracked[o] and tracked[o].highlight then tracked[o].highlight:Destroy() end 
        if tracked[o] and tracked[o].chams then tracked[o].chams:Destroy() end
    end
    if flyBodyVel then flyBodyVel:Destroy() end
    if cam.CameraType == Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Custom end
    local char = localPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 16; hum.AutoRotate = true end
    if ui then ui:Destroy() end
end

local staffRoles = { ["Anticheat Mod"] = true, ["Anticheat Manager"] = true, ["Owner"] = true }
local function checkStaff(plr)
    if not toggles.StaffDetect then return end
    task.spawn(function()
        local s, role = pcall(function() return plr:GetRoleInGroup(5774246) end)
        if s and staffRoles[role] then
            if toggles.StaffLeave then leaveParty() end
            if toggles.StaffDestruct then uninject() end
        end
    end)
end
Players.PlayerAdded:Connect(checkStaff)

local function handleStaffScan()
    if toggles.StaffDetect then for _, p in pairs(Players:GetPlayers()) do checkStaff(p) end end
end

-- ==========================================
-- CYBERPUNK TERMINAL UI LIBRARY
-- ==========================================
local coreGui = gethui and gethui() or game.CoreGui
if coreGui:FindFirstChild("FEATHERWARE_ULTIMATE") then coreGui.FEATHERWARE_ULTIMATE:Destroy() end

ui = Instance.new("ScreenGui", coreGui)
ui.Name = "FEATHERWARE_ULTIMATE"
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true 

local uiScale = Instance.new("UIScale", ui)
uiScale.Scale = toggles.MenuScale or 1.0

local c_bg = Color3.fromRGB(10, 10, 12)
local c_sidebar = Color3.fromRGB(15, 15, 18)
local c_element = Color3.fromRGB(22, 22, 26)
local c_hover = Color3.fromRGB(30, 30, 35)
local c_text = Color3.fromRGB(230, 230, 230)
local c_textMuted = Color3.fromRGB(120, 120, 130)
local accentObjects = {}
local searchableItems = {}

local function setAccent(color)
    currentAccent = color
    for obj, prop in pairs(accentObjects) do
        if obj and obj.Parent then TweenService:Create(obj, TweenInfo.new(0.3), {[prop] = color}):Play() end
    end
end

local function addCorner(val, p) 
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, val) 
end

local function makeDraggable(f, h)
    local d, ds, sp
    table.insert(connections, h.InputBegan:Connect(function(i) 
        if tutorialActive then return end 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            d = true; ds = i.Position; sp = f.Position 
        end 
    end))
    table.insert(connections, UIS.InputChanged:Connect(function(i) 
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local del = i.Position - ds; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + (del.X / uiScale.Scale), sp.Y.Scale, sp.Y.Offset + (del.Y / uiScale.Scale)) 
        end 
    end))
    table.insert(connections, UIS.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end 
    end))
end

local tooltipFrame = Instance.new("Frame", ui)
tooltipFrame.BackgroundColor3 = c_sidebar
tooltipFrame.Visible = false
tooltipFrame.ZIndex = 100
addCorner(2, tooltipFrame)

local ttStroke = Instance.new("UIStroke", tooltipFrame)
ttStroke.Color = currentAccent
accentObjects[ttStroke] = "Color"

local ttLabel = Instance.new("TextLabel", tooltipFrame)
ttLabel.BackgroundTransparency = 1
ttLabel.TextColor3 = c_text
ttLabel.Font = Enum.Font.Gotham
ttLabel.TextSize = 12
ttLabel.ZIndex = 101
ttLabel.TextXAlignment = Enum.TextXAlignment.Left
ttLabel.TextYAlignment = Enum.TextYAlignment.Top

table.insert(connections, RunService.RenderStepped:Connect(function()
    if tooltipFrame.Visible then
        if isDraggingSlider then tooltipFrame.Position = UDim2.new(2, 0, 2, 0); return end
        local mPos = UIS:GetMouseLocation()
        tooltipFrame.Position = UDim2.new(0, (mPos.X / uiScale.Scale) + 15, 0, (mPos.Y / uiScale.Scale) - 20)
        ttLabel.TextWrapped = false
        ttLabel.Size = UDim2.new(0, 1000, 0, 20)
        local bounds = ttLabel.TextBounds
        local targetWidth = bounds.X
        if targetWidth > 250 then targetWidth = 250; ttLabel.TextWrapped = true end
        ttLabel.Size = UDim2.new(0, targetWidth, 0, 1000)
        local targetHeight = ttLabel.TextBounds.Y
        ttLabel.Size = UDim2.new(0, targetWidth, 0, targetHeight)
        ttLabel.Position = UDim2.new(0, 10, 0, 6)
        tooltipFrame.Size = UDim2.new(0, targetWidth + 20, 0, targetHeight + 12)
    end
end))

local function attachTooltip(element, desc)
    if not desc or desc == "" then return end
    element.MouseEnter:Connect(function() 
        if isDraggingSlider then return end
        ttLabel.Text = desc; tooltipFrame.Visible = true 
    end)
    element.MouseLeave:Connect(function() tooltipFrame.Visible = false end)
end

local notifHolder = Instance.new("Frame", ui)
notifHolder.Size = UDim2.new(0, 250, 1, -50)
notifHolder.Position = UDim2.new(1, -260, 0, 0)
notifHolder.BackgroundTransparency = 1
notifHolder.ZIndex = 50
local notifLayout = Instance.new("UIListLayout", notifHolder)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 10)

local function notify(title, state)
    local wrapper = Instance.new("Frame", notifHolder)
    wrapper.Size = UDim2.new(1, 0, 0, 40)
    wrapper.BackgroundTransparency = 1
    
    local f = Instance.new("Frame", wrapper)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.Position = UDim2.new(0, 50, 0, 0)
    f.BackgroundColor3 = c_sidebar
    f.BackgroundTransparency = 0.1
    f.ZIndex = 51
    addCorner(2, f)
    
    local accentBar = Instance.new("Frame", f)
    accentBar.Size = UDim2.new(0, 3, 1, -10)
    accentBar.Position = UDim2.new(0, 5, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = state and currentAccent or Color3.fromRGB(239, 68, 68)
    accentBar.BorderSizePixel = 0
    addCorner(1, accentBar)
    if state then accentObjects[accentBar] = "BackgroundColor3" end
    
    local s = Instance.new("UIStroke", f)
    s.Color = Color3.fromRGB(45, 45, 50)
    s.Transparency = 0
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -20, 1, 0)
    t.Position = UDim2.new(0, 15, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = "> " .. title
    t.TextColor3 = c_text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTransparency = 1
    t.ZIndex = 52
    
    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    task.delay(2.5, function()
        if wrapper.Parent then
            TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, 50, 0, 0), BackgroundTransparency = 1}):Play()
            TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            wrapper:Destroy()
        end
    end)
end

do -- [UI BUILDER START] 
    mainFrame = Instance.new("Frame", ui)
    mainFrame.Size = UDim2.new(0, 560, 0, 400) 
    mainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
    mainFrame.BackgroundColor3 = c_bg
    mainFrame.BackgroundTransparency = toggles.MenuTransparency
    mainFrame.ClipsDescendants = true
    addCorner(2, mainFrame)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = currentAccent
    mainStroke.Thickness = 1
    accentObjects[mainStroke] = "Color"
    makeDraggable(mainFrame, mainFrame)

    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 140, 1, 0)
    sidebar.BackgroundColor3 = c_sidebar
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", sidebar)
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "[ FEATHERWARE ]"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = currentAccent
    accentObjects[titleLabel] = "TextColor3"

    local tabContainer = Instance.new("Frame", sidebar)
    tabContainer.Size = UDim2.new(1, 0, 1, -50)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local contentWrapper = Instance.new("Frame", mainFrame)
    contentWrapper.Size = UDim2.new(1, -140, 1, 0)
    contentWrapper.Position = UDim2.new(0, 140, 0, 0)
    contentWrapper.BackgroundTransparency = 1

    local topbar = Instance.new("Frame", contentWrapper)
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundTransparency = 1

    local searchBox = Instance.new("TextBox", topbar)
    searchBox.Size = UDim2.new(0.92, 0, 0, 26)
    searchBox.Position = UDim2.new(0.04, 0, 0.5, -13)
    searchBox.BackgroundColor3 = c_element
    searchBox.PlaceholderText = "> Search parameters..."
    searchBox.Text = ""
    searchBox.TextColor3 = c_text
    searchBox.PlaceholderColor3 = c_textMuted
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    addCorner(2, searchBox)
    local sPad = Instance.new("UIPadding", searchBox)
    sPad.PaddingLeft = UDim.new(0, 10)
    local searchStroke = Instance.new("UIStroke", searchBox)
    searchStroke.Color = Color3.fromRGB(45, 45, 50)

    local contentContainer = Instance.new("Frame", contentWrapper)
    contentContainer.Size = UDim2.new(1, 0, 1, -45)
    contentContainer.Position = UDim2.new(0, 0, 0, 45)
    contentContainer.BackgroundTransparency = 1

    local activeTab = nil
    local tabs = {}

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower()
        for _, item in ipairs(searchableItems) do
            if q == "" then 
                item.element.Visible = true
            else
                if item.name:find(q) then 
                    item.element.Visible = true
                    if item.parentCategory then item.parentCategory(true) end
                else item.element.Visible = false end
            end
        end
    end)

    local function createTab(name)
        local tabBtn = Instance.new("TextButton", tabContainer)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 30)
        tabBtn.BackgroundColor3 = c_element
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = name:upper()
        tabBtn.TextColor3 = c_textMuted
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 11
        addCorner(2, tabBtn)

        local tabContent = Instance.new("ScrollingFrame", contentContainer)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 1
        tabContent.ScrollBarImageColor3 = currentAccent
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        accentObjects[tabContent] = "ScrollBarImageColor3"

        local contentLayout = Instance.new("UIListLayout", tabContent)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local cPad = Instance.new("UIPadding", tabContent)
        cPad.PaddingTop = UDim.new(0, 2); cPad.PaddingBottom = UDim.new(0, 20)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)

        tabBtn.MouseButton1Down:Connect(function()
            for _, t in pairs(tabs) do
                TweenService:Create(t.btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = c_textMuted}):Play()
                t.content.Visible = false
            end
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, TextColor3 = currentAccent}):Play()
            tabContent.Visible = true
            activeTab = name
            searchBox.Text = ""
        end)

        table.insert(tabs, {btn = tabBtn, content = tabContent})
        if not activeTab then 
            tabBtn.BackgroundTransparency = 0.5; tabBtn.TextColor3 = currentAccent; tabContent.Visible = true; activeTab = name 
        end

        return tabContent
    end

    local function MakeExpandableCategory(parent, titleText)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(0.94, 0, 0, 30)
        container.BackgroundColor3 = c_sidebar
        container.BackgroundTransparency = 0.2
        container.ClipsDescendants = true
        addCorner(2, container)
        local catStroke = Instance.new("UIStroke", container); catStroke.Color = Color3.fromRGB(35, 35, 40)

        local header = Instance.new("TextButton", container)
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundTransparency = 1
        header.Text = ""

        local lbl = Instance.new("TextLabel", header)
        lbl.Size = UDim2.new(1, -30, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "// " .. titleText:upper()
        lbl.TextColor3 = c_textMuted
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local arrow = Instance.new("TextLabel", header)
        arrow.Size = UDim2.new(0, 30, 1, 0)
        arrow.Position = UDim2.new(1, -30, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "+"
        arrow.TextColor3 = c_textMuted
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 14

        local content = Instance.new("Frame", container)
        content.Size = UDim2.new(1, 0, 1, -30)
        content.Position = UDim2.new(0, 0, 0, 30)
        content.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", content)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", content); pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)

        local expanded = expandedStates[titleText] or false

        local function setExpanded(state, instant)
            expanded = state
            expandedStates[titleText] = state
            arrow.Text = expanded and "-" or "+"
            arrow.TextColor3 = expanded and currentAccent or c_textMuted
            lbl.TextColor3 = expanded and c_text or c_textMuted

            local targetHeight = expanded and (30 + layout.AbsoluteContentSize.Y + 8) or 30
            if instant then
                container.Size = UDim2.new(0.94, 0, 0, targetHeight)
            else
                TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0.94, 0, 0, targetHeight)}):Play()
            end
            saveConfig()
        end

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if expanded then container.Size = UDim2.new(0.94, 0, 0, 30 + layout.AbsoluteContentSize.Y + 8) end
        end)

        header.MouseButton1Down:Connect(function() setExpanded(not expanded) end)
        if expanded then setExpanded(true, true) end
        
        return content, function(forceOpen) if forceOpen and not expanded then setExpanded(true) end end
    end

    local function MakeToggle(parent, id, titleText, desc, callback, parentExpanderFn, hasSettings)
        local outerFrame = Instance.new("Frame", parent)
        outerFrame.Size = UDim2.new(0.96, 0, 0, 28)
        outerFrame.BackgroundTransparency = 1
        outerFrame.ClipsDescendants = true

        local frame = Instance.new("Frame", outerFrame)
        frame.Size = UDim2.new(1, 0, 0, 28)
        frame.BackgroundColor3 = c_element
        frame.BackgroundTransparency = 0.5
        addCorner(2, frame)

        local triggerBtn = Instance.new("TextButton", frame)
        triggerBtn.Size = UDim2.new(1, -120, 1, 0)
        triggerBtn.BackgroundTransparency = 1
        triggerBtn.Text = ""
        triggerBtn.ZIndex = 5
        attachTooltip(triggerBtn, desc)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "> " .. titleText
        lbl.TextColor3 = c_text
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local kbBtn = Instance.new("TextButton", frame)
        kbBtn.Size = UDim2.new(0, 36, 0, 16)
        kbBtn.Position = UDim2.new(1, hasSettings and -95 or -70, 0.5, -8)
        kbBtn.BackgroundColor3 = c_sidebar
        kbBtn.TextColor3 = c_textMuted
        kbBtn.Text = "[+]"
        kbBtn.Font = Enum.Font.Gotham
        kbBtn.TextSize = 10
        kbBtn.ZIndex = 6
        addCorner(2, kbBtn)
        attachTooltip(kbBtn, "Left click to bind key. Right click to unbind.")

        local function updateKB() kbBtn.Text = hotkeys[id] and "["..hotkeys[id].Name.."]" or "[+]" end
        uiVisuals[id.."_key"] = updateKB
        kbBtn.InputBegan:Connect(function(inp) 
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then hotkeys[id] = nil; updateKB(); saveConfig() end 
        end)
        kbBtn.MouseButton1Down:Connect(function() currentBindName = id; kbBtn.Text = "..." end)
        updateKB()

        local expandBtn = nil
        local settingsContainer = nil
        
        if hasSettings then
            expandBtn = Instance.new("TextButton", frame)
            expandBtn.Size = UDim2.new(0, 20, 0, 16)
            expandBtn.Position = UDim2.new(1, -70, 0.5, -8)
            expandBtn.BackgroundColor3 = c_sidebar
            expandBtn.TextColor3 = c_textMuted
            expandBtn.Text = "v"
            expandBtn.Font = Enum.Font.GothamBold
            expandBtn.TextSize = 10
            expandBtn.ZIndex = 6
            addCorner(2, expandBtn)
            
            settingsContainer = Instance.new("Frame", outerFrame)
            settingsContainer.Position = UDim2.new(0, 10, 0, 30)
            settingsContainer.Size = UDim2.new(1, -10, 0, 0)
            settingsContainer.BackgroundTransparency = 1
            
            local sLayout = Instance.new("UIListLayout", settingsContainer)
            sLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sLayout.Padding = UDim.new(0, 4)
            
            local isExpanded = false
            sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isExpanded then
                    settingsContainer.Size = UDim2.new(1, -10, 0, sLayout.AbsoluteContentSize.Y)
                    outerFrame.Size = UDim2.new(0.96, 0, 0, 28 + sLayout.AbsoluteContentSize.Y + 6)
                end
            end)
            
            expandBtn.MouseButton1Down:Connect(function()
                isExpanded = not isExpanded
                expandBtn.Text = isExpanded and "^" or "v"
                if isExpanded then
                    settingsContainer.Size = UDim2.new(1, -10, 0, sLayout.AbsoluteContentSize.Y)
                    TweenService:Create(outerFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.96, 0, 0, 28 + sLayout.AbsoluteContentSize.Y + 6)}):Play()
                else
                    TweenService:Create(outerFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.96, 0, 0, 28)}):Play()
                end
            end)
        end

        local switchBg = Instance.new("Frame", frame)
        switchBg.Size = UDim2.new(0, 14, 0, 14)
        switchBg.Position = UDim2.new(1, -24, 0.5, -7)
        switchBg.BackgroundColor3 = c_sidebar
        addCorner(2, switchBg)
        local switchStroke = Instance.new("UIStroke", switchBg); switchStroke.Color = Color3.fromRGB(50, 50, 60)

        local knob = Instance.new("Frame", switchBg)
        knob.Size = UDim2.new(0, 8, 0, 8)
        knob.Position = UDim2.new(0.5, -4, 0.5, -4)
        knob.BackgroundColor3 = currentAccent
        knob.BackgroundTransparency = toggles[id] and 0 or 1
        addCorner(1, knob)
        accentObjects[knob] = "BackgroundColor3"

        local function updateVis()
            local state = toggles[id]
            switchStroke.Color = state and currentAccent or Color3.fromRGB(50, 50, 60)
            if state then accentObjects[switchStroke] = "Color" else accentObjects[switchStroke] = nil end
            TweenService:Create(knob, TweenInfo.new(0.15), {BackgroundTransparency = state and 0 or 1}):Play()
            if id == "KitRender" and kitFrame then kitFrame.Visible = (state and uiVisible) end
            if id == "Fullbright" then Lighting.Ambient = state and Color3.new(1,1,1) or Color3.new(0,0,0); Lighting.Brightness = state and 1 or 0.5 end
            if id == "DisableClouds" then updateClouds() end
        end
        
        uiVisuals[id] = updateVis

        triggerBtn.MouseButton1Down:Connect(function()
            toggles[id] = not toggles[id]
            updateVis()
            if type(callback) == "function" then pcall(callback) end
            saveConfig()
        end)
        
        updateVis()
        table.insert(searchableItems, {name = titleText:lower(), element = outerFrame, parentCategory = parentExpanderFn})
        return outerFrame, settingsContainer
    end

    local function MakeSlider(parent, id, titleText, desc, min, max, isFloat, parentExpanderFn)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0.96, 0, 0, 40)
        frame.BackgroundColor3 = c_element
        frame.BackgroundTransparency = 0.5
        addCorner(4, frame)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -20, 0, 18)
        lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = c_text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local sBg = Instance.new("Frame", frame)
        sBg.Size = UDim2.new(1, -20, 0, 4)
        sBg.Position = UDim2.new(0, 10, 0, 26)
        sBg.BackgroundColor3 = c_sidebar
        addCorner(0, sBg)

        local fill = Instance.new("Frame", sBg)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = currentAccent
        addCorner(0, fill)
        accentObjects[fill] = "BackgroundColor3"

        local btn = Instance.new("TextButton", sBg)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 5
        attachTooltip(btn, desc)

        local function updateVis()
            local val = toggles[id] or min
            local pct = math.clamp((val - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            lbl.Text = "> " .. titleText .. " : [" .. (isFloat and string.format("%.2f", val) or val) .. "]"
            if id == "FOVValue" and toggles.FOVChanger then cam.FieldOfView = val end
            if id == "CloudTransparency" then updateClouds() end
            if id == "MenuScale" then uiScale.Scale = val end
            if id == "MenuTransparency" and mainFrame then mainFrame.BackgroundTransparency = val end
        end
        
        uiVisuals[id] = updateVis
        local drag = false
        
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; isDraggingSlider = true; tooltipFrame.Visible = false
                local pct = math.clamp((i.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                local raw = min + ((max - min) * pct)
                toggles[id] = isFloat and raw or math.floor(raw)
                updateVis(); saveConfig()
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false; isDraggingSlider = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local pct = math.clamp((i.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                local raw = min + ((max - min) * pct)
                toggles[id] = isFloat and raw or math.floor(raw)
                updateVis(); saveConfig()
            end
        end)
        btn.MouseButton1Down:Connect(function(x)
            local pct = math.clamp((x - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
            local raw = min + ((max - min) * pct)
            toggles[id] = isFloat and raw or math.floor(raw)
            updateVis(); saveConfig()
        end)

        updateVis()
        table.insert(searchableItems, {name = titleText:lower(), element = frame, parentCategory = parentExpanderFn})
        return frame
    end

    local function MakeTextBox(parent, id, titleText, desc, defaultText, parentExpanderFn)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0.96, 0, 0, 32)
        frame.BackgroundColor3 = c_element
        frame.BackgroundTransparency = 0.5
        addCorner(4, frame)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = c_text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local boxBg = Instance.new("Frame", frame)
        boxBg.Size = UDim2.new(0.55, -10, 0, 20)
        boxBg.Position = UDim2.new(0.45, 0, 0.5, -10)
        boxBg.BackgroundColor3 = c_sidebar
        boxBg.ZIndex = 10
        addCorner(2, boxBg)

        local box = Instance.new("TextBox", boxBg)
        box.Size = UDim2.new(1, -10, 1, 0)
        box.Position = UDim2.new(0, 5, 0, 0)
        box.BackgroundTransparency = 1
        box.TextColor3 = c_textMuted
        box.Font = Enum.Font.Gotham
        box.TextSize = 10
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.ZIndex = 11
        box.Text = toggles[id] or defaultText

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.45, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 5
        attachTooltip(btn, desc)

        local function updateVis()
            lbl.Text = "> " .. titleText
            box.Text = toggles[id] or defaultText
        end
        
        uiVisuals[id] = updateVis

        box.FocusLost:Connect(function()
            toggles[id] = box.Text
            saveConfig()
        end)

        updateVis()
        table.insert(searchableItems, {name = titleText:lower(), element = frame, parentCategory = parentExpanderFn})
        return frame
    end

    local function MakeDropdown(parent, id, titleText, desc, options, parentExpanderFn)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0.96, 0, 0, 32)
        frame.BackgroundColor3 = c_element
        frame.BackgroundTransparency = 0.5
        addCorner(4, frame)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = c_text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 5
        attachTooltip(btn, desc)

        local function updateVis() 
            local currentVal = toggles[id] or options[1]
            lbl.Text = "> " .. titleText .. " : [" .. tostring(currentVal):upper() .. "]"
            if id == "CloudColorPreset" then updateClouds() end
        end
        uiVisuals[id] = updateVis

        btn.MouseButton1Down:Connect(function()
            local current = toggles[id] or options[1]
            local idx = table.find(options, current) or 1
            local nextIdx = idx >= #options and 1 or idx + 1
            toggles[id] = options[nextIdx]
            updateVis(); saveConfig()
        end)
        
        updateVis()
        table.insert(searchableItems, {name = titleText:lower(), element = frame, parentCategory = parentExpanderFn})
        return frame
    end

    local function MakeButton(parent, text, desc, callback, parentExpanderFn)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0.96, 0, 0, 28)
        b.BackgroundColor3 = c_element
        b.BackgroundTransparency = 0.2
        b.TextColor3 = c_text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.Text = "> " .. text
        addCorner(2, b)
        local str = Instance.new("UIStroke", b); str.Color = Color3.fromRGB(40, 40, 45)
        attachTooltip(b, desc)

        b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = c_hover}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = c_element}):Play() end)
        b.MouseButton1Down:Connect(function()
            if type(callback) == "function" then pcall(callback) end
        end)

        table.insert(searchableItems, {name = text:lower(), element = b, parentCategory = parentExpanderFn})
        return b
    end

    local tHub = createTab("Hub")
    local tCombat = createTab("Combat")
    local tMovement = createTab("Movement")
    local tVisuals = createTab("Visuals")
    local tWorld = createTab("World")
    local tUtility = createTab("Utility")
    local tSettings = createTab("Settings")

    local cat, f, set

    -- HUB TAB
    cat, f = MakeExpandableCategory(tHub, "Profile Status")
    local profFrame = Instance.new("Frame", cat)
    profFrame.Size = UDim2.new(0.96, 0, 0, 50)
    profFrame.BackgroundColor3 = c_element
    profFrame.BackgroundTransparency = 0.5
    addCorner(2, profFrame)

    local pName = Instance.new("TextLabel", profFrame)
    pName.Size = UDim2.new(1, -20, 0, 20)
    pName.Position = UDim2.new(0, 10, 0, 5)
    pName.BackgroundTransparency = 1
    pName.Text = "USER: FEATHER"
    pName.TextColor3 = c_text
    pName.Font = Enum.Font.Gotham
    pName.TextSize = 12
    pName.TextXAlignment = Enum.TextXAlignment.Left

    local currentKitTxt = Instance.new("TextLabel", profFrame)
    currentKitTxt.Size = UDim2.new(1, -20, 0, 20)
    currentKitTxt.Position = UDim2.new(0, 10, 0, 25)
    currentKitTxt.BackgroundTransparency = 1
    currentKitTxt.Text = "KIT : SCANNING..."
    currentKitTxt.TextColor3 = currentAccent
    currentKitTxt.Font = Enum.Font.GothamBold
    currentKitTxt.TextSize = 12
    currentKitTxt.TextXAlignment = Enum.TextXAlignment.Left
    accentObjects[currentKitTxt] = "TextColor3"

    task.spawn(function()
        while isRunning do
            task.wait(1)
            local rK = tostring(localPlayer:GetAttribute("PlayingAsKits") or "None"):upper()
            currentKitTxt.Text = "KIT : " .. (kitTranslations[rK] or rK)
            
            if metalEspUI then metalEspUI.Visible = (rK == "TINKER") end
            if elderEspUI then elderEspUI.Visible = (rK == "BIGMAN") end
            if beeEspUI then beeEspUI.Visible = (rK == "FLOWER_BEE" or rK == "QUEEN_BEE") end
            if starEspUI then starEspUI.Visible = (rK == "STAR_COLLECTOR") end
        end
    end)

    -- COMBAT TAB
    cat, f = MakeExpandableCategory(tCombat, "Kill Aura")
    _, set = MakeToggle(cat, "KA", "Toggle Aura", "Attacks enemies in range.", nil, f, true)
    if set then
        MakeSlider(set, "KASpeed", "Hit Delay", "Wait time between hits.", 0.01, 2.0, true, f)
        MakeSlider(set, "KARange", "Hit Range", "Max attack distance.", 5, 28, false, f)
        MakeSlider(set, "KAAngle", "Hit Angle", "FOV requirement.", 10, 360, false, f)
        MakeToggle(set, "KAWallCheck", "Wall Check", "Ignore targets behind walls.", nil, f)
        MakeToggle(set, "KAAutoEquip", "Auto Equip", "Equips best weapon on spawn.", nil, f)
        MakeDropdown(set, "KAPriority", "Target Priority", "Who to attack first.", {"Distance", "Player", "NPC", "Dummy"}, f)
        MakeToggle(set, "KASwingAnim", "Swing Anim", "Visual hit animation.", nil, f)
        MakeSlider(set, "KASwingSpeed", "Anim Speed", "Speed of the swing.", 0.1, 3.0, true, f)
        MakeToggle(set, "KAStrafe", "Auto Strafe", "Circles target automatically.", nil, f)
        MakeToggle(set, "KAStrafeSafe", "Safe Strafe", "Prevents strafing off edges.", nil, f)
        MakeDropdown(set, "KAStrafeMode", "Strafe Mode", "Movement pattern to use.", {"Circle", "Back-and-Forth", "Random Point"}, f)
        MakeSlider(set, "KAStrafeRadius", "Strafe Radius", "Distance from target.", 5, 20, false, f)
        MakeSlider(set, "KAStrafeSpeed", "Strafe Speed", "Orbit rotation speed.", 1, 30, false, f)
        MakeToggle(set, "KATargetPlayer", "Target Players", "Attack players.", nil, f)
        MakeToggle(set, "KATargetNPC", "Target NPCs", "Attack mobs.", nil, f)
        MakeToggle(set, "KATargetDummy", "Target Dummies", "Attack dummies.", nil, f)
    end

    cat, f = MakeExpandableCategory(tCombat, "Aim Assist")
    _, set = MakeToggle(cat, "AimAssist", "Toggle Assist", "Locks camera to target.", nil, f, true)
    if set then
        MakeSlider(set, "AimSpeed", "Smoothness", "Lock-on tracking speed.", 1, 100, false, f)
        MakeSlider(set, "AimRange", "Max Range", "Max targeting distance.", 10, 500, false, f)
        MakeDropdown(set, "AimPart", "Target Part", "Body part to lock onto.", {"Head", "Torso"}, f)
        MakeToggle(set, "AimTeamCheck", "Team Check", "Ignore teammates.", nil, f)
        MakeToggle(set, "AimWallCheck", "Wall Check", "Ignore targets behind walls.", nil, f)
        MakeToggle(set, "AimReqSword", "Require Sword", "Only aim with weapon.", nil, f)
        MakeToggle(set, "AimTargetPlayer", "Target Players", "Lock onto players.", nil, f)
        MakeToggle(set, "AimTargetNPC", "Target NPCs", "Lock onto mobs.", nil, f)
        MakeToggle(set, "AimTargetDummy", "Target Dummies", "Lock onto dummies.", nil, f)
        MakeToggle(set, "AimTrackKA", "Sync Kill Aura", "Lock onto KA target.", nil, f)
    end

    cat, f = MakeExpandableCategory(tCombat, "Velocity Override")
    _, set = MakeToggle(cat, "Velocity", "Anti-Knockback", "Modifies knockback taken.", nil, f, true)
    if set then
        MakeSlider(set, "VelocityH", "Horizontal %", "Horizontal knockback.", 0, 100, false, f)
        MakeSlider(set, "VelocityV", "Vertical %", "Vertical knockback.", 0, 100, false, f)
    end

    -- MOVEMENT TAB
    cat, f = MakeExpandableCategory(tMovement, "Movement Modifiers")
    MakeToggle(cat, "Sprint", "Auto Sprint", "Forces sprint.", nil, f)
    _, set = MakeToggle(cat, "Speed", "Custom Speed", "Modifies walk speed.", nil, f, true)
    if set then MakeSlider(set, "SpeedValue", "Speed Value", "Target speed.", 16, 50, false, f) end
    _, set = MakeToggle(cat, "Fly", "Flight", "Allows air movement.", nil, f, true)
    if set then MakeSlider(set, "FlySpeed", "Flight Speed", "Air speed.", 10, 100, false, f) end

    cat, f = MakeExpandableCategory(tMovement, "Agility Enhancements")
    MakeToggle(cat, "InfJump", "Infinite Jump", "Jump mid-air.", nil, f)
    MakeToggle(cat, "HighJump", "High Jump", "Boosts jump height.", nil, f)
    MakeToggle(cat, "VoidJump", "Void Jump", "Boost out of void.", nil, f)
    MakeToggle(cat, "NoFall", "No Fall Damage", "Spoofs landing state.", nil, f)
    _, set = MakeToggle(cat, "WallClimb", "Spider Climb", "Climb walls.", nil, f, true)
    if set then MakeSlider(set, "WallClimbSpeed", "Climb Speed", "Climb velocity.", 20, 100, false, f) end
    _, set = MakeToggle(cat, "SpinBot", "Spin Bot", "Spins character.", nil, f, true)
    if set then MakeSlider(set, "SpinSpeed", "Spin Speed", "Rotation velocity.", 10, 100, false, f) end

    -- VISUALS TAB
    cat, f = MakeExpandableCategory(tVisuals, "Player ESP")
    MakeToggle(cat, "BoxESP", "Bounding Boxes", "Draws boxes.", nil, f)
    MakeToggle(cat, "Chams", "Chams Highlights", "Wallhack outlines.", nil, f)
    MakeDropdown(cat, "TM", "Target Filter", "Who to render.", {"All", "Enemy", "Teams"}, f)
    MakeToggle(cat, "ShowName", "Show Names", "Display names.", nil, f)
    MakeToggle(cat, "ShowTeam", "Show Teams", "Display teams.", nil, f)
    MakeToggle(cat, "ShowKit", "Show Kits", "Display kits.", nil, f)
    MakeToggle(cat, "ShowHealth", "Show Health", "Display HP.", nil, f)

    cat, f = MakeExpandableCategory(tVisuals, "Environment Modifiers")
    MakeToggle(cat, "KitRender", "Kit Monitor GUI", "Shows an active kit list.", nil, f)
    _, set = MakeToggle(cat, "Freecam", "Freecam", "Invisible fly camera.", nil, f, true)
    if set then MakeSlider(set, "FreecamSpeed", "Camera Speed", "Freecam speed.", 1, 10, false, f) end
    MakeToggle(cat, "Fullbright", "Fullbright", "Removes shadows.", nil, f)
    _, set = MakeToggle(cat, "TimeOfDay", "Custom Time", "Overrides map time.", nil, f, true)
    if set then MakeSlider(set, "TimeValue", "Time Selector", "Hour of day.", 0, 24, true, f) end
    _, set = MakeToggle(cat, "DisableClouds", "Disable Clouds", "Removes map clouds.", updateClouds, f, true)
    if set then
        MakeSlider(set, "CloudTransparency", "Cloud Trans.", "Cloud visibility.", 0, 1, true, f)
        MakeDropdown(set, "CloudColorPreset", "Cloud Color", "Changes cloud color.", {"White", "Grey", "Pink", "Violet", "Gold", "Red"}, f)
    end

    cat, f = MakeExpandableCategory(tVisuals, "Cosmetics")
    _, set = MakeToggle(cat, "Trails", "Movement Trails", "Leaves a trail.", nil, f, true)
    if set then
        MakeToggle(set, "TrailRainbow", "Rainbow Trail", "RGB trail.", nil, f)
        MakeToggle(set, "TrailBall", "Ball Style", "Spherical trail.", nil, f)
    end

    cat, f = MakeExpandableCategory(tVisuals, "Spectator Mode")
    MakeToggle(cat, "Spectate", "Spectate Player", "Locks camera to player.", nil, f)
    MakeButton(cat, "Cycle Spectator", "Next player in server.", function()
        local plrs = Players:GetPlayers()
        if #plrs <= 1 then notify("No other players found", false); return end
        local idx = 1
        for i, p in ipairs(plrs) do if p.Name == toggles.SpectateTarget then idx = i break end end
        idx = idx >= #plrs and 1 or idx + 1
        if plrs[idx] == localPlayer then idx = idx >= #plrs and 1 or idx + 1 end
        toggles.SpectateTarget = plrs[idx].Name
        notify("Spectating: " .. plrs[idx].DisplayName, true)
    end, f)

    -- WORLD TAB
    cat, f = MakeExpandableCategory(tWorld, "Kit Specific ESP")
    metalEspUI = MakeToggle(cat, "MetalESP", "Metal Drops", "Shows Tinkerer metal scrap.", nil, f)
    elderEspUI = MakeToggle(cat, "ElderESP", "Elder Orbs", "Shows TreeOrbs for Eldertree.", nil, f)
    starEspUI = MakeToggle(cat, "StarESP", "Fallen Stars", "Shows spawned Stars.", nil, f)
    beeEspUI = MakeToggle(cat, "BeeESP", "Wild Bees", "Shows spawned bees.", nil, f)

    cat, f = MakeExpandableCategory(tWorld, "General Object ESP")
    MakeToggle(cat, "CrateESP", "Team Crates", "Shows map crates.", nil, f)
    MakeToggle(cat, "OreESP", "Iron Ores", "Shows map ores.", nil, f)
    _, set = MakeToggle(cat, "FarmESP", "Crop ESP", "Shows fully grown crops.", nil, f, true)
    if set then MakeDropdown(set, "FF", "Crop Filter", "Specific crop filter.", {"Everything", "Melon Only", "Carrot Only", "Pumpkin Only"}, f) end
    MakeToggle(cat, "BeehiveESP", "Beehives", "Shows placed beehives.", nil, f)
    MakeToggle(cat, "TaliyahESP", "Taliyah Eggs", "Shows spawned eggs.", nil, f)
    MakeToggle(cat, "BedESP", "Enemy Beds", "Shows enemy beds globally.", nil, f)

    -- UTILITY TAB
    cat, f = MakeExpandableCategory(tUtility, "Block Nuker")
    _, set = MakeToggle(cat, "Nuker", "Enable Nuker", "Destroys blocks in radius.", nil, f, true)
    if set then
        MakeSlider(set, "NukerTimer", "Mining Speed", "Mining delay.", 0.01, 1.0, true, f)
        MakeToggle(set, "NukerBed", "Target Beds", "Prioritize enemy beds.", nil, f)
        MakeToggle(set, "NukerTesla", "Target Teslas", "Mine tesla traps.", nil, f)
        MakeToggle(set, "NukerTeamTesla", "Break Team Teslas", "Allow breaking teammate teslas.", nil, f)
        MakeToggle(set, "NukerOre", "Target Ores", "Prioritize map ores.", nil, f)
        MakeDropdown(set, "NukerPriority", "Priority Logic", "Target preference.", {"Bed", "Tesla", "Ore", "Distance"}, f)
        MakeToggle(set, "NukerHighlight", "Visual Highlight", "Shows mining target.", nil, f)
    end

    _, set = MakeToggle(cat, "FastBreak", "Fast Break", "Instantly breaks clicked blocks.", nil, f, true)
    if set then MakeSlider(set, "FastBreakTimer", "Break Speed", "Fast break delay.", 0.01, 0.5, true, f) end

    cat, f = MakeExpandableCategory(tUtility, "Automation")

    _, set = MakeToggle(cat, "AutoBuy", "Auto Buy", "Automatically buys shop upgrades.", nil, f, true)
    if set then
        MakeToggle(set, "AutoBuyArmor", "Buy Armor", "Includes armor in auto buy.", nil, f)
        MakeToggle(set, "AutoBuySword", "Buy Swords", "Includes swords in auto buy.", nil, f)
        MakeDropdown(set, "AutoBuyPriority", "Priority Path", "Purchase order preference.", {"Balanced", "Armor First", "Swords First"}, f)
        MakeSlider(set, "AutoBuyRange", "Shop Range", "Max distance to buy.", 10, 100, false, f)
    end

    _, set = MakeToggle(cat, "AutoHammer", "Auto Hammer", "Upgrades Frost Hammer automatically.", nil, f, true)
    if set then
        MakeDropdown(set, "HammerP1", "Priority 1", "First stat to max.", {"Strength", "Speed", "Shield"}, f)
        MakeDropdown(set, "HammerP2", "Priority 2", "Second stat to upgrade.", {"Speed", "Strength", "Shield"}, f)
        MakeDropdown(set, "HammerP3", "Priority 3", "Third stat to upgrade.", {"Shield", "Strength", "Speed"}, f)
        MakeDropdown(set, "HammerDist", "Upgrade Path", "How to spend 5 max points.", {"3-2-2 (Max All)", "3-2-0 (Max P1 & P2)", "3-1-1 (Max P1, Min Others)", "2-2-1 (Balanced)"}, f)
    end

    _, set = MakeToggle(cat, "ExtendedDrop", "Item Magnet", "Pulls drops to inventory.", nil, f, true)
    if set then MakeSlider(set, "ExtendedDropRange", "Magnet Range", "Pickup distance.", 10, 50, false, f) end

    _, set = MakeToggle(cat, "KillMessage", "Auto GG", "Send chat msg when enemy dies.", nil, f, true)
    if set then
        MakeTextBox(set, "KillMsgText", "Format", "Use {user} or {display} for names.", "GG {display}!", f)
        MakeSlider(set, "KillMsgDelay", "Spam Delay", "Delay between messages.", 1.0, 10.0, true, f)
    end

    _, set = MakeToggle(cat, "ArmorTrims", "Armor Trims", "Custom colored armor trims.", nil, f, true)
    if set then
        MakeDropdown(set, "TrimType", "Trim Design", "Choose the trim pattern.", {"Trim 1", "Trim 2", "Trim 3", "Trim 4", "Trim 5", "Trim 6", "Trim 7", "Trim 8", "Trim 9", "Trim 10", "Trim 11", "Trim 12"}, f)
        MakeDropdown(set, "TrimMaterial", "Trim Material", "Material of the trim.", {"Neon", "Plastic", "ForceField", "Glass", "Foil"}, f)
        MakeSlider(set, "TrimTrans", "Trim Transparency", "Transparency of trims.", 0, 1, true, f)
        MakeSlider(set, "TrimR", "Trim Color (R)", "Red channel.", 0, 255, false, f)
        MakeSlider(set, "TrimG", "Trim Color (G)", "Green channel.", 0, 255, false, f)
        MakeSlider(set, "TrimB", "Trim Color (B)", "Blue channel.", 0, 255, false, f)
    end

    MakeToggle(cat, "AntiAFK", "Anti-AFK", "Prevents idle kicks.", nil, f)

    -- SETTINGS TAB
    cat, f = MakeExpandableCategory(tSettings, "Interface Configuration")
    MakeSlider(cat, "MenuScale", "UI Scale", "Adjust the size of the interface.", 0.5, 2.0, true, f)
    MakeSlider(cat, "MenuTransparency", "Background Trans.", "Adjust menu visibility.", 0, 1, true, f)

    local colorGrid = Instance.new("Frame", cat)
    colorGrid.Size = UDim2.new(0.92, 0, 0, 40)
    colorGrid.BackgroundTransparency = 1

    local cl = Instance.new("UIListLayout", colorGrid)
    cl.FillDirection = Enum.FillDirection.Horizontal
    cl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cl.VerticalAlignment = Enum.VerticalAlignment.Center
    cl.Padding = UDim.new(0, 10)

    local colors = { Color3.fromRGB(139, 92, 246), Color3.fromRGB(239, 68, 68), Color3.fromRGB(59, 130, 246), Color3.fromRGB(16, 185, 129), Color3.fromRGB(245, 158, 11), Color3.fromRGB(236, 72, 153) }

    for _, col in ipairs(colors) do
        local cb = Instance.new("TextButton", colorGrid)
        cb.Size = UDim2.new(0, 24, 0, 24)
        cb.BackgroundColor3 = col
        cb.Text = ""
        cb.ZIndex = 5
        addCorner(2, cb)
        local cs = Instance.new("UIStroke", cb)
        cs.Color = Color3.new(1,1,1)
        cs.Transparency = 0.8
        cs.Thickness = 1
        cb.MouseButton1Down:Connect(function() setAccent(col); saveConfig() end)
    end

    cat, f = MakeExpandableCategory(tSettings, "Keybinds & Resets")
    local menuKbFrame = Instance.new("Frame", cat)
    menuKbFrame.Size = UDim2.new(0.96, 0, 0, 32)
    menuKbFrame.BackgroundColor3 = c_element
    menuKbFrame.BackgroundTransparency = 0.5
    addCorner(2, menuKbFrame)

    local mKbLbl = Instance.new("TextLabel", menuKbFrame)
    mKbLbl.Size = UDim2.new(0.6, 0, 1, 0)
    mKbLbl.Position = UDim2.new(0, 10, 0, 0)
    mKbLbl.BackgroundTransparency = 1
    mKbLbl.Text = "> Toggle Key"
    mKbLbl.TextColor3 = c_text
    mKbLbl.Font = Enum.Font.Gotham
    mKbLbl.TextSize = 11
    mKbLbl.TextXAlignment = Enum.TextXAlignment.Left

    local mKbBtn = Instance.new("TextButton", menuKbFrame)
    mKbBtn.Size = UDim2.new(0, 80, 0, 18)
    mKbBtn.Position = UDim2.new(1, -90, 0.5, -9)
    mKbBtn.BackgroundColor3 = c_sidebar
    mKbBtn.TextColor3 = currentAccent
    mKbBtn.Font = Enum.Font.GothamBold
    mKbBtn.TextSize = 10
    mKbBtn.ZIndex = 5
    addCorner(2, mKbBtn)
    accentObjects[mKbBtn] = "TextColor3"

    local bindingMenu = false
    mKbBtn.Text = "[" .. (toggles.MenuKey or "RightShift") .. "]"

    mKbBtn.MouseButton1Down:Connect(function() bindingMenu = true; mKbBtn.Text = "..." end)
    attachTooltip(mKbBtn, "Click to rebind the menu toggle key.")

    MakeButton(cat, "Unbind All Hotkeys", "Resets every bound hotkey.", function()
        hotkeys = {}
        for id, fn in pairs(uiVisuals) do if id:find("_key") then pcall(fn) end end
        saveConfig(); notify("HOTKEYS UNBOUND", false)
    end, f)

    MakeButton(cat, "Disable All Toggles", "Turns off every hack.", function()
        for k, v in pairs(toggles) do if type(v) == "boolean" and k ~= "KitRenderOwnTeam" then toggles[k] = false end end
        for id, fn in pairs(uiVisuals) do if type(id) == "string" and not id:find("_key") then pcall(fn) end end
        saveConfig(); notify("TOGGLES DISABLED", false)
    end, f)

    MakeButton(cat, "Uninject", "Removes menu and stops hacks.", function() 
        notify("UNINJECTING FEATHERWARE...", false)
        uninject() 
    end, f)

    cat, f = MakeExpandableCategory(tSettings, "Safety Measures")
    MakeToggle(cat, "StaffDetect", "Staff Radar", "Alerts if a dev joins.", nil, f)
    MakeToggle(cat, "StaffLeave", "Auto-Leave", "Leaves game if staff found.", nil, f)
    MakeToggle(cat, "StaffDestruct", "Auto-Destruct", "Removes menu if staff found.", nil, f)
    MakeButton(cat, "Force Leave Party", "Leaves your current party.", function() 
        notify("LEAVING PARTY...", true)
        leaveParty() 
    end, f)

    if #tabs > 0 then
        TweenService:Create(tabs[1].btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, TextColor3 = currentAccent}):Play()
        tabs[1].content.Visible = true
        activeTab = tabs[1].btn.Text
    end
end -- END UI BUILDER BLOCK

uiVisuals.TM = function() boxTargetMode = toggles.TM or "All" end
uiVisuals.FF = function() farmFilter = toggles.FF or "Everything" end
setAccent(currentAccent)

local tutOverlay = Instance.new("Frame", ui)
tutOverlay.Size = UDim2.new(1, 0, 1, 0)
tutOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
tutOverlay.BackgroundTransparency = 0.5
tutOverlay.ZIndex = 1000

local tutFrame = Instance.new("Frame", tutOverlay)
tutFrame.Size = UDim2.new(0, 450, 0, 280)
tutFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
tutFrame.BackgroundColor3 = c_bg
tutFrame.ClipsDescendants = true
tutFrame.ZIndex = 1001
addCorner(2, tutFrame)

local tutStroke = Instance.new("UIStroke", tutFrame)
tutStroke.Color = currentAccent
tutStroke.Thickness = 1
accentObjects[tutStroke] = "Color"

local tutTitle = Instance.new("TextLabel", tutFrame)
tutTitle.Size = UDim2.new(1, 0, 0, 50)
tutTitle.BackgroundTransparency = 1
tutTitle.Text = "[ FEATHERWARE ULTIMATE ]"
tutTitle.Font = Enum.Font.GothamBold
tutTitle.TextSize = 16
tutTitle.TextColor3 = currentAccent
tutTitle.ZIndex = 1002
accentObjects[tutTitle] = "TextColor3"

local tutText = Instance.new("TextLabel", tutFrame)
tutText.Size = UDim2.new(1, -50, 1, -120)
tutText.Position = UDim2.new(0, 25, 0, 50)
tutText.BackgroundTransparency = 1
tutText.TextColor3 = c_text
tutText.TextWrapped = true
tutText.Font = Enum.Font.Gotham
tutText.TextSize = 12
tutText.TextXAlignment = Enum.TextXAlignment.Left
tutText.TextYAlignment = Enum.TextYAlignment.Top
tutText.ZIndex = 1002

local tutSlides = {
    "> QUICK START GUIDE:\n\n• Press [RightShift] (or your custom Menu Key) to toggle the terminal interface.\n\n• The interface is completely draggable.",
    "> HOTKEYS & CONFIGURATION:\n\n• Left-Click the [+] button next to a module, then press any key to bind.\n\n• Right-Click the same button to unbind.",
    "> TOOLTIPS & AUTOSAVE:\n\n• Hover your cursor over any module to view its exact function.\n\n• All configuration variables are saved locally and seamlessly."
}
local currentSlide = 1
tutText.Text = tutSlides[currentSlide]

local nextBtn = Instance.new("TextButton", tutFrame)
nextBtn.Size = UDim2.new(0, 100, 0, 30)
nextBtn.Position = UDim2.new(1, -125, 1, -45)
nextBtn.BackgroundColor3 = currentAccent
nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = 12
nextBtn.Text = "NEXT >"
nextBtn.ZIndex = 1002
addCorner(2, nextBtn)
accentObjects[nextBtn] = "BackgroundColor3"

local skipBtn = Instance.new("TextButton", tutFrame)
skipBtn.Size = UDim2.new(0, 100, 0, 30)
skipBtn.Position = UDim2.new(0, 25, 1, -45)
skipBtn.BackgroundColor3 = c_element
skipBtn.TextColor3 = c_textMuted
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextSize = 12
skipBtn.Text = "SKIP"
skipBtn.ZIndex = 1002
addCorner(2, skipBtn)

local function closeTutorial()
    tutOverlay:Destroy()
    tutorialActive = false
end

nextBtn.MouseButton1Click:Connect(function()
    if currentSlide < #tutSlides then
        currentSlide = currentSlide + 1
        tutText.Text = tutSlides[currentSlide]
        if currentSlide == #tutSlides then 
            nextBtn.Text = "FINISH" 
        end
    else
        closeTutorial()
    end
end)

skipBtn.MouseButton1Click:Connect(closeTutorial)

table.insert(connections, UIS.InputBegan:Connect(function(input, g)
    if currentBindName then
        local keyName = input.KeyCode.Name
        if keyName ~= "Unknown" then
            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Delete then
                hotkeys[currentBindName] = nil
                notify("UNBOUND HOTKEY", false)
            else
                local conflictId = nil
                for id, boundKey in pairs(hotkeys) do
                    if boundKey == input.KeyCode and id ~= currentBindName then 
                        conflictId = id 
                        break 
                    end
                end
                if conflictId then 
                    notify("KEY ALREADY BOUND", false)
                else 
                    hotkeys[currentBindName] = input.KeyCode
                    notify("BOUND TO [" .. keyName .. "]", true) 
                end
            end
            local temp = currentBindName
            currentBindName = nil
            if uiVisuals[temp.."_key"] then 
                pcall(uiVisuals[temp.."_key"]) 
            end
            saveConfig()
        end
        return
    end

    if bindingMenu then
        local keyName = input.KeyCode.Name
        if keyName ~= "Unknown" then
            toggles.MenuKey = keyName
            mKbBtn.Text = "[" .. keyName .. "]"
            bindingMenu = false
            saveConfig()
            notify("MENU KEY SET TO " .. keyName, true)
        end
        return
    end

    if g or UIS:GetFocusedTextBox() then return end

    local targetKey = toggles.MenuKey or "RightShift"
    if input.KeyCode.Name == targetKey then
        uiVisible = not uiVisible
        if mainFrame then mainFrame.Visible = uiVisible end
        if toggles.KitRender and kitFrame then 
            kitFrame.Visible = uiVisible 
        end
    end

    for id, k in pairs(hotkeys) do
        if input.KeyCode == k then
            toggles[id] = not toggles[id]
            if uiVisuals[id] then 
                pcall(uiVisuals[id]) 
            end
            local cleanName = string.gsub(id, "ESP", " ESP")
            notify(string.upper(cleanName) .. (toggles[id] and " ENABLED" or " DISABLED"), toggles[id])
            saveConfig()
        end
    end

    if input.KeyCode == Enum.KeyCode.Space then
        lastJumpTick = tick()
        local char = localPlayer.Character
        local locHrp = char and char:FindFirstChild("HumanoidRootPart")
        if locHrp then
            if toggles.InfJump then 
                locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 40, locHrp.Velocity.Z) 
            end
            if toggles.HighJump then 
                locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 100, locHrp.Velocity.Z) 
            end
        end
    end
end))

local strafeAngle = 0
local lastRandomStrafe = 0
local targetStrafeAngle = 0

table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    dt = typeof(dt) == "number" and dt or 0.016
    if not isRunning then return end

    local char = localPlayer.Character
    local locHrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if toggles.Velocity and locHrp and hum then
        local h = (tonumber(toggles.VelocityH) or 0) / 100
        local y = (tonumber(toggles.VelocityV) or 0) / 100
        local currentVel = locHrp.AssemblyLinearVelocity
        local isMovingIntentionally = (hum.MoveDirection.Magnitude > 0) or toggles.Fly or toggles.Freecam
        
        local targetY = currentVel.Y
        local isIntentionallyVertical = toggles.Fly or toggles.Freecam or UIS:IsKeyDown(Enum.KeyCode.Space) or (toggles.WallClimb and UIS:IsKeyDown(Enum.KeyCode.W)) or (tick() - lastJumpTick < 0.6)
        
        if not isIntentionallyVertical and currentVel.Y > 0 then
            targetY = currentVel.Y * y
        end
        
        if not isMovingIntentionally then
            locHrp.AssemblyLinearVelocity = Vector3.new(currentVel.X * h, targetY, currentVel.Z * h)
        else
            local expectedMax = hum.WalkSpeed + 5
            local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
            if horizontalVel.Magnitude > expectedMax then
                local excess = horizontalVel.Magnitude - expectedMax
                local scaledH = horizontalVel.Unit * (expectedMax + excess * h)
                locHrp.AssemblyLinearVelocity = Vector3.new(scaledH.X, targetY, scaledH.Z)
            else
                locHrp.AssemblyLinearVelocity = Vector3.new(currentVel.X, targetY, currentVel.Z)
            end
        end
        for _, v in ipairs(locHrp:GetChildren()) do
            if (v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("BodyModifier")) and v.Name ~= "FlyVelocity" then 
                v:Destroy() 
            end
        end
    end

    if toggles.NoFall and locHrp and hum then
        if not toggles.Fly and not toggles.Freecam and not UIS:IsKeyDown(Enum.KeyCode.Space) then
            if locHrp.AssemblyLinearVelocity.Y < -25 then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Exclude
                
                local groundHit = workspace:Raycast(locHrp.Position, Vector3.new(0, -12, 0), params)
                if groundHit then
                    locHrp.AssemblyLinearVelocity = Vector3.new(locHrp.AssemblyLinearVelocity.X, -2, locHrp.AssemblyLinearVelocity.Z)
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                end
            end
        end
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end
    
    local char = localPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local locHrp = char and char:FindFirstChild("HumanoidRootPart")
    local cp = cam.CFrame.Position

    local isStrafing = false
    if toggles.KA and toggles.KAStrafe and sharedKATarget and hum and locHrp and hum.Health > 0 then
        local tHRP = sharedKATarget:FindFirstChild("HumanoidRootPart") or sharedKATarget.PrimaryPart or sharedKATarget:FindFirstChildWhichIsA("BasePart")
        if tHRP then
            isStrafing = true
            local sSpeed = tonumber(toggles.KAStrafeSpeed) or 15
            local sRadius = tonumber(toggles.KAStrafeRadius) or 10
            local sMode = toggles.KAStrafeMode or "Circle"
            
            if sMode == "Circle" then
                strafeAngle = strafeAngle + math.rad(sSpeed * 10 * dt)
                if strafeAngle >= math.pi * 2 then strafeAngle = strafeAngle - (math.pi * 2) end
            elseif sMode == "Back-and-Forth" then
                strafeAngle = math.sin(tick() * (sSpeed / 15)) * math.pi
            elseif sMode == "Random Point" then
                if tick() - lastRandomStrafe > (20 / sSpeed) then
                    lastRandomStrafe = tick()
                    targetStrafeAngle = math.rad(math.random(0, 360))
                end
                local diff = targetStrafeAngle - strafeAngle
                if diff > math.pi then diff = diff - math.pi * 2 elseif diff < -math.pi then diff = diff + math.pi * 2 end
                strafeAngle = strafeAngle + diff * (dt * 5)
            end
            
            local targetPos = tHRP.Position + Vector3.new(math.cos(strafeAngle) * sRadius, 0, math.sin(strafeAngle) * sRadius)
            local dir = (targetPos - locHrp.Position)
            local flatDir = Vector3.new(dir.X, 0, dir.Z)
            
            if toggles.KAStrafeSafe then
                local predictedPos = locHrp.Position + (flatDir.Unit * 4)
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char, sharedKATarget}
                params.FilterType = Enum.RaycastFilterType.Exclude
                
                local groundHit = workspace:Raycast(predictedPos + Vector3.new(0, 3, 0), Vector3.new(0, -15, 0), params)
                if not groundHit then
                    strafeAngle = strafeAngle + math.pi
                    targetPos = tHRP.Position + Vector3.new(math.cos(strafeAngle) * sRadius, 0, math.sin(strafeAngle) * sRadius)
                    dir = (targetPos - locHrp.Position)
                    flatDir = Vector3.new(dir.X, 0, dir.Z)
                end
            end

            if flatDir.Magnitude > 0.5 then
                hum:Move(flatDir.Unit, false)
            end
            
            -- Force character to stare at the target while orbiting!
            hum.AutoRotate = false
            locHrp.CFrame = CFrame.lookAt(locHrp.Position, Vector3.new(tHRP.Position.X, locHrp.Position.Y, tHRP.Position.Z))
        end
    end

    if toggles.Sprint and hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0 then
        if hum.WalkSpeed < 20 then 
            hum.WalkSpeed = 20 
        end
    end

    if toggles.AimAssist and locHrp then
        local isHoldingSword = true 
        if toggles.AimReqSword then
            isHoldingSword = false
            if char then
                for _, item in ipairs(char:GetDescendants()) do
                    if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
                        local n = item.Name:lower()
                        if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("rageblade") or n:find("hammer") or n:find("weapon") or n:find("katana") then
                            isHoldingSword = true
                            break
                        end
                    end
                end
            end
        end

        if isHoldingSword then
            local range = tonumber(toggles.AimRange) or 100
            local bestTarget = nil
            local bestDist = math.huge
            local mousePos = UIS:GetMouseLocation()

            if toggles.AimTrackKA and sharedKATarget then
                local thum = sharedKATarget:FindFirstChild("Humanoid")
                if thum and thum.Health > 0 then
                    local tHRP = sharedKATarget:FindFirstChild("HumanoidRootPart")
                    local tHead = sharedKATarget:FindFirstChild("Head")
                    bestTarget = toggles.AimPart == "Head" and tHead or tHRP
                end
            end

            if not bestTarget then
                local function checkAimTarget(model, isPlayerTarget)
                    if not model then return end
                    local targetHRP = model:FindFirstChild("HumanoidRootPart")
                    local targetHead = model:FindFirstChild("Head")
                    local aimPart = toggles.AimPart == "Head" and targetHead or targetHRP
                    local thum = model:FindFirstChild("Humanoid")

                    if aimPart and aimPart:IsA("BasePart") and thum and thum.Health > 0 then
                        if isPlayerTarget and toggles.AimTeamCheck then
                            local p = Players:GetPlayerFromCharacter(model)
                            if p and p.Team == localPlayer.Team then return end
                        end
                        
                        local dist3D = (aimPart.Position - locHrp.Position).Magnitude
                        if dist3D <= range then
                            local screenPos, onScreen = cam:WorldToViewportPoint(aimPart.Position)
                            if onScreen then
                                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist2D < bestDist then
                                    local isBlocked = false
                                    if toggles.AimWallCheck then
                                        local params = RaycastParams.new()
                                        params.FilterDescendantsInstances = {char, model}
                                        params.FilterType = Enum.RaycastFilterType.Exclude
                                        local hit = workspace:Raycast(cam.CFrame.Position, aimPart.Position - cam.CFrame.Position, params)
                                        if hit then isBlocked = true end
                                    end
                                    if not isBlocked then 
                                        bestDist = dist2D
                                        bestTarget = aimPart 
                                    end
                                end
                            end
                        end
                    end
                end

                if toggles.AimTargetPlayer then
                    for _, p in ipairs(Players:GetPlayers()) do 
                        if p ~= localPlayer and p.Character then 
                            checkAimTarget(p.Character, true) 
                        end 
                    end
                end
                
                if toggles.AimTargetNPC or toggles.AimTargetDummy then
                    local npcs = workspace:FindFirstChild("Live") or workspace
                    for _, npc in ipairs(npcs:GetChildren()) do
                        if npc:IsA("Model") and npc ~= char and not Players:GetPlayerFromCharacter(npc) then
                            local nName = npc.Name:lower()
                            if toggles.AimTargetDummy and nName:find("dummy") then 
                                checkAimTarget(npc, false)
                            elseif toggles.AimTargetNPC and not nName:find("dummy") then 
                                checkAimTarget(npc, false) 
                            end
                        end
                    end
                end
            end

            if bestTarget then
                local targetCFrame = CFrame.lookAt(cam.CFrame.Position, bestTarget.Position)
                local speed = (tonumber(toggles.AimSpeed) or 50) / 100
                cam.CFrame = cam.CFrame:Lerp(targetCFrame, speed)
            end
        end
    end

    if toggles.Freecam then
        if not freecamActive then
            freecamActive = true
            local rx, ry, rz = cam.CFrame:ToEulerAnglesYXZ()
            camAngleX = math.deg(ry)
            camAngleY = math.deg(rx)
            if locHrp then 
                locHrp.Anchored = true 
            end 
        end
        cam.CameraType = Enum.CameraType.Scriptable
        local move = Vector3.new()
        local spd = toggles.FreecamSpeed
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then move = move + cam.CFrame.UpVector end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then move = move - cam.CFrame.UpVector end
        cam.CFrame = cam.CFrame + (move * (spd * 0.5))
    else
        if freecamActive then
            freecamActive = false
            if locHrp and locHrp.Anchored then 
                locHrp.Anchored = false 
            end
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end

    if toggles.TimeOfDay then 
        Lighting.ClockTime = toggles.TimeValue 
    end

    if toggles.Spectate and not toggles.Freecam then
        local targetPlayer = Players:FindFirstChild(toggles.SpectateTarget)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            cam.CameraSubject = targetPlayer.Character.Humanoid
        else 
            if hum then 
                cam.CameraSubject = hum 
            end 
        end
    elseif not toggles.Freecam then
        if hum and cam.CameraSubject ~= hum then 
            cam.CameraSubject = hum 
        end
    end

    if toggles.SpinBot and locHrp and hum and not toggles.Freecam and not isStrafing then
        hum.AutoRotate = false
        locHrp.CFrame = locHrp.CFrame * CFrame.Angles(0, math.rad(toggles.SpinSpeed), 0)
    elseif hum and not toggles.SpinBot and not isStrafing then 
        hum.AutoRotate = true 
    end

    if toggles.Fly and locHrp then
        if not flyBodyVel or not flyBodyVel.Parent then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Name = "FlyVelocity"
            flyBodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
            flyBodyVel.Parent = locHrp
        end
        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        local yVel = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space) then yVel = toggles.FlySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then yVel = -toggles.FlySpeed end
        flyBodyVel.Velocity = Vector3.new(move.X * toggles.FlySpeed, yVel, move.Z * toggles.FlySpeed)
    else 
        if flyBodyVel then 
            flyBodyVel:Destroy()
            flyBodyVel = nil 
        end 
    end

    if toggles.Speed and locHrp and hum and not toggles.Fly then
        if hum.MoveDirection.Magnitude > 0 then
            local bonusSpeed = toggles.SpeedValue - 16
            if bonusSpeed > 0 then 
                locHrp.CFrame = locHrp.CFrame + (hum.MoveDirection * (bonusSpeed * dt)) 
            end
        end
    end

    if toggles.WallClimb and locHrp and UIS:IsKeyDown(Enum.KeyCode.W) then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(locHrp.Position, locHrp.CFrame.LookVector * 3, params)
        if hit then 
            local speed = tonumber(toggles.WallClimbSpeed) or 40
            locHrp.Velocity = Vector3.new(locHrp.Velocity.X, speed, locHrp.Velocity.Z) 
        end
    end

    if toggles.VoidJump and locHrp and hum then
        if tick() - (lastVoidJump or 0) > 0.6 then
            if hum:GetState() == Enum.HumanoidStateType.Freefall and locHrp.Velocity.Y < -15 then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local groundHit = workspace:Raycast(locHrp.Position, Vector3.new(0, -15, 0), params)
                if not groundHit then 
                    locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 65, locHrp.Velocity.Z)
                    lastVoidJump = tick() 
                end
            end
        end
    end

    if toggles.Trails and locHrp and hum then
        if hum.MoveDirection.Magnitude > 0 and tick() - (tonumber(lastTrail) or 0) > 0.08 then
            lastTrail = tick()
            local p = Instance.new("Part")
            p.Anchored = true
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
            p.Material = Enum.Material.Neon
            p.Size = toggles.TrailBall and Vector3.new(1.2,1.2,1.2) or Vector3.new(1,1,1)
            p.Shape = toggles.TrailBall and Enum.PartType.Ball or Enum.PartType.Block
            p.CFrame = locHrp.CFrame * CFrame.new(0, -1, 0)
            p.Color = toggles.TrailRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or currentAccent
            p.Parent = workspace
            TweenService:Create(p, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play()
            game:GetService("Debris"):AddItem(p, 1.1)
        end
    end

    for obj, data in pairs(tracked) do
        if obj and obj.Parent then
            if data.mode == "Player" then
                local act = toggles.BoxESP
                local chamsAct = toggles.Chams

                if data.player == localPlayer and not toggles.DevMode then 
                    act = false
                    chamsAct = false
                else
                    local team = (data.player.Team == localPlayer.Team)
                    if boxTargetMode == "Enemy" and team then 
                        act = false
                        chamsAct = false 
                    end
                    if boxTargetMode == "Teams" and not team then 
                        act = false
                        chamsAct = false 
                    end
                end

                data.gui.Enabled = act
                data.info.Enabled = act

                if chamsAct then
                    if not data.chams then
                        data.chams = Instance.new("Highlight", data.part)
                        data.chams.FillTransparency = 0.5
                        data.chams.OutlineTransparency = 0.1
                    end
                    local tc = data.player.TeamColor and data.player.TeamColor.Color or Color3.new(1,1,1)
                    data.chams.FillColor = tc
                    data.chams.OutlineColor = tc
                    data.chams.Enabled = true
                else 
                    if data.chams then 
                        data.chams.Enabled = false 
                    end 
                end

                if act then
                    local tc = data.player.TeamColor and data.player.TeamColor.Color or Color3.new(1,1,1)
                    data.stroke.Color = tc
                    data.textLabel.TextColor3 = tc
                    local l = {}
                    if toggles.ShowName then 
                        table.insert(l, data.player.DisplayName) 
                    end
                    if toggles.ShowTeam then 
                        table.insert(l, data.player.Team and data.player.Team.Name or "Neutral") 
                    end
                    if toggles.ShowKit then 
                        local rK = tostring(data.player:GetAttribute("PlayingAsKits") or "None"):upper()
                        table.insert(l, "[" .. (kitTranslations[rK] or rK) .. "]") 
                    end
                    if toggles.ShowHealth then
                        local phum = data.player.Character and data.player.Character:FindFirstChild("Humanoid")
                        local hp = phum and math.floor(phum.Health) or 0
                        table.insert(l, "[" .. hp .. " HP]")
                    end
                    data.textLabel.Text = table.concat(l, "\n")
                end
            end
        else 
            removeESP(obj) 
        end
    end
end))

task.spawn(function()
    while isRunning do
        task.wait(0.2)
        local cp = cam.CFrame.Position
        for obj, data in pairs(tracked) do
            if obj and obj.Parent then
                if data.mode == "Farm" then
                    if not toggles.FarmESP and not toggles.BeehiveESP and not toggles.TaliyahESP and not toggles.BedESP then
                        data.highlight.Enabled = false
                        data.info.Enabled = false
                        continue
                    end
                    
                    local act = false
                    if data.espType == "Beehive" and toggles.BeehiveESP then 
                        act = true
                        data.textLabel.Text = (obj:GetAttribute("Level") or 0) .. " BEES"
                    elseif data.espType == "Taliyah" and toggles.TaliyahESP then 
                        act = true
                        data.textLabel.Text = "EGG"
                    elseif data.espType == "Bed" and toggles.BedESP then 
                        act = true
                        data.textLabel.Text = "[BED]"
                    elseif toggles.FarmESP and data.espType ~= "Beehive" and data.espType ~= "Taliyah" and data.espType ~= "Bed" then
                        if farmFilter == "Everything" or farmFilter:find(data.espType) then 
                            act = true
                            data.textLabel.Text = "[" .. data.espType:upper() .. "]" 
                        end 
                    end
                    
                    data.highlight.Enabled = act
                    data.info.Enabled = act
                elseif data.mode == "World" then
                    if not toggles.MetalESP and not toggles.StarESP and not toggles.BeeESP and not toggles.CrateESP and not toggles.ElderESP and not toggles.OreESP then
                        data.info.Enabled = false
                        continue
                    end
                    
                    local act = false
                    local eType = tostring(data.espType)
                    
                    if eType:find("Star") and toggles.StarESP then 
                        act = true
                    elseif eType:find("Tree Orb") and toggles.ElderESP then 
                        act = true
                    elseif eType:find("Ore") and toggles.OreESP then 
                        act = true
                    elseif toggles[eType:gsub(" ","") .. "ESP"] then 
                        act = true 
                    end

                    data.info.Enabled = act
                    if act then 
                        data.textLabel.Text = eType .. " [" .. math.floor((data.part.Position - cp).Magnitude) .. "m]" 
                    end
                end
            end
        end
    end
end)

do -- [KIT RENDER WRAPPER]
local function updateRender()
    kitFrame = ui:FindFirstChild("KitFrame")
    if not kitFrame then return end
    
    local kitScroll = kitFrame:FindFirstChild("ScrollingFrame")
    if not kitScroll then return end

    if not kitScroll:FindFirstChild("UIListLayout") then
        local layout = Instance.new("UIListLayout", kitScroll)
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
    end

    for _, child in ipairs(kitScroll:GetChildren()) do 
        if child:IsA("GuiObject") then 
            child.Visible = false 
        end 
    end

    local layoutIndex = 0
    local safeTeams = {}
    pcall(function() safeTeams = Teams:GetTeams() or {} end)
    
    local allPlayersCache = {}
    pcall(function() allPlayersCache = Players:GetPlayers() or {} end)
    
    for _, team in pairs(safeTeams) do
        if typeof(team) == "Instance" and team:IsA("Team") then
            local pCount = 0
            local pList = {}
            
            if type(allPlayersCache) == "table" then
                for _, p in ipairs(allPlayersCache) do
                    if typeof(p) == "Instance" and p.Team == team then
                        pCount = pCount + 1
                        pList[pCount] = p
                    end
                end
            end
            
            if pCount > 0 then
                if not toggles.KitRenderOwnTeam and localPlayer.Team == team then continue end

                layoutIndex = layoutIndex + 1
                local headerId = "TeamHeader_" .. team.Name
                local h = kitScroll:FindFirstChild(headerId)
                
                if not h then
                    h = Instance.new("TextButton", kitScroll)
                    h.Name = headerId
                    h.Size = UDim2.new(1, 0, 0, 28)
                    h.BackgroundColor3 = c_element
                    h.Font = Enum.Font.GothamBold
                    h.TextSize = 13
                    h.TextXAlignment = Enum.TextXAlignment.Left
                    addCorner(6, h)
                    
                    local arrow = Instance.new("TextLabel", h)
                    arrow.Name = "Arrow"
                    arrow.Size = UDim2.new(0, 30, 1, 0)
                    arrow.Position = UDim2.new(1, -30, 0, 0)
                    arrow.BackgroundTransparency = 1
                    arrow.Font = Enum.Font.GothamBold
                    arrow.TextSize = 14
                    
                    h.MouseButton1Down:Connect(function() 
                        expandedTeams[team.Name] = not expandedTeams[team.Name]
                        updateRender() 
                    end)
                end

                h.Text = "  " .. team.Name:upper()
                local tc = team.TeamColor and team.TeamColor.Color or Color3.new(1,1,1)
                h.TextColor3 = tc
                h.Arrow.Text = expandedTeams[team.Name] and "▼" or "▶"
                h.Arrow.TextColor3 = currentAccent
                accentObjects[h.Arrow] = "TextColor3"
                h.LayoutOrder = layoutIndex
                h.Visible = true

                if expandedTeams[team.Name] then
                    for _, p in ipairs(pList) do
                        layoutIndex = layoutIndex + 1
                        local cardId = "PlayerCard_" .. p.UserId
                        local card = kitScroll:FindFirstChild(cardId)
                        
                        if not card then
                            card = Instance.new("Frame", kitScroll)
                            card.Name = cardId
                            card.Size = UDim2.new(0.95, 0, 0, 85)
                            card.BackgroundColor3 = c_sidebar
                            addCorner(8, card)
                            
                            local stroke = Instance.new("UIStroke", card)
                            stroke.Name = "Border"
                            stroke.Thickness = 1.5
                            stroke.Transparency = 0.3
                            
                            local img = Instance.new("ImageLabel", card)
                            img.Name = "Avatar"
                            img.Size = UDim2.new(0, 46, 0, 46)
                            img.Position = UDim2.new(0, 8, 0, 8)
                            img.BackgroundColor3 = c_element
                            addCorner(24, img)
                            
                            local tName = Instance.new("TextLabel", card)
                            tName.Name = "PName"
                            tName.Size = UDim2.new(1, -60, 0, 15)
                            tName.Position = UDim2.new(0, 62, 0, 5)
                            tName.BackgroundTransparency = 1
                            tName.TextColor3 = Color3.new(1, 1, 1)
                            tName.Font = Enum.Font.GothamBold
                            tName.TextSize = 14
                            tName.TextXAlignment = Enum.TextXAlignment.Left
                            
                            local tKit = Instance.new("TextLabel", card)
                            tKit.Name = "PKit"
                            tKit.Size = UDim2.new(1, -60, 0, 15)
                            tKit.Position = UDim2.new(0, 62, 0, 20)
                            tKit.BackgroundTransparency = 1
                            tKit.Font = Enum.Font.GothamSemibold
                            tKit.TextSize = 12
                            tKit.TextXAlignment = Enum.TextXAlignment.Left
                            
                            local tClan = Instance.new("TextLabel", card)
                            tClan.Name = "PClan"
                            tClan.Size = UDim2.new(1, -60, 0, 15)
                            tClan.Position = UDim2.new(0, 62, 0, 35)
                            tClan.BackgroundTransparency = 1
                            tClan.Font = Enum.Font.Gotham
                            tClan.TextSize = 11
                            tClan.TextXAlignment = Enum.TextXAlignment.Left
                            tClan.RichText = true

                            local tStats = Instance.new("TextLabel", card)
                            tStats.Name = "PStats"
                            tStats.Size = UDim2.new(1, -15, 0, 15)
                            tStats.Position = UDim2.new(0, 8, 0, 52)
                            tStats.BackgroundTransparency = 1
                            tStats.TextColor3 = Color3.fromRGB(180, 180, 180)
                            tStats.Font = Enum.Font.Gotham
                            tStats.TextSize = 11
                            tStats.TextXAlignment = Enum.TextXAlignment.Left
                            
                            local tExtra = Instance.new("TextLabel", card)
                            tExtra.Name = "PExtra"
                            tExtra.Size = UDim2.new(1, -15, 0, 15)
                            tExtra.Position = UDim2.new(0, 8, 0, 67)
                            tExtra.BackgroundTransparency = 1
                            tExtra.TextColor3 = Color3.fromRGB(180, 180, 180)
                            tExtra.Font = Enum.Font.Gotham
                            tExtra.TextSize = 11
                            tExtra.TextXAlignment = Enum.TextXAlignment.Left

                            local tRole = Instance.new("TextLabel", card)
                            tRole.Name = "PRole"
                            tRole.Size = UDim2.new(1, -15, 0, 15)
                            tRole.Position = UDim2.new(0, 8, 0, 82)
                            tRole.BackgroundTransparency = 1
                            tRole.TextColor3 = Color3.fromRGB(255, 80, 80)
                            tRole.Font = Enum.Font.GothamBold
                            tRole.TextSize = 11
                            tRole.TextXAlignment = Enum.TextXAlignment.Left
                        end

                        local rK = tostring(p:GetAttribute("PlayingAsKits") or "None"):upper()
                        local kitName = kitTranslations[rK] or rK
                        local kitSkin = tostring(p:GetAttribute("KitSkin") or "default")
                        if kitSkin ~= "default" and kitSkin ~= "none" then
                            kitName = kitName .. " (" .. kitSkin .. ")"
                        end

                        local clanText = ""
                        pcall(function() 
                            local tags = p:FindFirstChild("Tags")
                            if tags then 
                                local zero = tags:FindFirstChild("0") or tags:FindFirstChild(0)
                                if zero and zero:IsA("StringValue") then 
                                    clanText = tostring(zero.Value) 
                                end 
                            end 
                        end)

                        local lvl = p:GetAttribute("PlayerLevel") or 0
                        local games = p:GetAttribute("GamesPlayed") or 0
                        local device = p:GetAttribute("UserInputType") or "Unknown"
                        local bp = p:GetAttribute("BattlePassPaid") and "PAID" or "FREE"
                        local isNew = p:GetAttribute("FirstTimePlayer") and "YES" or "NO"
                        local role = p:GetAttribute("CustomMatchRole") or "none"
                        local isJuggernaut = p:GetAttribute("Juggernaut")
                        local isObserver = p:GetAttribute("IsObserver")

                        card.Border.Color = tc
                        card.PName.Text = p.DisplayName
                        card.PKit.Text = kitName
                        card.PKit.TextColor3 = tc
                        
                        if clanText and clanText ~= "" then 
                            card.PClan.Text = "CLAN: " .. clanText
                            card.PClan.TextColor3 = Color3.new(1, 1, 1) 
                        else 
                            card.PClan.Text = "CLAN: NONE"
                            card.PClan.TextColor3 = Color3.fromRGB(130, 130, 130) 
                        end

                        card.PStats.Text = "LVL: " .. tostring(lvl) .. " | MATCHES: " .. tostring(games) .. " | DEV: " .. tostring(device)
                        card.PExtra.Text = "BP: " .. bp .. " | NEW: " .. isNew
                        
                        local activeRoles = {}
                        if role ~= "none" then table.insert(activeRoles, tostring(role):upper()) end
                        if isJuggernaut then table.insert(activeRoles, "JUGGERNAUT") end
                        if isObserver then table.insert(activeRoles, "OBSERVER") end
                        
                        if #activeRoles > 0 then
                            card.PRole.Text = "ROLE: " .. table.concat(activeRoles, ", ")
                            card.PRole.Visible = true
                            card.Size = UDim2.new(0.95, 0, 0, 100)
                        else
                            card.PRole.Visible = false
                            card.Size = UDim2.new(0.95, 0, 0, 85)
                        end
                        
                        if card.Avatar.Image == "" then 
                            pcall(function() 
                                card.Avatar.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) 
                            end) 
                        end
                        
                        card.LayoutOrder = layoutIndex
                        card.Visible = true
                    end
                end
            end
        end
    end
end

-- Initialize Kit Frame
kitFrame = Instance.new("Frame", ui)
kitFrame.Name = "KitFrame"
kitFrame.Size = UDim2.new(0, 380, 0, 520)
kitFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
kitFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
kitFrame.BackgroundTransparency = 0.25
kitFrame.Visible = false
kitFrame.ClipsDescendants = true
addCorner(10, kitFrame)
makeDraggable(kitFrame, kitFrame)

local kitStroke = Instance.new("UIStroke", kitFrame)
kitStroke.Color = Color3.fromRGB(255, 255, 255)
kitStroke.Transparency = 0.9
kitStroke.Thickness = 1

local kitTitleTxt = Instance.new("TextLabel", kitFrame)
kitTitleTxt.Size = UDim2.new(1, 0, 0, 45)
kitTitleTxt.BackgroundTransparency = 1
kitTitleTxt.Text = "KIT RENDER"
kitTitleTxt.TextColor3 = currentAccent
kitTitleTxt.Font = Enum.Font.GothamBold
kitTitleTxt.TextSize = 18
accentObjects[kitTitleTxt] = "TextColor3"

local kitLineFrame = Instance.new("Frame", kitFrame)
kitLineFrame.Size = UDim2.new(1, -30, 0, 1)
kitLineFrame.Position = UDim2.new(0, 15, 0, 45)
kitLineFrame.BackgroundColor3 = c_element
kitLineFrame.BorderSizePixel = 0

local kitScroll = Instance.new("ScrollingFrame", kitFrame)
kitScroll.Size = UDim2.new(0.95, 0, 0.85, 0)
kitScroll.Position = UDim2.new(0.025, 0, 0.12, 0)
kitScroll.BackgroundTransparency = 1
kitScroll.ScrollBarThickness = 2
kitScroll.ScrollBarImageColor3 = currentAccent
kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
accentObjects[kitScroll] = "ScrollBarImageColor3"

task.spawn(function() 
    while isRunning do 
        task.wait(0.5) 
        if toggles.KitRender and kitFrame and kitFrame.Visible then 
            updateRender() 
        end 
    end 
end)
end -- END KIT RENDER WRAPPER

-- ESP LOGIC
local function getESPConfig(obj)
    if not obj or not obj.Name then return nil end
    local n = obj.Name:lower()
    
    if n:find("melon") then return Color3.fromRGB(0, 255, 0), "Melon", "Farm" end
    if n:find("carrot") then return Color3.fromRGB(255, 255, 0), "Carrot", "Farm" end
    if n:find("pumpkin") then return Color3.fromRGB(255, 128, 0), "Pumpkin", "Farm" end
    if n:find("beehive") then return Color3.fromRGB(255, 200, 0), "Beehive", "Farm" end
    if n:find("chicken_egg_block") then return Color3.fromRGB(255, 170, 255), "Taliyah", "Farm" end
    
    if n:find("bed") and not n:find("bedrock") then 
        if not isMyTeamBed(obj) then
            return Color3.fromRGB(255, 50, 50), "Bed", "Farm" 
        end
    end
    
    if n:find("star") then
        if n:find("vitality") or n:find("health") then 
            return Color3.new(0, 1, 0), "Health Star", "World" 
        else 
            return Color3.new(1, 0.5, 0), "Crit Star", "World" 
        end
    end
    if n:find("treeorb") or n:find("tree_orb") then return Color3.fromRGB(50, 255, 50), "Tree Orb", "World" end
    if n:find("iron_ore_mesh_block") then return Color3.fromRGB(200, 200, 200), "Ore", "World" end
    if n:find("metal") or obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal", "World" end
    if n:find("bee") and not n:find("beehive") then return Color3.new(1, 1, 0), "Bee", "World" end
    if n:find("team_crate") then return Color3.fromRGB(150, 100, 50), "Crate", "World" end
    
    return nil
end

local function createESP(obj, isPlayer)
    if tracked[obj] then return end
    
    if isPlayer then 
        local root = obj:WaitForChild("HumanoidRootPart", 5)
        if not root then return end 
    end
    
    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
    if not targetPart and not isPlayer then return end
    
    local root = obj:FindFirstChild("HumanoidRootPart") or targetPart
    local col, typeStr, method = getESPConfig(obj)
    
    if isPlayer then method = "Player" end
    if not method or not root then return end

    if method == "Farm" then
        local hl = Instance.new("Highlight", targetPart)
        hl.Name = "ZenHL"
        hl.FillColor = col
        hl.FillTransparency = 0.5
        hl.OutlineColor = col
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        
        local marker = Instance.new("BillboardGui", targetPart)
        marker.Name = "ZenMarker"
        marker.AlwaysOnTop = true
        marker.Size = UDim2.fromOffset(180, 35)
        marker.StudsOffset = Vector3.new(0, 5, 0)
        marker.Enabled = false
        
        local markerTxt = Instance.new("TextLabel", marker)
        markerTxt.Size = UDim2.fromScale(1, 1)
        markerTxt.BackgroundTransparency = 1
        markerTxt.TextColor3 = col
        markerTxt.TextStrokeTransparency = 0.5
        markerTxt.Font = Enum.Font.GothamBold
        markerTxt.TextSize = 14
        
        tracked[obj] = { mode = "Farm", highlight = hl, info = marker, textLabel = markerTxt, espType = typeStr, part = targetPart }
        
    elseif method == "World" then
        local m = Instance.new("BillboardGui", root)
        m.AlwaysOnTop = true
        m.Size = UDim2.fromOffset(100, 30)
        m.StudsOffset = Vector3.new(0,3,0)
        m.Enabled = false
        
        local t = Instance.new("TextLabel", m)
        t.Size = UDim2.fromScale(1,1)
        t.BackgroundTransparency = 1
        t.TextColor3 = col
        t.Font = Enum.Font.Gotham
        t.TextSize = 12
        
        tracked[obj] = { mode = "World", info = m, textLabel = t, espType = typeStr, part = root }
        
    elseif method == "Player" then
        local info = Instance.new("BillboardGui", root)
        info.Name = "ZenMarker"
        info.AlwaysOnTop = true
        info.Size = UDim2.fromOffset(250, 100)
        info.StudsOffset = Vector3.new(0, 7.5, 0)
        info.Enabled = false
        
        local tl = Instance.new("TextLabel", info)
        tl.Size = UDim2.fromScale(1, 1)
        tl.BackgroundTransparency = 1
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 14
        tl.TextStrokeTransparency = 0.5
        tl.TextYAlignment = Enum.TextYAlignment.Bottom
        
        local b = Instance.new("BillboardGui", root)
        b.Name = "ZenBox"
        b.AlwaysOnTop = true
        b.Size = UDim2.fromScale(4.5, 6.5)
        b.Enabled = false
        
        local f = Instance.new("Frame", b)
        f.Size = UDim2.fromScale(1,1)
        f.BackgroundTransparency = 1
        
        local s = Instance.new("UIStroke", f)
        s.Thickness = 1.5
        
        tracked[obj] = { mode = "Player", gui = b, info = info, textLabel = tl, stroke = s, player = Players:GetPlayerFromCharacter(obj), part = root, chams = nil }
    end
end

local function removeESP(obj)
    if tracked[obj] then
        if tracked[obj].gui then tracked[obj].gui:Destroy() end
        if tracked[obj].info then tracked[obj].info:Destroy() end
        if tracked[obj].highlight then tracked[obj].highlight:Destroy() end
        if tracked[obj].chams then tracked[obj].chams:Destroy() end
        tracked[obj] = nil
    end
end

table.insert(connections, workspace.DescendantAdded:Connect(function(v) 
    task.wait(0.1)
    if getESPConfig(v) then 
        createESP(v, false) 
    end 
end))

table.insert(connections, workspace.DescendantRemoving:Connect(function(v) 
    removeESP(v) 
end))

for _, v in pairs(workspace:GetDescendants()) do 
    if getESPConfig(v) then 
        createESP(v, false) 
    end 
end

local function onPlayerAdded(p) 
    table.insert(connections, p.CharacterAdded:Connect(function(char) 
        task.wait(0.5)
        createESP(char, true) 
    end))
    
    if p.Character then 
        createESP(p.Character, true) 
    end 
end

table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
for _, p in pairs(Players:GetPlayers()) do 
    onPlayerAdded(p) 
end

-- ==========================================
-- KA LOGIC (PURE, AUTHENTIC HIT NO SPOOFING)
-- ==========================================
local cachedTargets = {}

task.spawn(function()
    while isRunning do
        task.wait(0.5) 
        local newCache = {}
        
        local function scanFolder(folder)
            if not folder then return end
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= localPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then 
                        table.insert(newCache, obj) 
                    end
                end
            end
        end
        
        scanFolder(workspace)
        if workspace:FindFirstChild("Live") then 
            scanFolder(workspace.Live) 
        end
        cachedTargets = newCache
    end
end)

task.spawn(function()
    local swingAnimInst = Instance.new("Animation")
    swingAnimInst.AnimationId = "rbxassetid://4947108314"
    local loadedSwingAnim = nil
    local currentAnimHum = nil
    local lastSwingTime = 0

    while isRunning do
        task.wait(tonumber(toggles.KASpeed) or 0.1)

        local SwordHit = ReplicatedStorage:FindFirstChild("rbxts_include")
        if SwordHit then SwordHit = SwordHit.node_modules:FindFirstChild("@rbxts") end
        if SwordHit then SwordHit = SwordHit.net.out._NetManaged:FindFirstChild("SwordHit") end

        local char = localPlayer.Character
        local locHrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if toggles.KA and char and locHrp and hum and hum.Health > 0 then
            local invFolder = ReplicatedStorage:FindFirstChild("Inventories") or ReplicatedStorage:FindFirstChild("inventories")
            local myInv = invFolder and invFolder:FindFirstChild(localPlayer.Name)

            local bestSword = getSwordFrom(myInv)
            if not bestSword then bestSword = getSwordFrom(localPlayer:FindFirstChild("Backpack")) end
            if not bestSword then bestSword = getSwordFrom(char) end

            if bestSword then
                local isHoldingSword = false
                for _, item in ipairs(char:GetDescendants()) do
                    if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
                        local n = item.Name:lower()
                        if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("rageblade") or n:find("hammer") or n:find("katana") or n:find("weapon") then
                            isHoldingSword = true
                            break
                        end
                    end
                end

                if isHoldingSword then
                    local range = tonumber(toggles.KARange) or 28
                    local maxAngle = (tonumber(toggles.KAAngle) or 360) / 2 

                    local closestPlayer, pDist = nil, math.huge
                    local closestNPC, nDist = nil, math.huge
                    local closestDummy, dDist = nil, math.huge

                    local function checkTargetGroup(groupList)
                        local cTarget, cDist = nil, math.huge
                        for _, model in ipairs(groupList) do
                            if model then
                                local targetHRP = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                                if targetHRP and targetHRP:IsA("BasePart") then
                                    local dirVec = targetHRP.Position - locHrp.Position
                                    local dist = dirVec.Magnitude
                                    
                                    if dist <= range then
                                        local dotProduct = locHrp.CFrame.LookVector:Dot(dirVec.Unit)
                                        local angleToTarget = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
                                        
                                        if angleToTarget <= maxAngle then
                                            local isBlocked = false
                                            if toggles.KAWallCheck then
                                                local params = RaycastParams.new()
                                                params.FilterDescendantsInstances = {char, model}
                                                params.FilterType = Enum.RaycastFilterType.Exclude
                                                local hit = workspace:Raycast(locHrp.Position, dirVec, params)
                                                if hit then isBlocked = true end
                                            end
                                            
                                            if not isBlocked and dist < cDist then 
                                                cDist = dist
                                                cTarget = model 
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        return cTarget, cDist
                    end

                    local pList = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= localPlayer and p.Character then
                            if not (p.Team and localPlayer.Team and p.Team == localPlayer.Team) then
                                local phum = p.Character:FindFirstChildOfClass("Humanoid")
                                if phum and phum.Health > 0 then 
                                    table.insert(pList, p.Character) 
                                end
                            end
                        end
                    end

                    local npcList, dummyList = {}, {}
                    for _, npc in ipairs(cachedTargets) do
                        if npc and npc.Parent then
                            local nhum = npc:FindFirstChildOfClass("Humanoid")
                            if nhum and nhum.Health > 0 then 
                                if npc.Name:lower():find("dummy") then 
                                    table.insert(dummyList, npc) 
                                else 
                                    table.insert(npcList, npc) 
                                end
                            end
                        end
                    end

                    if toggles.KATargetPlayer then closestPlayer, pDist = checkTargetGroup(pList) end
                    if toggles.KATargetNPC then closestNPC, nDist = checkTargetGroup(npcList) end
                    if toggles.KATargetDummy then closestDummy, dDist = checkTargetGroup(dummyList) end

                    local targetEnemy = nil
                    local actualTargetDist = 0

                    local allValid = {}
                    if closestPlayer then table.insert(allValid, {m=closestPlayer, d=pDist, type="Player"}) end
                    if closestNPC then table.insert(allValid, {m=closestNPC, d=nDist, type="NPC"}) end
                    if closestDummy then table.insert(allValid, {m=closestDummy, d=dDist, type="Dummy"}) end

                    if #allValid > 0 then
                        table.sort(allValid, function(a,b) 
                            return (tonumber(a.d) or math.huge) < (tonumber(b.d) or math.huge) 
                        end)

                        if toggles.KAPriority == "Distance" then 
                            targetEnemy = allValid[1].m
                            actualTargetDist = tonumber(allValid[1].d) or 0
                        else
                            for _, v in ipairs(allValid) do
                                if v.type == toggles.KAPriority then 
                                    targetEnemy = v.m
                                    actualTargetDist = tonumber(v.d) or 0
                                    break 
                                end
                            end
                            
                            if not targetEnemy then 
                                targetEnemy = allValid[1].m
                                actualTargetDist = tonumber(allValid[1].d) or 0 
                            end
                        end
                    end

                    sharedKATarget = targetEnemy

                    if targetEnemy then
                        local targetHRP = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy.PrimaryPart or targetEnemy:FindFirstChildWhichIsA("BasePart")
                        if targetHRP and targetHRP:IsA("BasePart") then
                            local p1 = locHrp.Position
                            local p2 = targetHRP.Position
                            local direction = (p2 - p1).Unit
                            local safeDist = tonumber(actualTargetDist) or 0

                            local reachOffset = safeDist - 14
                            if type(reachOffset) ~= "number" then reachOffset = 0 end
                            if reachOffset < 0 then reachOffset = 0 end
                            if reachOffset > 14.4 then reachOffset = 14.4 end

                            local fakePos = p1 + (direction * reachOffset)

                            local args = {
                                [1] = {
                                    ["entityInstance"] = targetEnemy,
                                    ["chargedAttack"] = { ["chargeRatio"] = 0 },
                                    ["validate"] = {
                                        ["targetPosition"] = { ["value"] = p2 },
                                        ["raycast"] = { ["cursorDirection"] = { ["value"] = direction }, ["cameraPosition"] = { ["value"] = fakePos } },
                                        ["selfPosition"] = { ["value"] = fakePos }
                                    },
                                    ["weapon"] = bestSword
                                }
                            }

                            task.spawn(function() 
                                if SwordHit then 
                                    pcall(function() fireRemote(SwordHit, unpack(args)) end) 
                                end
                                
                                if toggles.KASwingAnim then
                                    local sRange = tonumber(toggles.KASwingRange) or 43
                                    if safeDist <= sRange then
                                        local now = tick()
                                        local sSpeed = tonumber(toggles.KASwingSpeed) or 1.0
                                        if type(sSpeed) ~= "number" or sSpeed <= 0 then sSpeed = 1.0 end
                                        
                                        local animCooldown = 0.45 / sSpeed
                                        if (now - (tonumber(lastSwingTime) or 0)) >= animCooldown then
                                            lastSwingTime = now
                                            pcall(function()
                                                local animHum = char:FindFirstChild("Humanoid")
                                                if animHum then
                                                    local animator = animHum:FindFirstChild("Animator")
                                                    if animator then
                                                        if currentAnimHum ~= animHum then 
                                                            loadedSwingAnim = animator:LoadAnimation(swingAnimInst)
                                                            currentAnimHum = animHum 
                                                        end
                                                        if loadedSwingAnim then 
                                                            loadedSwingAnim:Play(0.1)
                                                            loadedSwingAnim:AdjustSpeed(sSpeed) 
                                                        end
                                                    end
                                                end
                                            end)
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- NUKER LOGIC (SMART RAYCAST TUNNELING)
-- ==========================================
do -- [NUKER WRAPPER]
local cachedNukerBlocks = {}
local nukerHighlight = Instance.new("Highlight")
nukerHighlight.Name = "NukerHighlight"
nukerHighlight.FillColor = Color3.fromRGB(255, 50, 50)
nukerHighlight.OutlineColor = Color3.fromRGB(255, 200, 0)
nukerHighlight.FillTransparency = 0.5
nukerHighlight.OutlineTransparency = 0.1
nukerHighlight.Parent = ui
nukerHighlight.Enabled = false

local nukerOreUI = Instance.new("BillboardGui")
nukerOreUI.Name = "NukerOreHP"
nukerOreUI.Size = UDim2.new(0, 100, 0, 12)
nukerOreUI.StudsOffset = Vector3.new(0, 1.5, 0)
nukerOreUI.AlwaysOnTop = true
nukerOreUI.Enabled = false
nukerOreUI.Parent = ui

local hpBg = Instance.new("Frame", nukerOreUI)
hpBg.Size = UDim2.new(1, 0, 1, 0)
hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
hpBg.BorderSizePixel = 0
local hpC = Instance.new("UICorner", hpBg)
hpC.CornerRadius = UDim.new(0, 4)

local hpFill = Instance.new("Frame", hpBg)
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
hpFill.BorderSizePixel = 0
local hpFC = Instance.new("UICorner", hpFill)
hpFC.CornerRadius = UDim.new(0, 4)

local hpTxt = Instance.new("TextLabel", hpBg)
hpTxt.Size = UDim2.new(1, 0, 1, 0)
hpTxt.BackgroundTransparency = 1
hpTxt.Font = Enum.Font.GothamBold
hpTxt.TextSize = 10
hpTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
hpTxt.TextStrokeTransparency = 0.5

task.spawn(function()
    while isRunning do
        task.wait(0.25) 
        local blocks = {}
        local searchArea = workspace:FindFirstChild("Map") or workspace
        for _, obj in ipairs(searchArea:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name:lower()
                local pN = obj.Parent and obj.Parent.Name:lower() or ""

                local isBed = (n:find("bed") or pN:find("bed")) and not n:find("bedrock") and not pN:find("bedrock")
                local isOre = n:find("iron_ore") or pN:find("iron_ore")

                if isBed or isOre then
                    local targetPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if targetPart then
                        local exists = false
                        for _, b in ipairs(blocks) do if b.part == targetPart then exists = true break end end
                        if not exists then
                            table.insert(blocks, { part = targetPart, type = isBed and "Bed" or "Ore", orig = obj })
                        end
                    end
                end
            end
        end
        cachedNukerBlocks = blocks
    end
end)

local function getBlockHp(block)
    if not block then return nil, nil end
    local hp = block:GetAttribute("Health") or block:GetAttribute("blockHealth") or block:GetAttribute("health") or block:GetAttribute("block.Health")
    local maxHp = block:GetAttribute("MaxHealth") or block:GetAttribute("blockMaxHealth") or block:GetAttribute("maxHealth") or block:GetAttribute("maxHealth") or block:GetAttribute("block.MaxHealth")
    if not hp and block.Parent then
        hp = block.Parent:GetAttribute("Health") or block.Parent:GetAttribute("blockHealth") or block.Parent:GetAttribute("health") or block.Parent:GetAttribute("block.Health")
        maxHp = block.Parent:GetAttribute("MaxHealth") or block.Parent:GetAttribute("blockMaxHealth") or block.Parent:GetAttribute("maxHealth") or block.Parent:GetAttribute("block.MaxHealth")
    end
    return hp, maxHp
end

local function isFriendlyTesla(teslaObj)
    if not teslaObj then return false end
    local placedBy = teslaObj:GetAttribute("PlacedByUserId") or (teslaObj.Parent and teslaObj.Parent:GetAttribute("PlacedByUserId"))
    
    if placedBy and placedBy == localPlayer.UserId then
        return true 
    end
    
    if not toggles.NukerTeamTesla then
        local ownerTeam = teslaObj:GetAttribute("OwnerTeam") or (teslaObj.Parent and teslaObj.Parent:GetAttribute("OwnerTeam"))
        if ownerTeam then
            local myTeamId = localPlayer:GetAttribute("Team") or localPlayer:GetAttribute("team")
            if not myTeamId and localPlayer.Team then
                myTeamId = localPlayer.Team:GetAttribute("id") or localPlayer.Team:GetAttribute("TeamId") or localPlayer.Team.Name:match("%d+")
            end
            
            if myTeamId and tostring(ownerTeam) == tostring(myTeamId) then
                return true
            end
        end
        
        if isMyTeamBed(teslaObj) then
            return true
        end
    end
    
    return false
end

task.spawn(function()
    while isRunning do
        task.wait(tonumber(toggles.NukerTimer) or 0.1)

        local char = localPlayer.Character
        local locHrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if toggles.Nuker and char and locHrp and hum and hum.Health > 0 then
            local invFolder = ReplicatedStorage:FindFirstChild("Inventories") or ReplicatedStorage:FindFirstChild("inventories")
            local myInv = invFolder and invFolder:FindFirstChild(localPlayer.Name)
            
            if myInv then
                local function checkTool(keyword)
                    if myInv then 
                        for _, item in ipairs(myInv:GetChildren()) do 
                            if item.Name:lower():find(keyword) then return item end 
                        end 
                    end
                    
                    if char then 
                        for _, item in ipairs(char:GetChildren()) do 
                            if item:IsA("Model") or item:IsA("Tool") or item:IsA("Accessory") then 
                                if item.Name:lower():find(keyword) then return item end 
                            end 
                        end 
                    end
                    return nil
                end

                local hasPickaxe = checkTool("pickaxe")
                local hasAxe = checkTool("axe")
                local hasShears = checkTool("shears")

                local canNuke = true
                if toggles.NukerReqPickaxe or toggles.NukerReqAxe or toggles.NukerReqShears then
                    local hasRequired = false
                    if toggles.NukerReqPickaxe and hasPickaxe then hasRequired = true end
                    if toggles.NukerReqAxe and hasAxe then hasRequired = true end
                    if toggles.NukerReqShears and hasShears then hasRequired = true end

                    if not hasRequired then 
                        canNuke = false 
                    end
                end

                if canNuke then
                    local closestBed, closestBedDist = nil, 40 
                    local closestOre, closestOreDist = nil, 40
                    local closestTesla, closestTeslaDist = nil, 40

                    local validBlocks = {}

                    for _, data in ipairs(cachedNukerBlocks) do
                        local obj = data.part
                        if obj and obj.Parent then
                            table.insert(validBlocks, data)
                            local dist = (obj.Position - locHrp.Position).Magnitude

                            if data.type == "Bed" and toggles.NukerBed then
                                local isMyBed = isMyTeamBed(data.orig) or isMyTeamBed(obj)
                                if not isMyBed and dist < closestBedDist then 
                                    closestBedDist = dist
                                    closestBed = obj 
                                end
                            
                            elseif data.type == "Tesla" and toggles.NukerTesla then
                                local isFriendly = isFriendlyTesla(data.orig) or isFriendlyTesla(obj)
                                if not isFriendly and dist < closestTeslaDist then 
                                    closestTeslaDist = dist
                                    closestTesla = obj 
                                end
                                
                            elseif data.type == "Ore" and toggles.NukerOre then
                                if dist < closestOreDist then 
                                    closestOreDist = dist
                                    closestOre = obj 
                                end
                            end
                        end
                    end
                    cachedNukerBlocks = validBlocks

                    local rawTarget = nil
                    if toggles.NukerPriority == "Bed" then 
                        rawTarget = closestBed or closestTesla or closestOre
                    elseif toggles.NukerPriority == "Tesla" then 
                        rawTarget = closestTesla or closestBed or closestOre
                    elseif toggles.NukerPriority == "Ore" then 
                        rawTarget = closestOre or closestBed or closestTesla
                    else
                        if closestBed and closestOre then
                            if closestBedDist < closestOreDist then 
                                rawTarget = closestBed 
                            else 
                                rawTarget = closestOre 
                            end
                        else 
                            rawTarget = closestBed or closestOre or closestTesla 
                        end
                    end

                    local lockedNukerBlock = nil

                    if rawTarget then
                        lockedNukerBlock = rawTarget
                        
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local excludeList = {char, cam}
                        for _, p in ipairs(Players:GetPlayers()) do 
                            if p.Character then table.insert(excludeList, p.Character) end 
                        end
                        if workspace:FindFirstChild("ItemDrops") then 
                            table.insert(excludeList, workspace.ItemDrops) 
                        end
                        params.FilterDescendantsInstances = excludeList
                        
                        local dirVec = rawTarget.Position - cam.CFrame.Position
                        local hit = workspace:Raycast(cam.CFrame.Position, dirVec, params)
                        
                        if hit and hit.Instance then
                            local inst = hit.Instance
                            if inst ~= rawTarget and inst.Parent ~= rawTarget.Parent and inst.Transparency < 1 and inst.CanCollide then
                                if not (isMyTeamBed(inst) or isMyTeamBed(inst.Parent) or isFriendlyTesla(inst) or isFriendlyTesla(inst.Parent)) then
                                    lockedNukerBlock = inst
                                end
                            end
                        end
                    end

                    if lockedNukerBlock then
                        if toggles.NukerHighlight then 
                            nukerHighlight.Adornee = lockedNukerBlock
                            nukerHighlight.Enabled = true 
                        else 
                            nukerHighlight.Enabled = false 
                        end
                        
                        local hp, maxHp = getBlockHp(lockedNukerBlock)
                        if type(hp) == "number" and type(maxHp) == "number" and maxHp > 0 then
                            nukerOreUI.Adornee = lockedNukerBlock
                            nukerOreUI.Enabled = true
                            local pct = math.clamp(hp / maxHp, 0, 1)
                            hpFill.Size = UDim2.new(pct, 0, 1, 0)
                            hpTxt.Text = math.floor(hp) .. " / " .. math.floor(maxHp)
                            
                            if pct > 0.5 then 
                                hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129) 
                            elseif pct > 0.25 then 
                                hpFill.BackgroundColor3 = Color3.fromRGB(245, 158, 11) 
                            else 
                                hpFill.BackgroundColor3 = Color3.fromRGB(239, 68, 68) 
                            end
                        else
                            nukerOreUI.Adornee = lockedNukerBlock
                            nukerOreUI.Enabled = true
                            hpFill.Size = UDim2.new(1, 0, 1, 0)
                            hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
                            hpTxt.Text = "MINING"
                        end

                        local DamageBlock = getDamageBlockRemote()
                        if DamageBlock then
                            local function smash(targetPart)
                                if not targetPart then return end
                                local bPos = targetPart:GetAttribute("blockPosition") or targetPart:GetAttribute("BlockPosition")
                                if not bPos and targetPart.Parent then 
                                    bPos = targetPart.Parent:GetAttribute("blockPosition") or targetPart.Parent:GetAttribute("BlockPosition") 
                                end
                                if typeof(bPos) ~= "Vector3" then 
                                    bPos = Vector3.new(math.round(targetPart.Position.X / 3), math.round(targetPart.Position.Y / 3), math.round(targetPart.Position.Z / 3)) 
                                end
                                local blockData = { 
                                    ["blockRef"] = { ["blockPosition"] = bPos }, 
                                    ["hitPosition"] = targetPart.Position, 
                                    ["hitNormal"] = Vector3.new(0, 1, 0) 
                                }
                                fireRemote(DamageBlock, blockData)
                            end
                            smash(lockedNukerBlock)
                        end
                    else
                        nukerHighlight.Enabled = false
                        nukerOreUI.Enabled = false
                    end
                else
                    nukerHighlight.Enabled = false
                    nukerOreUI.Enabled = false
                end
            else
                nukerHighlight.Enabled = false
                nukerOreUI.Enabled = false
            end
        else
            nukerHighlight.Enabled = false
            nukerOreUI.Enabled = false
        end
    end
end)
end -- END NUKER WRAPPER

-- ==========================================
-- FAST BREAK LOGIC
-- ==========================================
task.spawn(function()
    local mouse = localPlayer:GetMouse()
    while isRunning do
        task.wait(tonumber(toggles.FastBreakTimer) or 0.05)
        local char = localPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if toggles.FastBreak and char and hum and hum.Health > 0 and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local target = mouse.Target
            if target and target:IsA("BasePart") and not target.Parent:FindFirstChild("Humanoid") then
                pcall(function()
                    local DamageBlock = getDamageBlockRemote()
                    if DamageBlock then
                        local myInv = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
                        local currentEquipped = nil
                        for _, item in ipairs(char:GetChildren()) do
                            if (item:IsA("Model") or item:IsA("Tool") or item:IsA("Accessory")) and myInv and myInv:FindFirstChild(item.Name) then 
                                currentEquipped = myInv[item.Name]
                                break 
                            end
                        end

                        local toolType = "pickaxe"
                        local n = target.Name:lower()
                        if n:find("wood") or n:find("plank") or n:find("bed") then toolType = "axe" end
                        if n:find("wool") then toolType = "shears" end

                        local bestTool = nil
                        if myInv then
                            if toolType == "pickaxe" then 
                                bestTool = myInv:FindFirstChild("diamond_pickaxe") or myInv:FindFirstChild("iron_pickaxe") or myInv:FindFirstChild("stone_pickaxe") or myInv:FindFirstChild("wood_pickaxe")
                            elseif toolType == "axe" then 
                                bestTool = myInv:FindFirstChild("diamond_axe") or myInv:FindFirstChild("iron_axe") or myInv:FindFirstChild("stone_axe") or myInv:FindFirstChild("wood_axe")
                            elseif toolType == "shears" then 
                                bestTool = myInv:FindFirstChild("shears") 
                            end
                        end

                        local net = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
                        local equipRemote = net and net:FindFirstChild("SetInvItem")
                        
                        if bestTool and equipRemote then 
                            pcall(function() 
                                equipRemote:FireServer({["item"] = bestTool}) 
                            end) 
                        end

                        local bPos = target:GetAttribute("blockPosition") or target:GetAttribute("BlockPosition")
                        if not bPos and target.Parent then 
                            bPos = target.Parent:GetAttribute("blockPosition") or target.Parent:GetAttribute("BlockPosition") 
                        end
                        
                        if typeof(bPos) ~= "Vector3" then 
                            bPos = Vector3.new(math.round(target.Position.X / 3), math.round(target.Position.Y / 3), math.round(target.Position.Z / 3)) 
                        end

                        local blockData = { 
                            ["blockRef"] = { ["blockPosition"] = bPos }, 
                            ["hitPosition"] = mouse.Hit.Position, 
                            ["hitNormal"] = Vector3.new(0, 1, 0) 
                        }
                        
                        task.spawn(function() 
                            fireRemote(DamageBlock, blockData) 
                        end)

                        if currentEquipped and bestTool and currentEquipped ~= bestTool and equipRemote then 
                            pcall(function() 
                                equipRemote:FireServer({["item"] = currentEquipped}) 
                            end) 
                        end
                    end
                end)
            end
        end
    end
end)

-- ==========================================
-- AUTO BUY (ARMOR & SWORDS)
-- ==========================================
task.spawn(function()
    local cachedShops = {}
    local scanned = false
    
    local noSwordKits = {
        ["FROST_HAMMER_KIT"] = true,
        ["BARBARIAN"] = true
    }
    
    while isRunning do
        task.wait(0.5)
        if toggles.AutoBuy then
            local char = localPlayer.Character
            local locHrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if locHrp and hum and hum.Health > 0 then
                if not scanned then
                    for _, v in ipairs(workspace:GetDescendants()) do 
                        if v:IsA("Model") and (v.Name:lower():find("itemshop") or v.Name:lower():find("merchant") or v:GetAttribute("ShopId") == "1_item_shop") then 
                            table.insert(cachedShops, v) 
                        end 
                    end
                    scanned = true
                end

                local nearShop = false
                local shopRange = tonumber(toggles.AutoBuyRange) or 30
                
                for _, v in ipairs(cachedShops) do
                    if v and v.Parent then
                        local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                        if p and (p.Position - locHrp.Position).Magnitude <= shopRange then 
                            nearShop = true
                            break 
                        end
                    end
                end

                if nearShop then
                    local inv = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
                    if inv then
                        local aTier = 0
                        if inv:FindFirstChild("emerald_chestplate") or (char and char:FindFirstChild("emerald_chestplate")) then aTier = 4
                        elseif inv:FindFirstChild("diamond_chestplate") or (char and char:FindFirstChild("diamond_chestplate")) then aTier = 3
                        elseif inv:FindFirstChild("iron_chestplate") or (char and char:FindFirstChild("iron_chestplate")) then aTier = 2
                        elseif inv:FindFirstChild("leather_chestplate") or (char and char:FindFirstChild("leather_chestplate")) then aTier = 1
                        end

                        local sTier = 0
                        if inv:FindFirstChild("emerald_sword") or (char and char:FindFirstChild("emerald_sword")) then sTier = 4
                        elseif inv:FindFirstChild("diamond_sword") or (char and char:FindFirstChild("diamond_sword")) then sTier = 3
                        elseif inv:FindFirstChild("iron_sword") or (char and char:FindFirstChild("iron_sword")) then sTier = 2
                        elseif inv:FindFirstChild("stone_sword") or (char and char:FindFirstChild("stone_sword")) then sTier = 1
                        end

                        local currentKit = tostring(localPlayer:GetAttribute("PlayingAsKits") or "None"):upper()
                        if not toggles.AutoBuyArmor then aTier = 4 end
                        if not toggles.AutoBuySword or noSwordKits[currentKit] then sTier = 4 end

                        local targetType = nil
                        local targetTier = 0

                        if toggles.AutoBuyPriority == "Armor First" then
                            if aTier < 4 then targetType = "armor"; targetTier = aTier + 1
                            elseif sTier < 4 then targetType = "sword"; targetTier = sTier + 1 end
                        elseif toggles.AutoBuyPriority == "Swords First" then
                            if sTier < 4 then targetType = "sword"; targetTier = sTier + 1
                            elseif aTier < 4 then targetType = "armor"; targetTier = aTier + 1 end
                        else
                            if sTier <= aTier and sTier < 4 then targetType = "sword"; targetTier = sTier + 1 
                            elseif aTier < sTier and aTier < 4 then targetType = "armor"; targetTier = aTier + 1
                            elseif aTier < 4 then targetType = "armor"; targetTier = aTier + 1 end
                        end

                        if targetType then
                            local buyArgs = nil
                            local prefix = ""
                            
                            if targetType == "armor" then
                                if targetTier == 1 then prefix = "leather"; buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "leather_chestplate", ["price"] = 50, ["customDisplayName"] = "Leather Armor", ["superiorItems"] = { "iron_chestplate" }, ["currency"] = "iron", ["amount"] = 1, ["nextTier"] = "iron_chestplate", ["ignoredByKit"] = { "bigman", "tinker", "void_knight" }, ["spawnWithItems"] = { "leather_helmet", "leather_chestplate", "leather_boots" }, ["category"] = "Combat" }, ["shopId"] = "1_item_shop" } }
                                elseif targetTier == 2 then prefix = "iron"; buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "iron_chestplate", ["price"] = 120, ["prevTier"] = "leather_chestplate", ["customDisplayName"] = "Iron Armor", ["currency"] = "iron", ["category"] = "Combat", ["amount"] = 1, ["tiered"] = true, ["nextTier"] = "diamond_chestplate", ["spawnWithItems"] = { "iron_helmet", "iron_chestplate", "iron_boots" }, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" } }, ["shopId"] = "1_item_shop" } }
                                elseif targetTier == 3 then prefix = "diamond"; buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "diamond_chestplate", ["price"] = 8, ["prevTier"] = "iron_chestplate", ["customDisplayName"] = "Diamond Armor", ["currency"] = "emerald", ["category"] = "Combat", ["amount"] = 1, ["tiered"] = true, ["nextTier"] = "emerald_chestplate", ["spawnWithItems"] = { "diamond_helmet", "diamond_chestplate", "diamond_boots" }, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" } }, ["shopId"] = "1_item_shop" } }
                                elseif targetTier == 4 then prefix = "emerald"; buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "emerald_chestplate", ["price"] = 40, ["prevTier"] = "diamond_chestplate", ["customDisplayName"] = "Emerald Armor", ["currency"] = "emerald", ["amount"] = 1, ["tiered"] = true, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" }, ["spawnWithItems"] = { "emerald_helmet", "emerald_chestplate", "emerald_boots" }, ["category"] = "Combat" }, ["shopId"] = "1_item_shop" } }
                                end
                            elseif targetType == "sword" then
                                if targetTier == 1 then buyArgs = { { ["shopItem"] = { ["itemType"] = "stone_sword", ["amount"] = 1 }, ["shopId"] = "1_item_shop" } }
                                elseif targetTier == 2 then buyArgs = { { ["shopItem"] = { ["itemType"] = "iron_sword", ["amount"] = 1 }, ["shopId"] = "1_item_shop" } }
                                elseif targetTier == 3 then buyArgs = { { ["shopItem"] = { ["itemType"] = "diamond_sword", ["amount"] = 1 }, ["shopId"] = "1_item_shop" } }
                                elseif targetTier == 4 then buyArgs = { { ["shopItem"] = { ["itemType"] = "emerald_sword", ["amount"] = 1 }, ["shopId"] = "1_item_shop" } }
                                end
                            end

                            if buyArgs then
                                local purchaseRemote = getPurchaseRemote()
                                if purchaseRemote then
                                    local s = pcall(function() fireRemote(purchaseRemote, unpack(buyArgs)) end)
                                    if s and targetType == "armor" then
                                        task.wait(0.2)
                                        local equipRemote = getEquipRemote()
                                        if equipRemote then
                                            local h = inv:FindFirstChild(prefix .. "_helmet")
                                            local c = inv:FindFirstChild(prefix .. "_chestplate")
                                            local b = inv:FindFirstChild(prefix .. "_boots")
                                            if h then pcall(function() fireRemote(equipRemote, { item = h, armorSlot = 0 }) end) end
                                            if c then pcall(function() fireRemote(equipRemote, { item = c, armorSlot = 1 }) end) end
                                            if b then pcall(function() fireRemote(equipRemote, { item = b, armorSlot = 2 }) end) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO FROST HAMMER (ADETUNDE KIT)
-- ==========================================
do -- [AUTO HAMMER WRAPPER]
local hammerLevels = {strength = 0, speed = 0, shield = 0}

task.spawn(function()
    local lastUpgradeTick = 0
    while isRunning do
        task.wait(0.5)
        if toggles.AutoHammer then
            local currentKit = tostring(localPlayer:GetAttribute("PlayingAsKits") or "None"):upper()
            if currentKit == "FROST_HAMMER_KIT" then
                local invFolder = ReplicatedStorage:FindFirstChild("Inventories") or ReplicatedStorage:FindFirstChild("inventories")
                local myInv = invFolder and invFolder:FindFirstChild(localPlayer.Name)
                
                if myInv then
                    local crystal = myInv:FindFirstChild("frost_crystal")
                    local crystalAmt = 0
                    if crystal then
                        local amtAttr = crystal:GetAttribute("Amount") or crystal:GetAttribute("amount")
                        if amtAttr ~= nil then
                            crystalAmt = tonumber(amtAttr) or 0
                        else
                            crystalAmt = 1
                        end
                    end

                    if crystalAmt > 0 and tick() - lastUpgradeTick > 1.5 then
                        local mode = toggles.HammerDist or "3-2-2 (Max All)"
                        local p1 = (toggles.HammerP1 or "Strength"):lower()
                        local p2 = (toggles.HammerP2 or "Speed"):lower()
                        local p3 = (toggles.HammerP3 or "Shield"):lower()

                        local used = {[p1] = true}
                        if used[p2] then p2 = ("speed" ~= p1 and "speed") or ("shield" ~= p1 and "shield") or "strength" end
                        used[p2] = true
                        if used[p3] then p3 = ("shield" ~= p1 and "shield" ~= p2 and "shield") or ("strength" ~= p1 and "strength" ~= p2 and "strength") or "speed" end
                        
                        local plan = {}
                        if mode:find("3%-2%-2") then
                            plan = {
                                {s = p1, cost = 2, targetTier = 1}, {s = p2, cost = 2, targetTier = 1}, {s = p3, cost = 2, targetTier = 1},
                                {s = p1, cost = 5, targetTier = 2}, {s = p2, cost = 5, targetTier = 2}, {s = p3, cost = 5, targetTier = 2},
                                {s = p1, cost = 12, targetTier = 3}
                            }
                        elseif mode:find("3%-2%-0") then
                            plan = {
                                {s = p1, cost = 2, targetTier = 1}, {s = p1, cost = 5, targetTier = 2}, {s = p1, cost = 12, targetTier = 3},
                                {s = p2, cost = 2, targetTier = 1}, {s = p2, cost = 5, targetTier = 2}
                            }
                        elseif mode:find("3%-1%-1") then
                            plan = {
                                {s = p1, cost = 2, targetTier = 1}, {s = p2, cost = 2, targetTier = 1}, {s = p3, cost = 2, targetTier = 1},
                                {s = p1, cost = 5, targetTier = 2}, {s = p1, cost = 12, targetTier = 3}
                            }
                        elseif mode:find("2%-2%-1") then
                            plan = {
                                {s = p1, cost = 2, targetTier = 1}, {s = p2, cost = 2, targetTier = 1}, {s = p3, cost = 2, targetTier = 1},
                                {s = p1, cost = 5, targetTier = 2}, {s = p2, cost = 5, targetTier = 2}
                            }
                        end

                        for _, step in ipairs(plan) do
                            if hammerLevels[step.s] < step.targetTier then
                                if crystalAmt >= step.cost then
                                    lastUpgradeTick = tick()
                                    task.spawn(function()
                                        pcall(function()
                                            local net = ReplicatedStorage:FindFirstChild("rbxts_include").node_modules["@rbxts"].net.out._NetManaged
                                            local upgradeRemote = net:FindFirstChild("UpgradeFrostyHammer")
                                            if upgradeRemote then
                                                upgradeRemote:InvokeServer(step.s)
                                                hammerLevels[step.s] = step.targetTier
                                            end
                                        end)
                                    end)
                                end
                                break 
                            end
                        end
                    end
                end
            end
        end
    end
end)
end -- END HAMMER WRAPPER

-- ==========================================
-- EXTENDED RESOURCE PICKUP
-- ==========================================
task.spawn(function()
    while isRunning do
        task.wait(0.1)
        local char = localPlayer.Character
        local locHrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if toggles.ExtendedDrop and locHrp and hum and hum.Health > 0 then
            local itemDrops = workspace:FindFirstChild("ItemDrops")
            if itemDrops then
                local pickupRemote = ReplicatedStorage:FindFirstChild("rbxts_include")
                if pickupRemote then pickupRemote = pickupRemote.node_modules:FindFirstChild("@rbxts") end
                if pickupRemote then pickupRemote = pickupRemote.net.out._NetManaged:FindFirstChild("PickupItemDrop") end
                if pickupRemote then
                    local myPos = locHrp.Position
                    local range = toggles.ExtendedDropRange or 25
                    for _, drop in ipairs(itemDrops:GetChildren()) do
                        if drop:IsA("BasePart") or drop:IsA("Model") then
                            local posPart = drop:IsA("BasePart") and drop or drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")
                            if posPart then
                                if (posPart.Position - myPos).Magnitude <= range then
                                    task.spawn(function() 
                                        pcall(function() 
                                            fireRemote(pickupRemote, { ["itemDrop"] = drop }) 
                                        end) 
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- KILL MESSAGE / CHAT SPAMMER LOGIC
-- ==========================================
local chatQueue = {}
local lastChatTime = 0

local function isTeammate(plr)
    if plr == localPlayer then return true end
    if plr.Team and localPlayer.Team and plr.Team == localPlayer.Team then return true end
    
    local myTeamId = localPlayer:GetAttribute("Team") or localPlayer:GetAttribute("team")
    local theirTeamId = plr:GetAttribute("Team") or plr:GetAttribute("team")
    
    if myTeamId and theirTeamId and tostring(myTeamId) == tostring(theirTeamId) then 
        return true 
    end
    
    return false
end

task.spawn(function()
    while isRunning do
        task.wait(0.1)
        if #chatQueue > 0 then
            local delayRequired = tonumber(toggles.KillMsgDelay) or 3.5
            if tick() - lastChatTime >= delayRequired then
                local msg = table.remove(chatQueue, 1)
                lastChatTime = tick()
                task.spawn(function()
                    pcall(function()
                        local tcs = game:GetService("TextChatService")
                        if tcs and tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                            local targetChannel = nil
                            if tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral") then
                                targetChannel = tcs.TextChannels.RBXGeneral
                            end
                            
                            if targetChannel then
                                targetChannel:SendAsync(msg)
                            end
                        else
                            local legacyChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                            if legacyChat then
                                local req = legacyChat:FindFirstChild("SayMessageRequest")
                                if req then
                                    req:FireServer(msg, "All")
                                end
                            else
                                game:GetService("Players"):Chat(msg)
                            end
                        end
                    end)
                end)
            end
        end
    end
end)

local function hookDeathChat(plr, char)
    if not char then return end
    task.spawn(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        local ticks = 0
        while not hum and ticks < 20 do
            task.wait(0.2)
            if not char or not char.Parent then return end
            hum = char:FindFirstChildOfClass("Humanoid")
            ticks = ticks + 1
        end
        
        if hum then
            local isDead = false
            
            local function checkDeath()
                if hum.Health <= 0 and not isDead then
                    isDead = true
                    if toggles.KillMessage and not isTeammate(plr) then
                        local msg = tostring(toggles.KillMsgText or "GG {display}!")
                        msg = msg:gsub("{user}", plr.Name)
                        msg = msg:gsub("{display}", plr.DisplayName)
                        
                        local safeSuffixes = {"", " .", " ..", " !", " !!", " ~", " -", "  "}
                        local bypassStr = safeSuffixes[math.random(1, #safeSuffixes)]
                        
                        table.insert(chatQueue, msg .. bypassStr)
                    end
                elseif hum.Health > 0 and isDead then
                    isDead = false
                end
            end
            
            hum.Died:Connect(checkDeath)
            hum:GetPropertyChangedSignal("Health"):Connect(checkDeath)
        end
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        hookDeathChat(plr, char)
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then task.spawn(hookDeathChat, p, p.Character) end
    p.CharacterAdded:Connect(function(char) hookDeathChat(p, char) end)
end

-- ==========================================
-- ARMOR TRIMS LOGIC (24/7 OVERHAUL)
-- ==========================================
task.spawn(function()
    while isRunning do
        task.wait(0.5)
        local char = localPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if not char or not hum or hum.Health <= 0 then continue end

        if not toggles.ArmorTrims then
            for _, v in ipairs(char:GetChildren()) do
                if v:GetAttribute("IsCustomTrim") then
                    v:Destroy()
                end
            end
            char:SetAttribute("LastTrimState", nil)
            continue
        end

        local trimNum = toggles.TrimType:match("%d+") or "1"
        local currentTrimTag = "TrimState_" .. trimNum .. "_" .. tostring(toggles.TrimR) .. "_" .. tostring(toggles.TrimG) .. "_" .. tostring(toggles.TrimB) .. "_" .. tostring(toggles.TrimTrans) .. "_" .. tostring(toggles.TrimMaterial)
        
        local hasTrim = false
        for _, v in ipairs(char:GetChildren()) do
            if v:GetAttribute("IsCustomTrim") then hasTrim = true break end
        end

        if not hasTrim or char:GetAttribute("LastTrimState") ~= currentTrimTag then
            for _, v in ipairs(char:GetChildren()) do
                if v:GetAttribute("IsCustomTrim") then v:Destroy() end
            end

            local trimFolder = ReplicatedStorage:FindFirstChild("Assets")
            if trimFolder then trimFolder = trimFolder:FindFirstChild("ArmorTrims") end
            if trimFolder then trimFolder = trimFolder:FindFirstChild("trim_" .. trimNum) end

            if trimFolder then
                for _, trimAcc in ipairs(trimFolder:GetChildren()) do
                    if trimAcc:IsA("Accessory") then
                        local c = trimAcc:Clone()
                        c:SetAttribute("IsCustomTrim", true)
                        local handle = c:FindFirstChild("Handle")
                        if handle and handle:IsA("MeshPart") then
                            handle.TextureID = ""
                            handle.Color = Color3.fromRGB(toggles.TrimR, toggles.TrimG, toggles.TrimB)
                            handle.Transparency = toggles.TrimTrans
                            
                            local matName = tostring(toggles.TrimMaterial)
                            local targetMat = Enum.Material[matName] or Enum.Material.Neon
                            handle.Material = targetMat
                        end
                        hum:AddAccessory(c)
                    end
                end
                char:SetAttribute("LastTrimState", currentTrimTag)
            end
        else
            for _, v in ipairs(char:GetChildren()) do
                if v:GetAttribute("IsCustomTrim") then
                    local handle = v:FindFirstChild("Handle")
                    if handle then
                        handle.Color = Color3.fromRGB(toggles.TrimR, toggles.TrimG, toggles.TrimB)
                        handle.Transparency = toggles.TrimTrans
                        
                        local matName = tostring(toggles.TrimMaterial)
                        local targetMat = Enum.Material[matName] or Enum.Material.Neon
                        handle.Material = targetMat
                    end
                end
            end
        end
    end
end)

local cloudsFolder = workspace:FindFirstChild("Clouds")
if cloudsFolder then
    local function onCloudAdded()
        task.wait(0.1)
        updateClouds()
    end
    local cloudConn = cloudsFolder.ChildAdded:Connect(onCloudAdded)
    table.insert(connections, cloudConn)
    updateClouds()
end

task.spawn(function()
    if type(loadConfig) == "function" then
        loadConfig()
    end
    
    if type(uiVisuals) == "table" then
        for id, fn in pairs(uiVisuals) do 
            if type(id) == "string" and type(fn) == "function" then
                if not string.find(id, "_key") then 
                    task.spawn(fn)
                end
            end 
        end
    end
    
    if type(handleStaffScan) == "function" then
        handleStaffScan()
    end
end)
