-- =========================================================
-- BLATANT V4 AUTO FISHING (RAW API WRAPPER ONLY)
-- =========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local BlatantV4 = {}
BlatantV4.Active = false

BlatantV4.Settings = {
    ChargeDelay = 0.007,
    CompleteDelay = 0.001,
    CancelDelay = 0.001
}

local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

local function fishingLoop()
    while BlatantV4.Active do
        local startTime = tick()

        safeFire(function()
            RF_ChargeFishingRod:InvokeServer({[1] = startTime})
        end)

        task.wait(BlatantV4.Settings.ChargeDelay)

        safeFire(function()
            RF_RequestMinigame:InvokeServer(1, 0, tick())
        end)

        task.wait(BlatantV4.Settings.CompleteDelay)

        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(BlatantV4.Settings.CancelDelay)

        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

RE_MinigameChanged.OnClientEvent:Connect(function()
    if not BlatantV4.Active then return end

    task.spawn(function()
        task.wait(BlatantV4.Settings.CompleteDelay)

        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(BlatantV4.Settings.CancelDelay)

        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end)

-- ================= PUBLIC API =================

function BlatantV4.UpdateSettings(chargeDelay, completeDelay, cancelDelay)
    if chargeDelay ~= nil then
        BlatantV4.Settings.ChargeDelay = chargeDelay
    end
    if completeDelay ~= nil then
        BlatantV4.Settings.CompleteDelay = completeDelay
    end
    if cancelDelay ~= nil then
        BlatantV4.Settings.CancelDelay = cancelDelay
    end
end

function BlatantV4.Start()
    if BlatantV4.Active then return end
    BlatantV4.Active = true
    task.spawn(fishingLoop)
end

function BlatantV4.Stop()
    if not BlatantV4.Active then return end

    BlatantV4.Active = false

    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)

    task.wait(0.2)

    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end

return BlatantV4
