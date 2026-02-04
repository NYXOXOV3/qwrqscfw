-- =========================================================
-- AUTO FISHING BLATANT API (RAW LOGIC - SINGLE MODE)
-- ⚠️ NO MODE | NO EQUIP | FULL BLIND LOOP
-- =========================================================

local BlatantAPI = {}

-- ================= SERVICES =================
local RS = game:GetService("ReplicatedStorage")

-- ================= NET =================
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RF_Complete = Net["RF/CatchFishCompleted"]
local RF_Cancel   = Net["RF/CancelFishingInputs"]
local RF_Update   = Net["RF/UpdateAutoFishingState"]

-- ================= CONTROLLER =================
local FC = require(RS.Controllers.FishingController)

-- ================= BACKUP ORIGINAL =================
local originalClick  = FC.RequestFishingMinigameClick
local originalCharge = FC.RequestChargeFishingRod

-- ================= CONFIG =================
local Config = {
    Active = false,
    CancelDelay = 0.90,
    CompleteDelay = 0.89,
}

local mainThread

-- ======================================================
-- 🔥 FORCE AUTO PERFECT (ALWAYS ON)
-- ======================================================
local function EnableAutoPerfect()
    FC.RequestFishingMinigameClick = function() end
    FC.RequestChargeFishingRod = function() end
end

local function DisableAutoPerfect()
    pcall(function()
        RF_Update:InvokeServer(false)
    end)

    FC.RequestFishingMinigameClick = originalClick
    FC.RequestChargeFishingRod = originalCharge
end

-- ======================================================
-- 🔥 RAW CORE (BLIND, NO TOOL SAFETY)
-- ======================================================
local function DoFish_RAW()
    task.spawn(function()
        pcall(function()
            local t = tick()
            RF_Cancel:InvokeServer()
            RF_Charge:InvokeServer(math.huge)
            RF_Start:InvokeServer(-139.630, 0.996, t)
        end)
    end)

    task.spawn(function()
        task.wait(Config.CompleteDelay)
        if Config.Active then
            pcall(RF_Complete.InvokeServer, RF_Complete)
        end
    end)
end

local function FishingLoop_RAW()
    while Config.Active do
        DoFish_RAW()
        task.wait(Config.CancelDelay)
    end
end

-- ======================================================
-- 🧠 PUBLIC API
-- ======================================================
function BlatantAPI.Start()
    if Config.Active then return end
    Config.Active = true

    EnableAutoPerfect()

    if mainThread then
        task.cancel(mainThread)
    end
    mainThread = task.spawn(FishingLoop_RAW)
end

function BlatantAPI.Stop()
    Config.Active = false

    if mainThread then
        task.cancel(mainThread)
        mainThread = nil
    end

    pcall(RF_Cancel.InvokeServer, RF_Cancel)
    DisableAutoPerfect()
end

function BlatantAPI.SetDelay(cancel, complete)
    if cancel then Config.CancelDelay = cancel end
    if complete then Config.CompleteDelay = complete end
end

return BlatantAPI
