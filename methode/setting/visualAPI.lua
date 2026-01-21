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
-- 2. FPS BOOSTER
-- =========================================================

VisualAPI.FPSBooster = {
    Enabled = false,
    Original = { lighting = {}, effects = {}, water = {} },
    Conn = nil
}

local function optimize(obj)
    if not VisualAPI.FPSBooster.Enabled then return end
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end)
end

function VisualAPI.ToggleFPSBoost(state)
    if state and not VisualAPI.FPSBooster.Enabled then
        VisualAPI.FPSBooster.Enabled = true

        for _, obj in ipairs(workspace:GetDescendants()) do
            optimize(obj)
        end

        if Terrain then
            VisualAPI.FPSBooster.Original.water = {
                Reflectance = Terrain.WaterReflectance,
                WaveSize = Terrain.WaterWaveSize,
                WaveSpeed = Terrain.WaterWaveSpeed
            }
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
        end

        VisualAPI.FPSBooster.Original.lighting = {
            GlobalShadows = Lighting.GlobalShadows,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd
        }

        Lighting.GlobalShadows = false
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e6

        for _, eff in ipairs(Lighting:GetChildren()) do
            if eff:IsA("PostEffect") then
                VisualAPI.FPSBooster.Original.effects[eff] = eff.Enabled
                eff.Enabled = false
            end
        end

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        VisualAPI.FPSBooster.Conn = workspace.DescendantAdded:Connect(function(o)
            task.wait(0.1)
            optimize(o)
        end)

    elseif not state and VisualAPI.FPSBooster.Enabled then
        VisualAPI.FPSBooster.Enabled = false

        if Terrain then
            local w = VisualAPI.FPSBooster.Original.water
            Terrain.WaterReflectance = w.Reflectance
            Terrain.WaterWaveSize = w.WaveSize
            Terrain.WaterWaveSpeed = w.WaveSpeed
        end

        local l = VisualAPI.FPSBooster.Original.lighting
        Lighting.GlobalShadows = l.GlobalShadows
        Lighting.FogStart = l.FogStart
        Lighting.FogEnd = l.FogEnd

        for eff, st in pairs(VisualAPI.FPSBooster.Original.effects) do
            if eff and eff.Parent then eff.Enabled = st end
        end

        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

        if VisualAPI.FPSBooster.Conn then
            VisualAPI.FPSBooster.Conn:Disconnect()
            VisualAPI.FPSBooster.Conn = nil
        end
    end
end

-- =========================================================
-- 3. UNLOCK FPS (DROPDOWN + TOGGLE)
-- =========================================================

VisualAPI.UnlockFPS = {
    Enabled = false,
    Selected = 60,
    Caps = {30,60,90,120,144,165,240}
}

function VisualAPI.SetFPSCap(fps)
    VisualAPI.UnlockFPS.Selected = fps
    if VisualAPI.UnlockFPS.Enabled and setfpscap then
        setfpscap(fps)
    end
end

function VisualAPI.ToggleUnlockFPS(state)
    VisualAPI.UnlockFPS.Enabled = state
    if setfpscap then
        setfpscap(state and VisualAPI.UnlockFPS.Selected or 60)
    end
end

-- =========================================================
-- 4. PLAYER ESP
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
    GOOD   = Color3.fromRGB(140, 255, 200),
    MID    = Color3.fromRGB(255, 200, 140),
    BAD    = Color3.fromRGB(255, 120, 140),
}

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
    panel.Size = UDim2.new(0, 170, 0, 64)
    panel.Position = UDim2.new(0.5, -85, 0, 60)
    panel.BackgroundColor3 = THEME.BG
    panel.BackgroundTransparency = 0.18
    panel.BorderSizePixel = 0
    panel.Parent = gui

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = THEME.STROKE
    stroke.Thickness = 1.4
    stroke.Transparency = 0.45

    local content = Instance.new("Frame", panel)
    content.Size = UDim2.fromScale(1,1)
    content.BackgroundTransparency = 1

    local function statBlock(titleText, x)
        local block = Instance.new("Frame", content)
        block.Size = UDim2.new(0.5, 0, 1, 0)
        block.Position = UDim2.new(x, 0, 0, 0)
        block.BackgroundTransparency = 1

        local title = Instance.new("TextLabel", block)
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.Font = Enum.Font.GothamBold
        title.TextSize = 11
        title.TextColor3 = THEME.TITLE

        local value = Instance.new("TextLabel", block)
        value.Position = UDim2.new(0, 0, 0, 22)
        value.Size = UDim2.new(1, 0, 0, 30)
        value.BackgroundTransparency = 1
        value.Text = "--"
        value.Font = Enum.Font.GothamBold
        value.TextSize = 18
        value.TextColor3 = THEME.TEXT

        return value
    end

    local fpsLabel  = statBlock("FPS", 0)
    local pingLabel = statBlock("PING", 0.5)

    -- =========================
    -- DRAG (MOUSE + TOUCH)
    -- =========================
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

                VisualAPI.PingPanel.GUI.FPS.Text = fps
                colorize(VisualAPI.PingPanel.GUI.FPS, fps, 50, 30)
            end

            if statTimer >= 0.5 then
                statTimer = 0
                local ping = getPing()
                VisualAPI.PingPanel.GUI.Ping.Text = ping
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
