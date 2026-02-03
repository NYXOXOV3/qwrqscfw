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
local BlatantV4 = _G.NYXHUB.Modules["farm/blatant4API.lua"]
if not BlatantV4 then
    warn("[FarmTab] BlatantV4 API not loaded")
    return
end
local BlatantV5 = _G.NYXHUB.Modules["farm/blatant5API.lua"]
if not BlatantV5 then
    warn("[FarmTab] BlatantV5 API not loaded")
    return
end
--local BlatantV6 = _G.NYXHUB.Modules["farm/blatant6API.lua"]
--if not BlatantV6 then
--    warn("[FarmTab] BlatantV6 API not loaded")
--    return
--end
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
local legit1  = farm:Section({ Title = "Legit Fast" })

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
    Title = "Legit Fast",
    Callback = function(state)
        if state then
            Legit1API.Start()
        else
            Legit1API.Stop()
        end
    end
})
legit1:Divider()
local legit2 = farm:Section({ Title  = "Legit Perfect" })

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
    Title = "Legit Perfect",
    Callback = function(state)
        if state then
            PerfectAPI.Start()
        else
            PerfectAPI.Stop()
        end
    end
})
legit2:Divider()
local blatant = farm:Section({ Title = "Blatant Beta" })

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
    Placeholder = "0.05",
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
    Placeholder = "0.01",
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
    Placeholder = "0.01",
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
    Placeholder = "0.25",
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
    Placeholder = "0.8",
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

local blatantv4 = farm:Section ({Title = "Blatant Beta"})
blatantv4:Input({
    Title = "Charge Delay",
    Placeholder = tostring(BlatantV4.Settings.ChargeDelay),
    Default = tostring(BlatantV4.Settings.ChargeDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV4.UpdateSettings(n, nil, nil)
        end
    end
})

blatantv4:Input({
    Title = "Complete Delay",
    Placeholder = tostring(BlatantV4.Settings.CompleteDelay),
    Default = tostring(BlatantV4.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV4.UpdateSettings(nil, n, nil)
        end
    end
})

blatantv4:Input({
    Title = "Cancel Delay",
    Placeholder = tostring(BlatantV4.Settings.CancelDelay),
    Default = tostring(BlatantV4.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV4.UpdateSettings(nil, nil, n)
        end
    end
})

blatantv4:Toggle({
    Title = "Enable Blatant V4",
    Callback = function(state)
        if state then
            BlatantV4.Start()
            WindUI:Notify({
                Title = "Blatant V4 ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            BlatantV4.Stop()
            WindUI:Notify({
                Title = "Blatant V4 OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})

-- =========================================================
-- BLATANT V5 (AUTO PING TUNED)
-- =========================================================
local blatantv5 = farm:Section({ Title = "Blatant V5 Auto Tune" })

blatantv5:Input({
    Title = "Complete Delay",
    Placeholder = tostring(BlatantV5.Settings.CompleteDelay),
    Default = tostring(BlatantV5.Settings.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV5.UpdateSettings(n, nil)
        end
    end
})

blatantv5:Input({
    Title = "Cancel Delay",
    Placeholder = tostring(BlatantV5.Settings.CancelDelay),
    Default = tostring(BlatantV5.Settings.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BlatantV5.UpdateSettings(nil, n)
        end
    end
})

blatantv5:Toggle({
    Title = "Auto Tune Delay",
    Value = BlatantV5.Settings.AutoTune,
    Callback = function(v)
        BlatantV5.Settings.AutoTune = v
    end
})

-- INFO PING
local pingLabel = blatantv5:Paragraph({
    Title = "Ping: 0 ms"
})

task.spawn(function()
    while true do
        task.wait(1)

        if BlatantV5 and BlatantV5.Stats then
            local ping = math.floor((BlatantV5.Stats.ping or 0) * 1000)
            pingLabel:SetTitle("Ping: "..ping.." ms")
        end
    end
end)

-- TOGGLE
blatantv5:Toggle({
    Title = "Enable Blatant V5",
    Callback = function(state)
        if state then
            BlatantV5.Start()
            WindUI:Notify({
                Title = "Blatant V5 ON",
                Duration = 2,
                Icon = "zap"
            })
        else
            BlatantV5.Stop()
            WindUI:Notify({
                Title = "Blatant V5 OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})

blatantv5:Divider()

-- =========================================================
-- BLATANT V6 (Continuous Charging Fix) - FIXED VERSION
-- =========================================================
local blatantv6 = farm:Section({ Title = "Blatant V6 - Continuous" })

-- Load BlatantV6 API dengan error handling
local BlatantV6 = _G.NYXHUB.Modules["farm/blatant6API.lua"]
if BlatantV6 then
    -- Default values untuk safety
    local defaultSettings = {
        ChargeDelay = 0.2,
        RetryDelay = 0.05,
        MaxRetries = 3,
        CompleteDelay = 1.97,
        CancelDelay = 1.98
    }
    
    -- Fungsi untuk mendapatkan setting dengan fallback
    local function getSetting(key)
        if BlatantV6.Settings and BlatantV6.Settings[key] ~= nil then
            return BlatantV6.Settings[key]
        elseif BlatantV6.Config and BlatantV6.Config[key] ~= nil then
            return BlatantV6.Config[key]
        else
            return defaultSettings[key]
        end
    end
    
    -- Fungsi untuk update setting dengan safety
    local function updateSettings(charge, retry, maxRetries, complete, cancel)
        if BlatantV6.UpdateSettings then
            BlatantV6.UpdateSettings(charge, retry, maxRetries, complete, cancel)
        elseif BlatantV6.SetDelay then
            -- Fallback untuk API lama
            if complete then BlatantV6.SetDelay(nil, complete) end
            if cancel then BlatantV6.SetDelay(cancel, nil) end
        end
    end
    
    -- CHARGE DELAY
    blatantv6:Input({
        Title = "Charge Delay",
        Placeholder = tostring(getSetting("ChargeDelay")),
        Default = tostring(getSetting("ChargeDelay")),
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then
                updateSettings(n, nil, nil, nil, nil)
            end
        end
    })
    
    -- RETRY DELAY
    blatantv6:Input({
        Title = "Retry Delay",
        Placeholder = tostring(getSetting("RetryDelay")),
        Default = tostring(getSetting("RetryDelay")),
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then
                updateSettings(nil, n, nil, nil, nil)
            end
        end
    })
    
    -- MAX RETRIES
    blatantv6:Input({
        Title = "Max Retries",
        Placeholder = tostring(getSetting("MaxRetries")),
        Default = tostring(getSetting("MaxRetries")),
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 1 then
                updateSettings(nil, nil, n, nil, nil)
            end
        end
    })
    
    -- COMPLETE DELAY
    blatantv6:Input({
        Title = "Complete Delay",
        Placeholder = tostring(getSetting("CompleteDelay")),
        Default = tostring(getSetting("CompleteDelay")),
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then
                updateSettings(nil, nil, nil, n, nil)
            end
        end
    })
    
    -- CANCEL DELAY
    blatantv6:Input({
        Title = "Cancel Delay",
        Placeholder = tostring(getSetting("CancelDelay")),
        Default = tostring(getSetting("CancelDelay")),
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then
                updateSettings(nil, nil, nil, nil, n)
            end
        end
    })
    
    -- STATUS INDICATOR
    local statusLabel = blatantv6:Paragraph({
        Title = "Status: IDLE",
        Content = "Ready to start"
    })
    
    -- UPDATE STATUS THREAD dengan safety check
    task.spawn(function()
        while true do
            task.wait(0.5)
            if BlatantV6 then
                local status = "IDLE"
                local casts = 0
                local fish = 0
                
                -- Cek berbagai kemungkinan struktur stats
                if BlatantV6.Stats then
                    if BlatantV6.Stats.Active then
                        status = "RUNNING ⚡"
                    end
                    casts = BlatantV6.Stats.Casts or 0
                    fish = BlatantV6.Stats.FishCaught or 0
                elseif BlantantV6.Active then
                    status = BlatantV6.Active and "RUNNING ⚡" or "IDLE"
                end
                
                statusLabel:SetTitle("Status: " .. status)
                statusLabel:SetContent(string.format("Casts: %d | Fish: %d", casts, fish))
            end
        end
    end)
    
    -- TEST CHARGE BUTTON dengan safety check
    blatantv6:Button({
        Title = "Test Charge",
        Callback = function()
            local success = false
            if BlatantV6.TestCharge then
                success = BlatantV6.TestCharge()
            elseif BlatantV6.EnsureCharged then
                success = BlatantV6.EnsureCharged()
            else
                -- Fallback: coba panggil RF_Charge langsung
                success = pcall(function()
                    -- Anggap ada RF_Charge di global
                    if RF_Charge then
                        RF_Charge:InvokeServer(math.huge)
                        return true
                    end
                end)
            end
            
            WindUI:Notify({
                Title = "Charge Test",
                Description = success and "✅ Charged Successfully" or "❌ Failed to Charge",
                Duration = 2,
                Icon = success and "check" or "x"
            })
        end
    })
    
    -- MAIN TOGGLE dengan safety check
    blatantv6:Toggle({
        Title = "Enable Continuous Fishing",
        Callback = function(state)
            -- MATIKAN SEMUA API LAIN
            local mods = _G.NYXHUB.Modules
            local apiList = {
                "farm/autoclickAPI.lua",
                "farm/legitAPI.lua",
                "farm/legit1API.lua",
                "farm/legit2API.lua",
                "farm/blatantAPI.lua",
                "farm/blatant1API.lua",
                "farm/blatant2API.lua",
                "farm/blatant3API.lua",
                "farm/blatant4API.lua",
                "farm/blatant5API.lua",
                "farm/blatantv1.lua"
            }
            
            for _, apiName in ipairs(apiList) do
                if mods[apiName] and mods[apiName].Stop then
                    pcall(mods[apiName].Stop, mods[apiName])
                end
            end
            
            -- KONTROL BLATANT V6
            if state then
                if BlatantV6.Start then
                    BlatantV6.Start()
                    WindUI:Notify({
                        Title = "Blatant V6 ON",
                        Description = "Continuous charging enabled",
                        Duration = 2,
                        Icon = "zap"
                    })
                else
                    WindUI:Notify({
                        Title = "Error",
                        Description = "BlatantV6.Start() not found",
                        Duration = 2,
                        Icon = "x"
                    })
                end
            else
                if BlatantV6.Stop then
                    BlatantV6.Stop()
                    WindUI:Notify({
                        Title = "Blatant V6 OFF",
                        Duration = 2,
                        Icon = "x"
                    })
                end
            end
        end
    })
    
    -- RESET BUTTON dengan safety check
    blatantv6:Button({
        Title = "Reset Settings",
        Callback = function()
            if BlatantV6.ResetSettings then
                BlatantV6.ResetSettings()
                WindUI:Notify({
                    Title = "Settings Reset",
                    Description = "All settings restored to default",
                    Duration = 2,
                    Icon = "refresh-cw"
                })
            else
                WindUI:Notify({
                    Title = "Error",
                    Description = "Reset function not available",
                    Duration = 2,
                    Icon = "x"
                })
            end
        end
    })
    
else
    -- Jika BlatantV6 tidak ditemukan
    blatantv6:Paragraph({
        Title = "⚠️ BlatantV6 API not loaded",
        Content = "Make sure blatant6API.lua is in NYXHUB modules"
    })
    
    -- Atau buat BlatantV6 placeholder untuk testing
    warn("[FarmTab] BlatantV6 API not found, creating placeholder...")
    _G.NYXHUB.Modules["farm/blatant6API.lua"] = {
        Settings = {
            ChargeDelay = 0.2,
            RetryDelay = 0.05,
            MaxRetries = 3,
            CompleteDelay = 1.97,
            CancelDelay = 1.98
        },
        Stats = {
            Active = false,
            Casts = 0,
            FishCaught = 0
        },
        Start = function()
            warn("BlatantV6 placeholder: Start called")
        end,
        Stop = function()
            warn("BlatantV6 placeholder: Stop called")
        end
    }
end

blatantv6:Divider()

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
