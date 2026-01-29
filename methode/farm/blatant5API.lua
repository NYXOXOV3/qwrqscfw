-- ⚠️ ULTRA BLATANT AUTO FISHING - AUTO PING TUNED VERSION
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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

local BlatantV5 = {}
BlatantV5.Active = false

BlatantV5.Stats = {
    castCount = 0,
    startTime = 0,
    ping = 0
}

BlatantV5.Settings = {
    CompleteDelay = 0.01,
    CancelDelay = 0.01,
    AutoTune = true,
    TuneInterval = 3,
    MinDelay = 0.002,
    MaxDelay = 0.08
}

-------------------------------------------------
-- SAFE CALL
-------------------------------------------------
local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

-------------------------------------------------
-- PING CHECK
-------------------------------------------------
local function measurePing()
    local t0 = tick()

    pcall(function()
        RF_RequestMinigame:InvokeServer(1, 0, t0)
    end)

    local dt = tick() - t0
    return dt
end

-------------------------------------------------
-- AUTO TUNE LOOP
-------------------------------------------------
local function autoTuneLoop()
    while BlatantV5.Active and BlatantV5.Settings.AutoTune do
        local ping = measurePing()
        BlatantV5.Stats.ping = ping

        local newDelay = math.clamp(
            ping * 0.6,
            BlatantV5.Settings.MinDelay,
            BlatantV5.Settings.MaxDelay
        )

        BlatantV5.Settings.CompleteDelay = newDelay
        BlatantV5.Settings.CancelDelay = newDelay

        task.wait(BlatantV5.Settings.TuneInterval)
    end
end

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------
local function ultraSpamLoop()
    while BlatantV5.Active do
        local currentTime = tick()

        safeFire(function()
            RF_ChargeFishingRod:InvokeServer({[1] = currentTime})
        end)

        safeFire(function()
            RF_RequestMinigame:InvokeServer(1, 0, currentTime)
        end)

        BlatantV5.Stats.castCount += 1

        task.wait(BlatantV5.Settings.CompleteDelay)

        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(BlatantV5.Settings.CancelDelay)

        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

-------------------------------------------------
-- BACKUP LISTENER
-------------------------------------------------
RE_MinigameChanged.OnClientEvent:Connect(function()
    if not BlatantV5.Active then return end

    task.spawn(function()
        task.wait(BlatantV5.Settings.CompleteDelay)

        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(BlatantV5.Settings.CancelDelay)

        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end)

-------------------------------------------------
-- PUBLIC API
-------------------------------------------------
function BlatantV5.UpdateSettings(cd, cancel)
    if cd then
        BlatantV5.Settings.CompleteDelay = cd
    end

    if cancel then
        BlatantV5.Settings.CancelDelay = cancel
    end
end

function BlatantV5.Start()
    if BlatantV5.Active then return end

    BlatantV5.Active = true
    BlatantV5.Stats.castCount = 0
    BlatantV5.Stats.startTime = tick()

    task.spawn(ultraSpamLoop)
    task.spawn(autoTuneLoop)
end

function BlatantV5.Stop()
    if not BlatantV5.Active then return end

    BlatantV5.Active = false

    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)

    task.wait(0.2)

    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end

return BlatantV5
