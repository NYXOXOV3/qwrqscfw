-- =========================================================
-- ULTRA BLATANT AUTO FISHING V3 (BURST 8 CAST)
-- RAW LOGIC API WRAPPER ONLY
-- =========================================================

local UltraBlatantV3 = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= NET =================
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod        = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame         = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs    = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted       = netFolder:WaitForChild("RE/FishingCompleted")

-- ================= STATE =================
UltraBlatantV3.Active = false

UltraBlatantV3.Settings = {
    BurstCount   = 8,     -- 🔥 BURST 8 CAST
    CastGap      = 0.002, -- jarak antar lempar
    CompleteDelay= 0.01,  -- delay sebelum complete
    CancelDelay  = 0.01,  -- delay sebelum cancel
    BurstDelay   = 0.12   -- delay antar burst
}

------------------------------------------------------------
-- CORE
------------------------------------------------------------
local function safeFire(fn)
    task.spawn(function()
        pcall(fn)
    end)
end

local function castOnce()
    local t = tick()

    safeFire(function()
        RF_ChargeFishingRod:InvokeServer({ [1] = t })
    end)

    safeFire(function()
        RF_RequestMinigame:InvokeServer(1, 0, t)
    end)
end

local function burstCast()
    -- 🔥 8x CAST CEPAT
    for i = 1, UltraBlatantV3.Settings.BurstCount do
        if not UltraBlatantV3.Active then return end
        castOnce()
        task.wait(UltraBlatantV3.Settings.CastGap)
    end

    -- COMPLETE
    task.wait(UltraBlatantV3.Settings.CompleteDelay)
    if UltraBlatantV3.Active then
        safeFire(function()
            RE_FishingCompleted:FireServer()
        end)
    end

    -- CANCEL
    task.wait(UltraBlatantV3.Settings.CancelDelay)
    if UltraBlatantV3.Active then
        safeFire(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end
end

local function mainLoop()
    while UltraBlatantV3.Active do
        burstCast()
        task.wait(UltraBlatantV3.Settings.BurstDelay)
    end
end

------------------------------------------------------------
-- PUBLIC API
------------------------------------------------------------
function UltraBlatantV3.UpdateSettings(burst, castGap, completeDelay, cancelDelay, burstDelay)
    if burst ~= nil then UltraBlatantV3.Settings.BurstCount = burst end
    if castGap ~= nil then UltraBlatantV3.Settings.CastGap = castGap end
    if completeDelay ~= nil then UltraBlatantV3.Settings.CompleteDelay = completeDelay end
    if cancelDelay ~= nil then UltraBlatantV3.Settings.CancelDelay = cancelDelay end
    if burstDelay ~= nil then UltraBlatantV3.Settings.BurstDelay = burstDelay end
end

function UltraBlatantV3.Start()
    if UltraBlatantV3.Active then return end
    UltraBlatantV3.Active = true

    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)

    task.wait(0.15)
    task.spawn(mainLoop)
end

function UltraBlatantV3.Stop()
    if not UltraBlatantV3.Active then return end
    UltraBlatantV3.Active = false

    safeFire(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)

    task.wait(0.1)

    safeFire(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end

return UltraBlatantV3
