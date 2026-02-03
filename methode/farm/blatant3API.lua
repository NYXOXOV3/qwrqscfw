-- =========================================================
-- BLATANT V3 FIX API
-- RAW LOGIC WRAPPER ONLY (NO MODIFICATION)
-- =========================================================

local BlatantV3FixAPI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod     = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame      = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
--local RE_FishingCompleted    = netFolder:WaitForChild("RE/FishingCompleted")
local RF_FishingCompleted    = netFolder:WaitForChild("RF/CatchFishCompleted")
local RE_MinigameChanged     = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught          = netFolder:WaitForChild("RE/FishCaught")

-- ================= RAW STATE =================
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.05,
        CancelDelay = 0.01,
        HookWaitTime = 0.01,
        CastDelay = 0.25,
        TimeoutDelay = 0.8,
    },
}

_G.FishingScript = fishing

-- ================= EVENTS =================
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string"
        and string.find(string.lower(state), "hook") then

        fishing.WaitingHook = false

        task.spawn(function()
            task.wait(fishing.Settings.HookWaitTime)
            RF_FishingCompleted:FireServer()

            task.wait(fishing.Settings.CancelDelay)
            pcall(function()
                RF_CancelFishingInputs:InvokeServer()
            end)

            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then
                fishing.Cast()
            end
        end)
    end
end)

RE_FishCaught.OnClientEvent:Connect(function()
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish += 1

        task.spawn(function()
            task.wait(fishing.Settings.CancelDelay)
            pcall(function()
                RF_CancelFishingInputs:InvokeServer()
            end)

            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then
                fishing.Cast()
            end
        end)
    end
end)

-- ================= RAW CAST =================
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    fishing.CurrentCycle += 1

    task.spawn(function()
        pcall(function()
            RF_ChargeFishingRod:InvokeServer({ [10] = tick() })
            task.wait(fishing.Settings.CastDelay)
            RF_RequestMinigame:InvokeServer(10, 0, tick())

            fishing.WaitingHook = true

            task.delay(fishing.Settings.TimeoutDelay, function()
                if fishing.WaitingHook and fishing.Running then
                    fishing.WaitingHook = false
                    RF_FishingCompleted:FireServer()

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
        end)
    end)
end

-- ================= API =================
function BlatantV3FixAPI.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.Cast()
end

function BlatantV3FixAPI.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
end

function BlatantV3FixAPI.UpdateSettings(fd, cd, hwt, castd, timeout)
    if fd then fishing.Settings.FishingDelay = fd end
    if cd then fishing.Settings.CancelDelay = cd end
    if hwt then fishing.Settings.HookWaitTime = hwt end
    if castd then fishing.Settings.CastDelay = castd end
    if timeout then fishing.Settings.TimeoutDelay = timeout end
end

return BlatantV3FixAPI
