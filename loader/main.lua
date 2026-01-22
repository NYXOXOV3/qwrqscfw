-- =========================================================
-- NYXHUB EXECUTOR LOADER (GITHUB MODE)
-- =========================================================

if _G.__NYXHUB_EXECUTED then return end
_G.__NYXHUB_EXECUTED = true

-- ================= CONFIG =================
local GITHUB_RAW = "https://raw.githubusercontent.com/NYXOXOV3/qwrqscfw/main/"

-- ================= SERVICES =================
local HttpService = game:GetService("HttpService")

-- ================= UI CORE =================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
    Color = Color3.fromRGB(0, 255, 0),
})

-- ================= GLOBAL CONTEXT =================
_G.NYXHUB = {
    Window = Window,
    WindUI = WindUI,
    Modules = {},
    Flags = {},
}

-- ================= SAFE HTTP LOAD =================
local function httpLoad(path)
    local url = GITHUB_RAW .. path
    local ok, src = pcall(game.HttpGet, game, url)
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
-- 1️⃣ SECURITY (FIRST)
-- =================================================
local Security = httpLoad("security/SecurityLoader.lua")
if Security and Security.Init then
    Security.Init()
end
_G.NYXHUB.Modules.Security = Security

-- =================================================
-- 2️⃣ METHOD API LOADER
-- =================================================
local METHOD_LIST = {
    "info/infoAPI.lua",

    "setting/configAPI.lua",
    "setting/securityAPI.lua",
    "setting/movementAPI.lua",
    "setting/modesAPI.lua",
    "setting/visualAPI.lua",
    "setting/externalAPI.lua",
    "setting/resetAPI.lua",

    "farm/autoclickAPI.lua",
    "farm/legitAPI.lua",
    "farm/blatantAPI.lua",
    "farm/blatant1API.lua",
    "farm/blatant2API.lua",
    "farm/blatant3API.lua",
    "farm/blatant4API.lua",
    "farm/blatant5API.lua",
    "farm/blatant6API.lua",
    "farm/fastperfectAPI.lua",
    "farm/areapositionAPI.lua",

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
-- 3️⃣ UI TABS (EXECUTE)
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
    local ok, err = pcall(function()
        loadstring(game:HttpGet(GITHUB_RAW .. "ui/" .. tab))()
    end)
    if not ok then
        warn("[NYXHUB][UI TAB ERROR]:", tab, err)
    end
end

-- =================================================
-- READY
-- =================================================
_G.NYXHUB.Flags.Ready = true

WindUI:Notify({
    Title = "NYXHUB Ready",
    Content = "Loaded from GitHub repository",
    Duration = 3,
    Icon = "check",
})

print("[NYXHUB] Loaded fully from GitHub.")
