-- =========================================================
-- INSTANT FISHING v29.4 API
-- RAW LOGIC | NO MODIFICATION
-- =========================================================

local Legit1API = {}

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ================= NET =================
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

-- ================= SAFE CONFIG =================
local function safeGetConfig(key, default)
    if _G.GetConfigValue and type(_G.GetConfigValue) == "function" then
        local ok, value = pcall(function()
            return _G.GetConfigValue(key, default)
        end)
        if ok and value ~= nil then
            return value
        end
    end
    return default
end

local function loadConfigSettings()
    local maxWait = safeGetConfig("InstantFishing.FishingDelay", 1.30)
    local cancelDelay = safeGetConfig("InstantFishing.CancelDelay", 0.19)
    return maxWait, cancelDelay
end

local initialMaxWait, initialCancelDelay = loadConfigSettings()

-- ================= RAW MODULE =================
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Connections = {},
    Settings = {
        FishingDelay = 0.01,
        CancelDelay = initialCancelDelay,
        HookDetectionDelay = 0.05,
        RetryDelay = 0.1,
        MaxWaitTime = initialMaxWait,
    }
}

-- ================= INTERNAL =================
local function refreshSettings()
    fishing.Settings.MaxWaitTime =
        safeGetConfig("InstantFishing.FishingDelay", fishing.Settings.MaxWaitTime)
    fishing.Settings.CancelDelay =
        safeGetConfig("InstantFishing.CancelDelay", fishing.Settings.CancelDelay)
end

local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
            end
        end
    end)

    task.spawn(function()
        local rod = Character:FindFirstChild("Rod") or Character:FindFirstChildWhichIsA("Tool")
        if rod and rod:FindFirstChild("Handle") then
            local weld = rod.Handle:FindFirstChildOfClass("Weld")
                or rod.Handle:FindFirstChildOfClass("Motor6D")
            if weld then
                weld.C0 = CFrame.new(0, -1, -1.2)
                    * CFrame.Angles(math.rad(-10), 0, 0)
            end
        end
    end)
end

-- ================= RAW CAST =================
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1

    local ok = pcall(function()
        RF_ChargeFishingRod:InvokeServer({ [10] = tick() })
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true

        task.delay(fishing.Settings.MaxWaitTime * 0.7, function()
            if fishing.WaitingHook and fishing.Running then
                pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)
            end
        end)

        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)

                task.wait(fishing.Settings.RetryDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
    end)

    if not ok then
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end

-- ================= START / STOP =================
function fishing.Start()
    if fishing.Running then return end

    refreshSettings()
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0

    disableFishingAnim()

    fishing.Connections.Minigame =
        RE_MinigameChanged.OnClientEvent:Connect(function(state)
            if fishing.WaitingHook and typeof(state) == "string" then
                local s = state:lower()
                if s:find("hook") or s:find("bite") or s:find("catch") then
                    fishing.WaitingHook = false
                    task.wait(fishing.Settings.HookDetectionDelay)

                    pcall(RE_FishingCompleted.FireServer, RE_FishingCompleted)
                    task.wait(fishing.Settings.CancelDelay)
                    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)

                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then fishing.Cast() end
                end
            end
        end)

    fishing.Connections.Caught =
        RE_FishCaught.OnClientEvent:Connect(function()
            if fishing.Running then
                fishing.WaitingHook = false
                fishing.TotalFish += 1

                task.wait(fishing.Settings.CancelDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)

    fishing.Connections.Anim =
        task.spawn(function()
            while fishing.Running do
                disableFishingAnim()
                task.wait(0.15)
            end
        end)

    task.wait(0.5)
    fishing.Cast()
end

function fishing.Stop()
    if not fishing.Running then return end

    fishing.Running = false
    fishing.WaitingHook = false

    for _, c in pairs(fishing.Connections) do
        if typeof(c) == "RBXScriptConnection" then
            c:Disconnect()
        elseif typeof(c) == "thread" then
            task.cancel(c)
        end
    end

    fishing.Connections = {}

    pcall(RF_UpdateAutoFishingState.InvokeServer, RF_UpdateAutoFishingState)
    task.wait(0.2)
    pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
end

function fishing.UpdateSettings(maxWait, cancelDelay)
    if maxWait then fishing.Settings.MaxWaitTime = maxWait end
    if cancelDelay then fishing.Settings.CancelDelay = cancelDelay end
end

-- ================= PUBLIC API =================
function Legit1API.Start()
    if _G.FishingScriptFast then
        _G.FishingScriptFast.Stop()
        task.wait(0.1)
    end
    _G.FishingScriptFast = fishing
    fishing.Start()
end

function Legit1API.Stop()
    fishing.Stop()
end

function Legit1API.SetDelay(maxWait, cancelDelay)
    fishing.UpdateSettings(maxWait, cancelDelay)
end

return Legit1API
