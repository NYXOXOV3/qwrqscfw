-- =========================================================
-- NYXHUB SECURITY LOADER (GITHUB)
-- =========================================================

local Security = {}

if _G.__NYXHUB_SECURITY then
    return Security
end
_G.__NYXHUB_SECURITY = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local state = {
    Initialized = false,
}

function Security.Init()
    if state.Initialized then return end

    -- Lifecycle marker only
    LocalPlayer.CharacterAdded:Connect(function()
        if _G.NYXHUB and _G.NYXHUB.Flags then
            _G.NYXHUB.Flags.LastRespawn = os.time()
        end
    end)

    state.Initialized = true
    print("[NYXHUB][SECURITY] Initialized (GitHub)")
end

return Security
