print("Access Granted asdasdd !")
-- FEENWARE ULTIMATE

-- FEENWARE ULTIMATE
local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cam = workspace.CurrentCamera
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

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

-- THEME CONSTANTS 
local c_bg = Color3.fromRGB(15, 15, 15)
local c_bg2 = Color3.fromRGB(22, 22, 22)
local c_bg3 = Color3.fromRGB(30, 30, 30)
local c_gold = Color3.fromRGB(255, 215, 0)
local c_goldDark = Color3.fromRGB(180, 150, 0)
local c_text = Color3.fromRGB(220, 220, 220)
local c_textDim = Color3.fromRGB(130, 130, 130)

-- STATE TRACKING
local tracked = {}
local defaultToggles = {
	["BeeESP"] = false, ["MetalESP"] = false, ["StarESP"] = false, ["BoxESP"] = false,
	["ShowName"] = false, ["ShowTeam"] = false, ["ShowKit"] = false, ["ShowHealth"] = false, ["DevMode"] = false, 
	["KitRender"] = false, ["KitRenderOwnTeam"] = true, ["FarmESP"] = false, ["BeehiveESP"] = false, ["TaliyahESP"] = false, ["BedESP"] = false,
	["Trails"] = false, ["TrailRainbow"] = false, ["TrailBall"] = false,
	["AntiAFK"] = false, ["Freecam"] = false, ["FreecamSpeed"] = 2, 
	["SpinBot"] = false, ["SpinSpeed"] = 20, ["VoidJump"] = false, 
	["Fly"] = false, ["FlySpeed"] = 20, ["InfJump"] = false,
	["Speed"] = false, ["SpeedValue"] = 23, ["WallClimb"] = false,
	["KA"] = false, ["KASpeed"] = 0.1, ["KARange"] = 25, ["KAAngle"] = 360,
	["KAWallCheck"] = false, ["KARequireSword"] = false, ["KASwingAnim"] = false, ["KASwingSpeed"] = 1.0, ["KASwingRange"] = 25,
	["KATargetPlayer"] = true, ["KATargetNPC"] = false, ["KATargetDummy"] = false, ["KAPriority"] = "Distance",
	["FastBreak"] = false, ["FastBreakTimer"] = 0.05,
	["Nuker"] = false, ["NukerTimer"] = 0.1, ["NukerReqPickaxe"] = true, ["NukerReqAxe"] = false, ["NukerReqShears"] = false, ["NukerBed"] = true, ["NukerOre"] = false, ["NukerPriority"] = "Bed", ["NukerHighlight"] = false,
	["AutoBuyArmor"] = false,
	["FastDrop"] = false, ["FastDropSpeed"] = 5,
	["ExtendedDrop"] = false, ["ExtendedDropRange"] = 20,
	["StaffDetect"] = false, ["StaffLeave"] = false, ["StaffDestruct"] = false
}
local toggles = {}
for k,v in pairs(defaultToggles) do toggles[k] = v end

local hotkeys = {}
local uiVisuals = {} 
local boxTargetMode = "All"
local farmFilter = "Everything"
local expandedTeams = {}
local uiVisible = true
local connections = {}
local currentBindName = nil
local flyBodyVel = nil

-- RE-SETUP CHARACTER REFS
localPlayer.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
end)

-- CORE FUNCTIONS
local function addCorner(val, p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, val); c.Parent = p end
local function addPad(p, left) local pad = Instance.new("UIPadding", p); pad.PaddingLeft = UDim.new(0, left) end
local function makeDraggable(f, h)
	local d, ds, sp
	table.insert(connections, h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = f.Position end end))
	table.insert(connections, UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local del = i.Position - ds f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end))
	table.insert(connections, UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end))
end

-- CONFIG SAVING
local function saveConfig()
	local cfg = { t = toggles, h = {}, btm = boxTargetMode, ff = farmFilter }
	for k, v in pairs(hotkeys) do cfg.h[k] = v.Name end
	if type(writefile) == "function" then pcall(function() writefile("feenware_cfg.json", HttpService:JSONEncode(cfg)) end) end
end

local function loadConfig()
	if type(readfile) == "function" and type(isfile) == "function" and isfile("feenware_cfg.json") then
		local s, res = pcall(function() return HttpService:JSONDecode(readfile("feenware_cfg.json")) end)
		if s and type(res) == "table" then
			if res.t then for k, v in pairs(res.t) do toggles[k] = v end end
			if res.h then for k, v in pairs(res.h) do pcall(function() hotkeys[k] = Enum.KeyCode[v] end) end end
			boxTargetMode = res.btm or "All"
			farmFilter = res.ff or "Everything"
		end
	end
end

-- AUTO SAVE ON LEAVE
table.insert(connections, Players.PlayerRemoving:Connect(function(plr)
	if plr == localPlayer then saveConfig() end
end))

-- GUI ROOT
local zenWareGUI = Instance.new("ScreenGui")
zenWareGUI.Name = "FEENWARE_ULTIMATE"
zenWareGUI.ResetOnSpawn = false 
if gethui then zenWareGUI.Parent = gethui() else zenWareGUI.Parent = game.CoreGui end

-- UNINJECT / DESTRUCT FUNCTION
local function uninject() 
	saveConfig() -- Save on uninject
	for k, v in pairs(toggles) do if type(v) == "boolean" then toggles[k] = false end end
	for _, c in pairs(connections) do c:Disconnect() end
	for o, _ in pairs(tracked) do if tracked[o] and tracked[o].gui then tracked[o].gui:Destroy() end; if tracked[o] and tracked[o].info then tracked[o].info:Destroy() end; if tracked[o] and tracked[o].highlight then tracked[o].highlight:Destroy() end end
	if flyBodyVel then flyBodyVel:Destroy() end
	if cam.CameraType == Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Custom end
	local char = localPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then hum.WalkSpeed = 16; hum.AutoRotate = true end
	if zenWareGUI then zenWareGUI:Destroy() end
end

-- NOTIFICATION SYSTEM
local notifHolder = Instance.new("Frame", zenWareGUI)
notifHolder.Size = UDim2.new(0, 220, 1, -50); notifHolder.Position = UDim2.new(1, -230, 0, 0); notifHolder.BackgroundTransparency = 1
local notifLayout = Instance.new("UIListLayout", notifHolder); notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; notifLayout.Padding = UDim.new(0, 8)

local function notify(title, state)
	local f = Instance.new("Frame", notifHolder); f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundColor3 = c_bg2; f.BackgroundTransparency = 1; addCorner(6, f)
	local s = Instance.new("UIStroke", f); s.Color = state and c_gold or Color3.fromRGB(60, 60, 60); s.Transparency = 1
	local line = Instance.new("Frame", f); line.Size = UDim2.new(0, 4, 1, 0); line.BackgroundColor3 = state and c_gold or Color3.fromRGB(60, 60, 60); line.BorderSizePixel = 0; line.BackgroundTransparency = 1; addCorner(6, line)
	local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, -15, 1, 0); t.Position = UDim2.new(0, 10, 0, 0); t.BackgroundTransparency = 1; t.Text = title; t.TextColor3 = c_text; t.Font = Enum.Font.GothamBold; t.TextSize = 13; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextTransparency = 1
	TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 0}):Play()
	TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	task.delay(2.5, function()
		TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
		TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		task.wait(0.3); f:Destroy()
	end)
end

-- MAIN UI WINDOW
local mainUI = Instance.new("Frame", zenWareGUI)
mainUI.Size = UDim2.new(0, 300, 0, 620); mainUI.Position = UDim2.new(0.05, 0, 0.1, 0); mainUI.BackgroundColor3 = c_bg; addCorner(8, mainUI)
local titleFrame = Instance.new("Frame", mainUI); titleFrame.Size = UDim2.new(1, 0, 0, 50); titleFrame.BackgroundColor3 = c_bg2; addCorner(8, titleFrame); makeDraggable(mainUI, titleFrame)
local titleText = Instance.new("TextLabel", titleFrame); titleText.Size = UDim2.new(1, 0, 1, 0); titleText.Text = "FEENWARE"; titleText.TextColor3 = c_gold; titleText.Font = Enum.Font.GothamBlack; titleText.TextSize = 22; titleText.BackgroundTransparency = 1
local titleLine = Instance.new("Frame", titleFrame); titleLine.Size = UDim2.new(1, 0, 0, 2); titleLine.Position = UDim2.new(0, 0, 1, -2); titleLine.BackgroundColor3 = c_gold; titleLine.BorderSizePixel = 0

-- SEARCH BAR
local searchFrame = Instance.new("Frame", mainUI)
searchFrame.Size = UDim2.new(0.9, 0, 0, 30)
searchFrame.Position = UDim2.new(0.05, 0, 0, 55)
searchFrame.BackgroundColor3 = c_bg3
addCorner(6, searchFrame)

local searchBox = Instance.new("TextBox", searchFrame)
searchBox.Size = UDim2.new(1, -10, 1, 0)
searchBox.Position = UDim2.new(0, 10, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search features..."
searchBox.Text = "" 
searchBox.TextColor3 = c_text
searchBox.PlaceholderColor3 = c_textDim
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 12
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false

local scroll = Instance.new("ScrollingFrame", mainUI)
scroll.Size = UDim2.new(1, 0, 1, -95); scroll.Position = UDim2.new(0, 0, 0, 90); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = c_gold; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local listLayout = Instance.new("UIListLayout", scroll); listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; listLayout.Padding = UDim.new(0, 6)

local searchableItems = {}

-- SEARCH LOGIC
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = searchBox.Text:lower()
	for _, item in ipairs(searchableItems) do
		if q == "" or item.name:find(q) then
			item.container.Visible = true
		else
			item.container.Visible = false
		end
	end
end)

-- KIT RENDER FRAME
local kitFrame = Instance.new("Frame", zenWareGUI)
kitFrame.Size = UDim2.new(0, 380, 0, 520); kitFrame.Position = UDim2.new(0.35, 0, 0.2, 0); kitFrame.BackgroundColor3 = c_bg; kitFrame.Visible = false; addCorner(10, kitFrame); makeDraggable(kitFrame, kitFrame)
local kitStroke = Instance.new("UIStroke", kitFrame); kitStroke.Color = c_goldDark; kitStroke.Thickness = 1
local kitTitleTxt = Instance.new("TextLabel", kitFrame); kitTitleTxt.Size = UDim2.new(1, 0, 0, 45); kitTitleTxt.BackgroundTransparency = 1; kitTitleTxt.Text = "KIT RENDER"; kitTitleTxt.TextColor3 = c_gold; kitTitleTxt.Font = Enum.Font.GothamBlack; kitTitleTxt.TextSize = 20
local kitLineFrame = Instance.new("Frame", kitFrame); kitLineFrame.Size = UDim2.new(1, -30, 0, 1); kitLineFrame.Position = UDim2.new(0, 15, 0, 45); kitLineFrame.BackgroundColor3 = Color3.fromRGB(40,40,40); kitLineFrame.BorderSizePixel = 0
local kitScroll = Instance.new("ScrollingFrame", kitFrame); kitScroll.Size = UDim2.new(0.95, 0, 0.85, 0); kitScroll.Position = UDim2.new(0.025, 0, 0.12, 0); kitScroll.BackgroundTransparency = 1; kitScroll.ScrollBarThickness = 2; kitScroll.ScrollBarImageColor3 = c_gold; kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- UI GENERATORS
local function createSec(title)
	local f = Instance.new("Frame", scroll); f.Size = UDim2.new(0.9, 0, 0, 25); f.BackgroundTransparency = 1
	local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = " " .. title; t.TextColor3 = c_goldDark; t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(searchableItems, {name = title:lower(), container = f})
	return f
end

local function applyGoldTheme(target, state, title)
	target.Text = title .. (state and " [ON]" or " [OFF]")
	target.TextColor3 = state and c_bg or c_text
	target.BackgroundColor3 = state and c_gold or c_bg3
	local s = target:FindFirstChildOfClass("UIStroke"); if s then s.Color = state and c_gold or Color3.fromRGB(50, 50, 50) end
end

local function attachKeybind(btn, id, title)
	local kb = Instance.new("TextButton", btn); kb.Size = UDim2.new(0, 40, 1, -12); kb.Position = UDim2.new(1, -45, 0, 6); kb.BackgroundColor3 = c_bg; kb.TextColor3 = c_textDim; kb.Font = Enum.Font.Gotham; kb.TextSize = 10; addCorner(4, kb)
	local function updateKB() kb.Text = hotkeys[id] and "["..hotkeys[id].Name.."]" or "[+]" end
	uiVisuals[id.."_key"] = updateKB
	
	-- Instant Right-Click Unbind
	kb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			hotkeys[id] = nil
			updateKB()
			notify("Unbound " .. title, false)
			saveConfig()
		end
	end)
	
	kb.Activated:Connect(function() 
		currentBindName = id; 
		kb.Text = "..." 
		notify("Press key to bind (Del/Esc/R-Click to clear)", true)
	end)
	updateKB()
end

local function createToggle(id, title, parent, callback, conditionCheck)
	local container = Instance.new("Frame", parent or scroll); container.Size = UDim2.new(0.9, 0, 0, 38); container.BackgroundTransparency = 1
	local b = Instance.new("TextButton", container); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundColor3 = c_bg3; b.TextColor3 = c_text; b.Font = Enum.Font.GothamSemibold; b.TextSize = 13; b.TextXAlignment = Enum.TextXAlignment.Left; addCorner(6, b); addPad(b, 15)
	attachKeybind(b, id, title)
	local function updateVis() 
		applyGoldTheme(b, toggles[id], title)
		if id == "KitRender" then kitFrame.Visible = (toggles[id] and uiVisible) end
	end
	uiVisuals[id] = updateVis
	b.Activated:Connect(function() 
		if not toggles[id] and conditionCheck and not conditionCheck() then return end
		toggles[id] = not toggles[id]
		updateVis()
		if callback then callback() end
		notify(title .. (toggles[id] and " Enabled" or " Disabled"), toggles[id])
		saveConfig() 
	end)
	updateVis()
	table.insert(searchableItems, {name = title:lower(), container = container})
	return container
end

local function createExpandable(id, title, callback, conditionCheck)
	local container = Instance.new("Frame", scroll); container.Size = UDim2.new(0.9, 0, 0, 38); container.BackgroundTransparency = 1
	local row = Instance.new("Frame", container); row.Size = UDim2.new(1, 0, 0, 38); row.BackgroundTransparency = 1
	local b = Instance.new("TextButton", row); b.Size = UDim2.new(0.82, -5, 1, 0); b.BackgroundColor3 = c_bg3; b.TextColor3 = c_text; b.Font = Enum.Font.GothamSemibold; b.TextSize = 13; b.TextXAlignment = Enum.TextXAlignment.Left; addCorner(6, b); addPad(b, 15)
	attachKeybind(b, id, title)
	local gearBtn = Instance.new("TextButton", row); gearBtn.Size = UDim2.new(0.18, 0, 1, 0); gearBtn.Position = UDim2.new(0.82, 5, 0, 0); gearBtn.BackgroundColor3 = c_bg2; gearBtn.Text = "⚙"; gearBtn.TextColor3 = c_textDim; gearBtn.Font = Enum.Font.GothamBlack; gearBtn.TextSize = 16; addCorner(6, gearBtn)
	local subCont = Instance.new("Frame", container); subCont.Size = UDim2.new(1, 0, 0, 0); subCont.Position = UDim2.new(0, 0, 0, 44); subCont.Visible = false; subCont.BackgroundTransparency = 1; local subList = Instance.new("UIListLayout", subCont); subList.Padding = UDim.new(0, 4)
	gearBtn.Activated:Connect(function() subCont.Visible = not subCont.Visible; container.Size = subCont.Visible and UDim2.new(0.9, 0, 0, 44 + subList.AbsoluteContentSize.Y) or UDim2.new(0.9, 0, 0, 38) end)
	local function updateVis() 
		applyGoldTheme(b, toggles[id], title) 
		if id == "KitRender" then kitFrame.Visible = (toggles[id] and uiVisible) end
	end
	uiVisuals[id] = updateVis
	b.Activated:Connect(function() 
		if not toggles[id] and conditionCheck and not conditionCheck() then return end
		toggles[id] = not toggles[id]; 
		updateVis(); 
		if callback then callback() end
		notify(title .. (toggles[id] and " Enabled" or " Disabled"), toggles[id]); 
		saveConfig() 
	end)
	updateVis()
	table.insert(searchableItems, {name = title:lower(), container = container})
	return subCont
end

local function createSubOption(id, title, parent, isToggle)
	local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundColor3 = c_bg2; b.TextColor3 = c_textDim; b.Text = title; b.Font = Enum.Font.Gotham; b.TextSize = 12; addCorner(4, b)
	if isToggle then
		local function updateVis() b.Text = title .. (toggles[id] and " [ON]" or " [OFF]"); b.TextColor3 = toggles[id] and c_gold or c_textDim end
		uiVisuals[id] = updateVis; 
		b.Activated:Connect(function() 
			toggles[id] = not toggles[id]; 
			updateVis(); 
			saveConfig();
			notify(title .. (toggles[id] and " Enabled" or " Disabled"), toggles[id]) 
		end); 
		updateVis()
	end
	return b
end

local function createSlider(id, title, min, max, parent, isFloat)
	local cont = Instance.new("Frame", parent); cont.Size = UDim2.new(1, 0, 0, 45); cont.BackgroundTransparency = 1
	local lbl = Instance.new("TextLabel", cont); lbl.Size = UDim2.new(1, -10, 0, 20); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = c_textDim; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
	local bg = Instance.new("Frame", cont); bg.Size = UDim2.new(0.9, 0, 0, 6); bg.Position = UDim2.new(0.05, 0, 0, 25); bg.BackgroundColor3 = c_bg3; addCorner(3, bg)
	local fill = Instance.new("Frame", bg); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = c_gold; addCorner(3, fill)
	local btn = Instance.new("TextButton", bg); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
	local function updateVis()
		local val = toggles[id] or min; local pct = math.clamp((val - min) / (max - min), 0, 1)
		fill.Size = UDim2.new(pct, 0, 1, 0); lbl.Text = title .. ": " .. (isFloat and string.format("%.2f", val) or val)
	end
	uiVisuals[id] = updateVis
	local dragging = false
	btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local pct = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			local rawVal = min + ((max - min) * pct)
			toggles[id] = isFloat and rawVal or math.floor(rawVal)
			updateVis(); saveConfig()
		end
	end)
	updateVis()
end

local function addManualSearch(name, inst)
	table.insert(searchableItems, {name = name:lower(), container = inst})
end

-- LEAVE PARTY LOGIC
local function leaveParty()
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		rs:WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty"):FireServer()
	end)
end

-- STAFF DETECTOR LOGIC
local staffRoles = {
	["Anticheat Mod"] = true,
	["Anticheat Manager"] = true,
	["Owner"] = true
}

local function checkStaff(plr)
	if not toggles.StaffDetect then return end
	task.spawn(function()
		local s, role = pcall(function() return plr:GetRoleInGroup(5774246) end)
		if s and staffRoles[role] then
			notify("STAFF DETECTED: " .. plr.Name, false)
			if toggles.StaffLeave then leaveParty() end
			if toggles.StaffDestruct then uninject() end
		end
	end)
end

Players.PlayerAdded:Connect(checkStaff)

local function handleStaffScan()
	if toggles.StaffDetect then
		for _, p in pairs(Players:GetPlayers()) do checkStaff(p) end
	end
end

-- ==========================================
-- KA LOGIC (HYPER-OPTIMIZED & STATELESS)
-- ==========================================
local SwordHit = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SwordHit
local cachedTargets = {}

-- Dynamic Multi-Point Raycast
local function isTargetVisible(startPos, targetModel, ignoreList)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = ignoreList
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	for _, part in ipairs(targetModel:GetChildren()) do
		if part:IsA("BasePart") then
			local dir = part.Position - startPos
			local hit = workspace:Raycast(startPos, dir, params)
			if not hit then
				return true 
			end
		end
	end
	
	return false 
end

-- Hyper-Optimized Target Cacher (No deep descendants lag)
task.spawn(function()
	while zenWareGUI.Parent do
		task.wait(0.5) 
		local newCache = {}
		
		local function scanFolder(folder)
			if not folder then return end
			for _, obj in ipairs(folder:GetChildren()) do
				if obj:IsA("Model") and obj ~= character and not Players:GetPlayerFromCharacter(obj) then
					local hum = obj:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						table.insert(newCache, obj)
					end
				end
			end
		end
		
		scanFolder(workspace)
		if workspace:FindFirstChild("Live") then scanFolder(workspace.Live) end
		
		cachedTargets = newCache
	end
end)

-- Main Attack Loop
task.spawn(function()
	local SetInvItemRemote = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts")
	if SetInvItemRemote then SetInvItemRemote = SetInvItemRemote.net.out._NetManaged:FindFirstChild("SetInvItem") end
	
	local swingAnimInst = Instance.new("Animation")
	swingAnimInst.AnimationId = "rbxassetid://4947108314"
	local loadedSwingAnim = nil
	local currentAnimHum = nil
	local lastSwingTime = 0

	while zenWareGUI.Parent do
		task.wait(toggles.KASpeed or 0.1)
		
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		
		-- Master abort condition (death, unequipped, etc.)
		if not toggles.KA or not char or not hrp or not hum or hum.Health <= 0 then
			continue
		end
		
		-- Inventory scanning
		local invFolder = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
		local equippedItem = nil
		
		if char and invFolder then
			for _, item in ipairs(char:GetChildren()) do
				if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
					local found = invFolder:FindFirstChild(item.Name)
					if found then
						equippedItem = found
						break
					end
				end
			end
		end

		-- Verify what we are holding
		local isHoldingSword = false
		if equippedItem then
			local n = equippedItem.Name:lower()
			if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("rageblade") then
				isHoldingSword = true
			end
		end

		-- Master Requirement Check
		if toggles.KARequireSword and not isHoldingSword then
			continue
		end

		-- Determine best sword for spoofing if needed
		local bestSword = nil
		if isHoldingSword then
			bestSword = equippedItem
		elseif invFolder then
			local priorityWeapons = {
				"emerald_sword", "diamond_sword", "iron_sword", "stone_sword", "wood_sword", 
				"rageblade", "emerald_dao", "diamond_dao", "iron_dao", "stone_dao", "wood_dao",
				"emerald_scythe", "diamond_scythe", "iron_scythe", "stone_scythe", "wood_scythe",
				"emerald_dagger", "diamond_dagger", "iron_dagger", "stone_dagger", "wood_dagger"
			}
			for _, sName in ipairs(priorityWeapons) do
				local w = invFolder:FindFirstChild(sName)
				if w then bestSword = w; break end
			end
			if not bestSword then
				for _, w in ipairs(invFolder:GetChildren()) do
					local n = w.Name:lower()
					if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") then 
						bestSword = w 
						break 
					end
				end
			end
		end

		-- If we have nothing to hit with, skip
		local weaponToUse = bestSword or equippedItem
		if not weaponToUse then continue end

		-- Range and Angle setup
		local range = toggles.KARange or 25
		local maxAngle = (toggles.KAAngle or 360) / 2 
		local targetGroups = {Player = {}, NPC = {}, Dummy = {}}
		
		-- Gather Targets
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= localPlayer and p.Character then
				local phum = p.Character:FindFirstChildOfClass("Humanoid")
				if phum and phum.Health > 0 then table.insert(targetGroups.Player, p.Character) end
			end
		end
		for _, npc in ipairs(cachedTargets) do
			if npc and npc.Parent then
				local nhum = npc:FindFirstChildOfClass("Humanoid")
				if nhum and nhum.Health > 0 then 
					if npc.Name:lower():find("dummy") then table.insert(targetGroups.Dummy, npc)
					else table.insert(targetGroups.NPC, npc) end
				end
			end
		end
		
		-- Target Processing
		local closestPlayer, pDist = nil, math.huge
		local closestNPC, nDist = nil, math.huge
		local closestDummy, dDist = nil, math.huge

		local function checkTargetGroup(groupList)
			local cTarget, cDist = nil, math.huge
			for _, model in ipairs(groupList) do
				local targetHRP = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
				if targetHRP then
					local dirVec = targetHRP.Position - hrp.Position
					local dist = dirVec.Magnitude
					if dist <= range then
						local dotProduct = hrp.CFrame.LookVector:Dot(dirVec.Unit)
						local angleToTarget = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
						if angleToTarget <= maxAngle then
							local isBlocked = false
							if toggles.KAWallCheck then isBlocked = not isTargetVisible(hrp.Position, model, {char, model}) end
							if not isBlocked and dist < cDist then
								cDist = dist
								cTarget = model
							end
						end
					end
				end
			end
			return cTarget, cDist
		end

		if toggles.KATargetPlayer then closestPlayer, pDist = checkTargetGroup(targetGroups.Player) end
		if toggles.KATargetNPC then closestNPC, nDist = checkTargetGroup(targetGroups.NPC) end
		if toggles.KATargetDummy then closestDummy, dDist = checkTargetGroup(targetGroups.Dummy) end
		
		-- Priority Selection
		local targetEnemy = nil
		local finalEnemyDist = math.huge
		
		if toggles.KAPriority == "Player" then
			targetEnemy = closestPlayer or closestNPC or closestDummy
			finalEnemyDist = closestPlayer and pDist or (closestNPC and nDist or dDist)
		elseif toggles.KAPriority == "NPC" then
			targetEnemy = closestNPC or closestPlayer or closestDummy
			finalEnemyDist = closestNPC and nDist or (closestPlayer and pDist or dDist)
		elseif toggles.KAPriority == "Dummy" then
			targetEnemy = closestDummy or closestPlayer or closestNPC
			finalEnemyDist = closestDummy and dDist or (closestPlayer and pDist or nDist)
		else -- Distance
			local allValid = {}
			if closestPlayer then table.insert(allValid, {m=closestPlayer, d=pDist}) end
			if closestNPC then table.insert(allValid, {m=closestNPC, d=nDist}) end
			if closestDummy then table.insert(allValid, {m=closestDummy, d=dDist}) end
			table.sort(allValid, function(a,b) return a.d < b.d end)
			if #allValid > 0 then 
				targetEnemy = allValid[1].m 
				finalEnemyDist = allValid[1].d
			end
		end

		-- Execution Core
		if targetEnemy then
			local targetHRP = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy.PrimaryPart or targetEnemy:FindFirstChildWhichIsA("BasePart")
			if targetHRP then
				local direction = (targetHRP.Position - hrp.Position).Unit
				
				-- Reach Spoofing
				local reachOffset = math.clamp(finalEnemyDist - 14, 0, 14.4)
				local fakePos = hrp.Position + (direction * reachOffset)
				
				local args = {
					[1] = {
						["entityInstance"] = targetEnemy,
						["chargedAttack"] = { ["chargeRatio"] = 0 },
						["validate"] = {
							["targetPosition"] = { ["value"] = targetHRP.Position },
							["raycast"] = {
								["cursorDirection"] = { ["value"] = direction },
								["cameraPosition"] = { ["value"] = fakePos }
							},
							["selfPosition"] = { ["value"] = fakePos }
						},
						["weapon"] = weaponToUse
					}
				}
				
				-- Run hit sequence sequentially in a thread to match precise game timing
				task.spawn(function()
					local needsSpoof = (weaponToUse ~= equippedItem) and SetInvItemRemote
					
					-- Phase 1: Switch to Sword
					if needsSpoof then
						pcall(function() SetInvItemRemote:InvokeServer({hand = weaponToUse}) end)
					end
					
					-- Phase 2: Hit
					pcall(function() SwordHit:FireServer(unpack(args)) end)
					
					-- Phase 3: Instantly revert back to Original Item
					if needsSpoof and equippedItem then
						pcall(function() SetInvItemRemote:InvokeServer({hand = equippedItem}) end)
					end
					
					-- Visual Animation
					if toggles.KASwingAnim then
						if finalEnemyDist <= (toggles.KASwingRange or 25) then
							local now = tick()
							local animCooldown = 0.45 / (toggles.KASwingSpeed or 1.0)
							if now - lastSwingTime >= animCooldown then
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
												loadedSwingAnim:AdjustSpeed(toggles.KASwingSpeed or 1.0)
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
end)

-- ESP LOGIC
local function getESPConfig(obj)
	if not obj or not obj.Name then return nil end
	local n = obj.Name:lower()
	if n:find("melon") then return Color3.fromRGB(0, 255, 0), "Melon", "Farm" end
	if n:find("carrot") then return Color3.fromRGB(255, 255, 0), "Carrot", "Farm" end
	if n:find("pumpkin") then return Color3.fromRGB(255, 128, 0), "Pumpkin", "Farm" end
	if n:find("beehive") then return Color3.fromRGB(255, 200, 0), "Beehive", "Farm" end
	if n:find("chicken_egg_block") then return Color3.fromRGB(255, 170, 255), "Taliyah", "Farm" end
	if n:find("bed") and not n:find("bedrock") then return Color3.fromRGB(255, 50, 50), "Bed", "Farm" end
	if n:find("star") then
		if n:find("vitality") or n:find("health") then return Color3.new(0, 1, 0), "Health Star", "World"
		else return Color3.new(1, 0.5, 0), "Crit Star", "World" end
	end
	if n:find("metal") or obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal", "World" end
	if n:find("bee") and not n:find("beehive") then return Color3.new(1, 1, 0), "Bee", "World" end
	return nil
end

local function removeESP(obj)
	if tracked[obj] then
		if tracked[obj].gui then tracked[obj].gui:Destroy() end
		if tracked[obj].info then tracked[obj].info:Destroy() end
		if tracked[obj].highlight then tracked[obj].highlight:Destroy() end
		tracked[obj] = nil
	end
end

local function createESP(obj, isPlayer)
	if tracked[obj] then return end
	local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
	if not targetPart and not isPlayer then return end
	local root = obj:FindFirstChild("HumanoidRootPart") or targetPart
	local col, typeStr, method = getESPConfig(obj)
	if isPlayer then method = "Player" end
	if not method then return end

	if method == "Farm" then
		local hl = Instance.new("Highlight", targetPart); hl.Name = "ZenHL"; hl.FillColor = col; hl.FillTransparency = 0.5; hl.OutlineColor = col; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = false
		local marker = Instance.new("BillboardGui", targetPart); marker.Name = "ZenMarker"; marker.AlwaysOnTop = true; marker.Size = UDim2.fromOffset(180, 35); marker.StudsOffset = Vector3.new(0, 5, 0); marker.Enabled = false
		local markerTxt = Instance.new("TextLabel", marker); markerTxt.Size = UDim2.fromScale(1, 1); markerTxt.BackgroundTransparency = 1; markerTxt.TextColor3 = col; markerTxt.TextStrokeTransparency = 0.5; markerTxt.Font = Enum.Font.GothamBold; markerTxt.TextSize = 16
		tracked[obj] = { mode = "Farm", highlight = hl, info = marker, textLabel = markerTxt, espType = typeStr, part = targetPart }
	elseif method == "World" then
		local m = Instance.new("BillboardGui", root); m.AlwaysOnTop = true; m.Size = UDim2.fromOffset(100, 30); m.StudsOffset = Vector3.new(0,3,0); m.Enabled = false
		local t = Instance.new("TextLabel", m); t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1; t.TextColor3 = col; t.Font = Enum.Font.GothamBold; t.TextSize = 14
		tracked[obj] = { mode = "World", info = m, textLabel = t, espType = typeStr, part = root }
	elseif method == "Player" then
		local info = Instance.new("BillboardGui", root); info.Name = "ZenMarker"; info.AlwaysOnTop = true; info.Size = UDim2.fromOffset(250, 100); info.StudsOffset = Vector3.new(0, 7.5, 0); info.Enabled = false
		local tl = Instance.new("TextLabel", info); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.TextSize = 16; tl.TextStrokeTransparency = 0.5; tl.TextYAlignment = Enum.TextYAlignment.Bottom
		local b = Instance.new("BillboardGui", root); b.Name = "ZenBox"; b.AlwaysOnTop = true; b.Size = UDim2.fromScale(4.5, 6.5); b.Enabled = false
		local f = Instance.new("Frame", b); f.Size = UDim2.fromScale(1,1); f.BackgroundTransparency = 1; local s = Instance.new("UIStroke", f); s.Thickness = 2
		tracked[obj] = { mode = "Player", gui = b, info = info, textLabel = tl, stroke = s, player = Players:GetPlayerFromCharacter(obj), part = root }
	end
end

-- BUILD UI LAYOUT
createSec("MOVEMENT & COMBAT")

local kaSub = createExpandable("KA", "KA")
createSlider("KASpeed", "Wait", 0.01, 2.0, kaSub, true)
createSlider("KARange", "Studs", 5, 100, kaSub, false)
createSlider("KAAngle", "Angle (FOV)", 10, 360, kaSub, false)
createSubOption("KAWallCheck", "WALL CHECK", kaSub, true)
createSubOption("KARequireSword", "REQUIRE SWORD HELD", kaSub, true)
createSubOption("KASwingAnim", "SWING ANIMATION", kaSub, true)
createSlider("KASwingRange", "ANIM RANGE", 5, 100, kaSub, false)
createSlider("KASwingSpeed", "ANIM SPEED", 0.1, 3.0, kaSub, true)

createSubOption("KATargetPlayer", "TARGET: PLAYER", kaSub, true)
createSubOption("KATargetNPC", "TARGET: NPC", kaSub, true)
createSubOption("KATargetDummy", "TARGET: DUMMY", kaSub, true)

-- Priority Mode Button
local kaPrio = createSubOption("KAPriority", "PRIO: DISTANCE", kaSub, false)
uiVisuals.KAPriority = function() kaPrio.Text = "PRIO: " .. toggles.KAPriority:upper() end
kaPrio.Activated:Connect(function() 
	if toggles.KAPriority == "Distance" then toggles.KAPriority = "Player"
	elseif toggles.KAPriority == "Player" then toggles.KAPriority = "NPC"
	elseif toggles.KAPriority == "NPC" then toggles.KAPriority = "Dummy"
	else toggles.KAPriority = "Distance" end
	uiVisuals.KAPriority()
	saveConfig()
	notify("KA Priority: " .. toggles.KAPriority:upper(), true)
end)

local spSub = createExpandable("Speed", "SPEED")
createSlider("SpeedValue", "Rate", 16, 50, spSub, false)

local flSub = createExpandable("Fly", "FLY")
createSlider("FlySpeed", "Speed", 10, 100, flSub, false)

createToggle("InfJump", "INF JUMP")
createToggle("VoidJump", "VOID JUMP")
createToggle("WallClimb", "CRAWLER")

local sbSub = createExpandable("SpinBot", "SPINBOT")
createSlider("SpinSpeed", "Speed", 10, 100, sbSub, false)

local fcSub = createExpandable("Freecam", "FREECAM")
createSlider("FreecamSpeed", "Speed", 1, 10, fcSub, false)

local trSub = createExpandable("Trails", "TRAILS")
createSubOption("TrailRainbow", "RAINBOW", trSub, true)
createSubOption("TrailBall", "BALL", trSub, true)

createToggle("AntiAFK", "ANTI-AFK")

createSec("VISUALS")
local bSub = createExpandable("BoxESP", "BOXES")
local tM = createSubOption("TM", "TARGET: ALL", bSub, false)
uiVisuals.TM = function() tM.Text = "TARGET: " .. boxTargetMode:upper() end
tM.Activated:Connect(function() 
	boxTargetMode = (boxTargetMode == "All" and "Teams" or boxTargetMode == "Teams" and "Enemy" or "All")
	uiVisuals.TM()
	saveConfig()
	notify("Box Target Mode: " .. boxTargetMode:upper(), true)
end)
-- Added ShowHealth here for Player HP text
for _, o in pairs({"ShowName", "ShowTeam", "ShowKit", "ShowHealth", "DevMode"}) do createSubOption(o, o:upper(), bSub, true) end

createSec("WORLD")
for _, o in pairs({"Metal", "Star", "Bee"}) do createToggle(o.."ESP", o:upper().." ESP") end

createSec("FARMING")
createToggle("BeehiveESP", "BEEHIVES")
createToggle("TaliyahESP", "TALIYAH")
createToggle("BedESP", "BEDS")
local fSub = createExpandable("FarmESP", "CROPS")
local fF = createSubOption("FF", "FILTER: EVERYTHING", fSub, false)
uiVisuals.FF = function() fF.Text = "FILTER: " .. farmFilter:upper() end
fF.Activated:Connect(function() 
	farmFilter = (farmFilter == "Everything" and "Melon Only" or farmFilter == "Melon Only" and "Carrot Only" or farmFilter == "Carrot Only" and "Pumpkin Only" or "Everything")
	uiVisuals.FF()
	saveConfig()
	notify("Farm Filter: " .. farmFilter:upper(), true)
end)

createSec("MISC")

local fbSub = createExpandable("FastBreak", "FAST BREAK")
createSlider("FastBreakTimer", "Wait Time", 0.01, 0.5, fbSub, true)

local nuSub = createExpandable("Nuker", "NUKER")
createSlider("NukerTimer", "Break Speed", 0.01, 1.0, nuSub, true)
createSubOption("NukerReqPickaxe", "REQUIRE PICKAXE", nuSub, true)
createSubOption("NukerReqAxe", "REQUIRE AXE", nuSub, true)
createSubOption("NukerReqShears", "REQUIRE SHEARS", nuSub, true)
createSubOption("NukerBed", "DESTROY BEDS", nuSub, true)
createSubOption("NukerOre", "DESTROY ORES", nuSub, true)

local nuPrio = createSubOption("NukerPriority", "PRIO: BED", nuSub, false)
uiVisuals.NukerPriority = function() nuPrio.Text = "PRIO: " .. toggles.NukerPriority:upper() end
nuPrio.Activated:Connect(function() 
	if toggles.NukerPriority == "Bed" then toggles.NukerPriority = "Ore"
	elseif toggles.NukerPriority == "Ore" then toggles.NukerPriority = "Distance"
	else toggles.NukerPriority = "Bed" end
	uiVisuals.NukerPriority()
	saveConfig()
	notify("Nuker Priority: " .. toggles.NukerPriority:upper(), true)
end)

createSubOption("NukerHighlight", "HIGHLIGHT TARGET", nuSub, true)

-- AUTO BUY ARMOR FEATURE
local abSub = createExpandable("AutoBuyArmor", "AUTO BUY ARMOR")

local fdSub = createExpandable("FastDrop", "FAST DROP")
createSlider("FastDropSpeed", "Drop Multiplier", 1, 40, fdSub, false)

local edSub = createExpandable("ExtendedDrop", "EXTENDED PICKUP")
createSlider("ExtendedDropRange", "Range (Studs)", 8, 40, edSub, false)

local krSub = createExpandable("KitRender", "KIT RENDER")
createSubOption("KitRenderOwnTeam", "INCLUDE OWN TEAM", krSub, true)

local sdSub = createExpandable("StaffDetect", "STAFF DETECT", handleStaffScan)
createSubOption("StaffLeave", "LEAVE PARTY", sdSub, true)
createSubOption("StaffDestruct", "DESTRUCT", sdSub, true)

local lParty = Instance.new("TextButton", scroll); lParty.Size = UDim2.new(0.9, 0, 0, 38); lParty.BackgroundColor3 = Color3.fromRGB(20, 20, 50); lParty.TextColor3 = c_text; lParty.Text = "LEAVE PARTY"; lParty.Font = Enum.Font.GothamBold; lParty.TextSize = 13; addCorner(6, lParty)
lParty.Activated:Connect(function() notify("Leaving Party...", true); leaveParty() end)
addManualSearch("leave party", lParty)

-- RESET AND UNINJECT BUTTONS
local disAll = Instance.new("TextButton", scroll); disAll.Size = UDim2.new(0.9, 0, 0, 38); disAll.BackgroundColor3 = Color3.fromRGB(60, 40, 0); disAll.TextColor3 = c_text; disAll.Text = "DISABLE ALL TOGGLES"; disAll.Font = Enum.Font.GothamBold; disAll.TextSize = 13; addCorner(6, disAll)
disAll.Activated:Connect(function()
	for k, v in pairs(toggles) do 
		if type(v) == "boolean" then toggles[k] = false end 
	end
	for id, fn in pairs(uiVisuals) do if not id:find("_key") then fn() end end
	notify("All toggles disabled.", false)
	saveConfig()
end)
addManualSearch("disable all toggles", disAll)

local unbAll = Instance.new("TextButton", scroll); unbAll.Size = UDim2.new(0.9, 0, 0, 38); unbAll.BackgroundColor3 = Color3.fromRGB(60, 20, 60); unbAll.TextColor3 = c_text; unbAll.Text = "UNBIND ALL HOTKEYS"; unbAll.Font = Enum.Font.GothamBold; unbAll.TextSize = 13; addCorner(6, unbAll)
unbAll.Activated:Connect(function()
	hotkeys = {}
	for id, fn in pairs(uiVisuals) do if id:find("_key") then fn() end end
	notify("All hotkeys unbound.", false)
	saveConfig()
end)
addManualSearch("unbind all hotkeys", unbAll)

local rstAll = Instance.new("TextButton", scroll); rstAll.Size = UDim2.new(0.9, 0, 0, 38); rstAll.BackgroundColor3 = Color3.fromRGB(80, 40, 10); rstAll.TextColor3 = c_text; rstAll.Text = "RESET ALL SETTINGS"; rstAll.Font = Enum.Font.GothamBold; rstAll.TextSize = 13; addCorner(6, rstAll)
rstAll.Activated:Connect(function()
	for k, v in pairs(defaultToggles) do toggles[k] = v end
	hotkeys = {}
	for id, fn in pairs(uiVisuals) do fn() end
	notify("All settings and hotkeys reset to default.", true)
	saveConfig()
end)
addManualSearch("reset all settings", rstAll)

local unBtn = Instance.new("TextButton", scroll); unBtn.Size = UDim2.new(0.9, 0, 0, 38); unBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 10); unBtn.TextColor3 = Color3.new(1,0.5,0.5); unBtn.Text = "UNINJECT"; unBtn.Font = Enum.Font.GothamBold; unBtn.TextSize = 14; addCorner(6, unBtn); addPad(unBtn, 0)
unBtn.Activated:Connect(uninject)
addManualSearch("uninject", unBtn)

-- LOGIC & PHYSICS LOOPS
table.insert(connections, workspace.DescendantAdded:Connect(function(v) 
	task.wait(0.1)
	if getESPConfig(v) then createESP(v, false) end
end))
table.insert(connections, workspace.DescendantRemoving:Connect(function(v) removeESP(v) end))
for _, v in pairs(workspace:GetDescendants()) do if getESPConfig(v) then createESP(v, false) end end

local function onPlayerAdded(p) table.insert(connections, p.CharacterAdded:Connect(function(char) task.wait(0.5); createESP(char, true) end)); if p.Character then createESP(p.Character, true) end end
table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end

local camAngleX, camAngleY, lastTrail, lastVoidJump = 0, 0, tick(), 0
local freecamActive = false

-- Inputs for Freecam and InfJump
table.insert(connections, UIS.InputChanged:Connect(function(input)
	if toggles.Freecam and input.UserInputType == Enum.UserInputType.MouseMovement then
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			camAngleX = camAngleX - (input.Delta.X * 0.4)
			camAngleY = math.clamp(camAngleY - (input.Delta.Y * 0.4), -89, 89)
			cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(0, math.rad(camAngleX), 0) * CFrame.Angles(math.rad(camAngleY), 0, 0)
		else UIS.MouseBehavior = Enum.MouseBehavior.Default end
	end
end))

table.insert(connections, UIS.InputBegan:Connect(function(input, g)
	if g then return end
	if input.KeyCode == Enum.KeyCode.Space and toggles.InfJump then
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then 
			hrp.Velocity = Vector3.new(hrp.Velocity.X, 40, hrp.Velocity.Z) 
		end
	end
end))

-- MAIN BACKGROUND LOOP
table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	local char = localPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local cp = cam.CFrame.Position
	
	-- FREECAM
	if toggles.Freecam then
		if not freecamActive then
			freecamActive = true; local rx, ry, rz = cam.CFrame:ToEulerAnglesYXZ(); camAngleX = math.deg(ry); camAngleY = math.deg(rx)
			if hrp then hrp.Anchored = true end 
		end
		cam.CameraType = Enum.CameraType.Scriptable; local move = Vector3.new(); local spd = toggles.FreecamSpeed
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then move += cam.CFrame.UpVector end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then move -= cam.CFrame.UpVector end
		cam.CFrame = cam.CFrame + (move * (spd * 0.5))
	else
		if freecamActive then
			freecamActive = false; if hrp and hrp.Anchored then hrp.Anchored = false end
			cam.CameraType = Enum.CameraType.Custom; cam.CameraSubject = hum; UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	-- SPINBOT
	if toggles.SpinBot and hrp and hum and not toggles.Freecam then
		hum.AutoRotate = false -- Disables camera/movement locking rotation
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(toggles.SpinSpeed), 0)
	elseif hum and not toggles.SpinBot then
		hum.AutoRotate = true
	end

	-- FLY
	if toggles.Fly and hrp then
		if not flyBodyVel or not flyBodyVel.Parent then
			flyBodyVel = Instance.new("BodyVelocity")
			flyBodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
			flyBodyVel.Parent = hrp
		end
		local move = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		local yVel = 0
		if UIS:IsKeyDown(Enum.KeyCode.Space) then yVel = toggles.FlySpeed end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then yVel = -toggles.FlySpeed end
		flyBodyVel.Velocity = Vector3.new(move.X * toggles.FlySpeed, yVel, move.Z * toggles.FlySpeed)
	else
		if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
	end

	-- SPEED
	if toggles.Speed and hrp and hum and not toggles.Fly then
		if hum.MoveDirection.Magnitude > 0 then
			-- Calculate bonus speed based on 16 (default walk speed)
			local bonusSpeed = toggles.SpeedValue - 16
			if bonusSpeed > 0 then
				-- Translate via CFrame instead of overwriting WalkSpeed.
				-- This allows Sprinting, Gloops, and Potions to still work naturally!
				hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (bonusSpeed * dt))
			end
		end
	end

	-- WALL CLIMB
	if toggles.WallClimb and hrp and UIS:IsKeyDown(Enum.KeyCode.W) then
		local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
		local hit = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, params)
		if hit then hrp.Velocity = Vector3.new(hrp.Velocity.X, 40, hrp.Velocity.Z) end
	end

	-- VOID JUMP
	if toggles.VoidJump and hrp and hum then
		if tick() - lastVoidJump > 0.6 then
			if hum:GetState() == Enum.HumanoidStateType.Freefall and hrp.Velocity.Y < -15 then
				local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
				local groundHit = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), params)
				if not groundHit then
					hrp.Velocity = Vector3.new(hrp.Velocity.X, 65, hrp.Velocity.Z)
					lastVoidJump = tick()
				end
			end
		end
	end

	-- TRAILS
	if toggles.Trails and hrp and hum then
		if hum.MoveDirection.Magnitude > 0 and tick() - lastTrail > 0.08 then
			lastTrail = tick()
			local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.Material = Enum.Material.Neon
			p.Size = toggles.TrailBall and Vector3.new(1.2,1.2,1.2) or Vector3.new(1,1,1); p.Shape = toggles.TrailBall and Enum.PartType.Ball or Enum.PartType.Block
			p.CFrame = hrp.CFrame * CFrame.new(0, -1, 0); p.Color = toggles.TrailRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or c_gold; p.Parent = workspace
			TweenService:Create(p, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play(); game.Debris:AddItem(p, 1.1)
		end
	end

	-- ESP UPDATES
	for obj, data in pairs(tracked) do
		if obj and obj.Parent then
			if data.mode == "Farm" then
				local act = false
				if data.espType == "Beehive" and toggles.BeehiveESP then act = true; data.textLabel.Text = (obj:GetAttribute("Level") or 0) .. " BEES"
				elseif data.espType == "Taliyah" and toggles.TaliyahESP then act = true; data.textLabel.Text = "EGG"
				elseif data.espType == "Bed" and toggles.BedESP then act = true; data.textLabel.Text = "[BED]"
				elseif toggles.FarmESP and data.espType ~= "Beehive" and data.espType ~= "Taliyah" and data.espType ~= "Bed" then
					if farmFilter == "Everything" or farmFilter:find(data.espType) then act = true; data.textLabel.Text = "[" .. data.espType:upper() .. "]" end 
				end
				data.highlight.Enabled = act; data.info.Enabled = act
			elseif data.mode == "World" then
				local act = toggles[data.espType:gsub(" ","") .. "ESP"] or (data.espType:find("Star") and toggles.StarESP)
				data.info.Enabled = act; if act then data.textLabel.Text = data.espType .. " [" .. math.floor((data.part.Position - cp).Magnitude) .. "m]" end
			elseif data.mode == "Player" then
				local act = toggles.BoxESP
				if data.player == localPlayer and not toggles.DevMode then act = false 
				else
					local team = (data.player.Team == localPlayer.Team)
					if boxTargetMode == "Enemy" and team then act = false end
					if boxTargetMode == "Teams" and not team then act = false end
				end
				data.gui.Enabled = act; data.info.Enabled = act
				if act then
					data.stroke.Color = data.player.TeamColor.Color; data.textLabel.TextColor3 = data.player.TeamColor.Color
					local l = {}
					if toggles.ShowName then table.insert(l, data.player.DisplayName) end
					if toggles.ShowTeam then table.insert(l, data.player.Team and data.player.Team.Name or "Neutral") end
					if toggles.ShowKit then local rK = tostring(data.player:GetAttribute("PlayingAsKits") or "None"):upper(); table.insert(l, "[" .. (kitTranslations[rK] or rK) .. "]") end
					
					-- PLAYER HP ADDED HERE
					if toggles.ShowHealth then
						local phum = data.player.Character and data.player.Character:FindFirstChild("Humanoid")
						local hp = phum and math.floor(phum.Health) or 0
						table.insert(l, "[" .. hp .. " HP]")
					end
					
					data.textLabel.Text = table.concat(l, "\n")
				end
			end
		else removeESP(obj) end
	end
end))

-- KIT RENDER LOOP
local function updateRender()
	if not kitScroll:FindFirstChild("UIListLayout") then
		local layout = Instance.new("UIListLayout", kitScroll)
		layout.Padding = UDim.new(0, 8)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	end
	
	-- Hide all existing elements to reuse them
	for _, child in ipairs(kitScroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = false
		end
	end
	
	local layoutIndex = 0
	for _, team in pairs(Teams:GetTeams()) do
		local pList = team:GetPlayers()
		
		-- Filter out own team if setting is disabled
		if not toggles.KitRenderOwnTeam and localPlayer.Team == team then
			continue
		end
		
		if #pList > 0 then
			layoutIndex = layoutIndex + 1
			local headerId = "TeamHeader_" .. team.Name
			local h = kitScroll:FindFirstChild(headerId)
			
			if not h then
				h = Instance.new("TextButton", kitScroll)
				h.Name = headerId
				h.Size = UDim2.new(1, 0, 0, 28)
				h.BackgroundColor3 = Color3.fromRGB(35,35,35)
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
				
				h.Activated:Connect(function() 
					expandedTeams[team.Name] = not expandedTeams[team.Name]
					updateRender() 
				end)
			end
			
			h.Text = "  " .. team.Name:upper()
			h.TextColor3 = team.TeamColor.Color
			h.Arrow.Text = expandedTeams[team.Name] and "▼" or "▶"
			h.Arrow.TextColor3 = c_gold
			h.LayoutOrder = layoutIndex
			h.Visible = true
			
			if expandedTeams[team.Name] then
				for _, p in pairs(pList) do
					layoutIndex = layoutIndex + 1
					local cardId = "PlayerCard_" .. p.UserId
					local card = kitScroll:FindFirstChild(cardId)
					
					if not card then
						card = Instance.new("Frame", kitScroll)
						card.Name = cardId
						card.Size = UDim2.new(0.95, 0, 0, 65)
						card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
						addCorner(8, card)
						
						local stroke = Instance.new("UIStroke", card)
						stroke.Name = "Border"
						stroke.Thickness = 1.5
						stroke.Transparency = 0.3
						
						local img = Instance.new("ImageLabel", card)
						img.Name = "Avatar"
						img.Size = UDim2.new(0, 46, 0, 46)
						img.Position = UDim2.new(0, 8, 0.5, -23)
						img.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
						addCorner(24, img)
						
						local tName = Instance.new("TextLabel", card)
						tName.Name = "PName"
						tName.Size = UDim2.new(1, -70, 0.33, 0)
						tName.Position = UDim2.new(0, 62, 0, 5)
						tName.BackgroundTransparency = 1
						tName.TextColor3 = Color3.new(1, 1, 1)
						tName.Font = Enum.Font.GothamBold
						tName.TextSize = 14
						tName.TextXAlignment = Enum.TextXAlignment.Left
						
						local tKit = Instance.new("TextLabel", card)
						tKit.Name = "PKit"
						tKit.Size = UDim2.new(1, -70, 0.33, 0)
						tKit.Position = UDim2.new(0, 62, 0.33, 1)
						tKit.BackgroundTransparency = 1
						tKit.Font = Enum.Font.GothamSemibold
						tKit.TextSize = 12
						tKit.TextXAlignment = Enum.TextXAlignment.Left
						
						local tClan = Instance.new("TextLabel", card)
						tClan.Name = "PClan"
						tClan.Size = UDim2.new(1, -70, 0.33, 0)
						tClan.Position = UDim2.new(0, 62, 0.66, -1)
						tClan.BackgroundTransparency = 1
						tClan.Font = Enum.Font.Gotham
						tClan.TextSize = 11
						tClan.TextXAlignment = Enum.TextXAlignment.Left
						tClan.RichText = true
					end
					
					local rK = tostring(p:GetAttribute("PlayingAsKits") or "None"):upper()
					local kitName = kitTranslations[rK] or rK
					
					local clanText = ""
					pcall(function()
						local tags = p:FindFirstChild("Tags")
						if tags then
							local zero = tags:FindFirstChild("0") or tags:FindFirstChild(0)
							if zero then
								clanText = tostring(zero.Value)
							end
						end
					end)
					
					card.Border.Color = team.TeamColor.Color
					card.PName.Text = p.DisplayName
					card.PKit.Text = kitName
					card.PKit.TextColor3 = team.TeamColor.Color
					
					if clanText and clanText ~= "" then
						card.PClan.Text = "CLAN: " .. clanText
						card.PClan.TextColor3 = Color3.new(1, 1, 1)
					else
						card.PClan.Text = "CLAN: NONE"
						card.PClan.TextColor3 = Color3.fromRGB(130, 130, 130)
					end
					
					-- Only fetch thumbnail if not already set
					if card.Avatar.Image == "" then
						pcall(function() card.Avatar.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
					end
					
					card.LayoutOrder = layoutIndex
					card.Visible = true
				end
			end
		end
	end
end
task.spawn(function() while zenWareGUI.Parent and task.wait(0.5) do if toggles.KitRender and kitFrame.Visible then updateRender() end end end)

-- KEYBINDS INPUT
UIS.InputBegan:Connect(function(i, g)
	if currentBindName then
		local keyName = i.KeyCode.Name
		
		-- Always allow unbinding via these keys, bypassing chat/menu interference (g)
		if i.KeyCode == Enum.KeyCode.Backspace or i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Delete then
			hotkeys[currentBindName] = nil
			notify("Unbound " .. currentBindName:gsub("ESP", " ESP"), false)
			local temp = currentBindName
			currentBindName = nil
			if uiVisuals[temp.."_key"] then uiVisuals[temp.."_key"]() end
			saveConfig()
			return
		end
		
		if g then return end -- Don't bind if they are typing in chat
		
		-- Hotkey Conflict Warning Logic
		local conflict = nil
		for id, k in pairs(hotkeys) do
			if k == i.KeyCode and id ~= currentBindName then
				conflict = id
				break
			end
		end
		
		if conflict then
			notify("WARNING: ["..keyName.."] is already used by "..conflict:gsub("ESP", " ESP").."!", false)
			return -- Stop here so currentBindName stays active and they have to press something else
		else
			hotkeys[currentBindName] = i.KeyCode
			notify("Bound " .. currentBindName:gsub("ESP", " ESP") .. " to [" .. keyName .. "]", true)
			local temp = currentBindName
			currentBindName = nil
			if uiVisuals[temp.."_key"] then uiVisuals[temp.."_key"]() end
			saveConfig()
		end
		return
	end
	
	if g then return end -- Don't trigger toggles if they are typing in chat
	
	-- Toggle UI visibility
	if i.KeyCode == Enum.KeyCode.RightShift then
		uiVisible = not uiVisible; mainUI.Visible = uiVisible
		if toggles.KitRender then kitFrame.Visible = uiVisible end
	end
	
	-- Trigger stored hotkeys
	for id, k in pairs(hotkeys) do
		if i.KeyCode == k then
			toggles[id] = not toggles[id]; 
			if uiVisuals[id] then uiVisuals[id]() end
			local cleanName = string.gsub(id, "ESP", " ESP")
			notify(string.upper(cleanName) .. (toggles[id] and " Enabled" or " Disabled"), toggles[id])
			saveConfig()
		end
	end
end)

-- ANTI-AFK
localPlayer.Idled:Connect(function()
	if toggles.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end)

-- ==========================================
-- FAST BREAK LOGIC (MOUSE/GRID BASED)
-- ==========================================
task.spawn(function()
	local mouse = localPlayer:GetMouse()
	while zenWareGUI.Parent do
		task.wait(toggles.FastBreakTimer or 0.05)
		local char = localPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if toggles.FastBreak and char and hum and hum.Health > 0 and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local target = mouse.Target
			if target and target:IsA("BasePart") and not target.Parent:FindFirstChild("Humanoid") then
				
				-- FIX: Only damage if holding a pickaxe/axe/shears to prevent placement glitches
				local holdingMiningTool = false
				if char then
					for _, item in ipairs(char:GetChildren()) do
						if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
							local name = item.Name:lower()
							if name:find("pickaxe") or name:find("axe") or name:find("shears") then
								holdingMiningTool = true
								break
							end
						end
					end
				end

				if holdingMiningTool then
					pcall(function()
						local DamageBlock = ReplicatedStorage:FindFirstChild("rbxts_include")
						if DamageBlock then
							DamageBlock = DamageBlock.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("DamageBlock")
						end
						
						if DamageBlock then
							-- Bedwars 3x3x3 Grid Calculation
							local gridX = math.round(target.Position.X / 3)
							local gridY = math.round(target.Position.Y / 3)
							local gridZ = math.round(target.Position.Z / 3)
							
							local args = {
								[1] = {
									["blockRef"] = {
										["blockPosition"] = Vector3.new(gridX, gridY, gridZ)
									},
									["hitPosition"] = mouse.Hit.Position,
									["hitNormal"] = Vector3.new(0, 1, 0)
								}
							}
							
							task.spawn(function()
								pcall(function() DamageBlock:InvokeServer(unpack(args)) end)
							end)
						end
					end)
				end
			end
		end
	end
end)

-- ==========================================
-- AUTO BUY ARMOR FEATURE
-- ==========================================
task.spawn(function()
	local purchaseRemote = ReplicatedStorage:FindFirstChild("rbxts_include")
	if purchaseRemote then purchaseRemote = purchaseRemote.node_modules:FindFirstChild("@rbxts") end
	if purchaseRemote then purchaseRemote = purchaseRemote.net.out._NetManaged:FindFirstChild("BedwarsPurchaseItem") end
	
	local equipRemote = ReplicatedStorage:FindFirstChild("rbxts_include")
	if equipRemote then equipRemote = equipRemote.node_modules:FindFirstChild("@rbxts") end
	if equipRemote then equipRemote = equipRemote.net.out._NetManaged:FindFirstChild("SetArmorInvItem") end

	while zenWareGUI.Parent do
		task.wait(0.5)
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.AutoBuyArmor or not hrp or not hum or hum.Health <= 0 then continue end
		
		local nearShop = false
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and (v.Name:lower():find("itemshop") or v.Name:lower():find("merchant") or v:GetAttribute("ShopId") == "1_item_shop") then
				local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
				if p and (p.Position - hrp.Position).Magnitude < 30 then
					nearShop = true
					break
				end
			end
		end
		
		if nearShop then
			local inv = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
			if not inv then continue end
			
			local currentTier = 0
			if inv:FindFirstChild("emerald_chestplate") or (char and char:FindFirstChild("emerald_chestplate")) then currentTier = 4
			elseif inv:FindFirstChild("diamond_chestplate") or (char and char:FindFirstChild("diamond_chestplate")) then currentTier = 3
			elseif inv:FindFirstChild("iron_chestplate") or (char and char:FindFirstChild("iron_chestplate")) then currentTier = 2
			elseif inv:FindFirstChild("leather_chestplate") or (char and char:FindFirstChild("leather_chestplate")) then currentTier = 1
			end

			local buyArgs = nil
			local prefix = ""

			if currentTier == 0 then
				prefix = "leather"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "leather_chestplate", ["price"] = 50, ["customDisplayName"] = "Leather Armor", ["superiorItems"] = { "iron_chestplate" }, ["currency"] = "iron", ["amount"] = 1, ["nextTier"] = "iron_chestplate", ["ignoredByKit"] = { "bigman", "tinker", "void_knight" }, ["spawnWithItems"] = { "leather_helmet", "leather_chestplate", "leather_boots" }, ["category"] = "Combat" }, ["shopId"] = "1_item_shop" } }
			elseif currentTier == 1 then
				prefix = "iron"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "iron_chestplate", ["price"] = 120, ["prevTier"] = "leather_chestplate", ["customDisplayName"] = "Iron Armor", ["currency"] = "iron", ["category"] = "Combat", ["amount"] = 1, ["tiered"] = true, ["nextTier"] = "diamond_chestplate", ["spawnWithItems"] = { "iron_helmet", "iron_chestplate", "iron_boots" }, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" } }, ["shopId"] = "1_item_shop" } }
			elseif currentTier == 2 then
				prefix = "diamond"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "diamond_chestplate", ["price"] = 8, ["prevTier"] = "iron_chestplate", ["customDisplayName"] = "Diamond Armor", ["currency"] = "emerald", ["category"] = "Combat", ["amount"] = 1, ["tiered"] = true, ["nextTier"] = "emerald_chestplate", ["spawnWithItems"] = { "diamond_helmet", "diamond_chestplate", "diamond_boots" }, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" } }, ["shopId"] = "1_item_shop" } }
			elseif currentTier == 3 then
				prefix = "emerald"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "emerald_chestplate", ["price"] = 40, ["prevTier"] = "diamond_chestplate", ["customDisplayName"] = "Emerald Armor", ["currency"] = "emerald", ["amount"] = 1, ["tiered"] = true, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" }, ["spawnWithItems"] = { "emerald_helmet", "emerald_chestplate", "emerald_boots" }, ["category"] = "Combat" }, ["shopId"] = "1_item_shop" } }
			end

			if buyArgs and purchaseRemote then
				local s = pcall(function() purchaseRemote:InvokeServer(unpack(buyArgs)) end)
				if s and equipRemote then
					task.wait(0.2)
					local h = inv:FindFirstChild(prefix .. "_helmet")
					local c = inv:FindFirstChild(prefix .. "_chestplate")
					local b = inv:FindFirstChild(prefix .. "_boots")
					if h then pcall(function() equipRemote:InvokeServer({ item = h, armorSlot = 0 }) end) end
					if c then pcall(function() equipRemote:InvokeServer({ item = c, armorSlot = 1 }) end) end
					if b then pcall(function() equipRemote:InvokeServer({ item = b, armorSlot = 2 }) end) end
				end
			end
		end
	end
end)

-- ==========================================
-- NUKER LOGIC (PURE RAYCAST TARGETING & LOCK)
-- ==========================================
local cachedNukerBlocks = {}

-- Setup the Highlight Instance for the Nuker
local nukerHighlight = Instance.new("Highlight")
nukerHighlight.Name = "NukerHighlight"
nukerHighlight.FillColor = Color3.fromRGB(255, 50, 50)
nukerHighlight.OutlineColor = Color3.fromRGB(255, 200, 0)
nukerHighlight.FillTransparency = 0.5
nukerHighlight.OutlineTransparency = 0.1
nukerHighlight.Parent = zenWareGUI
nukerHighlight.Enabled = false

-- Cacher for Nuker (updates every 1 second to avoid lag spikes)
task.spawn(function()
	while zenWareGUI.Parent do
		task.wait(1)
		local blocks = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local n = obj.Name:lower()
				if n:find("bed") and not n:find("bedrock") then
					table.insert(blocks, obj)
				elseif n == "iron_ore_mesh_block" then
					table.insert(blocks, obj)
				end
			end
		end
		cachedNukerBlocks = blocks
	end
end)

-- Main Nuker Loop
task.spawn(function()
	local lockedNukerBlock = nil
	local lockedRawTarget = nil

	while zenWareGUI.Parent do
		task.wait(toggles.NukerTimer or 0.1)
		
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.Nuker or not char or not hrp or not hum or hum.Health <= 0 then 
			nukerHighlight.Enabled = false
			lockedNukerBlock = nil
			lockedRawTarget = nil
			continue 
		end
		
		-- Check Specific Tool requirements
		local holdingPickaxe = false
		local holdingAxe = false
		local holdingShears = false
		
		if char then
			for _, item in ipairs(char:GetChildren()) do
				if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
					local name = item.Name:lower()
					if name:find("pickaxe") then holdingPickaxe = true end
					if name:find("axe") and not name:find("pickaxe") then holdingAxe = true end
					if name:find("shears") then holdingShears = true end
				end
			end
		end

		local requiresTool = toggles.NukerReqPickaxe or toggles.NukerReqAxe or toggles.NukerReqShears
		if requiresTool then
			local hasRequired = false
			if toggles.NukerReqPickaxe and holdingPickaxe then hasRequired = true end
			if toggles.NukerReqAxe and holdingAxe then hasRequired = true end
			if toggles.NukerReqShears and holdingShears then hasRequired = true end
			if not hasRequired then 
				nukerHighlight.Enabled = false
				continue 
			end
		end

		-- VALIDATE LOCKED TARGET (Nuker won't randomly switch blocks anymore!)
		if lockedNukerBlock then
			if not lockedNukerBlock:IsDescendantOf(workspace) or not lockedNukerBlock.CanCollide or lockedNukerBlock.Transparency >= 1 or not hrp or (lockedNukerBlock.Position - hrp.Position).Magnitude > 32 then
				lockedNukerBlock = nil
				lockedRawTarget = nil
			end
		end
		
		if not lockedNukerBlock then
			local closestBed = nil
			local closestBedDist = 30
			local closestOre = nil
			local closestOreDist = 30
			
			for _, obj in ipairs(cachedNukerBlocks) do
				if obj and obj.Parent then
					local n = obj.Name:lower()
					local dist = (obj.Position - hrp.Position).Magnitude
					
					if toggles.NukerBed and n:find("bed") and not n:find("bedrock") then
						-- COLOR & ATTRIBUTE BASED BED PROTECTION
						local isMyBed = false
						local myTeam = localPlayer.Team
						
						if myTeam then
							local myColor = myTeam.TeamColor.Color
							local myTeamName = myTeam.Name:lower():gsub(" team", "")
							local shortTeam = myTeamName ~= "" and string.split(myTeamName, " ")[1] or ""
							
							-- 1. Name verification
							if shortTeam ~= "" and (n:find(shortTeam) or (obj.Parent and obj.Parent.Name:lower():find(shortTeam))) then 
								isMyBed = true 
							end
							
							-- 2. Direct Color Verification (Checks bed parts)
							if not isMyBed then
								local function checkColor(part)
									if part:IsA("BasePart") then
										local pColor = part.Color
										local diff = math.abs(pColor.R - myColor.R) + math.abs(pColor.G - myColor.G) + math.abs(pColor.B - myColor.B)
										if diff < 0.1 then return true end
									end
									return false
								end
								
								if checkColor(obj) then isMyBed = true end
								
								if not isMyBed and obj.Parent and obj.Parent.Name:lower():find("bed") then
									for _, p in ipairs(obj.Parent:GetChildren()) do
										if checkColor(p) then
											isMyBed = true
											break
										end
									end
								end
							end
							
							-- 3. Attribute verification hierarchy
							local myTeamId1 = localPlayer:GetAttribute("Team")
							local myTeamId2 = localPlayer:GetAttribute("TeamId")
							
							local curr = obj
							while curr and curr ~= workspace and not isMyBed do
								local cId1 = curr:GetAttribute("Team")
								local cId2 = curr:GetAttribute("TeamId")
								
								if (myTeamId1 ~= nil and cId1 ~= nil and tostring(cId1) == tostring(myTeamId1)) or 
								   (myTeamId2 ~= nil and cId2 ~= nil and tostring(cId2) == tostring(myTeamId2)) then
									isMyBed = true
									break
								end
								curr = curr.Parent
							end
						end
						
						if not isMyBed and dist < closestBedDist then
							closestBedDist = dist
							closestBed = obj
						end
						
					elseif toggles.NukerOre and n == "iron_ore_mesh_block" then
						if dist < closestOreDist then
							closestOreDist = dist
							closestOre = obj
						end
					end
				end
			end
			
			-- Priority System
			local rawTarget = nil
			if toggles.NukerPriority == "Bed" then
				rawTarget = closestBed or closestOre
			elseif toggles.NukerPriority == "Ore" then
				rawTarget = closestOre or closestBed
			else -- Distance
				if closestBed and closestOre then
					if closestBedDist < closestOreDist then
						rawTarget = closestBed
					else
						rawTarget = closestOre
					end
				else
					rawTarget = closestBed or closestOre
				end
			end
			
			if rawTarget then
				local exposed = false
				local closestProtector = nil
				
				-- Prepare True Line-of-Sight Raycast
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				
				local excludeList = {char}
				for _, p in ipairs(Players:GetPlayers()) do
					if p.Character then table.insert(excludeList, p.Character) end
				end
				if workspace:FindFirstChild("ItemDrops") then table.insert(excludeList, workspace.ItemDrops) end
				params.FilterDescendantsInstances = excludeList
				
				-- Target parts to check raycast against
				local partsToCheck = {}
				if rawTarget == closestBed and rawTarget.Parent and rawTarget.Parent.Name:lower():find("bed") then
					for _, p in ipairs(rawTarget.Parent:GetChildren()) do
						if p:IsA("BasePart") then table.insert(partsToCheck, p) end
					end
				else
					table.insert(partsToCheck, rawTarget)
				end
				
				local cPDist = math.huge
				-- Shoots raycasts from Camera, Chest, Head, and both sides to guarantee it finds 1-block openings!
				local startPositions = {
					cam.CFrame.Position, 
					hrp.Position, 
					hrp.Position + Vector3.new(0, 1.5, 0),
					hrp.Position + Vector3.new(1.2, 0, 0),
					hrp.Position + Vector3.new(-1.2, 0, 0)
				}
				
				for _, part in ipairs(partsToCheck) do
					for _, startPos in ipairs(startPositions) do
						local dir = part.Position - startPos
						local hit = workspace:Raycast(startPos, dir.Unit * (dir.Magnitude + 2), params)
						
						if hit and hit.Instance then
							local hName = hit.Instance.Name:lower()
							-- Check if the raycast cleanly hit the actual target directly
							local isTarget = (hit.Instance == part) or (hit.Instance == rawTarget) or (hit.Instance.Parent and hit.Instance.Parent == rawTarget.Parent) or hName:find("bed") or hName == "iron_ore_mesh_block"
							
							if isTarget then
								exposed = true
								break
							else
								-- The raycast hit a protective wall! Ensure we only target solid blocks
								if hit.Instance.CanCollide then
									local hitDist = (hit.Position - startPos).Magnitude
									if hitDist < cPDist then
										cPDist = hitDist
										closestProtector = hit.Instance
									end
								end
							end
						else
							exposed = true
							break
						end
					end
					if exposed then break end
				end
				
				lockedRawTarget = rawTarget
				lockedNukerBlock = (not exposed and closestProtector) and closestProtector or rawTarget
			end
		end
		
		if lockedNukerBlock then
			if toggles.NukerHighlight then
				nukerHighlight.Adornee = lockedNukerBlock
				nukerHighlight.Enabled = true
			else
				nukerHighlight.Enabled = false
			end
			
			local DamageBlock = ReplicatedStorage:FindFirstChild("rbxts_include")
			if DamageBlock then
				DamageBlock = DamageBlock.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("DamageBlock")
			end
			
			if DamageBlock then
				local function smash(targetPart)
					if not targetPart then return end
					local gridX = math.round(targetPart.Position.X / 3)
					local gridY = math.round(targetPart.Position.Y / 3)
					local gridZ = math.round(targetPart.Position.Z / 3)
					
					local args = {
						[1] = {
							["blockRef"] = {
								["blockPosition"] = Vector3.new(gridX, gridY, gridZ)
							},
							["hitPosition"] = targetPart.Position,
							["hitNormal"] = Vector3.new(0, 1, 0)
						}
					}
					
					task.spawn(function()
						pcall(function() DamageBlock:InvokeServer(unpack(args)) end)
					end)
				end
				
				-- Pure Outer-Block execution
				smash(lockedNukerBlock)
				if lockedRawTarget and lockedRawTarget ~= lockedNukerBlock then
					smash(lockedRawTarget)
				end
			end
		else
			nukerHighlight.Enabled = false
		end
	end
end)

-- ==========================================
-- EXTENDED RESOURCE PICKUP
-- ==========================================
task.spawn(function()
	while zenWareGUI.Parent do
		task.wait(0.1)
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if toggles.ExtendedDrop and hrp and hum and hum.Health > 0 then
			local itemDrops = workspace:FindFirstChild("ItemDrops")
			if itemDrops then
				local pickupRemote = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts")
				if pickupRemote then pickupRemote = pickupRemote.net.out._NetManaged:FindFirstChild("PickupItemDrop") end
				
				if pickupRemote then
					local myPos = hrp.Position
					local range = toggles.ExtendedDropRange or 25
					for _, drop in ipairs(itemDrops:GetChildren()) do
						if drop:IsA("BasePart") or drop:IsA("Model") then
							local posPart = drop:IsA("BasePart") and drop or drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")
							if posPart then
								if (posPart.Position - myPos).Magnitude <= range then
									task.spawn(function()
										pcall(function()
											pickupRemote:InvokeServer({
												["itemDrop"] = drop
											})
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
-- FAST DROP HOOK
-- ==========================================
pcall(function()
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		if getgenv()._fastDropping then return oldNamecall(self, ...) end

		if toggles.FastDrop and method == "InvokeServer" and tostring(self) == "DropItem" then
			local args = {...}
			task.spawn(function()
				getgenv()._fastDropping = true
				local dropMult = math.floor(toggles.FastDropSpeed or 5)
				-- the original fire handles the first drop, so loop dropMult-1 times
				for i = 1, dropMult - 1 do
					pcall(function() self:InvokeServer(unpack(args)) end)
					task.wait(0.01)
				end
				getgenv()._fastDropping = false
			end)
		end
		return oldNamecall(self, ...)
	end)
end)

loadConfig()
-- Fixed initialization so both toggles AND visual hotkeys load instantly on screen
for id, fn in pairs(uiVisuals) do if not id:find("_key") then fn() end end
handleStaffScan()
