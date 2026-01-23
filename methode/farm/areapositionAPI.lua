-- =========================================================
-- AREA POSITION API (RAW LOGIC WRAPPER)
-- =========================================================

local AreaAPI = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- =========================
-- DATA AREA (RAW)
-- =========================
AreaAPI.FishingAreas = {
    ["Ancient Jungle"] = {Pos = Vector3.new(1482.753784, 4.772020, -335.656494), Look = Vector3.new(0.505, 0, 0.863)},
    ["Ancient Ruin"] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, 0, -0.949)},
    ["Arrow Lever"] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, 0, 1)},
    ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0, 0.229)},
    ["Crater Island"] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0, 0.615)},
    ["Cresent Lever"] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0, 0, -1)},
    ["Crystalline Passage"] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0, 0.994)},
    ["Diamond Lever"] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0, 0, -1)},
    ["Enchant Room"] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(0, 0, -1)},
    ["Esoteric Depths"] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(0, 0, -1)},
    ["Fisherman Island"] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(0, 0, -1)},
    ["Iron Cavern"] = {Pos = Vector3.new(-8792.546, -588.000, 230.642), Look = Vector3.new(0.718, 0, 0.696)},
    ["Kohana"] = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, 0, 0.458)},
    ["Lost Isle"] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, 0, 0.433)},
}

AreaAPI.AreaNames = {}
for name in pairs(AreaAPI.FishingAreas) do
    table.insert(AreaAPI.AreaNames, name)
end

-- =========================
-- STATE
-- =========================
AreaAPI.SelectedArea = nil
AreaAPI.SavedPosition = nil
AreaAPI.FreezeActive = false

-- =========================
-- HELPERS (RAW)
-- =========================
local function GetHRP()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

function AreaAPI.TeleportToLookAt(pos, look)
    local hrp = GetHRP()
    hrp.CFrame = CFrame.new(pos, pos + look) * CFrame.new(0, 0.5, 0)
end

-- =========================
-- FREEZE LOGIC (RAW)
-- =========================
function AreaAPI.ToggleFreeze(state)
    AreaAPI.FreezeActive = state
    local hrp = GetHRP()
    if not hrp then return end

    if not state then
        hrp.Anchored = false
        return
    end

    local area = AreaAPI.FishingAreas[AreaAPI.SelectedArea]
        or AreaAPI.SavedPosition
    if not area then return end

    hrp.Anchored = false
    AreaAPI.TeleportToLookAt(area.Pos, area.Look)

    local start = os.clock()
    while os.clock() - start < 1.5 and AreaAPI.FreezeActive do
        hrp.Velocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(area.Pos, area.Pos + area.Look) * CFrame.new(0, 0.5, 0)
        RunService.Heartbeat:Wait()
    end

    if AreaAPI.FreezeActive then
        hrp.Anchored = true
    end
end

-- =========================
-- SAVE POS
-- =========================
function AreaAPI.SaveCurrent()
    local hrp = GetHRP()
    AreaAPI.SavedPosition = {
        Pos = hrp.Position,
        Look = hrp.CFrame.LookVector
    }
end

return AreaAPI
