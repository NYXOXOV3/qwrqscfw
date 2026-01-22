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
local FishingAPI
local function LoadFishingAPI()
    -- Coba ambil dari cache NYXHUB terlebih dahulu
    if _G.NYXHUB.Modules and _G.NYXHUB.Modules["farm/legitAPI.lua"] then
        FishingAPI = _G.NYXHUB.Modules["farm/legitAPI.lua"]
        return true
    end
    
    -- Jika tidak ada di cache, load dari source
    local success, result = pcall(function()
        -- Dapatkan ModuleScript dari ReplicatedStorage atau tempat lain
        local modulesFolder = _G.NYXHUB.ModulesFolder
        if modulesFolder then
            local moduleScript = modulesFolder:FindFirstChild("farm/legitAPI.lua") 
                             or modulesFolder:FindFirstChild("legitAPI")
            if moduleScript then
                return require(moduleScript)
            end
        end
        return nil
    end)
    
    if success and result then
        FishingAPI = result
        -- Simpan ke cache
        if _G.NYXHUB.Modules then
            _G.NYXHUB.Modules["farm/legitAPI.lua"] = result
        end
        return true
    else
        warn("[NYXHUB][FarmTab] Failed to load FishingAPI:", result)
        return false
    end
end

local tab = Window:Tab({
    Title = "Farm",
    Icon = "fish",
    Locked = false,
})

-- =========================
-- AUTO FISHING SECTION
-- =========================
tab:Section({
    Title = "Auto Fishing",
    TextSize = 20,
})

-- Mode Selection
local modeDropdown = tab:Dropdown({
    Title = "Fishing Mode",
    Desc = "Select fishing algorithm",
    Values = {"Instant V1", "Instant V2", "Instant X2"},
    Default = "Instant V1",
    Callback = function(value)
        if not FishingAPI and not LoadFishingAPI() then return end
        
        FishingAPI.SetMode(value)
        
        -- Update sliders based on mode
        local defaults = {
            ["Instant V1"] = {fishingDelay = 0.01, cancelDelay = 0.19},
            ["Instant V2"] = {fishingDelay = 0.07, cancelDelay = 0.19},
            ["Instant X2"] = {fishingDelay = 0.30, cancelDelay = 0.05}
        }
        
        local default = defaults[value]
        if default then
            FishingAPI.UpdateFishingSettings(default.fishingDelay, default.cancelDelay)
            if fishingDelaySlider then
                fishingDelaySlider:Set(default.fishingDelay)
            end
            if cancelDelaySlider then
                cancelDelaySlider:Set(default.cancelDelay)
            end
        end
        
        WindUI:Notify({
            Title = "Mode Changed",
            Content = value .. " activated",
            Duration = 2,
            Icon = "settings",
        })
    end,
})

-- Status Display
local statusLabel = tab:Paragraph({
    Title = "Status: Not Running",
    Desc = "Fish Caught: 0 | Cycles: 0"
})

-- Toggle Auto Fishing
local fishingToggle = tab:Toggle({
    Title = "Auto Fishing",
    Desc = "Automatically catch fish",
    Default = false,
    Callback = function(state)
        if not FishingAPI and not LoadFishingAPI() then
            WindUI:Notify({
                Title = "Error",
                Content = "Failed to load Fishing API",
                Duration = 3,
                Icon = "alert-triangle",
            })
            fishingToggle:Set(false)
            return
        end
        
        FishingAPI.ToggleFishing(state)
        
        WindUI:Notify({
            Title = "Auto Fishing",
            Content = state and "Started (" .. modeDropdown:Get() .. ")" or "Stopped",
            Duration = 2,
            Icon = state and "play" or "stop",
        })
    end,
})

-- Fishing Delay Slider
local fishingDelaySlider = tab:Slider({
    Title = "Fishing Delay",
    Step = 0.01,
    Desc = "Delay between fishing attempts",
    Value = {
        Min = 0.01,
        Max = 2.0,
        Default = 0.01,
    },
    Callback = function(value)
        if not FishingAPI and not LoadFishingAPI() then return end
        
        FishingAPI.UpdateFishingSettings(value, nil)
        WindUI:Notify({
            Title = "Fishing Delay Updated",
            Content = "Set to " .. tostring(value) .. " seconds",
            Duration = 2,
            Icon = "timer",
        })
    end,
})

-- Cancel Delay Slider
local cancelDelaySlider = tab:Slider({
    Title = "Cancel Delay",
    Step = 0.01,
    Desc = "Delay before canceling fishing",
    Value = {
        Min = 0.01,
        Max = 1.0,
        Default = 0.19,
    },
    Callback = function(value)
        if not FishingAPI and not LoadFishingAPI() then return end
        
        FishingAPI.UpdateFishingSettings(nil, value)
        WindUI:Notify({
            Title = "Cancel Delay Updated",
            Content = "Set to " .. tostring(value) .. " seconds",
            Duration = 2,
            Icon = "timer",
        })
    end,
})

-- Start Button
tab:Button({
    Title = "Start Fishing",
    Icon = "play",
    Locked = false,
    Callback = function()
        if not FishingAPI and not LoadFishingAPI() then
            WindUI:Notify({
                Title = "Error",
                Content = "Failed to load Fishing API",
                Duration = 3,
                Icon = "alert-triangle",
            })
            return
        end
        
        FishingAPI.StartFishing()
        fishingToggle:Set(true)
        
        WindUI:Notify({
            Title = "Fishing Started",
            Content = "Auto fishing is now active (" .. modeDropdown:Get() .. ")",
            Duration = 2,
            Icon = "play",
        })
    end
})

-- Stop Button
tab:Button({
    Title = "Stop Fishing",
    Icon = "stop",
    Locked = false,
    Callback = function()
        if not FishingAPI and not LoadFishingAPI() then
            WindUI:Notify({
                Title = "Error",
                Content = "Fishing API not loaded",
                Duration = 3,
                Icon = "alert-triangle",
            })
            return
        end
        
        FishingAPI.StopFishing()
        fishingToggle:Set(false)
        
        WindUI:Notify({
            Title = "Fishing Stopped",
            Content = "Auto fishing has been stopped",
            Duration = 2,
            Icon = "stop",
        })
    end
})

-- Get Status Button
tab:Button({
    Title = "Refresh Status",
    Icon = "refresh-cw",
    Locked = false,
    Callback = function()
        if not FishingAPI and not LoadFishingAPI() then
            WindUI:Notify({
                Title = "Error",
                Content = "Fishing API not loaded",
                Duration = 3,
                Icon = "alert-triangle",
            })
            return
        end
        
        local status = FishingAPI.GetStatus()
        statusLabel:Set({
            Title = "Status: " .. (status.Running and "Running" or "Stopped"),
            Desc = string.format("Fish Caught: %d | Cycles: %d", status.TotalFish, status.CurrentCycle)
        })
        
        WindUI:Notify({
            Title = "Status Updated",
            Content = string.format("Fish: %d | Cycles: %d", status.TotalFish, status.CurrentCycle),
            Duration = 2,
            Icon = "info",
        })
    end
})

-- =========================
-- MODE DESCRIPTIONS
-- =========================
tab:Section({
    Title = "Mode Descriptions",
    TextSize = 16,
})

tab:Paragraph({
    Title = "Instant V1",
    Desc = "Ultra Speed (v29.4) - Fastest mode"
})

tab:Paragraph({
    Title = "Instant V2", 
    Desc = "Perfect Cast (v35.2) - Better accuracy"
})

tab:Paragraph({
    Title = "Instant X2",
    Desc = "2X Speed - Balanced speed & safety"
})

-- =========================
-- SETTINGS SECTION
-- =========================
tab:Section({
    Title = "Settings",
    TextSize = 18,
})

-- Reset to Default Button
tab:Button({
    Title = "Reset to Default",
    Icon = "rotate-ccw",
    Locked = false,
    Callback = function()
        if not FishingAPI and not LoadFishingAPI() then return end
        
        local mode = modeDropdown:Get()
        local defaults = {
            ["Instant V1"] = {fishingDelay = 0.01, cancelDelay = 0.19},
            ["Instant V2"] = {fishingDelay = 0.07, cancelDelay = 0.19},
            ["Instant X2"] = {fishingDelay = 0.30, cancelDelay = 0.05}
        }
        
        local default = defaults[mode] or defaults["Instant V1"]
        FishingAPI.UpdateFishingSettings(default.fishingDelay, default.cancelDelay)
        fishingDelaySlider:Set(default.fishingDelay)
        cancelDelaySlider:Set(default.cancelDelay)
        
        WindUI:Notify({
            Title = "Settings Reset",
            Content = "All delays reset to default values",
            Duration = 2,
            Icon = "check",
        })
    end
})

-- Quick Presets
tab:Dropdown({
    Title = "Quick Presets",
    Desc = "Select a preset configuration",
    Values = {"Fast", "Safe", "Balanced", "Slow"},
    Default = "Balanced",
    Callback = function(value)
        if not FishingAPI and not LoadFishingAPI() then return end
        
        local presets = {
            Fast = {fishingDelay = 0.01, cancelDelay = 0.10},
            Safe = {fishingDelay = 0.05, cancelDelay = 0.25},
            Balanced = {fishingDelay = 0.01, cancelDelay = 0.19},
            Slow = {fishingDelay = 0.10, cancelDelay = 0.30}
        }
        
        local preset = presets[value]
        if preset then
            FishingAPI.UpdateFishingSettings(preset.fishingDelay, preset.cancelDelay)
            fishingDelaySlider:Set(preset.fishingDelay)
            cancelDelaySlider:Set(preset.cancelDelay)
            
            WindUI:Notify({
                Title = "Preset Applied",
                Content = value .. " preset loaded",
                Duration = 2,
                Icon = "settings",
            })
        end
    end,
})

-- =========================
-- AUTO UPDATE STATUS
-- =========================
task.spawn(function()
    while task.wait(2) do
        if FishingAPI then
            local status = FishingAPI.GetStatus()
            if status then
                local mode = modeDropdown:Get()
                local statusText = string.format(
                    "Status: %s | Mode: %s",
                    status.Running and "Running" or "Stopped",
                    mode
                )
                
                local descText = string.format(
                    "Fish: %d | Cycles: %d",
                    status.TotalFish,
                    status.CurrentCycle
                )
                
                statusLabel:Set({
                    Title = statusText,
                    Desc = descText
                })
            end
        end
    end
end)

warn("[NYXHUB][FarmTab] Loaded successfully")
