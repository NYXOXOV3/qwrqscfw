-- =========================================================
-- VISUAL API (FINAL)
-- NYXHUB - Fish It
-- =========================================================

local VisualAPI = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- =========================================================
-- 1. DISABLE 3D RENDERING
-- =========================================================

VisualAPI.DisableRendering = { Enabled = false, Conn = nil }

function VisualAPI.ToggleDisable3D(state)
    if state and not VisualAPI.DisableRendering.Enabled then
        VisualAPI.DisableRendering.Enabled = true
        VisualAPI.DisableRendering.Conn = RunService.RenderStepped:Connect(function()
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
            end)
        end)
    elseif not state and VisualAPI.DisableRendering.Enabled then
        VisualAPI.DisableRendering.Enabled = false
        if VisualAPI.DisableRendering.Conn then
            VisualAPI.DisableRendering.Conn:Disconnect()
            VisualAPI.DisableRendering.Conn = nil
        end
        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if VisualAPI.DisableRendering.Enabled then
        task.wait(0.5)
        pcall(function()
            RunService:Set3dRenderingEnabled(false)
        end)
    end
end)

-- =========================================================
-- 2. FPS BOOSTER (RAW / BRUTAL)
-- =========================================================

VisualAPI.FPSBooster = {
    Enabled = false,
    Conn = nil
}

local function applyRawBoost(obj)
    if not VisualAPI.FPSBooster.Enabled then return end
    if obj:IsDescendantOf(LocalPlayer.Character) then return end

    pcall(function()
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
            obj:Destroy()

        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail")
            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj:Destroy()

        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()

        elseif obj:IsA("MeshPart") then
            obj.TextureID = ""
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false

        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""

        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
    end)
end

function VisualAPI.ToggleFPSBoost(state)
    if state and not VisualAPI.FPSBooster.Enabled then
        VisualAPI.FPSBooster.Enabled = true

        -- ===== LIGHTING BRUTAL =====
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 2.5
            Lighting.Ambient = Color3.fromRGB(200,200,200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ShadowSoftness = 0
            Lighting.ClockTime = 14

            for _,v in ipairs(Lighting:GetChildren()) do
                if v:IsA("BloomEffect") or v:IsA("BlurEffect")
                or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect")
                or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") then
                    v:Destroy()
                end
            end
        end)

        -- ===== RENDER SETTINGS =====
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        end)

        -- ===== CLEAN EXISTING =====
        for _,obj in ipairs(workspace:GetDescendants()) do
            applyRawBoost(obj)
        end

        -- ===== AUTO CLEAN NEW OBJECT =====
        if VisualAPI.FPSBooster.Conn then
            VisualAPI.FPSBooster.Conn:Disconnect()
        end

        VisualAPI.FPSBooster.Conn = workspace.DescendantAdded:Connect(function(obj)
            if not VisualAPI.FPSBooster.Enabled then return end
            task.wait(0.15)
            applyRawBoost(obj)
        end)

    elseif not state and VisualAPI.FPSBooster.Enabled then
        VisualAPI.FPSBooster.Enabled = false

        if VisualAPI.FPSBooster.Conn then
            VisualAPI.FPSBooster.Conn:Disconnect()
            VisualAPI.FPSBooster.Conn = nil
        end

        -- ⚠️ NO FULL RESTORE (REJOIN RECOMMENDED)
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(127,127,127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        end)

        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
    end
end

-- =========================================================
-- 3. PLAYER ESP
-- =========================================================

local espEnabled = false
local espConns = {}
local STUD_TO_M = 0.28

local function clearESP(plr)
    local d = espConns[plr]
    if d then
        if d.conn then d.conn:Disconnect() end
        if d.gui then d.gui:Destroy() end
        espConns[plr] = nil
    end
end

local function makeESP(plr)
    if plr == LocalPlayer or not plr.Character then return end
    clearESP(plr)

    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "NYXHUBESP"
    gui.Adornee = hrp
    gui.Size = UDim2.new(0,140,0,40)
    gui.StudsOffset = Vector3.new(0,2.6,0)
    gui.AlwaysOnTop = true
    gui.Parent = plr.Character

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255,230,230)

    local conn = RunService.RenderStepped:Connect(function()
        local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if my then
            local dist = (my.Position - hrp.Position).Magnitude * STUD_TO_M
            label.Text = string.format("%s\n%.1f m", plr.DisplayName or plr.Name, dist)
        end
    end)

    plr.CharacterAdded:Connect(function()
        task.wait(0.6)
        if espEnabled then makeESP(plr) end
    end)

    espConns[plr] = { gui = gui, conn = conn }
end

function VisualAPI.ToggleESP(state)
    espEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
        espConns._add = Players.PlayerAdded:Connect(makeESP)
        espConns._rem = Players.PlayerRemoving:Connect(clearESP)
    else
        for p in pairs(espConns) do
            if typeof(p) == "Instance" then clearESP(p) end
        end
        if espConns._add then espConns._add:Disconnect() end
        if espConns._rem then espConns._rem:Disconnect() end
        espConns = {}
    end
end

-- =========================================================
-- 5. NYX MINI PING PANEL (FPS + REAL PING)
-- =========================================================

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

VisualAPI.PingPanel = {
    Enabled = false,
    GUI = nil,
    Conn = nil,
}

-- =========================
-- THEME NYX MINI
-- =========================
local THEME = {
    BG     = Color3.fromRGB(10, 8, 18),
    STROKE = Color3.fromRGB(180, 120, 255),
    TITLE  = Color3.fromRGB(200, 170, 255),
    TEXT   = Color3.fromRGB(235, 235, 245),
    GOOD   = Color3.fromRGB(140, 255, 200), -- hijau
    MID    = Color3.fromRGB(255, 200, 140), -- kuning
    BAD    = Color3.fromRGB(255, 120, 140), -- merah
}

-- =========================
-- COLOR LOGIC
-- =========================
local function colorizeFPS(label, fps)
    if fps <= 50 then
        label.TextColor3 = THEME.GOOD
    elseif fps <= 100 then
        label.TextColor3 = THEME.MID
    else
        label.TextColor3 = THEME.BAD
    end
end

local function colorizePing(label, ping)
    if ping <= 80 then
        label.TextColor3 = THEME.GOOD
    elseif ping <= 150 then
        label.TextColor3 = THEME.MID
    else
        label.TextColor3 = THEME.BAD
    end
end

-- =========================
-- INTERNAL GUI BUILDER
-- =========================
local function createMiniPanel()
    local old = CoreGui:FindFirstChild("LynxNyxMini")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LynxNyxMini"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 190, 0, 64)
    panel.Position = UDim2.new(0.5, -95, 0, 60)
    panel.BackgroundColor3 = THEME.BG
    panel.BackgroundTransparency = 0.18
    panel.BorderSizePixel = 0
    panel.Parent = gui

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = THEME.STROKE
    stroke.Thickness = 1.4
    stroke.Transparency = 0.45

    -- FPS LABEL
    local fpsLabel = Instance.new("TextLabel", panel)
    fpsLabel.Position = UDim2.new(0, 12, 0, 8)
    fpsLabel.Size = UDim2.new(1, -60, 0, 22)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS  : --"
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 14
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.TextColor3 = THEME.TEXT

    -- PING LABEL
    local pingLabel = Instance.new("TextLabel", panel)
    pingLabel.Position = UDim2.new(0, 12, 0, 34)
    pingLabel.Size = UDim2.new(1, -60, 0, 22)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "PING : -- ms"
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 14
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.TextColor3 = THEME.TEXT

    -- LOGO
    local logo = Instance.new("ImageLabel", panel)
    logo.Size = UDim2.new(0, 26, 0, 26)
    logo.Position = UDim2.new(1, -38, 0.5, -13)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://137263312772667"
    logo.ImageTransparency = 0.1
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 6)

    -- DRAG
    do
        local dragging, dragStart, startPos
        panel.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = i.Position
                startPos = panel.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                panel.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    return {
        Gui = gui,
        FPS = fpsLabel,
        Ping = pingLabel,
    }
end

-- =========================
-- PING FETCH
-- =========================
local function getPing()
    local ping = 0
    pcall(function()
        local net = Stats:FindFirstChild("Network")
        if net then
            local s = net:FindFirstChild("ServerStatsItem")
            if s and s:FindFirstChild("Data Ping") then
                ping = tonumber(s["Data Ping"]:GetValueString():match("%d+")) or 0
            end
        end
    end)
    return ping
end

-- =========================
-- PUBLIC TOGGLE
-- =========================
function VisualAPI.TogglePingPanel(state)
    if state and not VisualAPI.PingPanel.Enabled then
        VisualAPI.PingPanel.Enabled = true
        VisualAPI.PingPanel.GUI = createMiniPanel()

        local frames, fpsTimer, statTimer = 0, 0, 0

        VisualAPI.PingPanel.Conn = RunService.Heartbeat:Connect(function(dt)
            frames += 1
            fpsTimer += dt
            statTimer += dt

            if fpsTimer >= 1 then
                local fps = frames
                frames = 0
                fpsTimer = 0

                VisualAPI.PingPanel.GUI.FPS.Text = "FPS  : " .. fps
                colorizeFPS(VisualAPI.PingPanel.GUI.FPS, fps)
            end

            if statTimer >= 0.5 then
                statTimer = 0
                local ping = getPing()
                VisualAPI.PingPanel.GUI.Ping.Text = "PING : " .. ping .. " ms"
                colorizePing(VisualAPI.PingPanel.GUI.Ping, ping)
            end
        end)

    elseif not state and VisualAPI.PingPanel.Enabled then
        VisualAPI.PingPanel.Enabled = false

        if VisualAPI.PingPanel.Conn then
            VisualAPI.PingPanel.Conn:Disconnect()
            VisualAPI.PingPanel.Conn = nil
        end

        if VisualAPI.PingPanel.GUI and VisualAPI.PingPanel.GUI.Gui then
            VisualAPI.PingPanel.GUI.Gui:Destroy()
        end

        VisualAPI.PingPanel.GUI = nil
    end
end

-- =========================
-- UTIL
-- =========================
local function getPing()
    local ping = 0
    pcall(function()
        local net = Stats:FindFirstChild("Network")
        if net then
            local s = net:FindFirstChild("ServerStatsItem")
            if s and s:FindFirstChild("Data Ping") then
                ping = tonumber(s["Data Ping"]:GetValueString():match("%d+")) or 0
            end
        end
    end)
    return ping
end

local function colorize(label, value, good, mid)
    if value <= good then
        label.TextColor3 = THEME.GOOD
    elseif value <= mid then
        label.TextColor3 = THEME.MID
    else
        label.TextColor3 = THEME.BAD
    end
end

-- =========================
-- PUBLIC TOGGLE
-- =========================
function VisualAPI.TogglePingPanel(state)
    if state and not VisualAPI.PingPanel.Enabled then
        VisualAPI.PingPanel.Enabled = true
        VisualAPI.PingPanel.GUI = createMiniPanel()

        local frames, fpsTimer, statTimer = 0, 0, 0

        VisualAPI.PingPanel.Conn = RunService.Heartbeat:Connect(function(dt)
            frames += 1
            fpsTimer += dt
            statTimer += dt

            if fpsTimer >= 1 then
                local fps = frames
                frames = 0
                fpsTimer = 0

                VisualAPI.PingPanel.GUI.FPS.Text = "FPS  : " .. fps
                colorize(VisualAPI.PingPanel.GUI.FPS, fps, 50, 30)
            end

            if statTimer >= 0.5 then
                statTimer = 0
                local ping = getPing()
                VisualAPI.PingPanel.GUI.Ping.Text = "PING : " .. ping .. " ms"
                colorize(VisualAPI.PingPanel.GUI.Ping, ping, 80, 150)
            end
        end)

    elseif not state and VisualAPI.PingPanel.Enabled then
        VisualAPI.PingPanel.Enabled = false

        if VisualAPI.PingPanel.Conn then
            VisualAPI.PingPanel.Conn:Disconnect()
            VisualAPI.PingPanel.Conn = nil
        end

        if VisualAPI.PingPanel.GUI and VisualAPI.PingPanel.GUI.Gui then
            VisualAPI.PingPanel.GUI.Gui:Destroy()
        end

        VisualAPI.PingPanel.GUI = nil
    end
end

return VisualAPI
