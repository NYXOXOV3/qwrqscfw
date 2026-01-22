-- =========================================================
-- AUTO FISHING LEGIT FUNCTION
-- =========================================================

local LegitAPI = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= CONTROLLERS =================
task.wait(0.2)
local FishingController = require(
    ReplicatedStorage:WaitForChild("Controllers").FishingController
)

-- ================= REMOTES =================
local Net = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"].net

local RE_Equip = Net["RE/EquipToolFromHotbar"]
local RF_Update = Net["RF/UpdateAutoFishingState"]

-- ================= STATE =================
LegitAPI.Active = false
LegitAPI.ClickSpeed = 0.05
local clickThread
local equipThread

-- ================= CORE =================
function LegitAPI.Start()
    if LegitAPI.Active then return end
    LegitAPI.Active = true

    pcall(function()
        RE_Equip:FireServer(1)
        RF_Update:InvokeServer(true)
    end)

    clickThread = task.spawn(function()
        while LegitAPI.Active do
            FishingController:RequestFishingMinigameClick()
            task.wait(LegitAPI.ClickSpeed)
        end
    end)

    equipThread = task.spawn(function()
        while LegitAPI.Active do
            pcall(function() RE_Equip:FireServer(1) end)
            task.wait(0.1)
        end
    end)
end

function LegitAPI.Stop()
    LegitAPI.Active = false
    if clickThread then task.cancel(clickThread) end
    if equipThread then task.cancel(equipThread) end
    clickThread, equipThread = nil, nil
end

function LegitAPI.SetSpeed(v)
    LegitAPI.ClickSpeed = v
end

return LegitAPI
