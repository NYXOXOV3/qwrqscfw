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
local security = tab:Section({
    Title = "Security",
    TextSize = 20,
})

security:Toggle({
    Title = "Hide Username (Solace)",
    Desc = "Hide your real username & display name",
    Default = _G.SolaceDisguise == true,
    Callback = function(state)
        SecurityAPI.ToggleSolace(state)
    end,
})

security:Toggle({
    Title = "Anti Staff",
    Desc = "Detect staff/moderator joining the server",
    Default = _G.AntiStaffEnabled == true,
    Callback = function(state)
        SecurityAPI.ToggleAntiStaff(state)
    end,
})
security:Divider()
-- =========================================================
-- MOVEMENT SECTION
-- =========================================================

local MovementAPI = _G.NYXHUB.Modules["setting/movementAPI.lua"]
if not MovementAPI then
    warn("[NYXHUB][SettingTab] MovementAPI not loaded.")
    return
end

local movement = tab:Section({
    Title = "Movement",
    TextSize = 20,
})

-- 1. SLIDER WALKSPEED
local SliderSpeed = movement:Slider({
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
local SliderJump = movement:Slider({
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
movement:Button({
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
movement:Divider()
-- =========================================================
-- MODES SECTION
-- =========================================================

local ModesAPI = _G.NYXHUB.Modules["setting/modesAPI.lua"]
if not ModesAPI then
    warn("[NYXHUB][SettingTab] ModesAPI not loaded.")
    return
end

local modes = tab:Section({
    Title = "Modes",
    TextSize = 20,
})

-- 1. Infinite Jump
modes:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump without limit",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleInfiniteJump(state)
    end,
})

-- 2. No Clip
modes:Toggle({
    Title = "No Clip",
    Desc = "Walk through objects",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleNoClip(state)
    end,
})

-- 3. Walk on Water
modes:Toggle({
    Title = "Walk on Water",
    Desc = "Walk on terrain water",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleWalkOnWater(state)
    end,
})

-- 4. Infinite Zoom
modes:Toggle({
    Title = "Infinite Zoom",
    Desc = "Unlimited camera zoom",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleInfiniteZoom(state)
    end,
})

-- 5. Freecam
modes:Toggle({
    Title = "Freecam",
    Desc = "Detach camera and fly freely",
    Default = false,
    Callback = function(state)
        ModesAPI.ToggleFreecam(state)
    end,
})
modes:Divider()
-- =========================================================
-- VISUAL SECTION
-- =========================================================

local VisualAPI = _G.NYXHUB.Modules["setting/visualAPI.lua"]
if not VisualAPI then
    warn("[NYXHUB][SettingTab] VisualAPI not loaded.")
    return
end


local visual = tab:Section({ Title = "Visual", TextSize = 20 })

visual:Toggle({
    Title = "FPS Boost",
    Callback = function(v)
        VisualAPI.ToggleFPSBoost(v)
    end,
})

visual:Toggle({
    Title = "Disable 3D Rendering",
    Callback = function(v)
        VisualAPI.ToggleDisable3D(v)
    end,
})

visual:Dropdown({
    Title = "FPS Limit",
    Values = {"30","60","90","120","144","165","240"},
    Default = tostring(VisualAPI.UnlockFPS.Selected),
    Callback = function(v)
        VisualAPI.SetFPSCap(tonumber(v))
    end,
})

visual:Toggle({
    Title = "Unlock FPS",
    Callback = function(v)
        VisualAPI.ToggleUnlockFPS(v)
    end,
})

visual:Toggle({
    Title = "Ping Panel",
    Desc = "Show FPS & Ping",
    Default = false,
    Callback = function(state)
        VisualAPI.TogglePingPanel(state)
    end,
})

visual:Toggle({
    Title = "Player ESP",
    Callback = function(v)
        VisualAPI.ToggleESP(v)
    end,
})
visual:Divider()
-- =========================================================
-- EXTERNAL SECTION
-- =========================================================

local external = tab:Section({ Title = "External", TextSize = 20 })

external:Button({
    Title = "Fly",
    Desc = "Fly Gui",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})
external:Divider()
