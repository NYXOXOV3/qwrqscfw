-- =========================================================
-- AUTO SELL API (LOGIC ONLY, NO UI)
-- =========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local AutoSellAPI = {}

-- ================= CONFIG =================
AutoSellAPI.Method = "Delay" -- Delay | Count
AutoSellAPI.Value = 50
AutoSellAPI.Active = false
AutoSellAPI._thread = nil

-- ================= REMOTE =================
local RF_SellAllItems
do
    local net = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")

    RF_SellAllItems = net:FindFirstChild("RF/SellAllItems", true)
end

-- ================= HELPERS =================
local function getFishCount()
    local replion = _G.GetPlayerDataReplion and _G.GetPlayerDataReplion()
    if not replion then return 0 end

    local inv = replion:GetExpect("Inventory")
    if not inv or not inv.Items then return 0 end

    local total = 0
    for _, item in ipairs(inv.Items) do
        if item.Metadata and item.Metadata.Weight then
            total += (item.Count or 1)
        end
    end
    return total
end

-- ================= CORE LOOP =================
local function runLoop()
    if AutoSellAPI._thread then task.cancel(AutoSellAPI._thread) end

    AutoSellAPI._thread = task.spawn(function()
        while AutoSellAPI.Active do
            if AutoSellAPI.Method == "Delay" then
                if RF_SellAllItems then
                    pcall(function()
                        RF_SellAllItems:InvokeServer()
                    end)
                end
                task.wait(math.max(AutoSellAPI.Value, 1))

            elseif AutoSellAPI.Method == "Count" then
                local count = getFishCount()
                if count >= AutoSellAPI.Value then
                    if RF_SellAllItems then
                        pcall(function()
                            RF_SellAllItems:InvokeServer()
                        end)
                        task.wait(2)
                    end
                end
                task.wait(1)
            end
        end
    end)
end

-- ================= PUBLIC API =================
function AutoSellAPI.Start()
    if AutoSellAPI.Active then return end
    AutoSellAPI.Active = true
    runLoop()
end

function AutoSellAPI.Stop()
    AutoSellAPI.Active = false
    if AutoSellAPI._thread then
        task.cancel(AutoSellAPI._thread)
        AutoSellAPI._thread = nil
    end
end

function AutoSellAPI.SetMethod(method)
    if method == "Delay" or method == "Count" then
        AutoSellAPI.Method = method
        if AutoSellAPI.Active then
            runLoop()
        end
    end
end

function AutoSellAPI.SetValue(val)
    if tonumber(val) and tonumber(val) > 0 then
        AutoSellAPI.Value = tonumber(val)
    end
end

function AutoSellAPI.GetStatus()
    return {
        active = AutoSellAPI.Active,
        method = AutoSellAPI.Method,
        value = AutoSellAPI.Value,
    }
end

return AutoSellAPI
