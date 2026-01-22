-- =========================================================
-- AUTO FISHING BLATANT API (RAW LOGIC 1:1)
-- ⚠️ DO NOT OPTIMIZE | DO NOT CLEAN
-- =========================================================

local BlatantAPI = {}

-- ================= SERVICES =================
local RS = game:GetService("ReplicatedStorage")

-- ================= NET =================
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RE_Complete = Net["RE/FishingCompleted"]
local RE_Equip    = Net["RE/EquipToolFromHotbar"]
local RF_Cancel   = Net["RF/CancelFishingInputs"]
local RF_Update   = Net["RF/UpdateAutoFishingState"]

-- ================= CONTROLLER =================
local FC = require(RS.Controllers.FishingController)

-- ================= BACKUP ORIGINAL =================
local originalClick  = FC.RequestFishingMinigameClick
local originalCharge = FC.RequestChargeFishingRod

-- ================= RAW CONFIG =================
local Config = {
    Active = false,
    Mode = "Old",        -- Old / New
    CancelDelay = 1.75,
    CompleteDelay = 1.33,
    AutoPerfect = false,
}

local mainThread
local equipThread

-- ======================================================
-- 🔥 AUTO PERFECT (RAW)
-- ======================================================
local function SyncAutoPerfect()
    local shouldEnable = Config.Active and Config.Mode == "New"

    if shouldEnable and not Config.AutoPerfect then
        Config.AutoPerfect = true

        FC.RequestFishingMinigameClick = function() end
        FC.RequestChargeFishingRod = function() end

    elseif not shouldEnable and Config.AutoPerfect then
        Config.AutoPerfect = false

        pcall(function()
            RF_Update:InvokeServer(false)
        end)

        FC.RequestFishingMinigameClick = originalClick
        FC.RequestChargeFishingRod = originalCharge
    end
end

-- ======================================================
-- 🔥 RAW CORE FISH (NO SAFETY)
-- ======================================================
local function DoFish_RAW()
    task.spawn(function()
        pcall(function()
            RF_Cancel:InvokeServer()
            RF_Charge:InvokeServer(math.huge)
            RF_Start:InvokeServer(-139.6379699707, 0.99647927980797)
        end)
    end)

    task.spawn(function()
        task.wait(Config.CompleteDelay)
        if Config.Active then
            pcall(RE_Complete.FireServer, RE_Complete)
        end
    end)
end

local function FishingLoop_RAW()
    equipThread = task.spawn(function()
        while Config.Active do
            pcall(RE_Equip.FireServer, RE_Equip, 1)
            task.wait(0.1)
        end
    end)

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

    SyncAutoPerfect()

    if mainThread then task.cancel(mainThread) end
    mainThread = task.spawn(FishingLoop_RAW)
end

function BlatantAPI.Stop()
    Config.Active = false

    if mainThread then task.cancel(mainThread) end
    if equipThread then task.cancel(equipThread) end

    mainThread, equipThread = nil, nil

    pcall(function()
        RF_Cancel:InvokeServer()
    end)

    -- restore controller
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
