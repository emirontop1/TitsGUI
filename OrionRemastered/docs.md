


 uswge:

 ```lua

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/emirontop1/TitsGUI/refs/heads/main/OrionRemastered/Source.lua'))()

local Window = OrionLib:MakeWindow({
    Name = "ORIONRecontinued",
    IntroEnabled = true,
    IntroText = "ORIONRecontinued",
    SaveConfig = false,
    Anonymous = true,
})

-- =============================================================================
-- SETTINGS TAB
-- =============================================================================
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "settings" })

SettingsTab:AddToggle({
    Name = "Anonymous Mode",
    Default = true,
    Callback = function(state)
        OrionLib:SetAnonymous(state)
    end,
    Flag = "Anonymous",
    Save = false
})

-- =============================================================================
-- MAIN TAB
-- =============================================================================
local MainTab = Window:MakeTab({ Name = "Main", Icon = "home" })

MainTab:AddLabel("Hello! ORIONRecontinued is running.")

MainTab:AddButton({
    Name = "Click Me",
    Callback = function() 
        print("Button clicked!") 
    end 
})

MainTab:AddToggle({ 
    Name = "Toggle", 
    Default = true, 
    Callback = function(value) 
        print("Toggle value:", value) 
    end 
})

MainTab:AddSlider({ 
    Name = "Slider", 
    Min = 0, 
    Max = 100, 
    Default = 50, 
    Callback = function(value) 
        print("Slider value:", value) 
    end 
})

MainTab:AddDropdown({ 
    Name = "Dropdown", 
    Options = {"A", "B", "C"}, 
    Default = "A", 
    Callback = function(value) 
        print("Selected option:", value) 
    end 
})

MainTab:AddMultiDropdown({ 
    Name = "Multi Dropdown", 
    Options = {"X", "Y", "Z"}, 
    Default = {"X"}, 
    Callback = function(value) 
        print("Selected multi options:", table.concat(value, ", ")) 
    end 
})

MainTab:AddBind({ 
    Name = "Keybind", 
    Default = Enum.KeyCode.F, 
    Callback = function() 
        print("Keybind triggered!") 
    end 
})

MainTab:AddTextbox({ 
    Name = "Textbox", 
    Default = "Prevent long text from overflowing", 
    Callback = function(value) 
        print("Textbox input:", value) 
    end 
})



-- Startup Notification
print("✅ ORIONRecontinued is running! Resize, Textbox, and Colorpicker have been fixed.")

```
