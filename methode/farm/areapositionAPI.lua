-- =========================================================
-- AREA API (LOGIC ONLY)
-- =========================================================

local AreaAPI = {}

-- ================= DATA =================
AreaAPI.FishingAreas = {
    ["Ancient Jungle"] = {Pos = Vector3.new(1482.753784, 4.772020, -335.656494), Look = Vector3.new(0.505, 0, 0.863)},
    ["Ancient Ruin"] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, 0, -0.949)},
    ["Arrow Lever"] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, 0, 1)},
    ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0, 0.229)},
    ["Crater Island"] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0, 0.615)},
    ["Cresent Lever"] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0, 0, -1)},
    ["Crystal Depths"] = {Pos = Vector3.new(5860.520, -893.612, 15375.271), Look = Vector3.new(-0.3902, -0.9204, -0.0258)},
    ["Crystalline Passage"] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0, 0.994)},
    ["Diamond Lever"] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0, 0, -1)},
    ["Enchant Room"] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(0, 0, -1)},
    ["Esoteric Depths"] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(0, 0, -1)},
    ["Fisherman Island"] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(0, 0, -1)},
    ["Hourglass Diamond Lever"] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(0, 0, -1)},
    ["Iron Cavern"] = {Pos = Vector3.new(-8792.546, -588.000, 230.642), Look = Vector3.new(0.718, 0, 0.696)},
    ["Kohana"] = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, 0, 0.458)},
    ["Kohana Volcano"] = {Pos = Vector3.new(-546.899, 18.995, 142.474), Look = Vector3.new(-0.1536, -0.9485, 0.2771)},
    ["Lost Isle"] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, 0, 0.433)},
    ["Pirate Cove"] = {Pos = Vector3.new(3428.686, 4.193, 3432.854), Look = Vector3.new(0.2789, -0.3725, 0.8851)},
    ["Pirate Treasure Room"] = {Pos = Vector3.new(3301.503, -305.071, 3039.451), Look = Vector3.new(0.7264, -0.6726, 0.1413)},
    ["Sacred Temple"] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, 0, 0.143)},
    ["Second Enchant Altar"] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0, -0.955)},
    ["Sisyphus Statue"] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0, 0.951)},
    ["Treasure Room"] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0, -0.998)},
    ["Tropical Grove"] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, 0, 0.925)},
    ["Underground Cellar"] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0, 0.521)},
    ["Volcanic Cavern"] = {Pos = Vector3.new(1146.005, 74.569, -10232.295), Look = Vector3.new(0.1295, -0.9579, 0.2562)},
    ["Weather Machine"] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0, 0.999)},
}

AreaAPI.Selected = nil
AreaAPI.SavedPosition = nil
AreaAPI.Freeze = false

-- ================= HELPERS =================
local function getHRP()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

function AreaAPI.GetSortedNames()
    local t = {}
    for k in pairs(AreaAPI.FishingAreas) do
        table.insert(t, k)
    end
    table.sort(t, function(a,b)
        return a:lower() < b:lower()
    end)
    return t
end

function AreaAPI.Filter(keyword)
    local res = {}
    keyword = (keyword or ""):lower()
    for _, name in ipairs(AreaAPI.GetSortedNames()) do
        if keyword == "" or name:lower():find(keyword, 1, true) then
            table.insert(res, name)
        end
    end
    return res
end

function AreaAPI.Teleport(name)
    local data = AreaAPI.FishingAreas[name]
    if not data then return end
    local hrp = getHRP()
    hrp.CFrame = CFrame.new(data.Pos, data.Pos + data.Look) * CFrame.new(0, 0.5, 0)
end

function AreaAPI.SetFreeze(state)
    AreaAPI.Freeze = state
    local hrp = getHRP()
    hrp.Anchored = state
end

function AreaAPI.SaveCurrent()
    local hrp = getHRP()
    AreaAPI.SavedPosition = {
        Pos = hrp.Position,
        Look = hrp.CFrame.LookVector
    }
    AreaAPI.FishingAreas["Custom: Saved"] = AreaAPI.SavedPosition
end

function AreaAPI.TeleportSaved()
    if AreaAPI.SavedPosition then
        local d = AreaAPI.SavedPosition
        local hrp = getHRP()
        hrp.CFrame = CFrame.new(d.Pos, d.Pos + d.Look) * CFrame.new(0, 0.5, 0)
    end
end

return AreaAPI
