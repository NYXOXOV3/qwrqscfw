-- =========================================================
-- ULTRA BLATANT AUTO FISHING API (RAW LOGIC)
-- =========================================================

local UltraBlatant = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod      = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame       = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs  = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState= netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted     = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged      = netFolder:WaitForChild("RE/FishingMinigameChanged")

UltraBlatant.Active = false
UltraBlatant.Stats = {
    castCount = 0,
    startTime = 0
}

UltraBlatant.Settings = {
    CompleteDelay = 0.001,
    CancelDelay   = 0.001
}

------------------------------------------------------------
-- RAW INTERNAL
------------------------------------------------------------
local function safeFire(fn)
    task.spawn(function()
        pcall(fn)
    end)
end

local function ultraSpamLoop()
    while UltraBlatant.Active do
        local t = tick()

        safeFire(function()
            RF_ChargeFishingRod:InvokeServer({[1] = t})
        end)

        safeFire(function()
            RF_RequestMinigame:InvokeServer(1, 0, t)
        end)

        UltraBlatant.Stats.castCount += 1

        task.wait(UltraBlatant.Settings.CompleteDelay)

        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(UltraBlatant.Settings.CancelDelay)

        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

RE_MinigameChanged.OnClientEvent:Connect(function()
    if not UltraBlatant.Active then return end

    task.spawn(function()
        task.wait(UltraBlatant.Settings.CompleteDelay)
        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(UltraBlatant.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end)

------------------------------------------------------------
-- PUBLIC API
------------------------------------------------------------
function UltraBlatant.UpdateSettings(completeDelay, cancelDelay)
    if completeDelay ~= nil then
        UltraBlatant.Settings.CompleteDelay = completeDelay
    end
    if cancelDelay ~= nil then
        UltraBlatant.Settings.CancelDelay = cancelDelay
    end
end

function UltraBlatant.Start()
    if UltraBlatant.Active then return end

    UltraBlatant.Active = true
    UltraBlatant.Stats.castCount = 0
    UltraBlatant.Stats.startTime = tick()

    task.spawn(ultraSpamLoop)
end

function UltraBlatant.Stop()
    if not UltraBlatant.Active then return end

    UltraBlatant.Active = false

    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)

    task.wait(0.2)

    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end

return UltraBlatant
