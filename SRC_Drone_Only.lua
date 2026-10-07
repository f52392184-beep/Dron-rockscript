local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
if _G.RockHubUnload then
	pcall(_G.RockHubUnload)
end
local toggleKey = Enum.KeyCode.RightShift
local blurSize = 16
local keyListener
local bgColor = Color3.fromRGB(14, 14, 14)
local panelColor = Color3.fromRGB(20, 20, 20)
local elemColor = Color3.fromRGB(27, 27, 27)
local hoverColor = Color3.fromRGB(36, 36, 36)
local strokeColor = Color3.fromRGB(42, 42, 42)
local textColor = Color3.fromRGB(230, 230, 230)
local dimColor = Color3.fromRGB(120, 120, 120)
local mutedColor = Color3.fromRGB(85, 85, 85)
local accentColor = Color3.fromRGB(255, 255, 255)
local connections = {}
local lobbyBrand

local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

local function create(className, props)
	local inst = Instance.new(className)
	local parent = props.Parent
	props.Parent = nil
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function addCorner(inst, r)
	create("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = inst })
end

local function makeRound(inst)
	create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = inst })
end

local function addStroke(inst, color)
	return create("UIStroke", {
		Color = color or strokeColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst,
	})
end

local function tween(inst, t, props, dir, style)
	local tw = TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local gradients = {}

local function addGradient(target)
	local gradient = create("UIGradient", { Parent = target })
	table.insert(gradients, gradient)
	return gradient
end

local function shimmerSeq(t)
	local kps = {}
	for i = 0, 8 do
		local x = i / 8
		local v = 0.5 + 0.5 * math.sin((x - t) * math.pi * 2)
		local c = math.floor(80 + v * 175)
		kps[#kps + 1] = ColorSequenceKeypoint.new(x, Color3.fromRGB(c, c, c))
	end
	return ColorSequence.new(kps)
end

local function line(parent, x1, y1, x2, y2, th, color)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	local f = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Size = UDim2.fromOffset(len + th * 0.6, th),
		Rotation = math.deg(math.atan2(dy, dx)),
		BackgroundColor3 = color or dimColor,
		BorderSizePixel = 0,
		Parent = parent,
	})
	makeRound(f)
	return f
end

local function dot(parent, x, y, size)
	local f = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = dimColor,
		BorderSizePixel = 0,
		Parent = parent,
	})
	makeRound(f)
	return f
end

local function createIcon(kind, parent)
	local holder = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = parent,
	})
	local scale = create("UIScale", { Parent = holder })
	local parts = {}

	local function add(inst, prop)
		table.insert(parts, { inst, prop })
	end

	if kind == "move" then
		add(dot(holder, 11.5, 2.8, 4.6), "BackgroundColor3")
		local lines = {
			{ 10, 6, 8, 11 },
			{ 9.6, 7, 12.6, 9 },
			{ 12.6, 9, 15, 7.4 },
			{ 9.6, 7, 6.6, 8.6 },
			{ 6.6, 8.6, 4.6, 7 },
			{ 8, 11, 11, 13.4 },
			{ 11, 13.4, 10.6, 17 },
			{ 8, 11, 6, 14 },
			{ 6, 14, 2.6, 15 },
		}
		for _, s in ipairs(lines) do
			add(line(holder, s[1], s[2], s[3], s[4], 2), "BackgroundColor3")
		end
	elseif kind == "eye" then
		local eye = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(16, 10),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		makeRound(eye)
		add(create("UIStroke", { Color = dimColor, Thickness = 1.6, Parent = eye }), "Color")
		add(dot(holder, 9, 9, 5), "BackgroundColor3")
	elseif kind == "wing" then
		add(dot(holder, 3, 15, 3.4), "BackgroundColor3")
		local lines = { { 3, 15, 9, 3 }, { 9, 3, 16.5, 5 }, { 7.4, 6.4, 15.5, 9.6 }, { 5.6, 9.8, 13, 14.2 } }
		for _, s in ipairs(lines) do
			add(line(holder, s[1], s[2], s[3], s[4], 1.8), "BackgroundColor3")
		end
	elseif kind == "sliders" then
		local rows = { { 4, 6 }, { 9, 12 }, { 14, 8 } }
		for _, r in ipairs(rows) do
			add(line(holder, 2, r[1], 16, r[1], 1.6), "BackgroundColor3")
			add(dot(holder, r[2], r[1], 5), "BackgroundColor3")
		end
	elseif kind == "star" then
		add(line(holder, 9, 1.5, 9, 16.5, 2), "BackgroundColor3")
		add(line(holder, 1.5, 9, 16.5, 9, 2), "BackgroundColor3")
		add(line(holder, 5, 5, 13, 13, 1.4), "BackgroundColor3")
		add(line(holder, 13, 5, 5, 13, 1.4), "BackgroundColor3")
		add(dot(holder, 9, 9, 5), "BackgroundColor3")
	elseif kind == "gear" then
		local ring = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		makeRound(ring)
		add(create("UIStroke", { Color = dimColor, Thickness = 2.6, Parent = ring }), "Color")
		for i = 0, 7 do
			local a = math.rad(i * 45)
			add(line(holder, 9 + math.cos(a) * 5.5, 9 + math.sin(a) * 5.5, 9 + math.cos(a) * 8, 9 + math.sin(a) * 8, 3), "BackgroundColor3")
		end
	elseif kind == "target" then
		local ring = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(12, 12),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		makeRound(ring)
		add(create("UIStroke", { Color = dimColor, Thickness = 1.6, Parent = ring }), "Color")
		add(line(holder, 9, 0.5, 9, 4.5, 1.6), "BackgroundColor3")
		add(line(holder, 9, 13.5, 9, 17.5, 1.6), "BackgroundColor3")
		add(line(holder, 0.5, 9, 4.5, 9, 1.6), "BackgroundColor3")
		add(line(holder, 13.5, 9, 17.5, 9, 1.6), "BackgroundColor3")
		add(dot(holder, 9, 9, 3), "BackgroundColor3")
	elseif kind == "cart" then
		local lines = {
			{ 1, 3, 4, 3 },
			{ 4, 3, 6.2, 11.5 },
			{ 4.8, 5.5, 16.5, 5.5 },
			{ 16.5, 5.5, 14.8, 11.5 },
			{ 6.2, 11.5, 14.8, 11.5 },
			{ 5.5, 8.5, 15.8, 8.5 },
		}
		for _, s in ipairs(lines) do
			add(line(holder, s[1], s[2], s[3], s[4], 1.7), "BackgroundColor3")
		end
		add(dot(holder, 7.2, 15, 3.2), "BackgroundColor3")
		add(dot(holder, 13.8, 15, 3.2), "BackgroundColor3")
	elseif kind == "pin" then
		local ring = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(9, 7),
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		makeRound(ring)
		add(create("UIStroke", { Color = dimColor, Thickness = 1.8, Parent = ring }), "Color")
		add(line(holder, 4.8, 9.6, 9, 16.5, 1.8), "BackgroundColor3")
		add(line(holder, 13.2, 9.6, 9, 16.5, 1.8), "BackgroundColor3")
		add(dot(holder, 9, 7, 3), "BackgroundColor3")
	elseif kind == "smile" then
		add(dot(holder, 5.5, 6, 3.4), "BackgroundColor3")
		add(dot(holder, 12.5, 6, 3.4), "BackgroundColor3")
		add(line(holder, 4, 11, 6.8, 13.8, 2), "BackgroundColor3")
		add(line(holder, 6.8, 13.8, 11.2, 13.8, 2), "BackgroundColor3")
		add(line(holder, 11.2, 13.8, 14, 11, 2), "BackgroundColor3")
	elseif kind == "bolt" then
		add(line(holder, 12, 1.5, 5.5, 10, 2.4), "BackgroundColor3")
		add(line(holder, 5.5, 10, 12.5, 8, 2.4), "BackgroundColor3")
		add(line(holder, 12.5, 8, 6, 16.5, 2.4), "BackgroundColor3")
	elseif kind == "globe" then
		local ring = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		makeRound(ring)
		add(create("UIStroke", { Color = dimColor, Thickness = 1.5, Parent = ring }), "Color")
		local meridian = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(7, 16),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		makeRound(meridian)
		add(create("UIStroke", { Color = dimColor, Thickness = 1.3, Parent = meridian }), "Color")
		add(line(holder, 1.5, 9, 16.5, 9, 1.3), "BackgroundColor3")
		add(line(holder, 3, 5, 15, 5, 1.1), "BackgroundColor3")
		add(line(holder, 3, 13, 15, 13, 1.1), "BackgroundColor3")
	elseif kind == "drone" then
		for _, c in ipairs({ { 4, 4 }, { 14, 4 }, { 4, 14 }, { 14, 14 } }) do
			add(line(holder, 9, 9, c[1], c[2], 1.8), "BackgroundColor3")
			local r = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(c[1], c[2]),
				Size = UDim2.fromOffset(6, 6),
				BackgroundTransparency = 1,
				Parent = holder,
			})
			makeRound(r)
			add(create("UIStroke", { Color = dimColor, Thickness = 1.4, Parent = r }), "Color")
		end
		add(dot(holder, 9, 9, 5), "BackgroundColor3")
	elseif kind == "grid" then
		for _, p in ipairs({ { 4.5, 4.5 }, { 13.5, 4.5 }, { 4.5, 13.5 }, { 13.5, 13.5 } }) do
			local sq = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(p[1], p[2]),
				Size = UDim2.fromOffset(6.5, 6.5),
				BackgroundColor3 = dimColor,
				BorderSizePixel = 0,
				Parent = holder,
			})
			addCorner(sq, 2)
			add(sq, "BackgroundColor3")
		end
	end
	local icon = {}

	icon.color = function(c, t)
		for _, p in ipairs(parts) do
			tween(p[1], t or 0.2, { [p[2]] = c })
		end
	end

	icon.pop = function()
		scale.Scale = 0.7
		tween(scale, 0.35, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
	end

	return icon
end

local gui = create("ScreenGui", {
	Name = "RockHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
})
local parented = false
if gethui then
	parented = pcall(function()
		gui.Parent = gethui()
	end)
end
if not parented then
	parented = pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end)
end
if not parented then
	gui.Parent = player:WaitForChild("PlayerGui")
end
pcall(function()
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	gui.ClipToDeviceSafeArea = true
end)

local blur = create("BlurEffect", { Name = "RockHubBlur", Size = 0, Parent = Lighting })
local main = create("Frame", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(680, 470),
	BackgroundColor3 = bgColor,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 2,
	Parent = gui,
})
addCorner(main, 10)
local mainStroke = create("UIStroke", { Thickness = 1, Color = accentColor, Transparency = 0.3, Parent = main })
addGradient(mainStroke)
local mainScale = create("UIScale", { Scale = 0, Parent = main })
local menuOpen = false
local responsiveScale = 1
local viewportConnection
local updateWatermarkResponsive

local function updateResponsiveScale()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local viewport = cam.ViewportSize
	local topLeft, bottomRight = Vector2.zero, Vector2.zero
	pcall(function()
		topLeft, bottomRight = GuiService:GetGuiInset()
	end)
	local margin = UserInputService.TouchEnabled and 16 or 24
	local availableWidth = math.max(1, viewport.X - topLeft.X - bottomRight.X - margin)
	local availableHeight = math.max(1, viewport.Y - topLeft.Y - bottomRight.Y - margin)
	responsiveScale = math.clamp(math.min(availableWidth / 680, availableHeight / 470), 0.35, 1)
	if UserInputService.TouchEnabled then
		main.Position = UDim2.fromScale(0.5, 0.5)
	end
	if menuOpen then
		mainScale.Scale = responsiveScale
	end
	if updateWatermarkResponsive then
		updateWatermarkResponsive()
	end
end

local function bindViewport()
	if viewportConnection then
		viewportConnection:Disconnect()
	end
	local cam = workspace.CurrentCamera
	if cam then
		viewportConnection = connect(cam:GetPropertyChangedSignal("ViewportSize"), updateResponsiveScale)
	end
	updateResponsiveScale()
end

connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bindViewport)
connect(gui:GetPropertyChangedSignal("AbsoluteSize"), updateResponsiveScale)
bindViewport()
local topBar = create("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = main })
local logo = create("TextLabel", {
	Text = "ROCK dimas",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = accentColor,
	TextXAlignment = Enum.TextXAlignment.Left,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 0),
	Size = UDim2.new(0, 205, 1, 0),
	Parent = topBar,
})
addGradient(logo)
create("TextLabel", {
	Text = "v2.0",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = dimColor,
	TextXAlignment = Enum.TextXAlignment.Left,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(219, 1),
	Size = UDim2.new(0, 40, 1, 0),
	Parent = topBar,
})
local closeBtn = create("TextButton", {
	Text = "x",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = dimColor,
	BackgroundColor3 = elemColor,
	BackgroundTransparency = 1,
	AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -8, 0.5, 0),
	Size = UDim2.fromOffset(24, 24),
	Parent = topBar,
})
addCorner(closeBtn, 6)
connect(closeBtn.MouseEnter, function()
	tween(closeBtn, 0.15, { TextColor3 = accentColor, BackgroundTransparency = 0 })
end)
connect(closeBtn.MouseLeave, function()
	tween(closeBtn, 0.15, { TextColor3 = dimColor, BackgroundTransparency = 1 })
end)
local headerLine = create("Frame", {
	Position = UDim2.fromOffset(0, 38),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = accentColor,
	BorderSizePixel = 0,
	Parent = main,
})
addGradient(headerLine)
local tabY = 10
local layoutOrder = 0
local sidebar = create("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 39),
	Size = UDim2.new(0, 170, 1, -39),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	ScrollingEnabled = true,
	Active = true,
	CanvasSize = UDim2.new(),
	Parent = main,
})
local tabSelector = create("Frame", {
	Position = UDim2.fromOffset(8, 10),
	Size = UDim2.new(1, -16, 0, 32),
	BackgroundColor3 = accentColor,
	BorderSizePixel = 0,
	ZIndex = 1,
	Parent = sidebar,
})
addCorner(tabSelector, 8)
create("UIGradient", {
	Color = ColorSequence.new(Color3.fromRGB(105, 105, 105), Color3.fromRGB(62, 62, 62)),
	Parent = tabSelector,
})
local selectorStroke = create("UIStroke", {
	Color = accentColor,
	Thickness = 1,
	Transparency = 0.75,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	Parent = tabSelector,
})
local sweepGradient = create("UIGradient", { Parent = selectorStroke })
local solidSeq = NumberSequence.new(0)
local sweepSeq = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(0.85, 0.2),
	NumberSequenceKeypoint.new(1, 0),
})
local sweepId = 0
local sweepTween

local function playSweep()
	sweepId += 1
	local id = sweepId
	if sweepTween then
		sweepTween:Cancel()
	end
	sweepGradient.Transparency = sweepSeq
	sweepGradient.Rotation = -90
	sweepTween = tween(sweepGradient, 0.5, { Rotation = 270 }, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine)
	sweepTween.Completed:Connect(function(state)
		if id ~= sweepId or state ~= Enum.PlaybackState.Completed then
			return
		end
		sweepGradient.Transparency = solidSeq
		selectorStroke.Transparency = 0.4
		tween(selectorStroke, 0.4, { Transparency = 0.75 })
	end)
end

local tabList = create("Frame", {
	Position = UDim2.fromOffset(8, 10),
	Size = UDim2.new(1, -16, 1, -10),
	BackgroundTransparency = 1,
	ZIndex = 2,
	Parent = sidebar,
})
local tabLayout = create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabList })

local function updateSidebarCanvas()
	sidebar.CanvasSize = UDim2.fromOffset(0, 10 + tabLayout.AbsoluteContentSize.Y + 24)
end

tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarCanvas)
create("Frame", {
	Position = UDim2.fromOffset(170, 39),
	Size = UDim2.new(0, 1, 1, -39),
	BackgroundColor3 = strokeColor,
	BorderSizePixel = 0,
	Parent = main,
})
sidebar.ZIndex = 5
local content = create("Frame", {
	Position = UDim2.fromOffset(184, 50),
	Size = UDim2.new(1, -196, 1, -60),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	ZIndex = 1,
	Parent = main,
})
local fadeOverlay = create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = bgColor,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 50,
	Parent = content,
})
local fadeTween
local tabs = {}
local currentTab

local function selectTab(tab)
	if currentTab == tab then
		return
	end
	local old = currentTab
	currentTab = tab
	for _, t in ipairs(tabs) do
		if t ~= tab then
			t.page.Visible = false
		end
	end
	local y = tab.y
	if old then
		tween(tabSelector, 0.3, { Position = UDim2.fromOffset(8, y) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
	else
		tabSelector.Position = UDim2.fromOffset(8, y)
	end
	playSweep()
	if old then
		tween(old.label, 0.2, { TextColor3 = dimColor })
		old.label.Font = Enum.Font.GothamMedium
		old.icon.color(dimColor)
		old.chev(false)
	end
	tween(tab.label, 0.2, { TextColor3 = accentColor })
	tab.label.Font = Enum.Font.GothamBold
	tab.icon.color(accentColor)
	tab.icon.pop()
	tab.chev(true)
	tab.page.CanvasPosition = Vector2.zero
	tab.page.Position = UDim2.fromOffset(0, 14)
	tab.page.Visible = true
	tween(tab.page, 0.35, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
	if fadeTween then
		fadeTween:Cancel()
	end
	fadeOverlay.BackgroundTransparency = 0
	fadeTween = tween(fadeOverlay, 0.3, { BackgroundTransparency = 1 })
end

return (function(...)
	local searchTerms

	local function matchesSearch(item, s, tab)
		local key = item.key .. " " .. s.name:lower() .. " " .. tab.label.Text:lower()
		for _, w in ipairs(searchTerms) do
			if not key:find(w, 1, true) then
				return false
			end
		end
		return true
	end

	local function layoutTab(tab)
		if tab.custom then
			return
		end
		local y = 46
		if searchTerms then
			for _, s in ipairs(tab.sections) do
				local rowY = 30
				local any = false
				for _, item in ipairs(s.items) do
					local ok = matchesSearch(item, s, tab)
					item.row.Visible = ok
					if ok then
						item.row.Position = UDim2.fromOffset(8, rowY)
						rowY += item.h + 6
						any = true
					end
				end
				s.card.Visible = any
				if any then
					local h = rowY + 8 - 6
					s.card.Position = UDim2.fromOffset(2, y)
					s.card.Size = UDim2.new(1, -8, 0, h)
					y += h + 10
				end
			end
			tab.page.CanvasSize = UDim2.fromOffset(0, y - 10 + 2 + 4)
			return
		end
		for _, s in ipairs(tab.sections) do
			local shown = not tab.subs or s.group == tab.sub
			local expanded = not s.collapsible or s.isOpen or s.open > 0.001
			for _, item in ipairs(s.items) do
				item.row.Position = UDim2.fromOffset(8, item.y)
				item.row.Visible = expanded
			end
			local h = s.height
			if s.collapsible then
				h = math.floor(30 + (s.height - 30) * s.open + 0.5)
			end
			s.card.Visible = shown
			if shown then
				s.card.Position = UDim2.fromOffset(2, y)
				s.card.Size = UDim2.new(1, -8, 0, h)
				y += h + 10
			end
		end
		tab.page.CanvasSize = UDim2.fromOffset(0, y - 10 + 2 + 4)
	end

	local function addSeparator()
		layoutOrder += 1
		local holder = create("Frame", {
			Size = UDim2.new(1, 0, 0, 9),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = tabList,
		})
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 4, 0, 1),
			BackgroundColor3 = strokeColor,
			BorderSizePixel = 0,
			Parent = holder,
		})
		tabY += 12
	end

	local function addTab(name, iconName, desc)
		local index = #tabs + 1
		layoutOrder += 1
		local y = tabY
		tabY += 35
		local tabBtn = create("TextButton", {
			Text = "",
			BackgroundColor3 = elemColor,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 32),
			LayoutOrder = layoutOrder,
			Parent = tabList,
		})
		addCorner(tabBtn, 7)
		local icon = createIcon(iconName, tabBtn)
		local label = create("TextLabel", {
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = dimColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(38, 0),
			Size = UDim2.new(1, -60, 1, 0),
			ZIndex = 3,
			Parent = tabBtn,
		})
		local chevron = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(6, 10),
			BackgroundTransparency = 1,
			ZIndex = 3,
			Parent = tabBtn,
		})
		local chevTop = line(chevron, 1, 1.5, 4.5, 5, 1.5, mutedColor)
		local chevBottom = line(chevron, 4.5, 5, 1, 8.5, 1.5, mutedColor)
		chevTop.ZIndex, chevBottom.ZIndex = 3, 3

		local function setChevron(on)
			tween(chevron, 0.3, { Rotation = on and 90 or 0 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			tween(chevTop, 0.2, { BackgroundColor3 = on and accentColor or mutedColor })
			tween(chevBottom, 0.2, { BackgroundColor3 = on and accentColor or mutedColor })
		end

		local page = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = dimColor,
			CanvasSize = UDim2.new(),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.Never,
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			ScrollBarImageTransparency = 0.4,
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 1,
			Parent = content,
		})
		local pageTitle = create("TextLabel", {
			Text = name,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = accentColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -8, 0, 22),
			Parent = page,
		})
		local pageDesc = create("TextLabel", {
			Text = desc or "",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = dimColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 22),
			Size = UDim2.new(1, -8, 0, 16),
			Parent = page,
		})
		local tab = {
			index = index,
			y = y,
			btn = tabBtn,
			label = label,
			icon = icon,
			chev = setChevron,
			page = page,
			sections = {},
			title = pageTitle,
			desc = pageDesc,
		}
		table.insert(tabs, tab)
		connect(tabBtn.MouseButton1Click, function()
			selectTab(tab)
		end)
		connect(tabBtn.MouseEnter, function()
			if currentTab ~= tab then
				tween(label, 0.15, { TextColor3 = textColor })
				icon.color(textColor, 0.15)
			end
		end)
		connect(tabBtn.MouseLeave, function()
			if currentTab ~= tab then
				tween(label, 0.15, { TextColor3 = dimColor })
				icon.color(dimColor, 0.15)
			end
		end)
		return tab
	end

	local Section = {}
	Section.__index = Section

	local function addSection(tab, name, group)
		local card = create("Frame", { BackgroundColor3 = panelColor, Parent = tab.page })
		addCorner(card, 10)
		local stroke = addStroke(card)
		create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(accentColor, Color3.fromRGB(190, 190, 190)),
			Parent = card,
		})
		local highlight = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0, 15),
			Size = UDim2.fromOffset(3, 12),
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			Parent = card,
		})
		makeRound(highlight)
		addGradient(highlight)
		create("TextLabel", {
			Text = string.upper(name),
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(22, 0),
			Size = UDim2.new(1, -34, 0, 30),
			Parent = card,
		})
		connect(card.MouseEnter, function()
			tween(stroke, 0.2, { Color = Color3.fromRGB(56, 56, 56) })
		end)
		connect(card.MouseLeave, function()
			tween(stroke, 0.2, { Color = strokeColor })
		end)
		local s = setmetatable({
			tab = tab,
			card = card,
			name = name,
			items = {},
			y = 30,
			height = 32,
			rows = {},
			open = 1,
			group = group or tab.subs and tab.subs[1],
		}, Section)
		table.insert(tab.sections, s)
		layoutTab(tab)
		return s
	end

	local function setSubTabs(tab, items)
		tab.subs = items
		tab.sub = items[1]
		local cur = 1
		local titleW = TextService:GetTextSize(tab.title.Text, 18, Enum.Font.GothamBold, Vector2.new(400, 40)).X
		tab.desc.Visible = false
		tab.title.Size = UDim2.fromOffset(titleW + 4, 40)
		local bar = create("Frame", {
			Position = UDim2.fromOffset(titleW + 16, 6),
			Size = UDim2.new(1, -(titleW + 16) - 8, 0, 28),
			BackgroundTransparency = 1,
			ZIndex = 3,
			Parent = tab.page,
		})
		local subButtons = {}
		local x = 0
		for i, sub in ipairs(items) do
			local tw = TextService:GetTextSize(sub, 12, Enum.Font.GothamMedium, Vector2.new(300, 40)).X
			local w = tw + 34
			local b = create("TextButton", {
				Text = "",
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(90, 90, 90),
				BackgroundTransparency = i == cur and 0.35 or 1,
				Position = UDim2.fromOffset(x, 0),
				Size = UDim2.fromOffset(w, 28),
				ZIndex = 3,
				Parent = bar,
			})
			addCorner(b, 9)
			local pip = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 13, 0.5, 0),
				Size = UDim2.fromOffset(i == cur and 6 or 0, i == cur and 6 or 0),
				BackgroundColor3 = accentColor,
				BorderSizePixel = 0,
				ZIndex = 4,
				Parent = b,
			})
			makeRound(pip)
			local lbl = create("TextLabel", {
				Text = sub,
				Font = Enum.Font.GothamMedium,
				TextSize = 12,
				TextColor3 = i == cur and accentColor or dimColor,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(i == cur and 22 or 12, 0),
				Size = UDim2.new(1, -22, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
				Parent = b,
			})
			subButtons[i] = { b = b, dot = pip, lbl = lbl, w = w }
			x += w + 4
		end

		local function refresh(i, on)
			local o = subButtons[i]
			tween(o.b, 0.25, { BackgroundTransparency = on and 0.35 or 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			tween(o.dot, 0.25, { Size = UDim2.fromOffset(on and 6 or 0, on and 6 or 0) }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			tween(o.lbl, 0.25, { TextColor3 = on and accentColor or dimColor, Position = UDim2.fromOffset(on and 22 or 12, 0) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
		end

		local function relayout(anim)
			layoutTab(tab)
			if anim then
				tab.page.CanvasPosition = Vector2.zero
				tab.page.Position = UDim2.fromOffset(0, 14)
				tween(tab.page, 0.35, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
				if fadeTween then
					fadeTween:Cancel()
				end
				fadeOverlay.BackgroundTransparency = 0
				fadeTween = tween(fadeOverlay, 0.3, { BackgroundTransparency = 1 })
			end
		end

		local function set(i)
			if i == cur then
				return
			end
			refresh(cur, false)
			cur = i
			tab.sub = items[i]
			refresh(i, true)
			relayout(true)
		end

		tab.setSub = function(sub)
			local i = table.find(items, sub)
			if i then
				set(i)
			end
		end

		for i, o in ipairs(subButtons) do
			connect(o.b.MouseEnter, function()
				if i ~= cur then
					tween(o.b, 0.15, { BackgroundTransparency = 0.8 })
					tween(o.lbl, 0.15, { TextColor3 = textColor })
				end
			end)
			connect(o.b.MouseLeave, function()
				if i ~= cur then
					tween(o.b, 0.15, { BackgroundTransparency = 1 })
					tween(o.lbl, 0.15, { TextColor3 = dimColor })
				end
			end)
			connect(o.b.MouseButton1Click, function()
				set(i)
			end)
		end
		layoutTab(tab)
	end

	Section.Collapsible = function(self2, startOpen)
		self2.collapsible = true
		self2.isOpen = startOpen and true or false
		self2.open = self2.isOpen and 1 or 0
		self2.card.ClipsDescendants = true
		local stroke = self2.card:FindFirstChildOfClass("UIStroke")
		local headerBtn = create("TextButton", {
			Text = "",
			BackgroundColor3 = elemColor,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 4,
			Parent = self2.card,
		})
		local hint = create("TextLabel", {
			Text = self2.isOpen and "hide" or "open",
			Font = Enum.Font.GothamMedium,
			TextSize = 10,
			TextColor3 = mutedColor,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -30, 0, 15),
			Size = UDim2.fromOffset(40, 14),
			ZIndex = 5,
			Parent = self2.card,
		})
		local arrow = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -18, 0, 15),
			Size = UDim2.fromOffset(10, 6),
			BackgroundTransparency = 1,
			Rotation = self2.isOpen and 180 or 0,
			ZIndex = 5,
			Parent = self2.card,
		})
		local arrowL = line(arrow, 1, 1, 5, 5, 1.6)
		local arrowR = line(arrow, 5, 5, 9, 1, 1.6)
		arrowL.ZIndex, arrowR.ZIndex = 5, 5
		local anim = Instance.new("NumberValue")
		anim.Value = self2.open
		connect(anim.Changed, function(v)
			self2.open = v
			layoutTab(self2.tab)
		end)
		local openTween

		local function toggleCollapse()
			self2.isOpen = not self2.isOpen
			local on = self2.isOpen
			if on then
				for _, r in ipairs(self2.rows) do
					r.Visible = true
				end
			end
			if openTween then
				openTween:Cancel()
			end
			openTween = tween(anim, on and 0.4 or 0.3, { Value = on and 1 or 0 }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			openTween.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed and not self2.isOpen then
					for _, r in ipairs(self2.rows) do
						r.Visible = false
					end
				end
			end)
			tween(arrow, 0.35, { Rotation = on and 180 or 0 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			hint.Text = on and "hide" or "open"
			if stroke then
				stroke.Color = accentColor
				tween(stroke, 0.5, { Color = strokeColor })
			end
		end

		connect(headerBtn.MouseButton1Click, toggleCollapse)

		self2.expand = function()
			if not self2.isOpen then
				toggleCollapse()
			end
		end

		connect(headerBtn.MouseEnter, function()
			tween(arrowL, 0.15, { BackgroundColor3 = accentColor })
			tween(arrowR, 0.15, { BackgroundColor3 = accentColor })
			tween(hint, 0.15, { TextColor3 = textColor })
		end)
		connect(headerBtn.MouseLeave, function()
			tween(arrowL, 0.15, { BackgroundColor3 = dimColor })
			tween(arrowR, 0.15, { BackgroundColor3 = dimColor })
			tween(hint, 0.15, { TextColor3 = mutedColor })
		end)
		layoutTab(self2.tab)
		return self2
	end

	local config = {}
	local registry = {}
	local loading = true
	local HttpService = game:GetService("HttpService")
	local storageFolder = "Rock Hub"
	local currentConfigFile = storageFolder .. "/current.json"
	local profilesFile = storageFolder .. "/configs.json"
	if makefolder and not (isfolder and isfolder(storageFolder)) then
		pcall(makefolder, storageFolder)
	end
	pcall(function()
		local file = isfile and isfile(currentConfigFile) and currentConfigFile or "rockhub_config.json"
		if isfile and isfile(file) then
			local d = HttpService:JSONDecode(readfile(file))
			if type(d) == "table" then
				config = d
			end
		end
	end)
	local profiles = {}
	pcall(function()
		local file = isfile and isfile(profilesFile) and profilesFile or "rockhub_configs.json"
		if isfile and isfile(file) then
			local d = HttpService:JSONDecode(readfile(file))
			if type(d) == "table" then
				profiles = d
			end
		end
	end)
	local dirty, dirtyAt = false, 0
	local noSave = {}

	local function setConfig(key, v)
		if noSave[key] then
			return
		end
		if loading or config[key] == v then
			return
		end
		config[key] = v
		dirty = true
		dirtyAt = os.clock()
	end

	local function saveConfig()
		dirty = false
		if not writefile then
			return
		end
		pcall(function()
			writefile(currentConfigFile, HttpService:JSONEncode(config))
		end)
	end

	local function copyConfig(source)
		local ok, result = pcall(function()
			return HttpService:JSONDecode(HttpService:JSONEncode(source))
		end)
		return ok and result or {}
	end

	local function snapshotConfig()
		local snapshot = copyConfig(config)
		for _, r in ipairs(registry) do
			if r.get then
				local ok, value = pcall(r.get)
				if ok and value ~= nil then
					snapshot[r.key] = value
				end
			end
		end
		return snapshot
	end

	local function saveProfiles()
		if not writefile then
			return false, "file API is unavailable"
		end
		local ok, err = pcall(function()
			writefile(profilesFile, HttpService:JSONEncode(profiles))
		end)
		return ok, err
	end

	local function normalizeProfileName(name)
		name = tostring(name or ""):match("^%s*(.-)%s*$")
		if name == "" then
			return nil, "enter a config name"
		end
		if (utf8.len(name) or #name) > 32 then
			return nil, "name must be 32 characters or less"
		end
		if name:find("[%c]") then
			return nil, "name contains unsupported characters"
		end
		return name
	end

	local function applyConfig(data)
		config = copyConfig(data)
		loading = true
		for _, r in ipairs(registry) do
			local value = config[r.key]
			if value == nil then
				value = r.default
			end
			if value ~= nil then
				pcall(r.set, value)
			end
		end
		loading = false
		dirty = false
		saveConfig()
	end

	connect(RunService.Heartbeat, function()
		if dirty and os.clock() - dirtyAt > 1 then
			saveConfig()
		end
	end)

	local function configKey(sec, itemName)
		return sec.tab.label.Text .. "/" .. sec.name .. "/" .. itemName
	end

	local function register(key, set, get, default)
		if noSave[key] then
			return
		end
		table.insert(registry, { key = key, set = set, get = get, default = default })
	end

	local hoverStroke = Color3.fromRGB(62, 62, 62)
	local activeStroke = Color3.fromRGB(88, 88, 88)

	Section._row = function(self2, name, desc, height)
		local h = height or (desc and 40 or 32)
		local row = create("TextButton", {
			Text = "",
			BackgroundColor3 = elemColor,
			AutoButtonColor = false,
			Position = UDim2.fromOffset(8, self2.y),
			Size = UDim2.new(1, -16, 0, h),
			ClipsDescendants = true,
			Parent = self2.card,
		})
		addCorner(row, 7)
		local rowStroke = addStroke(row)
		table.insert(self2.rows, row)
		table.insert(self2.items, {
			row = row,
			y = self2.y,
			h = h,
			name = name,
			desc = desc,
			key = (name .. " " .. (desc or "")):lower(),
		})
		if self2.collapsible and not self2.isOpen then
			row.Visible = false
		end
		self2.y += h + 6
		self2.height = self2.y + 8 - 6
		layoutTab(self2.tab)
		local accent = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(2, 0),
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = row,
		})
		addCorner(accent, 1)
		local logo2 = create("TextLabel", {
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, desc and 6 or 0),
			Size = UDim2.new(1, -150, 0, desc and 15 or h),
			Parent = row,
		})
		if desc then
			create("TextLabel", {
				Text = desc,
				Font = Enum.Font.Gotham,
				TextSize = 10,
				TextColor3 = mutedColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 21),
				Size = UDim2.new(1, -150, 0, 13),
				Parent = row,
			})
		end
		local hovered, active = false, false

		local function refresh()
			local lit = hovered or active
			tween(accent, 0.3, { Size = UDim2.fromOffset(2, active and h - 14 or (hovered and 12 or 0)) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			tween(row, 0.15, { BackgroundColor3 = hovered and hoverColor or elemColor })
			tween(logo2, 0.2, {
				TextColor3 = lit and accentColor or textColor,
				Position = UDim2.fromOffset(hovered and 15 or 12, logo2.Position.Y.Offset),
			}, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			tween(rowStroke, 0.2, { Color = active and activeStroke or (hovered and hoverStroke or strokeColor) })
		end

		connect(row.MouseEnter, function()
			hovered = true
			refresh()
		end)
		connect(row.MouseLeave, function()
			hovered = false
			refresh()
		end)

		local function highlight(on)
			active = on
			refresh()
		end

		return row, logo2, rowStroke, highlight
	end

	Section.Toggle = function(self2, name, desc, callback)
		local state = false
		local key = configKey(self2, name)
		local row, _, _, highlight = self2:_row(name, desc)
		local track = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(34, 18),
			BackgroundColor3 = bgColor,
			BorderSizePixel = 0,
			Parent = row,
		})
		makeRound(track)
		local trackStroke = addStroke(track)
		local glow = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = accentColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = track,
		})
		makeRound(glow)
		create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(150, 150, 150), accentColor), Parent = glow })
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 9, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = dimColor,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
		})
		makeRound(knob)

		local function apply(v, silent)
			state = v
			knob.Size = UDim2.fromOffset(18, 12)
			tween(knob, 0.35, {
				Position = UDim2.new(0, state and 25 or 9, 0.5, 0),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = state and bgColor or dimColor,
			}, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			tween(glow, 0.25, { BackgroundTransparency = state and 0 or 1 })
			tween(trackStroke, 0.25, { Color = state and accentColor or strokeColor })
			highlight(state)
			setConfig(key, state)
			if not silent then
				task.spawn(callback, state)
			end
		end

		connect(row.MouseButton1Click, function()
			apply(not state)
		end)
		register(key, function(v)
			if type(v) == "boolean" and v ~= state then
				apply(v)
			end
		end, function()
			return state
		end, false)
		return {
			Set = function(v, silent)
				if v ~= state then
					apply(v, silent)
				end
			end,
			Get = function()
				return state
			end,
		}
	end

	Section.Segmented = function(self2, name, options, default, callback)
		local cur = table.find(options, default) or 1
		local n = #options
		local key = configKey(self2, name)
		local row, logo2 = self2:_row(name, nil, 34)
		local totalW = n * 60
		logo2.Size = UDim2.new(1, -(totalW + 24), 1, 0)
		local pill = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(totalW, 24),
			BackgroundColor3 = bgColor,
			Parent = row,
		})
		addCorner(pill, 7)
		local pillStroke = addStroke(pill)
		local thumb = create("Frame", {
			Position = UDim2.new((cur - 1) / n, 2, 0, 2),
			Size = UDim2.new(1 / n, -4, 1, -4),
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = pill,
		})
		addCorner(thumb, 6)
		create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(accentColor, Color3.fromRGB(185, 185, 185)),
			Parent = thumb,
		})
		local thumbScale = create("UIScale", { Parent = thumb })
		local optionBtns = {}

		local function set(i, silent)
			if i == cur then
				return
			end
			tween(optionBtns[cur], 0.2, { TextColor3 = dimColor })
			optionBtns[cur].Font = Enum.Font.GothamMedium
			cur = i
			tween(optionBtns[i], 0.2, { TextColor3 = bgColor })
			optionBtns[i].Font = Enum.Font.GothamBold
			tween(thumb, 0.35, { Position = UDim2.new((i - 1) / n, 2, 0, 2) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			thumbScale.Scale = 0.86
			tween(thumbScale, 0.4, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			pillStroke.Color = accentColor
			tween(pillStroke, 0.45, { Color = strokeColor })
			setConfig(key, options[i])
			if not silent then
				task.spawn(callback, options[i])
			end
		end

		register(key, function(v)
			local i = table.find(options, v)
			if i then
				set(i)
			end
		end, function()
			return options[cur]
		end, options[table.find(options, default) or 1])
		for i, opt in ipairs(options) do
			local b = create("TextButton", {
				Text = opt,
				Font = i == cur and Enum.Font.GothamBold or Enum.Font.GothamMedium,
				TextSize = 11,
				TextColor3 = i == cur and bgColor or dimColor,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Position = UDim2.fromScale((i - 1) / n, 0),
				Size = UDim2.fromScale(1 / n, 1),
				ZIndex = 3,
				Parent = pill,
			})
			optionBtns[i] = b
			connect(b.MouseEnter, function()
				if i ~= cur then
					tween(b, 0.15, { TextColor3 = textColor })
				end
			end)
			connect(b.MouseLeave, function()
				if i ~= cur then
					tween(b, 0.15, { TextColor3 = dimColor })
				end
			end)
			connect(b.MouseButton1Click, function()
				set(i)
			end)
		end
		return {
			Set = function(opt, silent)
				local i = table.find(options, opt)
				if i then
					set(i, silent)
				end
			end,
			Get = function()
				return options[cur]
			end,
		}
	end

	Section.Button = function(self2, name, desc, callback)
		local row = self2:_row(name, desc)
		local holder = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = bgColor,
			ZIndex = 2,
			Parent = row,
		})
		makeRound(holder)
		local circleStroke = addStroke(holder)
		local circleScale = create("UIScale", { Parent = holder })
		local arrow = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 1, 0.5, 0),
			Size = UDim2.fromOffset(6, 10),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Parent = holder,
		})
		local a1 = line(arrow, 1, 1, 5, 5, 1.6)
		local a2 = line(arrow, 5, 5, 1, 9, 1.6)
		a1.ZIndex, a2.ZIndex = 3, 3
		connect(row.MouseEnter, function()
			tween(holder, 0.2, { BackgroundColor3 = accentColor })
			tween(circleStroke, 0.2, { Color = accentColor })
			tween(a1, 0.2, { BackgroundColor3 = bgColor })
			tween(a2, 0.2, { BackgroundColor3 = bgColor })
		end)
		connect(row.MouseLeave, function()
			tween(holder, 0.2, { BackgroundColor3 = bgColor })
			tween(circleStroke, 0.2, { Color = strokeColor })
			tween(a1, 0.2, { BackgroundColor3 = dimColor })
			tween(a2, 0.2, { BackgroundColor3 = dimColor })
		end)
		connect(row.MouseButton1Click, function()
			local w = row.AbsoluteSize.X * 1.15
			local ripple = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(0, 0),
				BackgroundColor3 = accentColor,
				BackgroundTransparency = 0.82,
				BorderSizePixel = 0,
				Parent = row,
			})
			makeRound(ripple)
			tween(ripple, 0.55, { Size = UDim2.fromOffset(w, w), BackgroundTransparency = 1 })
			task.delay(0.6, function()
				ripple:Destroy()
			end)
			circleScale.Scale = 0.75
			tween(circleScale, 0.4, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			task.spawn(callback)
		end)
	end

	Section.Input = function(self2, name, desc, placeholder)
		local row = self2:_row(name, desc)
		local box = create("TextBox", {
			Text = "",
			PlaceholderText = placeholder or "enter text",
			PlaceholderColor3 = mutedColor,
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			BackgroundColor3 = bgColor,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(130, 24),
			Parent = row,
		})
		addCorner(box, 6)
		local outline = addStroke(box)
		create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box })
		connect(box.Focused, function()
			tween(outline, 0.15, { Color = accentColor })
		end)
		connect(box.FocusLost, function()
			tween(outline, 0.25, { Color = strokeColor })
		end)
		return {
			Get = function()
				return box.Text
			end,
			Set = function(value)
				box.Text = tostring(value or "")
			end,
			SetPlaceholder = function(value)
				box.PlaceholderText = tostring(value or "")
			end,
			Focus = function()
				box:CaptureFocus()
			end,
		}
	end

	Section.Dropdown = function(self2, name, desc, options, placeholder, callback)
		local row = self2:_row(name, desc)
		local values = table.clone(options or {})
		local selected
		local closePopup
		local badge = create("TextButton", {
			Text = placeholder or "select...",
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = dimColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundColor3 = bgColor,
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(130, 24),
			Parent = row,
		})
		addCorner(badge, 6)
		local badgeStroke = addStroke(badge)
		create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 20), Parent = badge })
		local arrow = create("TextLabel", {
			Text = "v",
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = mutedColor,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, -1),
			Size = UDim2.fromOffset(12, 16),
			ZIndex = 3,
			Parent = badge,
		})

		local function setSelected(value, silent)
			if value ~= nil and not table.find(values, value) then
				return
			end
			selected = value
			badge.Text = value or placeholder or "select..."
			badge.TextColor3 = value and textColor or dimColor
			if value and not silent then
				task.spawn(callback, value)
			end
		end

		connect(badge.MouseButton1Click, function()
			if closePopup then
				closePopup()
				return
			end
			local backdrop = create("TextButton", {
				Text = "",
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 149,
				Parent = gui,
			})
			local visibleRows = math.max(1, math.min(#values, 5))
			local popupHeight = visibleRows * 26 + 8
			local rel = badge.AbsolutePosition - gui.AbsolutePosition
			local x = math.clamp(rel.X, 4, math.max(4, gui.AbsoluteSize.X - 134))
			local below = rel.Y + badge.AbsoluteSize.Y + 4
			local y = below + popupHeight <= gui.AbsoluteSize.Y - 4 and below or math.max(4, rel.Y - popupHeight - 4)
			local popup = create("Frame", {
				Position = UDim2.fromOffset(x, y),
				Size = UDim2.fromOffset(130, popupHeight),
				BackgroundColor3 = panelColor,
				ZIndex = 150,
				Parent = gui,
			})
			addCorner(popup, 7)
			create("UIStroke", { Color = accentColor, Transparency = 0.45, Thickness = 1, Parent = popup })
			local list = create("ScrollingFrame", {
				Position = UDim2.fromOffset(4, 4),
				Size = UDim2.new(1, -8, 1, -8),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = #values > 5 and 2 or 0,
				CanvasSize = UDim2.fromOffset(0, math.max(22, #values * 26)),
				ZIndex = 151,
				Parent = popup,
			})
			closePopup = function()
				closePopup = nil
				if backdrop.Parent then
					backdrop:Destroy()
				end
				if popup.Parent then
					popup:Destroy()
				end
				tween(badgeStroke, 0.2, { Color = strokeColor })
				tween(arrow, 0.2, { Rotation = 0, TextColor3 = mutedColor })
			end
			backdrop.MouseButton1Click:Connect(closePopup)
			tween(badgeStroke, 0.15, { Color = accentColor })
			tween(arrow, 0.2, { Rotation = 180, TextColor3 = accentColor })
			if #values == 0 then
				create("TextLabel", {
					Text = "no configs",
					Font = Enum.Font.GothamMedium,
					TextSize = 10,
					TextColor3 = mutedColor,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					ZIndex = 152,
					Parent = list,
				})
			else
				for i, value in ipairs(values) do
					local option = create("TextButton", {
						Text = value,
						Font = selected == value and Enum.Font.GothamBold or Enum.Font.GothamMedium,
						TextSize = 10,
						TextColor3 = selected == value and accentColor or textColor,
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundColor3 = selected == value and hoverColor or elemColor,
						AutoButtonColor = false,
						Position = UDim2.fromOffset(0, (i - 1) * 26),
						Size = UDim2.new(1, -2, 0, 22),
						ZIndex = 152,
						Parent = list,
					})
					addCorner(option, 5)
					option.MouseButton1Click:Connect(function()
						setSelected(value)
						closePopup()
					end)
				end
			end
		end)

		return {
			Get = function()
				return selected
			end,
			Set = setSelected,
			Update = function(newOptions)
				values = table.clone(newOptions or {})
				if selected and not table.find(values, selected) then
					setSelected(nil, true)
				end
				if closePopup then
					closePopup()
				end
			end,
		}
	end

	local dragSlider

	Section.Slider = function(self2, name, min, max, default, callback, fmt)
		fmt = fmt or tostring
		local key = configKey(self2, name)
		local row, logo2 = self2:_row(name, nil, 44)
		logo2.Position = UDim2.fromOffset(12, 7)
		local valueW = 40
		for _, v in ipairs({ min, max, default }) do
			valueW = math.max(valueW, TextService:GetTextSize(fmt(v), 10, Enum.Font.GothamBold, Vector2.new(200, 20)).X + 16)
		end
		logo2.Size = UDim2.new(1, -(valueW + 30), 0, 16)
		local valueLabel = create("TextLabel", {
			Text = fmt(default),
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = textColor,
			BackgroundColor3 = bgColor,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 6),
			Size = UDim2.fromOffset(valueW, 18),
			Parent = row,
		})
		addCorner(valueLabel, 6)
		local valueStroke = addStroke(valueLabel)
		local bar = create("Frame", {
			Position = UDim2.new(0, 12, 0, 31),
			Size = UDim2.new(1, -24, 0, 5),
			BackgroundColor3 = bgColor,
			BorderSizePixel = 0,
			Parent = row,
		})
		makeRound(bar)
		addStroke(bar)
		local pct = (default - min) / (max - min)
		local fillBar = create("Frame", {
			Size = UDim2.new(pct, 6 - 12 * pct, 1, 0),
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			Parent = bar,
		})
		makeRound(fillBar)
		create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(95, 95, 95), accentColor), Parent = fillBar })
		local track = create("Frame", {
			Position = UDim2.fromOffset(6, 0),
			Size = UDim2.new(1, -12, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Parent = bar,
		})
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(pct, 0.5),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
		})
		makeRound(knob)
		create("UIStroke", { Color = elemColor, Thickness = 2, Parent = knob })
		local knobScale = create("UIScale", { Parent = knob })
		local hit = create("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 22),
			Size = UDim2.new(1, 0, 0, 22),
			ZIndex = 3,
			Parent = row,
		})
		local last = default
		local dragging = false

		local function render(val, t)
			local r = (val - min) / (max - min)
			tween(knob, t, { Position = UDim2.fromScale(r, 0.5) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			tween(fillBar, t, { Size = UDim2.new(r, 6 - 12 * r, 1, 0) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			valueLabel.Text = fmt(val)
		end

		local function set(x)
			local w = math.max(track.AbsoluteSize.X, 1)
			local rel = math.clamp((x - track.AbsolutePosition.X) / w, 0, 1)
			local val = math.floor(min + (max - min) * rel + 0.5)
			render(val, 0.08)
			if val ~= last then
				last = val
				setConfig(key, val)
				task.spawn(callback, val)
			end
		end

		connect(row.MouseEnter, function()
			if not dragging then
				tween(knobScale, 0.2, { Scale = 1.15 })
			end
		end)
		connect(row.MouseLeave, function()
			if not dragging then
				tween(knobScale, 0.2, { Scale = 1 })
			end
		end)
		connect(hit.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragSlider = set
				dragging = true
				tween(knobScale, 0.2, { Scale = 1.35 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
				tween(valueStroke, 0.15, { Color = accentColor })
				tween(valueLabel, 0.15, { TextColor3 = accentColor })
				set(input.Position.X)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				tween(knobScale, 0.25, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
				tween(valueStroke, 0.3, { Color = strokeColor })
				tween(valueLabel, 0.3, { TextColor3 = textColor })
			end
		end)

		local function setValue(v, silent)
			v = math.clamp(v, min, max)
			render(v, 0.3)
			if v ~= last then
				last = v
				setConfig(key, v)
				if not silent then
					task.spawn(callback, v)
				end
			end
		end

		register(key, function(v)
			if type(v) == "number" then
				setValue(v)
			end
		end, function()
			return last
		end, default)
		return {
			Set = setValue,
			Get = function()
				return last
			end,
		}
	end

	Section.Keybind = function(self2, name, desc, getKey, setKey)
		local key = configKey(self2, name)
		local row = self2:_row(name, desc)
		local badge = create("TextLabel", {
			Text = getKey().Name,
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = textColor,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundColor3 = bgColor,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(84, 22),
			Parent = row,
		})
		addCorner(badge, 6)
		local badgeStroke = addStroke(badge)
		connect(row.MouseButton1Click, function()
			if keyListener then
				return
			end
			badge.Text = "press a key..."
			tween(badgeStroke, 0.15, { Color = accentColor })
			tween(badge, 0.15, { BackgroundColor3 = hoverColor })

			keyListener = function(k)
				if k and k ~= Enum.KeyCode.Escape then
					setKey(k)
					setConfig(key, k.Name)
				end
				badge.Text = getKey().Name
				tween(badgeStroke, 0.3, { Color = strokeColor })
				tween(badge, 0.3, { BackgroundColor3 = bgColor })
			end
		end)
		register(key, function(v)
			local ok, k = pcall(function()
				return Enum.KeyCode[v]
			end)
			if ok and k then
				setKey(k)
				badge.Text = k.Name
			end
		end, function()
			return getKey().Name
		end, getKey().Name)
	end

	Section.Select = function(self2, name, desc, options, default, callback)
		local cur = table.find(options, default) or 1
		local n = #options
		local key = configKey(self2, name)
		local row = self2:_row(name, desc)
		local badge = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(130, 24),
			BackgroundColor3 = bgColor,
			ClipsDescendants = true,
			Parent = row,
		})
		addCorner(badge, 6)
		local badgeStroke = addStroke(badge)
		local arrows = {}
		for _, dir in ipairs({ -1, 1 }) do
			local a = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(dir < 0 and 0 or 1, dir < 0 and 10 or -10, 0.5, -1),
				Size = UDim2.fromOffset(5, 8),
				BackgroundTransparency = 1,
				ZIndex = 2,
				Parent = badge,
			})
			local l1, l2
			if dir < 0 then
				l1, l2 = line(a, 4, 0.5, 1, 4, 1.4), line(a, 1, 4, 4, 7.5, 1.4)
			else
				l1, l2 = line(a, 1, 0.5, 4, 4, 1.4), line(a, 4, 4, 1, 7.5, 1.4)
			end
			l1.ZIndex, l2.ZIndex = 2, 2
			arrows[dir] = { frame = a, l1 = l1, l2 = l2 }
		end
		local dots = {}
		if n <= 8 then
			for i = 1, n do
				local d = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, (i - (n + 1) / 2) * 6, 1, -3),
					Size = UDim2.fromOffset(i == cur and 5 or 2, 2),
					BackgroundColor3 = i == cur and accentColor or mutedColor,
					BorderSizePixel = 0,
					ZIndex = 2,
					Parent = badge,
				})
				makeRound(d)
				dots[i] = d
			end
		end

		local function makeLabel(text, yScale, transp)
			return create("TextLabel", {
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextColor3 = textColor,
				TextTransparency = transp,
				TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 18, yScale, #dots > 0 and -2 or 0),
				Size = UDim2.new(1, -36, 1, 0),
				Parent = badge,
			})
		end

		local lbl = makeLabel(options[cur], 0, 0)
		local labelY = #dots > 0 and -2 or 0

		local function choose(i, dir, silent)
			if i == cur then
				return
			end
			if dots[cur] then
				tween(dots[cur], 0.25, { Size = UDim2.fromOffset(2, 2), BackgroundColor3 = mutedColor })
			end
			cur = i
			if dots[cur] then
				tween(dots[cur], 0.25, { Size = UDim2.fromOffset(5, 2), BackgroundColor3 = accentColor }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			end
			local old = lbl
			tween(old, 0.15, { Position = UDim2.new(0, 18, -dir, labelY), TextTransparency = 1 })
			task.delay(0.16, function()
				old:Destroy()
			end)
			lbl = makeLabel(options[cur], dir, 1)
			tween(lbl, 0.25, { Position = UDim2.new(0, 18, 0, labelY), TextTransparency = 0 }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			local ar = arrows[dir]
			local base = ar.frame.Position
			ar.frame.Position = base + UDim2.fromOffset(dir * 3, 0)
			tween(ar.frame, 0.3, { Position = base }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			badgeStroke.Color = accentColor
			tween(badgeStroke, 0.4, { Color = strokeColor })
			setConfig(key, options[cur])
			if not silent then
				task.spawn(callback, options[cur])
			end
		end

		register(key, function(v)
			local i = table.find(options, v)
			if i and i ~= cur then
				choose(i, i > cur and 1 or -1)
			end
		end, function()
			return options[cur]
		end, options[table.find(options, default) or 1])

		local function step(dir)
			choose((cur - 1 + dir) % n + 1, dir)
		end

		connect(row.MouseButton1Click, function()
			step(1)
		end)
		connect(row.MouseButton2Click, function()
			step(-1)
		end)
		connect(row.MouseEnter, function()
			for _, ar in pairs(arrows) do
				tween(ar.l1, 0.15, { BackgroundColor3 = accentColor })
				tween(ar.l2, 0.15, { BackgroundColor3 = accentColor })
			end
		end)
		connect(row.MouseLeave, function()
			for _, ar in pairs(arrows) do
				tween(ar.l1, 0.15, { BackgroundColor3 = dimColor })
				tween(ar.l2, 0.15, { BackgroundColor3 = dimColor })
			end
		end)
		return {
			Set = function(opt, silent)
				local i = table.find(options, opt)
				if i then
					choose(i, i > cur and 1 or -1, silent)
				end
			end,
			Get = function()
				return options[cur]
			end,
		}
	end

	local openPicker
	local presets = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 69, 58),
		Color3.fromRGB(255, 159, 10),
		Color3.fromRGB(255, 214, 10),
		Color3.fromRGB(48, 209, 88),
		Color3.fromRGB(100, 210, 255),
		Color3.fromRGB(10, 132, 255),
		Color3.fromRGB(191, 90, 242),
		Color3.fromRGB(255, 55, 95),
	}

	local function relPos(inst)
		return inst.AbsolutePosition - gui.AbsolutePosition
	end

	local function openColorPicker(anchor, startColor, defaultColor, onChange)
		local h, sat, v = startColor:ToHSV()
		local original = startColor
		local backdrop = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 149,
			Parent = main,
		})
		addCorner(backdrop, 10)
		tween(backdrop, 0.3, { BackgroundTransparency = 0.45 })
		local popup = create("CanvasGroup", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = panelColor,
			GroupTransparency = 1,
			Size = UDim2.fromOffset(264, 344),
			ZIndex = 150,
			Parent = gui,
		})
		addCorner(popup, 12)
		create("UIStroke", { Color = accentColor, Transparency = 0.82, Thickness = 1, Parent = popup })
		local popupScale = create("UIScale", { Scale = 0.08, Parent = popup })

		local function anchorCenter()
			local p, sz = relPos(anchor), anchor.AbsoluteSize
			return UDim2.fromOffset(p.X + sz.X / 2, p.Y + sz.Y / 2)
		end

		local function mainCenter()
			local p, sz = relPos(main), main.AbsoluteSize
			return UDim2.fromOffset(p.X + sz.X / 2, p.Y + sz.Y / 2)
		end

		popup.Position = anchorCenter()
		local lights = {}
		local lightDefs = {
			{ Color3.fromRGB(255, 95, 87), "×" },
			{ Color3.fromRGB(254, 188, 46), "–" },
			{ Color3.fromRGB(40, 200, 64), "+" },
		}
		local lightsBar = create("Frame", {
			Position = UDim2.fromOffset(12, 10),
			Size = UDim2.fromOffset(56, 12),
			BackgroundTransparency = 1,
			ZIndex = 151,
			Parent = popup,
		})
		for i, l in ipairs(lightDefs) do
			local b = create("TextButton", {
				Text = "",
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = Color3.fromRGB(60, 20, 10),
				TextTransparency = 1,
				AutoButtonColor = false,
				BackgroundColor3 = l[1],
				Position = UDim2.fromOffset((i - 1) * 19, 0),
				Size = UDim2.fromOffset(12, 12),
				ZIndex = 152,
				Parent = lightsBar,
			})
			makeRound(b)
			b.Text = l[2]
			lights[i] = b
		end
		connect(lightsBar.MouseEnter, function()
			for _, b in ipairs(lights) do
				tween(b, 0.12, { TextTransparency = 0.2 })
			end
		end)
		connect(lightsBar.MouseLeave, function()
			for _, b in ipairs(lights) do
				tween(b, 0.12, { TextTransparency = 1 })
			end
		end)
		create("TextLabel", {
			Text = "Color",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = dimColor,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			ZIndex = 151,
			Parent = popup,
		})
		local sq = create("Frame", {
			Active = true,
			Position = UDim2.fromOffset(14, 36),
			Size = UDim2.fromOffset(236, 150),
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			ZIndex = 151,
			Parent = popup,
		})
		addCorner(sq, 8)
		local whiteLayer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = accentColor, ZIndex = 152, Parent = sq })
		addCorner(whiteLayer, 8)
		create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = whiteLayer })
		local blackLayer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 153, Parent = sq })
		addCorner(blackLayer, 8)
		create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = blackLayer })
		local svCursor = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			ZIndex = 155,
			Parent = sq,
		})
		makeRound(svCursor)
		create("UIStroke", { Color = accentColor, Thickness = 2, Parent = svCursor })
		local svCursorScale = create("UIScale", { Parent = svCursor })
		local hueBar = create("Frame", {
			Active = true,
			Position = UDim2.fromOffset(14, 198),
			Size = UDim2.fromOffset(236, 12),
			BackgroundColor3 = accentColor,
			ZIndex = 151,
			Parent = popup,
		})
		makeRound(hueBar)
		local hueKps = {}
		for i = 0, 6 do
			hueKps[#hueKps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1))
		end
		create("UIGradient", { Color = ColorSequence.new(hueKps), Parent = hueBar })
		local hueKnob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = accentColor,
			ZIndex = 153,
			Parent = hueBar,
		})
		makeRound(hueKnob)
		local hueKnobFill = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 154,
			Parent = hueKnob,
		})
		makeRound(hueKnobFill)
		local hueKnobScale = create("UIScale", { Parent = hueKnob })
		local prev = create("Frame", {
			Position = UDim2.fromOffset(14, 224),
			Size = UDim2.fromOffset(56, 30),
			BackgroundColor3 = original,
			ClipsDescendants = true,
			ZIndex = 151,
			Parent = popup,
		})
		addCorner(prev, 8)
		addStroke(prev, hoverColor)
		local previewNew = create("Frame", {
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
			BorderSizePixel = 0,
			ZIndex = 152,
			Parent = prev,
		})
		local hexBox = create("TextBox", {
			Text = "",
			PlaceholderText = "#FFFFFF",
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = textColor,
			PlaceholderColor3 = mutedColor,
			ClearTextOnFocus = false,
			BackgroundColor3 = elemColor,
			Position = UDim2.fromOffset(78, 224),
			Size = UDim2.new(1, -92, 0, 30),
			ZIndex = 151,
			Parent = popup,
		})
		addCorner(hexBox, 8)
		local hexStroke = addStroke(hexBox)
		create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = hexBox })
		hexBox.TextXAlignment = Enum.TextXAlignment.Left
		local rgbLabel = create("TextLabel", {
			Text = "",
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextColor3 = mutedColor,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 0),
			Size = UDim2.new(0, 90, 1, 0),
			ZIndex = 152,
			Parent = hexBox,
		})
		local swatches = {}
		local gap = (236 - #presets * 20) / (#presets - 1)
		for i, c in ipairs(presets) do
			local b = create("TextButton", {
				Text = "",
				AutoButtonColor = false,
				BackgroundColor3 = c,
				Position = UDim2.fromOffset(14 + (i - 1) * (20 + gap), 266),
				Size = UDim2.fromOffset(20, 20),
				ZIndex = 151,
				Parent = popup,
			})
			makeRound(b)
			local st = create("UIStroke", { Color = accentColor, Thickness = 1.5, Transparency = 1, Parent = b })
			local scale = create("UIScale", { Parent = b })
			connect(b.MouseEnter, function()
				tween(scale, 0.15, { Scale = 1.15 })
			end)
			connect(b.MouseLeave, function()
				tween(scale, 0.15, { Scale = 1 })
			end)
			swatches[i] = { btn = b, stroke = st, color = c, scale = scale }
		end
		local done = create("TextButton", {
			Text = "Done",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = bgColor,
			AutoButtonColor = false,
			BackgroundColor3 = accentColor,
			Position = UDim2.fromOffset(14, 300),
			Size = UDim2.new(1, -28, 0, 30),
			ZIndex = 151,
			Parent = popup,
		})
		addCorner(done, 8)
		local doneScale = create("UIScale", { Parent = done })
		connect(done.MouseEnter, function()
			tween(done, 0.15, { BackgroundColor3 = Color3.fromRGB(215, 215, 215) })
		end)
		connect(done.MouseLeave, function()
			tween(done, 0.15, { BackgroundColor3 = accentColor })
		end)

		local function currentTab2()
			return Color3.fromHSV(h, sat, v)
		end

		local function refresh(keepText)
			local c = currentTab2()
			sq.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			svCursor.Position = UDim2.fromScale(sat, 1 - v)
			hueKnob.Position = UDim2.fromScale(h, 0.5)
			hueKnobFill.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			previewNew.BackgroundColor3 = c
			if not keepText then
				hexBox.Text = "#" .. c:ToHex():upper()
			end
			rgbLabel.Text = ("%d  %d  %d"):format(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
			for _, sw in ipairs(swatches) do
				local match = sw.color:ToHex() == c:ToHex()
				sw.stroke.Transparency = match and 0 or 1
			end
			onChange(c)
		end

		refresh()
		local dragging
		local lastRelease = 0
		local overPopup = false

		local function dragTo(pos)
			if dragging == "sq" then
				local p, sz = sq.AbsolutePosition, sq.AbsoluteSize
				sat = math.clamp((pos.X - p.X) / sz.X, 0, 1)
				v = 1 - math.clamp((pos.Y - p.Y) / sz.Y, 0, 1)
			elseif dragging == "hue" then
				local p, sz = hueBar.AbsolutePosition, hueBar.AbsoluteSize
				h = math.clamp((pos.X - p.X) / sz.X, 0, 0.999)
			end
			refresh()
		end

		local function isPress(input)
			return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
		end

		local conns = {}

		local function bind(signal, fn)
			local c = signal:Connect(fn)
			table.insert(conns, c)
			table.insert(connections, c)
		end

		bind(sq.InputBegan, function(input)
			if not isPress(input) then
				return
			end
			dragging = "sq"
			tween(svCursorScale, 0.15, { Scale = 1.3 })
			dragTo(input.Position)
		end)
		bind(hueBar.InputBegan, function(input)
			if not isPress(input) then
				return
			end
			dragging = "hue"
			tween(hueKnobScale, 0.15, { Scale = 1.2 })
			dragTo(input.Position)
		end)
		bind(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				dragTo(input.Position)
			end
		end)
		bind(UserInputService.InputEnded, function(input)
			if dragging and isPress(input) then
				dragging = nil
				lastRelease = os.clock()
				tween(svCursorScale, 0.2, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
				tween(hueKnobScale, 0.2, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			end
		end)

		local function setColor(c)
			h, sat, v = c:ToHSV()
			refresh()
		end

		for _, sw in ipairs(swatches) do
			bind(sw.btn.MouseButton1Click, function()
				sw.scale.Scale = 0.8
				tween(sw.scale, 0.3, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
				setColor(sw.color)
			end)
		end
		bind(hexBox.Focused, function()
			tween(hexStroke, 0.15, { Color = accentColor })
		end)
		bind(hexBox.FocusLost, function()
			tween(hexStroke, 0.15, { Color = strokeColor })
			local hex = hexBox.Text:gsub("[^%x]", "")
			local ok, c = pcall(Color3.fromHex, hex)
			if ok and c and #hex == 6 then
				setColor(c)
			else
				refresh()
			end
		end)
		tween(popup, 0.5, { Position = mainCenter() }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
		tween(popupScale, 0.55, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
		tween(popup, 0.25, { GroupTransparency = 0 })
		local closing = false

		local function close(instant)
			if closing then
				return
			end
			closing = true
			if openPicker == close then
				openPicker = nil
			end
			for _, c in ipairs(conns) do
				c:Disconnect()
			end
			if instant then
				backdrop:Destroy()
				popup:Destroy()
				return
			end
			tween(backdrop, 0.25, { BackgroundTransparency = 1 })
			tween(popup, 0.32, { Position = anchorCenter() }, Enum.EasingDirection.In, Enum.EasingStyle.Quint)
			tween(popupScale, 0.32, { Scale = 0.05 }, Enum.EasingDirection.In, Enum.EasingStyle.Quint)
			local t = tween(popup, 0.3, { GroupTransparency = 1 }, Enum.EasingDirection.In)
			t.Completed:Connect(function()
				backdrop:Destroy()
				popup:Destroy()
			end)
		end

		bind(popup.MouseEnter, function()
			overPopup = true
		end)
		bind(popup.MouseLeave, function()
			overPopup = false
		end)
		bind(backdrop.MouseButton1Click, function()
			if overPopup or dragging or os.clock() - lastRelease < 0.3 then
				return
			end
			close()
		end)
		bind(lights[1].MouseButton1Click, function()
			setColor(original)
			close()
		end)
		bind(lights[2].MouseButton1Click, function()
			close()
		end)
		bind(lights[3].MouseButton1Click, function()
			setColor(defaultColor)
		end)
		bind(done.MouseButton1Click, function()
			doneScale.Scale = 0.92
			tween(doneScale, 0.2, { Scale = 1 })
			close()
		end)
		return close
	end

	local closeActiveAlert

	local function showAlert(logo2, text, buttonText)
		if closeActiveAlert then
			closeActiveAlert()
		end
		local backdrop = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 159,
			Parent = main,
		})
		addCorner(backdrop, 10)
		tween(backdrop, 0.25, { BackgroundTransparency = 0.45 })
		local card = create("CanvasGroup", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(300, 176),
			BackgroundColor3 = panelColor,
			GroupTransparency = 1,
			ZIndex = 160,
			Parent = main,
		})
		addCorner(card, 14)
		local st = create("UIStroke", { Color = accentColor, Transparency = 0.6, Parent = card })
		addGradient(st)
		local scale = create("UIScale", { Scale = 0.85, Parent = card })
		local alertIcon = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 18),
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = accentColor,
			ZIndex = 161,
			Parent = card,
		})
		makeRound(alertIcon)
		create("TextLabel", {
			Text = "!",
			Font = Enum.Font.GothamBlack,
			TextSize = 22,
			TextColor3 = bgColor,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 162,
			Parent = alertIcon,
		})
		local alertIconScale = create("UIScale", { Scale = 0.4, Parent = alertIcon })
		create("TextLabel", {
			Text = logo2,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = accentColor,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 64),
			Size = UDim2.new(1, -32, 0, 20),
			ZIndex = 161,
			Parent = card,
		})
		create("TextLabel", {
			Text = text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = dimColor,
			TextWrapped = true,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 86),
			Size = UDim2.new(1, -40, 0, 34),
			ZIndex = 161,
			Parent = card,
		})
		local done = create("TextButton", {
			Text = buttonText or "Done",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = bgColor,
			AutoButtonColor = false,
			BackgroundColor3 = accentColor,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -14),
			Size = UDim2.new(1, -32, 0, 30),
			ZIndex = 161,
			Parent = card,
		})
		addCorner(done, 8)
		local doneScale = create("UIScale", { Parent = done })
		connect(done.MouseEnter, function()
			tween(done, 0.15, { BackgroundColor3 = Color3.fromRGB(215, 215, 215) })
		end)
		connect(done.MouseLeave, function()
			tween(done, 0.15, { BackgroundColor3 = accentColor })
		end)
		tween(card, 0.25, { GroupTransparency = 0 })
		tween(scale, 0.45, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
		task.delay(0.12, function()
			tween(alertIconScale, 0.45, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
		end)
		local closed = false

		local function close()
			if closed then
				return
			end
			closed = true
			if closeActiveAlert == close then
				closeActiveAlert = nil
			end
			tween(backdrop, 0.2, { BackgroundTransparency = 1 })
			tween(scale, 0.2, { Scale = 0.9 }, Enum.EasingDirection.In)
			local t = tween(card, 0.2, { GroupTransparency = 1 })
			t.Completed:Connect(function()
				backdrop:Destroy()
				card:Destroy()
			end)
		end

		closeActiveAlert = close
		connect(done.MouseButton1Click, function()
			doneScale.Scale = 0.92
			tween(doneScale, 0.2, { Scale = 1 })
			close()
		end)
		connect(backdrop.MouseButton1Click, close)
	end

	Section.ColorPicker = function(self2, name, desc, default, callback)
		local color = default
		local key = configKey(self2, name)
		local row = self2:_row(name, desc)
		local swatch = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(38, 22),
			BackgroundColor3 = color,
			ZIndex = 2,
			Parent = row,
		})
		addCorner(swatch, 6)
		local outline = addStroke(swatch)
		local swatchScale = create("UIScale", { Parent = swatch })
		local hexLabel = create("TextLabel", {
			Text = "#" .. color:ToHex():upper(),
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = dimColor,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -56, 0.5, 0),
			Size = UDim2.fromOffset(70, 20),
			ZIndex = 2,
			Parent = row,
		})

		local function apply(c, silent)
			color = c
			swatch.BackgroundColor3 = c
			hexLabel.Text = "#" .. c:ToHex():upper()
			setConfig(key, c:ToHex())
			if not silent then
				task.spawn(callback, c)
			end
		end

		connect(row.MouseEnter, function()
			tween(outline, 0.15, { Color = accentColor })
		end)
		connect(row.MouseLeave, function()
			tween(outline, 0.15, { Color = strokeColor })
		end)
		connect(row.MouseButton1Click, function()
			if openPicker then
				openPicker(true)
			end
			swatchScale.Scale = 0.85
			tween(swatchScale, 0.3, { Scale = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			openPicker = openColorPicker(swatch, color, default, function(c)
				apply(c)
			end)
		end)
		register(key, function(v)
			if type(v) ~= "string" then
				return
			end
			local ok, c = pcall(Color3.fromHex, v)
			if ok and c then
				apply(c)
			end
		end, function()
			return color:ToHex()
		end, default:ToHex())
		return {
			Set = function(c, silent)
				apply(c, silent)
			end,
			Get = function()
				return color
			end,
		}
	end

	local menuSeq = 0
	local showMascot
	local mascot = {}
	local onMenuToggled

	local function setMenuOpen(state)
		menuOpen = state
		if showMascot then
			showMascot(state)
		end
		if onMenuToggled then
			onMenuToggled(state)
		end
		if not state and openPicker then
			openPicker(true)
		end
		menuSeq += 1
		local id = menuSeq
		if state then
			main.Visible = true
			tween(mainScale, 0.3, { Scale = responsiveScale }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			tween(blur, 0.3, { Size = blurSize })
			if currentTab then
				task.delay(0.15, function()
					if id == menuSeq then
						playSweep()
					end
				end)
			end
		else
			tween(blur, 0.2, { Size = 0 })
			local t = tween(mainScale, 0.2, { Scale = 0 }, Enum.EasingDirection.In)
			t.Completed:Connect(function()
				if id == menuSeq then
					main.Visible = false
				end
			end)
		end
	end

	local introPlaying = false

	local function toggleMenu()
		if introPlaying then
			return
		end
		setMenuOpen(not menuOpen)
	end

	connect(closeBtn.MouseButton1Click, function()
		setMenuOpen(false)
	end)
	connect(UserInputService.InputBegan, function(input, gameProcessed)
		if keyListener then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local f = keyListener
				keyListener = nil
				f(input.KeyCode)
			end
			return
		end
		if gameProcessed then
			return
		end
		if input.KeyCode == toggleKey then
			toggleMenu()
		end
	end)
	local hud = {}

	local function makeDraggable(inst, key, onClick, onRelease, handle)
		local saved = config[key]
		if type(saved) == "table" and #saved == 4 then
			inst.Position = UDim2.new(saved[1], saved[2], saved[3], saved[4])
		end
		local dragInput, dragStart, startPos, moved
		connect((handle or inst).InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragInput, dragStart, startPos, moved = input, input.Position, inst.Position, false
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if not dragInput then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input ~= dragInput then
				return
			end
			local d = input.Position - dragStart
			if not moved and d.Magnitude < 6 then
				return
			end
			moved = true
			inst.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			local absPos, absSize, vel = inst.AbsolutePosition, inst.AbsoluteSize, gui.AbsoluteSize
			local fx = math.clamp(absPos.X, 0, math.max(0, vel.X - absSize.X)) - absPos.X
			local py = math.clamp(absPos.Y, 0, math.max(0, vel.Y - absSize.Y)) - absPos.Y
			if fx ~= 0 or py ~= 0 then
				inst.Position = inst.Position + UDim2.fromOffset(fx, py)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if not dragInput then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input ~= dragInput then
				return
			end
			dragInput = nil
			if onRelease then
				onRelease()
			end
			if moved then
				local p = inst.Position
				config[key] = { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
				dirty, dirtyAt = true, os.clock()
			elseif onClick then
				onClick()
			end
		end)
	end

	local function setPopVisible(frame, scale, on, targetScale)
		targetScale = targetScale or 1
		frame:SetAttribute("pzOn", on)
		if on then
			frame.Visible = true
			scale.Scale = targetScale * 0.6
			tween(scale, 0.35, { Scale = targetScale }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
		else
			local tween2 = tween(scale, 0.18, { Scale = 0 }, Enum.EasingDirection.In)
			tween2.Completed:Connect(function()
				if not frame:GetAttribute("pzOn") then
					frame.Visible = false
				end
			end)
		end
	end

	local wmGradients = {}
	local wmHolder = create("Frame", {
		Name = "WatermarkHolder",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 62),
		Size = UDim2.fromOffset(320, 36),
		ZIndex = 50,
		Parent = gui,
	})
	local watermark = create("TextButton", {
		Name = "Watermark",
		Text = "",
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = bgColor,
		BackgroundTransparency = 0.04,
		Size = UDim2.fromOffset(0, 36),
		Visible = false,
		ZIndex = 50,
		Parent = wmHolder,
	})
	addCorner(watermark, 10)
	local wmScale = create("UIScale", { Scale = 0, Parent = watermark })
	local watermarkTargetScale = 1
	updateWatermarkResponsive = function()
		local cam = workspace.CurrentCamera
		local viewport = cam and cam.ViewportSize or Vector2.new(1280, 720)
		if UserInputService.TouchEnabled then
			if math.min(viewport.X, viewport.Y) >= 600 then
				watermarkTargetScale = 0.85
			else
				watermarkTargetScale = math.clamp(responsiveScale, 0.58, 0.75)
			end
		else
			watermarkTargetScale = 1
		end
		if watermark:GetAttribute("pzOn") then
			wmScale.Scale = watermarkTargetScale
		end
	end
	updateWatermarkResponsive()
	local wmStroke = create("UIStroke", {
		Color = accentColor,
		Thickness = 1,
		Transparency = 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = watermark,
	})
	table.insert(wmGradients, create("UIGradient", { Parent = wmStroke }))
	create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = watermark })
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 9),
		Parent = watermark,
	})
	local wmOrder = 0

	local function wmItem(className, props)
		wmOrder += 1
		props.LayoutOrder = wmOrder
		if props.BackgroundTransparency == nil then
			props.BackgroundTransparency = 1
		end
		props.BorderSizePixel = 0
		props.ZIndex = props.ZIndex or 51
		props.Parent = props.Parent or watermark
		return create(className, props)
	end

	local function wmDivider()
		return wmItem("Frame", { Size = UDim2.fromOffset(1, 14), BackgroundTransparency = 0, BackgroundColor3 = strokeColor })
	end

	local function wmLabel(width)
		return wmItem("TextLabel", {
			Text = "",
			RichText = true,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromOffset(width, 36),
		})
	end

	local logo2 = wmItem("Frame", { Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 0, BackgroundColor3 = accentColor, ClipsDescendants = true })
	addCorner(logo2, 7)
	table.insert(wmGradients, create("UIGradient", { Rotation = 45, Parent = logo2 }))
	local logoText = create("TextLabel", {
		Text = "rh",
		Font = Enum.Font.GothamBlack,
		TextSize = 12,
		TextColor3 = bgColor,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, -1),
		ZIndex = 52,
		Parent = logo2,
	})
	local brandLabel = wmItem("TextLabel", {
		Text = "ROCK dimas",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = accentColor,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 36),
	})
	table.insert(wmGradients, create("UIGradient", { Parent = brandLabel }))
	wmDivider()
	local fpsLabel = wmLabel(50)
	wmDivider()
	local signalIcon = wmItem("Frame", { Size = UDim2.fromOffset(13, 10) })
	local signalBars = {}
	for i = 1, 3 do
		signalBars[i] = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, (i - 1) * 5, 1, 0),
			Size = UDim2.fromOffset(3, 3 + i * 2.4),
			BackgroundColor3 = hoverColor,
			BorderSizePixel = 0,
			ZIndex = 52,
			Parent = signalIcon,
		})
		addCorner(signalBars[i], 1)
	end
	local pingLabel = wmLabel(44)
	wmDivider()
	local clockLabel = wmLabel(34)
	local function statText(left, right)
		return string.format("<font color=\"#FFFFFF\">%s</font> <font color=\"#787878\">%s</font>", left, right)
	end

	fpsLabel.Text = statText("--", "fps")
	pingLabel.Text = statText("--", "ms")
	clockLabel.Text = "<font color=\"#FFFFFF\">" .. os.date("%H:%M") .. "</font>"
	local menuButton = wmItem("Frame", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
		BackgroundTransparency = 0,
		BackgroundColor3 = elemColor,
	})
	addCorner(menuButton, 7)
	local menuStroke = create("UIStroke", {
		Color = accentColor,
		Transparency = 0.6,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = menuButton,
	})
	create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 10), Parent = menuButton })
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 7),
		Parent = menuButton,
	})
	local burger = create("Frame", {
		Size = UDim2.fromOffset(12, 10),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = menuButton,
	})
	local burgerLines = {}
	for i = 1, 3 do
		burgerLines[i] = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 1 + (i - 1) * 4),
			Size = UDim2.fromOffset(12, 2),
			BackgroundColor3 = textColor,
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = burger,
		})
		makeRound(burgerLines[i])
	end
	local menuLabel = create("TextLabel", {
		Text = "menu",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = textColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(32, 24),
		LayoutOrder = 2,
		ZIndex = 53,
		Parent = menuButton,
	})
	return (function(...)
		local tip = create("Frame", {
			Name = "WatermarkTip",
			AnchorPoint = Vector2.new(1, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = panelColor,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 60,
			Parent = wmHolder,
		})
		addCorner(tip, 8)
		addStroke(tip, hoverColor)
		local tipScale = create("UIScale", { Scale = 0, Parent = tip })
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 7),
			Parent = tip,
		})
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = tip })
		local tipTitle = create("TextLabel", {
			Text = "click to open the menu",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = accentColor,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			ZIndex = 61,
			Parent = tip,
		})
		local tipHint = create("TextLabel", {
			Text = "",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = dimColor,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			ZIndex = 61,
			Parent = tip,
		})
		local tipArrow = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(9, 9),
			Rotation = 45,
			BackgroundColor3 = panelColor,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 59,
			Parent = wmHolder,
		})
		addStroke(tipArrow, hoverColor)
		local wmUsed = config["hud/wm_used"] == true
		local hovering = false
		local tipShown, tipSeq = false, 0

		local function placeTip()
			local x0 = watermark.AbsolutePosition.X
			local relX = menuButton.AbsolutePosition.X - x0
			local y = watermark.AbsoluteSize.Y + 10
			tip.Position = UDim2.fromOffset(relX + menuButton.AbsoluteSize.X + 6, y)
			tipArrow.Position = UDim2.fromOffset(relX + menuButton.AbsoluteSize.X / 2, y)
		end

		local function showTip(on, hideAfter)
			tipSeq += 1
			if on == tipShown then
				if not on then
					return
				end
			else
				tipShown = on
				tipTitle.Text = menuOpen and "click to close the menu" or "click to open the menu"
				tipHint.Text = "drag to move  ·  or press " .. toggleKey.Name
				if on then
					placeTip()
				end
				setPopVisible(tip, tipScale, on)
				tipArrow.Visible = on
			end
			if on and hideAfter then
				local id = tipSeq
				task.delay(hideAfter, function()
					if id == tipSeq and not hovering then
						showTip(false)
					end
				end)
			end
		end

		local function refreshMenuButton()
			local hover = hovering
			tween(wmScale, 0.2, { Scale = watermarkTargetScale * (hover and 1.03 or 1) }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
			tween(wmStroke, 0.2, { Transparency = (hover or menuOpen) and 0 or 0.5 })
			local btnColor = hover and accentColor or (menuOpen and hoverColor or elemColor)
			local fg = hover and bgColor or textColor
			tween(menuButton, 0.2, { BackgroundColor3 = btnColor })
			tween(menuLabel, 0.2, { TextColor3 = fg })
			for _, l in ipairs(burgerLines) do
				tween(l, 0.2, { BackgroundColor3 = fg })
			end
			if wmUsed or hover then
				tween(menuStroke, 0.2, { Transparency = hover and 0 or 0.6 })
			end
		end

		local function animateBurger(open)
			local direction, style = Enum.EasingDirection.Out, Enum.EasingStyle.Quint
			tween(burgerLines[1], 0.35, { Position = UDim2.new(0.5, 0, 0, open and 5 or 1), Rotation = open and 45 or 0 }, direction, style)
			tween(burgerLines[2], 0.25, { Size = UDim2.fromOffset(open and 0 or 12, 2), BackgroundTransparency = open and 1 or 0 }, direction, style)
			tween(burgerLines[3], 0.35, { Position = UDim2.new(0.5, 0, 0, open and 5 or 9), Rotation = open and -45 or 0 }, direction, style)
			menuLabel.Text = open and "close" or "menu"
		end

		connect(watermark.MouseEnter, function()
			hovering = true
			refreshMenuButton()
			local id = tipSeq
			task.delay(0.35, function()
				if hovering and id == tipSeq then
					showTip(true)
				end
			end)
		end)
		connect(watermark.MouseLeave, function()
			hovering = false
			refreshMenuButton()
			showTip(false)
		end)
		connect(watermark.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				tween(wmScale, 0.1, { Scale = watermarkTargetScale * 0.96 })
			end
		end)
		makeDraggable(wmHolder, "hud/watermark_pos", function()
			if not wmUsed then
				wmUsed = true
				config["hud/wm_used"] = true
				dirty, dirtyAt = true, os.clock()
			end
			showTip(false)
			toggleMenu()
		end, function()
			if not UserInputService.MouseEnabled then
				hovering = false
			end
			refreshMenuButton()
		end, watermark)

		hud.setWatermark = function(on)
			if on == (watermark:GetAttribute("pzOn") == true) then
				return
			end
			setPopVisible(watermark, wmScale, on, watermarkTargetScale)
			if not on then
				showTip(false)
			end
		end

		local Stats = game:GetService("Stats")

		local function getPing()
			local ok, ping = pcall(function()
				return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and type(ping) == "number" then
				return ping
			end
			ok, ping = pcall(function()
				return player:GetNetworkPing() * 2000
			end)
			return ok and ping or 0
		end

		local frameCount, fpsClock, lastLevel = 0, os.clock(), -1
		local wmStart = os.clock()
		connect(RunService.RenderStepped, function()
			frameCount += 1
			local now = os.clock()
			if watermark.Visible then
				local t = (now - wmStart) * 0.35
				local seq = shimmerSeq(t)
				for _, g in ipairs(wmGradients) do
					g.Color = seq
				end
				if not wmUsed and not hovering then
					menuStroke.Transparency = 0.15 + 0.55 * (0.5 + 0.5 * math.cos((now - wmStart) * 4))
				end
				if wmScale.Scale > watermarkTargetScale * 0.99 then
					wmHolder.Size = UDim2.fromOffset(watermark.AbsoluteSize.X, watermark.AbsoluteSize.Y)
				end
				if tip.Visible then
					placeTip()
				end
			end
			if now - fpsClock < 0.5 then
				return
			end
			local fps = math.floor(frameCount / (now - fpsClock) + 0.5)
			frameCount, fpsClock = 0, now
			if not watermark.Visible then
				return
			end
			local pingMs = math.floor(getPing() + 0.5)
			fpsLabel.Text = statText(fps, "fps")
			pingLabel.Text = statText(pingMs, "ms")
			clockLabel.Text = "<font color=\"#FFFFFF\">" .. os.date("%H:%M") .. "</font>"
			local lit = pingMs < 90 and 3 or (pingMs < 180 and 2 or 1)
			if lit ~= lastLevel then
				lastLevel = lit
				for i, b in ipairs(signalBars) do
					tween(b, 0.25, { BackgroundColor3 = i <= lit and accentColor or hoverColor })
				end
			end
		end)

		onMenuToggled = function(state)
			animateBurger(state)
			refreshMenuButton()
			if state then
				showTip(false)
			elseif not wmUsed and watermark:GetAttribute("pzOn") then
				task.delay(0.25, function()
					if not menuOpen and not wmUsed then
						showTip(true, 6)
					end
				end)
			end
		end

		local dragging, dragOrigin, startPos
		connect(topBar.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragOrigin = input.Position
				startPos = main.Position
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			if dragSlider then
				dragSlider(input.Position.X)
			elseif dragging then
				local d = input.Position - dragOrigin
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				dragSlider = nil
			end
		end)
		local gradStart, lastGradientUpdate = os.clock(), 0
		connect(RunService.RenderStepped, function()
			if not main.Visible then
				return
			end
			local now = os.clock()
			if now - lastGradientUpdate < 1 / 30 then
				return
			end
			lastGradientUpdate = now
			local t = (now - gradStart) * 0.35
			local seq = shimmerSeq(t)
			for _, g in ipairs(gradients) do
				g.Color = seq
			end
			gradients[1].Rotation = t * 90 % 360
		end)
		do
			local mascots = {
				CoolRock = {
					file = storageFolder .. "/coolrock2.png",
					url = "https://raw.githubusercontent.com/rockscripter/MM2Drone/refs/heads/main/coolrock2.png",
					frames = 45,
					cols = 7,
					cell = 144,
					cropLeft = 8,
					cropRight = 8,
					cropTop = 16,
					cropBottom = 4,
					delay = 0.14,
				},
			}
			local img = create("ImageLabel", {
				Name = "Mascot",
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromOffset(150, 150),
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				ScaleType = Enum.ScaleType.Fit,
				Visible = false,
				ZIndex = 1,
				Parent = gui,
			})
			local cur
			mascot.name = "CoolRock"
			if config["meta/coolrock_default"] ~= true then
				config["meta/coolrock_default"] = true
				config["Settings/Mascot/CoolRock"] = true
				dirty = true
				saveConfig()
				pcall(function()
					if writefile then
						writefile("rockhub_mascot.txt", "CoolRock")
					end
				end)
			else
				pcall(function()
					if isfile and isfile("rockhub_mascot.txt") then
						local v = readfile("rockhub_mascot.txt")
						if v == "Off" or v == "CoolRock" then
							mascot.name = v
						end
					end
				end)
			end

			local cache = {}

			local function loadAsset(name)
				if cache[name] then
					return cache[name]
				end
				local m = mascots[name]
				local getAsset = getcustomasset or getsynasset
				if not m or not getAsset then
					return
				end
				if not (isfile and isfile(m.file)) and m.url and writefile then
					local ok, data = pcall(game.HttpGet, game, m.url)
					if ok and type(data) == "string" and #data > 0 then
						pcall(writefile, m.file, data)
					end
				end
				if not (isfile and isfile(m.file)) then
					return
				end
				local ok, asset = pcall(getAsset, m.file)
				if ok and asset then
					cache[name] = asset
					return asset
				end
			end

			local popValue = Instance.new("NumberValue")
			local hoverValue = Instance.new("NumberValue")
			local popTween
			local popSeq = 0

			showMascot = function(state)
				if not cur then
					return
				end
				popSeq += 1
				local id = popSeq
				if popTween then
					popTween:Cancel()
				end
				if state then
					img.Visible = true
					popValue.Value = 0
					popTween = TweenService:Create(popValue, TweenInfo.new(0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0.2), { Value = 1 })
					popTween:Play()
				else
					popTween = tween(popValue, 0.2, { Value = 0 }, Enum.EasingDirection.In)
					popTween.Completed:Connect(function(st)
						if id == popSeq and st == Enum.PlaybackState.Completed then
							img.Visible = false
						end
					end)
				end
			end

			local loadSeq = 0

			local function loadMascot(name)
				loadSeq += 1
				local id = loadSeq
				task.spawn(function()
					if cur and img.Visible then
						showMascot(false)
						task.wait(0.22)
					end
					if id ~= loadSeq then
						return
					end
					cur = nil
					img.Visible = false
					if name == "Off" then
						return
					end
					local asset = loadAsset(name)
					if id ~= loadSeq or not asset then
						return
					end
					local m = mascots[name]
					img.Image = asset
					local cropLeft, cropTop = m.cropLeft or 0, m.cropTop or 0
					local cropRight, cropBottom = m.cropRight or 0, m.cropBottom or 0
					img.ImageRectOffset = m.frames and Vector2.new(cropLeft, cropTop) or Vector2.zero
					img.ImageRectSize = m.frames and Vector2.new(m.cell - cropLeft - cropRight, m.cell - cropTop - cropBottom) or Vector2.zero
					cur = m
					if menuOpen then
						showMascot(true)
					end
				end)
			end

			mascot.set = function(name)
				if name == mascot.name then
					return
				end
				mascot.name = name
				pcall(function()
					if writefile then
						writefile("rockhub_mascot.txt", name)
					end
				end)
				loadMascot(name)
			end

			connect(img.MouseEnter, function()
				tween(hoverValue, 0.35, { Value = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Back)
			end)
			connect(img.MouseLeave, function()
				tween(hoverValue, 0.3, { Value = 0 })
			end)
			local fx, py, vx, vy = 0, 0, 0, 0
			local rot, rotVel = 0, 0
			local smoothVx = 0
			local lastX
			local dragAmt = 0
			local mascotStart = os.clock()
			connect(RunService.RenderStepped, function(dt)
				if not img.Visible or not cur then
					lastX = nil
					return
				end
				dt = math.min(dt, 0.03333333333333333)
				local t = os.clock() - mascotStart
				local s = mainScale.Scale
				local p = popValue.Value
				local hoverAmt = hoverValue.Value
				local pos, meshSize = main.Position, main.Size
				local menuX, menuY = pos.X.Offset, pos.Y.Offset
				if cur.frames then
					local f = math.floor(t / cur.delay) % cur.frames
					img.ImageRectOffset = Vector2.new(f % cur.cols * cur.cell + (cur.cropLeft or 0), math.floor(f / cur.cols) * cur.cell + (cur.cropTop or 0))
				end
				if not lastX then
					fx, py, vx, vy, rot, rotVel, smoothVx = menuX, menuY, 0, 0, 0, 0, 0
					lastX = menuX
				end
				smoothVx += ((menuX - lastX) / dt - smoothVx) * math.min(dt * 12, 1)
				lastX = menuX
				dragAmt += ((dragging and 1 or 0) - dragAmt) * math.min(dt * 8, 1)
				local h = dt / 2
				for _ = 1, 2 do
					vx += ((menuX - fx) * 170 - vx * 13) * h
					vy += ((menuY - py) * 170 - vy * 13) * h
					fx += vx * h
					py += vy * h
					rotVel += ((math.clamp(-smoothVx * 0.015, -22, 22) - rot) * 120 - rotVel * 9) * h
					rot += rotVel * h
				end
				local lagX = math.clamp(fx - menuX, -10, 10)
				local lagY = math.clamp(py - menuY, -40, 0)
				fx, py = menuX + lagX, math.clamp(py, menuY - 40, menuY)
				local sq = math.clamp(vy * 0.00025, -0.12, 0.12)
				local sx, sy = 1 + sq * 0.6, 1 - sq
				local size = 150 * s * (1 + 0.07 * hoverAmt)
				local w, imgH = size * sx, size * sy
				local left = menuX - meshSize.X.Offset / 2 * s
				local topBar2 = menuY - meshSize.Y.Offset / 2 * s
				local x = left + 58 * s + lagX * p
				local peekY = topBar2 + 13 * s
				local y = peekY - (1 - p) * 70 * s + lagY * p - 6 * hoverAmt * s - 6 * dragAmt * s
				local angle = rot * math.clamp(p, 0, 1) - 4 * hoverAmt
				local r = math.rad(angle)
				x += math.sin(r) * imgH / 2
				y += (1 - math.cos(r)) * imgH / 2
				img.Position = UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)
				img.Size = UDim2.fromOffset(w, imgH)
				img.Rotation = angle
				img.ImageTransparency = math.clamp(1 - p * 3, 0, 1)
			end)
			mascot.name = "CoolRock"
			loadMascot(mascot.name)
		end

		hud.setWatermark(true)

-- SRC Drone-only runtime helpers.
local charMods = { antiFling = false }
local desync = { real = nil, pause = 0, on = false, force = false }
local playerFlingAction
local droneCleanup

local function findTool(p, name)
local char, backpack = p and p.Character, p and p:FindFirstChildOfClass("Backpack")
return char and char:FindFirstChild(name) or backpack and backpack:FindFirstChild(name)
end

local function alive(p)
local char = p and p.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hrp and hum and hum.Health > 0 then
return hrp, hum, char
end
end

local function inLobby(pos)
local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("RegularLobby")
if not lobby then return false end
local ok, cf, size = pcall(lobby.GetBoundingBox, lobby)
if not ok then return false end
local rel = cf:PointToObjectSpace(pos)
local half = size / 2 + Vector3.new(10, 30, 10)
return math.abs(rel.X) <= half.X and math.abs(rel.Y) <= half.Y and math.abs(rel.Z) <= half.Z
end

local function pauseDesync(root)
if desync.real and root and root.Parent then root.CFrame = desync.real end
desync.real = nil
desync.pause += 1
end

local function resumeDesync()
desync.pause = math.max(0, desync.pause - 1)
end

local function disableAntiFling()
	charMods.antiFling = false
end

local function notify(head, body)
local card = create("TextLabel", {
Name = "SRCDroneNotice",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -18, 0, 18),
Size = UDim2.fromOffset(310, 48),
BackgroundColor3 = panelColor,
Text = tostring(head) .. (body and ("\n" .. tostring(body)) or ""),
Font = Enum.Font.Gotham,
TextSize = 12,
TextColor3 = textColor,
TextXAlignment = Enum.TextXAlignment.Left,
TextWrapped = true,
ZIndex = 180,
Parent = gui,
})
addCorner(card, 8)
create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10), Parent = card })
task.delay(2.8, function()
if card.Parent then
local fade = tween(card, 0.2, { TextTransparency = 1, BackgroundTransparency = 1 })
fade.Completed:Connect(function() if card.Parent then card:Destroy() end end)
end
end)
end


local droneTab = addTab("SRC Drone", "drone", "Shahed and FPV drone controls")
		do
			local fling = { busy = false, cancel = false }
			local roleCache, roleCacheAt = {}, 0
			local activeCleanup

			local function refreshRoles()
				if os.clock() - roleCacheAt < 1 then
					return
				end
				roleCacheAt = os.clock()
				local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true)
				if not (remote and remote:IsA("RemoteFunction")) then
					return
				end
				local ok, data = pcall(remote.InvokeServer, remote)
				if not ok or type(data) ~= "table" then
					return
				end
				local nextRoles = {}
				for name, info in pairs(data) do
					if type(info) == "table" and type(info.Role) == "string" and not info.Dead and not info.Killed then
						nextRoles[name] = info.Role
					end
				end
				roleCache = nextRoles
			end

			local function hasRole(p, role)
				if role == "Murderer" and findTool(p, "Knife") then
					return true
				end
				if role == "Sheriff" and findTool(p, "Gun") then
					return true
				end
				local value = roleCache[p.Name]
				return role == "Murderer" and value == "Murderer" or role == "Sheriff" and (value == "Sheriff" or value == "Hero")
			end


			local function impact(pos, color)
				local ring = create("Part", {
					Name = "RockHubFlingImpact",
					Anchored = true,
					CanCollide = false,
					CanQuery = false,
					CanTouch = false,
					CastShadow = false,
					Material = Enum.Material.Neon,
					Color = color,
					Transparency = 0.15,
					Shape = Enum.PartType.Cylinder,
					Size = Vector3.new(0.12, 1, 1),
					CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2),
					Parent = workspace,
				})
				tween(ring, 0.45, { Size = Vector3.new(0.12, 14, 14), Transparency = 1 }, Enum.EasingDirection.Out, Enum.EasingStyle.Quint)
				game:GetService("Debris"):AddItem(ring, 0.5)
			end

			local function flingPlayer(target, role, manual)
				if fling.busy then
					if manual then
						notify("Role Fling", "another fling is already running")
					end
					return false
				end
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local targetChar = target and target.Character
				local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
				local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
				if not (root and hum and hum.Health > 0 and targetRoot and targetHum and targetHum.Health > 0) then
					if manual then
						notify("Role Fling", role:lower() .. " is not available")
					end
					return false
				end
				if targetHum.Sit then
					if manual then
						notify("Role Fling", target.DisplayName .. " is sitting")
					end
					return false
				end

				fling.busy, fling.cancel = true, false
				local desyncWasActive = desync.on or desync.force
				if desyncWasActive then
					pauseDesync(root)
				end
				local savedPivot = char:GetPivot()
				local savedAutoRotate = hum.AutoRotate
				local savedFallenHeight = workspace.FallenPartsDestroyHeight
				local savedSeatedEnabled = hum:GetStateEnabled(Enum.HumanoidStateType.Seated)
				local fallenHeightDisabled = false
				local wasAntiFling = charMods.antiFling == true
				local color = role == "Sheriff" and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(255, 70, 70)
				local highlight = create("Highlight", {
					Name = "RockHubFlingTarget",
					Adornee = targetChar,
					DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
					FillColor = color,
					FillTransparency = 0.65,
					OutlineColor = accentColor,
					OutlineTransparency = 0,
					Parent = targetChar,
				})
				local marker = create("BillboardGui", {
					Name = "RockHubFlingMarker",
					Adornee = targetRoot,
					AlwaysOnTop = true,
					Size = UDim2.fromOffset(150, 30),
					StudsOffset = Vector3.new(0, 3.5, 0),
					Parent = gui,
				})
				create("TextLabel", {
					Text = "FLINGING  ↓",
					Font = Enum.Font.GothamBlack,
					TextSize = 14,
					TextColor3 = color,
					TextStrokeColor3 = Color3.new(),
					TextStrokeTransparency = 0.25,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Parent = marker,
				})
				local bodyVelocity = create("BodyVelocity", {
					Velocity = Vector3.zero,
					MaxForce = Vector3.new(9e9, 9e9, 9e9),
					Parent = root,
				})
				local cleaned = false

				local function cleanup()
					if cleaned then
						return
					end
					cleaned = true
					for _, inst in ipairs({ bodyVelocity, highlight, marker }) do
						if inst and inst.Parent then
							inst:Destroy()
						end
					end
					pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Seated, savedSeatedEnabled)
					if player.Character == char and root.Parent and hum.Health > 0 then
						pcall(function()
							for _ = 1, 6 do
								char:PivotTo(savedPivot * CFrame.new(0, 0.5, 0))
								for _, part in ipairs(char:GetChildren()) do
									if part:IsA("BasePart") then
										part.AssemblyLinearVelocity = Vector3.zero
										part.AssemblyAngularVelocity = Vector3.zero
									end
								end
								if (root.Position - savedPivot.Position).Magnitude < 25 then
									break
								end
								RunService.Heartbeat:Wait()
							end
							hum.AutoRotate = savedAutoRotate
							hum:ChangeState(Enum.HumanoidStateType.GettingUp)
						end)
					end
					if fallenHeightDisabled then
						pcall(function()
							workspace.FallenPartsDestroyHeight = savedFallenHeight
						end)
					end
					if wasAntiFling then
						charMods.antiFling = true
					end
					if desyncWasActive then
						resumeDesync()
					end
					fling.busy = false
					activeCleanup = nil
				end

				activeCleanup = cleanup
				if wasAntiFling then
					disableAntiFling()
				end
				hum.AutoRotate = false
				fallenHeightDisabled = pcall(function()
					workspace.FallenPartsDestroyHeight = 0 / 0
				end)
				if not fallenHeightDisabled then
					cleanup()
					if manual then
						notify("Role Fling", "executor cannot disable FallenPartsDestroyHeight")
					end
					return false
				end
				pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Seated, false)
				pcall(function()
					if sethiddenproperty then
						sethiddenproperty(player, "SimulationRadius", math.huge)
					end
				end)

				local started = os.clock()
				local lastPos = targetRoot.Position
				local launchOrigin = lastPos
				local launched = false
				local targetPart = targetRoot or targetChar:FindFirstChild("Head") or targetChar:FindFirstChildWhichIsA("BasePart")

				local function targetEscaped()
					if not targetPart.Parent then
						return false
					end
					lastPos = targetPart.Position
					local distance = (lastPos - launchOrigin).Magnitude
					local speed = targetPart.AssemblyLinearVelocity.Magnitude
					return lastPos.Y <= savedFallenHeight + 30 or distance > 350 or distance > 120 and speed > 200
				end

				-- Fling sequence adapted from K1LAS1K/Ultimate-Fling-GUI.
				local function flingPosition(pos, angle)
					local cf = CFrame.new(targetPart.Position) * pos * angle
					root.CFrame = cf
					char:PivotTo(cf)
					root.Velocity = Vector3.new(9e7, 9e8, 9e7)
					root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
				end

				local ok, err = pcall(function()
					local angle = 0
					while os.clock() - started < 2 and not fling.cancel do
						if not (root.Parent and hum.Health > 0 and targetPart.Parent and targetHum.Health > 0) then
							break
						end
						if targetEscaped() then
							launched = true
							break
						end
						local speed = targetPart.AssemblyLinearVelocity.Magnitude
						angle += 100
						local steps
						if speed < 50 then
							local lead = targetHum.MoveDirection * speed / 1.25
							local rotation = CFrame.Angles(math.rad(angle), 0, 0)
							steps = {
								{ CFrame.new(0, 1.5, 0) + lead, rotation },
								{ CFrame.new(0, -1.5, 0) + lead, rotation },
								{ CFrame.new(0, 1.5, 0) + lead, rotation },
								{ CFrame.new(0, -1.5, 0) + lead, rotation },
								{ CFrame.new(0, 1.5, 0) + targetHum.MoveDirection, rotation },
								{ CFrame.new(0, -1.5, 0) + targetHum.MoveDirection, rotation },
							}
						else
							local flat, quarter = CFrame.new(), CFrame.Angles(math.rad(90), 0, 0)
							steps = {
								{ CFrame.new(0, 1.5, targetHum.WalkSpeed), quarter },
								{ CFrame.new(0, -1.5, -targetHum.WalkSpeed), flat },
								{ CFrame.new(0, 1.5, targetHum.WalkSpeed), quarter },
								{ CFrame.new(0, -1.5, 0), quarter },
								{ CFrame.new(0, -1.5, 0), flat },
								{ CFrame.new(0, -1.5, 0), quarter },
								{ CFrame.new(0, -1.5, 0), flat },
							}
						end
						for _, step in ipairs(steps) do
							flingPosition(step[1], step[2])
							task.wait()
							if fling.cancel or targetEscaped() then
								launched = not fling.cancel
								break
							end
						end
						if launched then
							break
						end
					end
				end)
				cleanup()
				if ok and launched and lastPos then
					impact(lastPos, color)
				end
				if manual then
					if ok and launched then
						notify("Fling " .. role, target.DisplayName .. " flung down")
					elseif ok then
						notify("Role Fling", "target resisted the fling")
					else
						notify("Role Fling", "failed: " .. tostring(err))
					end
				end
				return ok and launched
			end

playerFlingAction = function(target)
local role = hasRole(target, "Sheriff") and "Sheriff" or (hasRole(target, "Murderer") and "Murderer" or "Player")
return flingPlayer(target, role, true)
end
end
		do
			local killing = false
			local cancelKill = false

			local function getTargets(sheriffOnly, origin, includeLobby)
				local list = {}
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player then
						local hrp = alive(p)
						if hrp and (includeLobby or not inLobby(hrp.Position)) then
							local gun = findTool(p, "Gun") ~= nil
							if not sheriffOnly or gun then
								table.insert(list, { p = p, gun = gun, d = (hrp.Position - origin).Magnitude })
							end
						end
					end
				end
				table.sort(list, function(a, b)
					if a.gun ~= b.gun then
						return a.gun
					end
					return a.d < b.d
				end)
				return list
			end

			local function getKnife(hum)
				local char = player.Character
				local knife = char and char:FindFirstChild("Knife")
				if knife then
					return knife
				end
				local backpack = player:FindFirstChildOfClass("Backpack")
				knife = backpack and backpack:FindFirstChild("Knife")
				if knife then
					hum:EquipTool(knife)
					for _ = 1, 10 do
						if knife.Parent == char then
							break
						end
						RunService.Heartbeat:Wait()
					end
					return knife
				end
			end

			local function hit(knife, char)
				pcall(function()
					knife:Activate()
				end)
				local handle = knife:FindFirstChild("Handle")
				if handle and firetouchinterest then
					for _, n in ipairs({ "HumanoidRootPart", "UpperTorso", "Torso", "Head" }) do
						local part = char:FindFirstChild(n)
						if part then
							firetouchinterest(handle, part, 0)
							firetouchinterest(handle, part, 1)
						end
					end
				end
			end

			local function makeStandIn(char)
				local old = char.Archivable
				char.Archivable = true
				local ok, clone = pcall(function()
					return char:Clone()
				end)
				char.Archivable = old
				if not ok or not clone then
					return
				end
				for _, d in ipairs(clone:GetDescendants()) do
					if d:IsA("LuaSourceContainer") or d:IsA("Sound") then
						d:Destroy()
					elseif d:IsA("BasePart") then
						d.Anchored = true
						d.CanCollide = false
						d.CanQuery = false
						d.CanTouch = false
					elseif d:IsA("Humanoid") then
						d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					end
				end
				clone.Name = "RockHubStandIn"
				clone.Parent = workspace.CurrentCamera
				return clone
			end

			local function hideChar(char, on)
				for _, d in ipairs(char:GetDescendants()) do
					if d:IsA("BasePart") or d:IsA("Decal") then
						d.LocalTransparencyModifier = on and 1 or 0
					end
				end
			end

			local function killAll(sheriffOnly, silent, onlyList)
				if killing then
					return
				end
				local hrp, hum, char = alive(player)
				if not hrp then
					return
				end
				if not findTool(player, "Knife") then
					if not silent then
						notify("Kill All", "you're not the murderer")
					end
					return
				end
				local list = getTargets(sheriffOnly, hrp.Position, onlyList ~= nil)
				if onlyList then
					local filtered = {}
					for _, e in ipairs(list) do
						if table.find(onlyList, e.p) then
							table.insert(filtered, e)
						end
					end
					list = filtered
				end
				if #list == 0 then
					if not silent then
						notify("Kill All", sheriffOnly and "no sheriff in the round" or "nobody to kill")
					end
					return
				end
				killing, cancelKill = true, false
				pauseDesync(hrp)
				local savedCF = hrp.CFrame
				local gradStart2 = os.clock()
				local cam = workspace.CurrentCamera
				local oldCamType, camCF = cam.CameraType, cam.CFrame
				local standIn = makeStandIn(char)
				cam.CameraType = Enum.CameraType.Scriptable
				cam.CFrame = camCF
				local knife = getKnife(hum)
				local target
				local stepConn = RunService.Stepped:Connect(function()
					cam.CFrame = camCF
					if hrp.Parent then
						hideChar(char, true)
						if target then
							hrp.CFrame = target
							hrp.AssemblyLinearVelocity = Vector3.zero
						end
					end
				end)
				local left = #list
				while left > 0 and os.clock() - gradStart2 < 2 do
					if cancelKill or hum.Health <= 0 or not hrp.Parent then
						break
					end
					left = 0
					for _, e in ipairs(list) do
						local th, _, targetChar = alive(e.p)
						if th and not cancelKill then
							left += 1
							local behind = th.CFrame * CFrame.new(0, 0, 1.4)
							target = CFrame.lookAt(behind.Position, th.Position)
							hrp.CFrame = target
							hrp.AssemblyLinearVelocity = Vector3.zero
							knife = knife and knife.Parent and knife or getKnife(hum)
							if knife then
								hit(knife, targetChar)
							end
							RunService.Heartbeat:Wait()
							if knife then
								hit(knife, targetChar)
							end
						end
					end
				end
				target = nil
				stepConn:Disconnect()
				if hrp.Parent and hum.Health > 0 then
					hrp.CFrame = savedCF
					hrp.AssemblyLinearVelocity = Vector3.zero
				end
				RunService.Heartbeat:Wait()
				if char.Parent then
					hideChar(char, false)
				end
				if standIn then
					standIn:Destroy()
				end
				cam.CameraType = oldCamType
				if hum.Parent then
					cam.CameraSubject = hum
				end
				local killed = 0
				for _, e in ipairs(list) do
					if not alive(e.p) then
						killed += 1
					end
				end
				killing = false
				resumeDesync()
				if not onlyList then
					notify("Kill All", ("killed %d/%d in %.2fs"):format(killed, #list, os.clock() - gradStart2))
				end
			end

			local shahedIds = { 120141614672192, 111443745475294, 16531510943 }
			local shahedFlip = { [120141614672192] = -1 }
			local soundIds = {
				engine = { 106621472307027, 117678889994053, 86747216998490 },
				boom = { 125127520917980, 7157159568, 9126102254 },
				rumble = { 1843024924, 9846227426, 138432031406888 },
				static = { 96891705634188, 83265726239905, 128865910652923 },
				fpv = { 114037851906101, 78411105609654, 122096583027065 },
			}
			local fpvIds = { 124994246147928, 129274863429961, 79445961621887 }
			local fpvFlip = {}
			local droneKind = "Shahed"
			local droneImpact = "Fling"
			local droneCache = {}
			local droneTemplate, droneLoading
			local soundCache = {}
			local soundsLoading = false
			local ContentProvider = game:GetService("ContentProvider")
			local SoundService = game:GetService("SoundService")

			local function getParts(m)
				local parts = {}
				for _, x in ipairs(m:GetDescendants()) do
					if x:IsA("BasePart") then
						table.insert(parts, x)
					end
				end
				return parts
			end

			local function buildShahed()
				local m = Instance.new("Model")
				local col = Color3.fromRGB(92, 96, 100)

				local function part(className, size, cf, color, shape)
					local p = Instance.new(className)
					p.Size, p.CFrame = size, cf
					p.Color = color or col
					p.Material = Enum.Material.SmoothPlastic
					if shape then
						p.Shape = shape
					end
					p.Parent = m
					return p
				end

				local rot90 = CFrame.Angles(0, math.rad(90), 0)
				part("Part", Vector3.new(9.6, 1.3, 1.3), CFrame.new(0, 0, 0.2) * rot90, nil, Enum.PartType.Cylinder)
				part("Part", Vector3.new(1.3, 1.3, 1.3), CFrame.new(0, 0, -4.6), nil, Enum.PartType.Ball)
				part("Part", Vector3.new(0.5, 0.9, 0.9), CFrame.new(0, 0, 5.2) * rot90, Color3.fromRGB(40, 40, 40), Enum.PartType.Cylinder)
				part("Part", Vector3.new(0.12, 3.2, 0.3), CFrame.new(0, 0, 5.5), Color3.fromRGB(30, 30, 30)).Name = "Prop"
				part("WedgePart", Vector3.new(0.25, 4.9, 7.5), CFrame.fromMatrix(Vector3.new(3.05, 0, 0.75), Vector3.new(0, -1, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1)))
				part("WedgePart", Vector3.new(0.25, 4.9, 7.5), CFrame.fromMatrix(Vector3.new(-3.05, 0, 0.75), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1)))
				part("Part", Vector3.new(0.2, 1.8, 1.4), CFrame.new(5.45, 0.4, 3.9))
				part("Part", Vector3.new(0.2, 1.8, 1.4), CFrame.new(-5.45, 0.4, 3.9))
				m.WorldPivot = CFrame.new()
				return m
			end

			local function orientShahed(m, parts, id)
				local lo, hi = Vector3.one * math.huge, -Vector3.one * math.huge
				local boxes = {}
				for _, p in ipairs(parts) do
					local cf, h = p.CFrame, p.Size / 2
					local r = Vector3.new(math.abs(cf.RightVector.X) * h.X + math.abs(cf.UpVector.X) * h.Y + math.abs(cf.LookVector.X) * h.Z, math.abs(cf.RightVector.Y) * h.X + math.abs(cf.UpVector.Y) * h.Y + math.abs(cf.LookVector.Y) * h.Z, math.abs(cf.RightVector.Z) * h.X + math.abs(cf.UpVector.Z) * h.Y + math.abs(cf.LookVector.Z) * h.Z)
					lo, hi = lo:Min(cf.Position - r), hi:Max(cf.Position + r)
					table.insert(boxes, { cf.Position, r })
				end
				local size, center = hi - lo, (lo + hi) / 2
				local axis, sidebar2 = Vector3.xAxis, Vector3.zAxis
				if size.Z > size.X then
					axis, sidebar2 = Vector3.zAxis, Vector3.xAxis
				end
				local moment = 0
				for _, b in ipairs(boxes) do
					local a = b[2]:Dot(axis) * b[2]:Dot(sidebar2)
					moment += (b[1] - center):Dot(axis) * a
				end
				local sign = moment >= 0 and 1 or -1
				if shahedFlip[id] then
					sign = shahedFlip[id]
				end
				m.WorldPivot = CFrame.lookAt(center, center - axis * sign)
				return math.max(size.X, size.Z)
			end

			local function buildFpv()
				local m = Instance.new("Model")

				local function part(size, cf, color, shape, mat)
					local p = Instance.new("Part")
					p.Size, p.CFrame = size, cf
					p.Color = color
					p.Material = mat or Enum.Material.SmoothPlastic
					if shape then
						p.Shape = shape
					end
					p.Parent = m
					return p
				end

				local dark = Color3.fromRGB(28, 28, 30)
				part(Vector3.new(0.9, 0.25, 1.5), CFrame.new(), dark)
				for _, a in ipairs({ 45, 135, 225, 315 }) do
					local r = math.rad(a)
					local tip2 = Vector3.new(math.sin(r) * 1.45, 0, math.cos(r) * 1.45)
					part(Vector3.new(0.18, 0.1, 2.9), CFrame.lookAt(Vector3.zero, tip2) * CFrame.new(0, 0, -1.45), dark)
					part(Vector3.new(0.3, 0.32, 0.32), CFrame.new(tip2 + Vector3.new(0, 0.18, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 120, 70), Enum.PartType.Cylinder, Enum.Material.Metal)
					local prop = part(Vector3.new(0.04, 1.3, 1.3), CFrame.new(tip2 + Vector3.new(0, 0.36, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(20, 20, 20), Enum.PartType.Cylinder)
					prop.Transparency = 0.55
					prop.Name = "Prop"
				end
				part(Vector3.new(0.6, 0.45, 1.1), CFrame.new(0, 0.38, 0.1), Color3.fromRGB(40, 90, 170))
				part(Vector3.new(0.35, 0.3, 0.3), CFrame.new(0, 0.25, -0.75), Color3.fromRGB(15, 15, 15))
				part(Vector3.new(2.2, 0.55, 0.55), CFrame.new(0, -0.4, -0.7) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(110, 90, 55), Enum.PartType.Cylinder, Enum.Material.Metal)
				part(Vector3.new(0.5, 0.5, 0.5), CFrame.new(0, -0.4, -1.8), Color3.fromRGB(200, 200, 190), Enum.PartType.Ball)
				m.WorldPivot = CFrame.new()
				return m
			end

			local function orientFpv(m, parts, id)
				local lo, hi = Vector3.one * math.huge, -Vector3.one * math.huge
				for _, p in ipairs(parts) do
					local cf, h = p.CFrame, p.Size / 2
					local r = Vector3.new(math.abs(cf.RightVector.X) * h.X + math.abs(cf.UpVector.X) * h.Y + math.abs(cf.LookVector.X) * h.Z, math.abs(cf.RightVector.Y) * h.X + math.abs(cf.UpVector.Y) * h.Y + math.abs(cf.LookVector.Y) * h.Z, math.abs(cf.RightVector.Z) * h.X + math.abs(cf.UpVector.Z) * h.Y + math.abs(cf.LookVector.Z) * h.Z)
					lo, hi = lo:Min(cf.Position - r), hi:Max(cf.Position + r)
				end
				local size, center = hi - lo, (lo + hi) / 2
				local best, bestScore, axis = nil, 0, Vector3.zAxis
				for _, p in ipairs(parts) do
					local sz = p.Size
					local longest = math.max(sz.X, sz.Y, sz.Z)
					local shortest = math.min(sz.X, sz.Y, sz.Z)
					local score = longest * longest * shortest / math.max(shortest, 0.05)
					if longest / math.max(shortest, 0.05) > 2.2 and score > bestScore then
						local cf = p.CFrame
						local longAxis = sz.X == longest and cf.RightVector or sz.Y == longest and cf.UpVector or cf.LookVector
						if math.abs(longAxis.Y) < 0.5 then
							best, bestScore = p, score
						end
					end
				end
				local sign = 1
				if best then
					local sz, cf = best.Size, best.CFrame
					local longAxis = sz.X == math.max(sz.X, sz.Y, sz.Z) and cf.RightVector or sz.Y == math.max(sz.X, sz.Y, sz.Z) and cf.UpVector or cf.LookVector
					axis = math.abs(longAxis.X) > math.abs(longAxis.Z) and Vector3.xAxis or Vector3.zAxis
					local half = math.max(sz.X, sz.Y, sz.Z) / 2
					local c = (cf.Position - center):Dot(axis)
					local endA, endB = c + half * math.abs(longAxis:Dot(axis)), c - half * math.abs(longAxis:Dot(axis))
					sign = math.abs(endA) >= math.abs(endB) and -1 or 1
				end
				if fpvFlip[id] then
					sign = fpvFlip[id]
				end
				m.WorldPivot = CFrame.lookAt(center, center - axis * sign)
				return math.max(size.X, size.Z)
			end

			local function pickSound(list)
				for _, id in ipairs(list) do
					local s = Instance.new("Sound")
					s.SoundId = "rbxassetid://" .. id
					s.Volume = 0
					s.Parent = SoundService
					local loaded = false
					local ok = pcall(function()
						ContentProvider:PreloadAsync({ s }, function(_, status)
							loaded = status == Enum.AssetFetchStatus.Success
						end)
					end)
					s:Destroy()
					if ok and loaded then
						return "rbxassetid://" .. id
					end
				end
				return "rbxassetid://" .. list[1]
			end

			local function ensureSounds()
				while soundsLoading do
					task.wait()
				end
				for key in pairs(soundIds) do
					if not soundCache[key] then
						soundsLoading = true
						for nextKey, list in pairs(soundIds) do
							if not soundCache[nextKey] then
								soundCache[nextKey] = pickSound(list)
							end
						end
						soundsLoading = false
						break
					end
				end
			end

			local function loadDrone(override)
				while droneLoading do
					task.wait(0.1)
				end
				local kind = override or droneKind
				ensureSounds()
				if droneCache[kind] then
					droneTemplate = droneCache[kind]
					return droneTemplate
				end
				droneLoading = true
				local isFpv = kind == "FPV"
				local m, usedId
				for _, id in ipairs(isFpv and fpvIds or shahedIds) do
					usedId = id
					local ok, objs = pcall(function()
						return game:GetObjects("rbxassetid://" .. id)
					end)
					if ok and objs and #objs > 0 then
						m = Instance.new("Model")
						for _, o in ipairs(objs) do
							o.Parent = m
						end
						for _, x in ipairs(m:GetDescendants()) do
							if x:IsA("LuaSourceContainer") or x:IsA("Sound") or x:IsA("ClickDetector") or x:IsA("ProximityPrompt") or x:IsA("Humanoid") or x:IsA("BillboardGui") then
								x:Destroy()
							end
						end
						if m:FindFirstChildWhichIsA("BasePart", true) then
							break
						end
						m:Destroy()
						m = nil
					end
				end
				local extent
				if m then
					extent = (isFpv and orientFpv or orientShahed)(m, getParts(m), usedId)
				elseif isFpv then
					m = buildFpv()
					extent = 4
				else
					m = buildShahed()
					extent = 11
				end
				pcall(function()
					m:ScaleTo(m:GetScale() * (isFpv and 3 or 5) / math.max(extent, 0.1))
				end)
				m.Archivable = true
				for _, x in ipairs(m:GetDescendants()) do
					x.Archivable = true
				end
				for _, p in ipairs(getParts(m)) do
					p.Anchored = true
					p.CanCollide = false
					p.CanQuery = false
					p.CanTouch = false
				end
				m.Name = "RockHubShahed"
				droneCache[kind] = m
				droneTemplate = droneCache[droneKind]
				droneLoading = false
				return m
			end

			local function playSound(key, parent, props)
				local soundId = soundCache[key]
				if not soundId then
					return
				end
				local s = Instance.new("Sound")
				s.SoundId = soundId
				for k, v in pairs(props) do
					s[k] = v
				end
				s.Parent = parent
				s:Play()
				if not s.IsLoaded then
					task.spawn(function()
						local deadline = os.clock() + 3
						while s.Parent and not s.IsLoaded and os.clock() < deadline do
							task.wait(0.05)
						end
						if s.Parent and not s.IsPlaying then
							s:Play()
						end
					end)
				end
				return s
			end

			local function shakeCamera(intensity, hideAfter)
				local name = "RockHubShahedShake" .. math.random(1000000)
				local gradStart2, last = os.clock(), CFrame.new()
				RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, function()
					local cam = workspace.CurrentCamera
					local k = 1 - (os.clock() - gradStart2) / hideAfter
					if k <= 0 then
						cam.CFrame = cam.CFrame * last:Inverse()
						RunService:UnbindFromRenderStep(name)
						return
					end
					local a = intensity * k * k
					local offset = CFrame.Angles((math.random() - 0.5) * a, (math.random() - 0.5) * a, (math.random() - 0.5) * a * 0.5)
					cam.CFrame = cam.CFrame * last:Inverse() * offset
					last = offset
				end)
			end

			local function explode(pos)
				local fx = Instance.new("Part")
				fx.Anchored, fx.CanCollide, fx.CanQuery, fx.CanTouch = true, false, false, false
				fx.Transparency, fx.Size, fx.Position = 1, Vector3.one, pos
				fx.Parent = workspace.CurrentCamera
				local e = Instance.new("Explosion")
				e.Position, e.BlastPressure, e.BlastRadius = pos, 0, 0
				e.DestroyJointRadiusPercent = 0
				e.ExplosionType = Enum.ExplosionType.NoCraters
				e.Parent = workspace

				local function emit(props, n)
					local emitter = Instance.new("ParticleEmitter")
					emitter.Enabled = false
					for k, v in pairs(props) do
						emitter[k] = v
					end
					emitter.Parent = fx
					emitter:Emit(n)
				end

				emit({
					Texture = "rbxasset://textures/particles/fire_main.dds",
					Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 80, 20)),
					LightEmission = 1,
					Lifetime = NumberRange.new(0.35, 0.7),
					Speed = NumberRange.new(25, 55),
					SpreadAngle = Vector2.new(180, 180),
					Drag = 6,
					Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 14) }),
					Transparency = NumberSequence.new(0.1, 1),
				}, 60)
				emit({
					Texture = "rbxasset://textures/particles/smoke_main.dds",
					Color = ColorSequence.new(Color3.fromRGB(60, 55, 50), Color3.fromRGB(25, 25, 25)),
					Lifetime = NumberRange.new(2.5, 4.5),
					Speed = NumberRange.new(8, 22),
					SpreadAngle = Vector2.new(180, 180),
					Drag = 2,
					Acceleration = Vector3.new(0, 6, 0),
					Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 22) }),
					Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }),
					RotSpeed = NumberRange.new(-40, 40),
					Rotation = NumberRange.new(0, 360),
				}, 35)
				emit({
					Texture = "rbxasset://textures/particles/sparkles_main.dds",
					Color = ColorSequence.new(Color3.fromRGB(255, 190, 90)),
					LightEmission = 1,
					Lifetime = NumberRange.new(0.6, 1.4),
					Speed = NumberRange.new(60, 110),
					SpreadAngle = Vector2.new(180, 180),
					Acceleration = Vector3.new(0, -60, 0),
					Size = NumberSequence.new(0.6, 0),
				}, 80)
				local light = Instance.new("PointLight")
				light.Color, light.Brightness, light.Range = Color3.fromRGB(255, 160, 70), 10, 60
				light.Parent = fx
				game:GetService("TweenService"):Create(light, TweenInfo.new(0.8), { Brightness = 0 }):Play()
				playSound("boom", fx, { Volume = 2, RollOffMinDistance = 20, RollOffMaxDistance = 1500 })
				playSound("rumble", fx, { Volume = 1.2, RollOffMinDistance = 60, RollOffMaxDistance = 3000 })
				local cam = workspace.CurrentCamera
				local d = (cam.CFrame.Position - pos).Magnitude
				if d < 200 then
					shakeCamera(0.06 * (1 - d / 200) + 0.01, 0.7)
				end
				game:GetService("Debris"):AddItem(fx, 7)
				game:GetService("Debris"):AddItem(e, 3)
			end

			local function showSignalLost(targetName, flightTime)
				local font = Enum.Font.Code
				local root = create("CanvasGroup", {
					Name = "RockHubSignalLost",
					Position = UDim2.fromOffset(0, -100),
					Size = UDim2.new(1, 0, 1, 200),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ZIndex = 50,
					Parent = gui,
				})
				local content2 = create("Frame", {
					Position = UDim2.fromOffset(0, 100),
					Size = UDim2.new(1, 0, 1, -200),
					BackgroundTransparency = 1,
					ZIndex = 52,
					Parent = root,
				})

				local function label(props)
					do
						local defaults = {}
						defaults[63741] = {
							function()
								return props
							end,
							"BackgroundTransparency",
							function()
								return 1
							end,
						}
						defaults[49931] = {
							function()
								return props
							end,
							"Parent",
							function()
								return props.Parent or content2
							end,
						}
						defaults[17390] = {
							function()
								return props
							end,
							"TextColor3",
							function()
								return props.TextColor3 or Color3.fromRGB(235, 235, 235)
							end,
						}
						defaults[59406] = {
							function()
								return props
							end,
							"Font",
							function()
								return props.Font or font
							end,
						}
						defaults[4207] = {
							function()
								return props
							end,
							"ZIndex",
							function()
								return 53
							end,
						}
						local order = { 63741, 59406, 17390, 4207, 49931 }
						for j = 1, #order do
							local entry = defaults[order[j]]
							entry[1]()[entry[2]] = entry[3]()
						end
					end
					return create("TextLabel", props)
				end

				local bars = {}
				for i = 1, 42 do
					bars[i] = create("Frame", {
						Position = UDim2.new(0, 0, (i - 1) / 42, 0),
						Size = UDim2.new(1.3, 0, 0.023809523809523808, 1),
						BorderSizePixel = 0,
						ZIndex = 51,
						Visible = false,
						Parent = root,
					})
				end
				for i = 0, 59 do
					create("Frame", {
						Position = UDim2.new(0, 0, i / 60, 0),
						Size = UDim2.new(1, 0, 0, 1),
						BackgroundColor3 = Color3.new(0, 0, 0),
						BackgroundTransparency = 0.75,
						BorderSizePixel = 0,
						ZIndex = 55,
						Parent = root,
					})
				end
				local box = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(380, 92),
					BackgroundTransparency = 1,
					Visible = false,
					ZIndex = 53,
					Parent = content2,
				})
				create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Parent = box })
				local titleLabel = label({ Size = UDim2.fromScale(1, 1), Text = "SIGNAL LOST", TextSize = 46, Parent = box })
				local noVideoLabel = label({
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 0.5, -58),
					Size = UDim2.fromOffset(300, 20),
					Text = "/!\\  NO VIDEO",
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255, 60, 50),
					Visible = false,
				})
				local subtitle = label({
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0.5, 58),
					Size = UDim2.fromOffset(500, 20),
					TextSize = 15,
					Visible = false,
					Text = targetName and "TARGET  " .. targetName:upper() .. "  -  HIT" or "NO TARGET",
					TextColor3 = targetName and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(170, 170, 170),
				})
				local secs = math.floor(flightTime)
				local corners = {
					label({
						Position = UDim2.fromOffset(28, 22),
						Size = UDim2.fromOffset(300, 18),
						TextSize = 15,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = droneKind == "FPV" and "FPV KAMIKAZE   CAM 1" or "SHAHED-136   CAM 1",
					}),
					label({
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -28, 0, 22),
						Size = UDim2.fromOffset(300, 18),
						TextSize = 15,
						TextXAlignment = Enum.TextXAlignment.Right,
						Text = ("REC  00:%02d:%02d"):format(secs // 60, secs % 60),
						TextColor3 = Color3.fromRGB(255, 60, 50),
					}),
					label({
						Position = UDim2.new(0, 28, 1, -40),
						Size = UDim2.fromOffset(300, 18),
						TextSize = 15,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = "CH 5.8G   RSSI  0%",
					}),
					label({
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -28, 1, -40),
						Size = UDim2.fromOffset(300, 18),
						TextSize = 15,
						TextXAlignment = Enum.TextXAlignment.Right,
						Text = "LINK  --.-  dB",
					}),
				}
				for _, c in ipairs(corners) do
					c.Visible = false
				end
				local staticSound = playSound("static", workspace.CurrentCamera, { Volume = 0.8 })
				local gradStart2 = os.clock()
				local conn
				conn = RunService.RenderStepped:Connect(function()
					local t = os.clock() - gradStart2
					if t < 0.07 then
						return
					elseif t < 0.6 then
						root.BackgroundColor3 = Color3.new(0, 0, 0)
						for _, b in ipairs(bars) do
							local g = math.random()
							b.Visible = true
							b.BackgroundColor3 = Color3.new(g, g, g)
							b.BackgroundTransparency = math.random() * 0.35
							b.Position = UDim2.new(-math.random() * 0.3, 0, b.Position.Y.Scale, 0)
						end
					else
						if staticSound and staticSound.IsPlaying then
							staticSound:Stop()
						end
						box.Visible = true
						noVideoLabel.Visible = true
						subtitle.Visible = true
						for _, c in ipairs(corners) do
							c.Visible = true
						end
						for _, b in ipairs(bars) do
							b.Visible = math.random() < 0.03
							if b.Visible then
								local g = math.random() * 0.5
								b.BackgroundColor3 = Color3.new(g, g, g)
								b.BackgroundTransparency = 0.6
							end
						end
						local on = t * 2.2 % 1 < 0.62
						titleLabel.TextTransparency = on and 0 or 0.85
						noVideoLabel.TextTransparency = on and 0 or 0.6
						box.Position = UDim2.new(0.5, math.random() < 0.06 and math.random(-6, 6) or 0, 0.5, 0)
					end
				end)
				task.delay(2.15, function()
					TweenService:Create(root, TweenInfo.new(0.3), { GroupTransparency = 1 }):Play()
					task.wait(0.32)
					conn:Disconnect()
					root:Destroy()
					if staticSound then
						staticSound:Destroy()
					end
				end)
			end

			local function finishTarget(p)
				local t = os.clock()
				while killing and os.clock() - t < 2 do
					RunService.Heartbeat:Wait()
				end
				if alive(p) then
					killAll(false, true, { p })
				end
			end

			local droneBusy = false
			local desyncPaused = false

			local function launchDrone2()
				if droneBusy then
					return
				end
				local hrp, hum, char = alive(player)
				if not hrp then
					return
				end
				local impactMode = droneImpact
				if impactMode == "Kill" and not findTool(player, "Knife") then
					notify("Drone", "Kill impact requires the murderer knife")
					return
				end
				if not droneTemplate then
					notify("Shahed", "loading the drone...")
					loadDrone()
				end
				if not alive(player) then
					return
				end
				droneBusy = true
				pcall(function()
					hum:UnequipTools()
				end)
				local controls
				task.spawn(function()
					pcall(function()
						local c = require(player.PlayerScripts:WaitForChild("PlayerModule", 1)):GetControls()
						c:Disable()
						controls = c
					end)
				end)
				local oldWalkSpeed, oldJumpPower = hum.WalkSpeed, hum.JumpPower
				hum.WalkSpeed, hum.JumpPower = 0, 0
				local cam = workspace.CurrentCamera
				local oldCamType = cam.CameraType
				cam.CameraType = Enum.CameraType.Scriptable
				local oldMouse, oldIconEnabled = UserInputService.MouseBehavior, UserInputService.MouseIconEnabled
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Exclude
				rp.IgnoreWater = true
				local ignoreList = { cam, char }
				rp.FilterDescendantsInstances = ignoreList
				local look = cam.CFrame.LookVector
				local turn = math.atan2(-look.X, -look.Z)
				local pitch = 0.12
				pauseDesync(hrp)
				desyncPaused = true
				local pos = hrp.Position + Vector3.new(0, 1.5, 0)
				hideChar(char, true)
				local bank = 0
				local gradStart2 = os.clock()
				local isFpv = droneKind == "FPV"
				local drone = droneTemplate:Clone()
				local basePart = drone:FindFirstChildWhichIsA("BasePart", true)
				drone.Parent = cam
				local props = {}
				for _, d in ipairs(drone:GetDescendants()) do
					if d:IsA("BasePart") then
						local n = d.Name:lower()
						if n:find("prop") or n:find("blade") then
							table.insert(props, d)
						end
					end
				end
				local engine = playSound(isFpv and "fpv" or "engine", basePart, { Looped = true, Volume = 1, RollOffMinDistance = 15, RollOffMaxDistance = 700 })
				local osd, osdLabels
				if isFpv then
					osd = create("Frame", { Name = "RockHubShahedOsd", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = gui })
					osdLabels = {}

					local function o(key, anchor, pos2, align)
						osdLabels[key] = create("TextLabel", {
							AnchorPoint = anchor,
							Position = pos2,
							Size = UDim2.fromOffset(200, 18),
							BackgroundTransparency = 1,
							Font = Enum.Font.Code,
							TextSize = 16,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextStrokeTransparency = 0.3,
							TextXAlignment = align,
							Text = "",
							Parent = osd,
						})
					end

					o("bat", Vector2.new(0, 0), UDim2.fromOffset(30, 70), Enum.TextXAlignment.Left)
					o("time", Vector2.new(1, 0), UDim2.new(1, -30, 0, 70), Enum.TextXAlignment.Right)
					o("alt", Vector2.new(0, 1), UDim2.new(0, 30, 1, -80), Enum.TextXAlignment.Left)
					o("spd", Vector2.new(1, 1), UDim2.new(1, -30, 1, -80), Enum.TextXAlignment.Right)
					o("mode", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 70), Enum.TextXAlignment.Center)
					osdLabels.mode.Text = impactMode:upper() .. "   ACRO"
					osdLabels.mode.TextColor3 = impactMode == "Kill" and Color3.fromRGB(255, 80, 70) or Color3.fromRGB(110, 190, 255)
				end
				local hud2 = create("Frame", {
					Name = "RockHubShahedHud",
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, -24),
					Size = UDim2.fromOffset(0, 30),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(14, 14, 18),
					BackgroundTransparency = 0.25,
					Parent = gui,
				})
				create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hud2 })
				create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = hud2 })
				local hint = create("TextLabel", {
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamMedium,
					TextSize = 13,
					TextColor3 = Color3.fromRGB(235, 235, 240),
					Text = "",
					Parent = hud2,
				})
				local crosshair = create("Frame", {
					Name = "RockHubShahedCross",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(6, 6),
					BackgroundColor3 = Color3.fromRGB(255, 70, 60),
					Parent = gui,
				})
				create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = crosshair })
				local pip
				local preferredTouch = false
				pcall(function()
					preferredTouch = UserInputService.PreferredInput == Enum.PreferredInput.Touch
				end)
				local touchDevice = UserInputService.TouchEnabled and (preferredTouch or not UserInputService.KeyboardEnabled)
				local mobileInput = {
					throttle = 0,
					yaw = 0,
					lookDelta = Vector2.zero,
					boost = false,
					up = false,
					down = false,
				}
				local mobileRoot
				local fpView, vWasDown = false, false

				local function closePip()
					if not pip then
						return
					end
					pip.frame:Destroy()
					if pip.rec then
						pip.rec:Destroy()
					end
					pip = nil
				end

				local function safeClone(obj)
					local old = obj.Archivable
					obj.Archivable = true
					local ok, c = pcall(function()
						return obj:Clone()
					end)
					obj.Archivable = old
					return ok and c or nil
				end

				local function openPip(p)
					closePip()
					local th, _, targetChar = alive(p)
					if not th then
						return
					end
					local frame = create("Frame", {
						Name = "RockHubShahedPip",
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.new(1, -20, 1, -20),
						Size = UDim2.fromOffset(300, 190),
						BackgroundColor3 = Color3.fromRGB(10, 10, 12),
						BorderSizePixel = 0,
						Visible = false,
						Parent = gui,
					})
					create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = frame })
					create("UIStroke", { Color = Color3.fromRGB(255, 70, 60), Thickness = 1.5, Transparency = 0.2, Parent = frame })
					local viewport = create("ViewportFrame", {
						Position = UDim2.fromOffset(4, 4),
						Size = UDim2.new(1, -8, 1, -8),
						BackgroundColor3 = Color3.fromRGB(28, 32, 40),
						BorderSizePixel = 0,
						Ambient = Color3.fromRGB(150, 150, 155),
						LightColor = Color3.fromRGB(255, 250, 240),
						LightDirection = Vector3.new(-0.6, -1, -0.4),
						Parent = frame,
					})
					create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = viewport })
					local vpCam = create("Camera", { FieldOfView = 62, Parent = viewport })
					viewport.CurrentCamera = vpCam

					local function text(props2)
						do
							local ops = {}
							ops[5924] = {
								function()
									return props2
								end,
								"Parent",
								function()
									return props2.Parent or frame
								end,
							}
							ops[33396] = {
								function()
									return props2
								end,
								"TextSize",
								function()
									return props2.TextSize or 13
								end,
							}
							ops[27460] = {
								function()
									return props2
								end,
								"Font",
								function()
									return Enum.Font.Code
								end,
							}
							ops[46500] = {
								function()
									return props2
								end,
								"BackgroundTransparency",
								function()
									return 1
								end,
							}
							ops[31679] = {
								function()
									return props2
								end,
								"TextStrokeTransparency",
								function()
									return 0.4
								end,
							}
							ops[59609] = {
								function()
									return props2
								end,
								"ZIndex",
								function()
									return 4
								end,
							}
							local order = { 46500, 27460, 33396, 31679, 59609, 5924 }
							for j = 1, #order do
								local op = ops[order[j]]
								op[1]()[op[2]] = op[3]()
							end
						end
						return create("TextLabel", props2)
					end

					text({
						Position = UDim2.fromOffset(12, 9),
						Size = UDim2.new(1, -24, 0, 14),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Text = "TARGET CAM  " .. p.DisplayName:upper(),
					})
					local stampLabel = text({
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 12, 1, -8),
						Size = UDim2.new(1, -24, 0, 14),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(255, 80, 70),
						Text = "",
					})
					local flash = create("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ZIndex = 3,
						Parent = frame,
					})
					create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = flash })
					local lostLabel = text({
						Size = UDim2.fromScale(1, 1),
						TextSize = 22,
						TextColor3 = Color3.fromRGB(235, 235, 235),
						BackgroundColor3 = Color3.new(0, 0, 0),
						Text = "SIGNAL LOST",
						Visible = false,
					})
					lostLabel.BackgroundTransparency = 0
					create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = lostLabel })
					local scene = Instance.new("Model")
					local overlapParams = OverlapParams.new()
					overlapParams.FilterType = Enum.RaycastFilterType.Exclude
					local excludeList = { cam }
					for _, pl in ipairs(Players:GetPlayers()) do
						if pl.Character then
							table.insert(excludeList, pl.Character)
						end
					end
					overlapParams.FilterDescendantsInstances = excludeList
					local gotGun = 0
					for _, part in ipairs(workspace:GetPartBoundsInRadius(th.Position, 80, overlapParams)) do
						if gotGun >= 600 then
							break
						end
						if part.Transparency < 0.95 and not part:IsA("Terrain") then
							local c = safeClone(part)
							if c then
								for _, d in ipairs(c:GetDescendants()) do
									if not (d:IsA("Decal") or d:IsA("Texture") or d:IsA("SpecialMesh") or d:IsA("SurfaceAppearance")) then
										d:Destroy()
									end
								end
								c.Anchored = true
								c.Parent = scene
								gotGun += 1
							end
						end
					end
					scene.Parent = viewport
					local links = {}
					local charClone = safeClone(targetChar)
					if charClone then
						for _, d in ipairs(charClone:GetDescendants()) do
							if d:IsA("LuaSourceContainer") or d:IsA("Sound") then
								d:Destroy()
							elseif d:IsA("BasePart") then
								d.Anchored = true
							end
						end

						local function linkParts(a, b)
							for _, ca in ipairs(a:GetChildren()) do
								local cb = b:FindFirstChild(ca.Name)
								if cb then
									if ca:IsA("BasePart") and cb:IsA("BasePart") then
										table.insert(links, { ca, cb })
									end
									linkParts(ca, cb)
								end
							end
						end

						linkParts(targetChar, charClone)
						charClone.Parent = viewport
					end
					local droneCopy = droneTemplate:Clone()
					droneCopy.Parent = viewport
					local recLabel = create("TextLabel", {
						Name = "RockHubShahedRec",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0.5, 0, 0, 14),
						Size = UDim2.fromOffset(220, 18),
						BackgroundTransparency = 1,
						Font = Enum.Font.Code,
						TextSize = 15,
						TextColor3 = Color3.fromRGB(255, 70, 60),
						TextStrokeTransparency = 0.5,
						Text = "● REC  TARGET CAM",
						Parent = gui,
					})
					pip = {
						frame = frame,
						vf = viewport,
						p = p,
						hrp = th,
						vcam = vpCam,
						links = links,
						drone = droneCopy,
						stamp = stampLabel,
						flash = flash,
						lost = lostLabel,
						rec = recLabel,
						frames = {},
					}
				end

				local function recordFrame(droneCf)
					if not pip then
						return
					end
					if not alive(pip.p) then
						closePip()
						return
					end
					local now = os.clock()
					local cfs = table.create(#pip.links)
					for i, l in ipairs(pip.links) do
						cfs[i] = l[1].CFrame
					end
					table.insert(pip.frames, { t = now, drone = droneCf, cfs = cfs, tp = pip.hrp.Position })
					while #pip.frames > 2 and now - pip.frames[1].t > 3.2 do
						table.remove(pip.frames, 1)
					end
					pip.rec.TextTransparency = now * 2 % 1 < 0.6 and 0 or 0.7
				end

				local function playReplay(clip)
					if clip.rec then
						clip.rec:Destroy()
					end
					local frameCount2 = clip.frames
					if #frameCount2 < 2 then
						clip.frame:Destroy()
						return
					end

					local function applyFrame(f)
						for i, l in ipairs(clip.links) do
							if f.cfs[i] then
								l[2].CFrame = f.cfs[i]
							end
						end
						clip.drone:PivotTo(f.drone)
						local delta = f.drone.Position - f.tp
						local flatDist = Vector3.new(delta.X, 0, delta.Z)
						flatDist = flatDist.Magnitude > 0.1 and flatDist.Unit or Vector3.zAxis
						local camPos = f.tp - flatDist * 11 + Vector3.new(0, 5, 0)
						return CFrame.lookAt(camPos, f.tp + delta.Unit * 6 + Vector3.new(0, 1, 0))
					end

					local frame = clip.frame
					frame.Visible = true
					frame.Size = UDim2.fromOffset(0, 0)
					TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(300, 190) }):Play()
					local start, len = frameCount2[1].t, frameCount2[#frameCount2].t - frameCount2[1].t
					local camCf
					local cur = 1
					local playStart = os.clock()
					while true do
						local t = os.clock() - playStart
						if t > len then
							break
						end
						while cur < #frameCount2 and frameCount2[cur + 1].t - start <= t do
							cur += 1
						end
						local want = applyFrame(frameCount2[cur])
						camCf = camCf and camCf:Lerp(want, 0.25) or want
						clip.vcam.CFrame = camCf
						clip.stamp.Text = ("● REC  00:00:%05.2f   REPLAY"):format(t)
						RunService.RenderStepped:Wait()
					end
					local last = frameCount2[#frameCount2]
					clip.drone:Destroy()
					local fireball = create("Part", {
						Shape = Enum.PartType.Ball,
						Size = Vector3.one * 2,
						Anchored = true,
						Material = Enum.Material.Neon,
						Color = Color3.fromRGB(255, 150, 50),
						CFrame = CFrame.new(last.drone.Position),
						Parent = clip.vf,
					})
					clip.flash.BackgroundTransparency = 0
					TweenService:Create(clip.flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(fireball, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * 22, Color = Color3.fromRGB(70, 60, 55), Transparency = 0.4 }):Play()
					local shakeStart = os.clock()
					while os.clock() - shakeStart < 0.6 do
						local k = 1 - (os.clock() - shakeStart) / 0.6
						clip.vcam.CFrame = camCf * CFrame.Angles((math.random() - 0.5) * 0.08 * k, (math.random() - 0.5) * 0.08 * k, 0)
						RunService.RenderStepped:Wait()
					end
					clip.lost.Visible = true
					task.wait(0.9)
					TweenService:Create(frame, TweenInfo.new(0.2), { Size = UDim2.fromOffset(0, 0) }):Play()
					task.wait(0.22)
					frame:Destroy()
				end

				local keysDown = {}
				local done = false
				local connections2 = {}

				local function endFlight(exploded)
					for _, c in ipairs(connections2) do
						c:Disconnect()
					end
					RunService:UnbindFromRenderStep("RockHubShahedPilot")
					if engine then
						engine:Stop()
					end
					drone:Destroy()
					hud2:Destroy()
					if mobileRoot then
						mobileRoot:Destroy()
					end
					closePip()
					crosshair:Destroy()
					if osd then
						osd:Destroy()
					end
					UserInputService.MouseBehavior, UserInputService.MouseIconEnabled = oldMouse, oldIconEnabled
					local t = os.clock()
					while exploded and os.clock() - t < 2.45 or killing and os.clock() - t < 3 do
						if char.Parent then
							hideChar(char, true)
						end
						RunService.Heartbeat:Wait()
					end
					if char.Parent then
						hideChar(char, false)
					end
					if controls then
						task.spawn(pcall, function()
							controls:Enable()
						end)
					end
					hum.WalkSpeed, hum.JumpPower = oldWalkSpeed, oldJumpPower
					if desyncPaused then
						desyncPaused = false
						resumeDesync()
					end
					cam.CameraType = oldCamType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or oldCamType
					if hum.Parent then
						cam.CameraSubject = hum
					end
					droneBusy = false
					droneCleanup = nil
				end

				local function detonate(at)
					if done then
						return
					end
					done = true
					local best, bestDist = nil, 16
					for _, e in ipairs(getTargets(false, at, true)) do
						local th = alive(e.p)
						local d = th and (th.Position - at).Magnitude
						if d and d < bestDist then
							best, bestDist = e.p, d
						end
					end
					if pip and pip.p == best and best then
						local clip = pip
						pip = nil
						table.insert(clip.frames, {
							t = os.clock(),
							drone = CFrame.new(at),
							cfs = clip.frames[#clip.frames] and clip.frames[#clip.frames].cfs or {},
							tp = clip.hrp.Position,
						})
						task.delay(2.5, playReplay, clip)
					end
					if best then
						if impactMode == "Kill" then
							task.spawn(finishTarget, best)
						end
					end
					showSignalLost(best and best.DisplayName, os.clock() - gradStart2)
					explode(at)
					if best and impactMode == "Fling" and playerFlingAction then
						endFlight(false)
						task.spawn(playerFlingAction, best)
					else
						task.spawn(endFlight, true)
					end
				end

				local function abort()
					if done then
						return
					end
					done = true
					task.spawn(endFlight, false)
				end
				droneCleanup = abort

				if touchDevice then
					mobileRoot = create("Frame", {
						Name = "RockHubDroneMobile",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Parent = gui,
					})
					local stickBase = create("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 24, 1, -28),
						Size = UDim2.fromOffset(136, 136),
						BackgroundColor3 = Color3.fromRGB(14, 14, 18),
						BackgroundTransparency = 0.28,
						Active = true,
						ZIndex = 20,
						Parent = mobileRoot,
					})
					create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = stickBase })
					create("UIStroke", { Color = accentColor, Thickness = 2, Transparency = 0.35, Parent = stickBase })
					local stickKnob = create("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(54, 54),
						BackgroundColor3 = accentColor,
						BackgroundTransparency = 0.08,
						ZIndex = 21,
						Parent = stickBase,
					})
					create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = stickKnob })
					local stickTouch

					local function resetStick()
						stickTouch = nil
						mobileInput.throttle, mobileInput.yaw = 0, 0
						stickKnob.Position = UDim2.fromScale(0.5, 0.5)
					end

					local function updateStick(input)
						local center = stickBase.AbsolutePosition + stickBase.AbsoluteSize / 2
						local delta = Vector2.new(input.Position.X, input.Position.Y) - center
						local radius = stickBase.AbsoluteSize.X * 0.36
						if delta.Magnitude > radius then
							delta = delta.Unit * radius
						end
						mobileInput.yaw = math.clamp(delta.X / radius, -1, 1)
						mobileInput.throttle = math.clamp(-delta.Y / radius, -1, 1)
						stickKnob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
					end

					table.insert(connections2, stickBase.InputBegan:Connect(function(input)
						if not stickTouch and input.UserInputType == Enum.UserInputType.Touch then
							stickTouch = input
							updateStick(input)
						end
					end))
					table.insert(connections2, UserInputService.InputChanged:Connect(function(input)
						if input == stickTouch then
							updateStick(input)
						end
					end))
					table.insert(connections2, UserInputService.InputEnded:Connect(function(input)
						if input == stickTouch then
							resetStick()
						end
					end))

					local lookPad = create("Frame", {
						Position = UDim2.fromScale(0.38, 0),
						Size = UDim2.new(0.62, 0, 1, -190),
						BackgroundTransparency = 1,
						Active = true,
						ZIndex = 19,
						Parent = mobileRoot,
					})
					create("TextLabel", {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -18, 0, 18),
						Size = UDim2.fromOffset(130, 22),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Text = "DRAG TO AIM",
						TextSize = 12,
						TextColor3 = Color3.fromRGB(225, 225, 230),
						TextTransparency = 0.35,
						ZIndex = 20,
						Parent = lookPad,
					})
					local lookTouch
					table.insert(connections2, lookPad.InputBegan:Connect(function(input)
						if not lookTouch and input.UserInputType == Enum.UserInputType.Touch then
							lookTouch = input
						end
					end))
					table.insert(connections2, UserInputService.InputChanged:Connect(function(input)
						if input == lookTouch then
							mobileInput.lookDelta += Vector2.new(input.Delta.X, input.Delta.Y)
						end
					end))
					table.insert(connections2, UserInputService.InputEnded:Connect(function(input)
						if input == lookTouch then
							lookTouch = nil
						end
					end))

					local function controlButton(text, x, y, callback, holdKey)
						local button = create("TextButton", {
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.new(1, x, 1, y),
							Size = UDim2.fromOffset(82, 54),
							BackgroundColor3 = Color3.fromRGB(18, 18, 23),
							BackgroundTransparency = 0.16,
							AutoButtonColor = false,
							Font = Enum.Font.GothamBold,
							Text = text,
							TextSize = 12,
							TextColor3 = Color3.fromRGB(245, 245, 248),
							ZIndex = 22,
							Parent = mobileRoot,
						})
						create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = button })
						create("UIStroke", { Color = text == "BOOM" and Color3.fromRGB(255, 75, 60) or accentColor, Thickness = 1.5, Transparency = 0.3, Parent = button })
						if holdKey then
							local heldInput
							table.insert(connections2, button.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.Touch then
									heldInput = input
									mobileInput[holdKey] = true
									button.BackgroundColor3 = accentColor
								end
							end))
							table.insert(connections2, UserInputService.InputEnded:Connect(function(input)
								if input == heldInput then
									heldInput = nil
									mobileInput[holdKey] = false
									button.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
								end
							end))
						else
							table.insert(connections2, button.Activated:Connect(callback))
						end
					end

					controlButton("BOOST", -212, -92, nil, "boost")
					controlButton("UP", -122, -92, nil, "up")
					controlButton("DOWN", -32, -92, nil, "down")
					controlButton("VIEW", -212, -28, function()
						fpView = not fpView
					end)
					controlButton("BOOM", -122, -28, function()
						if os.clock() - gradStart2 > 0.5 then
							detonate(pos)
						end
					end)
					controlButton("EXIT", -32, -28, abort)
				end

				table.insert(connections2, UserInputService.InputBegan:Connect(function(input, gp)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if not gp and os.clock() - gradStart2 > 0.5 then
							detonate(pos)
						end
					elseif input.KeyCode == Enum.KeyCode.X then
						abort()
					elseif not gp then
						keysDown[input.KeyCode] = true
					end
				end))
				table.insert(connections2, UserInputService.InputEnded:Connect(function(input)
					keysDown[input.KeyCode] = nil
				end))
				table.insert(connections2, hum.Died:Connect(abort))
				local velocity = Vector3.zero

				local function votesCast(move)
					local hit2 = workspace:Spherecast(pos, 1.4, move, rp)
					for _ = 1, 8 do
						if not hit2 then
							break
						end
						local obj = hit2.Instance
						local m = obj:FindFirstAncestorOfClass("Model")
						local hitHum = m and m:FindFirstChildOfClass("Humanoid")
						if not (obj.Transparency >= 0.9 or not obj.CanCollide or hitHum) then
							break
						end
						table.insert(ignoreList, hitHum and m or obj)
						rp.FilterDescendantsInstances = ignoreList
						hit2 = workspace:Spherecast(pos, 1.4, move, rp)
					end
					return hit2
				end

				local function moveDrone(move)
					for _ = 1, 3 do
						if move.Magnitude < 0.001 then
							return
						end
						local hit2 = votesCast(move)
						if not hit2 then
							pos += move
							return
						end
						local n = hit2.Normal
						local travel = math.max(hit2.Distance - 0.05, 0)
						pos += move.Unit * travel + n * 0.02
						move -= move.Unit * travel
						move -= n * move:Dot(n)
						velocity -= n * math.min(velocity:Dot(n), 0)
					end
				end

				local groundParams = RaycastParams.new()
				groundParams.FilterType = Enum.RaycastFilterType.Exclude
				groundParams.FilterDescendantsInstances = { cam, char }
				local camCf = cam.CFrame

				local function keyDown(k)
					return UserInputService:IsKeyDown(k)
				end

				RunService:BindToRenderStep("RockHubShahedPilot", Enum.RenderPriority.Last.Value + 5, function(dt)
					if done then
						return
					end
					dt = math.min(dt, 0.05)
					if not touchDevice then
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
						UserInputService.MouseIconEnabled = false
					end
					cam.CameraType = Enum.CameraType.Scriptable
					local mouseDelta = touchDevice and mobileInput.lookDelta or UserInputService:GetMouseDelta()
					mobileInput.lookDelta = Vector2.zero
					local turn2 = 0
					if keyDown(Enum.KeyCode.A) then
						turn2 += 1
					end
					if keyDown(Enum.KeyCode.D) then
						turn2 -= 1
					end
					turn2 -= mobileInput.yaw
					local yawDelta = -mouseDelta.X * (touchDevice and 0.0045 or 0.0035) + turn2 * 1.8 * dt
					turn += yawDelta
					pitch = math.clamp(pitch - mouseDelta.Y * (touchDevice and 0.0045 or 0.0035), -1.45, 1.3)
					local v = keyDown(Enum.KeyCode.V)
					if v and not vWasDown then
						fpView = not fpView
					end
					vWasDown = v
					local rot = CFrame.Angles(0, turn, 0) * CFrame.Angles(pitch, 0, 0)
					local dir = rot.LookVector
					local speed = 0
					if keyDown(Enum.KeyCode.W) then
						speed = isFpv and (keyDown(Enum.KeyCode.LeftShift) and 150 or 90) or (keyDown(Enum.KeyCode.LeftShift) and 110 or 60)
					end
					if keyDown(Enum.KeyCode.S) then
						speed = isFpv and -30 or -25
					end
					if touchDevice and math.abs(mobileInput.throttle) > 0.04 then
						if mobileInput.throttle > 0 then
							speed = mobileInput.throttle * (isFpv and (mobileInput.boost and 150 or 90) or (mobileInput.boost and 110 or 60))
						else
							speed = mobileInput.throttle * (isFpv and 30 or 25)
						end
					end
					local vert, vel = 0, isFpv and 40 or 28
					if keyDown(Enum.KeyCode.Space) or mobileInput.up then
						vert += vel
					end
					if keyDown(Enum.KeyCode.LeftControl) or keyDown(Enum.KeyCode.Q) or mobileInput.down then
						vert -= vel
					end
					velocity = velocity:Lerp(dir * speed + Vector3.yAxis * vert, math.min(dt * (isFpv and 4.5 or 3), 1))
					bank += (math.clamp(yawDelta / math.max(dt, 0.001) * 0.35, -0.9, 0.9) - bank) * math.min(dt * 5, 1)
					local step = velocity * dt
					for _, e in ipairs(getTargets(false, pos, true)) do
						local th = alive(e.p)
						if th and (th.Position - pos).Magnitude < 6 then
							detonate(th.Position)
							return
						end
					end
					moveDrone(step)
					local cf = CFrame.new(pos) * rot
					local tilt = isFpv and -math.clamp(velocity:Dot(dir) / 150, -0.4, 1) * 0.45 or 0
					local visualCf = cf * CFrame.Angles(tilt, 0, bank * (isFpv and 1.2 or 1))
					drone:PivotTo(visualCf)
					local spinAxis = isFpv and visualCf.UpVector or visualCf.LookVector
					for _, prop in ipairs(props) do
						prop.CFrame = CFrame.new(prop.Position) * CFrame.fromAxisAngle(spinAxis, dt * 45) * (prop.CFrame - prop.Position)
					end
					if engine and isFpv then
						engine.PlaybackSpeed = 0.9 + velocity.Magnitude / 170
					end
					local camGoal
					if fpView then
						camGoal = isFpv and cf * CFrame.new(0, 0.45, -0.9) * CFrame.Angles(0.1, 0, bank * 0.6) or cf * CFrame.new(0, 0.3, -3) * CFrame.Angles(0, 0, bank * 0.5)
					else
						camGoal = isFpv and cf * CFrame.new(0, 0.8, 2.8) * CFrame.Angles(-0.1, 0, 0) or cf * CFrame.new(0, 1.1, 4) * CFrame.Angles(-0.08, 0, 0)
					end
					if osdLabels then
						local elapsed = os.clock() - gradStart2
						local g = workspace:Raycast(pos, Vector3.new(0, -400, 0), groundParams)
						osdLabels.bat.Text = ("BAT %.1fV"):format(16.8 - elapsed * 0.05)
						osdLabels.time.Text = ("%02d:%02d"):format(math.floor(elapsed / 60), math.floor(elapsed % 60))
						osdLabels.alt.Text = ("ALT %dm"):format(g and math.floor(g.Distance * 0.28) or 99)
						osdLabels.spd.Text = ("%d km/h"):format(math.floor(velocity.Magnitude * 0.28 * 3.6))
					end
					camCf = camCf:Lerp(camGoal, math.min(dt * (fpView and 25 or 12), 1))
					cam.CFrame = camCf
					local pipTarget, bestEta
					for _, e in ipairs(getTargets(false, pos, true)) do
						local th = alive(e.p)
						if th then
							local delta = th.Position - pos
							local closing = delta.Magnitude > 0.1 and velocity:Dot(delta.Unit) or 0
							if closing > 4 then
								local eta = delta.Magnitude / closing
								if not bestEta or eta < bestEta then
									pipTarget, bestEta = e.p, eta
								end
							end
						end
					end
					if pip and (pip.p ~= pipTarget or bestEta > 4.5) then
						closePip()
					end
					if not pip and pipTarget and bestEta < 3 then
						openPip(pipTarget)
					end
					if pip then
						recordFrame(visualCf)
					end
					local left = 45 - (os.clock() - gradStart2)
					if touchDevice then
						hint.Text = ("stick - fly  ·  drag - aim  ·  buttons - actions  ·  %ds"):format(math.max(0, math.ceil(left)))
					else
						hint.Text = ("mouse - aim  ·  W fly  ·  Shift fast  ·  S back  ·  Space/Ctrl up/down  ·  V view  ·  LMB boom  ·  X exit  ·  %ds"):format(math.max(0, math.ceil(left)))
					end
					if left <= 0 then
						detonate(pos)
					end
				end)
			end

			local function launchDroneSafe()
				local ok, err = xpcall(launchDrone2, debug.traceback)
				if ok then
					return
				end
				warn("[rockhub] Shahed: " .. tostring(err))
				notify("Shahed error", tostring(err):match("^[^\n]*"):sub(-110))
				droneBusy, droneLoading = false, false
				if desyncPaused then
					desyncPaused = false
					resumeDesync()
				end
				pcall(function()
					RunService:UnbindFromRenderStep("RockHubShahedPilot")
				end)
				for _, n in ipairs({ "RockHubShahedHud", "RockHubShahedCross", "RockHubShahedOsd", "RockHubShahedRec", "RockHubDroneMobile" }) do
					local g = gui:FindFirstChild(n)
					if g then
						g:Destroy()
					end
				end
				for _, d in ipairs(workspace.CurrentCamera:GetChildren()) do
					if d.Name == "RockHubShahed" then
						d:Destroy()
					end
				end
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
				task.spawn(pcall, function()
					require(player.PlayerScripts.PlayerModule):GetControls():Enable()
				end)
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char then
					hideChar(char, false)
				end
				if hum and hum.WalkSpeed == 0 then
					hum.WalkSpeed, hum.JumpPower = 16, 50
				end
				local cam = workspace.CurrentCamera
				cam.CameraType = Enum.CameraType.Custom
				if hum then
					cam.CameraSubject = hum
				end
			end

			local droneSection = addSection(droneTab, "Drone")
			droneSection:Segmented("Type", { "Shahed", "FPV" }, droneKind, function(v)
				droneKind = v
				droneTemplate = droneCache[v]
			end)
			droneSection:Segmented("Impact", { "Kill", "Fling" }, droneImpact, function(v)
				droneImpact = v
			end)
			droneSection:Button("Launch Drone", "Kill needs the knife; Fling works for every role", function()
				task.spawn(launchDroneSafe)
			end)
		end

selectTab(droneTab)
for _, item in ipairs(registry) do
local value = config[item.key]
if value ~= nil then pcall(item.set, value) end
end
dirty = false
loading = false

_G.RockHubUnload = function()
if droneCleanup then pcall(droneCleanup) end
for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
table.clear(connections)
keyListener = nil
if dirty then pcall(saveConfig) end
pcall(disableAntiFling)
pcall(function() RunService:UnbindFromRenderStep("RockHubShahedPilot") end)
if blur and blur.Parent then blur:Destroy() end
if gui and gui.Parent then gui:Destroy() end
_G.RockHubUnload = nil
end
		local TextService2 = game:GetService("TextService")

		local function playIntro()
			introPlaying = true
			gui.IgnoreGuiInset = true
			local overlay = create("Frame", {
				Name = "Intro",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 200,
				Parent = gui,
			})
			local center = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(420, 130),
				BackgroundTransparency = 1,
				Parent = overlay,
			})
			local introViewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(420, 130)
			create("UIScale", { Scale = math.clamp((introViewport.X - 24) / 420, 0.55, 1), Parent = center })
			local font = Enum.Font.GothamBlack
			local widths, total = {}, 0
			for i = 1, #"ROCK dimas" do
				local ch = ("ROCK dimas"):sub(i, i)
				local w = ch == " " and 16.099999999999998 or TextService2:GetTextSize(ch, 46, font, Vector2.new(200, 200)).X
				widths[i] = w
				total += w + (i < #"ROCK dimas" and 4 or 0)
			end
			local left = (420 - total) / 2
			local letters = {}
			local x = left
			for i = 1, #"ROCK dimas" do
				local ch = ("ROCK dimas"):sub(i, i)
				if ch ~= " " then
					local holder = create("Frame", {
						Position = UDim2.fromOffset(x, 14),
						Size = UDim2.fromOffset(widths[i], 56),
						BackgroundTransparency = 1,
						Parent = center,
					})
					local lbl = create("TextLabel", {
						Text = ch,
						Font = font,
						TextSize = 46,
						TextColor3 = accentColor,
						TextTransparency = 1,
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(0, -26),
						Size = UDim2.fromScale(1, 1),
						Parent = holder,
					})
					local scale = create("UIScale", { Scale = 1.6, Parent = lbl })
					table.insert(letters, { lbl = lbl, sc = scale, i = i })
				end
				x += widths[i] + 4
			end
			local bar = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 86),
				Size = UDim2.fromOffset(0, 2),
				BackgroundColor3 = strokeColor,
				BorderSizePixel = 0,
				Parent = center,
			})
			makeRound(bar)
			local fill = create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = accentColor, BorderSizePixel = 0, Parent = bar })
			makeRound(fill)
			local grad = create("UIGradient", { Parent = fill })
			local status = create("TextLabel", {
				Text = "",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = dimColor,
				TextTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(left, 96),
				Size = UDim2.fromOffset(total - 44, 16),
				Parent = center,
			})
			local percent = create("TextLabel", {
				Text = "0%",
				Font = Enum.Font.GothamMedium,
				TextSize = 12,
				TextColor3 = textColor,
				TextTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Right,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(left + total - 44, 96),
				Size = UDim2.fromOffset(44, 16),
				Parent = center,
			})
			local startTime = os.clock()
			local animConn = connect(RunService.RenderStepped, function()
				local t = os.clock() - startTime
				for _, letter in ipairs(letters) do
					local v = 0.5 + 0.5 * math.sin(t * 3 - letter.i * 0.55)
					local c = math.floor(110 + v * 145)
					letter.lbl.TextColor3 = Color3.fromRGB(c, c, c)
				end
				grad.Color = shimmerSeq(t * 0.6)
			end)
			local progress = Instance.new("NumberValue")
			progress.Changed:Connect(function(v)
				percent.Text = math.floor(v * 100 + 0.5) .. "%"
			end)
			local easeOut, easeIn, easeInOut = Enum.EasingDirection.Out, Enum.EasingDirection.In, Enum.EasingDirection.InOut
			tween(overlay, 0.4, { BackgroundTransparency = 0.35 })
			tween(blur, 0.5, { Size = 24 })
			task.wait(0.3)
			for _, letter in ipairs(letters) do
				tween(letter.lbl, 0.55, { TextTransparency = 0, Position = UDim2.fromOffset(0, 0) }, easeOut, Enum.EasingStyle.Back)
				tween(letter.sc, 0.55, { Scale = 1 }, easeOut, Enum.EasingStyle.Back)
				task.wait(0.06)
			end
			task.wait(0.3)
			tween(bar, 0.45, { Size = UDim2.fromOffset(total, 2) }, easeOut, Enum.EasingStyle.Quint)
			tween(status, 0.3, { TextTransparency = 0 })
			tween(percent, 0.3, { TextTransparency = 0 })
			task.wait(0.35)
			local steps = {
				{ "loading interface", 0.3 },
				{ "loading drone controls", 0.55 },
				{ "setting up interface", 0.8 },
				{ "done", 1 },
			}
			for _, s in ipairs(steps) do
				if not gui.Parent then
					break
				end
				status.Text = s[1]
				tween(fill, 0.45, { Size = UDim2.fromScale(s[2], 1) }, easeInOut)
				tween(progress, 0.45, { Value = s[2] }, easeInOut)
				task.wait(0.5)
			end
			status.Text = "welcome, " .. player.DisplayName
			task.wait(0.6)
			for _, letter in ipairs(letters) do
				tween(letter.lbl, 0.35, { TextTransparency = 1, Position = UDim2.fromOffset(0, -18) }, easeIn)
				task.wait(0.03)
			end
			tween(status, 0.3, { TextTransparency = 1 })
			tween(percent, 0.3, { TextTransparency = 1 })
			tween(bar, 0.35, { Size = UDim2.fromOffset(0, 2) }, easeIn, Enum.EasingStyle.Quint)
			tween(fill, 0.3, { BackgroundTransparency = 1 })
			tween(overlay, 0.45, { BackgroundTransparency = 1 })
			task.wait(0.25)
			introPlaying = false
			if not gui.Parent then
				return
			end
			gui.IgnoreGuiInset = false
			pcall(function()
				gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
				gui.ClipToDeviceSafeArea = true
			end)
			updateResponsiveScale()
			setMenuOpen(true)
			task.wait(0.4)
			animConn:Disconnect()
			progress:Destroy()
			overlay:Destroy()
		end

		task.spawn(playIntro)

		end)(...)
end)(...)
