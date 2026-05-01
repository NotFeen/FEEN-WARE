local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Kit Translation Dictionary
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

-- Configuration & State
local isDev = localPlayer.Name == "NotFalle_n"
local tracked = {}
local toggles = {
	["Bee"] = false, ["Metal"] = false, ["Star"] = false, ["Box"] = false,
	["ShowTeam"] = false, ["ShowName"] = false, ["ShowKit"] = false,
	["DevMode"] = false, ["KitRender"] = false
}
local connections = {}

-- UI Helpers
local function addUICorner(quantity, parent)
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, quantity)
	UICorner.Parent = parent
end

local function makeDraggable(frame, handle)
	local dragging, dragStart, startPos
	table.insert(connections, handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true dragStart = input.Position startPos = frame.Position
		end
	end))
	table.insert(connections, UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
	table.insert(connections, UIS.InputEnded:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
	end))
end

local function rgbToHex(color)
	return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

-- Screen GUI
local feenWareGUI = Instance.new("ScreenGui", playerGUI)
feenWareGUI.Name = "FEENWARE_V_PERFECT"
feenWareGUI.IgnoreGuiInset = true
feenWareGUI.ResetOnSpawn = false 
feenWareGUI.DisplayOrder = 999999999 -- THIS PREVENTS GAME GUI OVERRIDE

-- MAIN MENU
local mainUI = Instance.new("Frame", feenWareGUI)
mainUI.Size = UDim2.new(0.15, 0, 0.55, 0)
mainUI.Position = UDim2.new(0.05, 0, 0.15, 0)
mainUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
addUICorner(10, mainUI)

local titleFrame = Instance.new("Frame", mainUI)
titleFrame.Size = UDim2.new(1, 0, 0.1, 0)
titleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
addUICorner(10, titleFrame)
makeDraggable(mainUI, titleFrame)

local titleText = Instance.new("TextLabel", titleFrame)
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.Text = "FEENWARE"
titleText.TextColor3 = Color3.fromRGB(255, 0, 0)
titleText.Font = Enum.Font.Code
titleText.TextScaled = true
titleText.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", mainUI)
scroll.Size = UDim2.new(1, 0, 0.75, 0)
scroll.Position = UDim2.new(0, 0, 0.11, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local listLayout = Instance.new("UIListLayout", scroll)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Padding = UDim.new(0, 8)

-- KIT RENDER PANEL
local kitFrame = Instance.new("Frame", feenWareGUI)
kitFrame.Size = UDim2.new(0.25, 0, 0.6, 0)
kitFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
kitFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
kitFrame.Visible = false
addUICorner(12, kitFrame)

local kitHandle = Instance.new("Frame", kitFrame)
kitHandle.Size = UDim2.new(1, 0, 0.08, 0)
kitHandle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
addUICorner(12, kitHandle)
makeDraggable(kitFrame, kitHandle)

local kitTitleTxt = Instance.new("TextLabel", kitHandle)
kitTitleTxt.Size = UDim2.new(1, 0, 1, 0)
kitTitleTxt.Text = "Kit Render"
kitTitleTxt.TextColor3 = Color3.new(1, 1, 1)
kitTitleTxt.Font = Enum.Font.GothamBold
kitTitleTxt.TextScaled = true
kitTitleTxt.BackgroundTransparency = 1

local kitScroll = Instance.new("ScrollingFrame", kitFrame)
kitScroll.Size = UDim2.new(0.95, 0, 0.88, 0)
kitScroll.Position = UDim2.new(0.025, 0, 0.1, 0)
kitScroll.BackgroundTransparency = 1
kitScroll.ScrollBarThickness = 0
kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", kitScroll).Padding = UDim.new(0, 10)

-- ESP Functions
local function getESPConfig(obj)
	local name = obj.Name:lower()
	if name:find("bee") then return Color3.new(1, 1, 0), "Bee" end
	if name:find("metal") or obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal" end
	
	if name:find("star") then
		if name:find("health") or name:find("vitality") then
			return Color3.new(0, 1, 0), "Vitality Star"
		elseif name:find("crit") or name:find("damage") then
			return Color3.new(1, 0.5, 0), "Critical Strike Star"
		else
			return Color3.new(1, 1, 1), "Star"
		end
	end
	return nil
end

local function removeESP(obj)
	if tracked[obj] then
		if tracked[obj].gui then tracked[obj].gui:Destroy() end
		if tracked[obj].info then tracked[obj].info:Destroy() end
		tracked[obj] = nil
	end
end

local function createESP(obj, isPlayer)
	if not isPlayer and (tracked[obj.Parent] or (obj:IsA("BasePart") and tracked[obj.Parent])) then return end
	
	if isPlayer then
		local p = Players:GetPlayerFromCharacter(obj)
		if p == localPlayer and not toggles["DevMode"] then return end
	end
	
	removeESP(obj)
	local hrp = obj:FindFirstChild("HumanoidRootPart") or (obj:IsA("BasePart") and obj) or (obj:IsA("Model") and obj.PrimaryPart)
	if not hrp then return end

	local bill = Instance.new("BillboardGui", hrp)
	bill.AlwaysOnTop = true
	bill.Size = UDim2.fromScale(5, 7)
	bill.Enabled = false
	
	local stroke
	if isPlayer then
		local f = Instance.new("Frame", bill)
		f.Size = UDim2.fromScale(1, 1)
		f.BackgroundTransparency = 1
		stroke = Instance.new("UIStroke", f)
		stroke.Thickness = 2
	end

	local info = Instance.new("BillboardGui", hrp)
	info.AlwaysOnTop = true
	info.Size = UDim2.fromOffset(200, 100)
	info.StudsOffset = Vector3.new(0, 4.5, 0)
	info.Enabled = false
	
	local container = Instance.new("Frame", info)
	container.Size = UDim2.fromScale(1,1)
	container.BackgroundTransparency = 1
	Instance.new("UIListLayout", container).VerticalAlignment = Enum.VerticalAlignment.Bottom

	local function createLabel()
		local t = Instance.new("TextLabel", container)
		t.Size = UDim2.new(1, 0, 0, 22)
		t.BackgroundTransparency = 1
		t.TextColor3 = Color3.new(1, 1, 1)
		t.Font = Enum.Font.GothamBold
		t.TextScaled = true
		t.TextStrokeTransparency = 0.5
		t.Text = "" 
		t.Visible = false
		return t
	end

	local col, typeStr = getESPConfig(obj)
	tracked[obj] = {
		gui = bill, info = info, stroke = stroke,
		teamL = createLabel(), nameL = createLabel(), kitL = createLabel(),
		part = hrp, isPlayer = isPlayer, player = isPlayer and Players:GetPlayerFromCharacter(obj) or nil,
		espType = not isPlayer and typeStr or "Player"
	}
end

-- Kit Render (Grouping Players under Team Header)
local function updateRender()
	kitScroll:ClearAllChildren()
	Instance.new("UIListLayout", kitScroll).Padding = UDim.new(0, 10)
	
	local teamGroups = {}
	for _, p in pairs(Players:GetPlayers()) do
		local tName = p.Team and p.Team.Name or "Neutral"
		if not teamGroups[tName] then teamGroups[tName] = {color = p.TeamColor.Color, players = {}} end
		table.insert(teamGroups[tName].players, p)
	end

	for tName, data in pairs(teamGroups) do
		local header = Instance.new("TextLabel", kitScroll)
		header.Size = UDim2.new(1, 0, 0, 30)
		header.Text = "  " .. tName:upper()
		header.TextColor3 = data.color
		header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		header.Font = Enum.Font.GothamBold
		header.TextScaled = true
		header.TextXAlignment = Enum.TextXAlignment.Left
		addUICorner(6, header)

		for _, p in pairs(data.players) do
			local card = Instance.new("Frame", kitScroll)
			card.Size = UDim2.new(1, 0, 0, 65)
			card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			addUICorner(8, card)

			local avatarImg = Instance.new("ImageLabel", card)
			avatarImg.Size = UDim2.new(0, 50, 0, 50)
			avatarImg.Position = UDim2.new(0, 5, 0.5, -25)
			avatarImg.BackgroundTransparency = 1
			task.spawn(function()
				avatarImg.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
			end)
			addUICorner(25, avatarImg)

			local infoTxt = Instance.new("TextLabel", card)
			infoTxt.Size = UDim2.new(0.65, 0, 0.8, 0)
			infoTxt.Position = UDim2.new(0.25, 0, 0.1, 0)
			infoTxt.BackgroundTransparency = 1
			infoTxt.TextColor3 = Color3.new(1, 1, 1)
			infoTxt.TextXAlignment = Enum.TextXAlignment.Left
			infoTxt.Font = Enum.Font.Gotham
			infoTxt.TextScaled = true
			infoTxt.RichText = true
			
			local rawKit = tostring(p:GetAttribute("PlayingAsKits") or "NONE"):upper()
			local displayKit = kitTranslations[rawKit] or rawKit
			infoTxt.Text = string.format("<b>%s</b>\nKit: <font color=\"%s\">%s</font>", p.DisplayName, rgbToHex(data.color), displayKit)
		end
	end
end

-- ESP Heartbeat
local camera = workspace.CurrentCamera
table.insert(connections, RunService.Heartbeat:Connect(function()
	local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
	for obj, data in pairs(tracked) do
		if obj and obj.Parent and data.part then
			if data.isPlayer then
				if data.player == localPlayer and not toggles["DevMode"] then
					data.gui.Enabled = false data.info.Enabled = false continue
				end

				local act = toggles["Box"]
				data.gui.Enabled = act data.info.Enabled = act
				if act then
					if data.stroke then data.stroke.Color = rainbow end
					data.teamL.Visible = toggles["ShowTeam"]
					data.nameL.Visible = toggles["ShowName"]
					data.kitL.Visible = toggles["ShowKit"]
					
					if data.player then
						data.nameL.Text = data.player.DisplayName
						data.teamL.Text = data.player.Team and data.player.Team.Name or "Neutral"
						data.teamL.TextColor3 = data.player.TeamColor.Color
						local rawKit = tostring(data.player:GetAttribute("PlayingAsKits") or "NONE"):upper()
						data.kitL.Text = "[" .. (kitTranslations[rawKit] or rawKit) .. "]"
						data.kitL.TextColor3 = rainbow
					end
				end
			else
				-- RESOURCE ESP Logic
				local espCol, espTypeStr = getESPConfig(obj)
				local isStar = (data.espType:find("Star"))
				local itemAct = isStar and toggles["Star"] or toggles[data.espType]
				
				data.info.Enabled = itemAct or false
				if itemAct then
					data.nameL.Visible = true
					local dist = math.floor((data.part.Position - camera.CFrame.Position).Magnitude)
					data.nameL.Text = string.format("%s [%d]", data.espType, dist)
					data.nameL.TextColor3 = espCol or Color3.new(1,1,1)
				else
					data.nameL.Visible = false
				end
			end
		else
			removeESP(obj)
		end
	end
end))

-- UI Buttons
local function createBtn(t, p)
	local b = Instance.new("TextButton", p)
	b.Size = UDim2.new(0.9, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = t .. " [OFF]"
	b.Font = Enum.Font.Code
	b.TextScaled = true
	addUICorner(6, b)
	return b
end

local options = {"Bee", "Metal", "Star", "Box", "ShowTeam", "ShowName", "ShowKit"}
if isDev then table.insert(options, "DevMode") end

for _, o in pairs(options) do
	local b = createBtn(o:upper(), scroll)
	b.Activated:Connect(function()
		toggles[o] = not toggles[o]
		b.Text = o:upper() .. " " .. (toggles[o] and "[ON]" or "[OFF]")
		b.BackgroundColor3 = toggles[o] and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
	end)
end

local kr = createBtn("KIT RENDER", scroll)
kr.Activated:Connect(function()
	toggles["KitRender"] = not toggles["KitRender"]
	kitFrame.Visible = toggles["KitRender"]
	kr.Text = "KIT RENDER " .. (toggles["KitRender"] and "[ON]" or "[OFF]")
	if toggles["KitRender"] then updateRender() end
end)

-- UNINJECT
local un = Instance.new("TextButton", mainUI)
un.Size = UDim2.new(0.9, 0, 0.1, 0)
un.Position = UDim2.new(0.05, 0, 0.88, 0)
un.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
un.TextColor3 = Color3.new(1, 1, 1)
un.Text = "UNINJECT"
un.Font = Enum.Font.Code
un.TextScaled = true
addUICorner(6, un)

un.Activated:Connect(function()
	for _, c in pairs(connections) do c:Disconnect() end
	for o, _ in pairs(tracked) do removeESP(o) end
	feenWareGUI:Destroy()
end)

-- Background Loops
task.spawn(function()
	while task.wait(1) do 
		if toggles["KitRender"] then updateRender() end
		for _, v in pairs(workspace:GetDescendants()) do
			if getESPConfig(v) and not tracked[v] then createESP(v, false) end
		end
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and not tracked[p.Character] then createESP(p.Character, true) end
		end
	end
end)

table.insert(connections, workspace.DescendantAdded:Connect(function(v)
	task.wait(1) if getESPConfig(v) then createESP(v, false) end
end))

for _, v in pairs(workspace:GetDescendants()) do if getESPConfig(v) then createESP(v, false) end end
for _, p in pairs(Players:GetPlayers()) do if p.Character then createESP(p.Character, true) end end
