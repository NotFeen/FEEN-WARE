

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera


local currentHotkey = Enum.KeyCode.F4
local VISIBILITY_HOTKEY = Enum.KeyCode.RightShift

local ALLOWED_WEAPONS = {
	["wood_sword"] = true, ["stone_sword"] = true, ["iron_sword"] = true,
	["diamond_sword"] = true, ["emerald_sword"] = true,
	["wood_dao"] = true, ["stone_dao"] = true, ["iron_dao"] = true,
	["diamond_dao"] = true, ["emerald_dao"] = true
}

local rbxts = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts")
local SwordHitRemote = rbxts:WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SwordHit")

local isActive = false
local manualMode = false
local isBindingHotkey = false
local isHoldingClick = false 
local lastMacroClickTime = 0 
local lastFire = 0

local config = {
	interval = 0.1,
	offset = 0,    
	fovAngle = 120,
	showHighlights = true,
	wallCheck = true 
}

local currentValidTargets = {}
local connections = {}


local function createUI(className, props)
	local el = Instance.new(className)
	for k, v in pairs(props) do el[k] = v end
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = el
	return el
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedQAUtility"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local targetHighlight = Instance.new("Highlight")
targetHighlight.FillColor = Color3.fromRGB(200, 50, 50)
targetHighlight.OutlineColor = Color3.fromRGB(255, 100, 100)
targetHighlight.FillTransparency = 0.5
targetHighlight.Enabled = false
targetHighlight.Parent = screenGui 

local mainFrame = createUI("Frame", {
	Size = UDim2.new(0, 300, 0, 630),
	Position = UDim2.new(0.85, -50, 0.5, -315),
	BackgroundColor3 = Color3.fromRGB(30, 30, 35),
	Active = true, -- Crucial for drag interactions
	Parent = screenGui
})

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 60, 70)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = mainFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding")
padding.Parent = mainFrame
padding.PaddingTop = UDim.new(0, 15)
padding.PaddingBottom = UDim.new(0, 15)

local title = createUI("TextLabel", {Size = UDim2.new(0.9, 0, 0, 25), Text = "QA COMBAT PANEL", Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, LayoutOrder = 1, Parent = mainFrame})

local toggleBtn = createUI("TextButton", {Size = UDim2.new(0.9, 0, 0, 40), Text = "STATUS: OFF", Font = Enum.Font.GothamBold, TextSize = 16, BackgroundColor3 = Color3.fromRGB(200, 60, 60), TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 2, Parent = mainFrame})

local hotkeyBtn = createUI("TextButton", {Size = UDim2.new(0.9, 0, 0, 35), Text = "[F4] Change Hotkey", Font = Enum.Font.GothamMedium, TextSize = 14, BackgroundColor3 = Color3.fromRGB(45, 45, 50), TextColor3 = Color3.fromRGB(200, 200, 200), LayoutOrder = 3, Parent = mainFrame})

local modeBtn = createUI("TextButton", {Size = UDim2.new(0.9, 0, 0, 40), Text = "Mode: AUTO-LOOP", Font = Enum.Font.GothamBold, TextSize = 16, BackgroundColor3 = Color3.fromRGB(60, 120, 200), TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 4, Parent = mainFrame})

local highlightBtn = createUI("TextButton", {Size = UDim2.new(0.9, 0, 0, 35), Text = "Highlights: ON", Font = Enum.Font.GothamBold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(150, 100, 200), TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 5, Parent = mainFrame})

local wallCheckBtn = createUI("TextButton", {Size = UDim2.new(0.9, 0, 0, 35), Text = "Wall Check: ON", Font = Enum.Font.GothamBold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(200, 120, 50), TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 6, Parent = mainFrame})

local function createInputRow(labelText, defaultVal, layoutOrder, configKey)
	local container = createUI("Frame", {Size = UDim2.new(0.9, 0, 0, 50), BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = mainFrame})
	local label = createUI("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 0), Text = labelText, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = container})
	local box = createUI("TextBox", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 20), Text = tostring(defaultVal), Font = Enum.Font.GothamBold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(45, 45, 50), TextColor3 = Color3.new(1, 1, 1), Parent = container})
	
	table.insert(connections, box.FocusLost:Connect(function()
		local val = tonumber(box.Text)
		if val then config[configKey] = val else box.Text = tostring(config[configKey]) end
	end))
end

createInputRow("Attack Interval (Secs)", config.interval, 7, "interval")
createInputRow("FOV Angle (Degrees)", config.fovAngle, 8, "fovAngle")

local function createSlider(labelText, layoutOrder)
	local container = createUI("Frame", {Size = UDim2.new(0.9, 0, 0, 60), BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = mainFrame})
	
	local header = createUI("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = container})
	local label = createUI("TextLabel", {Size = UDim2.new(0.7, 0, 1, 0), Text = labelText, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = header})
	local valueBox = createUI("TextBox", {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.7, 0, 0, 0), Text = tostring(config.offset), Font = Enum.Font.GothamBold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(45, 45, 50), TextColor3 = Color3.new(1, 1, 1), Parent = header})
	
	local track = createUI("TextButton", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 25), Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = container})
	local fill = createUI("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 150, 255), Parent = track}) 
	
	local minVal, maxVal = 0, 28 
	local isDragging = false
	
	local function updateSlider(input)
		local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		config.offset = math.floor((minVal + (relativeX * (maxVal - minVal))) * 10) / 10 
		fill.Size = UDim2.new(relativeX, 0, 1, 0)
		valueBox.Text = tostring(config.offset)
	end
	
	table.insert(connections, track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			updateSlider(input)
		end
	end))
	
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
	end))
	
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
	end))
	
	table.insert(connections, valueBox.FocusLost:Connect(function()
		local val = tonumber(valueBox.Text)
		if val then
			config.offset = math.clamp(val, minVal, maxVal)
			fill.Size = UDim2.new((config.offset - minVal) / (maxVal - minVal), 0, 1, 0)
		end
		valueBox.Text = tostring(config.offset)
	end))
end

createSlider("Pushback Reach (Studs)", 9)

local destroyBtn = createUI("TextButton", {Size = UDim2.new(0.9, 0, 0, 35), Text = "DESTROY PANEL", Font = Enum.Font.GothamBlack, TextSize = 14, BackgroundColor3 = Color3.fromRGB(150, 30, 30), TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 10, Parent = mainFrame})


local dragToggle, dragStart, startPos
local function updateDragInput(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

table.insert(connections, mainFrame.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		dragToggle = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragToggle = false
			end
		end)
	end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
	if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDragInput(input)
	end
end))

-
local function getEquippedWeaponName()
	local char = player.Character
	if not char then return nil end
	
	for _, child in ipairs(char:GetChildren()) do
		if ALLOWED_WEAPONS[string.lower(child.Name)] then 
			return child.Name 
		end
	end
	return nil
end

local function scanForTargets()
	local char = player.Character
	if not char or not char.Parent then return {} end 
	
	local root = char:FindFirstChild("HumanoidRootPart")
	local selfHum = char:FindFirstChild("Humanoid")
	if not root or not selfHum or selfHum.Health <= 0 then return {} end
	
	local validTargets = {}
	local lookDir = camera.CFrame.LookVector 
	local flatLookDir = Vector3.new(lookDir.X, 0, lookDir.Z).Unit 
	
	local fovRad = math.rad(config.fovAngle)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer == player then continue end
		if targetPlayer.Team == player.Team and player.Team ~= nil then continue end
		if targetPlayer.Team and targetPlayer.Team.Name == "Spectator" then continue end
		
		local targetChar = targetPlayer.Character
		if not targetChar or targetChar.Parent ~= Workspace then continue end
		
		local hum = targetChar:FindFirstChild("Humanoid")
		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		if not hum or not targetRoot or hum.Health <= 0 then continue end
		
		local toTarget = targetRoot.Position - root.Position
		local dist = toTarget.Magnitude
		if dist <= 0.1 then continue end 
		
		local flatToTarget = Vector3.new(toTarget.X, 0, toTarget.Z).Unit
		local dotProduct = flatLookDir:Dot(flatToTarget)
		local angleToTarget = math.acos(math.clamp(dotProduct, -1, 1))
		
		if angleToTarget > (fovRad / 2) then continue end
		
		if config.wallCheck then
			local rayOrigin = root.Position + Vector3.new(0, 1, 0)
			local rayTarget = targetRoot.Position + Vector3.new(0, 1, 0)
			
			raycastParams.FilterDescendantsInstances = {char, targetChar}
			local rayResult = Workspace:Raycast(rayOrigin, rayTarget - rayOrigin, raycastParams)
			if rayResult and rayResult.Instance.CanCollide and rayResult.Instance.Transparency < 1 then 
				continue 
			end 
		end
		
		table.insert(validTargets, { model = targetChar, root = targetRoot, distance = dist })
	end
	
	table.sort(validTargets, function(a, b) return a.distance < b.distance end)
	return validTargets
end


local function fireCombatEvent(triggerSource)
	local equippedWeaponName = getEquippedWeaponName()
	if not isActive or not equippedWeaponName then return end
	
	local now = tick()
	if (now - lastFire) < config.interval then return end
	
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local selfHum = char and char:FindFirstChild("Humanoid")
	if not root or not selfHum or selfHum.Health <= 0 then return end
	
	local closestTarget = currentValidTargets[1]
	if not closestTarget or not closestTarget.model.Parent then return end 
	
	local invFolder = ReplicatedStorage:FindFirstChild("Inventories")
	local playerInv = invFolder and invFolder:FindFirstChild(player.Name)
	local invWeaponInstance = playerInv and playerInv:FindFirstChild(equippedWeaponName)
	if not invWeaponInstance then return end

	lastFire = now
	
	local bodyLookDir = root.CFrame.LookVector
	local subtractedSelfPos = root.Position - (bodyLookDir * config.offset)
	
	local camLookDir = camera.CFrame.LookVector
	local subtractedCamPos = camera.CFrame.Position - (camLookDir * config.offset)
	
	local args = {
		[1] = {
			["entityInstance"] = closestTarget.model,
			["chargedAttack"] = { ["chargeRatio"] = 0 },
			["validate"] = {
				["targetPosition"] = { ["value"] = closestTarget.root.Position },
				["raycast"] = {
					["cursorDirection"] = { ["value"] = camLookDir },
					["cameraPosition"] = { ["value"] = subtractedCamPos } 
				},
				["selfPosition"] = { ["value"] = subtractedSelfPos } 
			},
			["weapon"] = invWeaponInstance 
		}
	}
	
	pcall(function() 
		SwordHitRemote:FireServer(unpack(args)) 
	end)
end


table.insert(connections, toggleBtn.MouseButton1Click:Connect(function()
	isActive = not isActive
	toggleBtn.Text = isActive and "STATUS: ON" or "STATUS: OFF"
	toggleBtn.BackgroundColor3 = isActive and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(200, 60, 60)
end))

table.insert(connections, modeBtn.MouseButton1Click:Connect(function()
	manualMode = not manualMode
	modeBtn.Text = manualMode and "Mode: MANUAL CLICK" or "Mode: AUTO-LOOP"
	modeBtn.BackgroundColor3 = manualMode and Color3.fromRGB(200, 150, 40) or Color3.fromRGB(60, 120, 200)
end))

table.insert(connections, highlightBtn.MouseButton1Click:Connect(function()
	config.showHighlights = not config.showHighlights
	highlightBtn.Text = config.showHighlights and "Highlights: ON" or "Highlights: OFF"
	highlightBtn.BackgroundColor3 = config.showHighlights and Color3.fromRGB(150, 100, 200) or Color3.fromRGB(80, 80, 90)
	if not config.showHighlights then targetHighlight.Enabled = false end
end))

table.insert(connections, wallCheckBtn.MouseButton1Click:Connect(function()
	config.wallCheck = not config.wallCheck
	wallCheckBtn.Text = config.wallCheck and "Wall Check: ON" or "Wall Check: OFF"
	wallCheckBtn.BackgroundColor3 = config.wallCheck and Color3.fromRGB(200, 120, 50) or Color3.fromRGB(80, 80, 90)
end))

table.insert(connections, hotkeyBtn.MouseButton1Click:Connect(function()
	isBindingHotkey = true
	hotkeyBtn.Text = "... Press Key ..."
end))

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- VISIBILITY TOGGLE: Right Shift logic handles completely hidden/shown states
	if input.KeyCode == VISIBILITY_HOTKEY then
		mainFrame.Visible = not mainFrame.Visible
		return
	end

	if isBindingHotkey and input.UserInputType == Enum.UserInputType.Keyboard then
		currentHotkey = input.KeyCode
		hotkeyBtn.Text = "[" .. currentHotkey.Name .. "] Change Hotkey"
		isBindingHotkey = false
		return
	end

	if gameProcessed then return end
	
	if input.KeyCode == currentHotkey then
		isActive = not isActive
		toggleBtn.Text = isActive and "STATUS: ON" or "STATUS: OFF"
		toggleBtn.BackgroundColor3 = isActive and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(200, 60, 60)
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isHoldingClick = true
		lastMacroClickTime = tick() 
		if manualMode and isActive then
			fireCombatEvent("Instant Click")
		end
	end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isHoldingClick = false
	end
end))


local mainLoop = RunService.Heartbeat:Connect(function()
	currentValidTargets = scanForTargets()
	
	local closestTarget = currentValidTargets[1]
	if isActive and config.showHighlights and closestTarget and closestTarget.model.Parent == Workspace and getEquippedWeaponName() then
		targetHighlight.Adornee = closestTarget.model
		targetHighlight.Enabled = true
	else
		targetHighlight.Enabled = false
	end
	
	local isEffectivelyHolding = isHoldingClick or (tick() - lastMacroClickTime < 0.15)
	
	if isActive then
		if not manualMode then
			fireCombatEvent("Auto-Loop")
		elseif manualMode and isEffectivelyHolding then
			fireCombatEvent("Macro Hold")
		end
	end
end)

table.insert(connections, mainLoop)


destroyBtn.MouseButton1Click:Connect(function()
	for _, conn in ipairs(connections) do
		if conn.Connected then conn:Disconnect() end
	end
	targetHighlight:Destroy()
	screenGui:Destroy()
end)
