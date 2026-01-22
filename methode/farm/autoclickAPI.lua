-- =========================================================
-- AUTO FISHING CLICKED FUNCTION (NORMAL INSTANT)
-- =========================================================

local AutoClickAPI = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= REMOTES =================
local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_Charge = Net["RF/ChargeFishingRod"]
local RF_Start  = Net["RF/RequestFishingMinigameStarted"]
local RE_Done   = Net["RE/FishingCompleted"]
local RF_Cancel = Net["RF/CancelFishingInputs"]
local RE_Equip  = Net["RE/EquipToolFromHotbar"]

-- ================= STATE =================
AutoClickAPI.Enabled = false
AutoClickAPI.Delay = 1.50
local loopThread
local equipThread

-- ================= CORE =================
function AutoClickAPI.Start()
    if AutoClickAPI.Enabled then return end
    AutoClickAPI.Enabled = true

    loopThread = task.spawn(function()
        while AutoClickAPI.Enabled do
            local ts = os.time() + os.clock()

            pcall(function()
                RF_Charge:InvokeServer(ts)
                RF_Start:InvokeServer(-139.630452165, 0.99647927980797)
            end)

            task.wait(AutoClickAPI.Delay)

            pcall(function() RE_Done:FireServer() end)
            task.wait(0.3)
            pcall(function() RF_Cancel:InvokeServer() end)

            task.wait(0.1)
        end
    end)

    equipThread = task.spawn(function()
        while AutoClickAPI.Enabled do
            pcall(function() RE_Equip:FireServer(1) end)
            task.wait(0.1)
        end
    end)
end

function AutoClickAPI.Stop()
    AutoClickAPI.Enabled = false
    if loopThread then task.cancel(loopThread) end
    if equipThread then task.cancel(equipThread) end
    loopThread, equipThread = nil, nil
end

function AutoClickAPI.SetDelay(v)
    AutoClickAPI.Delay = v
end

return AutoClickAPI
