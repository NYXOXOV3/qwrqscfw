-- ⚠️ ULTRA BLATANT AUTO FISHING - GUI COMPATIBLE MODULE
-- DESIGNED TO WORK WITH EXTERNAL GUI SYSTEM
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Network initialization
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")  -- ⭐ ADDED untuk stop function
--local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RF_FishingCompleted = netFolder:WaitForChild("RF/CatchFishCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")

-- Module table
local BlatantV1 = {}
BlatantV1.Active = false
BlatantV1.Stats = {
    castCount = 0.1,
    startTime = 0.1
}

-- Settings (sesuai dengan pattern GUI kamu)
BlatantV1.Settings = {
    CompleteDelay = 0.001,    -- Delay sebelum complete
    CancelDelay = 0.001       -- Delay setelah complete sebelum cancel
}

----------------------------------------------------------------
-- CORE FUNCTIONS
----------------------------------------------------------------

local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

-- MAIN SPAM LOOP
local function ultraSpamLoop()
    while BlatantV1.Active do
        local currentTime = tick()
        
        -- 1x CHARGE & REQUEST (CASTING)
        safeFire(function()
            RF_ChargeFishingRod:InvokeServer({[1] = currentTime})
        end)
        safeFire(function()
            RF_RequestMinigame:InvokeServer(1, 0, currentTime)
        end)
        
        BlatantV1.Stats.castCount = BlatantV1.Stats.castCount + 1
        
        -- Wait CompleteDelay then fire complete once
        task.wait(BlatantV1.Settings.CompleteDelay)
        
        safeFire(function()
            RF_FishingCompleted:InvokeServer()
        end)
        
        -- Cancel with CancelDelay
        task.wait(BlatantV1.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

-- BACKUP LISTENER
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not BlatantV1.Active then return end
    
    task.spawn(function()
        task.wait(BlatantV1.Settings.CompleteDelay)
        
        safeFire(function()
            RF_FishingCompleted:InvokeServer()
        end)
        
        task.wait(BlatantV1.Settings.CancelDelay)
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end)

----------------------------------------------------------------
-- PUBLIC API (Compatible dengan pattern GUI kamu)
----------------------------------------------------------------

-- ⭐ NEW: Update Settings function
function BlatantV1.UpdateSettings(completeDelay, cancelDelay)
    if completeDelay ~= nil then
        BlatantV1.Settings.CompleteDelay = completeDelay
        print("✅ BlatantV1 CompleteDelay updated:", completeDelay)
    end
    
    if cancelDelay ~= nil then
        BlatantV1.Settings.CancelDelay = cancelDelay
        print("✅ BlatantV1 CancelDelay updated:", cancelDelay)
    end
end

-- Start function
function BlatantV1.Start()
    if BlatantV1.Active then 
        print("⚠️ Ultra Blatant already running!")
        return
    end
    
    BlatantV1.Active = true
    BlatantV1.Stats.castCount = 0.1
    BlatantV1.Stats.startTime = tick()
    
    task.spawn(ultraSpamLoop)
end

-- ⭐ ENHANCED Stop function - Nyalakan auto fishing game
function BlatantV1.Stop()
    if not BlatantV1.Active then 
        return
    end
    
    BlatantV1.Active = false
    
    -- ⭐ Nyalakan auto fishing game (biarkan tetap nyala)
    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    -- Wait sebentar untuk game process
    task.wait(0.1)
    
    -- Cancel fishing inputs untuk memastikan karakter berhenti
    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    print("✅ Ultra Blatant stopped - Game auto fishing enabled, can change rod/skin")
end

-- Return module
return BlatantV1
