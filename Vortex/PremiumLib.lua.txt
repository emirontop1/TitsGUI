-- =============================================================================
-- [1. SOURCE: MASTER WINDOW LIBRARY WITH ALL MODERN UI ELEMENTS & SETTERS]
-- =============================================================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local PremiumLib = {}
PremiumLib.__index = PremiumLib

local COLORS = {
	Background = Color3.fromRGB(14, 14, 18),
	Secondary = Color3.fromRGB(30, 30, 38), 
	Sidebar = Color3.fromRGB(20, 20, 26),    
	Border = Color3.fromRGB(45, 45, 55),    
	Accent = Color3.fromRGB(255, 255, 255),  
	Text = Color3.fromRGB(250, 250, 255),
	TextMuted = Color3.fromRGB(130, 130, 140),
	CloseHover = Color3.fromRGB(240, 70, 70),
	ButtonBg = Color3.fromRGB(22, 22, 28),
	ToggleBg = Color3.fromRGB(18, 18, 22),
	FocusBorder = Color3.fromRGB(100, 100, 120)
}

-- Sürükleme Fonksiyonu
local function makeDraggable(frame, dragHandle)
	local dragging, dragInput, dragStart, startPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Geometrik Üçgen Oluşturucu
local function createPerfectTriangle(parent, size, position, rotation)
	local triangleFrame = Instance.new("Frame")
	triangleFrame.Size = size
	triangleFrame.Position = position
	triangleFrame.BackgroundColor3 = COLORS.Secondary
	triangleFrame.BorderSizePixel = 0
	triangleFrame.ZIndex = 102
	triangleFrame.Parent = parent

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = rotation
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.499, 0),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
	gradient.Parent = triangleFrame
	return triangleFrame
end

function PremiumLib.CreateWindow(hubName, SubText, LoadingText, LoadingDescription)
	local self = setmetatable({}, PremiumLib)
	self.Tabs = {}
	self.ActiveTab = nil
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PremiumHub_" .. hubName
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	----------------------------------------------------------------
	-- LOADING CONTAINER
	----------------------------------------------------------------
	local LoadingContainer = Instance.new("Frame")
	LoadingContainer.Size = UDim2.new(0, 500, 0, 250)
	LoadingContainer.Position = UDim2.new(0.5, -250, 0.5, -125)
	LoadingContainer.BackgroundTransparency = 1
	LoadingContainer.ZIndex = 100
	LoadingContainer.Parent = ScreenGui
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, 0, 0, 30)
	TitleLabel.Position = UDim2.new(0, 0, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = LoadingText:upper()
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 28
	TitleLabel.TextColor3 = COLORS.Text
	TitleLabel.ZIndex = 101
	TitleLabel.Parent = LoadingContainer
	
	local DescLabel = Instance.new("TextLabel")
	DescLabel.Size = UDim2.new(1, 0, 0, 20)
	DescLabel.Position = UDim2.new(0, 0, 0, 35)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Text = LoadingDescription or "Loading..."
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.TextSize = 13
	DescLabel.TextColor3 = COLORS.TextMuted
	DescLabel.ZIndex = 101
	DescLabel.Parent = LoadingContainer

	----------------------------------------------------------------
	-- GEOMETRİK MATRİS GRUBU
	----------------------------------------------------------------
	local GeometryGroup = Instance.new("Frame")
	GeometryGroup.Size = UDim2.new(0, 100, 0, 100)
	GeometryGroup.Position = UDim2.new(0.5, -50, 0, 100)
	GeometryGroup.BackgroundTransparency = 1
	GeometryGroup.ZIndex = 101
	GeometryGroup.Parent = LoadingContainer

	local triangleSize = UDim2.new(0, 100, 0, 100)
	local LeftTriangle = createPerfectTriangle(GeometryGroup, triangleSize, UDim2.new(0, -120, 0, 0), 45)
	local RightTriangle = createPerfectTriangle(GeometryGroup, triangleSize, UDim2.new(0, 120, 0, 0), -135)

	local CornerBorders = {}
	local borderConfigs = {
		{Size = UDim2.new(0, 2, 0, 0), Pos = UDim2.new(0, -2, 0, -2), Target = UDim2.new(0, 2, 0, 30)},
		{Size = UDim2.new(0, 0, 0, 2), Pos = UDim2.new(0, -2, 0, -2), Target = UDim2.new(0, 30, 0, 2)},
		{Size = UDim2.new(0, 2, 0, 0), Pos = UDim2.new(1, 0, 0, -2), Target = UDim2.new(0, 2, 0, 30)},
		{Size = UDim2.new(0, 0, 0, 2), Pos = UDim2.new(1, -30, 0, -2), Target = UDim2.new(0, 30, 0, 2)},
		{Size = UDim2.new(0, 2, 0, 0), Pos = UDim2.new(1, 0, 1, -30), Target = UDim2.new(0, 2, 0, 30)},
		{Size = UDim2.new(0, 0, 0, 2), Pos = UDim2.new(1, -30, 1, 0), Target = UDim2.new(0, 30, 0, 2)},
		{Size = UDim2.new(0, 2, 0, 0), Pos = UDim2.new(0, -2, 1, -30), Target = UDim2.new(0, 2, 0, 30)},
		{Size = UDim2.new(0, 0, 0, 2), Pos = UDim2.new(0, -2, 1, 0), Target = UDim2.new(0, 30, 0, 2)}
	}
	for i, cfg in ipairs(borderConfigs) do
		local border = Instance.new("Frame")
		border.Size = cfg.Size
		border.Position = cfg.Pos
		border.BackgroundColor3 = COLORS.Accent
		border.BorderSizePixel = 0
		border.ZIndex = 105
		border.Parent = GeometryGroup
		CornerBorders[i] = {Frame = border, TargetSize = cfg.Target}
	end

	local function createSplitBar(rotation)
		local barGroup = Instance.new("Frame")
		barGroup.Size = UDim2.new(0, 140, 0, 2)
		barGroup.Position = UDim2.new(0.5, -70, 0.5, -1)
		barGroup.BackgroundTransparency = 1
		barGroup.Rotation = rotation
		barGroup.ZIndex = 103
		barGroup.Parent = GeometryGroup

		local leftPart = Instance.new("Frame")
		leftPart.Size = UDim2.new(0, 0, 1, 0)
		leftPart.Position = UDim2.new(0.5, 0, 0, 0)
		leftPart.BackgroundColor3 = COLORS.Accent
		leftPart.BorderSizePixel = 0
		leftPart.ZIndex = 104
		leftPart.Parent = barGroup

		local rightPart = Instance.new("Frame")
		rightPart.Size = UDim2.new(0, 0, 1, 0)
		rightPart.Position = UDim2.new(0.5, 0, 0, 0)
		rightPart.BackgroundColor3 = COLORS.Accent
		rightPart.BorderSizePixel = 0
		rightPart.ZIndex = 104
		rightPart.Parent = barGroup
		
		return {Group = barGroup, Left = leftPart, Right = rightPart}
	end

	local Bar1 = createSplitBar(-45)
	local Bar2 = createSplitBar(45)

    

	----------------------------------------------------------------
	-- MAIN WINDOW STRUCTURE
	----------------------------------------------------------------
	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 560, 0, 360)
	MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
	MainFrame.BackgroundColor3 = COLORS.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.BackgroundTransparency = 1
	MainFrame.Visible = false
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

	local WindowBorder = Instance.new("UIStroke")
	WindowBorder.Color = COLORS.Border
	WindowBorder.Thickness = 1.2
	WindowBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	WindowBorder.Parent = MainFrame
	
	-- Top Bar
	local TopBarFrame = Instance.new("Frame")
	TopBarFrame.Size = UDim2.new(1, 0, 0, 45)
	TopBarFrame.BackgroundTransparency = 1
	TopBarFrame.Parent = MainFrame
	makeDraggable(MainFrame, TopBarFrame)
	
	local ListLayout = Instance.new("UIListLayout")
	ListLayout.FillDirection = Enum.FillDirection.Horizontal
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ListLayout.Padding = UDim.new(0, 10)
	ListLayout.Parent = TopBarFrame

	local WindowTitle = Instance.new("TextLabel")
	WindowTitle.AutomaticSize = Enum.AutomaticSize.X
	WindowTitle.Size = UDim2.new(0, 0, 1, 0)
	WindowTitle.BackgroundTransparency = 1
	WindowTitle.Text = hubName
	WindowTitle.Font = Enum.Font.GothamBold
	WindowTitle.TextSize = 16
	WindowTitle.TextColor3 = COLORS.Text
	WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
	WindowTitle.LayoutOrder = 1
	WindowTitle.Parent = TopBarFrame

	local WindowSubTitle = Instance.new("TextLabel")
	WindowSubTitle.AutomaticSize = Enum.AutomaticSize.X
	WindowSubTitle.Size = UDim2.new(0, 0, 1, 0)
	WindowSubTitle.BackgroundTransparency = 1
	WindowSubTitle.Text = SubText
	WindowSubTitle.Font = Enum.Font.GothamBold
	WindowSubTitle.TextSize = 12
	WindowSubTitle.TextColor3 = COLORS.Text
	WindowSubTitle.TextXAlignment = Enum.TextXAlignment.Left
	WindowSubTitle.LayoutOrder = 2
	WindowSubTitle.Parent = TopBarFrame

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, 0, 1, -45)
	ContentContainer.Position = UDim2.new(0, 0, 0, 45)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	----------------------------------------------------------------
	-- SIDEBAR & SMART SCROLL
	----------------------------------------------------------------
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 150, 1, 0)
	Sidebar.BackgroundColor3 = COLORS.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = ContentContainer

	local SidebarLine = Instance.new("Frame")
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)
	SidebarLine.Position = UDim2.new(1, -1, 0, 0)
	SidebarLine.BackgroundColor3 = COLORS.Border
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar

	local TabButtonList = Instance.new("ScrollingFrame")
	TabButtonList.Size = UDim2.new(1, -5, 1, -10)
	TabButtonList.Position = UDim2.new(0, 0, 0, 5)
	TabButtonList.BackgroundTransparency = 1
	TabButtonList.BorderSizePixel = 0
	TabButtonList.ScrollBarThickness = 2
	TabButtonList.ScrollBarImageColor3 = COLORS.Border
	TabButtonList.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabButtonList.ScrollingDirection = Enum.ScrollingDirection.Y
	TabButtonList.Parent = Sidebar

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Padding = UDim.new(0, 5)
	TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabListLayout.Parent = TabButtonList

	TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local contentHeight = TabListLayout.AbsoluteContentSize.Y
		TabButtonList.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 10)
		if contentHeight <= TabButtonList.AbsoluteSize.Y then
			TabButtonList.ScrollBarThickness = 0
		else
			TabButtonList.ScrollBarThickness = 2
		end
	end)

	local TabPagesContainer = Instance.new("Frame")
	TabPagesContainer.Size = UDim2.new(1, -150, 1, 0)
	TabPagesContainer.Position = UDim2.new(0, 150, 0, 0)
	TabPagesContainer.BackgroundTransparency = 1
	TabPagesContainer.Parent = ContentContainer

	----------------------------------------------------------------
	-- WINDOW CONTROLS
	----------------------------------------------------------------
	local ButtonContainer = Instance.new("Frame")
	ButtonContainer.Size = UDim2.new(0, 70, 1, 0)
	ButtonContainer.Position = UDim2.new(1, -75, 0, 0)
	ButtonContainer.BackgroundTransparency = 1
	ButtonContainer.Parent = TopBarFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 8)
	UIListLayout.Parent = ButtonContainer

	local function createTopButton(text, layoutOrder)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 26, 0, 26)
		btn.BackgroundTransparency = 1
		btn.Text = text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.TextColor3 = COLORS.TextMuted
		btn.LayoutOrder = layoutOrder
		btn.AutoButtonColor = false
		btn.Parent = ButtonContainer
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		return btn
	end

	local MinimizeBtn = createTopButton("-", 1)
	local CloseBtn = createTopButton("×", 2)
	CloseBtn.TextSize = 18

	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = COLORS.CloseHover, TextColor3 = COLORS.Accent}):Play()
	end)
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = COLORS.TextMuted}):Play()
	end)

	MinimizeBtn.MouseEnter:Connect(function()
		TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = COLORS.Secondary, TextColor3 = COLORS.Accent}):Play()
	end)
	MinimizeBtn.MouseLeave:Connect(function()
		TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = COLORS.TextMuted}):Play()
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 500, 0, 0), BackgroundTransparency = 1})
		closeTween:Play()
		closeTween.Completed:Connect(function() ScreenGui:Destroy() end)
	end)

	local isMinimized = false
	MinimizeBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			ContentContainer.Visible = false
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, 45)}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, 360)}):Play()
			task.wait(0.2)
			ContentContainer.Visible = true
		end
	end)

	----------------------------------------------------------------
	-- TAB ENGINE & COMPONENT CREATORS
	----------------------------------------------------------------
	function self:CreateTab(tabName)
		local tabData = {}
		
		-- Sol Sekme Butonu
		local TabButton = Instance.new("TextButton")
		TabButton.Size = UDim2.new(0, 135, 0, 34)
		TabButton.BackgroundTransparency = 1
		TabButton.Text = "   " .. tabName
		TabButton.Font = Enum.Font.GothamMedium
		TabButton.TextSize = 13
		TabButton.TextColor3 = COLORS.TextMuted
		TabButton.TextXAlignment = Enum.TextXAlignment.Left
		TabButton.AutoButtonColor = false
		TabButton.Parent = TabButtonList
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 3, 0, 0)
		Indicator.Position = UDim2.new(0, 0, 0.5, 0)
		Indicator.BackgroundColor3 = COLORS.Accent
		Indicator.BorderSizePixel = 0
		Indicator.Parent = TabButton

		-- Sağ Sayfa Alanı
		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, -20, 1, -20)
		Page.Position = UDim2.new(0, 10, 0, 10)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = COLORS.Border
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.ScrollingDirection = Enum.ScrollingDirection.Y
		Page.Visible = false
		Page.Parent = TabPagesContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 6)
		PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		PageLayout.Parent = Page

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local pageHeight = PageLayout.AbsoluteContentSize.Y
			Page.CanvasSize = UDim2.new(0, 0, 0, pageHeight + 10)
			if pageHeight <= Page.AbsoluteSize.Y then
				Page.ScrollBarThickness = 0
			else
				Page.ScrollBarThickness = 3
			end
		end)
        		------------------------------------------------------------
		-- SPECIAL SUB-SYSTEM: SECTION & SUB-TAB SYSTEM
		------------------------------------------------------------
		function tabData:CreateSection(sectionTitle)
			local sectionInstance = {}
			
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Size = UDim2.new(1, -10, 0, 28)
			SectionFrame.BackgroundTransparency = 1
			SectionFrame.Parent = Page
			
			local SectionLabel = Instance.new("TextLabel")
			SectionLabel.Size = UDim2.new(1, -10, 1, 0)
			SectionLabel.Position = UDim2.new(0, 5, 0, 0)
			SectionLabel.BackgroundTransparency = 1
			SectionLabel.Text = sectionTitle:upper()
			SectionLabel.Font = Enum.Font.GothamBold
			SectionLabel.TextSize = 11
			SectionLabel.TextColor3 = COLORS.Accent
			SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			SectionLabel.Parent = SectionFrame
			
			-- Section Başlığını Değiştirme (SetTitle / SetText)
			function sectionInstance:SetTitle(newTitle)
				if typeof(newTitle) == "string" then SectionLabel.Text = newTitle:upper() end
			end
			function sectionInstance:SetText(newText)
				if typeof(newText) == "string" then SectionLabel.Text = newText:upper() end
			end
			
			return sectionInstance
		end

		function tabData:CreateSubTabContainer()
			local subTabContainer = {SubTabs = {}, ActiveSubTab = nil}
			
			-- Sub-Tab Butonlarının Dizileceği Üst Panel
			local SubNavBar = Instance.new("Frame")
			SubNavBar.Size = UDim2.new(1, -10, 0, 30)
			SubNavBar.BackgroundColor3 = COLORS.Sidebar
			SubNavBar.BorderSizePixel = 0
			SubNavBar.Parent = Page
			Instance.new("UICorner", SubNavBar).CornerRadius = UDim.new(0, 6)
			
			local SubNavStroke = Instance.new("UIStroke")
			SubNavStroke.Color = COLORS.Border
			SubNavStroke.Thickness = 1
			SubNavStroke.Parent = SubNavBar
			
			local SubListLayout = Instance.new("UIListLayout")
			SubListLayout.FillDirection = Enum.FillDirection.Horizontal
			SubListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SubListLayout.Padding = UDim.new(0, 2)
			SubListLayout.Parent = SubNavBar
			
			-- Sub-Tab İçeriklerinin (Elementlerinin) Koyulacağı Alt Panel
			local SubPageContainer = Instance.new("Frame")
			SubPageContainer.Size = UDim2.new(1, -10, 0, 0)
			SubPageContainer.AutomaticSize = Enum.AutomaticSize.Y
			SubPageContainer.BackgroundTransparency = 1
			SubPageContainer.Parent = Page
			
			local SubPageLayout = Instance.new("UIListLayout")
			SubPageLayout.Padding = UDim.new(0, 6)
			SubPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			SubPageLayout.Parent = SubPageContainer
			
			function subTabContainer:CreateSubTab(subTabName)
				local subTabData = {}
				
				local SubButton = Instance.new("TextButton")
				SubButton.Size = UDim2.new(0, 100, 1, 0)
				SubButton.BackgroundTransparency = 1
				SubButton.Text = subTabName
				SubButton.Font = Enum.Font.GothamMedium
				SubButton.TextSize = 12
				SubButton.TextColor3 = COLORS.TextMuted
				SubButton.AutoButtonColor = false
				SubButton.Parent = SubNavBar
				Instance.new("UICorner", SubButton).CornerRadius = UDim.new(0, 6)
				
				local SubPage = Instance.new("Frame")
				SubPage.Size = UDim2.new(1, 0, 0, 0)
				SubPage.AutomaticSize = Enum.AutomaticSize.Y
				SubPage.BackgroundTransparency = 1
				SubPage.Visible = false
				SubPage.Parent = SubPageContainer
				
				local SubInnerLayout = Instance.new("UIListLayout")
				SubInnerLayout.Padding = UDim.new(0, 6)
				SubInnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				SubInnerLayout.Parent = SubPage
				
				-- Ana Tab fonksiyonlarını Sub-Tab'e miras bırakıyoruz
				subTabData.CreateButton = function(_, ...) return tabData.CreateButton({Page = SubPage}, ...) end
				subTabData.CreateToggle = function(_, ...) return tabData.CreateToggle({Page = SubPage}, ...) end
				subTabData.CreateTextBox = function(_, ...) return tabData.CreateTextBox({Page = SubPage}, ...) end
				subTabData.CreateParagraph = function(_, ...) return tabData.CreateParagraph({Page = SubPage}, ...) end
				subTabData.CreateSection = function(_, ...) return tabData.CreateSection({Page = SubPage}, ...) end
			subTabData.CreateDropdown = function(_, ...) return tabData.CreateDropdown({Page = SubPage}, ...) end
			subTabData.CreateMultiDropdown = function(_, ...) return tabData.CreateMultiDropdown({Page = SubPage}, ...) end
			subTabData.CreateSlider = function(_, ...) return tabData.CreateSlider({Page = SubPage}, ...) end
			subTabData.CreateColorPicker = function(_, ...) return tabData.CreateColorPicker({Page = SubPage}, ...) end
			subTabData.CreateKeybind = function(_, ...) return tabData.CreateKeybind({Page = SubPage}, ...) end
				
				local function selectSubTab()
					if subTabContainer.ActiveSubTab == subTabData then return end
					if subTabContainer.ActiveSubTab then
						local prev = subTabContainer.ActiveSubTab
						prev.Button.BackgroundTransparency = 1
						prev.Button.TextColor3 = COLORS.TextMuted
						prev.Page.Visible = false
					end
					subTabContainer.ActiveSubTab = subTabData
					SubButton.BackgroundTransparency = 0.9
					SubButton.BackgroundColor3 = COLORS.Accent
					SubButton.TextColor3 = COLORS.Text
					SubPage.Visible = true
				end
				
				SubButton.MouseButton1Click:Connect(selectSubTab)
				subTabData.Button = SubButton
				subTabData.Page = SubPage
				
				-- Başlık değiştirme modifierları
				function subTabData:SetTitle(newTitle)
					if typeof(newTitle) == "string" then SubButton.Text = newTitle end
				end
				function subTabData:SetText(newText)
					if typeof(newText) == "string" then SubButton.Text = newText end
				end
				
				if #subTabContainer.SubTabs == 0 then
					selectSubTab()
				end
				
				table.insert(subTabContainer.SubTabs, subTabData)
				return subTabData
			end
			
			return subTabContainer
		end
		
		tabData.Button = TabButton
		tabData.Page = Page
		tabData.Indicator = Indicator

		local function selectThisTab()
			if self.ActiveTab == tabData then return end
			if self.ActiveTab then
				local prev = self.ActiveTab
				TweenService:Create(prev.Button, TweenInfo.new(0.2), {TextColor3 = COLORS.TextMuted, BackgroundTransparency = 1}):Play()
				TweenService:Create(prev.Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}):Play()
				local fadeOut = TweenService:Create(prev.Page, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 10, 0, 20)})
				fadeOut:Play()
				fadeOut.Completed:Connect(function() prev.Page.Visible = false end)
			end

			self.ActiveTab = tabData
			TabButton.BackgroundTransparency = 0.92
			TabButton.BackgroundColor3 = COLORS.Accent
			TweenService:Create(TabButton, TweenInfo.new(0.25), {TextColor3 = COLORS.Text}):Play()
			TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 0, 0.5, -9)}):Play()
			
			Page.Position = UDim2.new(0, 10, 0, 0)
			Page.Visible = true
			TweenService:Create(Page, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0, 10, 0, 10)}):Play()
		end

		TabButton.MouseButton1Click:Connect(selectThisTab)

		if #self.Tabs == 0 then
			task.spawn(function()
				repeat task.wait() until MainFrame.Visible == true
				selectThisTab()
			end)
		end

		table.insert(self.Tabs, tabData)
		
		------------------------------------------------------------
		-- ELEMENT 1: BORDERLI BUTTON
		------------------------------------------------------------
				------------------------------------------------------------
		-- ELEMENT 1: BORDERLI BUTTON
		------------------------------------------------------------
		function tabData:CreateButton(btnText, callback)
			local btnInstance = {}
			
			local Button = Instance.new("TextButton")
			Button.Size = UDim2.new(1, -10, 0, 38)
			Button.BackgroundColor3 = COLORS.ButtonBg
			Button.BorderSizePixel = 0
			Button.Text = btnText
			Button.Font = Enum.Font.GothamMedium
			Button.TextSize = 14
			Button.TextColor3 = COLORS.Text
			Button.AutoButtonColor = false
			Button.Parent = Page
			
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
			
			local BtnBorder = Instance.new("UIStroke")
			BtnBorder.Color = COLORS.Border
			BtnBorder.Thickness = 1
			BtnBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			BtnBorder.Parent = Button

			Button.MouseEnter:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Secondary}):Play()
				TweenService:Create(BtnBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play()
			end)
			Button.MouseLeave:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonBg}):Play()
				TweenService:Create(BtnBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play()
			end)
			Button.MouseButton1Down:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.05), {Size = UDim2.new(1, -16, 0, 36)}):Play()
			end)
			Button.MouseButton1Up:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 38)}):Play()
				if callback then callback() end
			end)
			
			-- [SETTER 1] Dışarıdan Buton Yazısını Değiştirme (Eski Metot)
			function btnInstance:SetText(newText)
				Button.Text = newText
			end

			-- [SETTER 2] Dışarıdan Buton Başlığını Değiştirme (Yeni İstediğin Metot)
			function btnInstance:SetTitle(newTitle)
				Button.Text = newTitle
			end
			
			return btnInstance
		end
		

		------------------------------------------------------------
		-- ELEMENT 2: ANIMATED TOGGLE
		------------------------------------------------------------
		function tabData:CreateToggle(toggleText, defaultState, callback)
			local toggleData = {State = defaultState or false}
			
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
			ToggleFrame.BackgroundColor3 = COLORS.ButtonBg
			ToggleFrame.BorderSizePixel = 0
			ToggleFrame.Parent = Page
			Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

			local ToggleBorder = Instance.new("UIStroke")
			ToggleBorder.Color = COLORS.Border
			ToggleBorder.Thickness = 1
			ToggleBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ToggleBorder.Parent = ToggleFrame

			local ToggleLabel = Instance.new("TextLabel")
			ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
			ToggleLabel.Position = UDim2.new(0, 14, 0, 0)
			ToggleLabel.BackgroundTransparency = 1
			ToggleLabel.Text = toggleText
			ToggleLabel.Font = Enum.Font.GothamMedium
			ToggleLabel.TextSize = 14
			ToggleLabel.TextColor3 = COLORS.Text
			ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
			ToggleLabel.Parent = ToggleFrame

			local SwitchTrack = Instance.new("TextButton")
			SwitchTrack.Size = UDim2.new(0, 38, 0, 20)
			SwitchTrack.Position = UDim2.new(1, -52, 0.5, -10)
			SwitchTrack.BackgroundColor3 = COLORS.ToggleBg
			SwitchTrack.BorderSizePixel = 0
			SwitchTrack.Text = ""
			SwitchTrack.AutoButtonColor = false
			SwitchTrack.Parent = ToggleFrame
			Instance.new("UICorner", SwitchTrack).CornerRadius = UDim.new(1, 0)

			local TrackBorder = Instance.new("UIStroke")
			TrackBorder.Color = COLORS.Border
			TrackBorder.Thickness = 1
			TrackBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			TrackBorder.Parent = SwitchTrack

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0, 14, 0, 14)
			Circle.Position = toggleData.State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			Circle.BackgroundColor3 = toggleData.State and COLORS.Background or COLORS.TextMuted
			Circle.BorderSizePixel = 0
			Circle.Parent = SwitchTrack
			Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

			if toggleData.State then
				SwitchTrack.BackgroundColor3 = COLORS.Accent
				TrackBorder.Color = COLORS.Accent
			end

			local function updateToggle(fireCallback)
				local targetPos = toggleData.State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
				local targetTrackColor = toggleData.State and COLORS.Accent or COLORS.ToggleBg
				local targetCircleColor = toggleData.State and COLORS.Background or COLORS.TextMuted
				local targetBorderColor = toggleData.State and COLORS.Accent or COLORS.Border

				TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos, BackgroundColor3 = targetCircleColor}):Play()
				TweenService:Create(SwitchTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetTrackColor}):Play()
				TweenService:Create(TrackBorder, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Color = targetBorderColor}):Play()
				if fireCallback and callback then callback(toggleData.State) end
			end

			SwitchTrack.MouseButton1Click:Connect(function()
				toggleData.State = not toggleData.State
				updateToggle(true)
			end)
			
			ToggleFrame.MouseEnter:Connect(function() TweenService:Create(ToggleBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play() end)
			ToggleFrame.MouseLeave:Connect(function() TweenService:Create(ToggleBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play() end)

			-- [SETTER] Dışarıdan Toggle Durumunu Değiştirme metotları
			function toggleData:SetState(newState)
				toggleData.State = newState
				updateToggle(true) -- Callback tetiklensin istersek true yapıyoruz
			end
			
			function toggleData:SetText(newText)
				ToggleLabel.Text = newText
			end

			return toggleData
		end

		------------------------------------------------------------
		-- ELEMENT 3: TEXTBOX (GİRİŞ ALANI)
		------------------------------------------------------------
		function tabData:CreateTextBox(placeholder, def, callback)
			local tbInstance = {}
			
			local TextBoxFrame = Instance.new("Frame")
			TextBoxFrame.Size = UDim2.new(1, -10, 0, 42)
			TextBoxFrame.BackgroundColor3 = COLORS.ButtonBg
			TextBoxFrame.BorderSizePixel = 0
			TextBoxFrame.Parent = Page
			Instance.new("UICorner", TextBoxFrame).CornerRadius = UDim.new(0, 8)

			local TBBorder = Instance.new("UIStroke")
			TBBorder.Color = COLORS.Border
			TBBorder.Thickness = 1
			TBBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			TBBorder.Parent = TextBoxFrame

			local ActualTextBox = Instance.new("TextBox")
			ActualTextBox.Size = UDim2.new(1, -20, 1, 0)
			ActualTextBox.Position = UDim2.new(0, 10, 0, 0)
			ActualTextBox.BackgroundTransparency = 1
			ActualTextBox.Font = Enum.Font.GothamMedium
			ActualTextBox.TextSize = 13
			ActualTextBox.TextColor3 = COLORS.Text
			ActualTextBox.PlaceholderText = placeholder or "Enter text..."
			ActualTextBox.PlaceholderColor3 = COLORS.TextMuted
			ActualTextBox.TextXAlignment = Enum.TextXAlignment.Left
			ActualTextBox.ClearTextOnFocus = false
			ActualTextBox.Parent = TextBoxFrame
			ActualTextBox.Text = def
			
			ActualTextBox.Focused:Connect(function()
				TweenService:Create(TBBorder, TweenInfo.new(0.25), {Color = COLORS.FocusBorder, Thickness = 1.2}):Play()
			end)
			ActualTextBox.FocusLost:Connect(function(enterPressed)
				TweenService:Create(TBBorder, TweenInfo.new(0.25), {Color = COLORS.Border, Thickness = 1}):Play()
				if enterPressed and callback then
					callback(ActualTextBox.Text)
				end
			end)

			-- [SETTER] Dışarıdan TextBox İçeriğini Değiştirme
			function tbInstance:SetText(newText)
				ActualTextBox.Text = newText
			end

			return tbInstance
		end

		------------------------------------------------------------
		-- ELEMENT 4: PARAGRAPH (BİLGİLENDİRME METNİ)
		------------------------------------------------------------
		function tabData:CreateParagraph(title, content)
			local paragraphInstance = {}
			
			local ParagraphFrame = Instance.new("Frame")
			ParagraphFrame.Size = UDim2.new(1, -10, 0, 60)
			ParagraphFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
			ParagraphFrame.BorderSizePixel = 0
			ParagraphFrame.Parent = Page
			Instance.new("UICorner", ParagraphFrame).CornerRadius = UDim.new(0, 8)

			local PBorder = Instance.new("UIStroke")
			PBorder.Color = COLORS.Border
			PBorder.Thickness = 0.8
			PBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			PBorder.Parent = ParagraphFrame

			local PTitle = Instance.new("TextLabel")
			PTitle.Size = UDim2.new(1, -20, 0, 22)
			PTitle.Position = UDim2.new(0, 12, 0, 6)
			PTitle.BackgroundTransparency = 1
			PTitle.Text = title
			PTitle.Font = Enum.Font.GothamBold
			PTitle.TextSize = 13
			PTitle.TextColor3 = COLORS.Text
			PTitle.TextXAlignment = Enum.TextXAlignment.Left
			PTitle.Parent = ParagraphFrame

			local PContent = Instance.new("TextLabel")
			PContent.Size = UDim2.new(1, -24, 0, 0)
			PContent.Position = UDim2.new(0, 12, 0, 26)
			PContent.BackgroundTransparency = 1
			PContent.Text = content
			PContent.Font = Enum.Font.Gotham
			PContent.TextSize = 12
			PContent.TextColor3 = COLORS.TextMuted
			PContent.TextXAlignment = Enum.TextXAlignment.Left
			PContent.TextYAlignment = Enum.TextYAlignment.Top
			PContent.TextWrapped = true
			PContent.Parent = ParagraphFrame

			local function dynamicResize()
				local textHeight = PContent.TextBounds.Y
				PContent.Size = UDim2.new(1, -24, 0, textHeight)
				ParagraphFrame.Size = UDim2.new(1, -10, 0, textHeight + 36)
			end
			
			task.spawn(dynamicResize)
			PContent:GetPropertyChangedSignal("Text"):Connect(dynamicResize)

			-- [SETTER] Dışarıdan Paragraph Başlığını ve İçeriğini Güncelleme
			function paragraphInstance:SetText(newTitle, newContent)
				if newTitle then PTitle.Text = newTitle end
				if newContent then PContent.Text = newContent end
			end

			return paragraphInstance
		end

		------------------------------------------------------------
		-- ELEMENT 5: DROPDOWN (TEK SEÇİMLİ AÇILIR LİSTE)
		------------------------------------------------------------
		function tabData:CreateDropdown(dropdownText, options, defaultOption, callback)
			local ddInstance = {Value = defaultOption, Options = options or {}}
			local isOpen = false

			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size = UDim2.new(1, -10, 0, 42)
			DropdownFrame.BackgroundColor3 = COLORS.ButtonBg
			DropdownFrame.BorderSizePixel = 0
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.ZIndex = 20
			DropdownFrame.Parent = Page
			Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)

			local DDBorder = Instance.new("UIStroke")
			DDBorder.Color = COLORS.Border
			DDBorder.Thickness = 1
			DDBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			DDBorder.Parent = DropdownFrame

			local HeaderBtn = Instance.new("TextButton")
			HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
			HeaderBtn.BackgroundTransparency = 1
			HeaderBtn.Text = ""
			HeaderBtn.AutoButtonColor = false
			HeaderBtn.ZIndex = 21
			HeaderBtn.Parent = DropdownFrame

			local DDLabel = Instance.new("TextLabel")
			DDLabel.Size = UDim2.new(1, -80, 0, 42)
			DDLabel.Position = UDim2.new(0, 14, 0, 0)
			DDLabel.BackgroundTransparency = 1
			DDLabel.Text = dropdownText
			DDLabel.Font = Enum.Font.GothamMedium
			DDLabel.TextSize = 14
			DDLabel.TextColor3 = COLORS.Text
			DDLabel.TextXAlignment = Enum.TextXAlignment.Left
			DDLabel.ZIndex = 21
			DDLabel.Parent = DropdownFrame

			local DDValue = Instance.new("TextLabel")
			DDValue.Size = UDim2.new(0, 150, 0, 42)
			DDValue.Position = UDim2.new(1, -180, 0, 0)
			DDValue.BackgroundTransparency = 1
			DDValue.Text = tostring(defaultOption or "Select...")
			DDValue.Font = Enum.Font.Gotham
			DDValue.TextSize = 12
			DDValue.TextColor3 = COLORS.TextMuted
			DDValue.TextXAlignment = Enum.TextXAlignment.Right
			DDValue.ZIndex = 21
			DDValue.Parent = DropdownFrame

			local Arrow = Instance.new("TextLabel")
			Arrow.Size = UDim2.new(0, 20, 0, 42)
			Arrow.Position = UDim2.new(1, -28, 0, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Text = "▼"
			Arrow.Font = Enum.Font.Gotham
			Arrow.TextSize = 10
			Arrow.TextColor3 = COLORS.TextMuted
			Arrow.ZIndex = 21
			Arrow.Parent = DropdownFrame

			local OptionList = Instance.new("ScrollingFrame")
			OptionList.Size = UDim2.new(1, -10, 0, 0)
			OptionList.Position = UDim2.new(0, 5, 0, 46)
			OptionList.BackgroundTransparency = 1
			OptionList.BorderSizePixel = 0
			OptionList.ScrollBarThickness = 2
			OptionList.ScrollBarImageColor3 = COLORS.Border
			OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
			OptionList.ZIndex = 21
			OptionList.Parent = DropdownFrame

			local OptionLayout = Instance.new("UIListLayout")
			OptionLayout.Padding = UDim.new(0, 4)
			OptionLayout.Parent = OptionList

			local optionButtons = {}

			local function closeDropdown()
				isOpen = false
				TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -10, 0, 42)}):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			end

			local function openDropdown()
				isOpen = true
				local listHeight = math.min(#ddInstance.Options * 30, 150)
				OptionList.Size = UDim2.new(1, -10, 0, listHeight)
				TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, -10, 0, 46 + listHeight + 4)}):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
			end

			local function selectOption(opt)
				ddInstance.Value = opt
				DDValue.Text = tostring(opt)
				closeDropdown()
				if callback then callback(opt) end
			end

			local function rebuildOptions()
				for _, b in ipairs(optionButtons) do b:Destroy() end
				optionButtons = {}
				for i, opt in ipairs(ddInstance.Options) do
					local OptBtn = Instance.new("TextButton")
					OptBtn.Size = UDim2.new(1, 0, 0, 26)
					OptBtn.BackgroundColor3 = COLORS.ToggleBg
					OptBtn.BackgroundTransparency = 0.3
					OptBtn.Text = tostring(opt)
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 12
					OptBtn.TextColor3 = COLORS.TextMuted
					OptBtn.AutoButtonColor = false
					OptBtn.LayoutOrder = i
					OptBtn.ZIndex = 22
					OptBtn.Parent = OptionList
					Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6)

					OptBtn.MouseEnter:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.15), {TextColor3 = COLORS.Text}):Play()
					end)
					OptBtn.MouseLeave:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.15), {TextColor3 = COLORS.TextMuted}):Play()
					end)
					OptBtn.MouseButton1Click:Connect(function() selectOption(opt) end)

					table.insert(optionButtons, OptBtn)
				end
				OptionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					OptionList.CanvasSize = UDim2.new(0, 0, 0, OptionLayout.AbsoluteContentSize.Y)
				end)
			end

			rebuildOptions()

			HeaderBtn.MouseButton1Click:Connect(function()
				if isOpen then closeDropdown() else openDropdown() end
			end)

			DropdownFrame.MouseEnter:Connect(function() TweenService:Create(DDBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play() end)
			DropdownFrame.MouseLeave:Connect(function() TweenService:Create(DDBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play() end)

			-- [SETTER] Dışarıdan Seçili Değeri Değiştirme
			function ddInstance:SetValue(newValue)
				selectOption(newValue)
			end

			-- [SETTER] Dışarıdan Seçenek Listesini Güncelleme
			function ddInstance:SetOptions(newOptions)
				ddInstance.Options = newOptions
				rebuildOptions()
			end

			function ddInstance:SetText(newText)
				DDLabel.Text = newText
			end

			return ddInstance
		end

		------------------------------------------------------------
		-- ELEMENT 6: MULTI-DROPDOWN (ÇOKLU SEÇİMLİ AÇILIR LİSTE)
		------------------------------------------------------------
		function tabData:CreateMultiDropdown(dropdownText, options, defaultOptions, callback)
			local mddInstance = {Value = {}, Options = options or {}}
			for _, v in ipairs(defaultOptions or {}) do mddInstance.Value[v] = true end
			local isOpen = false

			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size = UDim2.new(1, -10, 0, 42)
			DropdownFrame.BackgroundColor3 = COLORS.ButtonBg
			DropdownFrame.BorderSizePixel = 0
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.ZIndex = 20
			DropdownFrame.Parent = Page
			Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)

			local DDBorder = Instance.new("UIStroke")
			DDBorder.Color = COLORS.Border
			DDBorder.Thickness = 1
			DDBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			DDBorder.Parent = DropdownFrame

			local HeaderBtn = Instance.new("TextButton")
			HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
			HeaderBtn.BackgroundTransparency = 1
			HeaderBtn.Text = ""
			HeaderBtn.AutoButtonColor = false
			HeaderBtn.ZIndex = 21
			HeaderBtn.Parent = DropdownFrame

			local DDLabel = Instance.new("TextLabel")
			DDLabel.Size = UDim2.new(1, -80, 0, 42)
			DDLabel.Position = UDim2.new(0, 14, 0, 0)
			DDLabel.BackgroundTransparency = 1
			DDLabel.Text = dropdownText
			DDLabel.Font = Enum.Font.GothamMedium
			DDLabel.TextSize = 14
			DDLabel.TextColor3 = COLORS.Text
			DDLabel.TextXAlignment = Enum.TextXAlignment.Left
			DDLabel.ZIndex = 21
			DDLabel.Parent = DropdownFrame

			local DDValue = Instance.new("TextLabel")
			DDValue.Size = UDim2.new(0, 150, 0, 42)
			DDValue.Position = UDim2.new(1, -180, 0, 0)
			DDValue.BackgroundTransparency = 1
			DDValue.Text = (#(defaultOptions or {}) > 0) and (#defaultOptions .. " selected") or "None"
			DDValue.Font = Enum.Font.Gotham
			DDValue.TextSize = 12
			DDValue.TextColor3 = COLORS.TextMuted
			DDValue.TextXAlignment = Enum.TextXAlignment.Right
			DDValue.ZIndex = 21
			DDValue.Parent = DropdownFrame

			local Arrow = Instance.new("TextLabel")
			Arrow.Size = UDim2.new(0, 20, 0, 42)
			Arrow.Position = UDim2.new(1, -28, 0, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Text = "▼"
			Arrow.Font = Enum.Font.Gotham
			Arrow.TextSize = 10
			Arrow.TextColor3 = COLORS.TextMuted
			Arrow.ZIndex = 21
			Arrow.Parent = DropdownFrame

			local OptionList = Instance.new("ScrollingFrame")
			OptionList.Size = UDim2.new(1, -10, 0, 0)
			OptionList.Position = UDim2.new(0, 5, 0, 46)
			OptionList.BackgroundTransparency = 1
			OptionList.BorderSizePixel = 0
			OptionList.ScrollBarThickness = 2
			OptionList.ScrollBarImageColor3 = COLORS.Border
			OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
			OptionList.ZIndex = 21
			OptionList.Parent = DropdownFrame

			local OptionLayout = Instance.new("UIListLayout")
			OptionLayout.Padding = UDim.new(0, 4)
			OptionLayout.Parent = OptionList

			local optionButtons = {}

			local function refreshValueLabel()
				local count = 0
				for _, v in pairs(mddInstance.Value) do if v then count = count + 1 end end
				DDValue.Text = (count > 0) and (count .. " selected") or "None"
			end

			local function closeDropdown()
				isOpen = false
				TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -10, 0, 42)}):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			end

			local function openDropdown()
				isOpen = true
				local listHeight = math.min(#mddInstance.Options * 30, 150)
				OptionList.Size = UDim2.new(1, -10, 0, listHeight)
				TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, -10, 0, 46 + listHeight + 4)}):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
			end

			local function rebuildOptions()
				for _, b in ipairs(optionButtons) do b:Destroy() end
				optionButtons = {}
				for i, opt in ipairs(mddInstance.Options) do
					local selected = mddInstance.Value[opt] == true
					local OptBtn = Instance.new("TextButton")
					OptBtn.Size = UDim2.new(1, 0, 0, 26)
					OptBtn.BackgroundColor3 = selected and COLORS.Accent or COLORS.ToggleBg
					OptBtn.BackgroundTransparency = selected and 0.85 or 0.3
					OptBtn.Text = (selected and "✓ " or "    ") .. tostring(opt)
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 12
					OptBtn.TextColor3 = selected and COLORS.Text or COLORS.TextMuted
					OptBtn.AutoButtonColor = false
					OptBtn.LayoutOrder = i
					OptBtn.ZIndex = 22
					OptBtn.Parent = OptionList
					Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6)

					OptBtn.MouseButton1Click:Connect(function()
						mddInstance.Value[opt] = not mddInstance.Value[opt]
						refreshValueLabel()
						rebuildOptions()
						if callback then callback(mddInstance.Value) end
					end)

					table.insert(optionButtons, OptBtn)
				end
				OptionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					OptionList.CanvasSize = UDim2.new(0, 0, 0, OptionLayout.AbsoluteContentSize.Y)
				end)
			end

			rebuildOptions()

			HeaderBtn.MouseButton1Click:Connect(function()
				if isOpen then closeDropdown() else openDropdown() end
			end)

			DropdownFrame.MouseEnter:Connect(function() TweenService:Create(DDBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play() end)
			DropdownFrame.MouseLeave:Connect(function() TweenService:Create(DDBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play() end)

			-- [SETTER] Dışarıdan Seçili Değerleri Değiştirme
			function mddInstance:SetValue(newValues)
				mddInstance.Value = {}
				for _, v in ipairs(newValues) do mddInstance.Value[v] = true end
				refreshValueLabel()
				rebuildOptions()
				if callback then callback(mddInstance.Value) end
			end

			function mddInstance:SetOptions(newOptions)
				mddInstance.Options = newOptions
				rebuildOptions()
			end

			function mddInstance:SetText(newText)
				DDLabel.Text = newText
			end

			return mddInstance
		end

		------------------------------------------------------------
		-- ELEMENT 7: SLIDER (SAYISAL DEĞER SEÇİCİ)
		------------------------------------------------------------
		function tabData:CreateSlider(sliderText, minValue, maxValue, defaultValue, callback)
			local sliderInstance = {Value = defaultValue or minValue}
			local dragging = false

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, -10, 0, 50)
			SliderFrame.BackgroundColor3 = COLORS.ButtonBg
			SliderFrame.BorderSizePixel = 0
			SliderFrame.Parent = Page
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

			local SliderBorder = Instance.new("UIStroke")
			SliderBorder.Color = COLORS.Border
			SliderBorder.Thickness = 1
			SliderBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			SliderBorder.Parent = SliderFrame

			local SliderLabel = Instance.new("TextLabel")
			SliderLabel.Size = UDim2.new(1, -80, 0, 24)
			SliderLabel.Position = UDim2.new(0, 14, 0, 4)
			SliderLabel.BackgroundTransparency = 1
			SliderLabel.Text = sliderText
			SliderLabel.Font = Enum.Font.GothamMedium
			SliderLabel.TextSize = 14
			SliderLabel.TextColor3 = COLORS.Text
			SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
			SliderLabel.Parent = SliderFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size = UDim2.new(0, 60, 0, 24)
			ValueLabel.Position = UDim2.new(1, -74, 0, 4)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(sliderInstance.Value)
			ValueLabel.Font = Enum.Font.GothamBold
			ValueLabel.TextSize = 13
			ValueLabel.TextColor3 = COLORS.TextMuted
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = SliderFrame

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(1, -28, 0, 6)
			Track.Position = UDim2.new(0, 14, 0, 34)
			Track.BackgroundColor3 = COLORS.ToggleBg
			Track.BorderSizePixel = 0
			Track.Parent = SliderFrame
			Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

			local TrackStroke = Instance.new("UIStroke")
			TrackStroke.Color = COLORS.Border
			TrackStroke.Thickness = 1
			TrackStroke.Parent = Track

			local Fill = Instance.new("Frame")
			local initialPct = (sliderInstance.Value - minValue) / math.max((maxValue - minValue), 0.0001)
			Fill.Size = UDim2.new(initialPct, 0, 1, 0)
			Fill.BackgroundColor3 = COLORS.Accent
			Fill.BorderSizePixel = 0
			Fill.Parent = Track
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 14, 0, 14)
			Knob.AnchorPoint = Vector2.new(0.5, 0.5)
			Knob.Position = UDim2.new(initialPct, 0, 0.5, 0)
			Knob.BackgroundColor3 = COLORS.Text
			Knob.BorderSizePixel = 0
			Knob.ZIndex = 5
			Knob.Parent = Track
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

			local function setFromAlpha(alpha, fireCallback)
				alpha = math.clamp(alpha, 0, 1)
				local rawValue = minValue + (maxValue - minValue) * alpha
				local stepped = math.floor(rawValue + 0.5)
				sliderInstance.Value = stepped
				local pct = (stepped - minValue) / math.max((maxValue - minValue), 0.0001)
				Fill.Size = UDim2.new(pct, 0, 1, 0)
				Knob.Position = UDim2.new(pct, 0, 0.5, 0)
				ValueLabel.Text = tostring(stepped)
				if fireCallback and callback then callback(stepped) end
			end

			local function inputToAlpha(inputPos)
				local trackAbsPos = Track.AbsolutePosition.X
				local trackAbsSize = Track.AbsoluteSize.X
				return (inputPos - trackAbsPos) / math.max(trackAbsSize, 1)
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					setFromAlpha(inputToAlpha(input.Position.X), true)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					setFromAlpha(inputToAlpha(input.Position.X), true)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			SliderFrame.MouseEnter:Connect(function() TweenService:Create(SliderBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play() end)
			SliderFrame.MouseLeave:Connect(function() TweenService:Create(SliderBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play() end)

			-- [SETTER] Dışarıdan Slider Değerini Değiştirme
			function sliderInstance:SetValue(newValue)
				local alpha = (newValue - minValue) / math.max((maxValue - minValue), 0.0001)
				setFromAlpha(alpha, true)
			end

			function sliderInstance:SetText(newText)
				SliderLabel.Text = newText
			end

			return sliderInstance
		end

		------------------------------------------------------------
		-- ELEMENT 8: COLORPICKER (RENK SEÇİCİ)
		------------------------------------------------------------
		function tabData:CreateColorPicker(pickerText, defaultColor, callback)
			local cpInstance = {Value = defaultColor or Color3.fromRGB(255, 255, 255)}
			local isOpen = false
			local h, s, v = Color3.toHSV(cpInstance.Value)

			local PickerFrame = Instance.new("Frame")
			PickerFrame.Size = UDim2.new(1, -10, 0, 42)
			PickerFrame.BackgroundColor3 = COLORS.ButtonBg
			PickerFrame.BorderSizePixel = 0
			PickerFrame.ClipsDescendants = true
			PickerFrame.ZIndex = 20
			PickerFrame.Parent = Page
			Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 8)

			local PickerBorder = Instance.new("UIStroke")
			PickerBorder.Color = COLORS.Border
			PickerBorder.Thickness = 1
			PickerBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			PickerBorder.Parent = PickerFrame

			local HeaderBtn = Instance.new("TextButton")
			HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
			HeaderBtn.BackgroundTransparency = 1
			HeaderBtn.Text = ""
			HeaderBtn.AutoButtonColor = false
			HeaderBtn.ZIndex = 21
			HeaderBtn.Parent = PickerFrame

			local PickerLabel = Instance.new("TextLabel")
			PickerLabel.Size = UDim2.new(1, -80, 0, 42)
			PickerLabel.Position = UDim2.new(0, 14, 0, 0)
			PickerLabel.BackgroundTransparency = 1
			PickerLabel.Text = pickerText
			PickerLabel.Font = Enum.Font.GothamMedium
			PickerLabel.TextSize = 14
			PickerLabel.TextColor3 = COLORS.Text
			PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
			PickerLabel.ZIndex = 21
			PickerLabel.Parent = PickerFrame

			local Preview = Instance.new("Frame")
			Preview.Size = UDim2.new(0, 28, 0, 18)
			Preview.Position = UDim2.new(1, -48, 0.5, -9)
			Preview.BackgroundColor3 = cpInstance.Value
			Preview.BorderSizePixel = 0
			Preview.ZIndex = 21
			Preview.Parent = PickerFrame
			Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 5)

			local PreviewStroke = Instance.new("UIStroke")
			PreviewStroke.Color = COLORS.Border
			PreviewStroke.Thickness = 1
			PreviewStroke.Parent = Preview

			-- Açılır Panel
			local Panel = Instance.new("Frame")
			Panel.Size = UDim2.new(1, -20, 0, 150)
			Panel.Position = UDim2.new(0, 10, 0, 46)
			Panel.BackgroundTransparency = 1
			Panel.ZIndex = 21
			Panel.Parent = PickerFrame

			-- SV Box (Saturation/Value)
			local SVBox = Instance.new("ImageButton")
			SVBox.Size = UDim2.new(1, 0, 0, 90)
			SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			SVBox.AutoButtonColor = false
			SVBox.ZIndex = 22
			SVBox.Parent = Panel
			Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 6)

			local SVWhite = Instance.new("Frame")
			SVWhite.Size = UDim2.new(1, 0, 1, 0)
			SVWhite.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SVWhite.BorderSizePixel = 0
			SVWhite.ZIndex = 22
			SVWhite.Parent = SVBox
			Instance.new("UICorner", SVWhite).CornerRadius = UDim.new(0, 6)
			local SVWhiteGradient = Instance.new("UIGradient")
			SVWhiteGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
			SVWhiteGradient.Transparency = NumberSequence.new(0, 1)
			SVWhiteGradient.Parent = SVWhite

			local SVBlack = Instance.new("Frame")
			SVBlack.Size = UDim2.new(1, 0, 1, 0)
			SVBlack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			SVBlack.BorderSizePixel = 0
			SVBlack.ZIndex = 22
			SVBlack.Parent = SVBox
			Instance.new("UICorner", SVBlack).CornerRadius = UDim.new(0, 6)
			local SVBlackGradient = Instance.new("UIGradient")
			SVBlackGradient.Rotation = 90
			SVBlackGradient.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))
			SVBlackGradient.Transparency = NumberSequence.new(0, 1)
			SVBlackGradient.Parent = SVBlack

			local SVCursor = Instance.new("Frame")
			SVCursor.Size = UDim2.new(0, 10, 0, 10)
			SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SVCursor.BorderSizePixel = 0
			SVCursor.ZIndex = 23
			SVCursor.Parent = SVBox
			Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1, 0)
			local SVCursorStroke = Instance.new("UIStroke")
			SVCursorStroke.Color = Color3.fromRGB(0,0,0)
			SVCursorStroke.Thickness = 1.5
			SVCursorStroke.Parent = SVCursor

			-- Hue Bar
			local HueBar = Instance.new("ImageButton")
			HueBar.Size = UDim2.new(1, 0, 0, 16)
			HueBar.Position = UDim2.new(0, 0, 0, 98)
			HueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
			HueBar.AutoButtonColor = false
			HueBar.ZIndex = 22
			HueBar.Parent = Panel
			Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 6)

			local HueGradient = Instance.new("UIGradient")
			HueGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0))
			})
			HueGradient.Parent = HueBar

			local HueCursor = Instance.new("Frame")
			HueCursor.Size = UDim2.new(0, 4, 1, 4)
			HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
			HueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
			HueCursor.BorderSizePixel = 0
			HueCursor.ZIndex = 23
			HueCursor.Parent = HueBar
			Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0, 2)
			local HueCursorStroke = Instance.new("UIStroke")
			HueCursorStroke.Color = Color3.fromRGB(0,0,0)
			HueCursorStroke.Thickness = 1.5
			HueCursorStroke.Parent = HueCursor

			-- Hex Input
			local HexBox = Instance.new("TextBox")
			HexBox.Size = UDim2.new(1, 0, 0, 28)
			HexBox.Position = UDim2.new(0, 0, 0, 122)
			HexBox.BackgroundColor3 = COLORS.ToggleBg
			HexBox.BorderSizePixel = 0
			HexBox.Font = Enum.Font.GothamMedium
			HexBox.TextSize = 13
			HexBox.TextColor3 = COLORS.Text
			HexBox.PlaceholderText = "#FFFFFF"
			HexBox.ClearTextOnFocus = false
			HexBox.Text = string.format("#%02X%02X%02X", cpInstance.Value.R*255, cpInstance.Value.G*255, cpInstance.Value.B*255)
			HexBox.ZIndex = 22
			HexBox.Parent = Panel
			Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0, 6)

			local draggingSV, draggingHue = false, false

			local function updateColor(fireCallback)
				local newColor = Color3.fromHSV(h, s, v)
				cpInstance.Value = newColor
				Preview.BackgroundColor3 = newColor
				SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				HexBox.Text = string.format("#%02X%02X%02X", newColor.R*255, newColor.G*255, newColor.B*255)
				if fireCallback and callback then callback(newColor) end
			end

			local function closeColorPicker()
				isOpen = false
				TweenService:Create(PickerFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -10, 0, 42)}):Play()
			end

			local function openColorPicker()
				isOpen = true
				TweenService:Create(PickerFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, -10, 0, 42 + 160)}):Play()
			end

			HeaderBtn.MouseButton1Click:Connect(function()
				if isOpen then closeColorPicker() else openColorPicker() end
			end)

			SVBox.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSV = true
				end
			end)
			HueBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingHue = true
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSV = false
					draggingHue = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
				if draggingSV then
					local relX = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
					local relY = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
					s = relX
					v = 1 - relY
					SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
					updateColor(true)
				elseif draggingHue then
					local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
					h = relX
					HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
					updateColor(true)
				end
			end)

			HexBox.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					local hexStr = HexBox.Text:gsub("#", "")
					if #hexStr == 6 then
						local r = tonumber(hexStr:sub(1,2), 16)
						local g = tonumber(hexStr:sub(3,4), 16)
						local b = tonumber(hexStr:sub(5,6), 16)
						if r and g and b then
							local newColor = Color3.fromRGB(r, g, b)
							h, s, v = Color3.toHSV(newColor)
							SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
							HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
							updateColor(true)
						end
					end
				end
			end)

			PickerFrame.MouseEnter:Connect(function() TweenService:Create(PickerBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play() end)
			PickerFrame.MouseLeave:Connect(function() TweenService:Create(PickerBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play() end)

			-- [SETTER] Dışarıdan Renk Değerini Değiştirme
			function cpInstance:SetValue(newColor)
				h, s, v = Color3.toHSV(newColor)
				SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
				HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
				updateColor(true)
			end

			function cpInstance:SetText(newText)
				PickerLabel.Text = newText
			end

			return cpInstance
		end

		------------------------------------------------------------
		-- ELEMENT 9: KEYBIND (TUŞ ATAMA)
		------------------------------------------------------------
		function tabData:CreateKeybind(keybindText, defaultKey, callback)
			local kbInstance = {Value = defaultKey or Enum.KeyCode.Unknown}
			local listening = false

			local KeybindFrame = Instance.new("Frame")
			KeybindFrame.Size = UDim2.new(1, -10, 0, 42)
			KeybindFrame.BackgroundColor3 = COLORS.ButtonBg
			KeybindFrame.BorderSizePixel = 0
			KeybindFrame.Parent = Page
			Instance.new("UICorner", KeybindFrame).CornerRadius = UDim.new(0, 8)

			local KBBorder = Instance.new("UIStroke")
			KBBorder.Color = COLORS.Border
			KBBorder.Thickness = 1
			KBBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			KBBorder.Parent = KeybindFrame

			local KBLabel = Instance.new("TextLabel")
			KBLabel.Size = UDim2.new(1, -100, 1, 0)
			KBLabel.Position = UDim2.new(0, 14, 0, 0)
			KBLabel.BackgroundTransparency = 1
			KBLabel.Text = keybindText
			KBLabel.Font = Enum.Font.GothamMedium
			KBLabel.TextSize = 14
			KBLabel.TextColor3 = COLORS.Text
			KBLabel.TextXAlignment = Enum.TextXAlignment.Left
			KBLabel.Parent = KeybindFrame

			local KeyButton = Instance.new("TextButton")
			KeyButton.Size = UDim2.new(0, 80, 0, 26)
			KeyButton.Position = UDim2.new(1, -90, 0.5, -13)
			KeyButton.BackgroundColor3 = COLORS.ToggleBg
			KeyButton.BorderSizePixel = 0
			KeyButton.Text = kbInstance.Value.Name
			KeyButton.Font = Enum.Font.GothamBold
			KeyButton.TextSize = 12
			KeyButton.TextColor3 = COLORS.TextMuted
			KeyButton.AutoButtonColor = false
			KeyButton.Parent = KeybindFrame
			Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0, 6)

			local KeyButtonStroke = Instance.new("UIStroke")
			KeyButtonStroke.Color = COLORS.Border
			KeyButtonStroke.Thickness = 1
			KeyButtonStroke.Parent = KeyButton

			KeyButton.MouseButton1Click:Connect(function()
				listening = true
				KeyButton.Text = "..."
				TweenService:Create(KeyButtonStroke, TweenInfo.new(0.2), {Color = COLORS.Accent}):Play()
			end)

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not listening then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					kbInstance.Value = input.KeyCode
					KeyButton.Text = input.KeyCode.Name
					listening = false
					TweenService:Create(KeyButtonStroke, TweenInfo.new(0.2), {Color = COLORS.Border}):Play()
					if callback then callback(input.KeyCode) end
				end
			end)

			KeybindFrame.MouseEnter:Connect(function() TweenService:Create(KBBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 80, 95)}):Play() end)
			KeybindFrame.MouseLeave:Connect(function() TweenService:Create(KBBorder, TweenInfo.new(0.2), {Color = COLORS.Border}):Play() end)

			-- [SETTER] Dışarıdan Atanan Tuşu Değiştirme
			function kbInstance:SetValue(newKeyCode)
				kbInstance.Value = newKeyCode
				KeyButton.Text = newKeyCode.Name
			end

			function kbInstance:SetText(newText)
				KBLabel.Text = newText
			end

			return kbInstance
		end

				-- =============================================================================
		-- VORTEX TAB RUNTIME MODIFIERS (SETTERS)
		-- =============================================================================

		-- [SETTER 1] Dışarıdan Sekme Yazısını Değiştirme
		function tabData:SetText(newText)
			if typeof(newText) == "string" then
				TabButton.Text = "   " .. newText
			end
		end

		-- [SETTER 2] Dışarıdan Sekme Başlığını Değiştirme (Alternatif)
		function tabData:SetTitle(newTitle)
			if typeof(newTitle) == "string" then
				TabButton.Text = "   " .. newTitle
			end
		end
		

		return tabData
	end

	----------------------------------------------------------------
	-- INTRO ANIMATION DISPATCHER
	----------------------------------------------------------------
	task.spawn(function()
		local tweenInfoQuick = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tweenInfoSlow = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfoCorner = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		TweenService:Create(LeftTriangle, tweenInfoQuick, {Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(RightTriangle, tweenInfoQuick, {Position = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.8)
		
		for i = 1, #CornerBorders do
			TweenService:Create(CornerBorders[i].Frame, tweenInfoCorner, {Size = CornerBorders[i].TargetSize}):Play()
			task.wait(0.15)
		end
		task.wait(0.2)
		
		TweenService:Create(Bar1.Left, tweenInfoSlow, {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(Bar1.Right, tweenInfoSlow, {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0)}):Play()
		task.wait(0.6)
		
		TweenService:Create(Bar2.Left, tweenInfoSlow, {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(Bar2.Right, tweenInfoSlow, {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0)}):Play()
		task.wait(1.0)

		local splitTweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
		TweenService:Create(Bar1.Left, splitTweenInfo, {Position = UDim2.new(-0.2, 0, 0, 0), BackgroundTransparency = 1}):Play()
		TweenService:Create(Bar1.Right, splitTweenInfo, {Position = UDim2.new(0.7, 0, 0, 0), BackgroundTransparency = 1}):Play()
		TweenService:Create(Bar2.Left, splitTweenInfo, {Position = UDim2.new(-0.2, 0, 0, 0), BackgroundTransparency = 1}):Play()
		TweenService:Create(Bar2.Right, splitTweenInfo, {Position = UDim2.new(0.7, 0, 0, 0), BackgroundTransparency = 1}):Play()
		task.wait(0.6)

		local spinInfo = TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(GeometryGroup, spinInfo, {Rotation = 45}):Play()
		task.wait(1.0)
		
		local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
		TweenService:Create(TitleLabel, fadeInfo, {TextTransparency = 1}):Play()
		TweenService:Create(DescLabel, fadeInfo, {TextTransparency = 1}):Play()
		TweenService:Create(LeftTriangle, fadeInfo, {BackgroundTransparency = 1}):Play()
		TweenService:Create(RightTriangle, fadeInfo, {BackgroundTransparency = 1}):Play()
		for _, border in ipairs(CornerBorders) do TweenService:Create(border.Frame, fadeInfo, {BackgroundTransparency = 1}):Play() end
		task.wait(0.4)
		LoadingContainer.Visible = false
		
		MainFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 530, 0, 330)
		MainFrame.Position = UDim2.new(0.5, -265, 0.5, -165)
		
		TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 560, 0, 360),
			Position = UDim2.new(0.5, -280, 0.5, -180),
			BackgroundTransparency = 0
		}):Play()
	end)

		-- =============================================================================
	-- VORTEX WINDOW RUNTIME MODIFIERS (SETTERS)
	-- =============================================================================

	-- Ana Hub Başlığını Canlı Değiştirir
	function self:SetTitle(newTitle)
		if typeof(newTitle) == "string" then
			if WindowTitle then
				WindowTitle.Text = newTitle
			end
		end
	end

	-- Alt Başlığı / Versiyon Metnini Canlı Değiştirir
	function self:SetSubtitle(newSubtitle)
		if typeof(newSubtitle) == "string" then
			if WindowSubTitle then
				WindowSubTitle.Text = newSubtitle
			end
		end
	end

	-- =============================================================================
	-- TOAST / NOTIFICATION SYSTEM
	-- =============================================================================
	local NotifyContainer = Instance.new("Frame")
	NotifyContainer.Name = "NotifyContainer"
	NotifyContainer.Size = UDim2.new(0, 280, 1, -20)
	NotifyContainer.Position = UDim2.new(1, -300, 0, 10)
	NotifyContainer.BackgroundTransparency = 1
	NotifyContainer.ZIndex = 200
	NotifyContainer.Parent = ScreenGui

	local NotifyLayout = Instance.new("UIListLayout")
	NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NotifyLayout.Padding = UDim.new(0, 8)
	NotifyLayout.Parent = NotifyContainer

	-- Bildirim Gönderme Fonksiyonu
	-- self:Notify(title, content, duration, notifyType)
	-- notifyType: "Info" | "Success" | "Warning" | "Error" (opsiyonel, varsayılan "Info")
	function self:Notify(title, content, duration, notifyType)
		duration = duration or 4
		local typeColors = {
			Info = COLORS.Accent,
			Success = Color3.fromRGB(80, 220, 130),
			Warning = Color3.fromRGB(255, 190, 70),
			Error = COLORS.CloseHover
		}
		local accentColor = typeColors[notifyType] or typeColors.Info

		local Toast = Instance.new("Frame")
		Toast.Size = UDim2.new(1, 0, 0, 0)
		Toast.AutomaticSize = Enum.AutomaticSize.Y
		Toast.BackgroundColor3 = COLORS.Background
		Toast.BorderSizePixel = 0
		Toast.BackgroundTransparency = 1
		Toast.ClipsDescendants = true
		Toast.LayoutOrder = -os.clock()
		Toast.ZIndex = 200
		Toast.Parent = NotifyContainer
		Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 10)

		local ToastStroke = Instance.new("UIStroke")
		ToastStroke.Color = COLORS.Border
		ToastStroke.Thickness = 1.2
		ToastStroke.Transparency = 1
		ToastStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ToastStroke.Parent = Toast

		local AccentBar = Instance.new("Frame")
		AccentBar.Size = UDim2.new(0, 3, 1, 0)
		AccentBar.BackgroundColor3 = accentColor
		AccentBar.BackgroundTransparency = 1
		AccentBar.BorderSizePixel = 0
		AccentBar.ZIndex = 201
		AccentBar.Parent = Toast
		Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)

		local Inner = Instance.new("Frame")
		Inner.Size = UDim2.new(1, -16, 0, 0)
		Inner.Position = UDim2.new(0, 14, 0, 8)
		Inner.AutomaticSize = Enum.AutomaticSize.Y
		Inner.BackgroundTransparency = 1
		Inner.ZIndex = 201
		Inner.Parent = Toast

		local ToastTitle = Instance.new("TextLabel")
		ToastTitle.Size = UDim2.new(1, 0, 0, 18)
		ToastTitle.BackgroundTransparency = 1
		ToastTitle.Text = title or "Notification"
		ToastTitle.Font = Enum.Font.GothamBold
		ToastTitle.TextSize = 13
		ToastTitle.TextColor3 = COLORS.Text
		ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
		ToastTitle.TextTransparency = 1
		ToastTitle.ZIndex = 201
		ToastTitle.Parent = Inner

		local ToastContent = Instance.new("TextLabel")
		ToastContent.Size = UDim2.new(1, 0, 0, 0)
		ToastContent.Position = UDim2.new(0, 0, 0, 20)
		ToastContent.AutomaticSize = Enum.AutomaticSize.Y
		ToastContent.BackgroundTransparency = 1
		ToastContent.Text = content or ""
		ToastContent.Font = Enum.Font.Gotham
		ToastContent.TextSize = 12
		ToastContent.TextColor3 = COLORS.TextMuted
		ToastContent.TextXAlignment = Enum.TextXAlignment.Left
		ToastContent.TextYAlignment = Enum.TextYAlignment.Top
		ToastContent.TextWrapped = true
		ToastContent.TextTransparency = 1
		ToastContent.ZIndex = 201
		ToastContent.Parent = Inner

		local function paddedHeight()
			return Inner.AbsoluteSize.Y + 16
		end

		task.spawn(function()
			task.wait()
			Toast.Size = UDim2.new(1, 0, 0, paddedHeight())
			TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
			TweenService:Create(ToastStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
			TweenService:Create(AccentBar, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
			TweenService:Create(ToastTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
			TweenService:Create(ToastContent, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

			task.wait(duration)

			local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(Toast, fadeInfo, {BackgroundTransparency = 1}):Play()
			TweenService:Create(ToastStroke, fadeInfo, {Transparency = 1}):Play()
			TweenService:Create(AccentBar, fadeInfo, {BackgroundTransparency = 1}):Play()
			TweenService:Create(ToastTitle, fadeInfo, {TextTransparency = 1}):Play()
			TweenService:Create(ToastContent, fadeInfo, {TextTransparency = 1}):Play()
			task.wait(0.3)
			Toast:Destroy()
		end)
	end

	return self
end



return PremiumLib
