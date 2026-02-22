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

local RF_Charge = Net["RF/FlgK:h oAkCC= D6"]
local RF_Start = Net["RF/UiwN8vNL7vB>D5\";pA5;A7$B3Jx8>"]
--local RE_Done   = Net["RE/FishingCompleted"]
local RF_Done   = Net["RF/Fez<;ICy6FIBF::Fg<"]
local RF_Cancel = Net["RF/Fet<8o oAkCC=vCBwLA"]
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

            pcall(function() RF_Done:InvokeServer() end)
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
