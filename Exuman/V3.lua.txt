local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local EmoC = {}

--------------------------------------------------------------------
-- İKON SİSTEMİ
--------------------------------------------------------------------
local IconSystem = {
	Spritesheets = {
		["1"] = "rbxassetid://133454478968909",
		["2"] = "rbxassetid://72981277089259",
		["3"] = "rbxassetid://73688247122068",
		["4"] = "rbxassetid://81914421960723",
		["5"] = "rbxassetid://86699749765447",
		["6"] = "rbxassetid://120220597097660",
		["7"] = "rbxassetid://72166980445410",
		["8"] = "rbxassetid://101990875962066",
	},
	Icons = {
		["home"] = { Image = 4, ImageRectPosition = Vector2.new(512, 256), ImageRectSize = Vector2.new(128, 128) },
		["settings-gear"] = { Image = 6, ImageRectPosition = Vector2.new(512, 768), ImageRectSize = Vector2.new(128, 128) },
		["user"] = { Image = 7, ImageRectPosition = Vector2.new(640, 896), ImageRectSize = Vector2.new(128, 128) },
		["box"] = { Image = 1, ImageRectPosition = Vector2.new(640, 768), ImageRectSize = Vector2.new(128, 128) },
		["shield-check"] = { Image = 6, ImageRectPosition = Vector2.new(384, 896), ImageRectSize = Vector2.new(128, 128) },
		["code"] = { Image = 2, ImageRectPosition = Vector2.new(768, 640), ImageRectSize = Vector2.new(128, 128) },
		["play"] = { Image = 6, ImageRectPosition = Vector2.new(0, 384), ImageRectSize = Vector2.new(128, 128) },
		["power"] = { Image = 6, ImageRectPosition = Vector2.new(768, 384), ImageRectSize = Vector2.new(128, 128) },
		["chevron-down"] = { Image = 2, ImageRectPosition = Vector2.new(640, 384), ImageRectSize = Vector2.new(128, 128) },
		["pencil"] = { Image = 6, ImageRectPosition = Vector2.new(128, 256), ImageRectSize = Vector2.new(128, 128) },
		["menu"] = { Image = 5, ImageRectPosition = Vector2.new(640, 768), ImageRectSize = Vector2.new(128, 128) }
	}
}

local function LoadIcon(imageLabel, iconName)
	local iconData = IconSystem.Icons[iconName]
	if iconData then
		imageLabel.Image = IconSystem.Spritesheets[tostring(iconData.Image)]
		imageLabel.ImageRectOffset = iconData.ImageRectPosition 
		imageLabel.ImageRectSize = iconData.ImageRectSize
		imageLabel.BackgroundTransparency = 1
		imageLabel.Visible = true
	else
		imageLabel.Visible = false
	end
end

--------------------------------------------------------------------
-- ANA KÜTÜPHANE MOTORU
--------------------------------------------------------------------
function EmoC:CreateWindow(mainTitle, subTitleText, config)
	config = config or {}
	local minWidth = config.minWidth or 400
	local maxWidth = config.maxWidth or 900
	local confirmClose = config.confirmClose == nil and true or config.confirmClose
	
	local currentTheme = {
		Background = Color3.fromRGB(14, 14, 14),
		Topbar = Color3.fromRGB(18, 18, 18),
		Accent = Color3.fromRGB(46, 204, 113),
		Stroke = Color3.fromRGB(30, 30, 30),
		Text = Color3.fromRGB(255, 255, 255),
		TextMuted = Color3.fromRGB(120, 120, 120),
		TabSelected = Color3.fromRGB(28, 28, 28)
	}

	if config.customTheme and config.theme then
		for key, value in pairs(config.theme) do currentTheme[key] = value end
	end

	-- DÜZELTME: Dinamik Tema Kayıt Sistemi (Hataları önlemek için otomatik tablo oluşturucu)
	local ThemeRegistry = {}
	for key, _ in pairs(currentTheme) do
		ThemeRegistry[key] = {}
	end

	local function RegisterTheme(obj, prop, type)
		if ThemeRegistry[type] then
			table.insert(ThemeRegistry[type], {Obj = obj, Prop = prop})
		end
	end

	local ScreenGui = Instance.new("ScreenGui")
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end
	ScreenGui.Name = "WindUiUltimate"
	ScreenGui.ResetOnSpawn = false

	local isMinimized, isMaximized = false, false
	local originalSize = UDim2.new(0, math.clamp(520, minWidth, maxWidth), 0, 380)
	local originalPos = UDim2.new(0.5, -260, 0.5, -190)
	local normalSizeBeforeMaximize, normalPosBeforeMaximize = originalSize, originalPos

	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Name = "MainFrame"; MainFrame.Size = originalSize; MainFrame.Position = originalPos
	MainFrame.BackgroundColor3 = currentTheme.Background; MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = false
	RegisterTheme(MainFrame, "BackgroundColor3", "Background")

	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = currentTheme.Stroke; MainStroke.Thickness = 1.5
	RegisterTheme(MainStroke, "Color", "Stroke")

	-- Üst Bar
	local Topbar = Instance.new("Frame", MainFrame)
	Topbar.Size = UDim2.new(1, 0, 0, 55); Topbar.BackgroundTransparency = 1

	local titleOffsetX = config.icon and 45 or 15
	if config.icon then
		local WindowIcon = Instance.new("ImageLabel", Topbar)
		WindowIcon.Size = UDim2.new(0, 22, 0, 22); WindowIcon.Position = UDim2.new(0, 15, 0, 15)
		WindowIcon.ImageColor3 = currentTheme.Accent; LoadIcon(WindowIcon, config.icon)
		RegisterTheme(WindowIcon, "ImageColor3", "Accent")
	end

	local Title = Instance.new("TextLabel", Topbar)
	Title.Size = UDim2.new(0.6, 0, 0, 25); Title.Position = UDim2.new(0, titleOffsetX, 0, 10); Title.BackgroundTransparency = 1
	Title.Text = mainTitle or "WIND UI"; Title.TextColor3 = currentTheme.Text; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.TextScaled = true
	local TitleSizeConstraint = Instance.new("UITextSizeConstraint", Title); TitleSizeConstraint.MaxTextSize = 16; TitleSizeConstraint.MinTextSize = 12

	local SubTitle = Instance.new("TextLabel", Topbar)
	SubTitle.Size = UDim2.new(0.6, 0, 0, 15); SubTitle.Position = UDim2.new(0, titleOffsetX, 0, 32); SubTitle.BackgroundTransparency = 1
	SubTitle.Text = subTitleText or "Premium UI System"; SubTitle.TextColor3 = currentTheme.TextMuted; SubTitle.Font = Enum.Font.GothamMedium; SubTitle.TextXAlignment = Enum.TextXAlignment.Left; SubTitle.TextScaled = true
	local SubTitleSizeConstraint = Instance.new("UITextSizeConstraint", SubTitle); SubTitleSizeConstraint.MaxTextSize = 11; SubTitleSizeConstraint.MinTextSize = 9

	-- Kontrol Butonları
	local ButtonContainer = Instance.new("Frame", Topbar)
	ButtonContainer.Size = UDim2.new(0, 90, 0, 30); ButtonContainer.Position = UDim2.new(1, -100, 0, 12); ButtonContainer.BackgroundTransparency = 1
	local BtnLayout = Instance.new("UIListLayout", ButtonContainer)
	BtnLayout.FillDirection = Enum.FillDirection.Horizontal; BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right; BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center; BtnLayout.Padding = UDim.new(0, 8)

	local function createControlBtn(name, color, symbol)
		local Btn = Instance.new("TextButton", ButtonContainer)
		Btn.Size = UDim2.new(0, 22, 0, 22); Btn.BackgroundColor3 = currentTheme.TabSelected; Btn.Text = symbol; Btn.TextColor3 = color; Btn.TextSize = 10; Btn.Font = Enum.Font.GothamBold; Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
		local bs = Instance.new("UIStroke", Btn); bs.Color = currentTheme.Stroke; RegisterTheme(bs, "Color", "Stroke")
		Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = color, TextColor3 = currentTheme.Background}):Play() end)
		Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.TabSelected, TextColor3 = color}):Play() end)
		return Btn
	end
	
	local MinimizeBtn = createControlBtn("Minimize", Color3.fromRGB(241, 196, 15), "-")
	local MaximizeBtn = createControlBtn("Maximize", currentTheme.Accent, "+"); RegisterTheme(MaximizeBtn, "TextColor3", "Accent")
	local CloseBtn = createControlBtn("Close", Color3.fromRGB(231, 76, 60), "x")

	-- ALANLAR (Sidebar ve Content)
	local currentSidebarWidth = 140

	local Sidebar = Instance.new("ScrollingFrame", MainFrame)
	Sidebar.Size = UDim2.new(0, currentSidebarWidth, 1, -55); Sidebar.Position = UDim2.new(0, 0, 0, 55); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0
	local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 6); SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local SidebarPadding = Instance.new("UIPadding", Sidebar); SidebarPadding.PaddingLeft = UDim.new(0, 8); SidebarPadding.PaddingRight = UDim.new(0, 8); SidebarPadding.PaddingTop = UDim.new(0, 5)
	SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20) end)

	local VerticalDivider = Instance.new("Frame", MainFrame)
	VerticalDivider.Size = UDim2.new(0, 1, 1, -55); VerticalDivider.Position = UDim2.new(0, currentSidebarWidth, 0, 55); VerticalDivider.BackgroundColor3 = currentTheme.Stroke; VerticalDivider.BorderSizePixel = 0
	RegisterTheme(VerticalDivider, "BackgroundColor3", "Stroke")

	local ContentArea = Instance.new("Frame", MainFrame)
	ContentArea.Size = UDim2.new(1, -(currentSidebarWidth + 1), 1, -55); ContentArea.Position = UDim2.new(0, currentSidebarWidth + 1, 0, 55); ContentArea.BackgroundTransparency = 1

	-- RESIZABLE SIDEBAR (Hareketli Orta Çizgi)
	local DividerHandle = Instance.new("TextButton", VerticalDivider)
	DividerHandle.Size = UDim2.new(0, 10, 1, 0); DividerHandle.Position = UDim2.new(0.5, -5, 0, 0); DividerHandle.BackgroundTransparency = 1; DividerHandle.Text = ""; DividerHandle.ZIndex = 50
	
	local divResizing, divStartPos, divStartWidth = false
	DividerHandle.MouseEnter:Connect(function() TweenService:Create(VerticalDivider, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Accent, Size = UDim2.new(0, 2, 1, -55)}):Play() end)
	DividerHandle.MouseLeave:Connect(function() if not divResizing then TweenService:Create(VerticalDivider, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Stroke, Size = UDim2.new(0, 1, 1, -55)}):Play() end end)
	
	DividerHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			divResizing = true; divStartPos = input.Position; divStartWidth = currentSidebarWidth
			TweenService:Create(VerticalDivider, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Accent, Size = UDim2.new(0, 2, 1, -55)}):Play()
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if divResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - divStartPos
			currentSidebarWidth = math.clamp(divStartWidth + delta.X, 100, 250)
			Sidebar.Size = UDim2.new(0, currentSidebarWidth, 1, -55)
			VerticalDivider.Position = UDim2.new(0, currentSidebarWidth, 0, 55)
			ContentArea.Size = UDim2.new(1, -(currentSidebarWidth + 1), 1, -55)
			ContentArea.Position = UDim2.new(0, currentSidebarWidth + 1, 0, 55)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
			divResizing = false
			TweenService:Create(VerticalDivider, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Stroke, Size = UDim2.new(0, 1, 1, -55)}):Play()
		end
	end)

	-- POPUP SİSTEMİ (Ortada Çıkan Uyarı)
	local PopupOverlay = Instance.new("TextButton", MainFrame)
	PopupOverlay.Size = UDim2.new(1, 0, 1, 0); PopupOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0); PopupOverlay.BackgroundTransparency = 1; PopupOverlay.Text = ""; PopupOverlay.AutoButtonColor = false; PopupOverlay.Visible = false; PopupOverlay.ZIndex = 100
	Instance.new("UICorner", PopupOverlay).CornerRadius = UDim.new(0, 10)

	local PopupBox = Instance.new("Frame", PopupOverlay)
	PopupBox.Size = UDim2.new(0, 280, 0, 150); PopupBox.Position = UDim2.new(0.5, -140, 0.5, -50); PopupBox.BackgroundColor3 = currentTheme.Background; PopupBox.ZIndex = 101; PopupBox.BackgroundTransparency = 1
	Instance.new("UICorner", PopupBox).CornerRadius = UDim.new(0, 8)
	local PopupStroke = Instance.new("UIStroke", PopupBox); PopupStroke.Color = currentTheme.Stroke; PopupStroke.Thickness = 1; PopupStroke.Transparency = 1
	RegisterTheme(PopupBox, "BackgroundColor3", "Background"); RegisterTheme(PopupStroke, "Color", "Stroke")

	local PopupTitle = Instance.new("TextLabel", PopupBox)
	PopupTitle.Size = UDim2.new(1, 0, 0, 30); PopupTitle.Position = UDim2.new(0, 0, 0, 10); PopupTitle.BackgroundTransparency = 1; PopupTitle.Text = ""; PopupTitle.TextColor3 = currentTheme.Text; PopupTitle.Font = Enum.Font.GothamBold; PopupTitle.TextSize = 16; PopupTitle.ZIndex = 102; PopupTitle.TextTransparency = 1

	local PopupDesc = Instance.new("TextLabel", PopupBox)
	PopupDesc.Size = UDim2.new(1, -40, 0, 40); PopupDesc.Position = UDim2.new(0, 20, 0, 45); PopupDesc.BackgroundTransparency = 1; PopupDesc.Text = ""; PopupDesc.TextColor3 = currentTheme.TextMuted; PopupDesc.Font = Enum.Font.GothamMedium; PopupDesc.TextSize = 13; PopupDesc.TextWrapped = true; PopupDesc.ZIndex = 102; PopupDesc.TextTransparency = 1

	local PopupBtnContainer = Instance.new("Frame", PopupBox)
	PopupBtnContainer.Size = UDim2.new(1, -40, 0, 35); PopupBtnContainer.Position = UDim2.new(0, 20, 1, -50); PopupBtnContainer.BackgroundTransparency = 1; PopupBtnContainer.ZIndex = 102
	local PopupLayout = Instance.new("UIListLayout", PopupBtnContainer); PopupLayout.FillDirection = Enum.FillDirection.Horizontal; PopupLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; PopupLayout.Padding = UDim.new(0, 15)

	local function ShowPopup(title, desc, buttonLabels, callback)
		PopupTitle.Text = title; PopupDesc.Text = desc
		for _, v in pairs(PopupBtnContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		
		for _, btnText in pairs(buttonLabels) do
			local pBtn = Instance.new("TextButton", PopupBtnContainer)
			pBtn.Size = UDim2.new(0, 100, 1, 0); pBtn.BackgroundColor3 = currentTheme.TabSelected; pBtn.Text = btnText; pBtn.TextColor3 = currentTheme.Text; pBtn.Font = Enum.Font.GothamBold; pBtn.TextSize = 12; pBtn.ZIndex = 102; pBtn.BackgroundTransparency = 1; pBtn.TextTransparency = 1
			Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 6)
			local pbStroke = Instance.new("UIStroke", pBtn); pbStroke.Color = currentTheme.Stroke; pbStroke.Transparency = 1
			RegisterTheme(pBtn, "BackgroundColor3", "TabSelected"); RegisterTheme(pbStroke, "Color", "Stroke")

			pBtn.MouseButton1Click:Connect(function()
				TweenService:Create(PopupOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(PopupBox, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -140, 0.5, -50)}):Play()
				TweenService:Create(PopupTitle, TweenInfo.new(0.2), {TextTransparency = 1}):Play(); TweenService:Create(PopupDesc, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
				for _, b in pairs(PopupBtnContainer:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play(); TweenService:Create(b.UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play() end end
				task.wait(0.2); PopupOverlay.Visible = false
				if callback then callback(btnText) end
			end)
		end
		
		PopupOverlay.Visible = true
		TweenService:Create(PopupOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
		TweenService:Create(PopupBox, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Position = UDim2.new(0.5, -140, 0.5, -75)}):Play()
		PopupStroke.Transparency = 0
		TweenService:Create(PopupTitle, TweenInfo.new(0.2), {TextTransparency = 0}):Play(); TweenService:Create(PopupDesc, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
		for _, b in pairs(PopupBtnContainer:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0}):Play(); TweenService:Create(b.UIStroke, TweenInfo.new(0.2), {Transparency = 0}):Play() end end
	end

	local WindowObj = { CurrentTab = nil }

	-- TEMA DEĞİŞTİRİCİ FONKSİYON
	function WindowObj:ChangeTheme(newColors)
		for key, color in pairs(newColors) do currentTheme[key] = color end
		for colorType, elements in pairs(ThemeRegistry) do
			for _, item in pairs(elements) do
				if item.Obj and item.Obj.Parent then
					TweenService:Create(item.Obj, TweenInfo.new(0.5), {[item.Prop] = currentTheme[colorType]}):Play()
				end
			end
		end
	end

	CloseBtn.MouseButton1Click:Connect(function()
		if confirmClose then
			ShowPopup("Arayüzü Kapat", "Arayüzü tamamen kapatmak istediğinize emin misiniz?", {"Evet", "İptal"}, function(res)
				if res == "Evet" then ScreenGui:Destroy() end
			end)
		else
			ScreenGui:Destroy()
		end
	end)

	-- Sürükleme ve Boyutlandırma
	local DragHandleArea = Instance.new("TextButton", MainFrame)
	DragHandleArea.Size = UDim2.new(0, 25, 0, 120); DragHandleArea.Position = UDim2.new(0, -33, 0.5, -60); DragHandleArea.BackgroundTransparency = 1; DragHandleArea.Text = ""
	local DragBar = Instance.new("Frame", DragHandleArea)
	DragBar.Size = UDim2.new(0, 4, 0, 50); DragBar.Position = UDim2.new(0.5, -2, 0.5, -25); DragBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60); DragBar.BorderSizePixel = 0
	Instance.new("UICorner", DragBar).CornerRadius = UDim.new(1, 0)
	DragHandleArea.MouseEnter:Connect(function() TweenService:Create(DragBar, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 4, 0, 80), Position = UDim2.new(0.5, -2, 0.5, -40)}):Play() end)
	DragHandleArea.MouseLeave:Connect(function() TweenService:Create(DragBar, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(0, 4, 0, 50), Position = UDim2.new(0.5, -2, 0.5, -25)}):Play() end)

	local dragging, dragStart, startPos
	DragHandleArea.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
	UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

	local ResizeHandle = Instance.new("TextButton", MainFrame)
	ResizeHandle.Size = UDim2.new(0, 15, 1, -20); ResizeHandle.Position = UDim2.new(1, -10, 0, 10); ResizeHandle.BackgroundTransparency = 1; ResizeHandle.Text = ""; ResizeHandle.AutoButtonColor = false
	local ResizeVisual = Instance.new("Frame", ResizeHandle)
	ResizeVisual.Size = UDim2.new(0, 2, 0.3, 0); ResizeVisual.Position = UDim2.new(0.5, -1, 0.35, 0); ResizeVisual.BackgroundColor3 = currentTheme.Stroke; ResizeVisual.BorderSizePixel = 0
	RegisterTheme(ResizeVisual, "BackgroundColor3", "Stroke")
	ResizeHandle.MouseEnter:Connect(function() TweenService:Create(ResizeVisual, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Accent, Size = UDim2.new(0, 3, 0.4, 0), Position = UDim2.new(0.5, -1.5, 0.3, 0)}):Play() end)
	ResizeHandle.MouseLeave:Connect(function() TweenService:Create(ResizeVisual, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Stroke, Size = UDim2.new(0, 2, 0.3, 0), Position = UDim2.new(0.5, -1, 0.35, 0)}):Play() end)

	local resizing, resizeStartSize, resizeStartMousePos = false
	ResizeHandle.InputBegan:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isMaximized and not isMinimized then resizing = true; resizeStartMousePos = input.Position; resizeStartSize = MainFrame.Size end end)
	UserInputService.InputChanged:Connect(function(input) if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - resizeStartMousePos; MainFrame.Size = UDim2.new(0, math.clamp(resizeStartSize.X.Offset + delta.X, minWidth, maxWidth), MainFrame.Size.Y.Scale, MainFrame.Size.Y.Offset) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end end)

	MinimizeBtn.MouseButton1Click:Connect(function()
		if isMaximized then return end
		isMinimized = not isMinimized
		if isMinimized then
			originalSize = MainFrame.Size; Sidebar.Visible, VerticalDivider.Visible, ContentArea.Visible, ResizeHandle.Visible, DragHandleArea.Visible = false, false, false, false, false
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 55)}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize}):Play()
			task.delay(0.2, function() if not isMinimized then Sidebar.Visible, VerticalDivider.Visible, ContentArea.Visible, ResizeHandle.Visible, DragHandleArea.Visible = true, true, true, true, true end end)
		end
	end)

	MaximizeBtn.MouseButton1Click:Connect(function()
		if isMinimized then return end
		isMaximized = not isMaximized
		if isMaximized then
			normalSizeBeforeMaximize, normalPosBeforeMaximize = MainFrame.Size, MainFrame.Position
			ResizeHandle.Visible, DragHandleArea.Visible = false, false
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
		else
			ResizeHandle.Visible, DragHandleArea.Visible = true, true
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = normalSizeBeforeMaximize, Position = normalPosBeforeMaximize}):Play()
		end
	end)

	--------------------------------------------------------------------
	-- ELEMENT OLUŞTURUCU MİMARİSİ
	--------------------------------------------------------------------
	local function BuildElements(ParentContainer)
		local Elements = {}

		function Elements:CreateSpace(height)
			local Space = Instance.new("Frame", ParentContainer); Space.Size = UDim2.new(1, 0, 0, height or 15); Space.BackgroundTransparency = 1
			return Space
		end

		-- TEXTBOX SİSTEMİ
		function Elements:CreateTextBox(name, placeholder, callback)
			local BoxFrame = Instance.new("Frame", ParentContainer)
			BoxFrame.Size = UDim2.new(1, 0, 0, 50); BoxFrame.BackgroundColor3 = currentTheme.TabSelected; BoxFrame.BackgroundTransparency = 0.6
			Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
			local bfStroke = Instance.new("UIStroke", BoxFrame); bfStroke.Color = currentTheme.Stroke; bfStroke.Thickness = 1
			RegisterTheme(BoxFrame, "BackgroundColor3", "TabSelected"); RegisterTheme(bfStroke, "Color", "Stroke")

			local TitleLbl = Instance.new("TextLabel", BoxFrame)
			TitleLbl.Size = UDim2.new(1, -20, 0, 20); TitleLbl.Position = UDim2.new(0, 12, 0, 5); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = name; TitleLbl.TextColor3 = currentTheme.Text; TitleLbl.TextSize = 13; TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local InputBox = Instance.new("TextBox", BoxFrame)
			InputBox.Size = UDim2.new(1, -24, 0, 20); InputBox.Position = UDim2.new(0, 12, 0, 25); InputBox.BackgroundTransparency = 1; InputBox.Text = ""; InputBox.PlaceholderText = placeholder or "Buraya yazın..."; InputBox.TextColor3 = currentTheme.Accent; InputBox.PlaceholderColor3 = currentTheme.TextMuted; InputBox.TextSize = 12; InputBox.Font = Enum.Font.Gotham; InputBox.TextXAlignment = Enum.TextXAlignment.Left; InputBox.ClearTextOnFocus = false
			RegisterTheme(InputBox, "TextColor3", "Accent")

			InputBox.FocusLost:Connect(function()
				if callback then callback(InputBox.Text) end
			end)
		end

		-- SLIDER SİSTEMİ
		function Elements:CreateSlider(name, min, max, default, callback)
			local val = math.clamp(default or min, min, max)

			local SliderFrame = Instance.new("Frame", ParentContainer)
			SliderFrame.Size = UDim2.new(1, 0, 0, 55); SliderFrame.BackgroundColor3 = currentTheme.TabSelected; SliderFrame.BackgroundTransparency = 0.6
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
			local sfStroke = Instance.new("UIStroke", SliderFrame); sfStroke.Color = currentTheme.Stroke; sfStroke.Thickness = 1
			RegisterTheme(SliderFrame, "BackgroundColor3", "TabSelected"); RegisterTheme(sfStroke, "Color", "Stroke")

			local TitleLbl = Instance.new("TextLabel", SliderFrame)
			TitleLbl.Size = UDim2.new(1, -60, 0, 20); TitleLbl.Position = UDim2.new(0, 12, 0, 5); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = name; TitleLbl.TextColor3 = currentTheme.Text; TitleLbl.TextSize = 13; TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local ValueLbl = Instance.new("TextLabel", SliderFrame)
			ValueLbl.Size = UDim2.new(0, 40, 0, 20); ValueLbl.Position = UDim2.new(1, -52, 0, 5); ValueLbl.BackgroundTransparency = 1; ValueLbl.Text = tostring(val); ValueLbl.TextColor3 = currentTheme.Accent; ValueLbl.TextSize = 13; ValueLbl.Font = Enum.Font.GothamBold; ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
			RegisterTheme(ValueLbl, "TextColor3", "Accent")

			local Track = Instance.new("TextButton", SliderFrame)
			Track.Size = UDim2.new(1, -24, 0, 6); Track.Position = UDim2.new(0, 12, 0, 35); Track.BackgroundColor3 = currentTheme.Background; Track.Text = ""; Track.AutoButtonColor = false
			Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0); RegisterTheme(Track, "BackgroundColor3", "Background")

			local Fill = Instance.new("Frame", Track)
			Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = currentTheme.Accent; Fill.BorderSizePixel = 0
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0); RegisterTheme(Fill, "BackgroundColor3", "Accent")

			local Grabber = Instance.new("Frame", Fill)
			Grabber.Size = UDim2.new(0, 14, 0, 14); Grabber.Position = UDim2.new(1, -7, 0.5, -7); Grabber.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Grabber.BorderSizePixel = 0
			Instance.new("UICorner", Grabber).CornerRadius = UDim.new(1, 0)

			local sliding = false
			local function updateSlider(input)
				local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local realVal = math.floor(min + (max - min) * percent)
				ValueLbl.Text = tostring(realVal); Fill.Size = UDim2.new(percent, 0, 1, 0)
				if callback then callback(realVal) end
			end

			Track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true; updateSlider(input) end end)
			UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
		end

		-- DROPDOWN SİSTEMİ
		function Elements:CreateDropdown(name, options, default, callback)
			local selected = default or options[1]

			local DropBtn = Instance.new("TextButton", ParentContainer)
			DropBtn.Size = UDim2.new(1, 0, 0, 40); DropBtn.BackgroundColor3 = currentTheme.TabSelected; DropBtn.BackgroundTransparency = 0.6; DropBtn.Text = ""; DropBtn.AutoButtonColor = false
			Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6)
			local dStroke = Instance.new("UIStroke", DropBtn); dStroke.Color = currentTheme.Stroke; dStroke.Thickness = 1
			RegisterTheme(DropBtn, "BackgroundColor3", "TabSelected"); RegisterTheme(dStroke, "Color", "Stroke")

			local TitleLbl = Instance.new("TextLabel", DropBtn)
			TitleLbl.Size = UDim2.new(1, -150, 1, 0); TitleLbl.Position = UDim2.new(0, 12, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = name; TitleLbl.TextColor3 = currentTheme.Text; TitleLbl.TextSize = 13; TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local SelectedLbl = Instance.new("TextLabel", DropBtn)
			SelectedLbl.Size = UDim2.new(0, 100, 1, 0); SelectedLbl.Position = UDim2.new(1, -135, 0, 0); SelectedLbl.BackgroundTransparency = 1; SelectedLbl.Text = tostring(selected); SelectedLbl.TextColor3 = currentTheme.Accent; SelectedLbl.TextSize = 12; SelectedLbl.Font = Enum.Font.Gotham; SelectedLbl.TextXAlignment = Enum.TextXAlignment.Right; SelectedLbl.TextTruncate = Enum.TextTruncate.AtEnd
			RegisterTheme(SelectedLbl, "TextColor3", "Accent")

			local Chevron = Instance.new("ImageLabel", DropBtn)
			Chevron.Size = UDim2.new(0, 16, 0, 16); Chevron.Position = UDim2.new(1, -26, 0.5, -8); Chevron.BackgroundTransparency = 1; Chevron.ImageColor3 = currentTheme.TextMuted; LoadIcon(Chevron, "chevron-down")

			local DropList = Instance.new("ScrollingFrame", ScreenGui)
			DropList.Size = UDim2.new(0, 0, 0, 0); DropList.BackgroundColor3 = currentTheme.Background; DropList.BorderSizePixel = 0; DropList.ZIndex = 50; DropList.Visible = false; DropList.ScrollBarThickness = 2; DropList.ScrollBarImageColor3 = currentTheme.Accent
			Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6); local listStroke = Instance.new("UIStroke", DropList); listStroke.Color = currentTheme.Stroke; listStroke.Thickness = 1
			RegisterTheme(DropList, "BackgroundColor3", "Background"); RegisterTheme(DropList, "ScrollBarImageColor3", "Accent"); RegisterTheme(listStroke, "Color", "Stroke")

			local ListLayout = Instance.new("UIListLayout", DropList); ListLayout.Padding = UDim.new(0, 2); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			local ListPad = Instance.new("UIPadding", DropList); ListPad.PaddingTop = UDim.new(0, 4); ListPad.PaddingBottom = UDim.new(0, 4); ListPad.PaddingLeft = UDim.new(0, 4); ListPad.PaddingRight = UDim.new(0, 4)

			local isOpen = false

			local function RenderOptions()
				for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
				for _, opt in pairs(options) do
					local optBtn = Instance.new("TextButton", DropList)
					optBtn.Size = UDim2.new(1, 0, 0, 30); optBtn.BackgroundColor3 = currentTheme.TabSelected; optBtn.BackgroundTransparency = 1; optBtn.Text = tostring(opt); optBtn.TextColor3 = (opt == selected) and currentTheme.Accent or currentTheme.TextMuted; optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 12; optBtn.ZIndex = 51; optBtn.AutoButtonColor = false
					Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

					optBtn.MouseEnter:Connect(function() TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play() end)
					optBtn.MouseLeave:Connect(function() TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
					optBtn.MouseButton1Click:Connect(function()
						selected = opt; SelectedLbl.Text = tostring(opt); isOpen = false
						DropList.Visible = false; TweenService:Create(Chevron, TweenInfo.new(0.3), {Rotation = 0}):Play()
						if callback then callback(opt) end
					end)
				end
				DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
			end

			DropBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				TweenService:Create(Chevron, TweenInfo.new(0.3), {Rotation = isOpen and 180 or 0}):Play()
				if isOpen then
					RenderOptions()
					local absPos = DropBtn.AbsolutePosition
					local absSize = DropBtn.AbsoluteSize
					DropList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 5)
					DropList.Size = UDim2.new(0, absSize.X, 0, math.clamp(ListLayout.AbsoluteContentSize.Y + 8, 30, 150))
					DropList.Visible = true
				else
					DropList.Visible = false
				end
			end)
			
			MainFrame:GetPropertyChangedSignal("Position"):Connect(function() if isOpen then isOpen = false; DropList.Visible = false; TweenService:Create(Chevron, TweenInfo.new(0.3), {Rotation = 0}):Play() end end)
		end

		function Elements:CreateSection(sectionTitle)
			local SectionMain = Instance.new("Frame", ParentContainer)
			SectionMain.Size = UDim2.new(1, 0, 0, 34); SectionMain.BackgroundTransparency = 1; SectionMain.ClipsDescendants = true

			local SectionHeader = Instance.new("TextButton", SectionMain)
			SectionHeader.Size = UDim2.new(1, 0, 0, 34); SectionHeader.BackgroundColor3 = currentTheme.TabSelected; SectionHeader.BackgroundTransparency = 0.3; SectionHeader.AutoButtonColor = false; SectionHeader.Text = ""
			Instance.new("UICorner", SectionHeader).CornerRadius = UDim.new(0, 6)
			local HeaderStroke = Instance.new("UIStroke", SectionHeader); HeaderStroke.Color = currentTheme.Stroke
			RegisterTheme(SectionHeader, "BackgroundColor3", "TabSelected"); RegisterTheme(HeaderStroke, "Color", "Stroke")

			local TitleLbl = Instance.new("TextLabel", SectionHeader)
			TitleLbl.Size = UDim2.new(1, -40, 1, 0); TitleLbl.Position = UDim2.new(0, 12, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = sectionTitle; TitleLbl.TextColor3 = currentTheme.Text; TitleLbl.TextSize = 13; TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local Chevron = Instance.new("ImageLabel", SectionHeader)
			Chevron.Size = UDim2.new(0, 16, 0, 16); Chevron.Position = UDim2.new(1, -26, 0.5, -8); Chevron.BackgroundTransparency = 1; Chevron.ImageColor3 = currentTheme.TextMuted; LoadIcon(Chevron, "chevron-down")

			local SectionContent = Instance.new("Frame", SectionMain)
			SectionContent.Size = UDim2.new(1, 0, 0, 0); SectionContent.Position = UDim2.new(0, 0, 0, 38); SectionContent.BackgroundTransparency = 1; SectionContent.ClipsDescendants = true
			local ContentLayout = Instance.new("UIListLayout", SectionContent); ContentLayout.Padding = UDim.new(0, 6); ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local expanded = false
			local function UpdateSize()
				if expanded then TweenService:Create(SectionMain, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 38 + ContentLayout.AbsoluteContentSize.Y)}):Play(); TweenService:Create(SectionContent, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y)}):Play()
				else TweenService:Create(SectionMain, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 34)}):Play(); TweenService:Create(SectionContent, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play() end
			end

			ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if expanded then SectionMain.Size = UDim2.new(1, 0, 0, 38 + ContentLayout.AbsoluteContentSize.Y); SectionContent.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y) end end)
			SectionHeader.MouseButton1Click:Connect(function() expanded = not expanded; TweenService:Create(Chevron, TweenInfo.new(0.3), {Rotation = expanded and 180 or 0}):Play(); UpdateSize() end)
			SectionHeader.MouseEnter:Connect(function() TweenService:Create(HeaderStroke, TweenInfo.new(0.2), {Color = currentTheme.Accent}):Play() end)
			SectionHeader.MouseLeave:Connect(function() TweenService:Create(HeaderStroke, TweenInfo.new(0.2), {Color = currentTheme.Stroke}):Play() end)

			return BuildElements(SectionContent)
		end

		function Elements:CreateButton(btnName, btnDescription, iconName, callback)
			local hasDesc, hasIcon = (btnDescription ~= nil and btnDescription ~= ""), (iconName ~= nil and iconName ~= "")
			local rowHeight = hasDesc and 48 or 36

			local ButtonFrame = Instance.new("TextButton", ParentContainer)
			ButtonFrame.Size = UDim2.new(1, 0, 0, rowHeight); ButtonFrame.BackgroundColor3 = currentTheme.TabSelected; ButtonFrame.BackgroundTransparency = 0.6; ButtonFrame.Text = ""; ButtonFrame.AutoButtonColor = false
			Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 6)
			local btnStroke = Instance.new("UIStroke", ButtonFrame); btnStroke.Color = currentTheme.Stroke; btnStroke.Thickness = 1
			RegisterTheme(ButtonFrame, "BackgroundColor3", "TabSelected"); RegisterTheme(btnStroke, "Color", "Stroke")

			local contentOffsetX = hasIcon and 38 or 12

			if hasIcon then
				local BtnIcon = Instance.new("ImageLabel", ButtonFrame)
				BtnIcon.Size = UDim2.new(0, 18, 0, 18); BtnIcon.Position = UDim2.new(0, 10, 0.5, -9); BtnIcon.ImageColor3 = currentTheme.Text; LoadIcon(BtnIcon, iconName)
			end

			local PointerIcon = Instance.new("ImageLabel", ButtonFrame)
			PointerIcon.Size = UDim2.new(0, 16, 0, 16); PointerIcon.Position = UDim2.new(1, -26, 0.5, -8); PointerIcon.ImageColor3 = currentTheme.TextMuted; LoadIcon(PointerIcon, "play")

			local TextContainer = Instance.new("Frame", ButtonFrame)
			TextContainer.Size = UDim2.new(1, -contentOffsetX - 35, 1, 0); TextContainer.Position = UDim2.new(0, contentOffsetX, 0, 0); TextContainer.BackgroundTransparency = 1

			local TitleLbl = Instance.new("TextLabel", TextContainer)
			TitleLbl.Size = UDim2.new(1, 0, 0, hasDesc and 22 or rowHeight); TitleLbl.Position = UDim2.new(0, 0, 0, hasDesc and 5 or 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = btnName; TitleLbl.TextColor3 = currentTheme.Text; TitleLbl.TextSize = 13; TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

			if hasDesc then
				local DescLbl = Instance.new("TextLabel", TextContainer)
				DescLbl.Size = UDim2.new(1, 0, 0, 16); DescLbl.Position = UDim2.new(0, 0, 0, 24); DescLbl.BackgroundTransparency = 1; DescLbl.Text = btnDescription; DescLbl.TextColor3 = currentTheme.TextMuted; DescLbl.TextSize = 10; DescLbl.Font = Enum.Font.Gotham; DescLbl.TextXAlignment = Enum.TextXAlignment.Left
			end

			ButtonFrame.MouseEnter:Connect(function() TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = currentTheme.Accent}):Play(); TweenService:Create(PointerIcon, TweenInfo.new(0.2), {ImageColor3 = currentTheme.Accent, Position = UDim2.new(1, -22, 0.5, -8)}):Play() end)
			ButtonFrame.MouseLeave:Connect(function() TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = currentTheme.Stroke}):Play(); TweenService:Create(PointerIcon, TweenInfo.new(0.2), {ImageColor3 = currentTheme.TextMuted, Position = UDim2.new(1, -26, 0.5, -8)}):Play() end)
			ButtonFrame.MouseButton1Click:Connect(function() ButtonFrame.BackgroundColor3 = currentTheme.Accent; TweenService:Create(ButtonFrame, TweenInfo.new(0.3), {BackgroundColor3 = currentTheme.TabSelected}):Play(); if callback then callback() end end)
		end

		function Elements:CreateToggle(toggleName, toggleDescription, iconName, defaultState, useCircleStyle, callback)
			local toggleActive = defaultState or false
			local hasDesc, hasIcon = (toggleDescription ~= nil and toggleDescription ~= ""), (iconName ~= nil and iconName ~= "")
			local rowHeight = hasDesc and 48 or 36

			local ToggleFrame = Instance.new("TextButton", ParentContainer)
			ToggleFrame.Size = UDim2.new(1, 0, 0, rowHeight); ToggleFrame.BackgroundColor3 = currentTheme.TabSelected; ToggleFrame.BackgroundTransparency = 0.6; ToggleFrame.Text = ""; ToggleFrame.AutoButtonColor = false
			Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
			local tfStroke = Instance.new("UIStroke", ToggleFrame); tfStroke.Color = currentTheme.Stroke; tfStroke.Thickness = 1
			RegisterTheme(ToggleFrame, "BackgroundColor3", "TabSelected"); RegisterTheme(tfStroke, "Color", "Stroke")

			local contentOffsetX = hasIcon and 38 or 12

			if hasIcon then
				local TglIcon = Instance.new("ImageLabel", ToggleFrame)
				TglIcon.Size = UDim2.new(0, 18, 0, 18); TglIcon.Position = UDim2.new(0, 10, 0.5, -9); TglIcon.ImageColor3 = currentTheme.Text; LoadIcon(TglIcon, iconName)
			end

			local TextContainer = Instance.new("Frame", ToggleFrame)
			TextContainer.Size = UDim2.new(1, -contentOffsetX - 60, 1, 0); TextContainer.Position = UDim2.new(0, contentOffsetX, 0, 0); TextContainer.BackgroundTransparency = 1

			local TitleLbl = Instance.new("TextLabel", TextContainer)
			TitleLbl.Size = UDim2.new(1, 0, 0, hasDesc and 22 or rowHeight); TitleLbl.Position = UDim2.new(0, 0, 0, hasDesc and 5 or 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = toggleName; TitleLbl.TextColor3 = currentTheme.Text; TitleLbl.TextSize = 13; TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

			if hasDesc then
				local DescLbl = Instance.new("TextLabel", TextContainer)
				DescLbl.Size = UDim2.new(1, 0, 0, 16); DescLbl.Position = UDim2.new(0, 0, 0, 24); DescLbl.BackgroundTransparency = 1; DescLbl.Text = toggleDescription; DescLbl.TextColor3 = currentTheme.TextMuted; DescLbl.TextSize = 10; DescLbl.Font = Enum.Font.Gotham; DescLbl.TextXAlignment = Enum.TextXAlignment.Left
			end

			local IndicatorContainer = Instance.new("Frame", ToggleFrame)
			IndicatorContainer.BackgroundTransparency = 1; Instance.new("UICorner", IndicatorContainer).CornerRadius = UDim.new(1, 0)
			local IndicatorStroke = Instance.new("UIStroke", IndicatorContainer)
			
			local MovingPart = Instance.new("Frame", IndicatorContainer)
			MovingPart.BorderSizePixel = 0; Instance.new("UICorner", MovingPart).CornerRadius = UDim.new(1, 0)

			if useCircleStyle then
				IndicatorContainer.Size = UDim2.new(0, 22, 0, 22); IndicatorContainer.Position = UDim2.new(1, -34, 0.5, -11)
				IndicatorStroke.Thickness = 1.5; MovingPart.BackgroundColor3 = currentTheme.Text

				local function updateVisuals(animate)
					local duration = animate and 0.2 or 0
					if toggleActive then TweenService:Create(IndicatorContainer, TweenInfo.new(duration), {BackgroundColor3 = currentTheme.Accent}):Play(); TweenService:Create(IndicatorStroke, TweenInfo.new(duration), {Color = currentTheme.Accent}):Play(); TweenService:Create(MovingPart, TweenInfo.new(duration), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -5)}):Play()
					else TweenService:Create(IndicatorContainer, TweenInfo.new(duration), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play(); TweenService:Create(IndicatorStroke, TweenInfo.new(duration), {Color = currentTheme.Stroke}):Play(); TweenService:Create(MovingPart, TweenInfo.new(duration), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play() end
				end
				updateVisuals(false)
				ToggleFrame.MouseButton1Click:Connect(function() toggleActive = not toggleActive; updateVisuals(true); if callback then callback(toggleActive) end end)
			else
				IndicatorContainer.Size = UDim2.new(0, 42, 0, 22); IndicatorContainer.Position = UDim2.new(1, -54, 0.5, -11)
				IndicatorStroke.Thickness = 1; MovingPart.Size = UDim2.new(0, 16, 0, 16); MovingPart.BackgroundColor3 = currentTheme.Text

				local function updateVisuals(animate)
					local duration = animate and 0.2 or 0
					if toggleActive then TweenService:Create(IndicatorContainer, TweenInfo.new(duration), {BackgroundColor3 = currentTheme.Accent}):Play(); TweenService:Create(IndicatorStroke, TweenInfo.new(duration), {Color = currentTheme.Accent}):Play(); TweenService:Create(MovingPart, TweenInfo.new(duration), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
					else TweenService:Create(IndicatorContainer, TweenInfo.new(duration), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play(); TweenService:Create(IndicatorStroke, TweenInfo.new(duration), {Color = currentTheme.Stroke}):Play(); TweenService:Create(MovingPart, TweenInfo.new(duration), {Position = UDim2.new(0, 3, 0.5, -8)}):Play() end
				end
				updateVisuals(false)
				ToggleFrame.MouseButton1Click:Connect(function() toggleActive = not toggleActive; updateVisuals(true); if callback then callback(toggleActive) end end)
			end

			ToggleFrame.MouseEnter:Connect(function() TweenService:Create(tfStroke, TweenInfo.new(0.2), {Color = currentTheme.TextMuted}):Play() end)
			ToggleFrame.MouseLeave:Connect(function() TweenService:Create(tfStroke, TweenInfo.new(0.2), {Color = currentTheme.Stroke}):Play() end)
		end

		return Elements
	end

	--------------------------------------------------------------------
	-- TAB OLUŞTURMA
	--------------------------------------------------------------------
	function WindowObj:CreateTab(tabName, tabDescription, iconName)
		local hasDesc, hasIcon = (tabDescription ~= nil and tabDescription ~= ""), (iconName ~= nil and iconName ~= "")
		local btnHeight = hasDesc and 44 or 34

		local TabButton = Instance.new("TextButton", Sidebar)
		TabButton.Size = UDim2.new(1, 0, 0, btnHeight); TabButton.BackgroundColor3 = currentTheme.Accent; TabButton.BackgroundTransparency = 1; TabButton.ClipsDescendants = true; TabButton.Text = ""; TabButton.AutoButtonColor = false
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6); RegisterTheme(TabButton, "BackgroundColor3", "Accent")

		local contentOffsetX = hasIcon and 32 or 8

		if hasIcon then
			local TabIcon = Instance.new("ImageLabel", TabButton)
			TabIcon.Size = UDim2.new(0, 16, 0, 16); TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
			TabIcon.ImageColor3 = currentTheme.TextMuted; LoadIcon(TabIcon, iconName)
		end

		local TabTitle = Instance.new("TextLabel", TabButton)
		TabTitle.Size = UDim2.new(1, -contentOffsetX - 8, 0, hasDesc and 20 or btnHeight); TabTitle.Position = UDim2.new(0, contentOffsetX, 0, hasDesc and 4 or 0); TabTitle.BackgroundTransparency = 1; TabTitle.Text = tabName; TabTitle.TextColor3 = currentTheme.TextMuted; TabTitle.TextSize = 13; TabTitle.Font = Enum.Font.GothamMedium; TabTitle.TextXAlignment = Enum.TextXAlignment.Left; TabTitle.TextWrapped = true; TabTitle.TextTruncate = Enum.TextTruncate.AtEnd

		if hasDesc then
			local TabDesc = Instance.new("TextLabel", TabButton)
			TabDesc.Size = UDim2.new(1, -contentOffsetX - 8, 0, 16); TabDesc.Position = UDim2.new(0, contentOffsetX, 0, 22); TabDesc.BackgroundTransparency = 1; TabDesc.Text = tabDescription; TabDesc.TextColor3 = Color3.fromRGB(80, 80, 80); TabDesc.TextSize = 10; TabDesc.Font = Enum.Font.Gotham; TabDesc.TextXAlignment = Enum.TextXAlignment.Left; TabDesc.TextWrapped = true; TabDesc.TextTruncate = Enum.TextTruncate.AtEnd
		end

		local TabPage = Instance.new("ScrollingFrame", ContentArea)
		TabPage.Size = UDim2.new(1, 0, 1, 0); TabPage.BackgroundTransparency = 1; TabPage.Visible = false; TabPage.ScrollBarThickness = 2; TabPage.ScrollBarImageColor3 = currentTheme.Accent; TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		RegisterTheme(TabPage, "ScrollBarImageColor3", "Accent")
		local PageLayout = Instance.new("UIListLayout", TabPage); PageLayout.Padding = UDim.new(0, 8); PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		local PagePadding = Instance.new("UIPadding", TabPage); PagePadding.PaddingTop = UDim.new(0, 15); PagePadding.PaddingLeft = UDim.new(0, 15); PagePadding.PaddingRight = UDim.new(0, 15)
		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30) end)

		local function SelectTab()
			if WindowObj.CurrentTab then
				WindowObj.CurrentTab.Button.BackgroundTransparency = 1; WindowObj.CurrentTab.Title.TextColor3 = currentTheme.TextMuted
				if WindowObj.CurrentTab.Icon then WindowObj.CurrentTab.Icon.ImageColor3 = currentTheme.TextMuted end
				WindowObj.CurrentTab.Page.Visible = false
			end
			WindowObj.CurrentTab = {Button = TabButton, Title = TabTitle, Icon = TabButton:FindFirstChildOfClass("ImageLabel"), Page = TabPage}
			TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.92}):Play()
			TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = currentTheme.Accent}):Play()
			if WindowObj.CurrentTab.Icon then TweenService:Create(WindowObj.CurrentTab.Icon, TweenInfo.new(0.2), {ImageColor3 = currentTheme.Accent}):Play() end
			TabPage.Visible = true
		end

		TabButton.MouseButton1Click:Connect(SelectTab)
		if #Sidebar:GetChildren() == 3 then SelectTab() end

		return BuildElements(TabPage)
	end

	return WindowObj
end

return EmoC
