-- =========================================================
-- AUTO FISHING LEGIT FUNCTION
-- =========================================================

local AutoAPI = {}

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

local RE_Equip = Net["RE/Hu{BCWIu:ILDCuDFd9@"]
local RF_Update = Net["RF/Xtj:Ghz{Br >I6>@i+B;H7"]

-- ================= STATE =================
AutoAPI.Active = false
AutoAPI.ClickSpeed = 0.05
local clickThread
local equipThread

-- ================= CORE =================
function AutoAPI.Start()
    if AutoAPI.Active then return end
    AutoAPI.Active = true

    pcall(function()
        RE_Equip:FireServer(1)
        RF_Update:InvokeServer(true)
    end)

    clickThread = task.spawn(function()
        while AutoAPI.Active do
            FishingController:RequestFishingMinigameClick()
            task.wait(AutoAPI.ClickSpeed)
        end
    end)

    equipThread = task.spawn(function()
        while AutoAPI.Active do
            pcall(function() RE_Equip:FireServer(1) end)
            task.wait(0.1)
        end
    end)
end

function AutoAPI.Stop()
    AutoAPI.Active = false
    if clickThread then task.cancel(clickThread) end
    if equipThread then task.cancel(equipThread) end
    clickThread, equipThread = nil, nil
end

function AutoAPI.SetSpeed(v)
    AutoAPI.ClickSpeed = v
end

return AutoAPI
