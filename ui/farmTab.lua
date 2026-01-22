-- =========================================================
-- NYXHUB FARM TAB
-- MODE: AUTO FISHING (3 Instant Modes)
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
local BlatantAPI   = _G.NYXHUB.Modules["farm/blatantAPI.lua"]
if not BlatantAPI then
    warn("[NYXHUB][FarmTab] BlatantAPI not loaded.")
    return
end

local farm = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
})

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
        BlatantAPI.Stop()
        if v then LegitAPI.Start() else LegitAPI.Stop() end
    end
})

local legit = farm:Section({ Title = "Legit"})     

legit:Slider({
    Title = "Normal Complete Delay",
    Step = 0.05,
    Value = { Min = 0.5, Max = 5, Default = 1.5 },
    Callback = AutoClickAPI.SetDelay
})

legit:Toggle({
    Title = "Normal Instant Fish",
    Callback = function(v)
        LegitAPI.Stop()
        BlatantAPI.Stop()
        if v then AutoClickAPI.Start() else AutoClickAPI.Stop() end
    end
})



local blatant = farm:Section({ Title = "Blatant Mode" })

blatant:Toggle({
    Title = "Instant Fishing (Blatant)",
    Callback = function(v)
        LegitAPI.Stop()
        AutoClickAPI.Stop()
        if v then BlatantAPI.Start() else BlatantAPI.Stop() end
    end
})

blatant:Dropdown({
    Title = "Mode",
    Values = {"Old","New"},
    Callback = BlatantAPI.SetMode
})

blatant:Input({
    Title = "Cancel Delay",
    Default = "1.75",
    Callback = function(v)
        BlatantAPI.SetDelay(tonumber(v), nil)
    end
})

blatant:Input({
    Title = "Complete Delay",
    Default = "1.33",
    Callback = function(v)
        BlatantAPI.SetDelay(nil, tonumber(v))
    end
})
