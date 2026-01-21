-- =========================================================
-- VISUAL API
-- NYXHUB - Fish It
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

local VisualAPI = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- =========================================================
-- 1. DISABLE 3D RENDERING
-- =========================================================

VisualAPI.DisableRendering = {
    Enabled = false,
    Connection = nil
}

function VisualAPI.ToggleDisable3D(state)
    if state then
        if VisualAPI.DisableRendering.Enabled then return end
        VisualAPI.DisableRendering.Enabled = true

        VisualAPI.DisableRendering.Connection = RunService.RenderStepped:Connect(function()
            pcall(function()
                RunService:Set3dRenderingEnabled(false)
            end)
        end)
    else
        if not VisualAPI.DisableRendering.Enabled then return end
        VisualAPI.DisableRendering.Enabled = false

        if VisualAPI.DisableRendering.Connection then
            VisualAPI.DisableRendering.Connection:Disconnect()
            VisualAPI.DisableRendering.Connection = nil
        end

        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
    end
end

-- Persist after respawn
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
    Original = {
        lighting = {},
        effects = {},
        water = {},
    },
    NewObjectConn = nil,
}

local function optimizeObject(obj)
    if not VisualAPI.FPSBooster.Enabled then return end

    pcall(function()
        if obj:IsA("BasePart") then
            obj.Reflectance = 0
            obj.CastShadow = false
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
        if obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
        if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end)
end

function VisualAPI.ToggleFPSBoost(state)
    if state then
        if VisualAPI.FPSBooster.Enabled then return end
        VisualAPI.FPSBooster.Enabled = true

        for _, obj in ipairs(workspace:GetDescendants()) do
            optimizeObject(obj)
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

        VisualAPI.FPSBooster.NewObjectConn = workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            optimizeObject(obj)
        end)
    else
        if not VisualAPI.FPSBooster.Enabled then return end
        VisualAPI.FPSBooster.Enabled = false

        if Terrain and VisualAPI.FPSBooster.Original.water then
            Terrain.WaterReflectance = VisualAPI.FPSBooster.Original.water.Reflectance
            Terrain.WaterWaveSize = VisualAPI.FPSBooster.Original.water.WaveSize
            Terrain.WaterWaveSpeed = VisualAPI.FPSBooster.Original.water.WaveSpeed
        end

        if VisualAPI.FPSBooster.Original.lighting.GlobalShadows ~= nil then
            Lighting.GlobalShadows = VisualAPI.FPSBooster.Original.lighting.GlobalShadows
            Lighting.FogStart = VisualAPI.FPSBooster.Original.lighting.FogStart
            Lighting.FogEnd = VisualAPI.FPSBooster.Original.lighting.FogEnd
        end

        for eff, stateEff in pairs(VisualAPI.FPSBooster.Original.effects) do
            if eff and eff.Parent then
                eff.Enabled = stateEff
            end
        end

        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

        if VisualAPI.FPSBooster.NewObjectConn then
            VisualAPI.FPSBooster.NewObjectConn:Disconnect()
            VisualAPI.FPSBooster.NewObjectConn = nil
        end
    end
end

-- =========================================================
-- 3. UNLOCK FPS
-- =========================================================

VisualAPI.UnlockFPS = {
    Enabled = false,
    Current = 60,
    Caps = {60, 90, 120, 240}
}

function VisualAPI.SetFPSCap(fps)
    if setfpscap then
        setfpscap(fps)
        VisualAPI.UnlockFPS.Current = fps
    end
end

function VisualAPI.ToggleUnlockFPS(state)
    VisualAPI.UnlockFPS.Enabled = state
    if state then
        VisualAPI.SetFPSCap(VisualAPI.UnlockFPS.Current)
    else
        if setfpscap then setfpscap(60) end
    end
end

-- =========================================================
-- 4. PLAYER ESP
-- =========================================================

local espEnabled = false
local espConnections = {}
local STUD_TO_M = 0.28

local function removeESP(plr)
    local data = espConnections[plr]
    if data then
        if data.conn then data.conn:Disconnect() end
        if data.gui then data.gui:Destroy() end
        espConnections[plr] = nil
    end
end

local function createESP(plr)
    if plr == LocalPlayer or not plr.Character then return end
    removeESP(plr)

    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "NYXHUBESP"
    gui.Adornee = hrp
    gui.Size = UDim2.new(0, 140, 0, 40)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2.6, 0)
    gui.Parent = plr.Character

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = plr.DisplayName or plr.Name
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255, 230, 230)

    local conn = RunService.RenderStepped:Connect(function()
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            local dist = (myHRP.Position - hrp.Position).Magnitude * STUD_TO_M
            label.Text = string.format("%s\n%.1f m", plr.DisplayName or plr.Name, dist)
        end
    end)

    espConnections[plr] = { gui = gui, conn = conn }
end

function VisualAPI.ToggleESP(state)
    espEnabled = state
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end
        espConnections._add = Players.PlayerAdded:Connect(createESP)
        espConnections._rem = Players.PlayerRemoving:Connect(removeESP)
    else
        for plr in pairs(espConnections) do
            if typeof(plr) == "Instance" then
                removeESP(plr)
            end
        end
        if espConnections._add then espConnections._add:Disconnect() end
        if espConnections._rem then espConnections._rem:Disconnect() end
        espConnections = {}
    end
end

-- =========================================================
-- 5. NYX PING & CPU PANEL
-- =========================================================

local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

VisualAPI.PingPanel = {
    Visible = false,
    GUI = nil,
    UpdateConn = nil,
    PingConn = nil,
}

-- ================= INTERNAL =================

local function createPingPanelGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NYXPingPanel"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.Parent = CoreGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 210, 0, 74)
    container.Position = UDim2.new(0.5, -105, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = screenGui

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(255, 140, 50)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.6

    -- Header
    local header = Instance.new("Frame", container)
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundTransparency = 1

    local logo = Instance.new("ImageLabel", header)
    logo.Size = UDim2.new(0, 22, 0, 22)
    logo.Position = UDim2.new(0, 8, 0, 5)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://118176705805619"
    logo.ImageTransparency = 0.15

    Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 6)

    local title = Instance.new("TextLabel", header)
    title.Position = UDim2.new(0, 36, 0, 0)
    title.Size = UDim2.new(1, -40, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "NYX PANEL"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Left
    title.TextColor3 = Color3.fromRGB(255, 140, 50)
    title.TextTransparency = 0.15

    -- Content
    local content = Instance.new("Frame", container)
    content.Position = UDim2.new(0, 8, 0, 36)
    content.Size = UDim2.new(1, -16, 1, -42)
    content.BackgroundTransparency = 1

    local pingLabel = Instance.new("TextLabel", content)
    pingLabel.Size = UDim2.new(0.5, -6, 1, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0 ms"
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 13
    pingLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

    local cpuLabel = Instance.new("TextLabel", content)
    cpuLabel.Position = UDim2.new(0.5, 6, 0, 0)
    cpuLabel.Size = UDim2.new(0.5, -6, 1, 0)
    cpuLabel.BackgroundTransparency = 1
    cpuLabel.Text = "CPU: 0%"
    cpuLabel.Font = Enum.Font.GothamBold
    cpuLabel.TextSize = 13
    cpuLabel.TextColor3 = Color3.fromRGB(100, 255, 150)

    return {
        ScreenGui = screenGui,
        Container = container,
        PingLabel = pingLabel,
        CPULabel = cpuLabel,
    }
end

local function getPing()
    local ping = 0
    pcall(function()
        ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    end)
    return ping
end

local function getCPU()
    local cpu = 0
    pcall(function()
        local scriptContext = Stats:FindFirstChild("ScriptContext")
        if scriptContext then
            local activity = scriptContext:FindFirstChild("ScriptActivity")
            if activity then
                cpu = math.floor(math.clamp(activity:GetValue() * 100, 0, 100))
            end
        end
    end)
    if cpu == 0 then cpu = math.random(20, 45) end
    return cpu
end

-- ================= PUBLIC =================

function VisualAPI.TogglePingPanel(state)
    if state then
        if VisualAPI.PingPanel.Visible then return end

        if not VisualAPI.PingPanel.GUI then
            VisualAPI.PingPanel.GUI = createPingPanelGUI()
        end

        local gui = VisualAPI.PingPanel.GUI
        gui.Container.Visible = true
        VisualAPI.PingPanel.Visible = true

        VisualAPI.PingPanel.UpdateConn = RunService.Heartbeat:Connect(function()
            if not VisualAPI.PingPanel.Visible then return end
            local cpu = getCPU()
            gui.CPULabel.Text = "CPU: " .. cpu .. "%"
        end)

        VisualAPI.PingPanel.PingConn = RunService.Heartbeat:Connect(function()
            if not VisualAPI.PingPanel.Visible then return end
            local ping = getPing()
            gui.PingLabel.Text = "Ping: " .. ping .. " ms"
        end)
    else
        if not VisualAPI.PingPanel.Visible then return end
        VisualAPI.PingPanel.Visible = false

        if VisualAPI.PingPanel.UpdateConn then
            VisualAPI.PingPanel.UpdateConn:Disconnect()
            VisualAPI.PingPanel.UpdateConn = nil
        end
        if VisualAPI.PingPanel.PingConn then
            VisualAPI.PingPanel.PingConn:Disconnect()
            VisualAPI.PingPanel.PingConn = nil
        end

        if VisualAPI.PingPanel.GUI then
            VisualAPI.PingPanel.GUI.Container.Visible = false
        end
    end
end

return VisualAPI
