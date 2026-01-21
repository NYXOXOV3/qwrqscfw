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

-- =========================================================
-- MOVEMENT SECTION
-- =========================================================

local MovementAPI = _G.NYXHUB.Modules["setting/movementAPI.lua"]
if not MovementAPI then
    warn("[NYXHUB][SettingTab] MovementAPI not loaded.")
    return
end

tab:Section({
    Title = "Movement",
    TextSize = 20,
})

-- 1. SLIDER WALKSPEED
local SliderSpeed = tab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = MovementAPI.State.WalkSpeed,
    },
    Callback = function(value)
        MovementAPI:SetWalkSpeed(value)
    end,
})

-- 2. SLIDER JUMPPOWER
local SliderJump = tab:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = {
        Min = 50,
        Max = 200,
        Default = MovementAPI.State.JumpPower,
    },
    Callback = function(value)
        MovementAPI:SetJumpPower(value)
    end,
})

-- 3. RESET BUTTON
tab:Button({
    Title = "Reset Movement",
    Icon = "rotate-ccw",
    Locked = false,
    Callback = function()
        MovementAPI:Reset()

        SliderSpeed:Set(16)
        SliderJump:Set(50)

        _G.NYXHUB.WindUI:Notify({
            Title = "Movement Reset",
            Content = "WalkSpeed & JumpPower reset to default",
            Duration = 3,
            Icon = "check",
        })
    end
})

-- =========================================================
-- MODES SECTION
-- =========================================================

local ModesAPI = _G.NYXHUB.Modules["setting/modesAPI.lua"]
if not ModesAPI then
    warn("[NYXHUB][SettingTab] ModesAPI not loaded.")
    return
end

tab:Section({
    Title = "Modes",
    TextSize = 20,
})

tab:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleInfiniteJump(state)
    end,
})

tab:Toggle({
    Title = "No Clip",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleNoClip(state)
    end,
})

tab:Toggle({
    Title = "Walk on Water",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleWalkOnWater(state)
    end,
})

tab:Toggle({
    Title = "Infinite Zoom",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleInfiniteZoom(state)
    end,
})

tab:Toggle({
    Title = "Freecam",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleFreecam(state)
    end,
})
