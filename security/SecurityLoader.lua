-- =========================================================
-- NYXHUB SECURITY LOADER (RELOAD SAFE)
-- =========================================================

local Security = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local state = {
    Initialized = false
}

function Security.Init()
    if state.Initialized then
        return
    end

    -- Track respawn time only
    LocalPlayer.CharacterAdded:Connect(function()
        if _G.NYXHUB and _G.NYXHUB.Flags then
            _G.NYXHUB.Flags.LastRespawn = os.time()
        end
    end)

    state.Initialized = true
    print("[NYXHUB][SECURITY] Initialized")
end

return Security
