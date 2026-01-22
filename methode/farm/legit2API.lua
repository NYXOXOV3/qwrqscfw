-- =========================================================
-- LEGIT2 API - ULTRA PERFECT CAST v35.2
-- RAW LOGIC | API WRAPPER ONLY
-- =========================================================

local Legit2API = {}

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ================= CLEAN OLD =================
if _G.FishingScript then
    _G.FishingScript.Stop()
    task.wait(0.1)
end

-- ================= NET =================
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

-- ================= SAFE CONFIG =================
local function safeGetConfig(key, default)
    if _G.GetConfigValue and type(_G.GetConfigValue) == "function" then
        local ok, val = pcall(function()
            return _G.GetConfigValue(key, default)
        end)
        if ok and val ~= nil then return val end
    end
    return default
end

local savedSettings = {
    MaxWaitTime = safeGetConfig("InstantFishing.FishingDelay", 1.5),
    CancelDelay = safeGetConfig("InstantFishing.CancelDelay", 0.19),
}

-- ================= RAW MODULE =================
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    PerfectCasts = 0,
    AmazingCasts = 0,
    FailedCasts = 0,
    Connections = {},
    Settings = {
        FishingDelay = 0.07,
        CancelDelay = savedSettings.CancelDelay,
        HookDetectionDelay = 0.03,
        RetryDelay = 0.04,
        MaxWaitTime = savedSettings.MaxWaitTime,
        FailTimeout = 2.5,
        PerfectChargeTime = 0.34,
        PerfectReleaseDelay = 0.005,
        PerfectPower = 0.95,
    }
}

_G.FishingScript = fishing

-- ================= INTERNAL =================
local function refreshSettings()
    fishing.Settings.MaxWaitTime =
        safeGetConfig("InstantFishing.FishingDelay", fishing.Settings.MaxWaitTime)
    fishing.Settings.CancelDelay =
        safeGetConfig("InstantFishing.CancelDelay", fishing.Settings.CancelDelay)
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
    fishing.WaitingHook = false
    fishing.FailedCasts += 1
    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
    task.wait(fishing.Settings.RetryDelay)
    if fishing.Running then fishing.PerfectCast() end
end

-- ================= RAW PERFECT CAST =================
function fishing.PerfectCast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1

    local ok = pcall(function()
        local startTime = tick()
        RF_ChargeFishingRod:InvokeServer({ [1] = startTime })

        local tEnd = tick() + fishing.Settings.PerfectChargeTime
        while tick() < tEnd and fishing.Running do
            task.wait(0.01)
        end

        task.wait(fishing.Settings.PerfectReleaseDelay)

        local res = RF_RequestMinigame:InvokeServer(
            fishing.Settings.PerfectPower,
            0,
            tick()
        )
        if not res then return handleFailedCast() end

        fishing.WaitingHook = true
        local detected = false
        local eventConn

        eventConn = RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" then
                local s = state:lower()
                if s:find("hook") or s:find("bite") or s:find("catch") or s == "!" then
                    detected = true
                    eventConn:Disconnect()
                    fishing.WaitingHook = false

                    task.wait(fishing.Settings.HookDetectionDelay)
                    pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)
                    task.wait(fishing.Settings.CancelDelay)
                    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then fishing.PerfectCast() end
                end
            end
        end)

        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running and not detected then
                eventConn:Disconnect()
                fishing.WaitingHook = false
                pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)
                task.wait(fishing.Settings.RetryDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
                if fishing.Running then fishing.PerfectCast() end
            end
        end)

        task.delay(fishing.Settings.FailTimeout, function()
            if fishing.WaitingHook and fishing.Running then
                if eventConn then eventConn:Disconnect() end
                handleFailedCast()
            end
        end)
    end)

    if not ok and fishing.Running then
        task.wait(fishing.Settings.RetryDelay)
        fishing.PerfectCast()
    end
end

-- ================= START / STOP =================
function fishing.Start()
    if fishing.Running then return end
    refreshSettings()
    fishing.Running = true
    disableFishingAnim()

    fishing.Connections.Stop =
        RE_FishingStopped.OnClientEvent:Connect(function()
            if fishing.Running and fishing.WaitingHook then
                handleFailedCast()
            end
        end)

    fishing.Connections.Catch =
        RE_FishCaught.OnClientEvent:Connect(function(_, data)
            if fishing.Running then
                fishing.WaitingHook = false
                fishing.TotalFish += 1
                task.wait(fishing.Settings.CancelDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
                if fishing.Running then fishing.PerfectCast() end
            end
        end)

    task.wait(0.3)
    fishing.PerfectCast()
end

function fishing.Stop()
    if not fishing.Running then return end
    fishing.Running = false
    fishing.WaitingHook = false

    for _, c in pairs(fishing.Connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif typeof(c) == "thread" then task.cancel(c) end
    end

    fishing.Connections = {}
    pcall(RF_UpdateAutoFishingState.InvokeServer, RF_UpdateAutoFishingState)
    task.wait(0.2)
    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
end

function fishing.UpdateSettings(maxWait, cancel)
    if maxWait then fishing.Settings.MaxWaitTime = maxWait end
    if cancel then fishing.Settings.CancelDelay = cancel end
end

-- ================= PUBLIC API =================
function Legit2API.Start()
    if _G.FishingScript and _G.FishingScript ~= fishing then
        _G.FishingScript.Stop()
        task.wait(0.1)
    end
    _G.FishingScript = fishing
    fishing.Start()
end

function Legit2API.Stop()
    fishing.Stop()
end

function Legit2API.SetDelay(maxWait, cancel)
    fishing.UpdateSettings(maxWait, cancel)
end

return Legit2API
