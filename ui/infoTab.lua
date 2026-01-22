-- =========================================================
-- NYXHUB INFO TAB
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

if not _G.NYXHUB or not _G.NYXHUB.Window then
    warn("[NYXHUB][InfoTab] Window not found.")
    return
end

local Window = _G.NYXHUB.Window
local WindUI = _G.NYXHUB.WindUI

-- Ambil InfoAPI dari registry GitHub-loader
local InfoAPI = _G.NYXHUB.Modules["info/infoAPI.lua"]
if not InfoAPI then
    warn("[NYXHUB][InfoTab] InfoAPI not loaded.")
    return
end

-- =========================================================
-- INFO TAB (UI ONLY)
-- =========================================================
local home = Window:Tab({
    Title  = "Info",
    Icon   = "info",
    Locked = false,
})

home:Select()

-- =========================================================
-- DISCORD
-- =========================================================
local info = home:Section({ Title = "Join Discord Server NYXHUB"})

info:Paragraph({
    Title = InfoAPI.Discord.Name,
    Desc  = "Join our community Discord for updates, support, and discussion.",
    Image = InfoAPI.Discord.Image,
    ImageSize = 24,
    Buttons = {
        {
            Title = "Copy Link",
            Icon  = "link",
            Callback = function()
                if InfoAPI.CopyDiscord() then
                    WindUI:Notify({
                        Title = "Link Copied",
                        Content = "Discord invite copied to clipboard",
                        Duration = 3,
                        Icon = "copy",
                    })
                else
                    WindUI:Notify({
                        Title = "Failed",
                        Content = "Clipboard not supported by executor",
                        Duration = 3,
                        Icon = "x",
                    })
                end
            end,
        }
    }
})
info:Divider()
