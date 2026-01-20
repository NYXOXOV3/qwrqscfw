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

-- Ambil InfoAPI
local InfoAPI = nil
do
    local ok, api = pcall(function()
        return _G.NYXHUB.Modules["info/infoAPI.lua"]
    end)
    if ok then InfoAPI = api end
end

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

    -- =====================================================
    -- DISCORD
    -- =====================================================

    home:Section({
        Title = "Join Discord Server NYXHUB",
        TextSize = 18,
    })

    home:Paragraph({
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

    home:Divider()

    -- =====================================================
    -- WHAT'S NEW
    -- =====================================================

    home:Section({
        Title = "What's New?",
        TextSize = 24,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    home:Image({
        Image = InfoAPI.Discord.Image,
        AspectRatio = "16:9",
        Radius = 9,
    })

    home:Space()

    home:Paragraph({
        Title = "Current Version",
        Desc  = InfoAPI:GetVersionString(),
    })

    home:Paragraph({
        Title = "Before Update",
        Desc  = InfoAPI:FormatList(InfoAPI.Changelog.BeforeUpdate, "[~] "),
    })

    home:Paragraph({
        Title = "Stable Update",
        Desc  = InfoAPI:FormatList(InfoAPI.Changelog.StableUpdate, "[+] "),
    })
end
