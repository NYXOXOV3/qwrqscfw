-- =========================================================
-- INSTANT PERFECT CAST API
-- RAW LOGIC | WRAPPER ONLY
-- =========================================================

local InstantPerfectAPI = {}

-- ⚡ ULTRA PERFECT CAST AUTO FISHING v35.2 (RAW + BURN FIRST CAST)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- =========================================================
-- CLEAN OLD INSTANCE
-- =========================================================
if _G.FishingScript then
    _G.FishingScript.Stop()
    task.wait(0.1)
end

-- =========================================================
-- NET
-- =========================================================
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod      = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame       = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs   = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState= netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted      = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged       = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught            = netFolder:WaitForChild("RE/FishCaught")
local RE_FishingStopped        = netFolder:WaitForChild("RE/FishingStopped")

-- =========================================================
-- SAFE CONFIG
-- =========================================================
local function safeGetConfig(key, default)
    if _G.GetConfigValue and type(_G.GetConfigValue) == "function" then
        local ok, v = pcall(function()
            return _G.GetConfigValue(key, default)
        end)
        if ok and v ~= nil then
            return v
        end
    end
    return default
end

local InstantPerfectAPI = {
    Running = false,
    WaitingHook = false,
    BurnNextCast = false, -- 🔥 BURN FLAG
    CurrentCycle = 0,
    TotalFish = 0,
    PerfectCasts = 0,
    AmazingCasts = 0,
    FailedCasts = 0,
    Connections = {},
    Settings = {
        FishingDelay = 0.07,
        CancelDelay = safeGetConfig("InstantFishing.CancelDelay", 0.19),
        HookDetectionDelay = 0.03,
        RetryDelay = 0.04,
        MaxWaitTime = safeGetConfig("InstantFishing.FishingDelay", 1.5),
        FailTimeout = 2.5,
        PerfectChargeTime = 0.34,
        PerfectReleaseDelay = 0.005,
        PerfectPower = 0.95,
    }
}

_G.FishingScript = InstantPerfectAPI

-- =========================================================
-- INTERNAL HELPERS
-- =========================================================
local function refreshSettings()
    InstantPerfectAPI.Settings.MaxWaitTime =
        safeGetConfig("InstantFishing.FishingDelay", InstantPerfectAPI.Settings.MaxWaitTime)
    InstantPerfectAPI.Settings.CancelDelay =
        safeGetConfig("InstantFishing.CancelDelay", InstantPerfectAPI.Settings.CancelDelay)
end

local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local n = track.Name:lower()
            if n:find("fish") or n:find("rod") or n:find("cast") or n:find("reel") then
                track:Stop(0)
                track.TimePosition = 0
            end
        end
    end)
end

local function handleFailedCast()
    InstantPerfectAPI.WaitingHook = false
    InstantPerfectAPI.FailedCasts += 1
    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
    task.wait(InstantPerfectAPI.Settings.RetryDelay)
    if InstantPerfectAPI.Running then
        InstantPerfectAPI.PerfectCast()
    end
end

-- =========================================================
-- CORE CAST (RAW + BURN)
-- =========================================================
function InstantPerfectAPI.PerfectCast()
    if not InstantPerfectAPI.Running or InstantPerfectAPI.WaitingHook then
        return
    end

    -- 🔥 BURN FIRST CAST (DUMMY)
    if InstantPerfectAPI.BurnNextCast then
        InstantPerfectAPI.BurnNextCast = false
        return
    end

    disableFishingAnim()
    InstantPerfectAPI.CurrentCycle += 1

    local ok = pcall(function()
        local startTime = tick()
        RF_ChargeFishingRod:InvokeServer({[1] = startTime})

        local endTime = tick() + InstantPerfectAPI.Settings.PerfectChargeTime
        while tick() < endTime and InstantPerfectAPI.Running do
            task.wait(0.01)
        end

        task.wait(InstantPerfectAPI.Settings.PerfectReleaseDelay)

        local released = RF_RequestMinigame:InvokeServer(
            InstantPerfectAPI.Settings.PerfectPower,
            0,
            tick()
        )

        if not released then
            handleFailedCast()
            return
        end

        InstantPerfectAPI.WaitingHook = true
        local hookDetected = false
        local castStart = tick()

        local detectConn
        detectConn = RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" then
                local s = state:lower()
                if s:find("hook") or s:find("bite") or s:find("catch") or s == "!" then
                    hookDetected = true
                    detectConn:Disconnect()

                    InstantPerfectAPI.WaitingHook = false
                    InstantPerfectAPI.BurnNextCast = true -- 🔥 SET BURN

                    task.wait(InstantPerfectAPI.Settings.HookDetectionDelay)
                    pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)
                    task.wait(InstantPerfectAPI.Settings.CancelDelay)
                    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
                    task.wait(InstantPerfectAPI.Settings.FishingDelay)

                    if InstantPerfectAPI.Running then
                        InstantPerfectAPI.PerfectCast()
                    end
                end
            end
        end)

        task.delay(InstantPerfectAPI.Settings.MaxWaitTime, function()
            if InstantPerfectAPI.WaitingHook and InstantPerfectAPI.Running then
                InstantPerfectAPI.WaitingHook = false
                detectConn:Disconnect()
                InstantPerfectAPI.BurnNextCast = true -- 🔥 SET BURN

                pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)
                task.wait(InstantPerfectAPI.Settings.RetryDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
                task.wait(InstantPerfectAPI.Settings.FishingDelay)

                if InstantPerfectAPI.Running then
                    InstantPerfectAPI.PerfectCast()
                end
            end
        end)

        task.delay(InstantPerfectAPI.Settings.FailTimeout, function()
            if InstantPerfectAPI.WaitingHook and InstantPerfectAPI.Running then
                if tick() - castStart >= InstantPerfectAPI.Settings.FailTimeout then
                    detectConn:Disconnect()
                    handleFailedCast()
                end
            end
        end)
    end)

    if not ok then
        task.wait(InstantPerfectAPI.Settings.RetryDelay)
        if InstantPerfectAPI.Running then
            InstantPerfectAPI.PerfectCast()
        end
    end
end

-- =========================================================
-- START / STOP
-- =========================================================
function InstantPerfectAPI.Start()
    if InstantPerfectAPI.Running then return end
    refreshSettings()

    InstantPerfectAPI.Running = true
    InstantPerfectAPI.WaitingHook = false
    InstantPerfectAPI.BurnNextCast = false

    disableFishingAnim()

    InstantPerfectAPI.Connections.Caught =
        RE_FishCaught.OnClientEvent:Connect(function(_, data)
            if InstantPerfectAPI.Running then
                InstantPerfectAPI.WaitingHook = false
                InstantPerfectAPI.TotalFish += 1
                InstantPerfectAPI.BurnNextCast = true -- 🔥 SET BURN

                task.wait(InstantPerfectAPI.Settings.CancelDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
                task.wait(InstantPerfectAPI.Settings.FishingDelay)

                if InstantPerfectAPI.Running then
                    InstantPerfectAPI.PerfectCast()
                end
            end
        end)

    InstantPerfectAPI.Connections.Stopped =
        RE_FishingStopped.OnClientEvent:Connect(function()
            if InstantPerfectAPI.Running and InstantPerfectAPI.WaitingHook then
                handleFailedCast()
            end
        end)

    InstantPerfectAPI.Connections.Anim =
        task.spawn(function()
            while InstantPerfectAPI.Running do
                disableFishingAnim()
                task.wait(0.1)
            end
        end)

    task.wait(0.3)
    InstantPerfectAPI.PerfectCast()
end

function InstantPerfectAPI.Stop()
    if not InstantPerfectAPI.Running then return end
    InstantPerfectAPI.Running = false
    InstantPerfectAPI.WaitingHook = false

    for _, c in pairs(InstantPerfectAPI.Connections) do
        if typeof(c) == "RBXScriptConnection" then
            c:Disconnect()
        elseif typeof(c) == "thread" then
            task.cancel(c)
        end
    end

    fishing.Connections = {}
    pcall(RF_UpdateAutoFishingState.InvokeServer, RF_UpdateAutoFishingState)
    task.wait(0.2)
    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
end

return InstantPerfectAPI
