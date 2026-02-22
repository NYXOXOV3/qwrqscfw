-- =========================================================
-- NYXHUB FARM TAB
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then
    warn("[NYXHUB][FarmTab] Window not found.")
    return
end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

-- Load fishing API dari cache NYXHUB
local AutoClickAPI = _G.NYXHUB.Modules["farm/autoclickAPI.lua"]
if not AutoClickAPI then
    warn("[NYXHUB][FarmTab] AutoClickAPI not loaded.")
    return
end
local LegitAPI     = _G.NYXHUB.Modules["farm/legitAPI.lua"]
if not LegitAPI then
    warn("[NYXHUB][FarmTab] LegitAPI not loaded.")
    return
end
local AreaAPI = _G.NYXHUB.Modules["farm/areapositionAPI.lua"]
if not AreaAPI then
    warn("[FarmTab] AreaPositionAPI not loaded")
    return
end
local SkinAPI = _G.NYXHUB.Modules["farm/skinAnimationAPI.lua"]
if not SkinAPI then
    warn("[FarmTab] SkinAnimationAPI not loaded")
    return
end

local farm = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
})

-- =========================================================
-- NYXHUB AUTO CLICK SECTION
-- =========================================================
local auto = farm:Section({ Title = "Auto Click" })

auto:Slider({
    Title = "Legit Click Speed",
    Step = 0.01,
    Value = { Min = 0.01, Max = 0.5, Default = 0.05 },
    Callback = LegitAPI.SetSpeed
})

auto:Toggle({
    Title = "Auto Click",
    Callback = function(v)
        AutoClickAPI.Stop()
        if v then LegitAPI.Start() else LegitAPI.Stop() end
    end
})
auto:Divider()

-- =========================================================
-- NYXHUB LEGIT SECTION
-- =========================================================
local legit = farm:Section({ Title = "Legit"})     

legit:Slider({
    Title = "Normal Complete Delay",
    Step = 0.05,
    Value = { Min = 0.01, Max = 5, Default = 0.5 },
    Callback = AutoClickAPI.SetDelay
})

legit:Toggle({
    Title = "Normal Instant Fish",
    Callback = function(v)
        LegitAPI.Stop()
        if v then AutoClickAPI.Start() else AutoClickAPI.Stop() end
    end
})
legit:Divider()

-- =========================================================
-- NYXHUB AREA SECTION
-- =========================================================
local areafish = farm:Section({ Title = "Farm Area" })

-- DROPDOWN
dropdown = areafish:Dropdown({
    Title = "Choose Area",
    Values = AreaAPI.GetSortedNames(),
    AllowNone = true,
    Callback = function(v)
        AreaAPI.Selected = v
    end
})

-- TELEPORT
areafish:Button({
    Title = "Teleport to Area",
    Callback = function()
        if AreaAPI.Selected then
            AreaAPI.Teleport(AreaAPI.Selected)
        end
    end
})

-- FREEZE
areafish:Toggle({
    Title = "Teleport & Freeze",
    Callback = function(v)
        if AreaAPI.Selected then
            AreaAPI.Teleport(AreaAPI.Selected)
            task.wait(1.5)
            AreaAPI.SetFreeze(v)
        end
    end
})

-- SAVE
areafish:Button({
    Title = "Save Current Position",
    Callback = function()
        AreaAPI.SaveCurrent()
        dropdown:SetValues(AreaAPI.GetSortedNames())
    end
})

-- TELEPORT SAVED
areafish:Button({
    Title = "Teleport to Saved Pos",
    Callback = function()
        AreaAPI.TeleportSaved()
    end
})
areafish:Divider()

-- =========================================================
-- NYXHUB SKIN ANIMATION SECTION
-- =========================================================
local skinSec = farm:Section({ Title = "Skin Animation" })

local skins = SkinAPI.GetSkins()
local current = skins[1]

skinSec:Dropdown({
    Title = "Select Skin",
    Values = skins,
    Value = current,
    Callback = function(v)
        current = v
        SkinAPI.SwitchSkin(v)
    end
})

skinSec:Toggle({
    Title = "Enable Skin Animation",
    Value = false,
    Callback = function(on)
        if on then
            SkinAPI.SwitchSkin(current)
            SkinAPI.Enable()
            WindUI:Notify({Title="Skin ON", Duration=2, Icon="check"})
        else
            SkinAPI.Disable()
            WindUI:Notify({Title="Skin OFF", Duration=2, Icon="x"})
        end
    end
})
