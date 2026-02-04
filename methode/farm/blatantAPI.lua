-- =========================================================
-- AUTO FISHING BLATANT API (FIXED - NO FREEZE)
-- =========================================================

local BlatantAPI = {}
local RS = game:GetService("ReplicatedStorage")
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RF_Complete = Net["RF/CatchFishCompleted"]
local RE_Equip    = Net["RE/EquipToolFromHotbar"]
local RF_Cancel   = Net["RF/CancelFishingInputs"]
local RF_Update   = Net["RF/UpdateAutoFishingState"]

local FC = require(RS.Controllers.FishingController)
local originalClick  = FC.RequestFishingMinigameClick
local originalCharge = FC.RequestChargeFishingRod

local Config = {
    Active = false,
    Mode = "Old",
    CancelDelay = 0.90,
    CompleteDelay = 0.89,
    AutoPerfect = false,
}

local mainThread

-- 🔧 Equip CUKUP 1x sebelum mulai mancing (bukan loop terus!)
local function SafeEquipRod()
    pcall(function()
        RE_Equip:FireServer(1)  -- Equip slot 1
        task.wait(0.15)         -- Delay stabil setelah equip
    end)
end

-- 🔄 CLEAN restart tiap loop (INI KUNCI BIAR GA FREEZE)
local function DoFish_CLEAN()
    -- 1. Pastikan state sebelumnya dibersihkan
    pcall(RF_Cancel.InvokeServer, RF_Cancel)
    task.wait(0.05)
    
    -- 2. Equip rod (cukup 1x per cast)
    SafeEquipRod()
    
    -- 3. Mulai mancing
    task.spawn(function()
        pcall(function()
            local t = tick()
            RF_Charge:InvokeServer(math.huge)
            RF_Start:InvokeServer(-139.630, 0.996, t)
        end)
    end)
    
    -- 4. Tunggu lalu complete
    task.wait(Config.CompleteDelay)
    if Config.Active then
        pcall(RF_Complete.InvokeServer, RF_Complete)
    end
    
    -- 5. Delay antar cast (jangan terlalu cepat!)
    task.wait(math.max(0.1, Config.CancelDelay - Config.CompleteDelay))
end

local function FishingLoop_CLEAN()
    while Config.Active do
        DoFish_CLEAN()
        -- Optional: tambahkan jitter kecil biar lebih natural
        task.wait(math.random() * 0.03)
    end
end

-- ===== API =====
function BlatantAPI.Start()
    if Config.Active then return end
    Config.Active = true
    
    if mainThread then task.cancel(mainThread) end
    mainThread = task.spawn(FishingLoop_CLEAN)
end

function BlatantAPI.Stop()
    Config.Active = false
    if mainThread then
        task.cancel(mainThread)
        mainThread = nil
    end
    pcall(RF_Cancel.InvokeServer, RF_Cancel)
end

function BlatantAPI.SetMode(mode)
    Config.Mode = mode
end

function BlatantAPI.SetDelay(cancel, complete)
    if cancel then Config.CancelDelay = cancel end
    if complete then Config.CompleteDelay = complete end
end

return BlatantAPI
