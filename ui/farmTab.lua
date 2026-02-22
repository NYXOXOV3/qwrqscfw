-- =========================================================
-- NYXHUB FARM TAB (FIXED VERSION)
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then
    warn("[NYXHUB][FarmTab] Window not found.")
    return
end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

local AutoClickAPI = _G.NYXHUB.Modules["farm/autoclickAPI.lua"]
local LegitAPI     = _G.NYXHUB.Modules["farm/legitAPI.lua"]
local AreaAPI      = _G.NYXHUB.Modules["farm/areapositionAPI.lua"]
local SkinAPI      = _G.NYXHUB.Modules["farm/skinAnimationAPI.lua"]

if not (AutoClickAPI and LegitAPI and AreaAPI and SkinAPI) then
    warn("[NYXHUB][FarmTab] Missing module.")
    return
end

local farm = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
})

-- =========================================================
-- AUTO CLICK SECTION
-- =========================================================
local auto = farm:Section({ Title = "Auto Click" })

auto:Input({
    Title = "Click Speed",
    Placeholder = "0.05",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0.01 and num <= 0.5 then
            AutoClickAPI.SetSpeed(num)
            WindUI:Notify({Title="Speed Updated", Content=tostring(num), Duration=2})
        else
            WindUI:Notify({Title="Invalid Value", Content="Range 0.01 - 0.5", Duration=2, Icon="x"})
        end
    end
})

auto:Toggle({
    Title = "Enable Auto Click",
    Callback = function(v)
        LegitAPI.Stop()
        if v then
            AutoClickAPI.Start()
        else
            AutoClickAPI.Stop()
        end
    end
})

auto:Divider()

-- =========================================================
-- INSTANT FISH SECTION
-- =========================================================
local legit = farm:Section({ Title = "Instant Fish" })

legit:Input({
    Title = "Complete Delay",
    Placeholder = "1.5",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0.05 and num <= 5 then
            LegitAPI.SetDelay(num)
            WindUI:Notify({Title="Delay Updated", Content=tostring(num), Duration=2})
        else
            WindUI:Notify({Title="Invalid Value", Content="Range 0.05 - 5", Duration=2, Icon="x"})
        end
    end
})

legit:Toggle({
    Title = "Enable Instant Fish",
    Callback = function(v)
        AutoClickAPI.Stop()
        if v then
            LegitAPI.Start()
        else
            LegitAPI.Stop()
        end
    end
})
legit:Divider()
-- =========================================================
-- AREA SECTION
-- =========================================================
local areafish = farm:Section({ Title = "Farm Area" })

local dropdown = areafish:Dropdown({
    Title = "Choose Area",
    Values = AreaAPI.GetSortedNames(),
    AllowNone = true,
    Callback = function(v)
        AreaAPI.Selected = v
    end
})

areafish:Button({
    Title = "Teleport to Area",
    Callback = function()
        if AreaAPI.Selected then
            AreaAPI.Teleport(AreaAPI.Selected)
        end
    end
})

areafish:Toggle({
    Title = "Teleport & Freeze",
    Callback = function(v)
        if AreaAPI.Selected then
            AreaAPI.Teleport(AreaAPI.Selected)
            task.wait(1)
            AreaAPI.SetFreeze(v)
        end
    end
})

areafish:Button({
    Title = "Save Current Position",
    Callback = function()
        AreaAPI.SaveCurrent()
        dropdown:SetValues(AreaAPI.GetSortedNames())
    end
})

areafish:Button({
    Title = "Teleport to Saved Pos",
    Callback = function()
        AreaAPI.TeleportSaved()
    end
})

areafish:Divider()

-- =========================================================
-- SKIN SECTION
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
    Callback = function(on)
        if on then
            SkinAPI.SwitchSkin(current)
            SkinAPI.Enable()
            WindUI:Notify({Title="Skin Enabled", Duration=2, Icon="check"})
        else
            SkinAPI.Disable()
            WindUI:Notify({Title="Skin Disabled", Duration=2, Icon="x"})
        end
    end
})
