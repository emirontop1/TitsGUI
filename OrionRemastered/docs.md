


 uswge:

 ```lua

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/emirontop1/GuiLibs/refs/heads/main/OrionRemastered/source.lua'))()

-- ============================================================
-- KULLANIM ÖRNEĞİ
-- ============================================================
local Win = OrionLib:MakeWindow({
   Name = "OrionRemastered",
   ConfigFolder = "OrionTest",
   SaveConfig = true,
   IntroEnabled = true,
   IntroText = "OrionRemastered",
   Gradient = {
   	Color3.fromRGB(15, 15, 30),
   	Color3.fromRGB(40, 40, 65),
   	Color3.fromRGB(15, 15, 30)
   },
   ShowIcon = true,
   Icon = "rbxassetid://8834748103",
   CloseCallback = function()
   	print("Closed Window")
   end
})

local AnaTab = Win:MakeTab({
   Name = "Home",
   Icon = "home"
})

local AyarlarTab = Win:MakeTab({
   Name = "Settings",
   Icon = "settings"
})

-- HATA DÜZELTİLDİ: Tırnak işareti eklendi
AnaTab:AddLabel("⭐ Welcome")

AnaTab:AddButton({
   Name = "Click Me",
   Callback = function()
   	print("Clicked Button")
   	OrionLib:MakeNotification({
   		Name = "Clicked",
   		Content = "Successfully clicked Button.",
   		Time = 3
   	})
   end
})

AnaTab:AddToggle({
   Name = "Example Toggle",
   Default = true,
   Callback = function(v) print("Toggle:", v) end,
   Flag = "toggle_test",
   Save = true
})

AnaTab:AddSlider({
   Name = "Example Slider",
   Min = 0,
   Max = 100,
   Default = 50,
   Increment = 5,
   ValueName = "%",
   Callback = function(v) print("Slider:", v) end,
   Flag = "slider_test",
   Save = true
})

AnaTab:AddDropdown({
   Name = "Example Dropdown",
   Options = {"Choice 1", "Choice 2", "Choice 3"},
   Default = "Seçenek 2",
   Callback = function(v) print("Dropdown:", v) end,
   Flag = "dropdown_test",
   Save = true
})

AnaTab:AddMultiDropdown({
   Name = "Multi Select",
   Options = {"A", "B", "C", "D"},
   Default = {"A", "C"},
   Callback = function(v) print("Multi:", table.concat(v, ", ")) end,
   Flag = "multi_test",
   Save = true
})

AnaTab:AddBind({
   Name = "Kısayol",
   Default = Enum.KeyCode.O,
   Hold = false,
   Callback = function() print("Bind Activated ") end,
   Flag = "bind_test",
   Save = true
})

AnaTab:AddTextbox({
   Name = " Example Text disappear Textbox",
   Default = "Normal Text",
   TextDisappear = true,
   Callback = function(txt) print("Textbox:", txt) end
})

AnaTab:AddTextbox({
   Name = " Example Textbox",
   Default = "Normal Text",
   TextDisappear = false,
   Callback = function(txt) print("Textbox:", txt) end
})

-- HATA DÜZELTİLDİ: Tırnak işareti eklendi
AyarlarTab:AddLabel("⚙️ Settings Section")

AyarlarTab:AddButton({
   Name = "Choice  1",
   Callback = function() print("Choice 1") end
})
AyarlarTab:AddButton({
   Name = "Choice 2",
   Callback = function() print("Choice 2") end
})

--[[
task.wait(2)
Win:SelectTab("Ana")
Win:GotoElement("Ana", 4)
]]--

```
