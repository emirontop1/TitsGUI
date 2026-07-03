


 uswge:

 ```lua

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/emirontop1/TitsGUI/refs/heads/main/OrionRemastered/source.lua'))()


local Window = OrionLib:MakeWindow({
	Name = "ORIONRecontinued",
	IntroEnabled = true,
	IntroText = "ORIONRecontinued",
	SaveConfig = false,
	Anonymous = true,
})

local toggleTab = Window:MakeTab({ Name = "Ayarlar", Icon = "settings" })
local anonToggle = toggleTab:AddToggle({
	Name = "Anonim Mod",
	Default = true,
	Callback = function(state)
		OrionLib:SetAnonymous(state)
	end,
	Flag = "Anonymous",
	Save = false
})

local MainTab = Window:MakeTab({ Name = "Ana", Icon = "home" })
MainTab:AddLabel("Merhaba! ORIONRecontinued çalışıyor.")
MainTab:AddButton({ Name = "Tıkla", Callback = function() print("Tıklandı!") end })
MainTab:AddToggle({ Name = "Toggle", Default = true, Callback = function(v) print(v) end })
MainTab:AddSlider({ Name = "Slider", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end })
MainTab:AddDropdown({ Name = "Dropdown", Options = {"A","B","C"}, Default = "A", Callback = function(v) print(v) end })
MainTab:AddMultiDropdown({ Name = "Multi", Options = {"X","Y","Z"}, Default = {"X"}, Callback = function(v) print(v) end })
MainTab:AddBind({ Name = "Bind", Default = Enum.KeyCode.F, Callback = function() print("Bind tetiklendi") end })
MainTab:AddTextbox({ Name = "Textbox", Default = "Uzun yazı taşmasın", Callback = function(v) print(v) end })
MainTab:AddColorpicker({ Name = "Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) print(c) end })

print("✅ ORIONRecontinued çalışıyor! Resize, Textbox, Colorpicker düzeltildi.")

```
