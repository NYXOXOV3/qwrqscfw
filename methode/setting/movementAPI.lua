-- =========================================================
-- MOVEMENT API
-- NYXHUB - Fish It
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

local MovementAPI = {}

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- DEFAULTS
-- =========================
local DEFAULT_SPEED = 16
local DEFAULT_JUMP  = 50

-- =========================
-- HELPERS
-- =========================
local function GetHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- =========================
-- STATE
-- =========================
MovementAPI.State = {
    WalkSpeed = DEFAULT_SPEED,
    JumpPower = DEFAULT_JUMP,
}

-- =========================
-- SETTERS
-- =========================
function MovementAPI:SetWalkSpeed(value)
    local speedValue = tonumber(value)
    if speedValue and speedValue >= 0 then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = speedValue
            self.State.WalkSpeed = speedValue
        end
    end
end

function MovementAPI:SetJumpPower(value)
    local jumpValue = tonumber(value)
    if jumpValue and jumpValue >= 50 then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.JumpPower = jumpValue
            self.State.JumpPower = jumpValue
        end
    end
end

function MovementAPI:Reset()
    local Humanoid = GetHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = DEFAULT_SPEED
        Humanoid.JumpPower = DEFAULT_JUMP
        self.State.WalkSpeed = DEFAULT_SPEED
        self.State.JumpPower = DEFAULT_JUMP
    end
end

-- =========================
-- RESPAWN HANDLER
-- =========================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    local Humanoid = GetHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = MovementAPI.State.WalkSpeed
        Humanoid.JumpPower = MovementAPI.State.JumpPower
    end
end)

return MovementAPI
