-- =========================================================
-- SECURITY API
-- NYXHUB - Fish It
-- MODE: IMPLEMENTASI_KETAT
-- =========================================================

local SecurityAPI = {}

-- =========================
-- STATE
-- =========================
_G.SolaceDisguise = _G.SolaceDisguise or false
_G.AntiStaffEnabled = _G.AntiStaffEnabled or false

-- =========================
-- SOLACE DISGUISE (AS-IS)
-- =========================
function SecurityAPI.ToggleSolace(state)
    _G.SolaceDisguise = state

    if state then
        -- Config untuk Solace
        if not getgenv().SolaceConfig then
            getgenv().SolaceConfig = {
                Headless = false,
                FakeDisplayName = "Solace",
                FakeName = "Solace",
                FakeId = 13886182,
                Enabled = true
            }
        else
            getgenv().SolaceConfig.FakeDisplayName = "Solace"
            getgenv().SolaceConfig.FakeName = "Solace"
            getgenv().SolaceConfig.FakeId = 13886182
            getgenv().SolaceConfig.Enabled = true
        end

        local players = game:GetService("Players")
        local lp = players.LocalPlayer

        -- Simpan data asli
        if not _G.OriginalPlayerData then
            _G.OriginalPlayerData = {
                UserId = tostring(lp.UserId),
                Name = lp.Name,
                DisplayName = lp.DisplayName
            }
        end

        local function processtext(text)
            if not text or text == "" then return text end
            local processed = text
            processed = string.gsub(processed, _G.OriginalPlayerData.Name, getgenv().SolaceConfig.FakeName)
            processed = string.gsub(processed, _G.OriginalPlayerData.UserId, tostring(getgenv().SolaceConfig.FakeId))
            processed = string.gsub(processed, _G.OriginalPlayerData.DisplayName, getgenv().SolaceConfig.FakeDisplayName)
            return processed
        end

        local function disguisechar(char, id)
            if not char then return end

            task.spawn(function()
                local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
                local head = char:WaitForChild("Head")

                local desc
                repeat
                    local ok = pcall(function()
                        desc = players:GetHumanoidDescriptionFromUserId(id)
                    end)
                    if not ok then task.wait(1) end
                until desc

                local originalDesc = hum:FindFirstChildOfClass("HumanoidDescription")
                if originalDesc then
                    desc.HeightScale = originalDesc.HeightScale
                end

                char.Archivable = true
                local disguiseclone = char:Clone()
                disguiseclone.Name = "disguisechar"
                disguiseclone.Parent = workspace

                for _, v in pairs(disguiseclone:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("ShirtGraphic") or v:IsA("Shirt")
                        or v:IsA("Pants") then
                        v:Destroy()
                    end
                end

                disguiseclone.Humanoid:ApplyDescriptionClientServer(desc)

                for _, v in pairs(char:GetChildren()) do
                    if (v:IsA("Accessory") and v:GetAttribute("InvItem") == nil
                        and v:GetAttribute("ArmorSlot") == nil)
                        or v:IsA("ShirtGraphic") or v:IsA("Shirt")
                        or v:IsA("Pants") or v:IsA("BodyColors") then
                        v.Parent = game
                    end
                end

                if not _G.SolaceChildAddedConnection then
                    _G.SolaceChildAddedConnection = char.ChildAdded:Connect(function(v)
                        if ((v:IsA("Accessory") and v:GetAttribute("InvItem") == nil
                            and v:GetAttribute("ArmorSlot") == nil)
                            or v:IsA("ShirtGraphic") or v:IsA("Shirt")
                            or v:IsA("Pants") or v:IsA("BodyColors"))
                            and v:GetAttribute("Disguise") == nil then
                            repeat task.wait() v.Parent = game until v.Parent == game
                        end
                    end)
                end

                if disguiseclone:FindFirstChild("Animate") and char:FindFirstChild("Animate") then
                    for _, v in pairs(disguiseclone.Animate:GetChildren()) do
                        v:SetAttribute("Disguise", true)
                        local real = char.Animate:FindFirstChild(v.Name)
                        if v:IsA("StringValue") and real then
                            real.Parent = game
                            v.Parent = char.Animate
                        end
                    end
                end

                for _, v in pairs(disguiseclone:GetChildren()) do
                    v:SetAttribute("Disguise", true)
                    if v:IsA("Accessory") then
                        for _, v2 in pairs(v:GetDescendants()) do
                            if v2:IsA("Weld") and v2.Part1 then
                                v2.Part1 = char[v2.Part1.Name]
                            end
                        end
                        v.Parent = char
                    elseif v:IsA("ShirtGraphic") or v:IsA("Shirt")
                        or v:IsA("Pants") or v:IsA("BodyColors") then
                        v.Parent = char
                    elseif v.Name == "Head" and v:FindFirstChildOfClass("SpecialMesh") then
                        local hm = char.Head:FindFirstChildOfClass("SpecialMesh")
                        local cm = v:FindFirstChildOfClass("SpecialMesh")
                        if hm and cm then hm.MeshId = cm.MeshId end
                    end
                end

                local lf = char:FindFirstChild("face", true)
                local cf = disguiseclone:FindFirstChild("face", true)
                if lf and cf then
                    lf.Parent = game
                    cf.Parent = char.Head
                end

                char.Humanoid.HumanoidDescription:SetEmotes(desc:GetEmotes())
                char.Humanoid.HumanoidDescription:SetEquippedEmotes(desc:GetEquippedEmotes())

                disguiseclone:Destroy()
            end)
        end

        local function processTextElement(el)
            if not (el:IsA("TextBox") or el:IsA("TextLabel") or el:IsA("TextButton")) then
                return
            end

            if el.Text and el.Text ~= "" then
                el.Text = processtext(el.Text)
                if not el:GetAttribute("SolaceTextConnected") then
                    el:SetAttribute("SolaceTextConnected", true)
                    el:GetPropertyChangedSignal("Text"):Connect(function()
                        if el.Text and el.Text ~= "" then
                            el.Text = processtext(el.Text)
                        end
                    end)
                end
            end
        end

        local function processAllTextElements()
            for _, v in ipairs(game:GetDescendants()) do
                processTextElement(v)
            end
        end

        processAllTextElements()

        if not _G.SolaceDescendantConnection then
            _G.SolaceDescendantConnection = game.DescendantAdded:Connect(processTextElement)
        end

        if lp.Character then
            task.spawn(function()
                task.wait(1)
                pcall(function()
                    disguisechar(lp.Character, getgenv().SolaceConfig.FakeId)
                end)
            end)
        end

        if not _G.SolaceCharacterConnection then
            _G.SolaceCharacterConnection = lp.CharacterAdded:Connect(function(char)
                task.spawn(function()
                    task.wait(2)
                    processAllTextElements()
                    pcall(function()
                        disguisechar(char, getgenv().SolaceConfig.FakeId)
                    end)
                end)
            end)
        end

        print("[Solace] Disguise activated and will persist!")

    else
        if getgenv().SolaceConfig then
            getgenv().SolaceConfig.Enabled = false
        end
        print("[Solace] Disguise toggle off (changes persist until rejoin)")
        warn("Rejoin the game to completely disable username hiding")
    end
end

-- =========================
-- ANTI STAFF (PASIF)
-- =========================
function SecurityAPI.ToggleAntiStaff(state)
    _G.AntiStaffEnabled = state
    local Players = game:GetService("Players")

    if not state then
        print("[AntiStaff] Disabled")
        return
    end

    if _G.__AntiStaffConnection then
        print("[AntiStaff] Already running")
        return
    end

    local STAFF_KEYWORDS = {
        "admin", "mod", "moderator", "staff", "helper", "owner"
    }

    _G.__AntiStaffConnection = Players.PlayerAdded:Connect(function(plr)
        local name = string.lower(plr.Name)
        local display = string.lower(plr.DisplayName)

        for _, k in ipairs(STAFF_KEYWORDS) do
            if string.find(name, k) or string.find(display, k) then
                warn("[AntiStaff] Staff detected:", plr.Name)
                if _G.NYXHUB and _G.NYXHUB.Flags then
                    _G.NYXHUB.Flags.StaffDetected = true
                end
                break
            end
        end
    end)

    print("[AntiStaff] Enabled")
end

return SecurityAPI
