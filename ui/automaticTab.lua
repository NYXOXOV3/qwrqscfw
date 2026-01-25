-- =========================================================
-- NYXHUB AUTOMATIC TAB (AUTO SELL UI)
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then return end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI
local AutoSellAPI = _G.NYXHUB.Modules["automatic/autosellAPI.lua"]

if not AutoSellAPI then
    warn("[AutomaticTab] AutoSellAPI not found")
    return
end

local automatic = Window:Tab({
    Title = "Automatic",
    Icon = "loader",
})

local sellSec = automatic:Section({
    Title = "Auto Sell Fish"
})

-- ================= METHOD DROPDOWN =================
local valueInput

sellSec:Dropdown({
    Title = "Method",
    Values = { "Delay", "Count" },
    Value = "Delay",
    Callback = function(v)
        AutoSellAPI.SetMethod(v)

        if valueInput then
            if v == "Delay" then
                valueInput:SetTitle("Sell Delay (Seconds)")
                valueInput:SetPlaceholder("e.g. 50")
            else
                valueInput:SetTitle("Sell at Fish Count")
                valueInput:SetPlaceholder("e.g. 100")
            end
        end
    end
})

-- ================= VALUE INPUT =================
valueInput = sellSec:Input({
    Title = "Sell Delay (Seconds)",
    Placeholder = "50",
    Default = "50",
    Callback = function(v)
        AutoSellAPI.SetValue(v)
    end
})

sellSec:Divider()

-- ================= TOGGLE =================
sellSec:Toggle({
    Title = "Enable Auto Sell",
    Callback = function(state)
        if state then
            AutoSellAPI.Start()
            WindUI:Notify({
                Title = "Auto Sell ON",
                Content = AutoSellAPI.Method .. " : " .. tostring(AutoSellAPI.Value),
                Duration = 2,
                Icon = "check"
            })
        else
            AutoSellAPI.Stop()
            WindUI:Notify({
                Title = "Auto Sell OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})

