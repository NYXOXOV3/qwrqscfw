-- =========================================================
-- SKIN ANIMATION API (TRUE PERSISTENT OVERRIDE)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local SkinAPI = {}

-- ================= DATA =================
local SKINS = {
    -- ⛔ PASTE FULL SKINS LU DI SINI TANPA DIUBAH
    ["1x1x1x1BanHammer"] = {
        ["EquipIdle"] = {
            id = "rbxassetid://81302570422307",
            speed = 1.0,
            priority = Enum.AnimationPriority.Core,
            looped = true,
        },
        ["RodThrow"] = {
            id = "rbxassetid://123133988645038",
            speed = 1.5,
            priority = Enum.AnimationPriority.Action,
            looped = false,
        },
        ["FishCaught"] = {
            id = "rbxassetid://96285280763544",
            speed = 1.0,
            priority = Enum.AnimationPriority.Action4,
            looped = false,
        },
        ["ReelingIdle"] = {
            id = "rbxassetid://74643095451174",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["ReelStart"] = {
            id = "rbxassetid://74643095451174",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = false,
        },
        ["ReelIntermission"] = {
            id = "rbxassetid://74643095451174",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["StartRodCharge"] = {
            id = "rbxassetid://134431618143422",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
    },
    ["BinaryEdge"] = {
        ["EquipIdle"] = {
            id = "rbxassetid://103714544264522",
            speed = 1.0,
            priority = Enum.AnimationPriority.Core,
            looped = true,
        },
        ["RodThrow"] = {
            id = "rbxassetid://104527781253009",
            speed = 1.5,
            priority = Enum.AnimationPriority.Action,
            looped = false,
        },
        ["FishCaught"] = {
            id = "rbxassetid://109653945741202",
            speed = 1.0,
            priority = Enum.AnimationPriority.Action4,
            looped = false,
        },
        ["ReelingIdle"] = {
            id = "rbxassetid://81700883907369",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["ReelStart"] = {
            id = "rbxassetid://81700883907369",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = false,
        },
        ["ReelIntermission"] = {
            id = "rbxassetid://81700883907369",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["StartRodCharge"] = {
            id = "rbxassetid://72745361965091",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
    },
    ["Eclipse"] = {
        ["EquipIdle"] = {
            id = "rbxassetid://103641983335689",
            speed = 1.0,
            priority = Enum.AnimationPriority.Core,
            looped = true,
        },
        ["RodThrow"] = {
            id = "rbxassetid://82600073500966",
            speed = 1.4,
            priority = Enum.AnimationPriority.Action,
            looped = false,
        },
        ["FishCaught"] = {
            id = "rbxassetid://107940819382815",
            speed = 1.0,
            priority = Enum.AnimationPriority.Action4,
            looped = false,
        },
        ["ReelingIdle"] = {
            id = "rbxassetid://115229621326605",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["ReelStart"] = {
            id = "rbxassetid://115229621326605",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = false,
        },
        ["ReelIntermission"] = {
            id = "rbxassetid://115229621326605",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["StartRodCharge"] = {
            id = "rbxassetid://115229621326605",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
    },
    ["HolyTrident"] = {
        ["EquipIdle"] = {
            id = "rbxassetid://83219020397849",
            speed = 1.0,
            priority = Enum.AnimationPriority.Core,
            looped = true,
        },
        ["RodThrow"] = {
            id = "rbxassetid://114917462794864",
            speed = 1.3,
            priority = Enum.AnimationPriority.Action,
            looped = false,
        },
        ["FishCaught"] = {
            id = "rbxassetid://128167068291703",
            speed = 1.2,
            priority = Enum.AnimationPriority.Action4,
            looped = false,
        },
        ["ReelingIdle"] = {
            id = "rbxassetid://126831815839724",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["ReelStart"] = {
            id = "rbxassetid://126831815839724",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["ReelIntermission"] = {
            id = "rbxassetid://126831815839724",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["StartRodCharge"] = {
            id = "rbxassetid://83219020397849",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
    },
    ["SoulScythe"] = {
        ["EquipIdle"] = {
            id = "rbxassetid://84686809448947",
            speed = 1.0,
            priority = Enum.AnimationPriority.Core,
            looped = true,
        },
        ["RodThrow"] = {
            id = "rbxassetid://104946400643250",
            speed = 1.0,
            priority = Enum.AnimationPriority.Action,
            looped = false,
        },
        ["FishCaught"] = {
            id = "rbxassetid://82259219343456",
            speed = 1.2,
            priority = Enum.AnimationPriority.Action4,
            looped = false,
        },
        ["ReelingIdle"] = {
            id = "rbxassetid://95453600470089",
            speed = 1.0,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["ReelStart"] = {
            id = "rbxassetid://137684649541594",
            speed = 1.2,
            priority = Enum.AnimationPriority.Idle,
            looped = false,
        },
        ["ReelIntermission"] = {
            id = "rbxassetid://139621583239992",
            speed = 1.2,
            priority = Enum.AnimationPriority.Idle,
            looped = true,
        },
        ["StartRodCharge"] = {
            id = "rbxassetid://117668204114399",
            speed = 1.4,
            priority = Enum.AnimationPriority.Idle,
            looped = false,
        },
    },
}

local ANIM_ID_MAP = {
    ["96586569072385"] = "EquipIdle",
    ["139622307103608"] = "StartRodCharge",
    ["92624107165273"] = "RodThrow",
    ["136614469321844"] = "ReelStart",
    ["134965425664034"] = "ReelingIdle",
    ["114959536562596"] = "ReelIntermission",
    ["117319000848286"] = "FishCaught",
}

-- ================= STATE =================
local enabled = false
local currentSkin = "Eclipse"
local connections = {}
local preloaded = {}

-- ================= UTILS =================
local function getHumanoid()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getAnimator()
    local h = getHumanoid()
    return h and h:FindFirstChildOfClass("Animator")
end

local function getAnimType(id)
    local n = id:match("(%d+)")
    return n and ANIM_ID_MAP[n]
end

local function clearPreload()
    for _, d in pairs(preloaded) do
        pcall(function()
            d.track:Stop()
            d.anim:Destroy()
        end)
    end
    preloaded = {}
end

-- ================= CORE =================
local function preload()
    clearPreload()
    local hum = getHumanoid()
    if not hum then return end

    for name, cfg in pairs(SKINS[currentSkin]) do
        local anim = Instance.new("Animation")
        anim.AnimationId = cfg.id

        local ok, track = pcall(function()
            return hum:LoadAnimation(anim)
        end)

        if ok and track then
            track.Priority = cfg.priority
            track.Looped = cfg.looped
            preloaded[name] = { track = track, cfg = cfg }
        end
    end
end

local function forceReplace(originalTrack)
    if not enabled then return end
    if not originalTrack or not originalTrack.Animation then return end

    local animType = getAnimType(originalTrack.Animation.AnimationId)
    if not animType then return end

    local data = preloaded[animType]
    if not data then return end

    local tPos = originalTrack.TimePosition
    local weight = originalTrack.WeightCurrent

    originalTrack:Stop(0)
    task.wait()

    data.track:Play(0, weight, data.cfg.speed)
    pcall(function()
        data.track.TimePosition = tPos
    end)
end

-- ================= PUBLIC =================
function SkinAPI.Enable()
    if enabled then return end
    enabled = true

    preload()

    local animator = getAnimator()
    if animator then
        table.insert(connections,
            animator.AnimationPlayed:Connect(function(track)
                task.defer(forceReplace, track)
            end)
        )
    end

    table.insert(connections,
        RunService.Heartbeat:Connect(function()
            if not enabled then return end
            local a = getAnimator()
            if not a then return end
            for _, t in ipairs(a:GetPlayingAnimationTracks()) do
                task.defer(forceReplace, t)
            end
        end)
    )
end

function SkinAPI.Disable()
    if not enabled then return end
    enabled = false

    clearPreload()

    for _, c in ipairs(connections) do
        c:Disconnect()
    end
    connections = {}
end

function SkinAPI.SwitchSkin(name)
    if not SKINS[name] then return end
    currentSkin = name
    if enabled then
        preload()
    end
end

function SkinAPI.GetSkins()
    local t = {}
    for k in pairs(SKINS) do table.insert(t, k) end
    table.sort(t)
    return t
end

function SkinAPI.GetCurrentSkin()
    return currentSkin
end

function SkinAPI.IsEnabled()
    return enabled
end

return SkinAPI
