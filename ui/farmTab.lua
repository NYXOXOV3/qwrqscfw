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
local BlatantV1 = _G.NYXHUB.Modules["farm/blatant1API.lua"]
if not BlatantV1 then
    warn("[FarmTab] BlatantV1 not loaded")
    return
end
local BlatantV2 = _G.NYXHUB.Modules["farm/blatant2API.lua"]
if not BlatantV2 then
    warn("[FarmTab] BlatantV2 API not loaded")
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
local SkinAPI = _G.NYXHUB.Modules["farm/skinAnimationAPI.lua"]
if not SkinAPI then
    warn("[FarmTab] SkinAnimationAPI not loaded")
    return
end
local BlatantBeta = _G.NYXHUB.Modules["farm/blatantv1.lua"]
if not BlatantBeta then
    warn("[FarmTab] BlatantBeta not loaded")
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
-- =========================================================
-- LEGIT MODE (FAST / PERFECT)
-- =========================================================

local legitMode = "Fast"
local legitEnabled = false

local legitCombo = farm:Section({ Title = "Legit Mode" })

-- MODE DROPDOWN
legitCombo:Dropdown({
    Title = "Legit Type",
    Values = { "Fast", "Perfect" },
    Value = "Fast",
    Callback = function(v)
        legitMode = v

        -- kalau lagi ON, switch mode langsung
        if legitEnabled then
            Legit1API.Stop()
            PerfectAPI.Stop()

            if v == "Fast" then
                Legit1API.Start()
            else
                PerfectAPI.Start()
            end
        end
    end
})

-- FAST SETTINGS (LEGIT V1)
legitCombo:Input({
    Title = "Fast - Max Wait Time",
    Placeholder = "1.30",
    Default = "1.30",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            Legit1API.SetDelay(n, nil)
        end
    end
})

legitCombo:Input({
    Title = "Fast - Cancel Delay",
    Placeholder = "0.19",
    Default = "0.19",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            Legit1API.SetDelay(nil, n)
        end
    end
})

-- PERFECT SETTINGS (LEGIT V2)
legitCombo:Input({
    Title = "Perfect - Fishing Delay",
    Placeholder = "1.50",
    Default = "1.50",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            PerfectAPI.SetDelay(n, nil)
        end
    end
})

legitCombo:Input({
    Title = "Perfect - Cancel Delay",
    Placeholder = "0.19",
    Default = "0.19",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            PerfectAPI.SetDelay(nil, n)
        end
    end
})

legitCombo:Divider()

-- TOGGLE
legitCombo:Toggle({
    Title = "Enable Legit Fishing",
    Callback = function(state)
        legitEnabled = state

        -- stop semua legit dulu
        Legit1API.Stop()
        PerfectAPI.Stop()

        if state then
            if legitMode == "Fast" then
                Legit1API.Start()
            else
                PerfectAPI.Start()
            end
        end
    end
})
legitCombo:Divider()
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

local blatantbt = farm:Section({ Title = "Blatant Beta" })

-- ===============================
-- COMPLETE DELAY INPUT
-- ===============================
blatantbt:Input({
    Title = "Complete Delay",
    Placeholder = "0.001",
    Default = tostring(BlatantBeta.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then
            BlatantBeta.UpdateSettings(n, nil)
        end
    end
})

-- ===============================
-- CANCEL DELAY INPUT
-- ===============================
blatantbt:Input({
    Title = "Cancel Delay",
    Placeholder = "0.001",
    Default = tostring(BlatantBeta.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then
            BlatantBeta.UpdateSettings(nil, n)
        end
    end
})

-- ===============================
-- TOGGLE
-- ===============================
blatantbt:Toggle({
    Title = "Enable Ultra Blatant Fishing",
    Value = false,
    Callback = function(state)

        -- 🛑 MATIKAN MODE LAIN (ANTI TABRAKAN)
        if _G.NYXHUB.Modules["farm/autoclickAPI.lua"] then
            _G.NYXHUB.Modules["farm/autoclickAPI.lua"].Stop()
        end
        if _G.NYXHUB.Modules["farm/legitAPI.lua"] then
            _G.NYXHUB.Modules["farm/legitAPI.lua"].Stop()
        end
        if _G.NYXHUB.Modules["farm/legit1API.lua"] then
            _G.NYXHUB.Modules["farm/legit1API.lua"].Stop()
        end
        if _G.NYXHUB.Modules["farm/legit2API.lua"] then
            _G.NYXHUB.Modules["farm/legit2API.lua"].Stop()
        end
        if _G.NYXHUB.Modules["farm/blatantAPI.lua"] then
            _G.NYXHUB.Modules["farm/blatantAPI.lua"].Stop()
        end
        if _G.NYXHUB.Modules["farm/blatant2API.lua"] then
            _G.NYXHUB.Modules["farm/blatant2API.lua"].Stop()
        end
        if _G.NYXHUB.Modules["farm/blatant3API.lua"] then
            _G.NYXHUB.Modules["farm/blatant3API.lua"].Stop()
        end

        -- ▶️ ULTRA BLATANT CONTROL
        if state then
            BlatantBeta.Start()
            _G.NYXHUB.WindUI:Notify({
                Title = "Ultra Blatant ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            BlatantBeta.Stop()
            _G.NYXHUB.WindUI:Notify({
                Title = "Ultra Blatant OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})
blatantbt:Divider()
local blatantv1 = farm:Section({ Title = "Blatant V1" })

blatantv1:Input({
    Title = "Complete Delay",
    Placeholder = tostring(BlatantV1.Settings.CancelDelay),
    Default = tostring(BlatantV1.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV1.UpdateSettings(n, nil)
        end
    end
})

blatantv1:Input({
    Title = "Cancel Delay",
    Placeholder = tostring(BlatantV1.Settings.CancelDelay),
    Default = tostring(BlatantV1.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV1.UpdateSettings(nil, n)
        end
    end
})

blatantv1:Toggle({
    Title = "Ultra Blatant Fishing",
    Callback = function(state)
        if state then
            BlatantV1.Start()
            WindUI:Notify({
                Title = "Ultra Blatant ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            BlatantV1.Stop()
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
    Placeholder = tostring(BlatantV2.Settings.CompleteDelay),
    Default = tostring(BlatantV2.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV2.UpdateSettings(n, nil, nil)
        end
    end
})

blatantv2:Input({
    Title = "Cancel Delay",
    Placeholder = tostring(BlatantV2.Settings.CancelDelay),
    Default = tostring(BlatantV2.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV2.UpdateSettings(nil, n, nil)
        end
    end
})

--blatantv2:Input({
--    Title = "ReCast Delay",
--    Placeholder = tostring(BlatantV2.Settings.ReCastDelay),
--    Default = tostring(BlatantV2.Settings.ReCastDelay),
--    Callback = function(v)
--        local n = tonumber(v)
--        if n then
--            BlatantV2.UpdateSettings(nil, nil, n)
--        end
--    end
--})

blatantv2:Toggle({
    Title = "Ultra Blatant V2",
    Callback = function(state)
        if state then
            BlatantV2.Start()
            WindUI:Notify({
                Title = "Ultra Blatant V2 ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            BlatantV2.Stop()
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

-- =========================================================
-- STOP ALL FARM BUTTON (PANIC BUTTON)
-- =========================================================

farm:Button({
    Title = "🛑 STOP ALL FARMING",
    Callback = function()

        local mods = _G.NYXHUB.Modules

        -- AUTO / LEGIT
        if mods["farm/autoclickAPI.lua"] then mods["farm/autoclickAPI.lua"].Stop() end
        if mods["farm/legitAPI.lua"] then mods["farm/legitAPI.lua"].Stop() end
        if mods["farm/legit1API.lua"] then mods["farm/legit1API.lua"].Stop() end
        if mods["farm/legit2API.lua"] then mods["farm/legit2API.lua"].Stop() end

        -- BLATANT
        if mods["farm/blatantAPI.lua"] then mods["farm/blatantAPI.lua"].Stop() end
        if mods["farm/blatant1API.lua"] then mods["farm/blatant1API.lua"].Stop() end
        if mods["farm/blatant2API.lua"] then mods["farm/blatant2API.lua"].Stop() end
        if mods["farm/blatant3API.lua"] then mods["farm/blatant3API.lua"].Stop() end
        if mods["farm/blatantv1.lua"] then mods["farm/blatantv1.lua"].Stop() end

        -- AREA / SKIN (opsional tapi aman)
        if mods["farm/areapositionAPI.lua"] then
            mods["farm/areapositionAPI.lua"].SetFreeze(false)
        end
        if mods["farm/skinAnimationAPI.lua"] then
            mods["farm/skinAnimationAPI.lua"].Disable()
        end

        WindUI:Notify({
            Title = "ALL FARM STOPPED",
            Description = "Semua mode fishing dimatikan",
            Duration = 2.5,
            Icon = "alert-triangle"
        })
    end
})
