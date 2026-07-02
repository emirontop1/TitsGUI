# TitsUI Documentation

TitsUI is a compact Roblox GUI library inspired by ImGui, Iris, and WindUI.
Designed for exploit/executor environments with mobile and desktop support.

## Installation

```lua
local TitsUI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()
```

---

## Create Window

Creates a new draggable and resizable window.

### Example
```lua
local Window = TitsUI:CreateWindow({
    Title = "My GUI"
})
```

### Parameters
| Name | Type | Description |
|---|---|---|
| Title | string | Window title |

---

## Widgets

### AddLabel
Displays text.

```lua
Window:AddLabel("Hello World")
```

### AddSeparator
Creates a horizontal line.

```lua
Window:AddSeparator()
```

### AddSeparatorText
Creates a titled separator.

```lua
Window:AddSeparatorText("Combat")
```

### AddSpacing
Adds vertical spacing.

```lua
Window:AddSpacing(10)
```

### AddButton
Clickable button.

```lua
local btn = Window:AddButton({
    Text = "Click Me",
    Callback = function()
        print("clicked")
    end
})
```

Parameters:
- Text: string
- Callback: function

### AddTooltip
Shows tooltip on hover/touch.

```lua
Window:AddTooltip(btn, "Tooltip text")
```

### AddCheckbox

```lua
local cb = Window:AddCheckbox({
    Text = "Godmode",
    Default = false,
    Callback = function(v)
        print(v)
    end
})
```

Methods:
```lua
cb:Set(true)
print(cb:Get())
```

### AddToggle

```lua
local tg = Window:AddToggle({
    Text = "ESP",
    Default = true
})
```

Methods:
```lua
tg:Set(false)
tg:Get()
```

### AddSlider

```lua
local slider = Window:AddSlider({
    Text = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(v)
        print(v)
    end
})
```

Methods:
```lua
slider:Set(75)
slider:Get()
```

### AddCombo

```lua
local combo = Window:AddCombo({
    Text = "Mode",
    Options = {"A","B","C"},
    Default = "A"
})
```

### AddInputText

```lua
Window:AddInputText({
    Text = "Username",
    Placeholder = "Type here"
})
```

### AddInputNumber

```lua
Window:AddInputNumber({
    Text = "Damage",
    Default = 50,
    Step = 5
})
```

### AddRadioButtons

```lua
Window:AddRadioButtons({
    Text = "Team",
    Options = {"Red", "Blue"}
})
```

### AddProgressBar

```lua
local bar = Window:AddProgressBar({
    Text = "Loading",
    Default = 0.3
})

bar:Set(0.8)
```

### AddColorPicker

```lua
Window:AddColorPicker({
    Text = "Accent",
    Default = Color3.fromRGB(255,0,0)
})
```

### AddKeybind

```lua
Window:AddKeybind({
    Text = "Open Menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        print("Pressed")
    end
})
```

### AddTreeNode

```lua
local node = Window:AddTreeNode({
    Text = "Advanced"
})

node:AddLabel("Hidden content")
```

### AddTabBar

```lua
local Tabs = Window:AddTabBar({
    "Main",
    "Settings"
})

Tabs.Tab("Main"):AddLabel("Main tab")
Tabs.Tab("Settings"):AddLabel("Settings tab")
```

### AddImage

```lua
Window:AddImage({
    Image = "rbxassetid://123456",
    Height = 120
})
```

### Add3DView

```lua
Window:Add3DView({
    Model = workspace.Dummy,
    Height = 250,
    AutoRotate = true,
    RotateSpeed = 35
})
```

Parameters:
- Model: Model
- Height: number
- AutoRotate: boolean
- RotateSpeed: number

---

# Full Example

```lua
local TitsUI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()

local Window = TitsUI:CreateWindow({
    Title = "TitsUI Full Example"
})

Window:AddLabel("Hello World")
Window:AddSeparatorText("Basic Widgets")
Window:AddSpacing(5)

local helpBtn = Window:AddButton({
    Text = "Click Me",
    Callback = function()
        print("clicked")
    end
})

Window:AddTooltip(helpBtn, "This is a tooltip")

Window:AddCheckbox({
    Text = "Godmode",
    Default = false,
    Callback = function(v)
        print("Checkbox:", v)
    end
})

Window:AddToggle({
    Text = "ESP",
    Default = true,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Window:AddSlider({
    Text = "Walkspeed",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(v)
        print("Slider:", v)
    end
})

Window:AddSeparator()

Window:AddCombo({
    Text = "Mode",
    Options = {"Normal", "Rage", "Stealth"},
    Default = "Normal",
    Callback = function(v)
        print("Combo:", v)
    end
})

Window:AddInputText({
    Text = "Username",
    Placeholder = "Type here",
    Callback = function(text)
        print(text)
    end
})

Window:AddInputNumber({
    Text = "Damage",
    Default = 50,
    Step = 5,
    Callback = function(v)
        print(v)
    end
})

Window:AddRadioButtons({
    Text = "Team",
    Options = {"Red", "Blue"},
    Default = "Red",
    Callback = function(v)
        print(v)
    end
})

local progress = Window:AddProgressBar({
    Text = "Loading",
    Default = 0.25
})

progress:Set(0.75)

Window:AddColorPicker({
    Text = "Accent Color",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(color)
        print(color)
    end
})

Window:AddKeybind({
    Text = "Menu Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        print("Keybind pressed")
    end
})

local node = Window:AddTreeNode({
    Text = "Advanced Settings",
    DefaultOpen = false
})

node:AddLabel("Hidden content")
node:AddButton({
    Text = "Secret Button",
    Callback = function()
        print("secret")
    end
})

local Tabs = Window:AddTabBar({
    "Main",
    "Settings",
    "Info"
})

Tabs.Tab("Main"):AddLabel("Main Tab")
Tabs.Tab("Settings"):AddLabel("Settings Tab")
Tabs.Tab("Info"):AddLabel("Info Tab")

Window:AddImage({
    Image = "rbxassetid://7072718362",
    Height = 100
})

if workspace:FindFirstChild("Dummy") then
    Window:Add3DView({
        Model = workspace.Dummy,
        Height = 200,
        AutoRotate = true,
        RotateSpeed = 40
    })
end
```

---

## Notes
- Only one window can exist at a time.
- Opening a new window destroys the previous one.
- GUI Name: `ImStyleUI_Gui`
- Exported Object: `ImUI`
- 
