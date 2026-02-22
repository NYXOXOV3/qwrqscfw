-- =========================================================
-- AUTO FISHING CLICKED FUNCTION (NORMAL INSTANT)
-- =========================================================

local LegitAPI = {}

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
local RF_Done   = Net["RF/Fez<;ICy6FIBF::Fg<"]
local RF_Cancel = Net["RF/Fet<8o oAkCC=vCBwLA"]
local RE_Equip  = Net["RE/EquipToolFromHotbar"]

-- ================= STATE =================
LegitAPI.Enabled = false
LegitAPI.Delay = 1.50
local loopThread
local equipThread

-- ================= CORE =================
function LegitAPI.Start()
    if LegitAPI.Enabled then return end
    LegitAPI.Enabled = true

    loopThread = task.spawn(function()
        while LegitAPI.Enabled do
            local ts = os.time() + os.clock()

            pcall(function()
                RF_Charge:InvokeServer(ts)
                RF_Start:InvokeServer(-57.994, 0.999)
            end)

            task.wait(LegitAPI.Delay)

            pcall(function() RF_Done:InvokeServer() end)
            pcall(function() RF_Cancel:InvokeServer() end)

        end
    end)

    equipThread = task.spawn(function()
        while LegitAPI.Enabled do
            pcall(function() RE_Equip:FireServer(1) end)
            task.wait(0.1)
        end
    end)
end

function LegitAPI.Stop()
    LegitAPI.Enabled = false
    if loopThread then task.cancel(loopThread) end
    if equipThread then task.cancel(equipThread) end
    loopThread, equipThread = nil, nil
end

function LegitAPI.SetDelay(v)
    LegitAPI.Delay = v
end

return LegitAPI
