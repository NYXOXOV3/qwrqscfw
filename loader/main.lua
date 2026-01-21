-- =========================================================
-- NYXHUB EXECUTOR LOADER (RE-EXECUTABLE | GITHUB MODE)
-- =========================================================

-- ================= CONFIG =================
local GITHUB_RAW = "https://raw.githubusercontent.com/NYXOXOV3/qwrqscfw/main/"

-- ================= GLOBAL CONTEXT =================
_G.NYXHUB = _G.NYXHUB or {
    Window = nil,
    WindUI = nil,
    Modules = {},
    Flags = {},
    Tabs = {},
}

-- ================= UI CORE =================
if not _G.NYXHUB.WindUI then
    _G.NYXHUB.WindUI = loadstring(
        game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    )()
end

local WindUI = _G.NYXHUB.WindUI

-- ================= WINDOW (CREATE OR REUSE) =================
if not _G.NYXHUB.Window then
    _G.NYXHUB.Window = WindUI:CreateWindow({
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

    _G.NYXHUB.Window:SetToggleKey(Enum.KeyCode.G)
    _G.NYXHUB.Window:Tag({
        Title = "v1.0.3",
        Color = Color3.fromRGB(0, 255, 0),
    })
end

local Window = _G.NYXHUB.Window

-- ================= CLEAN OLD TABS =================
if _G.NYXHUB.Tabs then
    for _, tab in pairs(_G.NYXHUB.Tabs) do
        pcall(function()
            if tab.Destroy then tab:Destroy() end
        end)
    end
end
_G.NYXHUB.Tabs = {}

-- ================= SAFE HTTP LOAD =================
local function httpLoad(path)
    local src = game:HttpGet(GITHUB_RAW .. path)
    local fn = loadstring(src)
    return fn()
end

-- =================================================
-- SECURITY (IDEMPOTENT)
-- =================================================
local Security = httpLoad("security/SecurityLoader.lua")
if Security and Security.Init then
    Security.Init()
end
_G.NYXHUB.Modules.Security = Security

-- =================================================
-- METHOD API LOADER (REFRESH)
-- =================================================
_G.NYXHUB.Modules = {}

for _, path in ipairs({
    "info/infoAPI.lua",

    "setting/configAPI.lua",
    "setting/securityAPI.lua",
    "setting/movementAPI.lua",
    "setting/modesAPI.lua",
    "setting/visualAPI.lua",
    "setting/externalAPI.lua",
    "setting/resetAPI.lua",

    "farm/legitAPI.lua",
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
    -- (list lo tetap, tidak gue ubah)
}) do
    _G.NYXHUB.Modules[path] = httpLoad("methode/" .. path)
end

-- =================================================
-- UI TABS (RELOAD)
-- =================================================
for _, tab in ipairs({
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
}) do
    local fn = loadstring(game:HttpGet(GITHUB_RAW .. "ui/" .. tab))
    fn()
end

_G.NYXHUB.Flags.Ready = true

WindUI:Notify({
    Title = "NYXHUB Reloaded",
    Content = "UI refreshed safely",
    Duration = 2,
    Icon = "refresh",
})
