TitsUI Documentation

"TitsUI" Roblox için yapılmış compact GUI library’dir.
ImGui / Iris / WindUI hissi verir.

Özellikler

- Draggable window
- Resizable window
- Collapse / Expand
- Mobile support
- 3D Viewport
- Tabs
- Tree Nodes
- Tooltip
- Slider / Combo / Input / Toggle / Checkbox
- ProgressBar / ColorPicker / Keybind

---

Installation

Kodun raw linkini bir yere koy (örn. GitHub raw / Pastebin raw), sonra:
```lua
local TitsUI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()
```
Örnek:
```lua
local TitsUI = loadstring(game:HttpGet("https://example.com/TitsUI.lua"))()
```
---

Create Window
```lua
local Window = TitsUI:CreateWindow({
    Title = "My GUI"
})
```
Parameters

Param| Type| Default| Açıklama
Title| string| ""Window""| Pencere başlığı

---

Label

Text gösterir.
```lua
Window:AddLabel("Hello")
```
---

Separator

Çizgi.

Window:AddSeparator()

---

Separator Text

Başlıklı separator.

Window:AddSeparatorText("Combat")

---

Spacing

Boşluk.

Window:AddSpacing(10)

Param| Type
size| number

---

Button

Window:AddButton({
    Text = "Click Me",
    Callback = function()
        print("clicked")
    end
})

Parameters

Param| Type
Text| string
Callback| function

---

Checkbox

local cb = Window:AddCheckbox({
    Text = "Godmode",
    Default = false,
    Callback = function(state)
        print(state)
    end
})

Methods

cb:Set(true)
print(cb:Get())

---

Toggle

Checkbox’in switch versiyonu.

local toggle = Window:AddToggle({
    Text = "ESP",
    Default = true,
    Callback = function(v)
        print(v)
    end
})

Methods:

toggle:Set(false)
toggle:Get()

---

Slider

local slider = Window:AddSlider({
    Text = "Walkspeed",
    Min = 16,
    Max = 300,
    Default = 50,
    Callback = function(v)
        print(v)
    end
})

Parameters

Param| Type
Text| string
Min| number
Max| number
Default| number
Callback| function

Methods:

slider:Set(100)
slider:Get()

---

Combo / Dropdown

local combo = Window:AddCombo({
    Text = "Mode",
    Options = {"A","B","C"},
    Default = "A",
    Callback = function(v)
        print(v)
    end
})

Methods:

combo:Set("B")
combo:Get()

---

Input Text

local input = Window:AddInputText({
    Text = "Username",
    Placeholder = "Type...",
    Default = "",
    Callback = function(text, enterPressed)
        print(text)
    end
})

Methods:

input:Set("Emir")
input:Get()

---

Input Number

local num = Window:AddInputNumber({
    Text = "Damage",
    Default = 10,
    Step = 5,
    Callback = function(v)
        print(v)
    end
})

Methods:

num:Set(50)
num:Get()

---

Radio Buttons

local radio = Window:AddRadioButtons({
    Text = "Team",
    Options = {"Red","Blue"},
    Default = "Red",
    Callback = function(v)
        print(v)
    end
})

Methods:

radio:Set("Blue")
radio:Get()

---

Progress Bar

local bar = Window:AddProgressBar({
    Text = "Loading",
    Default = 0.25
})

Set progress:

bar:Set(0.8)

Range:

- 0 → empty
- 1 → full

---

Color Picker

local picker = Window:AddColorPicker({
    Text = "Accent",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(color)
        print(color)
    end
})

Methods:

picker:Set(Color3.new(1,1,1))
picker:Get()

---

Keybind

local bind = Window:AddKeybind({
    Text = "Open Menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        print("Pressed")
    end
})

Methods:

bind:Set(Enum.KeyCode.F)
bind:Get()

---

Tree Node

Collapsible section.

local Node = Window:AddTreeNode({
    Text = "Advanced",
    DefaultOpen = false
})

Node:AddLabel("Hidden stuff")

---

Tabs

local Tabs = Window:AddTabBar({
    "Main",
    "Settings",
    "Info"
})

Tabs.Tab("Main"):AddLabel("Hello")
Tabs.Tab("Settings"):AddButton({
    Text = "Save"
})

---

Tooltip

local btn = Window:AddButton({
    Text = "Help"
})

Window:AddTooltip(btn, "This is tooltip")

---

Image

Window:AddImage({
    Image = "rbxassetid://123456",
    Height = 120
})

---

3D View

Viewport içinde model render eder.

Window:Add3DView({
    Model = workspace.Dummy,
    Height = 250,
    AutoRotate = true,
    RotateSpeed = 35
})

Parameters

Param| Type| Default
Model| Model| nil
Height| number| 250
AutoRotate| boolean| true
RotateSpeed| number| 35

Özellik:

- Drag ile rotate
- Auto rotate
- Mobile support

---

Full Example

local TitsUI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()

local Window = TitsUI:CreateWindow({
    Title = "TitsUI Full Example"
})

-- Label
Window:AddLabel("Hello World")

-- Separator Text
Window:AddSeparatorText("Basic")

-- Button
local HelpButton = Window:AddButton({
    Text = "Click Me",
    Callback = function()
        print("clicked")
    end
})

-- Tooltip
Window:AddTooltip(HelpButton, "This is a button")

-- Checkbox
local cb = Window:AddCheckbox({
    Text = "Godmode",
    Default = false,
    Callback = function(v)
        print("Checkbox:", v)
    end
})

-- Toggle
local tg = Window:AddToggle({
    Text = "ESP",
    Default = true,
    Callback = function(v)
        print("Toggle:", v)
    end
})

-- Slider
local slider = Window:AddSlider({
    Text = "Walkspeed",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(v)
        print("Slider:", v)
    end
})

Window:AddSeparator()

-- Combo
local combo = Window:AddCombo({
    Text = "Mode",
    Options = {"Normal", "Rage", "Stealth"},
    Default = "Normal",
    Callback = function(v)
        print("Combo:", v)
    end
})

-- Input Text
local textInput = Window:AddInputText({
    Text = "Username",
    Placeholder = "Type here",
    Callback = function(text)
        print("Text:", text)
    end
})

-- Input Number
local numberInput = Window:AddInputNumber({
    Text = "Damage",
    Default = 50,
    Step = 5,
    Callback = function(v)
        print("Number:", v)
    end
})

-- Radio Buttons
local radio = Window:AddRadioButtons({
    Text = "Team",
    Options = {"Red", "Blue"},
    Default = "Red",
    Callback = function(v)
        print("Radio:", v)
    end
})

-- Progress Bar
local progress = Window:AddProgressBar({
    Text = "Loading",
    Default = 0.25
})

task.spawn(function()
    for i = 0, 100 do
        progress:Set(i/100)
        task.wait(0.03)
    end
end)

-- Color Picker
local picker = Window:AddColorPicker({
    Text = "Accent Color",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(c)
        print("Color:", c)
    end
})

-- Keybind
local bind = Window:AddKeybind({
    Text = "Menu Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        print("Keybind pressed")
    end
})

-- Tree Node
local Node = Window:AddTreeNode({
    Text = "Advanced Settings",
    DefaultOpen = false
})

Node:AddLabel("Secret Stuff")
Node:AddButton({
    Text = "Secret Button",
    Callback = function()
        print("secret")
    end
})

-- Tabs
local Tabs = Window:AddTabBar({
    "Main",
    "Settings",
    "Info"
})

Tabs.Tab("Main"):AddLabel("Main Tab")
Tabs.Tab("Settings"):AddLabel("Settings Tab")
Tabs.Tab("Info"):AddLabel("Info Tab")

-- Image
Window:AddImage({
    Image = "rbxassetid://7072718362",
    Height = 100
})

-- 3D View
if workspace:FindFirstChild("Dummy") then
    Window:Add3DView({
        Model = workspace.Dummy,
        Height = 200,
        AutoRotate = true,
        RotateSpeed = 40
    })
end
---

Notes

- Sadece 1 window açık kalır.
- Yeni window açılırsa eski destroy edilir.
- GUI name:

ImStyleUI_Gui

- Library return ettiği object:

ImUI
