-- =========================================================
-- AUTO FISHING BLATANT FUNCTION (RAW BEHAVIOR)
-- SAME AS ORIGINAL SCRIPT, API STYLE
-- =========================================================

local BlatantAPI = {}

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= CONTROLLER =================
local FC = require(
    ReplicatedStorage:WaitForChild("Controllers").FishingController
)

-- ================= REMOTES =================
local Net = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"].net

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RE_Complete = Net["RE/FishingCompleted"]
local RE_Equip    = Net["RE/EquipToolFromHotbar"]
local RF_Cancel   = Net["RF/CancelFishingInputs"]
local RF_Update   = Net["RF/UpdateAutoFishingState"]

-- ================= BACKUP ORIGINAL =================
local originalClick  = FC.RequestFishingMinigameClick
local originalCharge = FC.RequestChargeFishingRod

-- ================= CONFIG =================
BlatantAPI.Config = {
    Active = false,
    CancelDelay   = 0.32,
    CompleteDelay = 0.18,
}

local mainThread
local equipThread
local updateThread

-- ================= CORE =================
function BlatantAPI.Start()
    if BlatantAPI.Config.Active then return end
    BlatantAPI.Config.Active = true

    -- 🔥 HARD BYPASS CLIENT FLOW (RAW)
    FC.RequestFishingMinigameClick = function() end
    FC.RequestChargeFishingRod = function() end

    -- 🔁 FORCE SERVER AUTO FISH MODE
    updateThread = task.spawn(function()
        while BlatantAPI.Config.Active do
            pcall(function()
                RF_Update:InvokeServer(true)
            end)
            task.wait(0.4)
        end
    end)

    -- 🎣 AUTO EQUIP SPAM
    equipThread = task.spawn(function()
        while BlatantAPI.Config.Active do
            pcall(RE_Equip.FireServer, RE_Equip, 1)
            task.wait(0.1)
        end
    end)

    -- ⚡ MAIN FISH LOOP (RAW SPEED)
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

    -- 🔄 RESTORE ORIGINAL FUNCTIONS
    FC.RequestFishingMinigameClick = originalClick
    FC.RequestChargeFishingRod = originalCharge

    if mainThread then task.cancel(mainThread) end
    if equipThread then task.cancel(equipThread) end
    if updateThread then task.cancel(updateThread) end

    mainThread, equipThread, updateThread = nil, nil, nil

    pcall(function()
        RF_Update:InvokeServer(false)
        RF_Cancel:InvokeServer()
    end)
end

function BlatantAPI.SetDelay(cancel, complete)
    if cancel then BlatantAPI.Config.CancelDelay = cancel end
    if complete then BlatantAPI.Config.CompleteDelay = complete end
end

return BlatantAPI
