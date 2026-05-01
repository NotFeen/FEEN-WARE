local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Configuration
local tracked = {}
local toggles = {
	["Bee"] = false,
	["Metal"] = false,
	["Star"] = false,
	["Player"] = false,
	["Box"] = false -- New Box ESP Toggle
}
local connections = {}

-- UI Setup
local fallenWareScreenUI = Instance.new("ScreenGui")
fallenWareScreenUI.Parent = playerGUI
fallenWareScreenUI.Name = "ZENWARE"
fallenWareScreenUI.IgnoreGuiInset = true
fallenWareScreenUI.ResetOnSpawn = false 

local function addUICorner(quantity, parent)
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, quantity)
	UICorner.Parent = parent
end

-- Main Frame
local mainUI = Instance.new("Frame")
mainUI.Parent = fallenWareScreenUI
mainUI.Size = UDim2.new(0.13, 0, 0.55, 0) -- Increased Y size for new button
mainUI.Position = UDim2.new(0.15, 0, 0.15, 0)
mainUI.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainUI.BorderSizePixel = 0
mainUI.Active = true
mainUI.ClipsDescendants = true
addUICorner(10, mainUI)

-- TITLE BAR
local titleFrame = Instance.new("Frame")
titleFrame.Parent = mainUI
titleFrame.Size = UDim2.new(1, 0, 0.1, 0)
titleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleFrame.ZIndex = 10
addUICorner(10, titleFrame)

local titleText = Instance.new("TextLabel")
titleText.Parent = titleFrame
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "GOATWARE"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.Code
titleText.ZIndex = 11

-- SCROLLING CONTENT
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainUI
scrollingFrame.Size = UDim2.new(1, 0, 0.75, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0.12, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.ZIndex = 5

local uiList = Instance.new("UIListLayout", scrollingFrame)
uiList.Padding = UDim.new(0, 8)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local uiPadding = Instance.new("UIPadding", scrollingFrame)
uiPadding.PaddingTop = UDim.new(0, 5)

-- BOTTOM BAR
local bottomBar = Instance.new("Frame")
bottomBar.Parent = mainUI
bottomBar.Size = UDim2.new(1, 0, 0.1, 0)
bottomBar.Position = UDim2.new(0, 0, 0.9, 0)
bottomBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bottomBar.ZIndex = 10
addUICorner(10, bottomBar)

--- DRAGGING ---
local dragging, dragStart, startPos
titleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true dragStart = input.Position startPos = mainUI.Position
	end
end)
table.insert(connections, UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainUI.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))
table.insert(connections, UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

--- ESP LOGIC ---
local function getESPConfig(obj)
	if obj.Name == "Bee" then return Color3.new(1, 1, 0), "Bee" end
	if obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal" end
	if obj.Name == "CritStar" then return Color3.fromRGB(255, 165, 0), "Crit Star" end
	if obj.Name == "VitalityStar" then return Color3.fromRGB(50, 255, 50), "Vitality Star" end
	return nil
end

local function removeESP(id)
	if tracked[id] then
		if tracked[id].gui then tracked[id].gui:Destroy() end
		if tracked[id].box then tracked[id].box:Destroy() end
		tracked[id] = nil
	end
end

local function createESP(obj, isPlayer)
	local id = isPlayer and obj.UserId or obj
	if tracked[id] then removeESP(id) end

	local color, labelName
	local targetPart

	if isPlayer then
		if obj == localPlayer then return end
		color = Color3.new(1, 1, 1)
		labelName = obj.DisplayName
		targetPart = obj.Character and obj.Character:FindFirstChild("HumanoidRootPart")
	else
		color, labelName = getESPConfig(obj)
		targetPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
	end

	if not targetPart then return end

	local data = {name = labelName, part = targetPart, isPlayer = isPlayer, playerObj = isPlayer and obj or nil}

	-- Text ESP Logic
	if (isPlayer and toggles["Player"]) or (not isPlayer) then
		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.fromOffset(150, 50)
		bill.AlwaysOnTop = true
		bill.StudsOffset = Vector3.new(0, 3, 0)
		bill.Adornee = targetPart
		bill.Parent = targetPart
		
		local label = Instance.new("TextLabel", bill)
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = color
		label.TextStrokeTransparency = 0
		label.TextSize = 14
		label.Font = Enum.Font.GothamBold
		data.gui = bill
		data.text = label
	end

	-- Box ESP Logic (Only for players)
	if isPlayer and toggles["Box"] then
		local box = Instance.new("SelectionBox")
		box.Adornee = targetPart
		box.Color3 = Color3.new(0, 0, 0) -- All Black
		box.LineThickness = 0.05
		box.SurfaceTransparency = 1
		box.Parent = targetPart
		data.box = box
	end

	tracked[id] = data
end

-- HEARTBEAT
table.insert(connections, RunService.Heartbeat:Connect(function()
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	
	for id, data in pairs(tracked) do
		-- Re-find character if player died
		if data.isPlayer then
			local pChar = data.playerObj.Character
			local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
			
			if pHrp and data.part ~= pHrp then
				createESP(data.playerObj, true) -- Refresh on respawn
			elseif pHrp and hrp then
				local dist = math.floor((hrp.Position - pHrp.Position).Magnitude)
				if data.text then data.text.Text = data.name .. "\n[" .. dist .. "m]" end
			end
		else
			-- World Objects
			if data.part and data.part.Parent and hrp then
				local dist = math.floor((hrp.Position - data.part.Position).Magnitude)
				if data.text then data.text.Text = data.name .. "\n[" .. dist .. "m]" end
			else
				removeESP(id)
			end
		end
	end
end))

local function refreshCategory(cat)
	if cat == "Player" or cat == "Box" then
		for _, p in pairs(Players:GetPlayers()) do
			if toggles["Player"] or toggles["Box"] then createESP(p, true) else removeESP(p.UserId) end
		end
	else
		if toggles[cat] then
			for _, v in pairs(workspace:GetDescendants()) do
				if getESPConfig(v) and getESPConfig(v):find(cat) then createESP(v, false) end
			end
		else
			for id, data in pairs(tracked) do
				if not data.isPlayer and data.name:find(cat) then removeESP(id) end
			end
		end
	end
end

--- BUTTONS ---
local function makeBtn(text, parent)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.9, 0, 0, 40)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.ZIndex = 6
	addUICorner(6, b)
	return b
end

local cats = {"Bee", "Metal", "Star", "Player", "Box"}
for _, name in pairs(cats) do
	local btnText = name == "Box" and "BOX ESP [OFF]" or name:upper() .. " ESP [OFF]"
	local btn = makeBtn(btnText, scrollingFrame)
	btn.Activated:Connect(function()
		toggles[name] = not toggles[name]
		btn.Text = (name == "Box" and "BOX ESP " or name:upper() .. " ESP ") .. (toggles[name] and "[ON]" or "[OFF]")
		btn.BackgroundColor3 = toggles[name] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(60, 60, 60)
		refreshCategory(name)
	end)
end

-- UNINJECT
local uninjectBtn = makeBtn("UNINJECT", bottomBar)
uninjectBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
uninjectBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
uninjectBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
uninjectBtn.ZIndex = 11
uninjectBtn.Activated:Connect(function()
	for _, conn in pairs(connections) do conn:Disconnect() end
	for id in pairs(tracked) do removeESP(id) end
	fallenWareScreenUI:Destroy()
end)

-- Live listeners
table.insert(connections, Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() task.wait(1) if toggles["Player"] or toggles["Box"] then createESP(p, true) end end)
end))

table.insert(connections, workspace.DescendantAdded:Connect(function(obj)
	task.wait(0.5)
	if getESPConfig(obj) then
		for cat, active in pairs(toggles) do
			if active and cat ~= "Player" and cat ~= "Box" then createESP(obj, false) end
		end
	end
end))
