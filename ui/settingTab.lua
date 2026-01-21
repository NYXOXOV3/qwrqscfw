-- =========================================================
-- NYXHUB SETTING TAB
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then
    warn("[NYXHUB][SettingTab] Window not found.")
    return
end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

local SecurityAPI = _G.NYXHUB.Modules["setting/securityAPI.lua"]
if not SecurityAPI then
    warn("[NYXHUB][SettingTab] SecurityAPI not loaded.")
    return
end

local tab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
    Locked = false,
})

-- =========================
-- SECURITY SECTION
-- =========================
tab:Section({
    Title = "Security",
    TextSize = 20,
})

tab:Toggle({
    Title = "Hide Username (Solace)",
    Desc = "Hide your real username & display name",
    Default = _G.SolaceDisguise == true,
    Callback = function(state)
        SecurityAPI.ToggleSolace(state)
    end,
})

tab:Toggle({
    Title = "Anti Staff",
    Desc = "Detect staff/moderator joining the server",
    Default = _G.AntiStaffEnabled == true,
    Callback = function(state)
        SecurityAPI.ToggleAntiStaff(state)
    end,
})
