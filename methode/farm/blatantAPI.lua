-- =========================================================
-- AUTO FISHING BLATANT FUNCTION
-- =========================================================

local BlatantAPI = {}

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= REMOTES =================
local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RE_Complete = Net["RE/FishingCompleted"]
local RE_Equip    = Net["RE/EquipToolFromHotbar"]
local RF_Cancel   = Net["RF/CancelFishingInputs"]
local RF_Update   = Net["RF/UpdateAutoFishingState"]

-- ================= CONFIG =================
BlatantAPI.Config = {
    Active = false,
    Mode = "Old",
    CancelDelay = 1.75,
    CompleteDelay = 1.33,
}

local mainThread
local equipThread
local FC -- ⚠️ LAZY LOAD

-- ================= CORE =================
function BlatantAPI.Start()
    if BlatantAPI.Config.Active then return end
    BlatantAPI.Config.Active = true

    -- ✅ REQUIRE CONTROLLER DI SINI (AMAN)
    if not FC then
        FC = require(
            ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("FishingController")
        )
    end

    equipThread = task.spawn(function()
        while BlatantAPI.Config.Active do
            pcall(RE_Equip.FireServer, RE_Equip, 1)
            task.wait(0.1)
        end
    end)

    mainThread = task.spawn(function()
        while BlatantAPI.Config.Active do
            pcall(function()
                RF_Cancel:InvokeServer()
                RF_Charge:InvokeServer(math.huge)
                RF_Start:InvokeServer(-139.6379699707, 0.99647927980797)
            end)

            task.delay(BlatantAPI.Config.CompleteDelay, function()
                if BlatantAPI.Config.Active then
                    pcall(RE_Complete.FireServer, RE_Complete)
                end
            end)

            task.wait(BlatantAPI.Config.CancelDelay)
        end
    end)
end

function BlatantAPI.Stop()
    BlatantAPI.Config.Active = false
    if mainThread then task.cancel(mainThread) end
    if equipThread then task.cancel(equipThread) end
    mainThread, equipThread = nil, nil
    pcall(function() RF_Cancel:InvokeServer() end)
end

function BlatantAPI.SetMode(v)
    BlatantAPI.Config.Mode = v
end

function BlatantAPI.SetDelay(cancel, complete)
    if cancel then BlatantAPI.Config.CancelDelay = cancel end
    if complete then BlatantAPI.Config.CompleteDelay = complete end
end

return BlatantAPI
