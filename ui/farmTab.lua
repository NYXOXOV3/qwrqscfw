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

-- Load fishing API
local FishingAPI
local function LoadFishingAPI()
    local success, result = pcall(function()
        return require(_G.NYXHUB.Modules["farm/legitAPI.lua"])
    end)
    
    if success then
        FishingAPI = result
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
        if FishingAPI then
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
        end
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
        if FishingAPI then
            FishingAPI.UpdateFishingSettings(value, nil)
            WindUI:Notify({
                Title = "Fishing Delay Updated",
                Content = "Set to " .. tostring(value) .. " seconds",
                Duration = 2,
                Icon = "timer",
            })
        end
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
        if FishingAPI then
            FishingAPI.UpdateFishingSettings(nil, value)
            WindUI:Notify({
                Title = "Cancel Delay Updated",
                Content = "Set to " .. tostring(value) .. " seconds",
                Duration = 2,
                Icon = "timer",
            })
        end
    end,
})

-- Start/Stop Button
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
        if FishingAPI then
            FishingAPI.StopFishing()
            fishingToggle:Set(false)
            
            WindUI:Notify({
                Title = "Fishing Stopped",
                Content = "Auto fishing has been stopped",
                Duration = 2,
                Icon = "stop",
            })
        end
    end
})

-- Detailed Stats Button
tab:Button({
    Title = "Detailed Stats",
    Icon = "bar-chart",
    Locked = false,
    Callback = function()
        if FishingAPI then
            local status = FishingAPI.GetStatus()
            local mode = modeDropdown:Get()
            
            local statsText = string.format(
                "Mode: %s\nFish Caught: %d\nCycles: %d\nPerfect Casts: %d\nAmazing Casts: %d\nFailed Casts: %d",
                mode,
                status.TotalFish,
                status.CurrentCycle,
                status.PerfectCasts,
                status.AmazingCasts,
                status.FailedCasts
            )
            
            WindUI:Notify({
                Title = "Fishing Statistics",
                Content = statsText,
                Duration = 5,
                Icon = "info",
            })
        end
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
                    "Fish: %d | Cycles: %d | Perfect: %d",
                    status.TotalFish,
                    status.CurrentCycle,
                    status.PerfectCasts
                )
                
                statusLabel:Set({
                    Title = statusText,
                    Desc = descText
                })
            end
        end
    end
end)

-- =========================
-- OTHER FARM FEATURES
-- =========================
tab:Section({
    Title = "Other Farm Features",
    TextSize = 18,
})

tab:Toggle({
    Title = "Auto Collect",
    Desc = "Automatically collect nearby items",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Auto Collect",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x",
        })
    end,
})

tab:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sell items",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Auto Sell",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x",
        })
    end,
})

warn("[NYXHUB][FarmTab] Loaded successfully")
