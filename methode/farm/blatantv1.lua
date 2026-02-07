-- ======================================================
-- BLATANT BETA V1 (RAW BURST LOGIC API)
-- 7x CAST (SPAWN) → 1x COMPLETE
-- ======================================================

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

-- ================= CONTROLLER =================
local FC = require(RS.Controllers.FishingController)

local originalClick  = FC.RequestFishingMinigameClick
local originalCharge = FC.RequestChargeFishingRod

-- ================= MODULE =================
local BlatantBeta = {}

-- ================= CONFIG =================
BlatantBeta.Settings = {
    Active        = false,
    CastDelay     = 0.05,
    CompleteDelay = 0.88,
    SpamCount     = 7
}

-- ================= STATE =================
local busy = false
local controllerLocked = false

-- ======================================================
-- CONTROLLER LOCK
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
-- CORE RAW LOGIC (BURST MODE)
-- ======================================================
local function DoFishOnce()
    if busy or not BlatantBeta.Settings.Active then return end
    busy = true

    -- reset state
    RF_Cancel:InvokeServer()

    -- 🔥 BURST CHARGE + START
    for i = 1, BlatantBeta.Settings.SpamCount do
        if not BlatantBeta.Settings.Active then break end

        task.spawn(function()
            RF_Charge:InvokeServer(math.huge)
            RF_Start:InvokeServer(-1, 0, tick())
        end)

        task.wait(BlatantBeta.Settings.CastDelay)
    end

    -- ⏱ COMPLETE ONCE
    task.delay(BlatantBeta.Settings.CompleteDelay, function()
        if BlatantBeta.Settings.Active then
            RF_Complete:InvokeServer()
        end
        busy = false
    end)
end

-- ======================================================
-- MAIN LOOP
-- ======================================================
task.spawn(function()
    while true do
        if BlatantBeta.Settings.Active then
            DoFishOnce()
        end
        task.wait(0.01)
    end
end)

-- ======================================================
-- PUBLIC API (DIPANGGIL UI)
-- ======================================================
function BlatantBeta.UpdateSettings(castDelay, completeDelay, spamCount)
    if castDelay     ~= nil then BlatantBeta.Settings.CastDelay     = castDelay end
    if completeDelay ~= nil then BlatantBeta.Settings.CompleteDelay = completeDelay end
    if spamCount     ~= nil then BlatantBeta.Settings.SpamCount     = spamCount end
end

function BlatantBeta.Start()
    if BlatantBeta.Settings.Active then return end
    BlatantBeta.Settings.Active = true
    LockController()
end

function BlatantBeta.Stop()
    if not BlatantBeta.Settings.Active then return end
    BlatantBeta.Settings.Active = false
    RestoreController()
end

return BlatantBeta
