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
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

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
-- 3. WALK ON WATER
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
            waterPlatform.Size = Vector3.new(15,1,15)
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

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = { workspace.Terrain }
            rayParams.FilterType = Enum.RaycastFilterType.Include
            rayParams.IgnoreWater = false

            local result = workspace:Raycast(
                hrp.Position + Vector3.new(0,5,0),
                Vector3.new(0,-500,0),
                rayParams
            )

            if result and result.Material == Enum.Material.Water then
                local y = result.Position.Y
                waterPlatform.Position = Vector3.new(hrp.Position.X, y, hrp.Position.Z)
                if hrp.Position.Y < y + 2 and hrp.Position.Y > y - 5 then
                    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        hrp.CFrame = CFrame.new(hrp.Position.X, y + 3.2, hrp.Position.Z)
                    end
                end
            else
                waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
            end
        end)
    else
        isWalkOnWater = false
        if walkOnWaterConnection then walkOnWaterConnection:Disconnect() end
        if waterPlatform then waterPlatform:Destroy() waterPlatform = nil end
    end
end

-- =========================================================
-- 4. INFINITE ZOOM
-- =========================================================
local ZoomState = false

local function ApplyZoom()
    if ZoomState then
        LocalPlayer.CameraMaxZoomDistance = 1000
    else
        LocalPlayer.CameraMaxZoomDistance = 32
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    ApplyZoom()
end)

function ModesAPI.ToggleInfiniteZoom(state)
    ZoomState = state
    ApplyZoom()
end

-- =========================================================
-- 5. FREECAM (EMBEDDED)
-- =========================================================

local freecam = false
local camPos = Vector3.new()
local camRot = Vector3.new()
local speed = 50
local sensitivity = 0.3
local hiddenGuis = {}

local renderConnection, inputBeganConnection, inputChangedConnection, inputEndedConnection

local function LockCharacter(state)
    local Humanoid = GetHumanoid()
    if not Humanoid then return end

    if state then
        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
        Humanoid.AutoRotate = false
        if Humanoid.RootPart then Humanoid.RootPart.Anchored = true end
    else
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        Humanoid.AutoRotate = true
        if Humanoid.RootPart then Humanoid.RootPart.Anchored = false end
    end
end

local function HideAllGuis()
    hiddenGuis = {}
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            table.insert(hiddenGuis, gui)
            gui.Enabled = false
        end
    end
end

local function ShowAllGuis()
    for _, gui in ipairs(hiddenGuis) do
        if gui then gui.Enabled = true end
    end
    hiddenGuis = {}
end

function ModesAPI.ToggleFreecam(state)
    if state then
        if freecam then return end
        freecam = true

        camPos = Camera.CFrame.Position
        local x,y,z = Camera.CFrame:ToEulerAnglesYXZ()
        camRot = Vector3.new(x,y,z)

        LockCharacter(true)
        HideAllGuis()
        Camera.CameraType = Enum.CameraType.Scriptable

        renderConnection = RunService.RenderStepped:Connect(function(dt)
            -- Mouse look
            local mouseDelta = UserInputService:GetMouseDelta()
            camRot = camRot + Vector3.new(
                -mouseDelta.Y * sensitivity * 0.01,
                -mouseDelta.X * sensitivity * 0.01,
                0
            )
        
            -- Clamp vertical look (biar ga kebalik)
            camRot = Vector3.new(
                math.clamp(camRot.X, -math.rad(89), math.rad(89)),
                camRot.Y,
                0
            )
        
            -- Input movement (6 axis)
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                move += Vector3.new(0, -1, 0)
            end
        
            -- Apply movement relative to camera
            if move.Magnitude > 0 then
                move = move.Unit
                local rotationCF = CFrame.fromEulerAnglesYXZ(camRot.X, camRot.Y, 0)
        
                camPos = camPos +
                    (rotationCF.LookVector * move.Z +
                     rotationCF.RightVector * move.X +
                     rotationCF.UpVector * move.Y) * speed * dt
            end
        
            Camera.CFrame = CFrame.new(camPos) * CFrame.fromEulerAnglesYXZ(camRot.X, camRot.Y, 0)
        end)
    else
        if not freecam then return end
        freecam = false

        if renderConnection then renderConnection:Disconnect() end
        renderConnection = nil

        LockCharacter(false)
        ShowAllGuis()
        Camera.CameraType = Enum.CameraType.Custom
    end
end

function ModesAPI.IsFreecamActive()
    return freecam
end

return ModesAPI
