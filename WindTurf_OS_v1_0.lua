--[[
    WINDTURF OS v1.0
    Client-side Roblox utility desktop
    Designed for touch-friendly Android screens.

    NOTE:
    This is a client-side UI/utility project. It does not modify
    Robux, inventories, or other players.

    Features:
    - Small mobile desktop
    - Square app icons with emoji
    - Red X close buttons
    - Browser/link launcher
    - Roblox audio player (asset ID)
    - Local soundboard
    - Notes
    - Calculator
    - System monitor
    - Customization
    - Settings
    - Notifications
    - Reopen button
    - Rerun protection

    IMPORTANT:
    A YouTube URL cannot be directly streamed through Roblox Sound.
    The Browser app therefore opens/copies YouTube links instead.
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then return end

-- Rerun protection
local ENV = (getgenv and getgenv()) or _G
if ENV.WindTurfOS_v1_0 then
    pcall(function()
        if ENV.WindTurfOS_v1_0.Destroy then
            ENV.WindTurfOS_v1_0.Destroy()
        end
    end)
end

local State = {
    destroyed = false,
    minimized = false,
    accent = Color3.fromRGB(190, 35, 45),
    notes = {},
    bookmarks = {},
    media = {},
    windows = {},
    z = 20,
}

-- Helpers
local function safeDestroy(obj)
    if obj then pcall(function() obj:Destroy() end) end
end

local function new(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(parent, radius)
    return new("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Color = color or Color3.fromRGB(70,70,80),
        Thickness = thickness or 1
    }, parent)
end

local function text(parent, value, size, position, font, color)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = value or "",
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextColor3 = color or Color3.fromRGB(235,235,240),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Position = position or UDim2.new(),
        Size = UDim2.new(1,0,0,24),
    }, parent)
end

local function button(parent, label, position, size, callback)
    local b = new("TextButton", {
        BackgroundColor3 = Color3.fromRGB(40,40,48),
        BorderSizePixel = 0,
        Text = label,
        TextColor3 = Color3.fromRGB(240,240,245),
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true,
        Position = position,
        Size = size,
    }, parent)
    corner(b, 7)
    if callback then
        b.Activated:Connect(function()
            local ok, err = pcall(callback)
            if not ok then warn("[WindTurf OS] Button error:", err) end
        end)
    end
    return b
end

local function notify(message)
    if State.destroyed or not MainGui then return end
    local n = new("TextLabel", {
        BackgroundColor3 = Color3.fromRGB(28,28,35),
        BorderSizePixel = 0,
        Text = "  " .. tostring(message),
        TextColor3 = Color3.fromRGB(240,240,245),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(1, 20, 1, -70),
        Size = UDim2.new(0, 230, 0, 42),
        ZIndex = 1000,
    }, MainGui)
    corner(n, 8)
    stroke(n, State.accent, 1)
    TweenService:Create(n, TweenInfo.new(.22), {
        Position = UDim2.new(1, -245, 1, -70)
    }):Play()
    task.delay(2.5, function()
        if n and n.Parent then
            local t = TweenService:Create(n, TweenInfo.new(.2), {
                Position = UDim2.new(1, 20, 1, -70)
            })
            t:Play()
            task.wait(.22)
            safeDestroy(n)
        end
    end)
end

-- GUI root
local parentGui
pcall(function()
    if gethui then parentGui = gethui() end
end)
if not parentGui then
    parentGui = player:WaitForChild("PlayerGui")
end

local MainGui = new("ScreenGui", {
    Name = "WindTurfOS_v1_0",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, parentGui)

-- Background
local Desktop = new("Frame", {
    Name = "Desktop",
    BackgroundColor3 = Color3.fromRGB(10,10,18),
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.5),
    Size = UDim2.new(0, 690, 0, 390),
}, MainGui)
corner(Desktop, 16)
stroke(Desktop, Color3.fromRGB(65,45,85), 1)

-- Responsive scaling for 1604x720 and smaller screens
local Scale = new("UIScale", {Scale = 1}, Desktop)

local function updateScale()
    if not Desktop.Parent then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local sx = (vp.X - 24) / 690
    local sy = (vp.Y - 70) / 390
    Scale.Scale = math.clamp(math.min(sx, sy), 0.72, 1)
end
updateScale()

local cameraConn
pcall(function()
    cameraConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end)

-- Galaxy-ish lightweight background
local bg = new("Frame", {
    BackgroundColor3 = Color3.fromRGB(15,12,27),
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1,1),
    ZIndex = 0,
}, Desktop)
corner(bg, 16)

for i = 1, 24 do
    local x = math.random(2,98)/100
    local y = math.random(4,94)/100
    local s = math.random(1,3)
    local dot = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(160,145,190),
        BackgroundTransparency = math.random(15,55)/100,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(x,y),
        Size = UDim2.new(0,s,0,s),
        ZIndex = 1,
    }, bg)
    corner(dot, 5)
end

-- Top bar
local Top = new("Frame", {
    BackgroundColor3 = Color3.fromRGB(23,21,32),
    BorderSizePixel = 0,
    Position = UDim2.new(0,0,0,0),
    Size = UDim2.new(1,0,0,42),
    ZIndex = 10,
}, Desktop)
corner(Top, 16)

local Title = text(Top, "📱  WindTurf OS", 17, UDim2.new(0,14,0,4), Enum.Font.GothamBold)
Title.Size = UDim2.new(0,250,0,34)

local Clock = text(Top, "--:--", 13, UDim2.new(1,-100,0,4), Enum.Font.GothamMedium)
Clock.TextXAlignment = Enum.TextXAlignment.Right
Clock.Size = UDim2.new(0,78,0,34)

local closeDesktop = button(Top, "X", UDim2.new(1,-42,0,7), UDim2.new(0,32,0,28), function()
    Desktop.Visible = false
    State.minimized = true
    Reopen.Visible = true
end)
closeDesktop.BackgroundColor3 = Color3.fromRGB(170,35,45)
closeDesktop.TextSize = 14

-- Dragging (mouse + touch)
local dragStart, startPos, dragging = nil, nil, false
local function beginDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = Desktop.Position
end
local function updateDrag(input)
    if not dragging or not dragStart or not startPos then return end
    local delta = input.Position - dragStart
    Desktop.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end
local function endDrag()
    dragging = false
end
Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)
Top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        endDrag()
    end
end)

-- Desktop status
local Status = text(Desktop, "Client-side utility desktop", 12,
    UDim2.new(0,18,0,48), Enum.Font.Gotham)
Status.TextColor3 = Color3.fromRGB(180,180,195)
Status.Size = UDim2.new(0,400,0,24)
Status.ZIndex = 5

local Monitor = text(Desktop, "FPS: --   Ping: --   Players: --", 11,
    UDim2.new(1,-300,0,48), Enum.Font.GothamMedium)
Monitor.TextXAlignment = Enum.TextXAlignment.Right
Monitor.Size = UDim2.new(0,282,0,24)
Monitor.ZIndex = 5

-- App area
local AppArea = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0,18,0,78),
    Size = UDim2.new(1,-36,1,-140),
    ZIndex = 5,
}, Desktop)

local Grid = new("UIGridLayout", {
    CellSize = UDim2.new(0,92,0,92),
    CellPadding = UDim2.new(0,14,0,14),
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, AppArea)

local function appIcon(emoji, name, order, callback)
    local holder = new("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, AppArea)

    local b = new("TextButton", {
        BackgroundColor3 = Color3.fromRGB(31,29,42),
        BorderSizePixel = 0,
        Text = emoji,
        TextSize = 30,
        Font = Enum.Font.Gotham,
        AutoButtonColor = true,
        Size = UDim2.new(0,68,0,68),
        Position = UDim2.new(.5,-34,0,0),
    }, holder)
    corner(b, 10)
    stroke(b, Color3.fromRGB(70,64,86), 1)
    b.Activated:Connect(callback)

    local lab = text(holder, name, 11, UDim2.new(0,0,0,70), Enum.Font.GothamMedium)
    lab.TextXAlignment = Enum.TextXAlignment.Center
    lab.Size = UDim2.new(1,0,0,18)
    return holder
end

-- Window creation
local function createWindow(titleText, width, height)
    local w = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(24,23,31),
        BorderSizePixel = 0,
        Position = UDim2.new(.5,-width/2,.5,-height/2),
        Size = UDim2.new(0,width,0,height),
        Visible = true,
        ZIndex = 100,
    }, Desktop)
    corner(w, 10)
    stroke(w, Color3.fromRGB(75,65,90), 1)

    local bar = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(31,29,40),
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,38),
        ZIndex = 101,
    }, w)
    corner(bar, 10)

    local t = text(bar, titleText, 14, UDim2.new(0,12,0,3), Enum.Font.GothamBold)
    t.Size = UDim2.new(1,-55,0,32)
    t.ZIndex = 102

    local x = button(bar, "X", UDim2.new(1,-36,0,5), UDim2.new(0,28,0,28), function()
        safeDestroy(w)
    end)
    x.BackgroundColor3 = Color3.fromRGB(170,35,45)
    x.ZIndex = 103

    local content = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,46),
        Size = UDim2.new(1,-20,1,-56),
        ZIndex = 102,
    }, w)

    -- Bring to front
    w.InputBegan:Connect(function()
        State.z += 1
        w.ZIndex = State.z
    end)

    -- Window dragging
    local ds, sp, dg
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dg = true
            ds = input.Position
            sp = w.Position
        end
    end)
    bar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) and dg then
            local d = input.Position - ds
            w.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)

    table.insert(State.windows, w)
    return w, content
end

-- Browser
local function openBrowser()
    local w, c = createWindow("🌐 Browser", 430, 260)
    local box = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(35,34,43),
        BorderSizePixel = 0,
        PlaceholderText = "Paste a URL here...",
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Color3.fromRGB(240,240,245),
        PlaceholderColor3 = Color3.fromRGB(145,145,155),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,38),
    }, c)
    corner(box, 7)

    button(c, "Open", UDim2.new(0,0,0,48), UDim2.new(.48,0,0,36), function()
        local url = box.Text
        if url == "" then notify("Enter a URL first.") return end
        if not string.match(url, "^https?://") then
            url = "https://" .. url
        end
        -- Clipboard is executor-dependent; external URL opening is also executor-dependent.
        -- We safely expose the URL for supported environments instead of pretending Roblox has a webview.
        local copied = false
        pcall(function()
            if setclipboard then setclipboard(url); copied = true end
        end)
        if copied then
            notify("URL copied. Open it in your browser.")
        else
            notify("URL ready: " .. url)
        end
    end)

    button(c, "Copy", UDim2.new(.52,0,0,48), UDim2.new(.48,0,0,36), function()
        if box.Text == "" then notify("Nothing to copy.") return end
        local ok = pcall(function()
            if setclipboard then setclipboard(box.Text) else error("clipboard unavailable") end
        end)
        notify(ok and "URL copied." or "Clipboard unavailable.")
    end)

    text(c, "YouTube links are supported as saved/opened links.\nRoblox cannot directly stream YouTube into Sound.", 11,
        UDim2.new(0,0,0,100), Enum.Font.Gotham, Color3.fromRGB(175,175,185)).Size = UDim2.new(1,0,0,60)
end

-- Media
local CurrentSound
local function openMedia()
    local w, c = createWindow("🎵 Media", 430, 300)

    local idBox = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(35,34,43),
        BorderSizePixel = 0,
        PlaceholderText = "Roblox audio ID (numbers only)",
        ClearTextOnFocus = false,
        TextColor3 = Color3.fromRGB(240,240,245),
        PlaceholderColor3 = Color3.fromRGB(145,145,155),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,38),
    }, c)
    corner(idBox, 7)

    local function getSound()
        if CurrentSound and CurrentSound.Parent then return CurrentSound end
        CurrentSound = new("Sound", {
            Name = "WindTurfOS_Media",
            Volume = .5,
            Looped = false,
        }, SoundService)
        return CurrentSound
    end

    button(c, "Play", UDim2.new(0,0,0,50), UDim2.new(.31,0,0,36), function()
        local id = idBox.Text:gsub("%D","")
        if id == "" then notify("Enter a Roblox audio ID.") return end
        local s = getSound()
        s.SoundId = "rbxassetid://" .. id
        local ok, err = pcall(function() s:Play() end)
        notify(ok and "Playback requested." or ("Playback error: "..tostring(err)))
    end)

    button(c, "Pause", UDim2.new(.345,0,0,50), UDim2.new(.31,0,0,36), function()
        if CurrentSound then CurrentSound:Pause() end
    end)

    button(c, "Stop", UDim2.new(.69,0,0,50), UDim2.new(.31,0,0,36), function()
        if CurrentSound then CurrentSound:Stop() end
    end)

    local vol = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(35,34,43),
        BorderSizePixel = 0,
        PlaceholderText = "Volume 0-10 (default 5)",
        Text = "5",
        ClearTextOnFocus = false,
        TextColor3 = Color3.fromRGB(240,240,245),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0,0,0,100),
        Size = UDim2.new(1,0,0,36),
    }, c)
    corner(vol, 7)

    button(c, "Apply Volume", UDim2.new(0,0,0,146), UDim2.new(1,0,0,34), function()
        local n = tonumber(vol.Text)
        if not n then notify("Invalid volume.") return end
        if CurrentSound then CurrentSound.Volume = math.clamp(n/10,0,1) end
        notify("Volume updated.")
    end)

    text(c, "YouTube: save/open the link externally.\nRoblox audio: use a Roblox audio asset ID that the experience can load.", 11,
        UDim2.new(0,0,0,192), Enum.Font.Gotham, Color3.fromRGB(175,175,185)).Size = UDim2.new(1,0,0,60)
end

-- Soundboard
local function openSoundboard()
    local w, c = createWindow("🔊 Soundboard", 430, 300)

    local idBox = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(35,34,43),
        BorderSizePixel = 0,
        PlaceholderText = "Roblox audio ID",
        ClearTextOnFocus = false,
        TextColor3 = Color3.fromRGB(240,240,245),
        PlaceholderColor3 = Color3.fromRGB(145,145,155),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,36),
    }, c)
    corner(idBox, 7)

    local names = {"Airhorn","Laugh","Alarm","Custom"}
    for i,name in ipairs(names) do
        local col = (i-1)%2
        local row = math.floor((i-1)/2)
        button(c, name, UDim2.new(0,col*.52,0,48+row*48), UDim2.new(.48,0,0,38), function()
            local id = idBox.Text:gsub("%D","")
            if id == "" then
                notify("Enter an audio ID for the soundboard.")
                return
            end
            local s = new("Sound", {
                SoundId = "rbxassetid://"..id,
                Volume = .5,
            }, SoundService)
            local ok = pcall(function() s:Play() end)
            notify(ok and (name.." playback requested.") or "Playback failed.")
            task.delay(15, function() safeDestroy(s) end)
        end)
    end

    text(c, "Soundboard sounds are local unless the game itself provides a server-side sound system.", 11,
        UDim2.new(0,0,0,154), Enum.Font.Gotham, Color3.fromRGB(175,175,185)).Size = UDim2.new(1,0,0,60)
end

-- Notes
local function openNotes()
    local w, c = createWindow("📝 Notes", 430, 320)
    local titleBox = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(35,34,43),
        BorderSizePixel = 0,
        PlaceholderText = "Note title",
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Color3.fromRGB(240,240,245),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,34),
    }, c)
    corner(titleBox,7)

    local body = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(31,30,39),
        BorderSizePixel = 0,
        PlaceholderText = "Write your note...",
        Text = "",
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = Color3.fromRGB(235,235,240),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0,0,0,44),
        Size = UDim2.new(1,0,0,160),
    }, c)
    corner(body,7)

    button(c, "Save Note", UDim2.new(0,0,0,216), UDim2.new(.48,0,0,36), function()
        local name = titleBox.Text ~= "" and titleBox.Text or ("Note "..tostring(#State.notes+1))
        table.insert(State.notes, {title=name, body=body.Text})
        notify("Note saved for this session.")
    end)

    button(c, "Clear", UDim2.new(.52,0,0,216), UDim2.new(.48,0,0,36), function()
        titleBox.Text = ""
        body.Text = ""
    end)

    text(c, "Saved notes: "..tostring(#State.notes), 11,
        UDim2.new(0,0,0,258), Enum.Font.Gotham, Color3.fromRGB(175,175,185)).Size = UDim2.new(1,0,0,24)
end

-- Calculator
local function openCalculator()
    local w, c = createWindow("🧮 Calculator", 300, 330)
    local display = new("TextBox", {
        BackgroundColor3 = Color3.fromRGB(18,18,24),
        BorderSizePixel = 0,
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Color3.fromRGB(240,240,245),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,42),
    }, c)
    corner(display,7)

    local keys = {
        {"7","8","9","/"},
        {"4","5","6","*"},
        {"1","2","3","-"},
        {"0",".","=","+"},
    }

    for r,row in ipairs(keys) do
        for col,key in ipairs(row) do
            button(c, key,
                UDim2.new((col-1)*.25,2,0,52+(r-1)*50),
                UDim2.new(.25,-4,0,44),
                function()
                    if key == "=" then
                        local expr = display.Text
                        if not expr:match("^[%d%s%+%-%*/%.%(%)]+$") then
                            notify("Calculator rejected that expression.")
                            return
                        end
                        local fn = loadstring("return "..expr)
                        if not fn then notify("Invalid expression.") return end
                        local ok, result = pcall(fn)
                        display.Text = ok and tostring(result) or "Error"
                    else
                        display.Text = display.Text .. key
                    end
                end)
        end
    end

    button(c, "Clear", UDim2.new(0,0,0,254), UDim2.new(1,0,0,36), function()
        display.Text = ""
    end)
end

-- System
local function openSystem()
    local w, c = createWindow("📊 System Monitor", 360, 250)
    local info = text(c, "Loading...", 14, UDim2.new(0,0,0,0), Enum.Font.GothamMedium)
    info.Size = UDim2.new(1,0,0,170)
    info.TextYAlignment = Enum.TextYAlignment.Top

    local started = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not w.Parent then
            if conn then conn:Disconnect() end
            return
        end
        local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 1/240))
        local ping = "?"
        pcall(function()
            ping = tostring(math.floor(player:GetNetworkPing()*1000)).." ms"
        end)
        local elapsed = math.floor(os.clock()-started)
        info.Text = string.format(
            "FPS: %s\nPing: %s\nPlayers: %d\nSession: %02d:%02d:%02d",
            tostring(fps), ping, #Players:GetPlayers(),
            math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60
        )
    end)
end

-- Settings / customization
local function openSettings()
    local w, c = createWindow("⚙️ Settings", 400, 300)

    text(c, "Accent", 12, UDim2.new(0,0,0,0), Enum.Font.GothamBold).Size = UDim2.new(1,0,0,24)

    local colors = {
        {"Red",Color3.fromRGB(190,35,45)},
        {"Purple",Color3.fromRGB(125,75,190)},
        {"Blue",Color3.fromRGB(55,110,200)},
        {"Green",Color3.fromRGB(50,160,105)},
    }

    for i,item in ipairs(colors) do
        button(c, item[1], UDim2.new((i-1)*.25,2,0,30), UDim2.new(.25,-4,0,34), function()
            State.accent = item[2]
            stroke(Desktop, State.accent, 1)
            notify("Accent changed to "..item[1])
        end)
    end

    button(c, "Toggle galaxy dots", UDim2.new(0,0,0,80), UDim2.new(1,0,0,36), function()
        for _,child in ipairs(bg:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = not child.Visible
            end
        end
        notify("Background dots toggled.")
    end)

    button(c, "Reset desktop position", UDim2.new(0,0,0,126), UDim2.new(1,0,0,36), function()
        Desktop.Position = UDim2.fromScale(.5,.5)
        notify("Desktop position reset.")
    end)

    button(c, "Close WindTurf OS", UDim2.new(0,0,0,172), UDim2.new(1,0,0,36), function()
        Desktop.Visible = false
        State.minimized = true
        Reopen.Visible = true
        safeDestroy(w)
    end)

    text(c, "WindTurf OS v1.0\nClient-side utility interface", 11,
        UDim2.new(0,0,0,220), Enum.Font.Gotham, Color3.fromRGB(175,175,185)).Size = UDim2.new(1,0,0,50)
end

-- App icons
appIcon("🌐","Browser",1,openBrowser)
appIcon("🎵","Media",2,openMedia)
appIcon("🔊","Soundboard",3,openSoundboard)
appIcon("📝","Notes",4,openNotes)
appIcon("🧮","Calculator",5,openCalculator)
appIcon("📊","System",6,openSystem)
appIcon("⚙️","Settings",7,openSettings)

-- Reopen floating button
Reopen = new("TextButton", {
    Name = "WindTurfOS_Reopen",
    BackgroundColor3 = Color3.fromRGB(30,28,40),
    BorderSizePixel = 0,
    Text = "📱",
    TextSize = 28,
    Font = Enum.Font.Gotham,
    Size = UDim2.new(0,58,0,58),
    Position = UDim2.new(1,-75,1,-90),
    Visible = false,
    ZIndex = 2000,
}, MainGui)
corner(Reopen, 16)
stroke(Reopen, State.accent, 2)

Reopen.Activated:Connect(function()
    Desktop.Visible = true
    Reopen.Visible = false
    State.minimized = false
end)

-- Floating button dragging
do
    local ds, sp, dg
    Reopen.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dg = true
            ds = input.Position
            sp = Reopen.Position
        end
    end)
    Reopen.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) and dg then
            local d = input.Position - ds
            Reopen.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dg = false
        end
    end)
end

-- Clock / monitor updates
task.spawn(function()
    while not State.destroyed and MainGui.Parent do
        Clock.Text = os.date("%I:%M %p")
        local ping = "?"
        pcall(function()
            ping = tostring(math.floor(player:GetNetworkPing()*1000)).."ms"
        end)
        Monitor.Text = string.format(
            "Ping: %s   Players: %d",
            ping, #Players:GetPlayers()
        )
        task.wait(1)
    end
end)

-- Public cleanup
local API = {}
function API.Destroy()
    if State.destroyed then return end
    State.destroyed = true
    if cameraConn then pcall(function() cameraConn:Disconnect() end) end
    if CurrentSound then safeDestroy(CurrentSound) end
    safeDestroy(MainGui)
end

ENV.WindTurfOS_v1_0 = API

-- Initial notification
task.delay(.5, function()
    if not State.destroyed then
        notify("WindTurf OS v1.0 loaded.")
    end
end)
