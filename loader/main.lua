-- =========================================================
-- NYXHUB EXECUTOR LOADER (RELOAD SAFE - GITHUB MODE)
-- =========================================================

-- ================= RELOAD HANDLER =================
if _G.NYXHUB then
    pcall(function()
        if _G.NYXHUB.Window and _G.NYXHUB.Window.Destroy then
            _G.NYXHUB.Window:Destroy()
        end

        if _G.NYXHUB.ScreenGui then
            _G.NYXHUB.ScreenGui:Destroy()
        end
    end)

    _G.NYXHUB = nil
end

-- ================= GLOBAL INIT =================
_G.NYXHUB = {
    Modules = {},
    Flags = {}
}

-- ================= CONFIG =================
local GITHUB_RAW = "https://raw.githubusercontent.com/NYXOXOV3/qwrqscfw/main/"
local Version = "1.6.63"

-- ================= SERVICES =================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================= LOAD WINDUI =================
local WindUI = loadstring(
    game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua")
)()

-- ================= CREATE WINDOW =================
local Window = WindUI:CreateWindow({
    Title = "NYXHUB - Fish It",
    Icon = "rbxassetid://137263312772667",
    Folder = "NYXHUB",
    Size = UDim2.fromOffset(600, 360),
    MinSize = Vector2.new(560, 250),
    MaxSize = Vector2.new(950, 760),
    Theme = "Violet",
    Resizable = true,
    SideBarWidth = 190,
    Transparent = true,
})

Window:SetToggleKey(Enum.KeyCode.G)
Window:Tag({
    Title = "v1.0.3",
    Color = Color3.fromRGB(0,255,0),
})

_G.NYXHUB.Window = Window
_G.NYXHUB.WindUI = WindUI

-- ================= SAFE HTTP LOAD =================
local function httpLoad(path)
    local ok, src = pcall(game.HttpGet, game, GITHUB_RAW .. path)
    if not ok or not src then
        warn("[NYXHUB][HTTP FAIL]:", path)
        return nil
    end

    local fn, err = loadstring(src)
    if not fn then
        warn("[NYXHUB][LOADSTRING FAIL]:", path, err)
        return nil
    end

    return fn()
end

-- =================================================
-- SECURITY LOAD
-- =================================================
local Security = httpLoad("security/SecurityLoader.lua")
if Security and Security.Init then
    Security.Init()
end
_G.NYXHUB.Modules.Security = Security

-- =================================================
-- LOAD METHODS
-- =================================================
local METHOD_LIST = {
    "info/infoAPI.lua",
    "setting/securityAPI.lua",
    "setting/movementAPI.lua",
    "setting/modesAPI.lua",
    "setting/visualAPI.lua",
    "farm/autoclickAPI.lua",
    "farm/blatantv1.lua",
    "farm/legitAPI.lua",
    "farm/blatantAPI.lua",
    "farm/areapositionAPI.lua",
    "farm/skinAnimationAPI.lua",
    "automatic/autosellAPI.lua",
    "automatic/autofavoritAPI.lua",
    "automatic/autotradeAPI.lua",
    "automatic/autoenchantAPI.lua",
    "automatic/autosecenchantAPI.lua",
    "automatic/autoweatherAPI.lua",
    "automatic/autototemAPI.lua",
    "quest/ghostfinAPI.lua",
    "quest/eleAPI.lua",
    "quest/diamondAPI.lua",
    "webhook/webhookAPI.lua",
    "util/gearAPI.lua",
    "util/equiptAPI.lua",
    "shop/gearAPI.lua",
    "shop/teleportAPI.lua",
    "shop/merchantAPI.lua",
    "teleport/locationAPI.lua",
    "teleport/playerAPI.lua",
    "event/admineventAPI.lua",
    "event/lochnessAPI.lua",
    "event/gameeventAPI.lua",
    "event/piratechestAPI.lua",
    "exclusive/templelaverAPI.lua",
    "exclusive/ruindoorAPI.lua",
    "exclusive/kaitunAPI.lua",
    "exclusive/miscAPI.lua",
}

for _, path in ipairs(METHOD_LIST) do
    local mod = httpLoad("methode/" .. path)
    if mod then
        _G.NYXHUB.Modules[path] = mod
    end
end

-- =================================================
-- LOAD UI TABS
-- =================================================
local UI_TABS = {
    "infoTab.lua",
    "settingTab.lua",
    "farmTab.lua",
    "automaticTab.lua",
    "questTab.lua",
    "webhookTab.lua",
    "utilitiesTab.lua",
    "shopTab.lua",
    "teleportTab.lua",
    "eventTab.lua",
    "exclusiveTab.lua",
}

for _, tab in ipairs(UI_TABS) do
    pcall(function()
        loadstring(game:HttpGet(GITHUB_RAW .. "ui/" .. tab))()
    end)
end

-- =================================================
-- FLOATING BUTTON
-- =================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NYX_FloatingBtn"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

_G.NYXHUB.ScreenGui = screenGui

local btn = Instance.new("ImageButton")
btn.Size = UDim2.new(0,55,0,55)
btn.AnchorPoint = Vector2.new(0.5,0.5)
btn.Position = UDim2.new(0.95,0,0.5,0)
btn.BackgroundColor3 = Color3.fromRGB(45,15,65)
btn.Image = "rbxassetid://137263312772667"
btn.Parent = screenGui

Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

btn.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

-- =================================================
-- CLEANUP ON DESTROY
-- =================================================
Window:OnDestroy(function()
    pcall(function()
        if screenGui then
            screenGui:Destroy()
        end
    end)
end)

-- =================================================
-- READY
-- =================================================
_G.NYXHUB.Flags.Ready = true

WindUI:Notify({
    Title = "NYXHUB Ready",
    Content = "Reload Safe Mode Active",
    Duration = 3,
    Icon = "check",
})

print("[NYXHUB] Loaded (Reload Safe)")
