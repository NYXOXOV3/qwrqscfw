-- =========================================================
-- AUTO FISHING BLATANT API (RAW LOGIC 1:1) - NO EQUIP
-- ⚠️ NO PCALL | NO SAFETY | DO NOT OPTIMIZE
-- =========================================================

local BlatantAPI = {}

-- ================= SERVICES =================
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- ================= NET =================
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RF_Complete = Net["RF/CatchFishCompleted"]
local RF_Cancel   = Net["RF/CancelFishingInputs"]
local RF_Update   = Net["RF/UpdateAutoFishingState"]
local RE_Update   = Net["RE/UpdateChargeState"]

-- ================= CONTROLLER =================
local FC = require(RS.Controllers.FishingController)

-- ================= BACKUP ORIGINAL =================
local originalClick  = FC.RequestFishingMinigameClick
local originalCharge = FC.RequestChargeFishingRod

-- ================= RAW CONFIG =================
local Config = {
    Active = false,
    Mode = "New", -- Old / New
    CancelDelay = 0.94,
    CompleteDelay = 0.83,
    SpamCount = 7,
    AutoPerfect = false,
}

local mainThread

-- ======================================================
-- 🔥 AUTO PERFECT (RAW - NO PCALL)
-- ======================================================
local function LockController()
    if controllerLocked then return end
    controllerLocked = true

    RF_Cancel:InvokeServer()
    RF_Update:InvokeServer(true)
    task.wait(0.05)

    FC.RequestFishingMinigameClick = function() end
    FC.RequestChargeFishingRod     = function() end
end

local function RestoreController()
    if not controllerLocked then return end
    controllerLocked = false

    RF_Cancel:InvokeServer()
    RF_Update:InvokeServer(false)
    task.wait(0.05)

    FC.RequestFishingMinigameClick = originalClick
    FC.RequestChargeFishingRod     = originalCharge
end

-- ======================================================
-- 🔥 RAW CORE FISH (FULL BRUTAL)
-- ======================================================
local function DoFish_RAW()
    task.spawn(function()
        local t = tick()
        RF_Cancel:InvokeServer()
        RF_Charge:InvokeServer(math.huge)
        RF_Start:InvokeServer(-139.630, 0.996, t)
    end)

    task.spawn(function()
        task.wait(Config.CompleteDelay)
        if Config.Active then
            RF_Complete:InvokeServer()
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

    LockController()

    if mainThread then
        task.cancel(mainThread)
    end

    mainThread = task.spawn(FishingLoop_RAW)
end

function BlatantAPI.Stop()
    Config.Active = false
    RestoreController()
    if mainThread then
        task.cancel(mainThread)
        mainThread = nil
    end

    RF_Cancel:InvokeServer()

    FC.RequestFishingMinigameClick = originalClick
    FC.RequestChargeFishingRod = originalCharge
end

function BlatantAPI.SetMode(mode)
    Config.Mode = mode
    SyncAutoPerfect()
end

function BlatantAPI.SetDelay(cancel, complete)
    if cancel then Config.CancelDelay = cancel end
    if complete then Config.CompleteDelay = complete end
end

return BlatantAPI
