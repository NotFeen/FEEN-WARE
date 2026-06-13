local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local FILE_NAME = "UI_AutoSave_Config.json"

-- Master table to hold all session settings
_G.SavedConfig = {}
_G.IsBindingKey = false -- Prevent hotkeys from firing while re-binding

-- Load settings from PC on startup
if readfile and pcall(function() return readfile(FILE_NAME) end) then
	local fileContent = readfile(FILE_NAME)
	local success, decoded = pcall(function() return HttpService:JSONDecode(fileContent) end)
	if success and decoded then
		_G.SavedConfig = decoded
		print("[AutoSave] Successfully loaded configuration from PC.")
	end
end

-- Universal function to save the config to your PC
local function saveConfigToPC()
	if writefile then
		local success, jsonString = pcall(function()
			return HttpService:JSONEncode(_G.SavedConfig)
		end)
		if success then
			writefile(FILE_NAME, jsonString)
		end
	end
end

local loops = {
	killaura = false,
	["aim assist"] = false,
	velocity = false,
	reach = false,
	["auto shoot"] = false,
	["auto sprint"] = false,
	["white hits"] = false,
	["chest stealer"] = false,
	["auto armor switch"] = false,
	["fast drop"] = false,
	["auto balloon"] = false,
	["auto pearl"] = false,
	["void drop"] = false
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

local balloonEvent = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.InflateBalloon

local DIRECTION_MODES = {
	["Normal"] = "Normal",
	["Backwards"] = "Backwards",
	["Reversed"] = "Reversed",
	["Up"] = "Up"
}

local WeaponSpeeds = {
	["wood_bow"] = 150,
	["wood_crossbow"] = 200,
	["mage_spellbook"] = 120,
	["whim_spellbook"] = 135,
	["frost_staff_1"] = 100
}

local telepearlSpeed = 125

local WeaponStats = {
	["wood_bow"] = { Charge = 0.5, Cooldown = 0.5 },
	["wood_crossbow"] = { Charge = 0.2, Cooldown = 0.8 },
	["mage_spellbook"] = { Charge = 0.0, Cooldown = 0.11 },
	["whim_spellbook"] = { Charge = 0.0, Cooldown = 0.15 },
	["frost_staff_1"] = { Charge = 0.1, Cooldown = 0.3 }
}

local AutoShoot = {
	Values = {
		["Target Players"] = true,
		["Target NPCs/Dummies"] = true,
		["Range"] = 500,
		["Aim at Head"] = true,
		["Aim at Torso"] = true,
		["Chance of headshot"] = 50,
		["Chance of shot"] = 100,
		["Shoot duration"] = 0,
		["Projectiles"] = {"wood_bow", "wood_crossbow", "mage_spellbook", "whim_spellbook"}
	}
}
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

local weaponTiers = {
	["rageblade"] = 50000,
	["rage_blade"] = 50000,

	["noctium_blade_4"] = 40004,
	["noctium_blade_3"] = 40003,
	["noctium_blade_2"] = 40002,
	["noctium_blade"] = 40001,

	["emerald_sword"] = 30006,
	["diamond_sword"] = 30005,
	["iron_sword"] = 30004,
	["stone_sword"] = 30003,
	["big_wood_sword"] = 30002,
	["wood_sword"] = 30001,

	["emerald_dao"] = 20005,
	["diamond_dao"] = 20004,
	["iron_dao"] = 20003,
	["stone_dao"] = 20002,
	["wood_dao"] = 20001,

	["void_sword"] = 10005,
	["frosty_hammer"] = 10004,
	["light_sword"] = 10003,
	["laser_sword"] = 10002,
	["ice_sword"] = 10001
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

local startTime = 0
local lastClickTime = 0
local clicking = false

local lastShotTimes = {}
local firingLocks = {} 
local currentHoldTrack = nil 

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

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local textFont = "Zekton"
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DRAG_SMOOTHNESS = 0.2

local HH_HOLD_ANIMATION_ID = "rbxassetid://13421339706"
local HH_SHOOT_ANIMATION_ID = "rbxassetid://13421344632"
local BOW_HOLD_ANIMATION_ID = "rbxassetid://15222797648"
local BOW_SHOOT_ANIMATION_ID = "rbxassetid://8860294521"
local CB_HOLD_ANIMATION_ID = "rbxassetid://8860301164"
local CB_SHOOT_ANIMATION_ID = "rbxassetid://8860304406"

local oldGui = PlayerGui:FindFirstChild("FeatherWare")
if oldGui then oldGui:SetAttribute("Running", false) task.wait(0.15) oldGui:Destroy() end

local mainScreenUI = Instance.new("ScreenGui")
mainScreenUI.Parent = PlayerGui
mainScreenUI.Name = "FeatherWare"
mainScreenUI.ResetOnSpawn = false
mainScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
mainScreenUI.DisplayOrder = 5000
mainScreenUI:SetAttribute("Running", true)

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
	["rageblade"] = 50000,
	["rage_blade"] = 50000,

	["noctium_blade_4"] = 40004,
	["noctium_blade_3"] = 40003,
	["noctium_blade_2"] = 40002,
	["noctium_blade"] = 40001,

	["emerald_sword"] = 30006,
	["diamond_sword"] = 30005,
	["iron_sword"] = 30004,
	["stone_sword"] = 30003,
	["big_wood_sword"] = 30002,
	["wood_sword"] = 30001,

	["emerald_dao"] = 20005,
	["diamond_dao"] = 20004,
	["iron_dao"] = 20003,
	["stone_dao"] = 20002,
	["wood_dao"] = 20001,

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

local FW = {}

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

local function injectElements(mod, settingsCont, uniquePrefix)
	uniquePrefix = uniquePrefix or "Overlay"

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
		local settingID = uniquePrefix .. "_" .. tName

		if _G.SavedConfig[settingID] ~= nil then
			default = _G.SavedConfig[settingID]
		else
			_G.SavedConfig[settingID] = default
		end

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

		if tCallback then tCallback(toggledState) end

		tFrame.MouseButton1Click:Connect(function()
			toggledState = not toggledState
			tFrame.TextColor3 = toggledState and Color3.fromRGB(78, 173, 73) or Color3.fromRGB(180, 180, 180)
			mod.Values[tName] = toggledState

			_G.SavedConfig[settingID] = toggledState
			saveConfigToPC()

			if tCallback then tCallback(toggledState) end
			if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(tName, toggledState) end
		end)
	end

	function mod:CreateSlider(sName, min, max, default, sCallback, sStep)
		sStep = sStep or 0.01
		local settingID = uniquePrefix .. "_" .. sName

		if _G.SavedConfig[settingID] ~= nil then
			default = _G.SavedConfig[settingID]
		else
			_G.SavedConfig[settingID] = default
		end

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

		mod.Values[sName] = default
		if sCallback then sCallback(default) end

		bg.MouseButton1Down:Connect(function()
			local moveConn, releaseConn
			moveConn = RunService.RenderStepped:Connect(function()
				local mouseP = UserInputService:GetMouseLocation().X
				local relative = math.clamp((mouseP - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
				local val = min + ((max - min) * relative)

				val = math.floor((val - min) / sStep + 0.5) * sStep + min
				val = math.clamp(val, min, max)

				fill.Size = UDim2.new(relative, 0, 1, 0)
				lbl.Text = string.format("      %s: %.2f", sName, val)

				mod.Values[sName] = val

				_G.SavedConfig[settingID] = val
				saveConfigToPC()

				if sCallback then sCallback(val) end
				if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(sName, val) end
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
		local settingID = uniquePrefix .. "_" .. txtName
		local defaultText = ""

		if _G.SavedConfig[settingID] ~= nil then
			defaultText = _G.SavedConfig[settingID]
		else
			_G.SavedConfig[settingID] = defaultText
		end

		mod.Values[txtName] = defaultText

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
		box.Text = defaultText
		box.TextScaled = true
		box.FontFace = Font.fromName(textFont)
		uiCorner(box, 4)

		if txtCallback and defaultText ~= "" then txtCallback(defaultText) end

		box.FocusLost:Connect(function()
			mod.Values[txtName] = box.Text

			_G.SavedConfig[settingID] = box.Text
			saveConfigToPC()

			if txtCallback then txtCallback(box.Text) end
			if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(txtName, box.Text) end
		end)
	end

	function mod:CreateDropdown(dName, options, default, dCallback, multiSelect)
		multiSelect = multiSelect or false
		local settingID = uniquePrefix .. "_" .. dName

		if _G.SavedConfig[settingID] ~= nil then
			default = _G.SavedConfig[settingID]
		else
			_G.SavedConfig[settingID] = default
		end

		if multiSelect then
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

		updateDropdownText() 
		if dCallback then dCallback(mod.Values[dName]) end

		for _, opt in ipairs(options) do
			local oBtn = Instance.new("TextButton", optFrame)
			oBtn.Size = UDim2.new(1, 0, 0, 24)
			oBtn.BackgroundTransparency = 1
			oBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
			oBtn.TextXAlignment = Enum.TextXAlignment.Left
			oBtn.TextSize = 18
			oBtn.FontFace = Font.fromName(textFont)

			local function updateVisual()
				if multiSelect then
					local isSelected = table.find(mod.Values[dName], opt)
					oBtn.Text = (isSelected and "         > [x] " or "         > [ ] ") .. tostring(opt)
					oBtn.TextColor3 = isSelected and Color3.new(1,1,1) or Color3.fromRGB(120, 120, 120)
				else
					oBtn.Text = "         > " .. tostring(opt)
				end
			end

			updateVisual() 

			oBtn.MouseEnter:Connect(function() 
				tween(oBtn, {TextColor3 = Color3.new(1,1,1)}) 
			end)

			oBtn.MouseLeave:Connect(function() 
				if multiSelect and table.find(mod.Values[dName], opt) then return end
				tween(oBtn, {TextColor3 = Color3.fromRGB(120, 120, 120)}) 
			end)

			oBtn.MouseButton1Click:Connect(function()
				if multiSelect then
					local foundIdx = table.find(mod.Values[dName], opt)
					if foundIdx then
						table.remove(mod.Values[dName], foundIdx)
					else
						table.insert(mod.Values[dName], opt)
					end

					updateVisual()
					updateDropdownText()

					_G.SavedConfig[settingID] = mod.Values[dName]
					saveConfigToPC()

					if dCallback then dCallback(mod.Values[dName]) end
					if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(dName, mod.Values[dName]) end
				else
					optFrame.Visible = false
					mod.Values[dName] = opt

					updateDropdownText()

					_G.SavedConfig[settingID] = opt
					saveConfigToPC()

					if dCallback then dCallback(opt) end
					if mod.Callbacks.OnValueChanged then mod.Callbacks.OnValueChanged(dName, opt) end
				end
			end)
		end
	end

	function mod:CreateKeybind(kName, defaultKey, kCallback)
		local settingID = uniquePrefix .. "_" .. kName

		if _G.SavedConfig[settingID] ~= nil then
			local savedEnumName = _G.SavedConfig[settingID]
			defaultKey = savedEnumName and Enum.KeyCode[savedEnumName] or nil
		else
			_G.SavedConfig[settingID] = defaultKey and defaultKey.Name or nil
		end

		local kBtn = Instance.new("TextButton", settingsCont)
		kBtn.Size = UDim2.new(1, 0, 0, 28)
		kBtn.BackgroundTransparency = 1
		local keyString = defaultKey and defaultKey.Name or "None"
		kBtn.Text = "      - " .. kName .. ": [" .. keyString .. "]"
		kBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		kBtn.TextXAlignment = Enum.TextXAlignment.Left
		kBtn.TextSize = 20
		kBtn.FontFace = Font.fromName(textFont)

		if kCallback then kCallback(defaultKey) end

		local waiting = false
		kBtn.MouseButton1Click:Connect(function()
			waiting = true
			_G.IsBindingKey = true
			kBtn.Text = "      - " .. kName .. ": [...]"
			kBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
		end)

		UserInputService.InputBegan:Connect(function(input, GPE)
			if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
				waiting = false
				local key = input.KeyCode
				if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Escape then key = nil end

				kBtn.Text = "      - " .. kName .. ": [" .. (key and key.Name or "None") .. "]"
				kBtn.TextColor3 = Color3.fromRGB(180, 180, 180)

				_G.SavedConfig[settingID] = key and key.Name or nil
				saveConfigToPC()

				if kCallback then kCallback(key) end
				task.defer(function() _G.IsBindingKey = false end)
			end
		end)
	end

	function mod:CreateColorPicker(cName, defaultColor, cCallback)
		local settingID = uniquePrefix .. "_" .. cName

		if _G.SavedConfig[settingID] ~= nil then
			local savedRGB = _G.SavedConfig[settingID]
			defaultColor = Color3.fromRGB(savedRGB.R / 255, savedRGB.G / 255, savedRGB.B / 255)
		else
			_G.SavedConfig[settingID] = {R = math.floor(defaultColor.R * 255), G = math.floor(defaultColor.G * 255), B = math.floor(defaultColor.B * 255)}
		end

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

		if cCallback then cCallback(defaultColor) end

		local function updateColor()
			local r = math.clamp(tonumber(rSlider.Text) or 255, 0, 255)
			local g = math.clamp(tonumber(gSlider.Text) or 255, 0, 255)
			local b = math.clamp(tonumber(bSlider.Text) or 255, 0, 255)
			rSlider.Text, gSlider.Text, bSlider.Text = tostring(r), tostring(g), tostring(b)

			_G.SavedConfig[settingID] = {R = r, G = g, B = b}
			saveConfigToPC()

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
injectElements(FW.SettingsOverlay, overlayScroll, "Overlay")

function FW:CreateCategory(name)
	local category = {}

	local catVisID = name .. "_CategoryVisibility"
	local catPosID = name .. "_CategoryPosition"

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

	local savedVisibility = false
	if _G.SavedConfig[catVisID] ~= nil then
		savedVisibility = _G.SavedConfig[catVisID]
	end

	local frame = Instance.new("Frame", mainScreenUI)
	frame.Name = name .. "Frame"
	frame.Size = UDim2.new(0.12, 0, 0.55, 0)

	if _G.SavedConfig[catPosID] ~= nil then
		local posData = _G.SavedConfig[catPosID]
		frame.Position = UDim2.new(posData.XS, posData.XO, posData.YS, posData.YO)
	else
		frame.Position = UDim2.new(0.25, 0, 0.1, 0)
	end

	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	frame.BorderSizePixel = 0
	frame.Visible = savedVisibility
	catBtn.TextColor3 = savedVisibility and Color3.fromRGB(78, 173, 73) or Color3.new(1, 1, 1)

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

		_G.SavedConfig[catVisID] = frame.Visible
		saveConfigToPC()
	end)

	frame:GetPropertyChangedSignal("Position"):Connect(function()
		local currentPos = frame.Position
		_G.SavedConfig[catPosID] = {
			XS = currentPos.X.Scale,
			XO = currentPos.X.Offset,
			YS = currentPos.Y.Scale,
			YO = currentPos.Y.Offset
		}
		saveConfigToPC()
	end)

	function category:CreateButton(btnName, callback, allowHotkey)
		local toggleID = name .. "_" .. btnName .. "_MainToggle"
		local hotkeyID = name .. "_" .. btnName .. "_Hotkey"

		local startingToggleState = false
		if _G.SavedConfig[toggleID] ~= nil then
			startingToggleState = _G.SavedConfig[toggleID]
		else
			_G.SavedConfig[toggleID] = startingToggleState
		end

		local mod = {
			Toggled = startingToggleState,
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
		btn.TextColor3 = startingToggleState and Color3.fromRGB(78, 173, 73) or Color3.new(1, 1, 1)
		btn.FontFace = Font.fromName(textFont)
		btn.TextSize = 22
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BorderSizePixel = 0
		btn.LayoutOrder = 1

		loops[string.lower(btnName)] = startingToggleState

		-- Central wrapper function to handle toggling flawlessly
		local function setToggleState(state)
			mod.Toggled = state
			btn.TextColor3 = state and Color3.fromRGB(78, 173, 73) or Color3.new(1, 1, 1)
			loops[string.lower(btnName)] = state

			_G.SavedConfig[toggleID] = state
			saveConfigToPC()

			if callback then callback(state) end
			if mod.Callbacks.OnToggle then mod.Callbacks.OnToggle(state) end
		end

		-- CRITICAL BUGFIX: Safely defers checking on startup. 
		-- Gives your code a split-second to assign loop callbacks below before triggering them.
		task.defer(function()
			if startingToggleState then
				if callback then callback(true) end
				if mod.Callbacks.OnToggle then mod.Callbacks.OnToggle(true) end
			end
		end)

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
			-- Load saved hotkey bind
			if _G.SavedConfig[hotkeyID] ~= nil then
				local savedKeyName = _G.SavedConfig[hotkeyID]
				currentBind = savedKeyName and Enum.KeyCode[savedKeyName] or nil
			end

			local bindLabel = Instance.new("TextButton", btn)
			bindLabel.Size = UDim2.new(0, 35, 1, 0)
			bindLabel.Position = UDim2.new(1, -70, 0, 0)
			bindLabel.BackgroundTransparency = 1
			bindLabel.Text = currentBind and ("[" .. currentBind.Name .. "]") or "[ - ]"
			bindLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
			bindLabel.FontFace = Font.fromName(textFont)
			bindLabel.TextSize = 16

			local isBinding = false
			bindLabel.MouseButton1Click:Connect(function()
				isBinding = true
				_G.IsBindingKey = true
				bindLabel.Text = "[...]"
			end)

			UserInputService.InputBegan:Connect(function(input, GPE)
				if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
					isBinding = false
					local key = input.KeyCode
					if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Escape then
						currentBind = nil
						_G.SavedConfig[hotkeyID] = nil
					else
						currentBind = key
						_G.SavedConfig[hotkeyID] = key.Name
					end
					bindLabel.Text = currentBind and ("[" .. currentBind.Name .. "]") or "[ - ]"
					saveConfigToPC()
					task.defer(function() _G.IsBindingKey = false end)

				elseif not GPE and not _G.IsBindingKey and currentBind and input.KeyCode == currentBind then
					setToggleState(not mod.Toggled)
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
			setToggleState(not mod.Toggled)
		end)

		arrow.MouseButton1Click:Connect(function()
			settingsCont.Visible = not settingsCont.Visible
			arrow.Rotation = settingsCont.Visible and 90 or 0
		end)

		injectElements(mod, settingsCont, name .. "_" .. btnName)

		return mod
	end

	return category
end

UserInputService.InputBegan:Connect(function(input, GPE)
	if input.KeyCode == Enum.KeyCode.RightShift and not GPE then
		mainScreenUI.Enabled = not mainScreenUI.Enabled
	end
end)

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
Killaura:CreateSlider("Hit Delay", 0.000001, 1, 0.1, nil, 0.01667)
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
AimAssist:CreateSlider("Range", 1, 150, 100, nil)
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

local AutoShoot = Combat:CreateButton("Auto Shoot", nil, true)
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
ChestStealer:CreateToggle("Chests", true, nil)

local AutoArmorSwitch = Utility:CreateButton("Auto Armor Switch", nil, true)
AutoArmorSwitch:CreateSlider("Range",1, 75, 30)

local fastDrop = Utility:CreateButton("Fast Drop", nil, true)

local AutoBalloon = Utility:CreateButton("Auto Balloon", nil, true)
AutoBalloon:CreateSlider("Void range", 1, 250, 100, nil)
AutoBalloon:CreateSlider("Amount of Balloons", 1, 3, 3, nil, 1)

local AutoPearl = Utility:CreateButton("Auto Pearl", nil, true)
AutoPearl:CreateSlider("Void range", 1, 250, 100, nil)
AutoPearl:CreateSlider("Shoot Duration", 0, 1, 0.25, nil)

local VoidDrop = Utility:CreateButton("Void Drop", nil, true)
VoidDrop:CreateSlider("Void range", 1, 250, 100, nil)


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
kaHighlight.FillColor = Color3.fromRGB(85, 0, 127)
kaHighlight.OutlineColor = Color3.fromRGB(0, 0, 0)
kaHighlight.FillTransparency = 0.5
kaHighlight.OutlineTransparency = 0
kaHighlight.Adornee = nil

pcall(function() kaHighlight.Parent = game:GetService("CoreGui") end)
if not kaHighlight.Parent then kaHighlight.Parent = workspace end
Killaura.Callbacks.OnToggle = function(state)
	loops["killaura"] = state

	if loops["killaura"] == false then
		currentKaTarget = nil
		kaHighlight.Adornee = nil 
		return 
	end

	task.spawn(function()
		while loops["killaura"] == true do
			local hitDelay = Killaura.Values["Hit Delay"]
			task.wait(hitDelay)

			if not (Killaura.Values["Target Players"] or Killaura.Values["Target NPCs/Dummies"]) then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end

			local char = Player.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end
			local rootPart = char.HumanoidRootPart

			local handItem = char:WaitForChild("HandInvItem", 1) 
			if not handItem then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end

			if Killaura.Values["Require Sword Equipped"] == true then
				if not t_find(swords, tostring(handItem.Value)) then
					currentKaTarget = nil
					kaHighlight.Adornee = nil
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
					if npc and npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.PrimaryPart then
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
				besttarget = playertarget or npcdummytarget
			elseif priority == "NPC/Dummy" then
				besttarget = npcdummytarget or playertarget
			elseif priority == "Nearest" then
				if playertarget and npcdummytarget then
					besttarget = (playerdistance <= npcdummydistance) and playertarget or npcdummytarget
				else
					besttarget = playertarget or npcdummytarget
				end
			end

			-- If no valid base target exists, clear everything completely
			if not besttarget then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end

			local HRP = rootPart 
			local targetHRP = besttarget.PrimaryPart
			local dir = (targetHRP.Position - HRP.Position).Unit

			-- WALL CHECK
			if Killaura.Values["Wall Check"] == true then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {HRP.Parent, besttarget}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true

				local wallRaycast = workspace:Raycast(HRP.Position, targetHRP.Position - HRP.Position, raycastParams)
				if wallRaycast then
					currentKaTarget = nil
					kaHighlight.Adornee = nil
					continue
				end
			end

			-- FOV ANGLE CHECK
			local angleMet = isInFOV(HRP, targetHRP, Killaura.Values["Angle Check"])
			if not angleMet then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end

			-- MANUAL SWING CHECK
			if Killaura.Values["Manual Swing"] == true and clicking == false then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end

			-- DISTANCE REACH CHECK
			local distance = (HRP.Position - targetHRP.Position).Magnitude
			local reach = tonumber(Killaura.Values["Reach"])
			if distance > reach then
				currentKaTarget = nil
				kaHighlight.Adornee = nil
				continue
			end

			-- Weapon Selection Setup
			local inventoryWeapon = nil
			local swordName = nil
			local oldItem = tostring(handItem.Value) or "hand"

			if Killaura.Values["Require Sword Equipped"] == true then
				inventoryWeapon = game.ReplicatedStorage:FindFirstChild("Inventories"):FindFirstChild(Player.Name):FindFirstChild(oldItem)
				if not inventoryWeapon then 
					currentKaTarget = nil
					kaHighlight.Adornee = nil
					continue 
				end
			else
				swordName = tostring(getBestEquippedSword(Player.Name))
				inventoryWeapon = game.ReplicatedStorage:FindFirstChild("Inventories"):FindFirstChild(Player.Name):FindFirstChild(swordName)
				if not inventoryWeapon then 
					currentKaTarget = nil
					kaHighlight.Adornee = nil
					continue 
				end
			end

			-- Everything passed! NOW it is safe to set the shared target variables
			currentKaTarget = besttarget
			if Killaura.Values["Highlight Target"] then
				kaHighlight.Adornee = besttarget
			end

			-- Build server validation arguments
			local spoofedTargetPosition = targetHRP.Position
			local maxNormalReach = 14 
			if distance > maxNormalReach then
				local dirToSelf = (HRP.Position - targetHRP.Position).Unit
				spoofedTargetPosition = targetHRP.Position + (dirToSelf * (distance - maxNormalReach + 0.5))
			end

			local kaArgs = {
				[1] = {
					["chargedAttack"] = { ["chargeRatio"] = 0 },
					["entityInstance"] = besttarget,
					["validate"] = {
						["selfPosition"] = { ["value"] = HRP.Position + dir * 5.5 },
						["targetPosition"] = { ["value"] = spoofedTargetPosition }
					},
					["weapon"] = inventoryWeapon
				}
			}

			if Killaura.Values["Require Sword Equipped"] == false and oldItem ~= swordName then
				local bestWeaponInst = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild(swordName)
				local args = {{ hand = bestWeaponInst }}
				game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(args))
			end

			-- Fire packet execution
			SwordHitRemote:FireServer(unpack(kaArgs))

			hitting = true
			lastHit = os.clock()

			if Killaura.Values["Face Target"] == true then
				faceTarget(rootPart.Parent, besttarget)
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

			-- FIX: Make sure Killaura is ACTUALLY toggled on before trying to sync!
			if AimAssist.Values["Sync with KA Target"] == true and loops["killaura"] == true then
				local kaTarget = currentKaTarget 

				if kaTarget and kaTarget:FindFirstChild("Humanoid") and kaTarget.Humanoid.Health > 0 then
					currentTarget = kaTarget
				else
					currentTarget = nil
				end
			else
				-- If Killaura is turned off OR Sync is turned off, fall back to normal Aim Assist
				if bestTarget and bestTarget:FindFirstChild("Humanoid") and bestTarget.Humanoid.Health > 0 then
					currentTarget = bestTarget
				else
					currentTarget = nil
				end
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

local function getCurrentAnimator()
	local character = Player.Character
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil end
	return humanoid:FindFirstChildOfClass("Animator")
end

local function playHoldAnimation(animationId)
	local animator = getCurrentAnimator()
	if not animator then return end
	if currentHoldTrack then currentHoldTrack:Stop() end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(animationId)
	local success, track = pcall(function() return animator:LoadAnimation(anim) end)
	if success and track then
		currentHoldTrack = track
		currentHoldTrack:Play()
	end
end

local function playShootAnimation(animationId)
	local animator = getCurrentAnimator()
	if not animator then return end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(animationId)
	local success, track = pcall(function() return animator:LoadAnimation(anim) end)
	if success and track then track:Play() end
end

local function stopHoldAnimation()
	if currentHoldTrack then
		currentHoldTrack:Stop()
		currentHoldTrack = nil
	end
end

local function spawnClientTracer(origin, targetPos, speed)
	local tracer = Instance.new("Part")
	tracer.Name = "ClientTracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.CanQuery = false
	tracer.Material = Enum.Material.Neon
	tracer.Color = Color3.fromRGB(255, 140, 0) 
	tracer.Size = Vector3.new(0.35, 0.35, 4.5) 
	tracer.CFrame = CFrame.lookAt(origin, targetPos)
	tracer.Parent = workspace.Terrain

	local distance = (targetPos - origin).Magnitude
	local safeSpeed = (speed and speed < 9999) and speed or 150
	local travelTime = distance / safeSpeed

	local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(tracer, tweenInfo, {
		CFrame = tracer.CFrame + (tracer.CFrame.LookVector * distance)
	})
	tween:Play()
	Debris:AddItem(tracer, travelTime)
end


local function isPathClear(origin, targetPos, ignoreList)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true 

	local direction = targetPos - origin
	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil 
end


local function hasLineOfSight(originPart, targetPart, playerCharacter)
	if not originPart or not targetPart then return false end
	local origin = originPart.Position
	local targetPos = targetPart.Position
	local direction = targetPos - origin

	local raycastOrigin = origin + (direction.Unit * 2.5)
	local raycastDirection = targetPos - raycastOrigin

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {playerCharacter, targetPart.Parent}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true 

	local raycastResult = workspace:Raycast(raycastOrigin, raycastDirection, raycastParams)
	return raycastResult == nil
end


local function fireProjectile(projectileName, HRP, targetPart, itemRequired, target)
	local origin = HRP.Position
	if not targetPart or not Player.Character then return end

	local targetHumanoid = target:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then return end

	local handItemName = tostring(itemRequired)
	local speed = WeaponSpeeds[handItemName] or 150
	local initialDistance = (targetPart.Position - origin).Magnitude

	if initialDistance < 8 then
		origin = origin + (HRP.CFrame.LookVector * 1.5)
	end

	local flightTime = 0
	local predictedPos = targetPart.Position

	if speed < 9999 then
		local velocity = targetPart.AssemblyLinearVelocity or Vector3.zero
		if velocity.Magnitude > 75 then velocity = velocity.Unit * 75 end

		for pass = 1, 3 do
			local currentDist = (predictedPos - origin).Magnitude
			local pingBuffer = 0.03 + (currentDist / 750) 
			flightTime = (currentDist / speed) + pingBuffer

			flightTime = math.min(flightTime, 1.5) 

			predictedPos = targetPart.Position + (velocity * flightTime)
		end

		if not isPathClear(origin, predictedPos, {Player.Character, target}) then
			local alternatePos = predictedPos + Vector3.new(0, 1.5, 0)
			if isPathClear(origin, alternatePos, {Player.Character, target}) then
				predictedPos = alternatePos
			else
				return false 
			end
		end
	else
		flightTime = initialDistance / 150
	end

	if targetPart.Name == "Head" then
		predictedPos = predictedPos + Vector3.new(0, 1.2, 0) 
	end

	local directionVector = predictedPos - origin
	local direction = directionVector.Magnitude > 0 and directionVector.Unit or HRP.CFrame.LookVector
	local velocitySpeed = (speed >= 9999) and 150 or speed
	local thirdPos = direction * velocitySpeed

	local ID = generateId()
	local args = {
		inventoriesFolder:FindFirstChild(Player.Name):FindFirstChild(tostring(itemRequired or projectileName)),
		tostring(projectileName),
		tostring(projectileName),
		vector.create(origin.X, origin.Y, origin.Z),
		vector.create(HRP.Position.X, HRP.Position.Y, HRP.Position.Z),
		vector.create(thirdPos.X, thirdPos.Y, thirdPos.Z), 
		generateId(),
		{shotId = ID, drawDurationSec = AutoShoot.Values["Shoot duration"]},
		workspace:GetServerTimeNow()
	}

	spawnClientTracer(origin, predictedPos, speed)

	task.spawn(function()
		stopHoldAnimation()
		local handItemLower = string.lower(handItemName)
		if string.find(handItemLower, "crossbow") then playShootAnimation(CB_SHOOT_ANIMATION_ID)
		elseif string.find(handItemLower, "bow") or string.find(handItemLower, "headhunter") then playShootAnimation(BOW_SHOOT_ANIMATION_ID)
		elseif string.find(handItemLower, "frost_staff") or string.find(handItemLower, "spellbook") then playShootAnimation() end
	end)

	fireProjectileEvent:InvokeServer(unpack(args))


	local hitArgs = {tostring(ID), workspace:WaitForChild(target.Name)}

	task.spawn(function()
		local startTime = os.clock()
		local timeout = flightTime + 0.3
		local hitRegistered = false

		while os.clock() - startTime < timeout do
			task.wait() 

			if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then break end

			local elapsedTime = os.clock() - startTime
			local currentArrowPos = origin + (direction * (velocitySpeed * elapsedTime))
			local actualTargetPos = targetPart.Position

			if (currentArrowPos - actualTargetPos).Magnitude <= 5.5 then
				game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileHit"):FireServer(unpack(hitArgs))
				hitRegistered = true
				break
			end
		end

		if not hitRegistered and target and target.Parent then
			game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileHit"):FireServer(unpack(hitArgs))
		end
	end)

	return true 
end

RunService.Heartbeat:Connect(function()
	if not isSystemEnabled or not Player.Character then return end
	local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Player.Character:FindFirstChild("Humanoid")
	if not HRP or not Humanoid then return end

	local currentVel = HRP.AssemblyLinearVelocity
	local deltaVel = currentVel - lastVelocity

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		deltaVel = Vector3.new(deltaVel.X, 0, deltaVel.Z)
	end

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

task.spawn(function()
	while true do
		task.wait(0.01) 

		if not autoShoot then continue end
		if not AutoShoot.Values["Aim at Head"] and not AutoShoot.Values["Aim at Torso"] then continue end
		if #AutoShoot.Values["Projectiles"] == 0 then continue end
		if not Player.Character then continue end

		local character = Player.Character 
		local HRP = character:FindFirstChild("HumanoidRootPart")
		local animator = getCurrentAnimator() 

		if inventoriesFolder and animator then
			local playerFolder = inventoriesFolder:FindFirstChild(Player.Name)
			local Handinvitem = character:FindFirstChild("HandInvItem")

			if not playerFolder or not Handinvitem or Handinvitem.Value == nil then continue end

			local handItemName = tostring(Handinvitem.Value.Name)
			if firingLocks[handItemName] then continue end 

			local item = playerFolder:FindFirstChild(handItemName)
			if not item then continue end

			local plrTarget, plrDistance, npcTarget, npcDistance, bestTarget = nil, nil, nil, nil, nil

			if AutoShoot.Values["Target Players"] then plrTarget, plrDistance = findClosestPlr(AutoShoot.Values["Range"], HRP) end
			if AutoShoot.Values["Target NPCs/Dummies"] then npcTarget, npcDistance = findClosestNPC(AutoShoot.Values["Range"], HRP) end

			if plrTarget and npcTarget then bestTarget = (plrDistance >= npcDistance) and plrTarget or npcTarget
			elseif plrTarget then bestTarget = plrTarget
			elseif npcTarget then bestTarget = npcTarget
			else continue end

			local targetHumanoid = bestTarget:FindFirstChild("Humanoid")
			if not targetHumanoid or targetHumanoid.Health <= 0 then stopHoldAnimation(); continue end

			local targetPlayer = Players:GetPlayerFromCharacter(bestTarget)
			if targetPlayer and Player.Team and targetPlayer.Team == Player.Team then stopHoldAnimation(); continue end

			local handItemLower = string.lower(handItemName)
			local projectileName = nil

			if string.find(handItemLower, "bow") or string.find(handItemLower, "crossbow") or string.find(handItemLower, "headhunter") then
				if playerFolder:FindFirstChild("arrow") then projectileName = "arrow" end
			elseif handItemName == "mage_spellbook" then projectileName = "mage_spell_base"
			elseif handItemName == "whim_spellbook" then projectileName = "whim_mage_book" 
			elseif handItemName == "frost_staff_1" then projectileName = "frosty_snowball_1"
			elseif handItemName == "frost_staff_2" then projectileName = "frosty_snowball_2"
			elseif handItemName == "frost_staff_3" then projectileName = "frosty_snowball_3"
			elseif table.find(AutoShoot.Values["Projectiles"], handItemName) then
				projectileName = handItemName
			end

			if projectileName == nil then continue end

			local currentTime = os.clock()
			local stats = WeaponStats[handItemName] or WeaponStats[projectileName] or { Charge = 0, Cooldown = 0.3 }
			local actualCharge, actualCooldown = stats.Charge, stats.Cooldown

			local guiDelay = AutoShoot.Values["Shoot duration"] or 0
			if guiDelay > (actualCharge + actualCooldown) then actualCooldown = guiDelay - actualCharge end
			local totalCycleTime = actualCharge + actualCooldown

			if currentTime - (lastShotTimes[handItemName] or 0) < totalCycleTime then continue end

			local chanceOfHeadShot = AutoShoot.Values["Chance of headshot"] or 100
			local chanceOfShot = AutoShoot.Values["Chance of shot"] or 100
			local targetPart = nil

			if AutoShoot.Values["Aim at Head"] and AutoShoot.Values["Aim at Torso"] then
				if chanceOfHeadShot >= math.random(1, 100) then targetPart = bestTarget:FindFirstChild("Head")
				elseif chanceOfShot >= math.random(1, 100) then targetPart = bestTarget:FindFirstChild("UpperTorso") end
			elseif AutoShoot.Values["Aim at Torso"] then
				if chanceOfShot >= math.random(1, 100) then targetPart = bestTarget:FindFirstChild("UpperTorso") end
			elseif AutoShoot.Values["Aim at Head"] then
				if chanceOfHeadShot >= math.random(1, 100) then targetPart = bestTarget:FindFirstChild("Head") end
			end

			if targetPart then
				local currentDistance = (targetPart.Position - HRP.Position).Magnitude
				if currentDistance > 6 and not isPathClear(HRP.Position, targetPart.Position, {character, bestTarget}) then
					stopHoldAnimation()
					continue 
				end

				lastShotTimes[handItemName] = os.clock()
				firingLocks[handItemName] = true 

				task.spawn(function()
					if actualCharge > 0 then
						if string.find(handItemLower, "crossbow") then playHoldAnimation(CB_HOLD_ANIMATION_ID)
						elseif string.find(handItemLower, "bow") or string.find(handItemLower, "headhunter") then playHoldAnimation(BOW_HOLD_ANIMATION_ID)
						elseif string.find(handItemLower, "frost_staff") or string.find(handItemLower, "spellbook") then playHoldAnimation() end
						task.wait(actualCharge) 
					end

					if Handinvitem and Handinvitem.Value and tostring(Handinvitem.Value.Name) == handItemName and getCurrentAnimator() then
						local shotFired = fireProjectile(projectileName, HRP, targetPart, handItemName, bestTarget)
						if not shotFired then lastShotTimes[handItemName] = 0 end 
					else
						stopHoldAnimation()
					end

					firingLocks[handItemName] = nil 
				end)
			else
				stopHoldAnimation()
			end
		end
	end
end)

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
	
	for _, npc in pairs(workspace:GetChildren()) do
		if npc and npc:FindFirstChild("Humanoid", true) then
			if Players:FindFirstChild(npc.Name) then continue end
				local highlight = npc:FindFirstChild("_DamageHighlight_")

				if highlight and highlight.Enabled then
					highlight.Enabled = false
			end
		end
	end
end)


local function findNearbyChests(radius)
	if loops["chest stealer"] ~= true then return {} end
	local chests = {}

	local character = Player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return chests end
	local playerPos = character.HumanoidRootPart.Position

	for i, chest in pairs(workspace:GetDescendants()) do
		if chest and chest:IsA("Part") and chest.Name == "chest" then
			local distance = (playerPos - chest.Position).Magnitude

			if distance <= radius then
				table.insert(chests, chest)
			end
		end
	end

	return chests
end

local function findNearbyCrates(radius)
	if loops["chest stealer"] ~= true then return {} end
	local crates = {}

	local character = Player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return crates end
	local playerPos = character.HumanoidRootPart.Position

	for i, crate in pairs(workspace:GetDescendants()) do
		if crate and crate:IsA("Part") and crate.Name == "team_crate" then
			local distance = (playerPos - crate.Position).Magnitude

			if distance <= radius then
				table.insert(crates, crate)
			end
		end
	end

	return crates
end

ChestStealer.Callbacks.OnToggle = function(state)
	loops["chest stealer"] = state
end

task.spawn(function()
	while true do
		task.wait(0.1) 

		if loops["chest stealer"] then
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				local character = Player.Character
				local Humanoid = character.Humanoid

				if Humanoid.Health > 0 then
					local rangeValue = tonumber(ChestStealer.Values["Range"]) or 20

					if ChestStealer.Values["Crates"] then
						local crates = findNearbyCrates(rangeValue)
						for i, crate in pairs(crates) do
							local folder = crate:FindFirstChild("ChestFolderValue")
							local crateInventory = folder and folder.Value

							if crateInventory then
								for i, item in pairs(crateInventory:GetChildren()) do
									if item.Name ~= "ChestOwner" then
										local args = {
											crateInventory,
											item
										}

										game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("Inventory/ChestGetItem"):InvokeServer(unpack(args))
									end
								end
							end
						end
					end

					if ChestStealer.Values["Chests"] then
						local chests = findNearbyChests(rangeValue)
						for i, chest in pairs(chests) do
							local folder = chest:FindFirstChild("ChestFolderValue")
							local chestInventory = folder and folder.Value

							if chestInventory then
								for i, item in pairs(chestInventory:GetChildren()) do
									if item.Name ~= "ChestOwner" then
										local args = {
											chestInventory,
											item
										}

										game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("Inventory/ChestGetItem"):InvokeServer(unpack(args))
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

local function inflateBalloons()
	local char = Player.Character
	if not char then return end

	local inflated = char:GetAttribute("InflatedBalloons") or 0
	local max = tonumber(AutoBalloon.Values["Amount of Balloons"]) or 0

	local needed = max - inflated
	if needed <= 0 then return end

	for i = 1, needed do
		balloonEvent:FireServer()
		task.wait(0.01)
	end
end

AutoBalloon.Callbacks.OnToggle = function(state)
	loops["auto balloon"] = state

	if loops["auto balloon"] then
		task.spawn(function()

			while loops["auto balloon"] do
				task.wait(0.01)
				local char = Player.Character
				if not char then return end
				local inflated = char:GetAttribute("InflatedBalloons") or 0

				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChild("Humanoid")

				if tonumber(inflated) >= tonumber(AutoBalloon.Values["Amount of Balloons"]) then
					task.wait(0.5)
					continue
				end

				if hrp and hum and hum.Health > 0 then
					local char = Player.Character
					local HRP = char.HumanoidRootPart

					local voidRange = tonumber(AutoBalloon.Values["Void range"])
					local threshold = -voidRange

					if HRP.Position.Y <= threshold then
						if char:FindFirstChild("HandInvItem") then
							local item = char.HandInvItem.Value
							local itemName = item.Name

							if itemName ~= "balloon" then
								if inventoriesFolder:FindFirstChild(Player.Name):FindFirstChild("balloon") then
									local oldItem = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild(tostring(char.HandInvItem.Value.Name))
									local balloonItem = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild("balloon")
									local args = {{ hand = balloonItem }}
									game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(args))

									inflateBalloons()

									task.wait(0.01)

									print(oldItem)

									local Oldargs = {{ hand = oldItem }}
									game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(Oldargs))
								end
							else
								inflateBalloons()
							end
						end
					end
				end
			end
		end)
	end
end

local function isValidGround(part)
	if not part:IsA("BasePart") then return false end
	if part.CanCollide == false then return false end

	-- reject walls (tall vertical surfaces)
	local upDot = part.CFrame.UpVector:Dot(Vector3.yAxis)

	-- 0.7+ means mostly flat surface
	if upDot < 0.7 then
		return false
	end

	return true
end

local function getNearestGroundPoint(pos, ignoreModel)
	local bestPoint = nil
	local bestDist = math.huge

	for _, part in ipairs(workspace:GetDescendants()) do
		if isValidGround(part) and not (ignoreModel and part:IsDescendantOf(ignoreModel)) then

			local topPoint = part.Position + Vector3.new(0, part.Size.Y / 2, 0)
			local dist = (topPoint - pos).Magnitude

			if dist < bestDist then
				bestDist = dist
				bestPoint = topPoint
			end
		end
	end

	return bestPoint
end

local function getVelocity(origin, target, speed)
	local direction = target - origin
	local flat = Vector3.new(direction.X, 0, direction.Z)

	local dist = flat.Magnitude
	if dist == 0 then
		return Vector3.zero
	end

	local time = dist / speed
	local gravity = workspace.Gravity

	local y = direction.Y + 0.5 * gravity * time * time

	local horiz = flat.Unit * speed
	local vert = Vector3.new(0, y / time, 0)

	return horiz + vert
end

local function thirdPOS(HRP)
	local origin = HRP.Position + Vector3.new(0, 2, 0)

	local target = getNearestGroundPoint(origin, HRP.Parent)
	if not target then return end

	local speed = 110

	local velocity = getVelocity(origin, target, speed)

	return vector.create(velocity.X, velocity.Y, velocity.Z)
end

local function autoPearl()
	local randomID = generateId()
	local shotID = generateId()
	if not Character then return end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local orgin = HRP.Position + Vector3.new(1,1,1)	

	local finalVelocity = thirdPOS(HRP)


	local fireArgs = {    
		[1] = inventoriesFolder[Player.Name].telepearl,
		[2] = "telepearl",
		[3] = "telepearl",
		[4] = vector.create(orgin.X, orgin.Y, orgin.Z),
		[5] = vector.create(HRP.Position.X, HRP.Position.Y, HRP.Position.Z),

		[6] = finalVelocity,

		[7] = tostring(randomID),
		[8] = {
			["drawDurationSec"] = AutoPearl.Values["Shoot Duration"],
			["shotId"] = tostring(shotID),
		},
		[9] = workspace:GetServerTimeNow()
	}

	game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileFire:InvokeServer(unpack(fireArgs))

	local hitArgs = {
		[1] = tostring(randomID)
	}

	game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileHit:FireServer(unpack(hitArgs))
end

AutoPearl.Callbacks.OnToggle = function(state)
	loops["auto pearl"] = state

	if loops["auto pearl"] then
		task.spawn(function()

			while loops["auto pearl"] do
				task.wait(0.01)
				local char = Player.Character

				-- FIX 1: Use 'continue' so it waits for you to respawn instead of killing the thread
				if not char then continue end

				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChild("Humanoid")


				if hrp and hum and hum.Health > 0 then

					-- FIX 2: Check for active pearls without returning out of the whole function
					local hasActivePearl = false
					for i, part in pairs(game.Workspace:GetChildren()) do
						if part.Name == "telepearl" and part:GetAttribute("ProjectileShooter") == Player.UserId then
							hasActivePearl = true
							break -- Stops checking the workspace, we already found one
						end
					end

					-- Skip this loop iteration if a pearl is already flying
					if hasActivePearl then continue end


					local voidRange = tonumber(AutoBalloon.Values["Void range"])
					local threshold = -voidRange

					if hrp.Position.Y <= threshold then
						if char:FindFirstChild("HandInvItem") then
							local handInvItem = char:FindFirstChild("HandInvItem")

							if handInvItem and handInvItem.Value then
								local item = handInvItem.Value
								local itemName = item.Name

								if itemName ~= "telepearl" then
									if inventoriesFolder:FindFirstChild(Player.Name):FindFirstChild("telepearl") then
										local oldItem = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild(tostring(char.HandInvItem.Value.Name))
										local telepearlItem = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(Player.Name):WaitForChild("telepearl")
										local args = {{ hand = telepearlItem }}

										game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(args))

										autoPearl()

										task.wait(0.01)

										local Oldargs = {{ hand = oldItem }}
										game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem"):InvokeServer(unpack(Oldargs))
									end
								else
									autoPearl()
								end
							end
						end
					end
				end
			end
		end)
	end
end

VoidDrop.Callbacks.OnToggle = function(state)
	loops["void drop"] = state
end

while loops["void drop"] do
	task.wait(0.05)
	
	local char = Player.Character

	if not char then continue end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")


	if hrp and hum and hum.Health > 0 then
		local voidRange = tonumber(VoidDrop.Values["Void range"])
		local threshold = -voidRange

		if hrp.Position.Y <= threshold then
			
			
		end
	end
end

