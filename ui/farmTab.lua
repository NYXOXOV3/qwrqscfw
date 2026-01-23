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
local Legit1API = _G.NYXHUB.Modules["farm/legit1API.lua"]
if not Legit1API then
    warn("[NYXHUB][FarmTab] Legit1API not loaded.")
    return
end
local PerfectAPI = _G.NYXHUB.Modules["farm/legit2API.lua"]
if not PerfectAPI then
    warn("[FarmTab] InstantPerfectAPI not loaded")
    return
end
local UltraBlatantAPI = _G.NYXHUB.Modules["farm/blatant1API.lua"]
if not UltraBlatantAPI then
    warn("[FarmTab] UltraBlatantAPI not loaded")
    return
end
local UltraBlatantV2 = _G.NYXHUB.Modules["farm/blatant2API.lua"]
if not UltraBlatantV2 then
    warn("[FarmTab] UltraBlatantV2 API not loaded")
    return
end
local BlatantV3FixAPI = _G.NYXHUB.Modules["farm/blatant3API.lua"]
if not BlatantV3FixAPI then
    warn("[FarmTab] BlatantV3FixAPI API not loaded")
    return
end
local AreaAPI = _G.NYXHUB.Modules["farm/areapositionAPI.lua"]
if not AreaAPI then
    warn("[FarmTab] AreaPositionAPI not loaded")
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
auto:Divider()
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
legit:Divider()
local legit1  = farm:Section({ Title = "Legit V1" })

legit1:Input({
    Title = "Max Wait Time",
    Placeholder = "1.30",
    Default = "1.30",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            Legit1API.SetDelay(n, nil)
        end
    end
})

legit1:Input({
    Title = "Cancel Delay",
    Placeholder = "0.19",
    Default = "0.19",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            Legit1API.SetDelay(nil, n)
        end
    end
})

legit1:Toggle({
    Title = "Legit V1",
    Callback = function(state)
        if state then
            Legit1API.Start()
        else
            Legit1API.Stop()
        end
    end
})
legit1:Divider()
local legit2 = farm:Section({ Title  = "Legit v2" })

legit2:Input({
    Title = "Fishing Delay",
    Placeholder = "1.50",
    Default = "1.50",
    Callback = function(v)
        local n = tonumber(v)
        if n then PerfectAPI.SetDelay(n, nil) end
    end
})

legit2:Input({
    Title = "Cancel Delay",
    Placeholder = "0.19",
    Default = "0.19",
    Callback = function(v)
        local n = tonumber(v)
        if n then PerfectAPI.SetDelay(nil, n) end
    end
})

legit2:Toggle({
    Title = "Enable Instant Perfect",
    Callback = function(state)
        if state then
            PerfectAPI.Start()
        else
            PerfectAPI.Stop()
        end
    end
})
legit2:Divider()
local blatant = farm:Section({ Title = "Blatant Stabil" })

blatant:Toggle({
    Title = "Instant Fishing (Blatant)",
    Callback = function(v)
        LegitAPI.Stop()
        AutoClickAPI.Stop()
        if v then BlatantAPI.Start() else BlatantAPI.Stop() end
    end
})

blatant:Input({
    Title = "Cancel Delay",
    Default = "1.75",
    Placeholder = "1.75",
    Callback = function(v)
        BlatantAPI.SetDelay(tonumber(v), nil)
    end
})

blatant:Input({
    Title = "Complete Delay",
    Default = "1.33",
    Placeholder = "1.33",
    Callback = function(v)
        BlatantAPI.SetDelay(nil, tonumber(v))
    end
})
blatant:Divider()
local blatantv1 = farm:Section({ Title = "Blatant V1" })

blatantv1:Input({
    Title = "Complete Delay",
    Placeholder = "0.001",
    Default = tostring(UltraBlatantAPI.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            UltraBlatantAPI.UpdateSettings(n, nil)
        end
    end
})

blatantv1:Input({
    Title = "Cancel Delay",
    Placeholder = "0.001",
    Default = tostring(UltraBlatantAPI.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            UltraBlatantAPI.UpdateSettings(nil, n)
        end
    end
})

blatantv1:Toggle({
    Title = "Ultra Blatant Fishing",
    Callback = function(state)
        if state then
            UltraBlatantAPI.Start()
            WindUI:Notify({
                Title = "Ultra Blatant ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            UltraBlatantAPI.Stop()
            WindUI:Notify({
                Title = "Ultra Blatant OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})
blatantv1:Divider()
local blatantv2 = farm:Section({ Title = "Blatant V2" })

blatantv2:Input({
    Title = "Complete Delay",
    Placeholder = "0.73",
    Default = tostring(UltraBlatantV2.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            UltraBlatantV2.UpdateSettings(n, nil, nil)
        end
    end
})

blatantv2:Input({
    Title = "Cancel Delay",
    Placeholder = "0.3",
    Default = tostring(UltraBlatantV2.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            UltraBlatantV2.UpdateSettings(nil, n, nil)
        end
    end
})

blatantv2:Input({
    Title = "ReCast Delay",
    Placeholder = "0.001",
    Default = tostring(UltraBlatantV2.Settings.ReCastDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            UltraBlatantV2.UpdateSettings(nil, nil, n)
        end
    end
})

blatantv2:Toggle({
    Title = "Ultra Blatant V2",
    Callback = function(state)
        if state then
            UltraBlatantV2.Start()
            WindUI:Notify({
                Title = "Ultra Blatant V2 ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            UltraBlatantV2.Stop()
            WindUI:Notify({
                Title = "Ultra Blatant V2 OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})
blatantv2:Divider()
local blatantv3 = farm:Section({ Title = "Auto Perfect" })

blatantv3:Input({
    Title = "Fishing Delay",
    Default = "0.05",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV3FixAPI.Settings.FishingDelay = n
        end
    end
})

blatantv3:Input({
    Title = "Cancel Delay",
    Default = "0.01",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV3FixAPI.Settings.CancelDelay = n
        end
    end
})

blatantv3:Input({
    Title = "Hook Wait Time",
    Default = "0.01",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV3FixAPI.Settings.HookWaitTime = n
        end
    end
})

blatantv3:Input({
    Title = "Cast Delay",
    Default = "0.25",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV3FixAPI.Settings.CastDelay = n
        end
    end
})

blatantv3:Input({
    Title = "Timeout Delay",
    Default = "0.8",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV3FixAPI.Settings.TimeoutDelay = n
        end
    end
})

blatantv3:Toggle({
    Title = "Enable Auto Perfect",
    Callback = function(state)
        if state then
            BlatantV3FixAPI.Start()
        else
            BlatantV3FixAPI.Stop()
        end
    end
})
blatantv3:Divider()
local areafish = farm:Section({ Title = "Farm Area" })

areafish:Dropdown({
    Title = "Choose Area",
    Values = AreaAPI.AreaNames,
    AllowNone = true,
    Callback = function(v)
        AreaAPI.SelectedArea = v
    end
})

areafish:Toggle({
    Title = "Teleport & Freeze Area",
    Callback = function(state)
        AreaAPI.ToggleFreeze(state)
        WindUI:Notify({
            Title = state and "Area Locked" or "Unfrozen",
            Duration = 2,
            Icon = state and "lock" or "unlock"
        })
    end
})

areafish:Button({
    Title = "Teleport to Area",
    Callback = function()
        local area = AreaAPI.FishingAreas[AreaAPI.SelectedArea]
        if area then
            AreaAPI.TeleportToLookAt(area.Pos, area.Look)
        end
    end
})

areafish:Button({
    Title = "Save Current Position",
    Callback = function()
        AreaAPI.SaveCurrent()
        WindUI:Notify({
            Title = "Position Saved",
            Duration = 2,
            Icon = "save"
        })
    end
})

areafish:Button({
    Title = "Teleport to Saved Pos",
    Callback = function()
        if AreaAPI.SavedPosition then
            AreaAPI.TeleportToLookAt(
                AreaAPI.SavedPosition.Pos,
                AreaAPI.SavedPosition.Look
            )
        end
    end
})
