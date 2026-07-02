--[[
    ImStyleUI - ImGui / Iris / WindUI Inspired Compact GUI Library
    Tek dosya: library + örnek kullanım aynı script içinde.
    Mobile destekli, PC öncelikli (ImGui zaten dev-tool amaçlı, dense UI).
--]]
--[[
  •Please fix the add console.
  •Add better usage And dont waste Iris/IMGUI
]]
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

-- ImGui'deki "active id" mantığının basit hali: aynı anda sadece TEK bir
-- sürüklenebilir widget input alabilir. Bu sayede hızlı el/parmak hareketinde
-- komşu slider'ların yanlışlıkla değer değiştirmesi engellenir.
local ActiveDrag = nil

function ImUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Window"

    local existing = PlayerGui:FindFirstChild("ImStyleUI_Gui")
    
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
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, w * 0.9, 0, h * 0.9),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    Create("UIStroke", { Parent = MainFrame, Color = Theme.Border, Thickness = 1 })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 0) })

    -- Title bar (thin, ImGui style)
    local titleBarH = IsMobile and 26 or 22
    local TitleBar = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, titleBarH),
        BackgroundColor3 = Theme.TitleBgActive,
        BorderSizePixel = 0,
    })

    -- corner masking fix: cover bottom corners of title bar
    Create("Frame", {
        Parent = TitleBar,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = Theme.TitleBgActive,
        BorderSizePixel = 0,
        ZIndex = 0,
    })

    -- Iris'teki gibi pencereyi katlayan (collapse) ok butonu
    local CollapseBtn = Create("TextButton", {
        Parent = TitleBar,
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
    })

    Create("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
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
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    MakeDraggable(TitleBar, MainFrame)

    local contentTop = IsMobile and 30 or 24
    local Content = Create("ScrollingFrame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -8, 1, -contentTop),
        Position = UDim2.new(0, 4, 0, contentTop),
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

    -- Katla/aç: içerik gizlenir, pencere sadece title bar yüksekliğine iner
    local collapsed = false
    local expandedH = h
    CollapseBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        CollapseBtn.Text = collapsed and "▸" or "▾"
        Content.Visible = not collapsed
        Tween(MainFrame, { Size = UDim2.new(0, MainFrame.AbsoluteSize.X, 0, collapsed and titleBarH or expandedH) }, 0.12)
    end)

    -- Sağ alt köşeden sürükleyerek yeniden boyutlandırma (Iris'teki mavi üçgen köşe)
    local ResizeHandle = Create("TextButton", {
        Parent = MainFrame,
        Size = UDim2.new(0, IsMobile and 22 or 16, 0, IsMobile and 22 or 16),
        Position = UDim2.new(1, -(IsMobile and 22 or 16), 1, -(IsMobile and 22 or 16)),
        BackgroundTransparency = 1,
        Text = "◢",
        TextColor3 = Theme.Accent,
        Font = Theme.Font,
        TextSize = IsMobile and 16 or 12,
        ZIndex = 5,
    })
    local resizing = false
    local resizeStart, sizeStart
    local MIN_W, MIN_H = 200, 120
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            sizeStart = MainFrame.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newW = math.max(MIN_W, sizeStart.X.Offset + delta.X)
            local newH = math.max(MIN_H, sizeStart.Y.Offset + delta.Y)
            MainFrame.Size = UDim2.new(0, newW, 0, newH)
            if not collapsed then expandedH = newH end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)

    Tween(MainFrame, { Size = UDim2.new(0, w, 0, h), BackgroundTransparency = 0 }, 0.18)

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
    Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Btn, Color = Theme.Border, Thickness = 1 })
    local Scale = Create("UIScale", { Parent = Btn, Scale = 1 })

    Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.FrameBgHover }) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.FrameBg }); Tween(Scale, { Scale = 1 }, 0.08) end)
    Btn.MouseButton1Down:Connect(function()
        Tween(Btn, { BackgroundColor3 = Theme.FrameBgActive }, 0.05)
        Tween(Scale, { Scale = 0.95 }, 0.05)
    end)
    Btn.MouseButton1Up:Connect(function()
        Tween(Btn, { BackgroundColor3 = Theme.FrameBgHover }, 0.08)
        Tween(Scale, { Scale = 1 }, 0.1)
    end)
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
    Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Box, Color = Theme.Border, Thickness = 1 })

    local Check = Create("TextLabel", {
        Parent = Box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓",
        TextTransparency = state and 0 or 1,
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

    local function render(v, animate)
        if animate then
            Tween(Check, { TextTransparency = v and 0 or 1 }, 0.1)
            Tween(Box, { BackgroundColor3 = v and Theme.FrameBgActive or Theme.FrameBg }, 0.1)
        else
            Check.TextTransparency = v and 0 or 1
            Box.BackgroundColor3 = v and Theme.FrameBgActive or Theme.FrameBg
        end
    end

    ClickArea.MouseButton1Click:Connect(function()
        state = not state
        render(state, true)
        callback(state)
    end)

    return { Set = function(v) state = v; render(v, false) end, Get = function() return state end }
end

--======================================================
-- TOGGLE (iOS tarzı anahtar - kayan yuvarlak + renk geçişi animasyonlu)
--======================================================
function ImUI:AddToggle(config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local state = default

    -- Iris/ImGui'nin yoğun, köşeli hissini koruyan küçük düz switch.
    -- (Önceki sürüm büyük, tam yuvarlak bir iOS pilliydi - burada daha
    -- kompakt, keskin köşeli ve checkbox ile aynı satır yüksekliğinde.)
    local trackW = IsMobile and 34 or 28
    local trackH = IsMobile and 18 or 14
    local knobSize = trackH - 6

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })

    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, -(trackW + 12), 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local Track = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(0, trackW, 0, trackH),
        Position = UDim2.new(1, -trackW, 0.5, -trackH / 2),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
    })
    Create("UIStroke", { Parent = Track, Color = Theme.Border, Thickness = 1 })

    local Knob = Create("Frame", {
        Parent = Track,
        Size = UDim2.new(0, knobSize, 1, -6),
        Position = state
            and UDim2.new(1, -knobSize - 3, 0.5, 0)
            or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = state and Theme.Accent or Theme.TextDim,
        BorderSizePixel = 0,
    })

    local ClickArea = Create("TextButton", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })

    local function render(v, animate)
        local knobGoal = v
            and UDim2.new(1, -knobSize - 3, 0.5, 0)
            or UDim2.new(0, 3, 0.5, 0)
        local knobColor = v and Theme.Accent or Theme.TextDim
        if animate then
            Tween(Knob, { Position = knobGoal, BackgroundColor3 = knobColor }, 0.08)
        else
            Knob.Position = knobGoal
            Knob.BackgroundColor3 = knobColor
        end
    end

    ClickArea.MouseButton1Click:Connect(function()
        state = not state
        render(state, true)
        callback(state)
    end)

    return { Set = function(v) state = v; render(v, false) end, Get = function() return state end }
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


function ImUI:Add3DView(config)
    config = config or {}
    local model = config.Model
    local height = config.Height or 250
    local autoRotate = config.AutoRotate ~= false
    local rotateSpeed = config.RotateSpeed or 35

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next()
    })

    Create("UICorner", {Parent = Holder, CornerRadius = UDim.new(0,4)})

    local Viewport = Create("ViewportFrame", {
        Parent = Holder,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1
    })

    local cam = Instance.new("Camera")
    cam.Parent = Viewport
    Viewport.CurrentCamera = cam

    if not model then
        return Viewport
    end

    local clone = model:Clone()
    clone.Parent = Viewport

    local cf, size = clone:GetBoundingBox()
    local center = cf.Position
    local dist = math.max(size.X,size.Y,size.Z) * 2.2

    cam.CFrame = CFrame.new(center + Vector3.new(0,0,dist), center)

    local rotX = 0
    local rotY = 0
    local dragging = false
    local lastPos

    local function applyRotation()
        clone:PivotTo(
            CFrame.new(center)
            * CFrame.Angles(math.rad(rotY), math.rad(rotX), 0)
        )
    end

    Viewport.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            lastPos = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - lastPos
            rotX += delta.X * 0.5
            rotY -= delta.Y * 0.5
            rotY = math.clamp(rotY, -80, 80)
            lastPos = input.Position
            applyRotation()
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if autoRotate and not dragging then
            rotX += rotateSpeed * dt
            applyRotation()
        end
    end)

    return Viewport
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
        ClipsDescendants = false,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
    local Stroke = Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local Fill = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 0) })

    -- Sürükleme tutamacı (thumb): sadece görsel geri bildirim, tıklama hâlâ
    -- bar'ın her yerinden çalışır ama sürüklerken parmağın/imlecin tam olarak
    -- nerede olduğunu görmek karışıklığı azaltır.
    local Thumb = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(0, 3, 1, 4),
        Position = UDim2.new((value - min) / (max - min), -1, 0, -2),
        BackgroundColor3 = Theme.AccentHover,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    Create("UICorner", { Parent = Thumb, CornerRadius = UDim.new(0, 0) })

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
        ZIndex = 3,
    })

    local function render(rel, v)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Thumb.Position = UDim2.new(rel, -1, 0, -2)
        Label.Text = text .. ": " .. tostring(v)
    end

    local function update(x)
        local rel = math.clamp((x - Holder.AbsolutePosition.X) / Holder.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel)
        render(rel, value)
        callback(value)
    end

    -- Sadece BU slider'ı tıkladığında ActiveDrag'i ele geçirir; başka bir
    -- widget zaten sürüklemedeyse burası input'u yok sayar. Bu, hızlı el
    -- hareketinde komşu slider'ın da tetiklenmesini engelleyen asıl fix.
    Holder.InputBegan:Connect(function(input)
        if ActiveDrag ~= nil then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveDrag = Holder
            Tween(Stroke, { Color = Theme.Accent }, 0.08)
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if ActiveDrag ~= Holder then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if ActiveDrag ~= Holder then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveDrag = nil
            Tween(Stroke, { Color = Theme.Border }, 0.12)
        end
    end)

    return {
        Set = function(v)
            value = math.clamp(v, min, max)
            render((value - min) / (max - min), value)
        end,
        Get = function() return value end,
    }
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
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
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
-- SEPARATOR (düz çizgi, ImGui::Separator)
--======================================================
function ImUI:AddSeparator()
    local Line = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    return Line
end

--======================================================
-- SPACING / DUMMY (ImGui::Spacing / Dummy)
--======================================================
function ImUI:AddSpacing(size)
    local Spacer = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, size or 6),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })
    return Spacer
end

--======================================================
-- INPUT TEXT (ImGui::InputText)
--======================================================
function ImUI:AddInputText(config)
    config = config or {}
    local text = config.Text or "Input"
    local placeholder = config.Placeholder or ""
    local default = config.Default or ""
    local callback = config.Callback or function() end

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })

    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(0.4, -4, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local Box = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Box, Color = Theme.Border, Thickness = 1 })

    local TextBox = Create("TextBox", {
        Parent = Box,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    TextBox.FocusLost:Connect(function(enterPressed)
        callback(TextBox.Text, enterPressed)
    end)

    return { Set = function(v) TextBox.Text = v end, Get = function() return TextBox.Text end }
end

--======================================================
-- INPUT NUMBER (ImGui::InputInt / InputFloat)
--======================================================
function ImUI:AddInputNumber(config)
    config = config or {}
    local text = config.Text or "Number"
    local default = config.Default or 0
    local step = config.Step or 1
    local callback = config.Callback or function() end
    local value = default

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })

    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(0.4, -4, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local Box = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Box, Color = Theme.Border, Thickness = 1 })

    local btnW = IsMobile and 26 or 18

    local MinusBtn = Create("TextButton", {
        Parent = Box,
        Size = UDim2.new(0, btnW, 1, 0),
        BackgroundTransparency = 1,
        Text = "-",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize + (IsMobile and 2 or 0),
    })

    local ValueBox = Create("TextBox", {
        Parent = Box,
        Size = UDim2.new(1, -btnW * 2, 1, 0),
        Position = UDim2.new(0, btnW, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local PlusBtn = Create("TextButton", {
        Parent = Box,
        Size = UDim2.new(0, btnW, 1, 0),
        Position = UDim2.new(1, -btnW, 0, 0),
        BackgroundTransparency = 1,
        Text = "+",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize + (IsMobile and 2 or 0),
    })

    local function setValue(v)
        value = v
        ValueBox.Text = tostring(value)
        callback(value)
    end

    MinusBtn.MouseButton1Click:Connect(function() setValue(value - step) end)
    PlusBtn.MouseButton1Click:Connect(function() setValue(value + step) end)
    ValueBox.FocusLost:Connect(function()
        local n = tonumber(ValueBox.Text)
        setValue(n or value)
    end)

    return { Set = setValue, Get = function() return value end }
end

--======================================================
-- RADIO BUTTON GROUP (ImGui::RadioButton)
--======================================================
function ImUI:AddRadioButtons(config)
    config = config or {}
    local text = config.Text
    local options = config.Options or {}
    local selected = config.Default or options[1]
    local callback = config.Callback or function() end
    local buttons = {}

    if text then self:AddSeparatorText(text) end

    for _, opt in ipairs(options) do
        local Holder = Create("Frame", {
            Parent = self.Content,
            Size = UDim2.new(1, 0, 0, Theme.RowHeight),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
        })

        local circleSize = IsMobile and 18 or 14
        local Circle = Create("Frame", {
            Parent = Holder,
            Size = UDim2.new(0, circleSize, 0, circleSize),
            Position = UDim2.new(0, 2, 0.5, -circleSize / 2),
            BackgroundColor3 = Theme.FrameBg,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Circle, CornerRadius = UDim.new(1, 0) })
        Create("UIStroke", { Parent = Circle, Color = Theme.Border, Thickness = 1 })

        local dotSize = circleSize - 7
        local Dot = Create("Frame", {
            Parent = Circle,
            Size = UDim2.new(0, dotSize, 0, dotSize),
            Position = UDim2.new(0.5, -dotSize / 2, 0.5, -dotSize / 2),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = (opt == selected) and 0 or 1,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Dot, CornerRadius = UDim.new(1, 0) })

        Create("TextLabel", {
            Parent = Holder,
            Size = UDim2.new(1, -26, 1, 0),
            Position = UDim2.new(0, 22, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(opt),
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

        buttons[opt] = Dot
        ClickArea.MouseButton1Click:Connect(function()
            selected = opt
            for k, d in pairs(buttons) do
                d.BackgroundTransparency = (k == selected) and 0 or 1
            end
            callback(selected)
        end)
    end

    return {
        Set = function(v)
            selected = v
            for k, d in pairs(buttons) do d.BackgroundTransparency = (k == selected) and 0 or 1 end
        end,
        Get = function() return selected end,
    }
end

--======================================================
-- PROGRESS BAR (ImGui::ProgressBar)
--======================================================
function ImUI:AddProgressBar(config)
    config = config or {}
    local text = config.Text or ""
    local default = config.Default or 0 -- 0..1

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local Fill = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(math.clamp(default, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 0) })

    local Label = Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text ~= "" and text or (math.floor(default * 100) .. "%"),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 2,
    })

    return {
        Set = function(v)
            v = math.clamp(v, 0, 1)
            Tween(Fill, { Size = UDim2.new(v, 0, 1, 0) }, 0.1)
            Label.Text = text ~= "" and text or (math.floor(v * 100) .. "%")
        end,
    }
end

--======================================================
-- COLOR PICKER (ImGui::ColorEdit3 - RGB slider tabanlı)
--======================================================
function ImUI:AddColorPicker(config)
    config = config or {}
    local text = config.Text or "Color"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local callback = config.Callback or function() end
    local color = default

    self:AddSeparatorText(text)

    local Preview = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, 16),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Preview, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Preview, Color = Theme.Border, Thickness = 1 })

    local function makeChannelSlider(label, getComp, setComp)
        return self:AddSlider({
            Text = label,
            Min = 0,
            Max = 255,
            Default = math.floor(getComp(color) * 255),
            Callback = function(v)
                color = setComp(color, v / 255)
                Preview.BackgroundColor3 = color
                callback(color)
            end,
        })
    end

    local rCtrl = makeChannelSlider("R", function(c) return c.R end, function(c, v) return Color3.new(v, c.G, c.B) end)
    local gCtrl = makeChannelSlider("G", function(c) return c.G end, function(c, v) return Color3.new(c.R, v, c.B) end)
    local bCtrl = makeChannelSlider("B", function(c) return c.B end, function(c, v) return Color3.new(c.R, c.G, v) end)

    return {
        Set = function(v)
            color = v
            Preview.BackgroundColor3 = color
            rCtrl.Set(math.floor(v.R * 255))
            gCtrl.Set(math.floor(v.G * 255))
            bCtrl.Set(math.floor(v.B * 255))
        end,
        Get = function() return color end,
    }
end

--======================================================
-- KEYBIND (dev-tool GUI'lerde standart yardımcı widget)
--======================================================
function ImUI:AddKeybind(config)
    config = config or {}
    local text = config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local key = default
    local listening = false

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })

    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local KeyBtn = Create("TextButton", {
        Parent = Holder,
        Size = UDim2.new(0.4, -4, 1, -4),
        Position = UDim2.new(0.6, 0, 0, 2),
        BackgroundColor3 = Theme.FrameBg,
        Text = key.Name,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = KeyBtn, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = KeyBtn, Color = Theme.Border, Thickness = 1 })

    KeyBtn.MouseButton1Click:Connect(function()
        listening = true
        KeyBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            KeyBtn.Text = key.Name
            listening = false
        elseif not gpe and key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
            callback()
        end
    end)

    return { Set = function(v) key = v; KeyBtn.Text = v.Name end, Get = function() return key end }
end

--======================================================
-- TREE NODE / COLLAPSING HEADER (ImGui::TreeNode)
--======================================================
function ImUI:AddTreeNode(config)
    config = config or {}
    local text = config.Text or "Node"
    local defaultOpen = config.DefaultOpen or false

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        LayoutOrder = self:_next(),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local HeaderBtn = Create("TextButton", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        Text = "",
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = HeaderBtn, CornerRadius = UDim.new(0, 0) })

    local Arrow = Create("TextLabel", {
        Parent = HeaderBtn,
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        Rotation = defaultOpen and 90 or 0,
        BackgroundTransparency = 1,
        Text = "▸",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
    })

    Create("TextLabel", {
        Parent = HeaderBtn,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local SubContent = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 12, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    Create("UIListLayout", { Parent = SubContent, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    local open = defaultOpen
    SubContent.Visible = open

    HeaderBtn.MouseEnter:Connect(function() Tween(HeaderBtn, { BackgroundColor3 = Theme.FrameBgHover }, 0.08) end)
    HeaderBtn.MouseLeave:Connect(function() Tween(HeaderBtn, { BackgroundColor3 = Theme.FrameBg }, 0.1) end)

    HeaderBtn.MouseButton1Click:Connect(function()
        open = not open
        SubContent.Visible = open
        Tween(Arrow, { Rotation = open and 90 or 0 }, 0.12)
    end)

    return setmetatable({ Content = SubContent, _order = 0 }, ImUI)
end

--======================================================
-- TAB BAR (ImGui::BeginTabBar / TabItem)
--======================================================
function ImUI:AddTabBar(tabNames)
    tabNames = tabNames or {}

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local TabButtons = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
    })
    Create("UIListLayout", { Parent = TabButtons, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2) })

    -- Aktif sekmenin altında kayan ince bir çizgi (Iris/modern sekme hissi için)
    local Underline = Create("Frame", {
        Parent = TabButtons,
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    })

    local PagesHolder = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, Theme.RowHeight + 2),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local tabs = {}

    for i, name in ipairs(tabNames) do
        local TabBtn = Create("TextButton", {
            Parent = TabButtons,
            Size = UDim2.new(0, math.max(60, #name * 8 + 16), 1, 0),
            BackgroundColor3 = (i == 1) and Theme.Header or Theme.FrameBg,
            Text = name,
            TextColor3 = Theme.Text,
            Font = Theme.Font,
            TextSize = Theme.FontSize - 1,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 0) })

        local Page = Create("Frame", {
            Parent = PagesHolder,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = (i == 1),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        Create("UIListLayout", { Parent = Page, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

        local pageObj = setmetatable({ Content = Page, _order = 0 }, ImUI)
        tabs[name] = { Button = TabBtn, Page = Page, Obj = pageObj }

        TabBtn.MouseButton1Click:Connect(function()
            for n, t in pairs(tabs) do
                t.Page.Visible = (n == name)
                Tween(t.Button, { BackgroundColor3 = (n == name) and Theme.Header or Theme.FrameBg }, 0.1)
            end
            Tween(Underline, {
                Size = UDim2.new(0, TabBtn.AbsoluteSize.X, 0, 2),
                Position = UDim2.new(0, TabBtn.AbsolutePosition.X - TabButtons.AbsolutePosition.X, 1, -1),
            }, 0.14)
        end)

        if i == 1 then
            task.defer(function()
                Underline.Size = UDim2.new(0, TabBtn.AbsoluteSize.X, 0, 2)
                Underline.Position = UDim2.new(0, TabBtn.AbsolutePosition.X - TabButtons.AbsolutePosition.X, 1, -1)
            end)
        end
    end

    return {
        Tab = function(name) return tabs[name] and tabs[name].Obj end,
    }
end

--======================================================
-- TOOLTIP (ImGui::SetTooltip - hover üzerine bilgi kutusu)
--======================================================
function ImUI:AddTooltip(target, text)
    if not target or not target:IsA("GuiObject") then return end

    local ScreenGuiRef = self.ScreenGui or self.Content:FindFirstAncestorOfClass("ScreenGui")

    local Tip = Create("TextLabel", {
        Parent = ScreenGuiRef,
        Size = UDim2.new(0, math.max(60, #text * 7 + 12), 0, 20),
        BackgroundColor3 = Theme.TitleBg,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 2,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    })
    Create("UICorner", { Parent = Tip, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Tip, Color = Theme.Border, Thickness = 1 })

    target.MouseEnter:Connect(function() Tip.Visible = true end)
    target.MouseMoved:Connect(function(x, y)
        Tip.Position = UDim2.new(0, x + 12, 0, y + 12)
    end)
    target.MouseLeave:Connect(function() Tip.Visible = false end)

    -- Mobilde hover olmadığı için dokununca kısa süreliğine gösterip otomatik kapatıyoruz
    if IsMobile then
        target.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            Tip.Position = UDim2.new(0, target.AbsolutePosition.X, 0, target.AbsolutePosition.Y - 24)
            Tip.Visible = true
            task.delay(1.6, function() Tip.Visible = false end)
        end)
    end

    return Tip
end

function ImUI:AddConsole(config)
    config = config or {}
    config.MaxLines = config.MaxLines or 150

    local ConsoleGui = Create("ScreenGui", {
        Name = "ImUI_Console_" .. tostring(math.random(1,999999)),
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local width = config.Width or 400
    local height = config.Height or 250

    -- Gerçek ImGui Tarzı Keskin Panel
    local Main = Create("Frame", {
        Parent = ConsoleGui,
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.75, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0
    })

    -- İnce Sert Border (ImGui Standartı)
    Create("UIStroke", {
        Parent = Main,
        Color = Theme.Border,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    -- Başlık Çubuğu
    local TitleBar = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 20), -- ImGui tarzı daha dar başlık alanı
        BackgroundColor3 = Theme.TitleBgActive, -- Aktif pencere rengi
        BorderSizePixel = 0
    })

    Create("TextLabel", {
        Parent = TitleBar,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Console",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Sert Köşeli Küçük Kapatma Butonu
    local Close = Create("TextButton", {
        Parent = TitleBar,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -2, 0, 2),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Color3.fromRGB(150, 40, 40),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Theme.Font,
        TextSize = Theme.FontSize - 2
    })

    Close.MouseButton1Click:Connect(function()
        ConsoleGui:Destroy()
    end)

    -- Sürükleme Mekanizması
    local dragging = false
    local dragStart
    local startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Terminal / Liste Alanı (Koyu ve İnce Scrollbar)
    local Holder = Create("ScrollingFrame", {
        Parent = Main,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 1, -20),
        BackgroundColor3 = Color3.fromRGB(12, 12, 14), -- Çok koyu iç alan
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 3, -- Ultra ince kaydırma çubuğu
        ScrollBarImageColor3 = Theme.Border
    })

    local ListLayout = Create("UIListLayout", {
        Parent = Holder,
        Padding = UDim.new(0, 1), -- Satırlar arası çok dar mesafe (Kompakt görünüm)
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Create("UIPadding", {
        Parent = Holder,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    })

    local console = {}
    local lines = {}
    local lineCounter = 0

    local function getTime()
        return os.date("%H:%M:%S")
    end

    local function push(prefix, text, color)
        lineCounter = lineCounter + 1
        
        -- Gerçek ImGui metin yapısı (Sıkıştırılmış satır yüksekliği, Monospace font)
        local LogLabel = Create("TextLabel", {
            Parent = Holder,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = string.format("[%s] [%s] %s", getTime(), prefix, tostring(text)),
            TextColor3 = color,
            Font = Theme.Font, -- Kod içindeki 'Enum.Font.Code' yapısını kullanır
            TextSize = Theme.FontSize - 2, -- Yazılar hafif küçük ve sıkı olur
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            RichText = true,
            LayoutOrder = lineCounter
        })

        table.insert(lines, LogLabel)

        if #lines > config.MaxLines then
            local oldLine = table.remove(lines, 1)
            if oldLine then oldLine:Destroy() end
        end

        task.defer(function()
            if Holder then
                Holder.CanvasPosition = Vector2.new(0, Holder.AbsoluteCanvasSize.Y)
            end
        end)
    end

    function console:Log(text)
        push("INFO", text, Theme.Text)
    end

    function console:Warn(text)
        push("WARN", text, Color3.fromRGB(230, 179, 51)) -- Klasik sönük sarı
    end

    function console:Error(text)
        push("ERROR", text, Color3.fromRGB(212, 69, 69)) -- Klasik sönük kırmızı
    end

    function console:Clear()
        for _, v in ipairs(lines) do
            if v then v:Destroy() end
        end
        table.clear(lines)
    end

    return console
end



--======================================================
-- IMAGE (ImGui::Image)
--======================================================
function ImUI:AddImage(config)
    config = config or {}
    local imageId = config.Image or ""
    local height = config.Height or 100

    local Img = Create("ImageLabel", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.FrameBg,
        Image = imageId,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Img, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Img, Color = Theme.Border, Thickness = 1 })

    return Img
end

--======================================================
-- BULLET TEXT (ImGui::BulletText)
--======================================================
function ImUI:AddBulletText(text)
    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })
    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(0, 14, 1, 0),
        BackgroundTransparency = 1,
        Text = "•",
        TextColor3 = Theme.Accent,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return Holder
end

--======================================================
-- TEXT COLORED / DISABLED / WRAPPED (ImGui::TextColored vs.)
--======================================================
function ImUI:AddTextColored(text, color)
    local Lbl = Create("TextLabel", {
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, Theme.RowHeight),
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = color or Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = self:_next(),
    })
    return Lbl
end

function ImUI:AddTextDisabled(text)
    return self:AddTextColored(text, Theme.TextDim)
end

function ImUI:AddTextWrapped(text)
    local Lbl = Create("TextLabel", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        LayoutOrder = self:_next(),
    })
    return Lbl
end

--======================================================
-- SELECTABLE (ImGui::Selectable)
--======================================================
function ImUI:AddSelectable(config)
    config = config or {}
    local text = config.Text or "Selectable"
    local selected = config.Selected or false
    local callback = config.Callback or function() end

    local Holder = Create("TextButton", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = selected and Theme.Header or Theme.WindowBg,
        BackgroundTransparency = selected and 0 or 1,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })

    Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Holder.MouseEnter:Connect(function()
        if not selected then Tween(Holder, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.FrameBgHover }, 0.08) end
    end)
    Holder.MouseLeave:Connect(function()
        if not selected then Tween(Holder, { BackgroundTransparency = 1 }, 0.1) end
    end)
    Holder.MouseButton1Click:Connect(function()
        selected = not selected
        Holder.BackgroundColor3 = selected and Theme.Header or Theme.WindowBg
        Holder.BackgroundTransparency = selected and 0 or 1
        callback(selected)
    end)

    return {
        Set = function(v)
            selected = v
            Holder.BackgroundColor3 = selected and Theme.Header or Theme.WindowBg
            Holder.BackgroundTransparency = selected and 0 or 1
        end,
        Get = function() return selected end,
    }
end

--======================================================
-- LIST BOX (ImGui::ListBox)
--======================================================
function ImUI:AddListBox(config)
    config = config or {}
    local text = config.Text
    local options = config.Options or {}
    local default = config.Default or options[1]
    local height = config.Height or (Theme.RowHeight * math.min(#options, 5))
    local callback = config.Callback or function() end
    local selected = default

    if text then self:AddSeparatorText(text) end

    local Holder = Create("ScrollingFrame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_next(),
    })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })
    Create("UIListLayout", { Parent = Holder, SortOrder = Enum.SortOrder.LayoutOrder })

    local rows = {}
    local function paint()
        for k, r in pairs(rows) do
            r.BackgroundTransparency = (k == selected) and 0 or 1
            r.BackgroundColor3 = (k == selected) and Theme.Header or Theme.WindowBg
        end
    end

    for i, opt in ipairs(options) do
        local Row = Create("TextButton", {
            Parent = Holder,
            Size = UDim2.new(1, 0, 0, Theme.RowHeight),
            BackgroundColor3 = (opt == selected) and Theme.Header or Theme.WindowBg,
            BackgroundTransparency = (opt == selected) and 0 or 1,
            Text = "  " .. tostring(opt),
            TextColor3 = Theme.Text,
            Font = Theme.Font,
            TextSize = Theme.FontSize - 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = i,
        })
        rows[opt] = Row
        Row.MouseButton1Click:Connect(function()
            selected = opt
            paint()
            callback(selected)
        end)
    end

    return {
        Set = function(v) selected = v; paint() end,
        Get = function() return selected end,
    }
end

--======================================================
-- MULTI COMBO (birden çok seçim yapılabilen Combo varyasyonu)
--======================================================
function ImUI:AddMultiCombo(config)
    config = config or {}
    local text = config.Text or "MultiCombo"
    local options = config.Options or {}
    local defaults = config.Default or {}
    local callback = config.Callback or function() end
    local open = false

    local state = {}
    for _, v in ipairs(defaults) do state[v] = true end

    local function summary()
        local picked = {}
        for _, opt in ipairs(options) do
            if state[opt] then table.insert(picked, tostring(opt)) end
        end
        if #picked == 0 then return "Yok" end
        return table.concat(picked, ", ")
    end

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = self:_next(),
        ZIndex = 3,
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
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
        Text = text .. ": " .. summary(),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
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
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = i,
        })
        local Check = Create("TextLabel", {
            Parent = OptBtn,
            Size = UDim2.new(0, 18, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            BackgroundTransparency = 1,
            Text = state[opt] and "✓" or "",
            TextColor3 = Theme.Accent,
            Font = Theme.Font,
            TextSize = Theme.FontSize,
        })
        Create("TextLabel", {
            Parent = OptBtn,
            Size = UDim2.new(1, -26, 1, 0),
            Position = UDim2.new(0, 24, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(opt),
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = Theme.FontSize - 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        OptBtn.MouseEnter:Connect(function() OptBtn.BackgroundColor3 = Theme.Header end)
        OptBtn.MouseLeave:Connect(function() OptBtn.BackgroundColor3 = Theme.WindowBg end)
        OptBtn.MouseButton1Click:Connect(function()
            state[opt] = not state[opt]
            Check.Text = state[opt] and "✓" or ""
            DisplayLbl.Text = text .. ": " .. summary()
            local picked = {}
            for _, o in ipairs(options) do if state[o] then table.insert(picked, o) end end
            callback(picked)
        end)
    end

    Header.MouseButton1Click:Connect(function()
        open = not open
        local target = open and (Theme.RowHeight + #options * Theme.RowHeight) or Theme.RowHeight
        Tween(Holder, { Size = UDim2.new(1, -4, 0, target) }, 0.12)
    end)

    return {
        Get = function()
            local picked = {}
            for _, o in ipairs(options) do if state[o] then table.insert(picked, o) end end
            return picked
        end,
    }
end

--======================================================
-- MULTILINE INPUT TEXT (ImGui::InputTextMultiline)
--======================================================
function ImUI:AddInputTextMultiline(config)
    config = config or {}
    local text = config.Text
    local placeholder = config.Placeholder or ""
    local default = config.Default or ""
    local height = config.Height or 80
    local callback = config.Callback or function() end

    if text then self:AddSeparatorText(text) end

    local Box = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Box, Color = Theme.Border, Thickness = 1 })

    local TextBox = Create("TextBox", {
        Parent = Box,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    TextBox.FocusLost:Connect(function(enterPressed)
        callback(TextBox.Text, enterPressed)
    end)

    return { Set = function(v) TextBox.Text = v end, Get = function() return TextBox.Text end }
end

--======================================================
-- DRAG FLOAT / DRAG INT (ImGui::DragFloat / DragInt)
-- Yatay sürükleyerek değer değiştirme. Decimals = 0 verilirse DragInt gibi davranır.
--======================================================
function ImUI:AddDragFloat(config)
    config = config or {}
    local text = config.Text or "Drag"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local speed = config.Speed or 1
    local decimals = config.Decimals or 0
    local callback = config.Callback or function() end
    local value = default

    local function fmt(v)
        if decimals <= 0 then return tostring(math.floor(v + 0.5)) end
        return string.format("%." .. decimals .. "f", v)
    end

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
    local Stroke = Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local Label = Create("TextLabel", {
        Parent = Holder,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text = text .. ": " .. fmt(value),
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize - 1,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local dragging = false
    local lastX

    Holder.InputBegan:Connect(function(input)
        if ActiveDrag ~= nil then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveDrag = Holder
            dragging = true
            lastX = input.Position.X
            Tween(Stroke, { Color = Theme.Accent }, 0.08)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or ActiveDrag ~= Holder then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local dx = input.Position.X - lastX
            lastX = input.Position.X
            local step = speed * (decimals > 0 and 0.05 or 1)
            value = math.clamp(value + dx * step, min, max)
            Label.Text = text .. ": " .. fmt(value)
            callback(value)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if ActiveDrag ~= Holder then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            ActiveDrag = nil
            Tween(Stroke, { Color = Theme.Border }, 0.12)
        end
    end)

    return {
        Set = function(v) value = math.clamp(v, min, max); Label.Text = text .. ": " .. fmt(value) end,
        Get = function() return value end,
    }
end

--======================================================
-- ROW / SAME LINE (ImGui::SameLine) - küçük widgetları yan yana dizmek için
--======================================================
function ImUI:AddRow(height)
    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height or Theme.RowHeight),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
    })
    Create("UIListLayout", {
        Parent = Holder,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    -- Not: Row içine en iyi AddButton / AddLabel gibi kendi genişliğini
    -- ayarlayan widgetlar eklenir (tam-genişlik widgetlar Row içinde ImGui'deki
    -- gibi yan yana değil üst üste sıkışabilir).
    return setmetatable({ Content = Holder, _order = 0, ScreenGui = self.ScreenGui }, ImUI)
end

--======================================================
-- PLOT LINES (ImGui::PlotLines)
--======================================================
function ImUI:AddPlotLines(config)
    config = config or {}
    local text = config.Text
    local values = config.Values or {}
    local height = config.Height or 50
    local min = config.Min
    local max = config.Max

    if text then self:AddSeparatorText(text) end

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local segments = {}

    local function redraw()
        for _, s in ipairs(segments) do s:Destroy() end
        table.clear(segments)
        if #values < 2 then return end

        local lo, hi = min, max
        if not lo or not hi then
            lo, hi = values[1], values[1]
            for _, v in ipairs(values) do
                lo = math.min(lo, v)
                hi = math.max(hi, v)
            end
            if lo == hi then hi = lo + 1 end
        end

        local w = Holder.AbsoluteSize.X > 0 and Holder.AbsoluteSize.X or 200
        local h = Holder.AbsoluteSize.Y > 0 and Holder.AbsoluteSize.Y or height

        local function pointPos(i)
            local x = (i - 1) / (#values - 1) * w
            local rel = (values[i] - lo) / (hi - lo)
            local y = h - (rel * h)
            return Vector2.new(x, y)
        end

        for i = 1, #values - 1 do
            local p1, p2 = pointPos(i), pointPos(i + 1)
            local delta = p2 - p1
            local dist = delta.Magnitude
            local angle = math.deg(math.atan2(delta.Y, delta.X))
            local Seg = Create("Frame", {
                Parent = Holder,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, p1.X, 0, p1.Y),
                Size = UDim2.new(0, dist, 0, 2),
                Rotation = angle,
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
            })
            table.insert(segments, Seg)
        end
    end

    redraw()
    Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(redraw)

    return { SetValues = function(v) values = v; redraw() end }
end

--======================================================
-- PLOT HISTOGRAM (ImGui::PlotHistogram)
--======================================================
function ImUI:AddPlotHistogram(config)
    config = config or {}
    local text = config.Text
    local values = config.Values or {}
    local height = config.Height or 50
    local min = config.Min
    local max = config.Max

    if text then self:AddSeparatorText(text) end

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })

    local BarHolder = Create("Frame", {
        Parent = Holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    })
    Create("UIListLayout", {
        Parent = BarHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local bars = {}

    local function redraw()
        for _, b in ipairs(bars) do b:Destroy() end
        table.clear(bars)
        if #values == 0 then return end

        local lo, hi = min, max
        if not lo or not hi then
            lo, hi = 0, values[1]
            for _, v in ipairs(values) do hi = math.max(hi, v) end
            if hi == 0 then hi = 1 end
        end

        local w = Holder.AbsoluteSize.X > 0 and Holder.AbsoluteSize.X or 200
        local barW = math.max(2, math.floor(w / #values) - 1)
        for i, v in ipairs(values) do
            local rel = math.clamp((v - lo) / (hi - lo), 0, 1)
            local Bar = Create("Frame", {
                Parent = BarHolder,
                Size = UDim2.new(0, barW, rel, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                LayoutOrder = i,
            })
            table.insert(bars, Bar)
        end
    end

    redraw()
    Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(redraw)

    return { SetValues = function(v) values = v; redraw() end }
end

--======================================================
-- MENU BAR (ImGui::BeginMenuBar / BeginMenu / MenuItem)
--======================================================
function ImUI:AddMenuBar(menus)
    menus = menus or {}
    local ScreenGuiRef = self.ScreenGui or self.Content:FindFirstAncestorOfClass("ScreenGui")

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, Theme.RowHeight),
        BackgroundColor3 = Theme.TitleBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
        ZIndex = 4,
    })
    Create("UIListLayout", {
        Parent = Holder,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local openDropdown = nil
    local function closeDropdown()
        if openDropdown then openDropdown:Destroy(); openDropdown = nil end
    end

    for _, menu in ipairs(menus) do
        local name = menu.Name or "Menu"
        local items = menu.Items or {}

        local MenuBtn = Create("TextButton", {
            Parent = Holder,
            Size = UDim2.new(0, math.max(50, #name * 8 + 16), 1, 0),
            BackgroundColor3 = Theme.TitleBg,
            Text = name,
            TextColor3 = Theme.Text,
            Font = Theme.Font,
            TextSize = Theme.FontSize - 1,
            BorderSizePixel = 0,
            ZIndex = 4,
        })

        MenuBtn.MouseButton1Click:Connect(function()
            if openDropdown then
                closeDropdown()
                return
            end
            local Dropdown = Create("Frame", {
                Parent = ScreenGuiRef,
                Position = UDim2.new(0, MenuBtn.AbsolutePosition.X, 0, MenuBtn.AbsolutePosition.Y + MenuBtn.AbsoluteSize.Y),
                Size = UDim2.new(0, 130, 0, #items * Theme.RowHeight),
                BackgroundColor3 = Theme.WindowBg,
                BorderSizePixel = 0,
                ZIndex = 50,
            })
            Create("UIStroke", { Parent = Dropdown, Color = Theme.Border, Thickness = 1 })
            Create("UIListLayout", { Parent = Dropdown, SortOrder = Enum.SortOrder.LayoutOrder })

            for i, item in ipairs(items) do
                local ItemBtn = Create("TextButton", {
                    Parent = Dropdown,
                    Size = UDim2.new(1, 0, 0, Theme.RowHeight),
                    BackgroundColor3 = Theme.WindowBg,
                    Text = "  " .. (item.Text or "Item"),
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = Theme.FontSize - 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 50,
                    LayoutOrder = i,
                })
                ItemBtn.MouseEnter:Connect(function() ItemBtn.BackgroundColor3 = Theme.Header end)
                ItemBtn.MouseLeave:Connect(function() ItemBtn.BackgroundColor3 = Theme.WindowBg end)
                ItemBtn.MouseButton1Click:Connect(function()
                    if item.Callback then item.Callback() end
                    closeDropdown()
                end)
            end

            openDropdown = Dropdown
        end)
    end

    return Holder
end

--======================================================
-- CHILD WINDOW (ImGui::BeginChild) - içiçe scroll edilebilir alan
--======================================================
function ImUI:AddChildWindow(config)
    config = config or {}
    local height = config.Height or 100

    local Holder = Create("ScrollingFrame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_next(),
    })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })
    Create("UIListLayout", { Parent = Holder, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })
    Create("UIPadding", { Parent = Holder, PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })

    return setmetatable({ Content = Holder, _order = 0, ScreenGui = self.ScreenGui }, ImUI)
end

--======================================================
-- TABLE (ImGui::BeginTable - basit satır/sütun tablosu)
--======================================================
function ImUI:AddTable(config)
    config = config or {}
    local columns = config.Columns or {}
    local rows = config.Rows or {}
    local colCount = math.max(1, #columns)

    local Holder = Create("Frame", {
        Parent = self.Content,
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.FrameBg,
        BorderSizePixel = 0,
        LayoutOrder = self:_next(),
    })
    Create("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 0) })
    Create("UIStroke", { Parent = Holder, Color = Theme.Border, Thickness = 1 })
    Create("UIListLayout", { Parent = Holder, SortOrder = Enum.SortOrder.LayoutOrder })

    local function makeRow(cells, header)
        local Row = Create("Frame", {
            Parent = Holder,
            Size = UDim2.new(1, 0, 0, Theme.RowHeight),
            BackgroundColor3 = header and Theme.Header or Theme.FrameBg,
            BorderSizePixel = 0,
        })
        Create("UIListLayout", { Parent = Row, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder })
        for i = 1, colCount do
            local cellText = cells[i] ~= nil and tostring(cells[i]) or ""
            local Cell = Create("TextLabel", {
                Parent = Row,
                Size = UDim2.new(1 / colCount, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = cellText,
                TextColor3 = header and Theme.Text or Theme.TextDim,
                Font = Theme.Font,
                TextSize = Theme.FontSize - 1,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Create("UIPadding", { Parent = Cell, PaddingLeft = UDim.new(0, 6) })
        end
        return Row
    end

    if #columns > 0 then makeRow(columns, true) end
    for _, r in ipairs(rows) do makeRow(r, false) end

    return Holder
end

--======================================================
-- POPUP / MODAL (ImGui::OpenPopup / BeginPopupModal)
--======================================================
function ImUI:AddPopup(config)
    config = config or {}
    local title = config.Title or "Popup"
    local width = config.Width or 220
    local height = config.Height or 140

    local ScreenGuiRef = self.ScreenGui or self.Content:FindFirstAncestorOfClass("ScreenGui")

    local Overlay = Create("Frame", {
        Parent = ScreenGuiRef,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 90,
    })

    local Box = Create("Frame", {
        Parent = Overlay,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, width, 0, height),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        ZIndex = 91,
    })
    Create("UIStroke", { Parent = Box, Color = Theme.Accent, Thickness = 1 })

    local TitleBar = Create("Frame", {
        Parent = Box,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = Theme.TitleBgActive,
        BorderSizePixel = 0,
        ZIndex = 91,
    })
    Create("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = Theme.FontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 91,
    })

    local Body = Create("ScrollingFrame", {
        Parent = Box,
        Size = UDim2.new(1, -8, 1, -26),
        Position = UDim2.new(0, 4, 0, 22),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 91,
    })
    Create("UIListLayout", { Parent = Body, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    local popupObj = setmetatable({ Content = Body, _order = 0, ScreenGui = ScreenGuiRef }, ImUI)

    local function close() Overlay.Visible = false end
    local function open() Overlay.Visible = true end

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -18, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        Text = "x",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Theme.Font,
        TextSize = 11,
        BorderSizePixel = 0,
        ZIndex = 91,
    })
    CloseBtn.MouseButton1Click:Connect(close)

    popupObj.Open = open
    popupObj.Close = close
    return popupObj
end

--======================================================
-- ÖRNEK KULLANIM
-- RunExample = true ise aşağıdaki demo GUI otomatik açılır.
-- (Kütüphaneyi loadstring ile çalıştırırken bu bloğu tetiklemek istersen true bırak.)
--======================================================
local RunExample = true
_G.Example = true
if RunExample and _G.Example == true then
    local Window = ImUI:CreateWindow({ Title = "ImStyleUI Demo" })

    Window:AddSeparatorText("Temel Widgetlar")
    Window:AddLabel("Merhaba, bu bir örnek GUI.")
    Window:AddButton({ Text = "Tıkla", Callback = function() print("Butona tıklandı!") end })
    Window:AddCheckbox({ Text = "Aktif", Default = true, Callback = function(v) print("Checkbox:", v) end })
    Window:AddToggle({ Text = "Bildirimler", Default = false, Callback = function(v) print("Toggle:", v) end })
    Window:AddSlider({ Text = "Hız", Min = 0, Max = 100, Default = 50, Callback = function(v) print("Slider:", v) end })
    Window:AddSpacing(4)
    Window:AddSeparator()

    Window:AddSeparatorText("Giriş Alanları")
    Window:AddInputText({ Text = "İsim", Placeholder = "Adını yaz...", Callback = function(v) print("Input:", v) end })
    Window:AddInputNumber({ Text = "Miktar", Default = 5, Step = 1, Callback = function(v) print("Number:", v) end })
    Window:AddCombo({ Text = "Mod", Options = { "Kolay", "Orta", "Zor" }, Default = "Kolay", Callback = function(v) print("Combo:", v) end })
    Window:AddRadioButtons({ Text = "Takım", Options = { "Kırmızı", "Mavi" }, Default = "Kırmızı", Callback = function(v) print("Radio:", v) end })
    Window:AddColorPicker({ Text = "Renk", Default = Color3.fromRGB(255, 60, 60), Callback = function(c) print("Color:", c) end })
    Window:AddProgressBar({ Text = "Yükleniyor", Default = 0.65 })
    Window:AddKeybind({ Text = "Kısayol", Default = Enum.KeyCode.F, Callback = function() print("Keybind tetiklendi!") end })

    local Node = Window:AddTreeNode({ Text = "Gelişmiş Ayarlar", DefaultOpen = false })
    Node:AddLabel("Gizli içerik burada.")
    Node:AddButton({ Text = "Gizli Buton", Callback = function() print("Gizli buton!") end })

    local Tabs = Window:AddTabBar({ "Genel", "İstatistik" })
    Tabs.Tab("Genel"):AddLabel("Genel sekme içeriği.")
    Tabs.Tab("İstatistik"):AddLabel("İstatistik sekme içeriği.")

    local HelpBtn = Window:AddButton({ Text = "Yardım", Callback = function() end })
    Window:AddTooltip(HelpBtn, "Bu bir tooltip örneğidir")
    local console = Window:AddConsole({ SeparateWindow = true, Title = "Debug Console", Height = 180})

    Window:AddSeparatorText("Gelişmiş Widgetlar (Tam IMGUI Seti)")
    Window:AddBulletText("Bu bir bullet text örneğidir.")
    Window:AddTextColored("Renkli metin örneği", Color3.fromRGB(120, 200, 120))
    Window:AddTextDisabled("Devre dışı görünen (soluk) metin")
    Window:AddTextWrapped("Bu uzun bir metindir ve pencere genişliğine göre otomatik olarak alt satıra kaydırılır (word-wrap).")

    Window:AddSelectable({ Text = "Seçilebilir öğe 1", Callback = function(v) print("Selectable1:", v) end })
    Window:AddSelectable({ Text = "Seçilebilir öğe 2", Selected = true, Callback = function(v) print("Selectable2:", v) end })

    Window:AddListBox({ Text = "Liste Kutusu", Options = { "Elma", "Armut", "Muz", "Karpuz", "Çilek" }, Default = "Armut", Callback = function(v) print("ListBox:", v) end })

    Window:AddMultiCombo({ Text = "Çoklu Seçim", Options = { "Kırmızı", "Yeşil", "Mavi" }, Default = { "Kırmızı" }, Callback = function(v) print("MultiCombo:", table.concat(v, ", ")) end })

    Window:AddInputTextMultiline({ Text = "Not", Placeholder = "Buraya notunu yaz...", Height = 60, Callback = function(v) print("Multiline:", v) end })

    Window:AddDragFloat({ Text = "Sürükle (Int)", Min = 0, Max = 200, Default = 20, Speed = 1, Callback = function(v) print("DragInt:", v) end })
    Window:AddDragFloat({ Text = "Sürükle (Float)", Min = 0, Max = 10, Default = 2.5, Speed = 1, Decimals = 2, Callback = function(v) print("DragFloat:", v) end })

    local Row = Window:AddRow()
    Row:AddButton({ Text = "Sol", Callback = function() print("Sol butona tıklandı") end })
    Row:AddButton({ Text = "Orta", Callback = function() print("Orta butona tıklandı") end })
    Row:AddButton({ Text = "Sağ", Callback = function() print("Sağ butona tıklandı") end })

    Window:AddPlotLines({ Text = "Çizgi Grafik", Values = { 5, 12, 8, 20, 14, 22, 9, 17 }, Height = 50 })
    Window:AddPlotHistogram({ Text = "Histogram", Values = { 3, 7, 2, 9, 5, 11, 4 }, Height = 50 })

    local Child = Window:AddChildWindow({ Height = 70 })
    Child:AddLabel("Bu içiçe (nested) scroll edilebilir bir alt penceredir.")
    Child:AddButton({ Text = "Alt Buton", Callback = function() print("Alt pencere butonu!") end })

    Window:AddTable({
        Columns = { "İsim", "Seviye", "Puan" },
        Rows = {
            { "Emir", 12, 980 },
            { "Ayşe", 9, 760 },
            { "Kaan", 15, 1240 },
        },
    })

    local Popup = Window:AddPopup({ Title = "Onay", Width = 220, Height = 120 })
    Popup:AddLabel("Bu işlemi onaylıyor musun?")
    Popup:AddButton({ Text = "Kapat", Callback = function() Popup.Close() end })
    Window:AddButton({ Text = "Popup Aç", Callback = function() Popup.Open() end })

    Window:AddMenuBar({
        {
            Name = "Dosya",
            Items = {
                { Text = "Yeni", Callback = function() print("Yeni") end },
                { Text = "Kaydet", Callback = function() print("Kaydet") end },
            },
        },
        {
            Name = "Yardım",
            Items = {
                { Text = "Hakkında", Callback = function() print("ImStyleUI Demo v2") end },
            },
        },
    })
else
    print("loaded Gui")
end

return ImUI
