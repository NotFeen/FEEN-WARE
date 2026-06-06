-------------------------------------------------------------------------
-- === FEATHERWARE UI LIBRARY DOCUMENTATION & CHEAT SHEET ===
-------------------------------------------------------------------------
--[[
	HOW TO ADD A CATEGORY:
	local MyCategory = FW:CreateCategory("CategoryName")

	HOW TO ADD A MAIN BUTTON:
	-- The 'true' at the end enables the quick-bind hotkey on the button!
	local MyCheat = MyCategory:CreateButton("CheatName", function(state)
		print("Cheat is now:", state)
	end, true)

	HOW TO ADD SETTINGS TO A BUTTON (Clicking the '>' arrow opens them):
	1. Toggle:   MyCheat:CreateToggle("Target", true, function(state) end)
	2. Slider:   MyCheat:CreateSlider("Range", 1, 20, 10, function(value) end)
	3. Textbox:  MyCheat:CreateTextbox("Message", "Text", function(text) end)
	4. Dropdown: MyCheat:CreateDropdown("Mode", {"A", "B"}, "A", function(opt) end)
	5. Keybind:  MyCheat:CreateKeybind("Bind", Enum.KeyCode.R, function(key) end)
	6. Label:    MyCheat:CreateLabel("This is a warning label.")
	7. ColorPicker: MyCheat:CreateColorPicker("ESP Color", Color3.fromRGB(255,0,0), function(color) end)
	
	HOW TO ADD SETTINGS TO THE MAIN MENU SETTINGS OVERLAY:
	FW.SettingsOverlay:CreateToggle("Watermark", true, function(state) end)
]]
-------------------------------------------------------------------------

local loops = {
	ka = nil
}

local lastSort = 2

local currentKaTarget = nil
local hitting = nil
local lastHit = nil
local stealChests = false

local whiteHits = false

local findTargetStuds = 100

local autoShoot = false

local maxHoldTime = 0.1
local maxClickInterval = 0.1   

local isSystemEnabled = false

local DIRECTION_MODES = {
	["Normal"] = "Normal",
	["Backwards"] = "Backwards",
	["Reversed"] = "Reversed",
	["Up"] = "Up"
}

local bows = {
	"wood_bow",
	"wood_crossbow",
	"headhunter"
}

local startTime = 0
local lastClickTime = 0
local clicking = false


local resetTask = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordHitRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts").net.out:WaitForChild("_NetManaged"):WaitForChild("SwordHit")

local netManaged = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
local setInvItem = netManaged:WaitForChild("SetInvItem")
local inventoriesFolder = ReplicatedStorage:WaitForChild("Inventories")


local t_find = table.find
local t_clear = table.clear
local m_deg = math.deg
local m_acos = math.acos

local swords = {
	"wood_sword",
	"stone_sword",
	"iron_sword",
	"diamond_sword",
	"emerald_sword",
	"rageblade",
	"rage_blade",
	"big_wood_sword",
	"wood_dao",
	"stone_dao",
	"iron_dao",
	"diamond_dao",
	"emerald_dao",
	"frosty_hammer",
	"void_sword",
	"ice_sword",
	"laser_sword",
	"light_sword",
	"noctium_blade",
	"noctium_blade_2",
	"noctium_blade_3",
	"noctium_blade_4"
}

local kaArgs = {
	[1] = {
		["chargedAttack"] = {
			["chargeRatio"] = 0
		},
		["entityInstance"] = 0,
		["validate"] = {
			["selfPosition"] = {
				["value"] = 0
			},
			["targetPosition"] = {
				["value"] = 0
			}
		},
		["weapon"] = 0
	}
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera

local localRootPart = Character:WaitForChild("HumanoidRootPart")
local humanoid = Character:WaitForChild("Humanoid")

local animator = humanoid:WaitForChild("Animator")

local fireProjectileEvent = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileFire")

local currentTarget = nil
local aimConnection = nil
local currentTrack = nil

-- === CONFIGURATION ===
local textFont = "Zekton"
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DRAG_SMOOTHNESS = 0.2 -- Lower = slower/smoother, Higher = faster snap! (0.1 to 0.3 is best)

local HH_HOLD_ANIMATION_ID = "rbxassetid://13421339706"
local HH_SHOOT_ANIMATION_ID = "rbxassetid://13421344632"
local BOW_HOLD_ANIMATION_ID = "rbxassetid://15222797648"
local BOW_SHOOT_ANIMATION_ID = "rbxassetid://8860294521"
local CB_HOLD_ANIMATION_ID = "rbxassetid://8860301164"
local CB_SHOOT_ANIMATION_ID = "rbxassetid://8860304406"


-- Cleanup Old GUI
local oldGui = PlayerGui:FindFirstChild("FeatherWare")
if oldGui then oldGui:Destroy() end

local mainScreenUI = Instance.new("ScreenGui")
mainScreenUI.Parent = PlayerGui
mainScreenUI.Name = "FeatherWare"
mainScreenUI.ResetOnSpawn = false
mainScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Vital for dynamic layering
mainScreenUI.DisplayOrder = 5000

-- === UTILITY FUNCTIONS ===
local function uiCorner(instance, amount)
	local UiCorner = Instance.new("UICorner")
	UiCorner.Parent = instance
	UiCorner.CornerRadius = UDim.new(0, amount)
end

local function tween(obj, goal)
	TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

local function getHoverColor(color)
	local h, s, v = color:ToHSV()
	if v > 0.8 then return Color3.fromHSV(h, s, v * 0.85) else return Color3.fromHSV(h, s, math.clamp(v * 1.25, 0, 1)) end
end

local function applyHoverEffect(guiObject)
	if guiObject:IsA("GuiButton") then guiObject.AutoButtonColor = false end
	guiObject:SetAttribute("BaseBgColor", guiObject.BackgroundColor3)
	if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
		guiObject:SetAttribute("BaseTextColor", guiObject.TextColor3)
	elseif guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
		guiObject:SetAttribute("BaseImageColor", guiObject.ImageColor3)
	end

	guiObject.MouseEnter:Connect(function()
		local hoverProps = {}
		if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
			hoverProps.BackgroundColor3 = getHoverColor(guiObject:GetAttribute("BaseBgColor"))
			hoverProps.TextColor3 = getHoverColor(guiObject:GetAttribute("BaseTextColor"))
		elseif guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
			hoverProps.ImageColor3 = getHoverColor(guiObject:GetAttribute("BaseImageColor"))
		end
		TweenService:Create(guiObject, tweenInfo, hoverProps):Play()
	end)

	guiObject.MouseLeave:Connect(function()
		local leaveProps = {}
		if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
			leaveProps.BackgroundColor3 = guiObject:GetAttribute("BaseBgColor")
			leaveProps.TextColor3 = guiObject:GetAttribute("BaseTextColor")
		elseif guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
			leaveProps.ImageColor3 = guiObject:GetAttribute("BaseImageColor")
		end
		TweenService:Create(guiObject, tweenInfo, leaveProps):Play()
	end)
end


local weaponTiers = {
	-- PRIORITY 1: Rageblade (First thing it checks for/highest score)
	["rageblade"] = 50000,
	["rage_blade"] = 50000,

	-- PRIORITY 2: Noctium Blades (Strongest available)
	["noctium_blade_4"] = 40004,
	["noctium_blade_3"] = 40003,
	["noctium_blade_2"] = 40002,
	["noctium_blade"] = 40001,

	-- PRIORITY 3: Normal Swords (Beats all Daos and Specials)
	["emerald_sword"] = 30006,
	["diamond_sword"] = 30005,
	["iron_sword"] = 30004,
	["stone_sword"] = 30003,
	["big_wood_sword"] = 30002,
	["wood_sword"] = 30001,

	-- PRIORITY 4: Daos (Only equipped if no Normal, Noctium, or Rageblade)
	["emerald_dao"] = 20005,
	["diamond_dao"] = 20004,
	["iron_dao"] = 20003,
	["stone_dao"] = 20002,
	["wood_dao"] = 20001,

	-- PRIORITY 5: Special Swords (Lowest priority, only if literally nothing else)
	["void_sword"] = 10005,
	["frosty_hammer"] = 10004,
	["light_sword"] = 10003,
	["laser_sword"] = 10002,
	["ice_sword"] = 10001
}

local function getBestEquippedSword(playerName)
	local inventories = ReplicatedStorage:FindFirstChild("Inventories")
	if not inventories then return nil end

	local playerInv = inventories:FindFirstChild(playerName)
	if not playerInv then return nil end

	local bestSword = nil
	local highestScore = -1

	-- Scans the inventory once. Because of the massive point gaps, 
	-- it automatically filters by your exact category rules.
	for _, item in ipairs(playerInv:GetChildren()) do
		local score = weaponTiers[item.Name]

		if score and score > highestScore then
			highestScore = score
			bestSword = item.Name
		end
	end

	return bestSword
end


local topZIndex = 10
local currentlyDragging = nil 
local function makeDraggable(frame)
	frame.Active = true
	local dragStart, startPos, targetPosition
	local moveConn, endConn

	frame.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 and currentlyDragging == nil then
			currentlyDragging = frame

			topZIndex = topZIndex + 1
			frame.ZIndex = topZIndex

			dragStart = input.Position
			startPos = frame.Position
			targetPosition = startPos

			moveConn = UserInputService.InputChanged:Connect(function(change)
				if change.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = change.Position - dragStart
					targetPosition = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end)

			endConn = UserInputService.InputEnded:Connect(function(change)
				if change.UserInputType == Enum.UserInputType.MouseButton1 then
					currentlyDragging = nil -- Release the lock
					if moveConn then moveConn:Disconnect() end
					if endConn then endConn:Disconnect() end
				end
			end)
		end
	end)

	-- Handle the smoothing strictly and safely
	RunService.RenderStepped:Connect(function()
		if targetPosition then
			frame.Position = frame.Position:Lerp(targetPosition, DRAG_SMOOTHNESS)
		end
	end)
end

-- === CORE UI LIBRARY SYSTEM ===
local FW = {}

-- Create the Main Window
local mainFrame = Instance.new("Frame", mainScreenUI)
mainFrame.Name = "mainFrame"
mainFrame.Size = UDim2.new(0.12, 0, 0.55, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
mainFrame.BorderSizePixel = 0
uiCorner(mainFrame, 8)
makeDraggable(mainFrame)

local glow = Instance.new("ImageLabel", mainFrame)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://1316045217"
glow.ImageColor3 = Color3.new(0,0,0)
glow.ImageTransparency = 0.4
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(10,10,118,118)
glow.Size = UDim2.new(1, 30, 1, 30)
glow.Position = UDim2.new(0, -15, 0, -15)
glow.ZIndex = 0

local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 3
uiStroke.Color = Color3.fromRGB(66, 66, 66)
uiStroke.Transparency = 0.3

-- Clean, Premium Header
local titleFrame = Instance.new("Frame", mainFrame)
titleFrame.Size = UDim2.new(1, 0, 0, 35)
titleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleFrame.BorderSizePixel = 0
titleFrame.ZIndex = 3
uiCorner(titleFrame, 8)

local titleBottomHider = Instance.new("Frame", titleFrame)
titleBottomHider.Size = UDim2.new(1, 0, 0, 8)
titleBottomHider.Position = UDim2.new(0, 0, 1, -8)
titleBottomHider.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBottomHider.BorderSizePixel = 0
titleBottomHider.ZIndex = 3

local featherImage = Instance.new("ImageLabel", titleFrame)
featherImage.BackgroundTransparency = 1
featherImage.Size = UDim2.new(0, 20, 0, 20)
featherImage.Position = UDim2.new(0, 12, 0.5, 0)
featherImage.AnchorPoint = Vector2.new(0, 0.5)
featherImage.Image = "rbxassetid://93633665863756"
featherImage.ZIndex = 3

local title = Instance.new("TextLabel", titleFrame)
title.Text = "FW"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.FontFace = Font.fromName(textFont)
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3

local settingsImage = Instance.new("ImageButton", titleFrame)
settingsImage.BackgroundTransparency = 1
settingsImage.Size = UDim2.new(0, 18, 0, 18)
settingsImage.Position = UDim2.new(1, -12, 0.5, 0)
settingsImage.AnchorPoint = Vector2.new(1, 0.5)
settingsImage.Image = "rbxassetid://120575276332005"
settingsImage.ImageColor3 = Color3.fromRGB(130, 130, 130)
settingsImage.ZIndex = 3
applyHoverEffect(settingsImage)

local mainScroll = Instance.new("ScrollingFrame", mainFrame)
mainScroll.Size = UDim2.new(1, 0, 1, -45)
mainScroll.Position = UDim2.new(0, 0, 0, 40)
mainScroll.BackgroundTransparency = 1
mainScroll.ScrollBarThickness = 0
mainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
mainScroll.ZIndex = 1
local mainLayout = Instance.new("UIListLayout", mainScroll)
mainLayout.Padding = UDim.new(0, 2)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- === MAIN UI SETTINGS OVERLAY ===
local overlayFrame = Instance.new("Frame", mainFrame)
overlayFrame.Size = UDim2.new(1, 0, 1, -35)
overlayFrame.Position = UDim2.new(0, 0, 0, 35)
overlayFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
overlayFrame.BorderSizePixel = 0
overlayFrame.Visible = false
overlayFrame.ZIndex = 4

local closeOverlayBtn = Instance.new("TextButton", overlayFrame)
closeOverlayBtn.Size = UDim2.new(1, 0, 0, 30)
closeOverlayBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeOverlayBtn.Text = "Close Settings [X]"
closeOverlayBtn.TextColor3 = Color3.new(1, 1, 1)
closeOverlayBtn.FontFace = Font.fromName(textFont)
closeOverlayBtn.TextSize = 18
closeOverlayBtn.ZIndex = 5
closeOverlayBtn.BorderSizePixel = 0

local overlayScroll = Instance.new("ScrollingFrame", overlayFrame)
overlayScroll.Size = UDim2.new(1, 0, 1, -35)
overlayScroll.Position = UDim2.new(0, 0, 0, 35)
overlayScroll.BackgroundTransparency = 1
overlayScroll.ScrollBarThickness = 0
overlayScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
overlayScroll.ZIndex = 5
local overlayLayout = Instance.new("UIListLayout", overlayScroll)
overlayLayout.Padding = UDim.new(0, 2)

settingsImage.MouseButton1Click:Connect(function()
	overlayFrame.Visible = true
	mainScroll.Visible = false
end)
closeOverlayBtn.MouseButton1Click:Connect(function()
	overlayFrame.Visible = false
	mainScroll.Visible = true
end)

-- === ELEMENT GENERATOR FUNCTION ===
local function injectElements(mod, settingsCont)
	function mod:CreateLabel(text)
		local lbl = Instance.new("TextLabel", settingsCont)
		lbl.Size = UDim2.new(1, 0, 0, 25)
		lbl.BackgroundTransparency = 1
		lbl.Text = "      " .. text
		lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
		lbl.TextSize = 18
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.FontFace = Font.fromName(textFont)
	end

	function mod:CreateToggle(tName, default, tCallback)
		mod.Values[tName] = default 

		local tFrame = Instance.new("TextButton", settingsCont)

		tFrame.Size = UDim2.new(1, 0, 0, 28)
		tFrame.BackgroundTransparency = 1
		tFrame.Text = "      - " .. tName
		tFrame.TextColor3 = default and Color3.fromRGB(78, 173, 73) or Color3.fromRGB(180, 180, 180)
		tFrame.TextSize = 20
		tFrame.TextXAlignment = Enum.TextXAlignment.Left
		tFrame.FontFace = Font.fromName(textFont)

		local toggledState = default
		tFrame.MouseButton1Click:Connect(function()
			toggledState = not toggledState
			tFrame.TextColor3 = toggledState and Color3.fromRGB(78, 173, 73) or Color3.fromRGB(180, 180, 180)
			mod.Values[tName] = toggledState

			if tCallback then
				tCallback(toggledState)
			end

			if mod.Callbacks.OnValueChanged then
				mod.Callbacks.OnValueChanged(tName, toggledState)
			end
		end)
	end

	function mod:CreateSlider(sName, min, max, default, sCallback)
		local sFrame = Instance.new("Frame", settingsCont)
		sFrame.Size = UDim2.new(1, 0, 0, 38)
		sFrame.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", sFrame)
		lbl.Text = "      " .. sName .. ": " .. default
		lbl.Size = UDim2.new(1, 0, 0.6, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
		lbl.TextSize = 18
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.FontFace = Font.fromName(textFont)

		local bg = Instance.new("TextButton", sFrame)
		bg.Text = ""
		bg.Size = UDim2.new(0.75, 0, 0.15, 0)
		bg.Position = UDim2.new(0.125, 0, 0.65, 0)
		bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		uiCorner(bg, 4)

		local fill = Instance.new("Frame", bg)
		fill.BackgroundColor3 = Color3.fromRGB(78, 173, 73)
		fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
		uiCorner(fill, 4)

		-- Store default slider value immediately
		mod.Values[sName] = default

		bg.MouseButton1Down:Connect(function()
			local moveConn, releaseConn
			moveConn = RunService.RenderStepped:Connect(function()
				local mouseP = UserInputService:GetMouseLocation().X
				local relative = math.clamp((mouseP - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(relative, 0, 1, 0)
				local val = min + ((max - min) * relative)
				val = math.clamp(val, min, max)
				val = math.floor(val * 100) / 100

				fill.Size = UDim2.new(relative, 0, 1, 0)

				lbl.Text = string.format("      %s: %.2f", sName, val)

				mod.Values[sName] = val

				if sCallback then
					sCallback(val)
				end

				if mod.Callbacks.OnValueChanged then
					mod.Callbacks.OnValueChanged(sName, val)
				end
			end)
			releaseConn = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConn:Disconnect()
					releaseConn:Disconnect()
				end
			end)
		end)
	end

	function mod:CreateTextbox(txtName, placeholder, txtCallback)

		mod.Values[txtName] = ""

		local tFrame = Instance.new("Frame", settingsCont)
		tFrame.Size = UDim2.new(1, 0, 0, 40)
		tFrame.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", tFrame)
		lbl.Text = "      " .. txtName
		lbl.Size = UDim2.new(0.4, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
		lbl.TextSize = 18
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.FontFace = Font.fromName(textFont)

		local box = Instance.new("TextBox", tFrame)
		box.Size = UDim2.new(0.45, 0, 0.6, 0)
		box.Position = UDim2.new(0.45, 0, 0.2, 0)
		box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		box.TextColor3 = Color3.new(1,1,1)
		box.PlaceholderText = placeholder
		box.Text = ""
		box.TextScaled = true
		box.FontFace = Font.fromName(textFont)
		uiCorner(box, 4)

		box.FocusLost:Connect(function()
			-- Save textbox value
			mod.Values[txtName] = box.Text

			if txtCallback then
				txtCallback(box.Text)
			end

			if mod.Callbacks.OnValueChanged then
				mod.Callbacks.OnValueChanged(txtName, box.Text)
			end
		end)
	end

	function mod:CreateDropdown(dName, options, default, dCallback, multiSelect)
		-- Default multiSelect to false if not provided
		multiSelect = multiSelect or false

		-- Setup the internal value storage
		if multiSelect then
			-- If multi-select is enabled, the stored value becomes a table
			if type(default) == "table" then
				mod.Values[dName] = {}
				for _, v in ipairs(default) do table.insert(mod.Values[dName], v) end
			else
				mod.Values[dName] = default and {default} or {}
			end
		else
			mod.Values[dName] = default
		end

		local dropCont = Instance.new("Frame", settingsCont)
		dropCont.BackgroundTransparency = 1
		dropCont.AutomaticSize = Enum.AutomaticSize.Y
		dropCont.Size = UDim2.new(1, 0, 0, 0)
		local dLayout = Instance.new("UIListLayout", dropCont)
		dLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local dBtn = Instance.new("TextButton", dropCont)
		dBtn.Size = UDim2.new(1, 0, 0, 28)
		dBtn.BackgroundTransparency = 1
		dBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		dBtn.TextXAlignment = Enum.TextXAlignment.Left
		dBtn.TextSize = 20
		dBtn.FontFace = Font.fromName(textFont)
		dBtn.LayoutOrder = 1

		local optFrame = Instance.new("Frame", dropCont)
		optFrame.BackgroundTransparency = 1
		optFrame.AutomaticSize = Enum.AutomaticSize.Y
		optFrame.Size = UDim2.new(1, 0, 0, 0)
		optFrame.Visible = false
		optFrame.LayoutOrder = 2

		local oLayout = Instance.new("UIListLayout", optFrame)

		dBtn.MouseButton1Click:Connect(function() 
			optFrame.Visible = not optFrame.Visible 
		end)

		-- Helper function to update the main button text dynamically
		local function updateDropdownText()
			if multiSelect then
				local count = #mod.Values[dName]
				if count == 0 then
					dBtn.Text = "      - " .. dName .. ": None"
				elseif count == 1 then
					dBtn.Text = "      - " .. dName .. ": " .. tostring(mod.Values[dName][1])
				else
					dBtn.Text = "      - " .. dName .. ": [" .. count .. " Selected]"
				end
			else
				dBtn.Text = "      - " .. dName .. ": " .. tostring(mod.Values[dName])
			end
		end

		updateDropdownText() -- Initialize text

		for _, opt in ipairs(options) do
			local oBtn = Instance.new("TextButton", optFrame)
			oBtn.Size = UDim2.new(1, 0, 0, 24)
			oBtn.BackgroundTransparency = 1
			oBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
			oBtn.TextXAlignment = Enum.TextXAlignment.Left
			oBtn.TextSize = 18
			oBtn.FontFace = Font.fromName(textFont)

			-- Helper function to update the option's visual state
			local function updateVisual()
				if multiSelect then
					local isSelected = table.find(mod.Values[dName], opt)
					oBtn.Text = (isSelected and "         > [x] " or "         > [ ] ") .. tostring(opt)
					oBtn.TextColor3 = isSelected and Color3.new(1,1,1) or Color3.fromRGB(120, 120, 120)
				else
					oBtn.Text = "         > " .. tostring(opt)
				end
			end

			updateVisual() -- Initialize visual state

			-- Hover effects (Modified to respect active multi-select options)
			oBtn.MouseEnter:Connect(function() 
				tween(oBtn, {TextColor3 = Color3.new(1,1,1)}) 
			end)

			oBtn.MouseLeave:Connect(function() 
				if multiSelect and table.find(mod.Values[dName], opt) then return end
				tween(oBtn, {TextColor3 = Color3.fromRGB(120, 120, 120)}) 
			end)

			oBtn.MouseButton1Click:Connect(function()
				if multiSelect then
					-- Toggle logic for multi-select
					local foundIdx = table.find(mod.Values[dName], opt)

					if foundIdx then
						table.remove(mod.Values[dName], foundIdx) -- Deselect
					else
						table.insert(mod.Values[dName], opt) -- Select
					end

					updateVisual()
					updateDropdownText()

					-- Send the entire table of selected options through the callback
					if dCallback then dCallback(mod.Values[dName]) end
					if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(dName, mod.Values[dName]) end
				else
					-- Standard logic for single-select
					optFrame.Visible = false
					mod.Values[dName] = opt

					updateDropdownText()

					if dCallback then dCallback(opt) end
					if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(dName, opt) end
				end
			end)
		end
	end

	function mod:CreateKeybind(kName, defaultKey, kCallback)
		local kBtn = Instance.new("TextButton", settingsCont)
		kBtn.Size = UDim2.new(1, 0, 0, 28)
		kBtn.BackgroundTransparency = 1
		local keyString = defaultKey and defaultKey.Name or "None"
		kBtn.Text = "      - " .. kName .. ": [" .. keyString .. "]"
		kBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		kBtn.TextXAlignment = Enum.TextXAlignment.Left
		kBtn.TextSize = 20
		kBtn.FontFace = Font.fromName(textFont)

		local waiting = false
		kBtn.MouseButton1Click:Connect(function()
			waiting = true
			kBtn.Text = "      - " .. kName .. ": [...]"
			kBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
		end)

		UserInputService.InputBegan:Connect(function(input, GPE)
			if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
				waiting = false
				local key = input.KeyCode
				if key == Enum.KeyCode.Backspace then key = nil end

				kBtn.Text = "      - " .. kName .. ": [" .. (key and key.Name or "None") .. "]"
				kBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
				if kCallback then kCallback(key) end
			end
		end)
	end

	function mod:CreateColorPicker(cName, defaultColor, cCallback)
		local cFrame = Instance.new("Frame", settingsCont)
		cFrame.Size = UDim2.new(1, 0, 0, 45)
		cFrame.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", cFrame)
		lbl.Text = "      " .. cName
		lbl.Size = UDim2.new(0.5, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
		lbl.TextSize = 18
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.FontFace = Font.fromName(textFont)

		local rSlider = Instance.new("TextBox", cFrame)
		rSlider.Size = UDim2.new(0.12, 0, 0.5, 0)
		rSlider.Position = UDim2.new(0.5, 0, 0.25, 0)
		rSlider.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
		rSlider.TextColor3 = Color3.new(1,1,1)
		rSlider.Text = tostring(math.floor(defaultColor.R * 255))
		uiCorner(rSlider, 4)

		local gSlider = Instance.new("TextBox", cFrame)
		gSlider.Size = UDim2.new(0.12, 0, 0.5, 0)
		gSlider.Position = UDim2.new(0.65, 0, 0.25, 0)
		gSlider.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
		gSlider.TextColor3 = Color3.new(1,1,1)
		gSlider.Text = tostring(math.floor(defaultColor.G * 255))
		uiCorner(gSlider, 4)

		local bSlider = Instance.new("TextBox", cFrame)
		bSlider.Size = UDim2.new(0.12, 0, 0.5, 0)
		bSlider.Position = UDim2.new(0.8, 0, 0.25, 0)
		bSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
		bSlider.TextColor3 = Color3.new(1,1,1)
		bSlider.Text = tostring(math.floor(defaultColor.B * 255))
		uiCorner(bSlider, 4)

		local function updateColor()
			local r = math.clamp(tonumber(rSlider.Text) or 255, 0, 255)
			local g = math.clamp(tonumber(gSlider.Text) or 255, 0, 255)
			local b = math.clamp(tonumber(bSlider.Text) or 255, 0, 255)
			rSlider.Text, gSlider.Text, bSlider.Text = tostring(r), tostring(g), tostring(b)
			if cCallback then cCallback(Color3.fromRGB(r, g, b)) end
		end

		rSlider.FocusLost:Connect(updateColor)
		gSlider.FocusLost:Connect(updateColor)
		bSlider.FocusLost:Connect(updateColor)
	end
end

FW.SettingsOverlay = {
	Values = {},
	Callbacks = {}
}
injectElements(FW.SettingsOverlay, overlayScroll)

-- === CATEGORY API ===
function FW:CreateCategory(name)
	local category = {}

	local catBtn = Instance.new("TextButton", mainScroll)
	catBtn.Name = name
	catBtn.Text = "  " .. name
	catBtn.Size = UDim2.new(1, 0, 0, 32)
	catBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	catBtn.BackgroundTransparency = 1
	catBtn.TextColor3 = Color3.new(1, 1, 1)
	catBtn.FontFace = Font.fromName(textFont)
	catBtn.TextSize = 24
	catBtn.TextXAlignment = Enum.TextXAlignment.Left
	catBtn.BorderSizePixel = 0
	catBtn.LayoutOrder = lastSort

	lastSort += 1

	catBtn.MouseEnter:Connect(function() tween(catBtn, {BackgroundTransparency = 0}) end)
	catBtn.MouseLeave:Connect(function() tween(catBtn, {BackgroundTransparency = 1}) end)

	local frame = Instance.new("Frame", mainScreenUI)
	frame.Name = name .. "Frame"
	frame.Size = UDim2.new(0.12, 0, 0.55, 0)
	frame.Position = UDim2.new(0.25, 0, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	frame.BorderSizePixel = 0
	frame.Visible = false
	uiCorner(frame, 8)
	makeDraggable(frame)

	glow:Clone().Parent = frame
	uiStroke:Clone().Parent = frame

	local fTitleFrame = titleFrame:Clone()
	fTitleFrame.Parent = frame
	fTitleFrame:ClearAllChildren()
	uiCorner(fTitleFrame, 8)

	local fTitleBottomHider = titleBottomHider:Clone()
	fTitleBottomHider.Parent = fTitleFrame

	local fTitle = title:Clone()
	fTitle.Parent = fTitleFrame
	fTitle.Text = name
	fTitle.Position = UDim2.new(0, 15, 0, 0)
	fTitle.Size = UDim2.new(1, -15, 1, 0)

	local fScroll = Instance.new("ScrollingFrame", frame)
	fScroll.Size = UDim2.new(1, 0, 1, -45)
	fScroll.Position = UDim2.new(0, 0, 0, 40)
	fScroll.BackgroundTransparency = 1
	fScroll.ScrollBarThickness = 0
	fScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local fLayout = Instance.new("UIListLayout", fScroll)
	fLayout.Padding = UDim.new(0, 2)

	catBtn.MouseButton1Click:Connect(function()
		frame.Visible = not frame.Visible
		catBtn.TextColor3 = frame.Visible and Color3.fromRGB(78, 173, 73) or Color3.new(1, 1, 1)
	end)

	function category:CreateButton(btnName, callback, allowHotkey)
		--[[
	This table stores EVERYTHING about the module/button.

	Toggled:
		If the main module itself is enabled.

	Values:
		Stores every setting value.
		Example:
		mod.Values.Range = 15
		mod.Values.Mode = "Rage"

	Callbacks:
		Functions that run whenever something changes.
]]
		local mod = {
			Toggled = false,
			Values = {},
			Callbacks = {}
		}

		local container = Instance.new("Frame", fScroll)
		container.Size = UDim2.new(1, 0, 0, 32)
		container.BackgroundTransparency = 1
		container.AutomaticSize = Enum.AutomaticSize.Y
		local cLayout = Instance.new("UIListLayout", container)
		cLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local btn = Instance.new("TextButton", container)
		btn.Name = btnName
		btn.Text = "    " .. btnName
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
		btn.BackgroundTransparency = 1
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.FontFace = Font.fromName(textFont)
		btn.TextSize = 22
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BorderSizePixel = 0
		btn.LayoutOrder = 1


		btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0}) end)
		btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 1}) end)

		local arrow = Instance.new("TextButton", btn)
		arrow.Text = "<b>></b>"
		arrow.RichText = true
		arrow.Size = UDim2.new(0, 30, 1, 0)
		arrow.Position = UDim2.new(1, -30, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.TextColor3 = Color3.fromRGB(130, 130, 130)
		arrow.FontFace = Font.fromName(textFont)
		arrow.TextSize = 20

		local currentBind = nil
		if allowHotkey then
			local bindLabel = Instance.new("TextButton", btn)
			bindLabel.Size = UDim2.new(0, 35, 1, 0)
			bindLabel.Position = UDim2.new(1, -70, 0, 0)
			bindLabel.BackgroundTransparency = 1
			bindLabel.Text = "[ - ]"
			bindLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
			bindLabel.FontFace = Font.fromName(textFont)
			bindLabel.TextSize = 16

			local isBinding = false
			bindLabel.MouseButton1Click:Connect(function()
				isBinding = true
				bindLabel.Text = "[...]"
			end)

			UserInputService.InputBegan:Connect(function(input, GPE)
				if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
					isBinding = false
					local key = input.KeyCode
					if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Escape then
						currentBind = nil
						bindLabel.Text = "[ - ]"
					else
						currentBind = key
						bindLabel.Text = "[" .. key.Name .. "]"
					end
				elseif not GPE and currentBind and input.KeyCode == currentBind then
					mod.Toggled = not mod.Toggled
					btn.TextColor3 = mod.Toggled and Color3.fromRGB(78, 173, 73) or Color3.new(1, 1, 1)
					if callback then callback(mod.Toggled) end
				end
			end)
		end

		local settingsCont = Instance.new("Frame", container)
		settingsCont.Size = UDim2.new(1, 0, 0, 0)
		settingsCont.BackgroundTransparency = 1
		settingsCont.Visible = false
		settingsCont.AutomaticSize = Enum.AutomaticSize.Y
		settingsCont.LayoutOrder = 2
		local sLayout = Instance.new("UIListLayout", settingsCont)
		sLayout.SortOrder = Enum.SortOrder.LayoutOrder

		btn.MouseButton1Click:Connect(function()


			mod.Toggled = not mod.Toggled


			btn.TextColor3 =
				mod.Toggled
				and Color3.fromRGB(78, 173, 73)
				or Color3.new(1, 1, 1)


			if callback then
				callback(mod.Toggled)
			end

			if mod.Callbacks.OnToggle then
				mod.Callbacks.OnToggle(mod.Toggled)
			end
		end)

		arrow.MouseButton1Click:Connect(function()
			settingsCont.Visible = not settingsCont.Visible
			arrow.Rotation = settingsCont.Visible and 90 or 0
		end)

		injectElements(mod, settingsCont)

		return mod
	end

	return category
end


UserInputService.InputBegan:Connect(function(input, GPE)
	if input.KeyCode == Enum.KeyCode.RightShift and not GPE then
		mainScreenUI.Enabled = not mainScreenUI.Enabled
	end
end)


-------------------------------------------------------------------------

FW.SettingsOverlay:CreateLabel("Global Settings")
FW.SettingsOverlay:CreateToggle("Show Watermark", true, function(state) end)
FW.SettingsOverlay:CreateColorPicker("Theme Color", Color3.fromRGB(78, 173, 73), function(col) end)

local Combat = FW:CreateCategory("Combat")
local Visuals = FW:CreateCategory("Visuals")
local Utility = FW:CreateCategory("Utility")
local Movement = FW:CreateCategory("Movement")
local GameTab = FW:CreateCategory("Game")

local Killaura = Combat:CreateButton("Killaura",nil, true)
Killaura:CreateToggle("Manual Swing", false, nil)
Killaura:CreateDropdown("Priority", {"Player", "NPC/Dummy", "Nearest"}, "Player", nil)
Killaura:CreateSlider("Hit Delay", 0.000001, 1, 0.1, nil)
Killaura:CreateSlider("Reach", 0, 28, 14, nil)
Killaura:CreateSlider("Angle Check", 0,360,180, nil)
Killaura:CreateToggle("Wall Check", false, nil)
Killaura:CreateToggle("Target Players", true, nil)
Killaura:CreateToggle("Target NPCs/Dummies", false, nil)
Killaura:CreateToggle("Face Target", false, nil)
Killaura:CreateToggle("Highlight Target", false, nil)
Killaura:CreateToggle("Require Sword Equipped", true, nil)
Killaura:CreateToggle("Multi Target Hit", false, nil)

local AimAssist = Combat:CreateButton("Aim Assist",nil, true)
AimAssist:CreateSlider("Range", 1, 150, 10000, nil)
AimAssist:CreateSlider("Smoothness", 0, 100, 50, nil)
AimAssist:CreateSlider("Shake Intensity", 0, 2, 0, nil)
AimAssist:CreateSlider("Shake Speed", 0, 20, 0, nil)
AimAssist:CreateDropdown("Priority", {"Player", "NPC/Dummy"}, "Player", nil)
AimAssist:CreateToggle("Target Players" , true, nil)
AimAssist:CreateToggle("Target NPC/Dummies" , false, nil)
AimAssist:CreateToggle("Sync with KA Target" , false, nil)
AimAssist:CreateToggle("Require Sword Equipped", false, nil)
AimAssist:CreateToggle("Track Through Walls", true, nil)
AimAssist:CreateToggle("Face Target", false,nil)

local Velocity = Combat:CreateButton("Velocity", nil, true)
Velocity:CreateSlider("Horizontal", 0, 100, 100, nil)
Velocity:CreateSlider("Velocity", 0, 100, 100, nil)
Velocity:CreateSlider("Left Knockback", 0, 100, 100, nil)
Velocity:CreateSlider("Right Knockback", 0, 100, 100, nil)
Velocity:CreateSlider("Front Knockback", 0, 100, 100, nil)
Velocity:CreateSlider("Back Knockback", 0, 100, 100, nil)
Velocity:CreateSlider("Up Knockback", 0, 100, 100, nil)
Velocity:CreateSlider("Down Knockback", 0, 100, 100, nil)
Velocity:CreateDropdown("Knockback Direction", {"Normal", "Backwards", "Reversed", "Up"}, "Normal", nil)
Velocity:CreateToggle("Take Knockback On Bridges", true,nil)
Velocity:CreateSlider("Bridge Horizontal Knockback", 0, 100, 50, nil)
Velocity:CreateSlider("Bridge Vertical Knockback", 0, 100, 50, nil)

local AutoClicker = Combat:CreateButton("Auto Clicker", nil, true)
AutoClicker:CreateSlider("CPS", 1,40,7, nil)
AutoClicker:CreateSlider("CDC", 1, 100, 50, nil)
AutoClicker:CreateToggle("Require Mouse Held", true, nil)

local Reach = Combat:CreateButton("Reach", nil, true)

local AutoShoot = Combat:CreateButton("AutoShoot", nil, true)
AutoShoot:CreateSlider("Range", 1, 1000, 50)
AutoShoot:CreateToggle("Target Players", true, nil)
AutoShoot:CreateToggle("Target NPCs/Dummies", false, nil)
AutoShoot:CreateToggle("Aim at Head", false, nil)
AutoShoot:CreateToggle("Aim at Torso", true, nil)
AutoShoot:CreateSlider("Chance of headshot", 1, 100, 100, nil)
AutoShoot:CreateSlider("Chance of shot", 1, 100, 100, nil)
--AutoShoot:CreateToggle("Randomize headshots & shots", false, nil)
--AutoShoot:CreateSlider("Randomization", 1, 100, 50, nil)
AutoShoot:CreateDropdown("Projectiles", {"arrow", "snowball", "mage_spell_base"}, "arrow", nil, true)
AutoShoot:CreateSlider("Shoot duration", 0.01, 2, 0.4)
local AutoSprint = Movement:CreateButton("Auto Sprint", nil, true)
AutoSprint:CreateToggle("Bypass all items")
AutoSprint:CreateToggle("Don't auto sprint on gloops")

local WhiteHits = Visuals:CreateButton("White Hits", nil, true)

local ChestStealer = Utility:CreateButton("Chest Stealer", nil, true)
ChestStealer:CreateSlider("Range", 1, 50, 25, nil)
ChestStealer:CreateToggle("Crates")
ChestStealer:CreateToggle("Chests")

local AutoArmorSwitch = Utility:CreateButton("Auto Armor Switch", nil, true)
AutoArmorSwitch:CreateSlider("Range",1, 75, 30)

local fastDrop = Utility:CreateButton("Fast Drop", nil, true)


local function isInFOV(myHRP, targetHRP, maxAngle)
	local forward = myHRP.CFrame.LookVector
	local toTarget = (targetHRP.Position - myHRP.Position).Unit

	local dot = forward:Dot(toTarget)

	local angle = m_deg((m_acos(math.clamp(dot, -1, 1))))

	return angle <= maxAngle
end

local function faceTarget(characterA, characterB)
	local hrpA = characterA:FindFirstChild("HumanoidRootPart")
	local hrpB = characterB:FindFirstChild("HumanoidRootPart")

	characterA.Humanoid.AutoRotate = false


	if hrpA and hrpB then

		local lookPosition = Vector3.new(hrpB.Position.X, hrpA.Position.Y, hrpB.Position.Z)


		hrpA.CFrame = CFrame.lookAt(hrpA.Position, lookPosition)

		characterA.Humanoid.AutoRotate = true
	end
end

local kaHighlight = Instance.new("Highlight")
kaHighlight.FillColor = Color3.fromRGB(255, 0, 0) -- Change color as needed
kaHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
kaHighlight.FillTransparency = 0.5
kaHighlight.OutlineTransparency = 0
kaHighlight.Adornee = nil

-- Parent to CoreGui to avoid detection, fallback to workspace if it fails
pcall(function() kaHighlight.Parent = game:GetService("CoreGui") end)
if not kaHighlight.Parent then kaHighlight.Parent = workspace end

Killaura.Callbacks.OnToggle = function(state)
	Killaura.Toggled = state

	if state == false then 
		kaHighlight.Adornee = nil 
		return 
	end

	task.spawn(function()
		while Killaura.Toggled do

			local hitDelay = Killaura.Values["Hit Delay"]

				task.wait(hitDelay)
			

			kaHighlight.Adornee = nil

			if not (Killaura.Values["Target Players"] or Killaura.Values["Target NPCs/Dummies"]) then
				continue
			end

			local char = Player.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then
				continue
			end
			local rootPart = char.HumanoidRootPart

			local handItem = char:WaitForChild("HandInvItem", 1) 
			if not handItem then
				continue
			end


			if Killaura.Values["Require Sword Equipped"] == true then
				if not t_find(swords, tostring(handItem.Value)) then
					continue
				end
			end 

			local playertarget = nil
			local playerdistance = findTargetStuds 

			local npcdummytarget = nil
			local npcdummydistance = findTargetStuds 

			local besttarget = nil

			if Killaura.Values["Target Players"] then
				for _, v in pairs(Players:GetChildren()) do
					local targetPlayer = Players:GetPlayerFromCharacter(v.Character)

					if v ~= Player and targetPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Team ~= Player.Team then
						local distance = (rootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude

						if distance <= playerdistance then
							playertarget = v.Character
							playerdistance = distance
						end
					end
				end
			end

			if Killaura.Values["Target NPCs/Dummies"] then
				for _, npc in pairs(workspace:GetChildren()) do
					if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.PrimaryPart then
						if not Players:GetPlayerFromCharacter(npc) then
							local distance = (rootPart.Position - npc.PrimaryPart.Position).Magnitude

							if distance <= npcdummydistance then
								npcdummytarget = npc
								npcdummydistance = distance
							end
						end
					end
				end
			end

			local priority = Killaura.Values["Priority"]

			if priority == "Player" then
				if playertarget then
					besttarget = playertarget
				else
					besttarget = npcdummytarget
				end
			elseif priority == "NPC/Dummy" then
				besttarget = npcdummytarget or playertarget
			elseif priority == "Nearest" then
				if playertarget and npcdummytarget then
					if playerdistance <= npcdummydistance then
						besttarget = playertarget
					else
						besttarget = npcdummytarget
					end
				else
					besttarget = playertarget or npcdummytarget
				end
			else
				print("WARNING: Unrecognized Priority value ->", tostring(priority))
			end

			-- FIX: Fully restructured the attack block to prevent the nested trap
			if besttarget then
				local HRP = rootPart 
				local targetHRP = besttarget.PrimaryPart
				local dir = (targetHRP.Position - HRP.Position).Unit

				local inventoryWeapon = nil
				local swordName = nil
				local oldItem = tostring(handItem.Value)

				if oldItem == nil then
					oldItem = "hand"
				end

				-- 1. Get the proper weapon based on the toggle setting
				if Killaura.Values["Require Sword Equipped"] == true then
					inventoryWeapon = game.ReplicatedStorage:FindFirstChild("Inventories"):FindFirstChild(Player.Name):FindFirstChild(oldItem)
					if not inventoryWeapon then continue end
				else
					swordName = tostring(getBestEquippedSword(Player.Name))

					inventoryWeapon = game.ReplicatedStorage:FindFirstChild("Inventories"):FindFirstChild(Player.Name):FindFirstChild(swordName)
					print(swordName,inventoryWeapon)
					if not inventoryWeapon then continue end
				end

				-- 2. Build the packet
				local kaArgs = {
					[1] = {
						["chargedAttack"] = { ["chargeRatio"] = 0 },
						["entityInstance"] = besttarget,
						["validate"] = {
							["selfPosition"] = { ["value"] = HRP.Position + dir * 5.5 },
							["targetPosition"] = { ["value"] = targetHRP.Position }
						},
						["weapon"] = inventoryWeapon
					}
				}

				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {HRP.Parent, besttarget}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true

				if Killaura.Values["Wall Check"] == true then
					local wallRaycast = workspace:Raycast(HRP.Position, besttarget.PrimaryPart.Position - HRP.Position, raycastParams)
					if wallRaycast then
						currentKaTarget = nil
						continue
					end
				end

				local angleMet = isInFOV(HRP, besttarget.PrimaryPart, Killaura.Values["Angle Check"])

				if not angleMet then
					currentKaTarget = nil
					continue
				end

				if Killaura.Values["Manual Swing"] == true then
					if clicking == false then
						continue
					end
				end

				local distance = (HRP.Position - targetHRP.Position).Magnitude
				local reach = tonumber(Killaura.Values["Reach"])

				if distance > reach then
					currentKaTarget = nil
					continue
				end

				-- Maximize target spoofing for extended reach
				local spoofedTargetPosition = targetHRP.Position
				local maxNormalReach = 14 

				if distance > maxNormalReach then
					local dirToSelf = (HRP.Position - targetHRP.Position).Unit
					spoofedTargetPosition = targetHRP.Position + (dirToSelf * (distance - maxNormalReach + 0.5))
				end

				kaArgs[1].validate.targetPosition.value = spoofedTargetPosition
				currentKaTarget = besttarget

				if Killaura.Values["Highlight Target"] == true then
					kaHighlight.Adornee = besttarget
				else
					kaHighlight.Adornee = nil
				end

				-- 3. Auto-Equip best sword if required
				if Killaura.Values["Require Sword Equipped"] == false and oldItem ~= swordName then
					local bestWeaponInst = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild(swordName)
					local args = {{ hand = bestWeaponInst }}
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(args))
				end

				-- 4. Swing
				SwordHitRemote:FireServer(unpack(kaArgs))

				-- 5. Auto-Unequip best sword back to original item
				if Killaura.Values["Require Sword Equipped"] == false and oldItem ~= swordName then
					if oldItem == nil then

					end
					local oldWeaponInst = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild(oldItem)
					local args = {{ hand = oldWeaponInst }}
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(args))
				end

				hitting = true
				lastHit = os.clock()

				if Killaura.Values["Face Target"] == true then
					faceTarget(rootPart.Parent, besttarget)
				end
			else
				currentKaTarget = nil
				kaHighlight.Adornee = nil
			end

		end
	end)
end
UserInputService.InputBegan:Connect(function(input, GPE)
	if GPE then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		startTime = os.clock()
	end
end)

UserInputService.InputEnded:Connect(function(input, GPE)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local currentTime = os.clock()
		local heldTime = currentTime - startTime

		if heldTime <= maxHoldTime then

			local timeSinceLastClick = currentTime - lastClickTime


			if timeSinceLastClick <= maxClickInterval then
				if not clicking then
					clicking = true
				end
			end


			lastClickTime = currentTime

			if resetTask then
				task.cancel(resetTask) 
			end


			resetTask = task.delay(maxClickInterval, function()
				clicking = false
			end)

		else

			clicking = false
		end
	end
end)

Player.CharacterAdded:Connect(function(character)
	if Killaura.Toggled == true and Killaura.Values["Equip Sword Upon Death"] == true then

	end
end)

local function getAlpha()
	return math.clamp(1 - (AimAssist.Values["Smoothness"] / 100), 0.01, 1)
end

AimAssist.Callbacks.OnToggle = function(state)
	AimAssist.Toggled = state

	if state == false then 

		if aimConnection then
			aimConnection:Disconnect()
			aimConnection = nil
		end
		currentTarget = nil
		return 
	end


	aimConnection = RunService.RenderStepped:Connect(function()

		if currentTarget and currentTarget.PrimaryPart then
			local targetPart = currentTarget.PrimaryPart

			local shakeIntensity = AimAssist.Values["Shake Intensity"]
			local shakeSpeed = AimAssist.Values["Shake Speed"]
			local currentTime = os.clock() * shakeSpeed

			local offsetX = math.noise(currentTime, 0, 0) * shakeIntensity
			local offsetY = math.noise(0, currentTime, 0) * shakeIntensity
			local offsetZ = math.noise(0, 0, currentTime) * shakeIntensity

			local shakeVector = Vector3.new(offsetX, offsetY, offsetZ)

			local spoofedTargetPos = targetPart.Position + shakeVector

			local goalCFrame = CFrame.new(camera.CFrame.Position, spoofedTargetPos)
			local char = Player.Character
			if not char then return end 

			local handItem = char:FindFirstChild("HandInvItem", true) 

			if AimAssist.Values["Sync with KA Target"] == false and AimAssist.Values["Track Through Walls"] == false then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {char, currentTarget} 
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true

				local origin = camera.CFrame.Position
				local direction = targetPart.Position - origin
				local wallHit = workspace:Raycast(origin, direction, raycastParams)


				if wallHit then
					return 
				end
			end



			if AimAssist.Values["Require Sword Equipped"] == true then
				if handItem and table.find(swords, tostring(handItem.Value)) then
					if AimAssist.Values["Face Target"] == true then faceTarget(char, currentTarget) end
					camera.CFrame = camera.CFrame:Lerp(goalCFrame, getAlpha())

				else
					return 
				end
			else
				if AimAssist.Values["Face Target"] == true then faceTarget(char, currentTarget) end
				camera.CFrame = camera.CFrame:Lerp(goalCFrame, getAlpha())
			end
		end
	end)

	task.spawn(function()
		while AimAssist.Toggled do
			task.wait(0.05) 


			local char = Player.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then
				currentTarget = nil
				continue 
			end
			local myHRP = char.HumanoidRootPart


			local playerTarget = nil
			local dummyTarget = nil
			local bestTarget = nil

			if AimAssist.Values["Target Players"] == true then
				for _, player in pairs(game.Players:GetPlayers()) do
					if player == Player or player.Team == Player.Team or player.Character == nil then continue end
					local targetCharacter = workspace:FindFirstChild(player.Name)

					if targetCharacter then
						local HRP = targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter.PrimaryPart

						if HRP then
							local distance = (HRP.Position - myHRP.Position).Magnitude

							if distance <= AimAssist.Values["Range"] then
								playerTarget = targetCharacter
							end
						end
					end
				end
			end

			if AimAssist.Values["Target NPC/Dummies"] == true then
				for _, npc in pairs(workspace:GetChildren()) do
					if npc:IsA("Model") and npc:FindFirstChild("Humanoid", true) then
						if Players:FindFirstChild(npc.Name) then continue end
						local HRP = npc.PrimaryPart
						if HRP then
							local distance = (HRP.Position - myHRP.Position).Magnitude

							if distance <= AimAssist.Values["Range"] then
								print("a")
								dummyTarget = npc

							end
						end
					end
				end
			end

			local priority = AimAssist.Values["Priority"]

			if priority == "Player" then
				bestTarget = playerTarget or dummyTarget
			elseif priority == "NPC/Dummy" then
				bestTarget = dummyTarget or playerTarget
			end

			if AimAssist.Values["Sync with KA Target"] == true then
				local kaTarget = currentKaTarget 

				if kaTarget and kaTarget:FindFirstChild("Humanoid") and kaTarget.Humanoid.Health > 0 then
					currentTarget = bestTarget
				else
					currentTarget = nil
				end

				continue
			end

			if bestTarget and bestTarget:FindFirstChild("Humanoid") and bestTarget.Humanoid.Health > 0 then
				print("correct")
				currentTarget = bestTarget
			else
				currentTarget = nil
			end
		end
	end)
end


-- Radar for Bridges
local function IsOnVoidOrBridge(hrp)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {hrp.Parent}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local pos = hrp.Position
	local down = Vector3.new(0, -20, 0)
	if not workspace:Raycast(pos, down, params) then return true end
	local right = hrp.CFrame.RightVector * 4
	local forward = hrp.CFrame.LookVector * 4
	if not workspace:Raycast(pos + right, down, params) or not workspace:Raycast(pos - right, down, params) or
		not workspace:Raycast(pos + forward, down, params) or not workspace:Raycast(pos - forward, down, params) then
		return true 
	end
	return false
end

local isSystemEnabled = false
Velocity.Callbacks.OnToggle = function(state) isSystemEnabled = state end
local lastVelocity = Vector3.zero

AutoShoot.Callbacks.OnToggle = function(state)
	autoShoot = state 
end

local function generateId()
	local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local id = ""
	for i = 1, 8 do
		local randomIndex = math.random(1, #characters)
		id = id .. string.sub(characters, randomIndex, randomIndex)
	end
	return id
end

local loadedAnimations = {}
local activeHoldTrack = nil

local function getLoadedTrack(animator, ID)
	local cacheKey = tostring(animator) .. "_" .. ID
	if not loadedAnimations[cacheKey] then
		local animation = Instance.new("Animation")
		animation.AnimationId = ID
		loadedAnimations[cacheKey] = animator:LoadAnimation(animation)
	end
	return loadedAnimations[cacheKey]
end

local function playHoldAnimation(animator, ID)
	local holdTrack = getLoadedTrack(animator, ID)

	if activeHoldTrack and activeHoldTrack ~= holdTrack then
		activeHoldTrack:Stop()
	end

	if not holdTrack.IsPlaying then
		holdTrack:Play()
	end

	activeHoldTrack = holdTrack
end

local lastShootAnimTime = 0
local VISUAL_COOLDOWN = 0.1 -- Plays a max of 10 times per second

local function stopHoldAnimation()
	if activeHoldTrack and activeHoldTrack.IsPlaying then
		activeHoldTrack:Stop()
	end
	activeHoldTrack = nil
end


local function playShootAnimation(animator, ID)
	local currentTime = os.clock()

	-- If it hasn't been long enough since the last animation, skip it.
	-- The projectile still fires, but we don't break the animator.
	if currentTime - lastShootAnimTime < VISUAL_COOLDOWN then
		return 
	end

	lastShootAnimTime = currentTime

	local shootTrack = getLoadedTrack(animator, ID)
	shootTrack:Stop()
	shootTrack:Play()
end
local function fireProjectile(projectileName, HRP, targetPart, itemRequired, target)

	local origin = HRP.Position
	if not targetPart then return end
	
	if not Player.Character then return end

	local character = Player.Character 
	local playerFolder = inventoriesFolder:FindFirstChild(Player.Name)
	local Handinvitem = character:FindFirstChild("HandInvItem")
	
	if not humanoid then return end
	if not animator then return end
	
	local handItemName = tostring(Handinvitem.Value.Name)

	local targetPos = targetPart.Position
	if targetPart.Name == "Head" then
		targetPos = targetPart.Position + Vector3.new(0,1,0)
	end
	local direction = (targetPos - origin).Unit

	local speed = 150
	local thirdPos = direction * speed

	local ID = 0
	ID = generateId()

	local args = {
		inventoriesFolder:FindFirstChild(Player.Name):FindFirstChild(tostring(itemRequired or projectileName)),
		tostring(projectileName),
		tostring(projectileName),
		vector.create(origin.X, origin.Y, origin.Z),
		vector.create(HRP.Position.X, HRP.Position.Y, HRP.Position.Z),
		vector.create(thirdPos.X, thirdPos.Y, thirdPos.Z),
		generateId(),
		{
			shotId = ID,
			drawDurationSec = AutoShoot.Values["Shoot duration"]
		},
		workspace:GetServerTimeNow()
	}
	
	task.spawn(function()
		-- 1. Stop the hold animation to return to an idle stance
		stopHoldAnimation()

		-- 2. Play the quick shoot animation
		if handItemName == "wood_bow" then
			playShootAnimation(animator, BOW_SHOOT_ANIMATION_ID)
		elseif handItemName == "wood_crossbow" then
			playShootAnimation(animator, CB_SHOOT_ANIMATION_ID)
		elseif handItemName == "headhunter" then
			playShootAnimation(animator, HH_SHOOT_ANIMATION_ID)
		end
	end)
	
	
	fireProjectileEvent:InvokeServer(unpack(args))

	local args = {
		tostring(ID),
		workspace:WaitForChild(target.Name)
	}
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileHit"):FireServer(unpack(args))
	print("done both")
end


RunService.Heartbeat:Connect(function()
	if not isSystemEnabled or not Player.Character then return end
	local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Player.Character:FindFirstChild("Humanoid")
	if not HRP or not Humanoid then return end

	local currentVel = HRP.AssemblyLinearVelocity
	local deltaVel = currentVel - lastVelocity

	-- JUMP PROTECTION
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		deltaVel = Vector3.new(deltaVel.X, 0, deltaVel.Z)
	end

	-- 1. DETECTION
	local forceMagnitude = deltaVel.Magnitude
	local isKnockbackHit = forceMagnitude > 25

	if isKnockbackHit then
		local lookVector = HRP.CFrame.LookVector
		local forceDirection = deltaVel.Unit
		local alignment = lookVector:Dot(forceDirection)

		if alignment > 0.7 then 
			isKnockbackHit = false 
		end
	end

	if isKnockbackHit then
		local isOnBridge = IsOnVoidOrBridge(HRP)

		if isOnBridge and Velocity.Values["Take Knockback On Bridges"] == false then
			HRP.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
			lastVelocity = HRP.AssemblyLinearVelocity
			return
		end

		local hMaster = (isOnBridge and (Velocity.Values["Bridge Horizontal Knockback"] or 100) or (Velocity.Values["Horizontal"] or 100)) / 100
		local vMaster = (isOnBridge and (Velocity.Values["Bridge Vertical Knockback"] or 100) or (Velocity.Values["Velocity"] or 100)) / 100

		local localHit = HRP.CFrame:VectorToObjectSpace(deltaVel)

		local modX = (localHit.X * ((localHit.X > 0 and Velocity.Values["Right Knockback"] or Velocity.Values["Left Knockback"]) / 100)) * hMaster
		local modZ = (localHit.Z * ((localHit.Z > 0 and Velocity.Values["Back Knockback"] or Velocity.Values["Front Knockback"]) / 100)) * hMaster
		local modY = (localHit.Y * ((localHit.Y > 0 and Velocity.Values["Up Knockback"] or Velocity.Values["Down Knockback"]) / 100)) * vMaster

		local kbDir = Velocity.Values["Knockback Direction"] or "Normal"
		if kbDir == "Backwards" then modZ = math.abs(modZ); modX = 0
		elseif kbDir == "Reversed" then modX = -modX; modZ = -modZ; modY = -modY
		elseif kbDir == "Up" then modX = 0; modZ = 0; modY = math.max(50, math.abs(modY)) end

		local newWorld = HRP.CFrame:VectorToWorldSpace(Vector3.new(modX, (vMaster > 0 and modY or 0), modZ))

		HRP.AssemblyLinearVelocity = Vector3.new(
			currentVel.X - deltaVel.X + newWorld.X,
			(vMaster > 0 and (currentVel.Y - deltaVel.Y + newWorld.Y) or currentVel.Y),
			currentVel.Z - deltaVel.Z + newWorld.Z
		)
	end

	lastVelocity = HRP.AssemblyLinearVelocity
end)

local function findClosestPlr(radius, rootPart)
	local closestCharacter = nil
	local shortestDistance = radius 

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= Player and targetPlayer.Team ~= Player.Team then
			local character = targetPlayer.Character

			if character then
				local targetRoot = character:FindFirstChild("HumanoidRootPart")

				if targetRoot then
					local distance = (rootPart.Position - targetRoot.Position).Magnitude

					if distance < shortestDistance then
						closestCharacter = character
						shortestDistance = distance
					end
				end
			end
		end
	end

	if closestCharacter then
		return closestCharacter, shortestDistance
	else
		return nil, nil
	end
end

local Players = game:GetService("Players")

local function findClosestNPC(radius, rootPart)
	local closestNPC = nil
	local shortestDistance = radius

	for _, npc in ipairs(workspace:GetChildren()) do

		if npc:IsA("Model") then
			local humanoid = npc:FindFirstChild("Humanoid")
			local targetRoot = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and targetRoot and not Players:GetPlayerFromCharacter(npc) then

				local distance = (rootPart.Position - targetRoot.Position).Magnitude

				if distance < shortestDistance then
					closestNPC = npc
					shortestDistance = distance
				end
			end
		end
	end

	if closestNPC then
		return closestNPC, shortestDistance
	else
		return nil, nil
	end
end

local lastShotTimes = {}

local WeaponStats = {
	["wood_bow"]      = { Charge = 0.8, Cooldown = 0.1 },  -- Bows must be drawn back
	["wood_crossbow"] = { Charge = 0.0, Cooldown = 1.3 },  -- Crossbows fire instantly, reload slow
	["headhunter"]    = { Charge = 0.0, Cooldown = 1.3 },  -- Sniper fires instantly, reloads slow
	["snowball"]      = { Charge = 0.0, Cooldown = 0.01 }, -- Fast projectiles
	["fireball"]      = { Charge = 0.0, Cooldown = 0.1 },
}

-- ==========================================
-- 2. THE AUTO-SHOOT LOOP
-- ==========================================
task.spawn(function()
	while true do
		task.wait(0.05) 

		if not autoShoot then continue end
		if not AutoShoot.Values["Aim at Head"] and not AutoShoot.Values["Aim at Torso"] then continue end
		if #AutoShoot.Values["Projectiles"] == 0 then continue end
		if not Player.Character then continue end

		local character = Player.Character 
		local HRP = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")

		if inventoriesFolder and animator then
			local playerFolder = inventoriesFolder:FindFirstChild(Player.Name)
			local Handinvitem = character:FindFirstChild("HandInvItem")

			if not playerFolder or not Handinvitem or Handinvitem.Value == nil then continue end

			local item = playerFolder:FindFirstChild(Handinvitem.Value.Name)
			if not item then continue end

			-- --- FIND TARGETS ---
			local plrTarget, plrDistance = nil, nil
			local npcTarget, npcDistance = nil, nil
			local bestTarget = nil

			if AutoShoot.Values["Target Players"] == true then
				plrTarget, plrDistance = findClosestPlr(AutoShoot.Values["Range"], HRP)
			end

			if AutoShoot.Values["Target NPCs/Dummies"] == true then
				npcTarget, npcDistance = findClosestNPC(AutoShoot.Values["Range"], HRP)
			end

			if plrTarget and npcTarget then
				bestTarget = (plrDistance >= npcDistance) and plrTarget or npcTarget
			elseif plrTarget then bestTarget = plrTarget
			elseif npcTarget then bestTarget = npcTarget
			else continue end

			-- --- PROJECTILE LOGIC ---
			local handItemName = tostring(Handinvitem.Value.Name)
			local projectileName = nil

			if table.find(bows, handItemName) then
				if playerFolder:FindFirstChild("arrow") then
					projectileName = "arrow"
				end
			elseif table.find(AutoShoot.Values["Projectiles"], handItemName) then
				projectileName = handItemName
			end

			if projectileName == nil then continue end

			-- ==========================================
			-- TIMELINE & COOLDOWN LOGIC
			-- ==========================================
			local currentTime = os.clock()
			local currentTime = os.clock()

			-- Get weapon stats, or default to 0 charge / safe cooldown
			local stats = WeaponStats[handItemName] or { Charge = 0, Cooldown = 0.3 }
			local actualCharge = stats.Charge
			local actualCooldown = stats.Cooldown

			-- If your GUI 'Shoot duration' is set HIGHER than the weapon's built-in delay, respect the GUI
			local guiDelay = AutoShoot.Values["Shoot duration"] or 0
			if guiDelay > (actualCharge + actualCooldown) then
				actualCooldown = guiDelay - actualCharge
			end

			local totalCycleTime = actualCharge + actualCooldown

			-- If not enough time has passed since we last fired THIS weapon, skip this cycle
			if currentTime - (lastShotTimes[handItemName] or 0) < totalCycleTime then
				continue 
			end

			-- Mark the timestamp of this shot right now to block other iterations
			lastShotTimes[handItemName] = currentTime

			-- Determine target part
			local chanceOfHeadShot = AutoShoot.Values["Chance of headshot"]
			local chanceOfShot = AutoShoot.Values["Chance of shot"]
			local headshotChance = math.random(1, 100)
			local shotChance = math.random(1, 100)

			local targetPart = nil
			if AutoShoot.Values["Aim at Head"] and AutoShoot.Values["Aim at Torso"] then
				if chanceOfHeadShot >= headshotChance then targetPart = bestTarget:FindFirstChild("Head")
				elseif chanceOfShot >= shotChance then targetPart = bestTarget:FindFirstChild("UpperTorso") end
			elseif AutoShoot.Values["Aim at Torso"] and not AutoShoot.Values["Aim at Head"] then
				if chanceOfShot >= shotChance then targetPart = bestTarget:FindFirstChild("UpperTorso") end
			elseif not AutoShoot.Values["Aim at Torso"] and AutoShoot.Values["Aim at Head"] then
				if chanceOfHeadShot >= headshotChance then targetPart = bestTarget:FindFirstChild("Head") end
			end

			-- Handle animations and firing
			if targetPart then
				-- Only play hold animation and yield if the weapon actually requires CHARGING (like a bow)
				if actualCharge > 0 then
					if handItemName == "wood_bow" then
						playHoldAnimation(animator, BOW_HOLD_ANIMATION_ID)
					elseif handItemName == "wood_crossbow" then
						playHoldAnimation(animator, CB_HOLD_ANIMATION_ID)
					elseif handItemName == "headhunter" then
						playHoldAnimation(animator, HH_HOLD_ANIMATION_ID)
					end

					-- Yield visually to show the charge-up
					task.wait(actualCharge) 
				end

				if not Handinvitem or not Handinvitem.Value then stopHoldAnimation() continue end
				-- Fire the projectile asynchronously so it doesn't freeze the loop
				task.spawn(function()
					fireProjectile(projectileName, HRP, targetPart, handItemName, bestTarget)
				end)

			else
				-- If target is lost before firing, drop the weapon
				stopHoldAnimation()
			end
		end
	end
end)

--WHITE HITS BUTTON

WhiteHits.Callbacks.OnToggle = function(state)
	whiteHits = state
end

RunService.Heartbeat:Connect(function()
	if not whiteHits then return end

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character 

		if character then
			local highlight = character:FindFirstChild("_DamageHighlight_")

			if highlight and highlight.Enabled then
				highlight.Enabled = false
			end
		end
	end
end)

--WHITE HITS BUTTON

local function findNearbyChests(radius)
	if stealChests == false or nil then return end
	local chests = {}

	for i, chest in pairs(inventoriesFolder:GetChildren()) do
		if chest and chest:GetAttribute("Chest") == true then
			if chest:FindFirstChild("ChestOwner") and Character then
				local chestModel = chest.ChestOwner.Value

				local distance = (chestModel.Position - Character.PrimaryPart.Position).Magnitude

				if distance <= radius then
					table.insert(chests, chestModel)
				end
			end
		end

	end

	return chests

end

ChestStealer.Callbacks.OnToggle = function(state)
	stealChests = state
end

RunService.Heartbeat:Connect(function()
	if not stealChests then return end

	if Player.Character and Player.Character.Humanoid then
		local character = Player.Character
		local Humanoid = Character.Humanoid

		if Humanoid.Health > 0 then
			local chests = findNearbyChests(ChestStealer.Values["Range"])

			for i, chest in pairs(chests) do
				if inventoriesFolder:FindFirstChild(chest) then
					local chestInventory = chest.Value

					if chestInventory then
						for i, item in pairs(chestInventory:GetChildren()) do
							if item and item:GetAttribute("Amount") then
								local blockChest = chestInventory.Name
								local diamondItem = chestInventory:FindFirstChild(tostring(item.Name)) -- You'll need to verify the exact name of the object in the explorer

								local args = {
									blockChest,
									diamondItem 
								}

								game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("Inventory/ChestGetItem"):InvokeServer(unpack(args))
							end
						end
					end
				end
			end
		end
	end
end)
