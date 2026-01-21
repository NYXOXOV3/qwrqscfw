-- =========================================================
-- NYXHUB SECURITY LOADER (RE-EXEC SAFE)
-- =========================================================

local Security = _G.__NYXHUB_SECURITY or {}
_G.__NYXHUB_SECURITY = Security

if Security._initialized then
    return Security
end
Security._initialized = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Security.Init()
    if Security._active then return end
    Security._active = true

    LocalPlayer.CharacterAdded:Connect(function()
        if _G.NYXHUB and _G.NYXHUB.Flags then
            _G.NYXHUB.Flags.LastRespawn = os.time()
        end
    end)

    print("[NYXHUB][SECURITY] Active (re-exec safe)")
end

return Security
