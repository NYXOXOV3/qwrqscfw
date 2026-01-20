-- =========================================================
-- NYXHUB INFO TAB
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then
    warn("[NYXHUB][InfoTab] Window not found.")
    return
end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

-- Ambil InfoAPI
local InfoAPI = nil
do
    local ok, api = pcall(function()
        return _G.NYXHUB.Modules["info/infoAPI.lua"]
    end)
    if ok then InfoAPI = api end
end

if not InfoAPI then
    warn("[NYXHUB][InfoTab] InfoAPI not loaded.")
    return
end

-- =========================================================
-- TAB SETUP
-- =========================================================
local tab = Window:Tab({
    Title = "Info",
    Icon = "info",
    Locked = false,
})

tab:Select()

tab:Section({
    Title = "NYXHUB Information",
    TextSize = 20,
})

-- =========================================================
-- STATIC INFO
-- =========================================================
local session = InfoAPI:GetSessionInfo()

tab:Paragraph({
    Title = "Version",
    Desc = tostring(session.Version),
})

tab:Paragraph({
    Title = "Executor",
    Desc = tostring(session.Executor),
})

tab:Paragraph({
    Title = "Player",
    Desc = tostring(session.Player),
})

tab:Paragraph({
    Title = "Place ID",
    Desc = tostring(session.PlaceId),
})

tab:Paragraph({
    Title = "Modules Loaded",
    Desc = tostring(session.Modules),
})

-- =========================================================
-- LIVE UPTIME
-- =========================================================
tab:Divider()

local uptimeLabel = tab:Paragraph({
    Title = "Session Uptime",
    Desc = "00h 00m 00s",
})

-- Update uptime tiap 1 detik (ringan)
task.spawn(function()
    while _G.NYXHUB and _G.NYXHUB.Flags and _G.NYXHUB.Flags.Ready do
        pcall(function()
            uptimeLabel:Set({
                Title = "Session Uptime",
                Desc = InfoAPI:GetUptime(),
            })
        end)
        task.wait(1)
    end
end)

-- =========================================================
-- STATUS
-- =========================================================
tab:Divider()

tab:Paragraph({
    Title = "System Status",
    Desc = InfoAPI:IsReady() and "✅ NYXHUB Ready" or "⚠️ Not Ready",
})
