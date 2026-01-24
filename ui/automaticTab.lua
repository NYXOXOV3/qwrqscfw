-- =========================================================
-- NYXHUB AUTOMATIC TAB
-- AUTO SELL SYSTEM UI
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then
    warn("[NYXHUB][AutomaticTab] Window not found.")
    return
end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

-- LOAD API
local AutoSell = _G.NYXHUB.Modules["automatic/autosellAPI.lua"] or _G.AutoSellSystem
if not AutoSell then
    warn("[NYXHUB][AutomaticTab] AutoSellSystem not loaded")
    return
end

-- TAB
local tab = Window:Tab({
    Title = "Automatic",
    Icon = "repeat"
})

-- =========================================================
-- AUTO SELL SECTION
-- =========================================================
local sellSec = tab:Section({
    Title = "Auto Sell"
})

-- ===============================
-- MANUAL SELL
-- ===============================
sellSec:Button({
    Title = "Sell All Now",
    Callback = function()
        local ok = AutoSell.SellOnce()
        WindUI:Notify({
            Title = ok and "Sell Executed" or "Sell Failed",
            Duration = 2,
            Icon = ok and "check" or "x"
        })
    end
})

sellSec:Divider()

-- ===============================
-- TIMER MODE
-- ===============================
sellSec:Input({
    Title = "Timer Interval (seconds)",
    Placeholder = "5",
    Default = "5",
    Callback = function(v)
        AutoSell.Timer.SetInterval(tonumber(v))
    end
})

sellSec:Toggle({
    Title = "Enable Auto Sell (Timer)",
    Callback = function(state)
        if state then
            AutoSell.Count.Stop() -- mutual exclusive
            AutoSell.Timer.Start()
        else
            AutoSell.Timer.Stop()
        end
    end
})

sellSec:Divider()

-- ===============================
-- COUNT MODE
-- ===============================
sellSec:Input({
    Title = "Sell When Bag >= (Count)",
    Placeholder = "235",
    Default = "235",
    Callback = function(v)
        AutoSell.Count.SetTarget(tonumber(v))
    end
})

sellSec:Toggle({
    Title = "Enable Auto Sell (By Count)",
    Callback = function(state)
        if state then
            AutoSell.Timer.Stop() -- mutual exclusive
            AutoSell.Count.Start()
        else
            AutoSell.Count.Stop()
        end
    end
})

sellSec:Divider()

-- ===============================
-- STATUS DISPLAY
-- ===============================
sellSec:Button({
    Title = "Check Auto Sell Status",
    Callback = function()
        local stats = AutoSell.GetStats()
        local timer = stats.timerStatus
        local count = stats.countStatus

        WindUI:Notify({
            Title = "Auto Sell Status",
            Duration = 4,
            Content = string.format(
                "Remote: %s\nTotal Sells: %d\n\nTimer: %s (%ds)\nCount: %s (%d/%d)",
                stats.remoteFound and "Found" or "Missing",
                stats.totalSells,
                timer.enabled and "ON" or "OFF",
                timer.interval,
                count.enabled and "ON" or "OFF",
                count.current,
                count.target
            ),
            Icon = "info"
        })
    end
})

-- =========================================================
-- STOP ALL AUTOMATIC
-- =========================================================
tab:Button({
    Title = "🛑 STOP ALL AUTOMATIC",
    Callback = function()
        AutoSell.Timer.Stop()
        AutoSell.Count.Stop()

        WindUI:Notify({
            Title = "Automatic Stopped",
            Content = "All auto sell modes disabled",
            Duration = 2.5,
            Icon = "alert-triangle"
        })
    end
})
