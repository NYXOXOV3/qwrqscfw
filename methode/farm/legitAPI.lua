-- =========================================================
-- AUTO FISHING CLICKED FUNCTION (NORMAL INSTANT)
-- =========================================================

local LegitAPI = {}

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= REMOTES =================
local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_Charge = Net["RF/ChargeFishingRod"]
local RF_Start  = Net["RF/RequestFishingMinigameStarted"]
local RF_Done   = Net["RF/CatchFishCompleted"]
local RF_Cancel = Net["RF/CancelFishingInputs"]
local RE_Equip  = Net["RE/EquipToolFromHotbar"]

-- ================= STATE =================
LegitAPI.Enabled = false
LegitAPI.Delay = 1
local loopThread

-- ================= CORE =================
function LegitAPI.Start()
    if LegitAPI.Enabled then return end
    LegitAPI.Enabled = true

    loopThread = task.spawn(function()
        local equipped = false

        while LegitAPI.Enabled do
            -- 🔥 Equip hanya sekali di awal loop
            if not equipped then
                pcall(function()
                    RE_Equip:FireServer(1)
                end)
                equipped = true
                task.wait(0.1) -- kasih delay kecil biar tool ready
            end

            pcall(function()
                RF_Charge:InvokeServer(nil,nil,tick(),nil)
                RF_Start:InvokeServer(1, 0.9898571008228, tick())
            end)

            task.wait(LegitAPI.Delay)

            pcall(function() RF_Done:InvokeServer() end)
        end
    end)
end

function LegitAPI.Stop()
    LegitAPI.Enabled = false
    if loopThread then
        task.cancel(loopThread)
        loopThread = nil
    end
end

function LegitAPI.SetDelay(v)
    LegitAPI.Delay = v
end

return LegitAPI
