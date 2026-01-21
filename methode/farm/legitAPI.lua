-- =========================================================
-- LEGIT API - AUTO FISHING
-- NYXHUB - Fish It (3 Instant Modes)
-- =========================================================

local legitAPI = {}

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Hentikan script lama jika masih aktif
if _G.FishingScript then
    if _G.FishingScript.Stop then
        _G.FishingScript.Stop()
    end
    task.wait(0.1)
end

-- Inisialisasi koneksi network
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")
local RE_FishingStopped = netFolder:WaitForChild("RE/FishingStopped")

-- ⭐ Config Storage
local Config = {
    FishingDelay = 0.01,
    CancelDelay = 0.19,
    HookDetectionDelay = 0.05,
    RetryDelay = 0.1,
    MaxWaitTime = 1.30,
    Mode = "Instant V1", -- Default mode
}

-- Current fishing instance
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    PerfectCasts = 0,
    AmazingCasts = 0,
    FailedCasts = 0,
    Connections = {},
    Settings = Config
}

_G.FishingScript = fishing

-- ⭐ Function untuk update settings dari UI
function legitAPI.UpdateFishingSettings(fishingDelay, cancelDelay)
    if fishingDelay then
        Config.FishingDelay = fishingDelay
        fishing.Settings.FishingDelay = fishingDelay
    end
    if cancelDelay then
        Config.CancelDelay = cancelDelay
        fishing.Settings.CancelDelay = cancelDelay
    end
    return true
end

-- ⭐ Function untuk set fishing mode
function legitAPI.SetFishingMode(mode)
    if mode == "Instant V1" or mode == "Instant V2" or mode == "Instant X2" then
        Config.Mode = mode
        fishing.Settings.Mode = mode
        
        -- Apply default settings for each mode
        if mode == "Instant V1" then
            fishing.Settings.FishingDelay = 0.01
            fishing.Settings.CancelDelay = 0.19
            fishing.Settings.MaxWaitTime = 1.30
        elseif mode == "Instant V2" then
            fishing.Settings.FishingDelay = 0.07
            fishing.Settings.CancelDelay = 0.19
            fishing.Settings.MaxWaitTime = 1.50
            fishing.Settings.PerfectChargeTime = 0.34
            fishing.Settings.PerfectReleaseDelay = 0.005
            fishing.Settings.PerfectPower = 0.95
        elseif mode == "Instant X2" then
            fishing.Settings.FishingDelay = 0.30
            fishing.Settings.CancelDelay = 0.05
            fishing.Settings.MaxWaitTime = 1.10
        end
    end
    return mode
end

-- Nonaktifkan animasi
local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
            end
        end
    end)

    task.spawn(function()
        local rod = Character:FindFirstChild("Rod") or Character:FindFirstChildWhichIsA("Tool")
        if rod and rod:FindFirstChild("Handle") then
            local handle = rod.Handle
            local weld = handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("Motor6D")
            if weld then
                weld.C0 = CFrame.new(0, -1, -1.2) * CFrame.Angles(math.rad(-10), 0, 0)
            end
        end
    end)
end

-- =========================================================
-- INSTANT V1 - ULTRA SPEED AUTO FISHING v29.4
-- =========================================================
function fishing.CastV1()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1

    local castSuccess = pcall(function()
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true

        task.delay(fishing.Settings.MaxWaitTime * 0.7, function()
            if fishing.WaitingHook and fishing.Running then
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)
            end
        end)

        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)

                task.wait(fishing.Settings.RetryDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
    end)

    if not castSuccess then
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end

-- =========================================================
-- INSTANT V2 - ULTRA PERFECT CAST AUTO FISHING v35.2
-- =========================================================
local function handleFailedCast()
    fishing.WaitingHook = false
    fishing.FailedCasts += 1
    
    pcall(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    task.wait(fishing.Settings.RetryDelay)
    
    if fishing.Running then
        fishing.Cast()
    end
end

function fishing.CastV2()
    if not fishing.Running or fishing.WaitingHook then 
        return 
    end

    disableFishingAnim()
    fishing.CurrentCycle += 1

    local castSuccess = pcall(function()
        local startTime = tick()
        local chargeData = {[1] = startTime}
        
        local chargeResult = RF_ChargeFishingRod:InvokeServer(chargeData)
        if not chargeResult then 
            error("Charge fishing rod failed") 
        end

        local waitTime = fishing.Settings.PerfectChargeTime or 0.34
        local endTime = tick() + waitTime
        while tick() < endTime and fishing.Running do
            task.wait(0.01)
        end

        task.wait(fishing.Settings.PerfectReleaseDelay or 0.005)

        local releaseTime = tick()
        local perfectPower = fishing.Settings.PerfectPower or 0.95

        local minigameResult = RF_RequestMinigame:InvokeServer(
            perfectPower,
            0,
            releaseTime
        )
        
        if not minigameResult then 
            handleFailedCast()
            return
        end

        fishing.WaitingHook = true
        local hookDetected = false
        local castStartTime = tick()
        local eventDetection

        eventDetection = RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" then
                local s = state:lower()
                if s:find("hook") or s:find("bite") or s:find("catch") or s == "!" then
                    hookDetected = true
                    eventDetection:Disconnect()
                    
                    fishing.WaitingHook = false

                    task.wait(fishing.Settings.HookDetectionDelay)
                    pcall(function()
                        RE_FishingCompleted:FireServer()
                    end)

                    task.wait(fishing.Settings.CancelDelay)
                    pcall(function()
                        RF_CancelFishingInputs:InvokeServer()
                    end)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then
                        fishing.Cast()
                    end
                end
            end
        end)

        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                if not hookDetected then
                    fishing.WaitingHook = false
                    eventDetection:Disconnect()

                    pcall(function()
                        RE_FishingCompleted:FireServer()
                    end)

                    task.wait(fishing.Settings.RetryDelay)
                    pcall(function()
                        RF_CancelFishingInputs:InvokeServer()
                    end)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then
                        fishing.Cast()
                    end
                end
            end
        end)
        
        task.delay(fishing.Settings.FailTimeout or 2.5, function()
            if fishing.WaitingHook and fishing.Running then
                local elapsedTime = tick() - castStartTime
                
                if elapsedTime >= (fishing.Settings.FailTimeout or 2.5) then
                    if eventDetection then
                        eventDetection:Disconnect()
                    end
                    
                    handleFailedCast()
                end
            end
        end)
    end)

    if not castSuccess then
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end

-- =========================================================
-- INSTANT X2 - 2X SPEED AUTO FISHING
-- =========================================================
function fishing.CastX2()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(10, 0, tick())
        fishing.WaitingHook = true
        
        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

-- =========================================================
-- MAIN CAST FUNCTION (Router ke mode yang dipilih)
-- =========================================================
function fishing.Cast()
    if not fishing.Running then return end
    
    local mode = fishing.Settings.Mode or "Instant V1"
    
    if mode == "Instant V1" then
        fishing.CastV1()
    elseif mode == "Instant V2" then
        fishing.CastV2()
    elseif mode == "Instant X2" then
        fishing.CastX2()
    else
        fishing.CastV1() -- Fallback
    end
end

-- =========================================================
-- START FISHING
-- =========================================================
function fishing.Start()
    if fishing.Running then return end
    
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.PerfectCasts = 0
    fishing.AmazingCasts = 0
    fishing.FailedCasts = 0

    disableFishingAnim()

    -- Set up event connections based on mode
    local mode = fishing.Settings.Mode or "Instant V1"
    
    if mode == "Instant V1" then
        fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" then
                local s = string.lower(state)
                if string.find(s, "hook") or string.find(s, "bite") or string.find(s, "catch") then
                    fishing.WaitingHook = false
                    task.wait(fishing.Settings.HookDetectionDelay)

                    pcall(function()
                        RE_FishingCompleted:FireServer()
                    end)

                    task.wait(fishing.Settings.CancelDelay)
                    pcall(function()
                        RF_CancelFishingInputs:InvokeServer()
                    end)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then
                        fishing.Cast()
                    end
                end
            end
        end)

        fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(_, data)
            if fishing.Running then
                fishing.WaitingHook = false
                fishing.TotalFish += 1

                pcall(function()
                    task.wait(fishing.Settings.CancelDelay)
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
        
    elseif mode == "Instant V2" then
        fishing.Connections.FishingStopped = RE_FishingStopped.OnClientEvent:Connect(function()
            if fishing.Running and fishing.WaitingHook then
                handleFailedCast()
            end
        end)

        fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
            if fishing.Running then
                fishing.WaitingHook = false
                fishing.TotalFish += 1

                local castResult = data and data.CastResult or "Unknown"
                if castResult == "Perfect" then
                    fishing.PerfectCasts += 1
                elseif castResult == "Amazing" then
                    fishing.AmazingCasts += 1
                end

                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
        
    elseif mode == "Instant X2" then
        fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
                fishing.WaitingHook = false
                task.wait(0.30)
                RE_FishingCompleted:FireServer()
                
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)

        fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
            if fishing.Running then
                fishing.WaitingHook = false
                fishing.TotalFish = fishing.TotalFish + 1
                
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end

    -- Animation disabler untuk semua mode
    fishing.Connections.AnimDisabler = task.spawn(function()
        while fishing.Running do
            disableFishingAnim()
            task.wait(0.15)
        end
    end)

    task.wait(0.5)
    fishing.Cast()
end

-- =========================================================
-- STOP FISHING
-- =========================================================
function fishing.Stop()
    if not fishing.Running then return end
    fishing.Running = false
    fishing.WaitingHook = false

    for _, conn in pairs(fishing.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        elseif typeof(conn) == "thread" then
            task.cancel(conn)
        end
    end
    fishing.Connections = {}
    
    pcall(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    task.wait(0.2)
    
    pcall(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end

-- =========================================================
-- EXPORT FUNCTIONS
-- =========================================================
function legitAPI.GetFishingStatus()
    return {
        Running = fishing.Running,
        CurrentCycle = fishing.CurrentCycle,
        TotalFish = fishing.TotalFish,
        PerfectCasts = fishing.PerfectCasts,
        AmazingCasts = fishing.AmazingCasts,
        FailedCasts = fishing.FailedCasts,
        Settings = {
            Mode = fishing.Settings.Mode or "Instant V1",
            FishingDelay = fishing.Settings.FishingDelay,
            CancelDelay = fishing.Settings.CancelDelay,
            MaxWaitTime = fishing.Settings.MaxWaitTime
        }
    }
end

function legitAPI.ToggleFishing(state)
    if state then
        fishing.Start()
    else
        fishing.Stop()
    end
end

function legitAPI.GetAvailableModes()
    return {
        "Instant V1",
        "Instant V2", 
        "Instant X2"
    }
end

-- Export functions
legitAPI.StartFishing = fishing.Start
legitAPI.StopFishing = fishing.Stop
legitAPI.GetStatus = legitAPI.GetFishingStatus
legitAPI.SetMode = legitAPI.SetFishingMode

return legitAPI
