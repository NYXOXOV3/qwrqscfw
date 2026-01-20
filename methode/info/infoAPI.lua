-- =========================================================
-- INFO API
-- NYXHUB - Fish It
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

local InfoAPI = {}

-- =========================================================
-- STATIC DATA
-- =========================================================

InfoAPI.Discord = {
    Name   = "NYXHUB Community",
    Invite = "https://discord.gg/gW9jjJjH",
    Image  = "rbxassetid://137263312772667",
}

-- =========================================================
-- ACTIONS / HELPERS
-- =========================================================

function InfoAPI.CopyDiscord()
    if setclipboard then
        setclipboard(InfoAPI.Discord.Invite)
        return true
    end
    return false
end

return InfoAPI
