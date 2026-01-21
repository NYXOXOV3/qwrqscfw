-- =========================================================
-- MODES API
-- NYXHUB - Fish It
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

local ModesAPI = {}

-- ================= SERVICES =================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ================= HELPERS =================
local function GetHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- =========================================================
-- 1. INFINITE JUMP
-- =========================================================
local InfinityJumpConnection = nil

function ModesAPI.ToggleInfiniteJump(state)
    if state then
        if InfinityJumpConnection then return end

        InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
            local Humanoid = GetHumanoid()
            if Humanoid and Humanoid.Health > 0 then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfinityJumpConnection then
            InfinityJumpConnection:Disconnect()
            InfinityJumpConnection = nil
        end
    end
end

-- =========================================================
-- 2. NO CLIP
-- =========================================================
local noclipConnection = nil
local isNoClipActive = false

function ModesAPI.ToggleNoClip(state)
    isNoClipActive = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if state then
        if noclipConnection then return end

        noclipConnection = RunService.Stepped:Connect(function()
            if isNoClipActive and character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- =========================================================
-- 3. WALK ON WATER (RESPAWN SAFE)
-- =========================================================
local walkOnWaterConnection = nil
local isWalkOnWater = false
local waterPlatform = nil

function ModesAPI.ToggleWalkOnWater(state)
    if state then
        isWalkOnWater = true

        if not waterPlatform then
            waterPlatform = Instance.new("Part")
            waterPlatform.Name = "WaterPlatform"
            waterPlatform.Anchored = true
            waterPlatform.CanCollide = true
            waterPlatform.Transparency = 1
            waterPlatform.Size = Vector3.new(15, 1, 15)
            waterPlatform.Parent = workspace
        end

        if walkOnWaterConnection then
            walkOnWaterConnection:Disconnect()
        end

        walkOnWaterConnection = RunService.RenderStepped:Connect(function()
            local character = LocalPlayer.Character
            if not isWalkOnWater or not character then return end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if not waterPlatform or not waterPlatform.Parent then
                waterPlatform = Instance.new("Part")
                waterPlatform.Name = "WaterPlatform"
                waterPlatform.Anchored = true
                waterPlatform.CanCollide = true
                waterPlatform.Transparency = 1
                waterPlatform.Size = Vector3.new(15, 1, 15)
                waterPlatform.Parent = workspace
            end

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = { workspace.Terrain }
            rayParams.FilterType = Enum.RaycastFilterType.Include
            rayParams.IgnoreWater = false

            local rayOrigin = hrp.Position + Vector3.new(0, 5, 0)
            local rayDirection = Vector3.new(0, -500, 0)

            local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)

            if result and result.Material == Enum.Material.Water then
                local waterY = result.Position.Y
                waterPlatform.Position = Vector3.new(hrp.Position.X, waterY, hrp.Position.Z)

                if hrp.Position.Y < (waterY + 2) and hrp.Position.Y > (waterY - 5) then
                    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        hrp.CFrame = CFrame.new(hrp.Position.X, waterY + 3.2, hrp.Position.Z)
                    end
                end
            else
                waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
            end
        end)
    else
        isWalkOnWater = false

        if walkOnWaterConnection then
            walkOnWaterConnection:Disconnect()
            walkOnWaterConnection = nil
        end

        if waterPlatform then
            waterPlatform:Destroy()
            waterPlatform = nil
        end
    end
end

-- =========================================================
-- 4. INFINITE ZOOM
-- =========================================================
local ZoomState = false
local player = LocalPlayer

local function ApplyZoom()
    if not player then return end
    if ZoomState then
        player.CameraMaxZoomDistance = 1000
    else
        player.CameraMaxZoomDistance = 32
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.2)
    ApplyZoom()
end)

function ModesAPI.ToggleInfiniteZoom(state)
    ZoomState = state
    ApplyZoom()
end

-- =========================================================
-- 5. FREECAM (EXTERNAL MODULE)
-- =========================================================
local FreecamModule = nil

function ModesAPI.SetFreecamModule(module)
    FreecamModule = module
end

function ModesAPI.ToggleFreecam(state)
    if not FreecamModule then return end

    if state then
        FreecamModule.Start()
    else
        FreecamModule.Stop()
    end
end

function ModesAPI.IsFreecamActive()
    if not FreecamModule then return false end
    return FreecamModule.IsActive()
end

return ModesAPI
