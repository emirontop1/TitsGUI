-- ============================================================
-- ORIONRecontinued - GELİŞTİRİLMİŞ SÜRÜM
-- (Popup, Gradient, Goto, Kullanıcı Bilgileri, Select Tab)
-- ============================================================
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
 
local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false,
	AnonymousMode = false,
	AvatarImage = nil,
	UsernameLabel = nil,
	UserTagLabel = nil,
	AnonymousToggle = nil,
	Tabs = {}, -- tab isimlerini ve containerlarını sakla
	MainWindow = nil,
	WindowStuff = nil,
	ResizeHandle = nil,
	PopupOverlay = nil, -- popup için overlay
}

-- Create fonksiyonu
local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function New(className, properties, children)
	return Create(className, properties, children)
end

-- Offline Icon
local IconFolder = "OrionIcons"
if not isfolder(IconFolder) then makefolder(IconFolder) end

local function GetIconOffline(IconName)
	local path = IconFolder .. "/" .. IconName .. ".txt"
	if isfile(path) then
		return readfile(path)
	end
	return nil
end

local function SaveIconOffline(IconName, Data)
	local path = IconFolder .. "/" .. IconName .. ".txt"
	writefile(path, Data)
end

local Icons = {}
local Success, Response = pcall(function()
	local raw = game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")
	local data = HttpService:JSONDecode(raw)
	Icons = data.icons
	for name, svg in pairs(Icons) do
		SaveIconOffline(name, svg)
	end
end)

if not Success then
	for _, name in ipairs({"home", "layout", "settings", "user", "info", "alert-circle", "check", "chevron-down", "chevron-right", "x", "minus", "plus"}) do
		local svg = GetIconOffline(name)
		if svg then Icons[name] = svg end
	end
	warn("Orion Library - Offline icon mode. Error: " .. Response)
end	

local function GetIcon(IconName)
	return Icons[IconName]
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "ORIONRecontinued"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do wait() end
	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
	end)
end   

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end    
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function() 
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

-- ========== ELEMENT CREATORS ==========
CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	
	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

-- ========== NOTIFICATION ==========
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = NotificationConfig.Time or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent, 
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		wait(0.3)
		TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		wait(0.05)
		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0),'In','Quint',0.8,true)
		wait(1.35)
		NotificationFrame:Destroy()
	end)
end    

function OrionLib:Init()
	if OrionLib.SaveCfg then	
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)		
	end	
end

function OrionLib:SetAnonymous(State)
	OrionLib.AnonymousMode = State or false
	if OrionLib.AvatarImage then
		if State then
			OrionLib.AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
		else
			OrionLib.AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"
		end
	end
	if OrionLib.UsernameLabel then
		if State then
			OrionLib.UsernameLabel.Text = "ROBLOX"
		else
			OrionLib.UsernameLabel.Text = LocalPlayer.DisplayName
		end
	end
	if OrionLib.UserTagLabel then
		if State then
			OrionLib.UserTagLabel.Text = "@ROBLOX"
		else
			OrionLib.UserTagLabel.Text = "@" .. LocalPlayer.Name
		end
	end
	if OrionLib.AnonymousToggle then
		OrionLib.AnonymousToggle:Set(State)
	end
end

-- ========== POPUP OLUŞTURMA ==========
function OrionLib:CreatePopup(title, message, callback)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 999
	overlay.Parent = Orion

	local popup = Instance.new("Frame")
	popup.Size = UDim2.new(0, 300, 0, 150)
	popup.Position = UDim2.new(0.5, -150, 0.5, -75)
	popup.BackgroundTransparency = 0
	popup.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main
	popup.BorderSizePixel = 0
	popup.ZIndex = 1000
	popup.Parent = overlay

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = popup

	local stroke = Instance.new("UIStroke")
	stroke.Color = OrionLib.Themes[OrionLib.SelectedTheme].Stroke
	stroke.Thickness = 1.2
	stroke.Parent = popup

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "Confirmation"
	titleLabel.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = popup

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -20, 0, 40)
	msgLabel.Position = UDim2.new(0, 10, 0, 45)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = message or "Are you sure?"
	msgLabel.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextSize = 14
	msgLabel.TextWrapped = true
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Parent = popup

	local yesBtn = Instance.new("TextButton")
	yesBtn.Size = UDim2.new(0, 120, 0, 35)
	yesBtn.Position = UDim2.new(1, -140, 1, -45)
	yesBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 230)
	yesBtn.Text = "Yes"
	yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	yesBtn.Font = Enum.Font.GothamBold
	yesBtn.TextSize = 14
	yesBtn.AutoButtonColor = false
	yesBtn.ZIndex = 1001
	yesBtn.Parent = popup
	local yesCorner = Instance.new("UICorner")
	yesCorner.CornerRadius = UDim.new(0, 4)
	yesCorner.Parent = yesBtn

	local noBtn = Instance.new("TextButton")
	noBtn.Size = UDim2.new(0, 120, 0, 35)
	noBtn.Position = UDim2.new(1, -130, 1, -45)
	noBtn.AnchorPoint = Vector2.new(1, 1)
	noBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	noBtn.Text = "No"
	noBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
	noBtn.Font = Enum.Font.Gotham
	noBtn.TextSize = 14
	noBtn.AutoButtonColor = false
	noBtn.ZIndex = 1001
	noBtn.Parent = popup
	local noCorner = Instance.new("UICorner")
	noCorner.CornerRadius = UDim.new(0, 4)
	noCorner.Parent = noBtn

	local function destroyPopup()
		overlay:Destroy()
	end

	yesBtn.MouseButton1Click:Connect(function()
		destroyPopup()
		if callback then callback(true) end
	end)
	noBtn.MouseButton1Click:Connect(function()
		destroyPopup()
		if callback then callback(false) end
	end)
	-- Touch support
	yesBtn.TouchTap:Connect(function()
		destroyPopup()
		if callback then callback(true) end
	end)
	noBtn.TouchTap:Connect(function()
		destroyPopup()
		if callback then callback(false) end
	end)

	return overlay
end

-- ============================================================
-- RESIZABLE PENCERE (SOL ÜST KÖŞE SABİT + DIŞTA KÖŞE TUTAMAÇ)
-- ============================================================
function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false
	local TabsData = {} -- tab adı -> container
	local TabButtons = {} -- tab adı -> buton

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "ORIONRecontinued"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	WindowConfig.Anonymous = WindowConfig.Anonymous or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "ORIONRecontinued"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	-- Gradient ayarları
	WindowConfig.Gradient = WindowConfig.Gradient or nil -- ColorSequence veya table of colors
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig
	OrionLib.AnonymousMode = WindowConfig.Anonymous

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://10747384394"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://10734896206"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"), 
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"), 
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", ""), {
					Size = UDim2.new(1, 0, 1, 0),
					Name = "AvatarImage",
					Image = "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1, 0, 1, 0),
				}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", "", 13), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = UDim2.new(0, 50, 0, 17),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true,
				Name = "UsernameLabel",
				TextTruncate = Enum.TextTruncate.AtEnd
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -22),
				Font = Enum.Font.Gotham,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				Name = "UserTagLabel",
				TextTruncate = Enum.TextTruncate.AtEnd
			}), "TextDark")
		}),
	}), "Second")

	-- Avatar ve isim
	local avatarImage = nil
	local usernameLabel = nil
	local userTagLabel = nil
	for _, child in ipairs(WindowStuff:GetDescendants()) do
		if child.Name == "AvatarImage" and child:IsA("ImageLabel") then
			avatarImage = child
		end
		if child.Name == "UsernameLabel" and child:IsA("TextLabel") then
			usernameLabel = child
		end
		if child.Name == "UserTagLabel" and child:IsA("TextLabel") then
			userTagLabel = child
		end
	end

	if avatarImage then
		if WindowConfig.Anonymous then
			avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
		else
			avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"
		end
		OrionLib.AvatarImage = avatarImage
	end

	if usernameLabel then
		if WindowConfig.Anonymous then
			usernameLabel.Text = "ROBLOX"
		else
			usernameLabel.Text = LocalPlayer.DisplayName
		end
		OrionLib.UsernameLabel = usernameLabel
	end

	if userTagLabel then
		if WindowConfig.Anonymous then
			userTagLabel.Text = "@ROBLOX"
		else
			userTagLabel.Text = "@" .. LocalPlayer.Name
		end
		OrionLib.UserTagLabel = userTagLabel
	end

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	-- ANA PENCERE - SOL ÜST KÖŞE SABİT
	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = Orion,
		Position = UDim2.new(0, 50, 0, 50),
		Size = UDim2.new(0, 615, 0, 344),
		AnchorPoint = Vector2.new(0, 0),
		ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"), 
				CloseBtn,
				MinimizeBtn
			}), "Second"), 
		}),
		DragPoint,
		WindowStuff,
	}), "Main")

	-- Gradient uygula (eğer parametre verilmişse)
	if WindowConfig.Gradient then
		local gradient = Instance.new("UIGradient")
		if type(WindowConfig.Gradient) == "table" then
			-- tablo olarak verilmişse ColorSequence oluştur
			local keys = {}
			for i, color in ipairs(WindowConfig.Gradient) do
				table.insert(keys, ColorSequenceKeypoint.new((i-1)/(#WindowConfig.Gradient-1), color))
			end
			gradient.Color = ColorSequence.new(keys)
		else
			gradient.Color = WindowConfig.Gradient
		end
		gradient.Parent = MainWindow
		-- Arkaplan rengini şeffaf yapalım ki gradient görünsün
		MainWindow.BackgroundTransparency = 0
		-- Ancak MainWindow'un arkaplanını da değiştirelim (RoundFrame)
		MainWindow.BackgroundColor3 = Color3.fromRGB(255,255,255) -- gradient üzerine biner
	end

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end	

	-- RESIZE HANDLE
	local ResizeHandle = New("Frame", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 99,
		Active = true,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(0, 48 * 2, 0, 48 * 2),
			BackgroundTransparency = 1,
			Image = "rbxassetid://120997033468887",
			Position = UDim2.new(0.5, -16, 0.5, -16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageTransparency = 0.65,
		}),
	})
	ResizeHandle.Parent = Orion

	local function UpdateHandlePosition()
		local mainPos = MainWindow.Position
		local mainSize = MainWindow.Size
		ResizeHandle.Position = UDim2.new(
			mainPos.X.Scale,
			mainPos.X.Offset + mainSize.X.Offset + 4,
			mainPos.Y.Scale,
			mainPos.Y.Offset + mainSize.Y.Offset + 4
		)
	end

	AddConnection(MainWindow:GetPropertyChangedSignal("Position"), UpdateHandlePosition)
	AddConnection(MainWindow:GetPropertyChangedSignal("Size"), UpdateHandlePosition)
	task.defer(UpdateHandlePosition)

	OrionLib.MainWindow = MainWindow
	OrionLib.WindowStuff = WindowStuff
	OrionLib.ResizeHandle = ResizeHandle

	AddDraggingFunctionality(DragPoint, MainWindow)

	local isResizing = false
	local resizeStart, sizeStart

	ResizeHandle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			isResizing = true
			resizeStart = Input.Position
			sizeStart = MainWindow.Size
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if isResizing and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Input.Position - resizeStart
			local newW = math.max(300, sizeStart.X.Offset + delta.X)
			local newH = math.max(200, sizeStart.Y.Offset + delta.Y)
			MainWindow.Size = UDim2.new(0, newW, 0, newH)
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			isResizing = false
		end
	end)

	-- KAPATMA BUTONU - Popup ile
	AddConnection(CloseBtn.MouseButton1Up, function()
		OrionLib:CreatePopup("Close Window", "Are you sure you want to close the interface?", function(confirm)
			if confirm then
				MainWindow.Visible = false
				UIHidden = true
				OrionLib:MakeNotification({
					Name = "Interface Hidden",
					Content = "Tap RightShift to reopen the interface",
					Time = 5
				})
				WindowConfig.CloseCallback()
			end
		end)
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://10734896206"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://10734924532"
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1)
			WindowStuff.Visible = false	
		end
		Minimized = not Minimized    
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})
		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end 

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end	

	-- ========== TAB FONKSİYONU ==========
	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end	

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end    

		-- Tab verilerini sakla
		TabsData[TabConfig.Name] = Container
		TabButtons[TabConfig.Name] = TabFrame

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				end    
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end    
			end  
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true   
		end)

		-- ========== TEMEL ELEMENTLER ==========
		local function GetElements(ItemParent)
			local ElementFunction = {}
			
			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = ToChange
				end
				return LabelFunction
			end

			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)
				ParagraphFrame.Content.Text = Content
				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				return ParagraphFunction
			end

			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://10723375250"

				local Button = {}
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function() ButtonConfig.Callback() end)
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Button:Set(ButtonText)
					ButtonFrame.Content.Text = ButtonText
				end	
				return Button
			end

			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name = "Ico"
					}),
				})
				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")

				function Toggle:Set(Value)
					Toggle.Value = Value
					TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
					TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
					TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end    
				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end	
				return Toggle
			end

			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false

				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), {Color = SliderConfig.Color}),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.8
					}), "Text"),
					SliderDrag
				})

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")

				local function OnInputBegin(Input)
					if isResizing then return end
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true
						local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
						SaveCfg(game.GameId)
					end
				end

				SliderBar.InputBegan:Connect(OnInputBegin)
				SliderDrag.InputBegan:Connect(OnInputBegin)

				UserInputService.InputChanged:Connect(function(Input)
					if isResizing then return end
					if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
						local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
						SaveCfg(game.GameId)
					end
				end)

				UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging = false
					end
				end)

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					local rel = (self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
					TweenService:Create(SliderDrag,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = UDim2.fromScale(rel, 1)}):Play()
					SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderConfig.Callback(self.Value)
				end      
				Slider:Set(Slider.Value)
				if SliderConfig.Flag then				
					OrionLib.Flags[SliderConfig.Flag] = Slider
				end
				return Slider
			end

			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false

				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 5

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local DropdownList = MakeElement("List")
				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DropdownList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)  

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = "Title"
							}), "Text")
						}), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")
						AddConnection(OptionBtn.MouseButton1Click, function()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end)
						Dropdown.Buttons[Option] = OptionBtn
					end
				end	

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _,v in pairs(Dropdown.Buttons) do v:Destroy() end    
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end  

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, v in pairs(Dropdown.Buttons) do
							TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
							TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
						end	
						return
					end
					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value
					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
					end	
					TweenService:Create(Dropdown.Buttons[Value],TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 0}):Play()
					TweenService:Create(Dropdown.Buttons[Value].Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
					return DropdownConfig.Callback(Dropdown.Value)
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Rotation = Dropdown.Toggled and 180 or 0}):Play()
					if #Dropdown.Options > MaxElements then
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
					else
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
					end
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then				
					OrionLib.Flags[DropdownConfig.Flag] = Dropdown
				end
				return Dropdown
			end

			function ElementFunction:AddMultiDropdown(MultiDropdownConfig)
				MultiDropdownConfig = MultiDropdownConfig or {}
				MultiDropdownConfig.Name = MultiDropdownConfig.Name or "Multi Dropdown"
				MultiDropdownConfig.Options = MultiDropdownConfig.Options or {}
				MultiDropdownConfig.Default = MultiDropdownConfig.Default or {}
				MultiDropdownConfig.Callback = MultiDropdownConfig.Callback or function() end
				MultiDropdownConfig.Flag = MultiDropdownConfig.Flag or nil
				MultiDropdownConfig.Save = MultiDropdownConfig.Save or false

				local MultiDropdown = {
					Selected = MultiDropdownConfig.Default or {},
					Options = MultiDropdownConfig.Options,
					Buttons = {},
					Toggled = false,
					Type = "MultiDropdown",
					Save = MultiDropdownConfig.Save
				}
				local MaxElements = 5

				local DropdownList = MakeElement("List")
				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DropdownList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", MultiDropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right,
							TextColor3 = Color3.fromRGB(180, 180, 190)
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)  

				local function UpdateSelectedText()
					if #MultiDropdown.Selected == 0 then
						DropdownFrame.F.Selected.Text = "None"
					elseif #MultiDropdown.Selected == 1 then
						DropdownFrame.F.Selected.Text = MultiDropdown.Selected[1]
					else
						DropdownFrame.F.Selected.Text = #MultiDropdown.Selected .. " selected"
					end
				end

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local isChecked = table.find(MultiDropdown.Selected, Option) ~= nil
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							SetProps(MakeElement("Image", isChecked and "rbxassetid://3944680095" or ""), {
								Size = UDim2.new(0, 16, 0, 16),
								Position = UDim2.new(0, 8, 0.5, -8),
								ImageColor3 = isChecked and Color3.fromRGB(60, 130, 230) or Color3.fromRGB(150, 150, 160),
								Name = "Check",
								ImageTransparency = isChecked and 0 or 1,
							}),
							AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0), {
								Position = UDim2.new(0, 30, 0, 0),
								Size = UDim2.new(1, -30, 1, 0),
								Name = "Title",
								TextColor3 = isChecked and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
							}), "Text")
						}), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")

						AddConnection(OptionBtn.MouseButton1Click, function()
							local index = table.find(MultiDropdown.Selected, Option)
							if index then
								table.remove(MultiDropdown.Selected, index)
							else
								table.insert(MultiDropdown.Selected, Option)
							end
							local newChecked = table.find(MultiDropdown.Selected, Option) ~= nil
							OptionBtn.Check.Image = newChecked and "rbxassetid://3944680095" or ""
							OptionBtn.Check.ImageTransparency = newChecked and 0 or 1
							OptionBtn.Check.ImageColor3 = newChecked and Color3.fromRGB(60, 130, 230) or Color3.fromRGB(150, 150, 160)
							OptionBtn.Title.TextColor3 = newChecked and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
							UpdateSelectedText()
							MultiDropdownConfig.Callback(MultiDropdown.Selected)
							SaveCfg(game.GameId)
						end)
						MultiDropdown.Buttons[Option] = OptionBtn
					end
				end	

				function MultiDropdown:Refresh(Options, Delete)
					if Delete then
						for _,v in pairs(MultiDropdown.Buttons) do v:Destroy() end    
						table.clear(MultiDropdown.Options)
						table.clear(MultiDropdown.Buttons)
						MultiDropdown.Selected = {}
					end
					MultiDropdown.Options = Options
					AddOptions(MultiDropdown.Options)
					UpdateSelectedText()
				end  

				function MultiDropdown:Set(Values)
					MultiDropdown.Selected = Values or {}
					for _, v in pairs(MultiDropdown.Buttons) do
						local opt = v.Title.Text
						local checked = table.find(MultiDropdown.Selected, opt) ~= nil
						v.Check.Image = checked and "rbxassetid://3944680095" or ""
						v.Check.ImageTransparency = checked and 0 or 1
						v.Check.ImageColor3 = checked and Color3.fromRGB(60, 130, 230) or Color3.fromRGB(150, 150, 160)
						v.Title.TextColor3 = checked and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
					end
					UpdateSelectedText()
					MultiDropdownConfig.Callback(MultiDropdown.Selected)
				end

				AddConnection(Click.MouseButton1Click, function()
					MultiDropdown.Toggled = not MultiDropdown.Toggled
					DropdownFrame.F.Line.Visible = MultiDropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Rotation = MultiDropdown.Toggled and 180 or 0}):Play()
					if #MultiDropdown.Options > MaxElements then
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = MultiDropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
					else
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = MultiDropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
					end
				end)

				MultiDropdown:Refresh(MultiDropdown.Options, false)
				MultiDropdown:Set(MultiDropdown.Selected)
				if MultiDropdownConfig.Flag then				
					OrionLib.Flags[MultiDropdownConfig.Flag] = MultiDropdown
				end
				return MultiDropdown
			end

			function ElementFunction:AddBind(BindConfig)
				BindConfig = BindConfig or {}
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)

				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, Input.KeyCode) then
								Key = Input.KeyCode
							end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
								Key = Input.UserInputType
							end
						end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = Bind.Value.Name or Bind.Value
					BindBox.Value.Text = Bind.Value
				end
				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then				
					OrionLib.Flags[BindConfig.Flag] = Bind
				end
				return Bind
			end

			-- ========== DİNAMİK TEXTBOX ==========
			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = "Input",
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 14,
					ClearTextOnFocus = false,
					TextWrapped = false,
					ClipsDescendants = false,
					TextTruncate = Enum.TextTruncate.None,
				}), "Text")

				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 0,
					ClipsDescendants = false,
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")

				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = false,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")

				local function UpdateTextContainerSize()
					local textBounds = TextboxActual.TextBounds
					local newWidth = math.max(textBounds.X + 20, 24)
					TextContainer.Size = UDim2.new(0, newWidth, 0, 24)
				end

				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					UpdateTextContainerSize()
				end)
				AddConnection(TextboxActual:GetPropertyChangedSignal("TextBounds"), function()
					UpdateTextContainerSize()
				end)

				task.defer(function()
					UpdateTextContainerSize()
				end)

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
						task.defer(function()
							UpdateTextContainerSize()
						end)
					end	
				end)
				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
			end

--[[			-- ========== COLORPICKER (Mobil destekli) ==========
			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false
				ColorpickerConfig.Transparency = ColorpickerConfig.Transparency or 0

				local Colorpicker = {
					Value = ColorpickerConfig.Default,
					Toggled = false,
					Type = "Colorpicker",
					Save = ColorpickerConfig.Save,
					Transparency = ColorpickerConfig.Transparency,
					Hue = 0,
					Sat = 0,
					Vib = 1,
				}

				Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Colorpicker.Value)

				local MainFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 0.7,
					Parent = ItemParent,
					ClipsDescendants = false,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")

				local ColorBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Colorpicker.Value,
					BackgroundTransparency = 0,
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Main")
				ColorBox.Parent = MainFrame

				local ClickBtn = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					Parent = MainFrame,
				})

				local DialogFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(30,30,35), 0, 8), {
					Size = UDim2.new(0, 300, 0, 280),
					Position = UDim2.new(0.5, -150, 0, 38 + 4),
					BackgroundTransparency = 0.05,
					Visible = false,
					ZIndex = 10,
					Parent = MainFrame,
					ClipsDescendants = true,
				}), {
					MakeElement("Stroke", Color3.fromRGB(60,60,70), 1),
					MakeElement("Padding", 8, 8, 8, 8),

					SetChildren(SetProps(MakeElement("ImageLabel", "rbxassetid://4155801252"), {
						Size = UDim2.new(0, 160, 0, 160),
						Position = UDim2.new(0, 0, 0, 0),
						BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1),
						Name = "SatVibMap"
					}), {
						MakeElement("Corner", 0, 6),
						SetProps(MakeElement("Frame"), {
							Size = UDim2.new(0, 14, 0, 14),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(Colorpicker.Sat, 0, 1 - Colorpicker.Vib, 0),
							BackgroundColor3 = Colorpicker.Value,
							Name = "Cursor",
						}, {
							MakeElement("Stroke", Color3.fromRGB(255,255,255), 2),
							MakeElement("Corner", 1),
						}),
					}),

					SetChildren(SetProps(MakeElement("Frame"), {
						Size = UDim2.new(0, 10, 0, 160),
						Position = UDim2.new(0, 170, 0, 0),
						BackgroundColor3 = Color3.fromRGB(255,255,255),
						BackgroundTransparency = 1,
						Name = "HueSlider"
					}), {
						SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundColor3 = Color3.fromRGB(255,255,255),
						}, {
							MakeElement("UIGradient", {
								Rotation = 90,
								Color = ColorSequence.new{
									ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
									ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
									ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
									ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
									ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
									ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
									ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
								}
							}),
							MakeElement("Corner", 1, 0),
						}),
						SetProps(MakeElement("Frame"), {
							Size = UDim2.new(0, 16, 0, 16),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, Colorpicker.Hue, 0),
							BackgroundColor3 = Colorpicker.Value,
							Name = "HueCursor",
						}, {
							MakeElement("Stroke", Color3.fromRGB(255,255,255), 2),
							MakeElement("Corner", 1),
						}),
					}),

					SetChildren(SetProps(MakeElement("Frame"), {
						Size = UDim2.new(1, -190, 0, 100),
						Position = UDim2.new(0, 190, 0, 0),
						BackgroundTransparency = 1,
						Name = "Inputs"
					}), {
						MakeElement("List", 0, 4),
						SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(40,40,45), 0, 4), {
							Size = UDim2.new(1, 0, 0, 28),
						}), {
							MakeElement("Stroke", Color3.fromRGB(60,60,70), 1),
							SetProps(MakeElement("TextBox"), {
								Size = UDim2.new(1, -20, 1, 0),
								Position = UDim2.new(0, 10, 0, 0),
								BackgroundTransparency = 1,
								Text = "255",
								TextColor3 = Color3.fromRGB(255,255,255),
								Font = Enum.Font.Gotham,
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								Name = "R",
							}),
							SetProps(MakeElement("TextLabel"), {
								Size = UDim2.new(0, 16, 1, 0),
								Position = UDim2.new(0, 4, 0, 0),
								BackgroundTransparency = 1,
								Text = "R",
								TextColor3 = Color3.fromRGB(255,100,100),
								Font = Enum.Font.GothamBold,
								TextSize = 13,
							}),
						}),
						SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(40,40,45), 0, 4), {
							Size = UDim2.new(1, 0, 0, 28),
						}), {
							MakeElement("Stroke", Color3.fromRGB(60,60,70), 1),
							SetProps(MakeElement("TextBox"), {
								Size = UDim2.new(1, -20, 1, 0),
								Position = UDim2.new(0, 10, 0, 0),
								BackgroundTransparency = 1,
								Text = "255",
								TextColor3 = Color3.fromRGB(255,255,255),
								Font = Enum.Font.Gotham,
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								Name = "G",
							}),
							SetProps(MakeElement("TextLabel"), {
								Size = UDim2.new(0, 16, 1, 0),
								Position = UDim2.new(0, 4, 0, 0),
								BackgroundTransparency = 1,
								Text = "G",
								TextColor3 = Color3.fromRGB(100,255,100),
								Font = Enum.Font.GothamBold,
								TextSize = 13,
							}),
						}),
						SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(40,40,45), 0, 4), {
							Size = UDim2.new(1, 0, 0, 28),
						}), {
							MakeElement("Stroke", Color3.fromRGB(60,60,70), 1),
							SetProps(MakeElement("TextBox"), {
								Size = UDim2.new(1, -20, 1, 0),
								Position = UDim2.new(0, 10, 0, 0),
								BackgroundTransparency = 1,
								Text = "255",
								TextColor3 = Color3.fromRGB(255,255,255),
								Font = Enum.Font.Gotham,
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								Name = "B",
							}),
							SetProps(MakeElement("TextLabel"), {
								Size = UDim2.new(0, 16, 1, 0),
								Position = UDim2.new(0, 4, 0, 0),
								BackgroundTransparency = 1,
								Text = "B",
								TextColor3 = Color3.fromRGB(100,100,255),
								Font = Enum.Font.GothamBold,
								TextSize = 13,
							}),
						}),
					}),

					SetChildren(SetProps(MakeElement("Frame"), {
						Size = UDim2.new(1, 0, 0, 32),
						Position = UDim2.new(0, 0, 1, -32),
						BackgroundTransparency = 1,
					}), {
						MakeElement("List", 0, 6),
						SetChildren(SetProps(MakeElement("TextButton"), {
							Size = UDim2.new(0.45, 0, 1, 0),
							BackgroundColor3 = Color3.fromRGB(50,50,55),
							Text = "Cancel",
							TextColor3 = Color3.fromRGB(200,200,210),
							Font = Enum.Font.Gotham,
							TextSize = 14,
							AutoButtonColor = false,
							Name = "CancelBtn",
						}), {
							MakeElement("Corner", 0, 4),
						}),
						SetChildren(SetProps(MakeElement("TextButton"), {
							Size = UDim2.new(0.45, 0, 1, 0),
							BackgroundColor3 = Color3.fromRGB(60,130,230),
							Text = "Apply",
							TextColor3 = Color3.fromRGB(255,255,255),
							Font = Enum.Font.GothamBold,
							TextSize = 14,
							AutoButtonColor = false,
							Name = "ApplyBtn",
						}), {
							MakeElement("Corner", 0, 4),
						}),
					}),
				})

				local function UpdateColorpicker()
					local color = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
					ColorBox.BackgroundColor3 = color
					Colorpicker.Value = color
					local satVibMap = DialogFrame:FindFirstChild("SatVibMap")
					if satVibMap then
						satVibMap.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
						local cursor = satVibMap:FindFirstChild("Cursor")
						if cursor then
							cursor.Position = UDim2.new(Colorpicker.Sat, 0, 1 - Colorpicker.Vib, 0)
							cursor.BackgroundColor3 = color
						end
					end
					local hueSlider = DialogFrame:FindFirstChild("HueSlider")
					if hueSlider then
						local hueCursor = hueSlider:FindFirstChild("HueCursor")
						if hueCursor then
							hueCursor.Position = UDim2.new(0.5, 0, Colorpicker.Hue, 0)
							hueCursor.BackgroundColor3 = color
						end
					end
					local inputs = DialogFrame:FindFirstChild("Inputs")
					if inputs then
						local r = inputs:FindFirstChild("R")
						local g = inputs:FindFirstChild("G")
						local b = inputs:FindFirstChild("B")
						if r then r.Text = tostring(math.floor(color.R * 255)) end
						if g then g.Text = tostring(math.floor(color.G * 255)) end
						if b then b.Text = tostring(math.floor(color.B * 255)) end
					end
				end

				local function onInputChanged(box, comp)
					box.FocusLost:Connect(function()
						local val = tonumber(box.Text)
						if val then
							val = math.clamp(val, 0, 255)
							box.Text = tostring(val)
							local color = Colorpicker.Value
							local r, g, b = color.R * 255, color.G * 255, color.B * 255
							if comp == "R" then r = val
							elseif comp == "G" then g = val
							elseif comp == "B" then b = val end
							local newColor = Color3.fromRGB(r, g, b)
							Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(newColor)
							UpdateColorpicker()
							ColorpickerConfig.Callback(newColor, Colorpicker.Transparency)
						end
					end)
				end

				local inputs = DialogFrame:FindFirstChild("Inputs")
				if inputs then
					local r = inputs:FindFirstChild("R")
					local g = inputs:FindFirstChild("G")
					local b = inputs:FindFirstChild("B")
					if r then onInputChanged(r, "R") end
					if g then onInputChanged(g, "G") end
					if b then onInputChanged(b, "B") end
				end

				local cancelBtn = DialogFrame:FindFirstChild("CancelBtn")
				local applyBtn = DialogFrame:FindFirstChild("ApplyBtn")
				if cancelBtn then
					cancelBtn.MouseButton1Click:Connect(function()
						DialogFrame.Visible = false
						Colorpicker.Toggled = false
					end)
					cancelBtn.TouchTap:Connect(function()
						DialogFrame.Visible = false
						Colorpicker.Toggled = false
					end)
				end
				if applyBtn then
					applyBtn.MouseButton1Click:Connect(function()
						DialogFrame.Visible = false
						Colorpicker.Toggled = false
						ColorpickerConfig.Callback(Colorpicker.Value, Colorpicker.Transparency)
						SaveCfg(game.GameId)
					end)
					applyBtn.TouchTap:Connect(function()
						DialogFrame.Visible = false
						Colorpicker.Toggled = false
						ColorpickerConfig.Callback(Colorpicker.Value, Colorpicker.Transparency)
						SaveCfg(game.GameId)
					end)
				end

				ClickBtn.MouseButton1Click:Connect(function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					DialogFrame.Visible = Colorpicker.Toggled
					if Colorpicker.Toggled then
						UpdateColorpicker()
					end
				end)
				ClickBtn.TouchTap:Connect(function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					DialogFrame.Visible = Colorpicker.Toggled
					if Colorpicker.Toggled then
						UpdateColorpicker()
					end
				end)

				local function handleDrag(input, slider, type)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end
					local absPos = slider.AbsolutePosition
					local size = slider.AbsoluteSize
					if type == "SatVib" then
						local x = math.clamp((input.Position.X - absPos.X) / size.X, 0, 1)
						local y = math.clamp((input.Position.Y - absPos.Y) / size.Y, 0, 1)
						Colorpicker.Sat = x
						Colorpicker.Vib = 1 - y
						UpdateColorpicker()
						ColorpickerConfig.Callback(Colorpicker.Value, Colorpicker.Transparency)
					elseif type == "Hue" then
						local y = math.clamp((input.Position.Y - absPos.Y) / size.Y, 0, 1)
						Colorpicker.Hue = y
						UpdateColorpicker()
						ColorpickerConfig.Callback(Colorpicker.Value, Colorpicker.Transparency)
					end
				end

				local satVibMap = DialogFrame:FindFirstChild("SatVibMap")
				local hueSlider = DialogFrame:FindFirstChild("HueSlider")

				if satVibMap then
					satVibMap.InputBegan:Connect(function(input)
						handleDrag(input, satVibMap, "SatVib")
					end)
					satVibMap.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							handleDrag(input, satVibMap, "SatVib")
						end
					end)
				end

				if hueSlider then
					hueSlider.InputBegan:Connect(function(input)
						handleDrag(input, hueSlider, "Hue")
					end)
					hueSlider.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							handleDrag(input, hueSlider, "Hue")
						end
					end)
				end

				UpdateColorpicker()

				if ColorpickerConfig.Flag then
					OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker
				end

				return Colorpicker
			end
]]
			return ElementFunction   
		end	

		local ElementFunction = {}

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (sirius.menu/discord)", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction   
	end  

	-- Window objesine metodlar ekle
	local WindowObject = {
		MakeTab = TabFunction.MakeTab,
		SelectTab = function(tabName)
			if TabsData[tabName] then
				-- butona tıkla
				local btn = TabButtons[tabName]
				if btn then
					btn.MouseButton1Click:Fire()
				end
			else
				warn("Tab not found: " .. tostring(tabName))
			end
		end,
		GotoElement = function(tabName, elementIndex)
			local container = TabsData[tabName]
			if not container then
				warn("Tab not found: " .. tostring(tabName))
				return
			end
			-- Önce tab'ı seç
			WindowObject.SelectTab(tabName)
			-- Elementleri bul (UIListLayout sırasına göre)
			local children = container:GetChildren()
			local element = nil
			local count = 0
			for _, child in ipairs(children) do
				if child:IsA("Frame") and child:FindFirstChild("Content") then -- basit kontrol
					count = count + 1
					if count == elementIndex then
						element = child
						break
					end
				end
			end
			if element then
				-- ScrollFrame'i o elementin pozisyonuna kaydır
				local yPos = element.AbsolutePosition.Y - container.AbsolutePosition.Y
				container.CanvasPosition = Vector2.new(0, yPos)
			else
				warn("Element not found at index " .. tostring(elementIndex) .. " in tab " .. tostring(tabName))
			end
		end,
		Close = function()
			MainWindow.Visible = false
			UIHidden = true
			OrionLib:MakeNotification({
				Name = "Interface Hidden",
				Content = "Tap RightShift to reopen",
				Time = 5
			})
			WindowConfig.CloseCallback()
		end,
		Show = function()
			MainWindow.Visible = true
			UIHidden = false
		end,
		Destroy = function()
			OrionLib:Destroy()
		end
	}

	OrionLib:MakeNotification({
		Name = "UI Library Upgrade",
		Content = "New UI Library Available at sirius.menu/discord and sirius.menu/rayfield",
		Time = 5
	})
	
	return WindowObject
end   

function OrionLib:Destroy()
	Orion:Destroy()
end



return OrionLib
