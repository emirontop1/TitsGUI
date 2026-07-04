

```lua
local EmoC = loadstring(game:HttpGet('https://raw.githubusercontent.com/emirontop1/GuiLibs/refs/heads/main/Exuman/source.lua'))()

local Config = {
    icon = "shield-check", 
    minWidth = 450,        
    maxWidth = 900,
    confirmClose = true -- Çarpıya basınca emin misiniz sorsun mu?
}

local MyWindow = EmoC:CreateWindow("New Window", "TextBox, Slider, Dropdown & Theme", Config)

-- SEKME 1: YENİ ELEMENTLER
local HomeTab = MyWindow:CreateTab("New elements", "TextBox, Slider, Dropdown", "home")

HomeTab:CreateTextBox("User name", "Set Username", function(text)
	print("Girilen Yazı: " .. text)
end)

HomeTab:CreateSlider("WalkSpeed", 16, 200, 16, function(value)
	print("Yeni Hız Değeri: ", value)
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

HomeTab:CreateDropdown("Select Place", {"Spawn Noktası", "VIP place", "Arena", "Safe Place"}, "Spawnpoint", function(selectedOption)
	print("Işınlanılacak Yer Seçildi: ", selectedOption)
end)

HomeTab:CreateSpace(15)

-- SEKME 2: TEMA DEĞİŞTİRİCİ
local SettingsTab = MyWindow:CreateTab("Settings", "Settings", "settings-gear")

local ThemeSection = SettingsTab:CreateSection("Tema Rengi Seçimi")

ThemeSection:CreateButton("Purple Theme (Purple Vibe)", "Purple.", "play", function()
	MyWindow:ChangeTheme({
		Accent = Color3.fromRGB(155, 89, 182),
		Background = Color3.fromRGB(15, 12, 22),
		Stroke = Color3.fromRGB(40, 35, 55),
		TabSelected = Color3.fromRGB(25, 20, 35)
	})
end)

ThemeSection:CreateButton("Blue Theme (Ocean Blue)", "Ocean Blue.", "play", function()
	MyWindow:ChangeTheme({
		Accent = Color3.fromRGB(0, 180, 255),
		Background = Color3.fromRGB(11, 14, 20),
		Stroke = Color3.fromRGB(30, 38, 50),
		TabSelected = Color3.fromRGB(20, 28, 40)
	})
end)

ThemeSection:CreateButton("Green Theme (Wind UI)", "Originall.", "play", function()
	MyWindow:ChangeTheme({
		Accent = Color3.fromRGB(46, 204, 113),
		Background = Color3.fromRGB(14, 14, 14),
		Stroke = Color3.fromRGB(30, 30, 30),
		TabSelected = Color3.fromRGB(28, 28, 28)
	})
end)

```
