-- =========================================================
-- AUTO FISHING BLATANT API (RAW LOGIC 1:1) - FIXED VERSION
-- ⚠️ DO NOT OPTIMIZE | DO NOT CLEAN
-- =========================================================

local BlatantAPI = {}

-- ================= SERVICES =================
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ================= NET =================
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local RF_Charge   = Net["RF/ChargeFishingRod"]
local RF_Start    = Net["RF/RequestFishingMinigameStarted"]
local RF_Complete = Net["RF/CatchFishCompleted"]
local RE_Equip    = Net["RE/EquipToolFromHotbar"]
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
    Mode = "Old",        -- Old / New
    CancelDelay = 1.98,
    CompleteDelay = 1.97,
    AutoPerfect = false,
    
    -- FIX: Add new timing settings
    ChargeDelay = 0.1,    -- Delay after charging
    RetryDelay = 0.05,    -- Delay if failed
    MaxRetries = 3,       -- Max retry attempts
}

local mainThread
local equipThread
local chargeCheckThread

-- ======================================================
-- 🔥 CHARGE STATE CHECKER (NEW)
-- ======================================================
local function EnsureCharged()
    local player = Players.LocalPlayer
    local character = player and player.Character
    
    if not character then return false end
    
    -- Check if fishing tool is equipped
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool or not tool:IsA("Tool") then
        return false
    end
    
    -- Try to charge with retry mechanism
    for i = 1, Config.MaxRetries do
        pcall(function()
            RF_Charge:InvokeServer(math.huge)  -- Charge to max
        end)
        
        task.wait(Config.ChargeDelay)
        
        -- Verify charge by checking if we can start minigame
        local success = pcall(function()
            local t = tick()
            RF_Start:InvokeServer(-139.630, 0.996, t)
            return true
        end)
        
        if success then
            return true
        end
        
        task.wait(Config.RetryDelay)
    end
    
    return false
end

-- ======================================================
-- 🔥 CONTINUOUS CHARGE LOOP (KEEP ROD CHARGED)
-- ======================================================
local function ChargeLoop()
    while Config.Active do
        pcall(function()
            -- Continuously charge the rod
            RF_Charge:InvokeServer(math.huge)
        end)
        
        -- Also update charge state
        pcall(function()
            RE_Update:FireServer(true)  -- Keep charged state
        end)
        
        task.wait(0.2)  -- Charge every 0.2 seconds
    end
end

-- ======================================================
-- 🔥 AUTO PERFECT (RAW)
-- ======================================================
local function SyncAutoPerfect()
    local shouldEnable = Config.Active and Config.Mode == "New"

    if shouldEnable then
        if not Config.AutoPerfect then
            Config.AutoPerfect = true

            FC.RequestFishingMinigameClick = function() end
            FC.RequestChargeFishingRod = function() end
        end
    else
        if Config.AutoPerfect then
            Config.AutoPerfect = false

            pcall(function()
                RF_Update:InvokeServer(false)
            end)

            FC.RequestFishingMinigameClick = originalClick
            FC.RequestChargeFishingRod = originalCharge
        end
    end
end

-- ======================================================
-- 🔥 RAW CORE FISH WITH RETRY MECHANISM
-- ======================================================
local function DoFish_RAW()
    local t = tick()
    
    -- FIX: Always cancel first to reset state
    pcall(RF_Cancel.InvokeServer, RF_Cancel)
    
    -- FIX: Ensure rod is charged before starting
    local isCharged = EnsureCharged()
    
    if not isCharged then
        -- If not charged, try to equip fishing rod
        pcall(RE_Equip.FireServer, RE_Equip, 1)
        task.wait(0.2)
        
        -- Try charging again
        EnsureCharged()
    end
    
    -- Start fishing with retry
    for attempt = 1, Config.MaxRetries do
        local success = pcall(function()
            RF_Start:InvokeServer(-139.630, 0.996, t)
            return true
        end)
        
        if success then
            break
        end
        
        if attempt < Config.MaxRetries then
            task.wait(Config.RetryDelay)
        end
    end
    
    -- Complete fishing after delay
    task.wait(Config.CompleteDelay)
    
    if Config.Active then
        pcall(RF_Complete.InvokeServer, RF_Complete)
    end
end

-- ======================================================
-- 🔥 MAIN FISHING LOOP WITH CONTINUOUS CHARGING
-- ======================================================
local function FishingLoop_RAW()
    -- Start continuous charge loop
    chargeCheckThread = task.spawn(ChargeLoop)
    
    -- Equip fishing rod if needed
    equipThread = task.spawn(function()
        while Config.Active do
            pcall(RE_Equip.FireServer, RE_Equip, 1)
            task.wait(1.0)  -- Less frequent equip checks
        end
    end)
    
    -- Main fishing loop
    while Config.Active do
        DoFish_RAW()
        
        -- FIX: Cancel inputs before next cycle
        pcall(RF_Cancel.InvokeServer, RF_Cancel)
        
        -- Wait for next cycle
        task.wait(Config.CancelDelay)
    end
end

-- ======================================================
-- 🧠 PUBLIC API
-- ======================================================
function BlatantAPI.Start()
    if Config.Active then return end
    Config.Active = true
    
    print("[FishingAPI] Starting continuous fishing...")
    
    SyncAutoPerfect()
    
    -- Reset game auto fishing
    pcall(function()
        RF_Update:InvokeServer(false)
    end)
    
    if mainThread then task.cancel(mainThread) end
    mainThread = task.spawn(FishingLoop_RAW)
    
    print("[FishingAPI] Fishing started with continuous charging")
end

function BlatantAPI.Stop()
    if not Config.Active then return end
    
    Config.Active = false
    print("[FishingAPI] Stopping fishing...")
    
    -- Cancel all threads
    if mainThread then
        task.cancel(mainThread)
        mainThread = nil
    end

    if equipThread then
        task.cancel(equipThread)
        equipThread = nil
    end
    
    if chargeCheckThread then
        task.cancel(chargeCheckThread)
        chargeCheckThread = nil
    end
    
    -- Cancel inputs
    pcall(RF_Cancel.InvokeServer, RF_Cancel)
    
    -- Restore original functions
    FC.RequestFishingMinigameClick = originalClick
    FC.RequestChargeFishingRod = originalCharge
    
    -- Re-enable game auto fishing
    pcall(function()
        RF_Update:InvokeServer(true)
    end)
    
    print("[FishingAPI] Fishing stopped")
end

function BlatantAPI.SetMode(mode)
    Config.Mode = mode
    SyncAutoPerfect()
    print("[FishingAPI] Mode set to:", mode)
end

function BlatantAPI.SetDelay(cancel, complete)
    if cancel then 
        Config.CancelDelay = cancel 
        print("[FishingAPI] Cancel delay set to:", cancel)
    end
    if complete then 
        Config.CompleteDelay = complete 
        print("[FishingAPI] Complete delay set to:", complete)
    end
end

-- FIX: Add new function for testing
function BlatantAPI.TestCharge()
    local success = EnsureCharged()
    print("[FishingAPI] Charge test:", success and "SUCCESS" or "FAILED")
    return success
end

return BlatantAPI
