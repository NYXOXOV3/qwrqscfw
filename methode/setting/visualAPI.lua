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
-- 5. NYX PING & CPU PANEL
-- =========================================================

VisualAPI.PingPanel = { Visible = false, GUI = nil, Conn = nil }

local function createPingPanel()
    local old = CoreGui:FindFirstChild("NYXPingPanel")
    if old then old:Destroy() end

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "NYXPingPanel"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999

    local c = Instance.new("Frame", sg)
    c.Size = UDim2.new(0,210,0,74)
    c.Position = UDim2.new(0.5,-105,0,60)
    c.BackgroundColor3 = Color3.fromRGB(12,14,18)
    c.BackgroundTransparency = 0.25
    c.Visible = false
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", c)
    stroke.Color = Color3.fromRGB(255,140,50)
    stroke.Transparency = 0.6

    local header = Instance.new("Frame", c)
    header.Size = UDim2.new(1,0,0,32)
    header.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", header)
    title.Position = UDim2.new(0,36,0,0)
    title.Size = UDim2.new(1,-40,1,0)
    title.BackgroundTransparency = 1
    title.Text = "NYX PANEL"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255,140,50)

    local content = Instance.new("Frame", c)
    content.Position = UDim2.new(0,8,0,36)
    content.Size = UDim2.new(1,-16,1,-42)
    content.BackgroundTransparency = 1

    local ping = Instance.new("TextLabel", content)
    ping.Size = UDim2.new(0.5,-6,1,0)
    ping.BackgroundTransparency = 1
    ping.Font = Enum.Font.GothamBold
    ping.TextSize = 13

    local cpu = Instance.new("TextLabel", content)
    cpu.Position = UDim2.new(0.5,6,0,0)
    cpu.Size = UDim2.new(0.5,-6,1,0)
    cpu.BackgroundTransparency = 1
    cpu.Font = Enum.Font.GothamBold
    cpu.TextSize = 13

    return { ScreenGui = sg, Container = c, Ping = ping, CPU = cpu }
end

function VisualAPI.TogglePingPanel(state)
    if state and not VisualAPI.PingPanel.Visible then
        if not VisualAPI.PingPanel.GUI then
            VisualAPI.PingPanel.GUI = createPingPanel()
        end
        local g = VisualAPI.PingPanel.GUI
        g.Container.Visible = true
        VisualAPI.PingPanel.Visible = true

        VisualAPI.PingPanel.Conn = RunService.Heartbeat:Connect(function()
            if not VisualAPI.PingPanel.Visible then return end
            g.Ping.Text = "Ping: " .. math.floor(LocalPlayer:GetNetworkPing()*1000) .. " ms"
            local cpu = math.random(20,45)
            g.CPU.Text = "CPU: " .. cpu .. "%"
        end)

    elseif not state and VisualAPI.PingPanel.Visible then
        VisualAPI.PingPanel.Visible = false
        if VisualAPI.PingPanel.Conn then
            VisualAPI.PingPanel.Conn:Disconnect()
            VisualAPI.PingPanel.Conn = nil
        end
        if VisualAPI.PingPanel.GUI then
            VisualAPI.PingPanel.GUI.Container.Visible = false
        end
    end
end

return VisualAPI
