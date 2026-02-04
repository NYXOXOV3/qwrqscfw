-- =========================================================
-- NYXHUB AUTOMATIC TAB (AUTO SELL - MODULE COMPAT)
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then return end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

-- ⬇️ AMBIL DARI MODULE LOADER (BENAR)
local AutoSell = _G.NYXHUB.Modules["automatic/autosellAPI.lua"]
if not AutoSell then
    warn("[AutomaticTab] autosellAPI.lua not loaded")
    return
end

local automatic = Window:Tab({
    Title = "Automatic",
    Icon = "loader",
})

local sellSec = automatic:Section({
    Title = "Auto Sell Fish"
})

-- =========================
-- UI STATE
-- =========================
local mode = "Delay"   -- Delay | Count
local value = 50
local running = false

-- =========================
-- METHOD
-- =========================
sellSec:Dropdown({
    Title = "Method",
    Values = { "Delay", "Count" },
    Value = "Delay",
    Callback = function(v)
        mode = v
        if v == "Delay" then
            valueInput:SetTitle("Sell Delay (Seconds)")
            valueInput:SetPlaceholder("e.g. 5")
        else
            valueInput:SetTitle("Sell at Fish Count")
            valueInput:SetPlaceholder("e.g. 200")
        end
    end
})

-- =========================
-- VALUE
-- =========================
valueInput = sellSec:Input({
    Title = "Sell Delay (Seconds)",
    Placeholder = "5",
    Default = "5",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then
            value = n
        end
    end
})

sellSec:Divider()

-- =========================
-- SELL ONCE
-- =========================
sellSec:Button({
    Title = "Sell Now",
    Callback = function()
        AutoSell.SellOnce()
        WindUI:Notify({
            Title = "Sell",
            Content = "Sell request sent",
            Duration = 1.5,
            Icon = "check"
        })
    end
})

sellSec:Divider()

-- =========================
-- AUTO SELL TOGGLE
-- =========================
sellSec:Toggle({
    Title = "Enable Auto Sell",
    Callback = function(state)
        if state then
            if running then return end
            running = true

            -- SAFETY: STOP BOTH
            AutoSell.Timer.Stop()
            AutoSell.Count.Stop()

            if mode == "Delay" then
                AutoSell.Timer.Start(value)
            else
                AutoSell.Count.Start(value)
            end

            WindUI:Notify({
                Title = "Auto Sell ON",
                Content = mode .. " : " .. tostring(value),
                Duration = 2,
                Icon = "check"
            })
        else
            running = false
            AutoSell.Timer.Stop()
            AutoSell.Count.Stop()

            WindUI:Notify({
                Title = "Auto Sell OFF",
                Duration = 2,
                Icon = "x"
            })
        end
    end
})
