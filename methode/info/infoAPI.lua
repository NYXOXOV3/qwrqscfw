-- =========================================================
-- NYXHUB INFO API
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

local InfoAPI = {}

-- ---------- Internal ----------
local startTime = os.clock()

local function getExecutor()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok then return name end
    end
    return "Unknown Executor"
end

-- ---------- Public API ----------
function InfoAPI:GetVersion()
    return (_G.NYXHUB and _G.NYXHUB.Version) or "Unknown"
end

function InfoAPI:GetUptime()
    local t = math.floor(os.clock() - startTime)
    local h = math.floor(t / 3600)
    local m = math.floor((t % 3600) / 60)
    local s = t % 60
    return string.format("%02dh %02dm %02ds", h, m, s)
end

function InfoAPI:GetExecutor()
    return getExecutor()
end

function InfoAPI:IsReady()
    return _G.NYXHUB and _G.NYXHUB.Flags and _G.NYXHUB.Flags.Ready == true
end

function InfoAPI:GetLoadedModulesCount()
    local count = 0
    if _G.NYXHUB and _G.NYXHUB.Modules then
        for _, group in pairs(_G.NYXHUB.Modules) do
            if type(group) == "table" then
                for _ in pairs(group) do
                    count += 1
                end
            end
        end
    end
    return count
end

function InfoAPI:GetSessionInfo()
    return {
        Version = InfoAPI:GetVersion(),
        Executor = InfoAPI:GetExecutor(),
        Ready = InfoAPI:IsReady(),
        Modules = InfoAPI:GetLoadedModulesCount(),
        Uptime = InfoAPI:GetUptime(),
        Player = game:GetService("Players").LocalPlayer.Name,
        PlaceId = game.PlaceId,
    }
end

return InfoAPI
