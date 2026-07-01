--[[
    ImStyleUI - ImGui / Iris / WindUI Inspired Compact GUI Library
    Tek dosya: library + örnek kullanım aynı script içinde.
    Mobile destekli, PC öncelikli (ImGui zaten dev-tool amaçlı, dense UI).
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

--======================================================
-- TEMA (ImGui klasik koyu tema referans alındı)
--======================================================
local Theme = {
    WindowBg = Color3.fromRGB(15, 15, 17),
    TitleBg = Color3.fromRGB(10, 10, 11),
    TitleBgActive = Color3.fromRGB(28, 55, 92),
    FrameBg = Color3.fromRGB(41, 44, 51),
    FrameBgHover = Color3.fromRGB(53, 57, 66),
    FrameBgActive = Color3.fromRGB(66, 71, 82),
    Border = Color3.fromRGB(50, 50, 54),
    Accent = Color3.fromRGB(51, 122, 218), -- ImGui mavi
    AccentHover = Color3.fromRGB(66, 150, 250),
    Text = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(150, 150, 150),
    Header = Color3.fromRGB(38, 65, 105),
    Font = Enum.Font.Code, -- monospace, dev-tool hissi
    FontSize = IsMobile and 15 or 13,
    RowHeight = IsMobile and 28 or 22,
    Padding = 6,
}

--======================================================
-- YARDIMCI FONKSİYONLAR
--======================================================
local function Create(className, props)
    local inst = Instance.new(className)
    for prop, value in pairs(props or {}) do
        if prop ~= "Parent" then
            inst[prop] = value
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(instance, props, duration)
    duration = duration or 0.08
    local t = 0
    local start = {}
    for k in pairs(props) do start[k] = instance[k] end
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        t = t + dt
        local a = math.clamp(t / duration, 0, 1)
        for k, v in pairs(props) do
            if typeof(v) == "Color3" then
                instance[k] = start[k]:Lerp(v, a)
            elseif typeof(v) == "UDim2" then
                instance[k] = start[k]:Lerp(v, a)
            elseif typeof(v) == "number" then
                instance[k] = start[k] + (v - start[k]) * a
            end
        end
        if a >= 1 then conn:Disconnect() end
    end)
end

local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--======================================================
-- CORE
--======================================================
local ImUI = {}
ImUI.__index = ImUI

function ImUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Window"

    local existing = PlayerGui:FindFirstChild("ImStyleUI_Gui")
    if existing then existing:Destroy() end

    local ScreenGui = Create("ScreenGui", {
        Name = "ImStyleUI_Gui",
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local w = IsMobile and 280 or 300
    local h = IsMobile and 360 or 380

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = UDim2.new(0, w, 0, h),
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
    })
    Create("UIStroke", { Parent = MainFrame, Color = Theme.Border, Thickness = 1 })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 4) })

    -- Title bar (thin, ImGui style)
    local TitleBar = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, IsMobile and 26 or 22),
        BackgroundColor3 = Theme.TitleBgActive,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = TitleBar, CornerRadius = UDim.new(0, 4) })

    -- corner masking fix: cover bottom corners of title bar
    Create("Frame", {
        Parent = TitleBar,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = Theme.TitleBgActive,
        BorderSizePixel = 0,
        ZIndex = 0,
    })

    Create("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -22, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        Text = "x",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Theme.Font,
        TextSize = 12,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = CloseBtn, CornerRadius = UDim.new(0, 2) })
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    MakeDraggable(TitleBar, MainFrame)

    local Content = Create("ScrollingFrame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -8, 1, -(IsMobile and 34 or 28)),
        Position = UDim2.new(0, 4, 0, IsMobile and 30 or 24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    Create("UIListLayout", {
        Parent = Content,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = Content,
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
    })

    return setmetatable({ ScreenGui = ScreenGui, Content = Content, _order = 0 }, ImUI)
end

function ImUI:_next() self._order = self._order + 1; return self._order end

--======================================================
-- SEPARATOR / LABEL (ImGui "Text" widget)
--======================================================
function ImUI:AddSeparatorText(text)
    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })
    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "── " .. text,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return Holder
end

function ImUI:AddLabel(text)
    local Lbl = Create("TextLabel", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = self:_next(),
    })
    return Lbl
end

--======================================================
-- BUTTON (ImGui: küçük, dolgu az, hover değişimi)
--======================================================
function ImUI:AddButton(config)
    config = config or {}
    local text = config.Text or "Button"
    local callback = config.Callback or function() end

    local Btn = Create("TextButton", {
        Parent = self.Content,
        Size = UDim2.new(0, math.max(70, #text * 8 + 20), 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 3) })
    Create("UIStroke", { Parent = Btn, Color = Theme.Border, Thickness = 1 })

    Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.FrameBgHover }) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.FrameBg }) end)
    Btn.MouseButton1Down:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.FrameBgActive }, 0.05) end)
    Btn.MouseButton1Up:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.FrameBgHover }, 0.08) end)
    Btn.MouseButton1Click:Connect(callback)

    return Btn
end

--======================================================
-- CHECKBOX (ImGui: küçük kare + tik)
--======================================================
function ImUI:AddCheckbox(config)
    config = config or {}
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local state = default

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })

    local Box = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(0, IsMobile and 20 or 16, 0, IsMobile and 20 or 16),
        Position = UDim2.new(0, 2, 0.5, -(IsMobile and 10 or 8)),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 2) })
    Create("UIStroke", { Parent = Box, Color = Theme.Border, Thickness = 1 })

    local Check = Create("TextLabel", {
        Parent = Box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = state and "✓" or "",
        TextColor3 = Theme.Accent,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
    })

    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local ClickArea = Create("TextButton", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    ClickArea.MouseButton1Click:Connect(function()
        state = not state
        Check.Text = state and "✓" or ""
        callback(state)
    end)

    return { Set = function(v) state = v; Check.Text = v and "✓" or "" end, Get = function() return state end }
end

--======================================================
-- SLIDER (ImGui: ince bar, değer sağda inline)
--======================================================
function ImUI:AddSlider(config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    local value = default

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 3) })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local Fill = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 3) })

    local Label = Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text = text .. ": " .. tostring(value),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 2,
    })

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - Holder.AbsolutePosition.X) / Holder.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(value)
        callback(value)
    end

    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Set = function(v) value = v end, Get = function() return value end }
end

--======================================================
-- COMBO / DROPDOWN (ImGui "Combo" widget)
--======================================================
function ImUI:AddCombo(config)
    config = config or {}
    local text = config.Text or "Combo"
    local options = config.Options or {}
    local selected = config.Default or options[1] or ""
    local callback = config.Callback or function() end
    local open = false

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = self:_next(),
        ZIndex = 3,
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 3) })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local Header = Create("TextButton", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
    })
    local DisplayLbl = Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = text .. ": " .. tostring(selected),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        ZIndex = 3,
    })

    local List = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 0, #options * Theme.RowHeight),
        Position = UDim2.new(0, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
    })
    Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder })

    for i, opt in ipairs(options) do
        local OptBtn = Create("TextButton", {
            Parent = List,
            Size = UDim2.new(1, 0, 0, Theme.RowHeight),
            BackgroundColor3 = Theme.WindowBg,
            Text = "  " .. tostring(opt),
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = Theme.FontSize - 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            LayoutOrder = i,
        })
        OptBtn.MouseEnter:Connect(function() OptBtn.BackgroundColor3 = Theme.Header end)
        OptBtn.MouseLeave:Connect(function() OptBtn.BackgroundColor3 = Theme.WindowBg end)
        OptBtn.MouseButton1Click:Connect(function()
            selected = opt
            DisplayLbl.Text = text .. ": " .. tostring(selected)
            callback(selected)
            open = false
            Tween(Holder, { Size = UDim2.new(1, -4, 0, Theme.RowHeight) }, 0.12)
        end)
    end

    Header.MouseButton1Click:Connect(function()
        open = not open
        local target = open and (Theme.RowHeight + #options * Theme.RowHeight) or Theme.RowHeight
        Tween(Holder, { Size = UDim2.new(1, -4, 0, target) }, 0.12)
    end)

    return { Set = function(v) selected = v; DisplayLbl.Text = text..": "..tostring(v) end, Get = function() return selected end }
end

--======================================================
-- ÖRNEK KULLANIM
--======================================================
local Window = ImUI:CreateWindow({ Title = "debug window" })

Window:AddSeparatorText("main")
Window:AddButton({ Text = "Click Me", Callback = function() print("clicked") end })
Window:AddCheckbox({ Text = "Enable ESP", Default = false, Callback = function(v) print("ESP:", v) end })
Window:AddSlider({ Text = "Speed", Min = 16, Max = 200, Default = 16, Callback = function(v) print("Speed:", v) end })
Window:AddCombo({ Text = "Mode", Options = { "Legit", "Rage", "Silent" }, Default = "Legit", Callback = function(v) print("Mode:", v) end })

Window:AddSeparatorText("misc")
Window:AddCheckbox({ Text = "Show FPS", Default = true, Callback = function(v) print("FPS:", v) end })
Window:AddButton({ Text = "Reset", Callback = function() print("reset") end })
