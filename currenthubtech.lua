local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local StatsService = game:GetService("Stats")
local player = Players.LocalPlayer

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI:SetNotificationLower(true)

local gradient = WindUI:Gradient({
    ['0'] = { Color = Color3.fromHex('#2e004f'), Transparency = 0.5 },
    ['100'] = { Color = Color3.fromHex('#0a0012'), Transparency = 0.5 },
}, { Rotation = 0 })

WindUI:AddTheme({
    Name = "ShadowPurple",
    Accent = gradient,
    Background = Color3.fromHex('#07000c'),
    Button = Color3.fromHex('#2a0045'),
    Hover = Color3.fromHex('#44006e'),
    Active = Color3.fromHex('#6800a8'),
    Outline = Color3.fromHex('#2b0542'),
    Border = Color3.fromHex('#1a002b'),
    Text = Color3.fromHex('#f3d9ff'),
    Placeholder = Color3.fromHex('#7b2cbf'),
    Icon = Color3.fromHex('#9d4edd'),
    ScrollBar = Color3.fromHex('#1a002e'),
    Dialog = Color3.fromHex('#0d0017'),
})

local function GradientText(text)
    local startColor = Color3.fromHex('#9d4edd')
    local endColor = Color3.fromHex('#3c096c')
    local output = ""
    for i = 1, #text do
        local progress = (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * progress) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * progress) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * progress) * 255)
        output = output .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i,i))
    end
    return output
end

WindUI:Popup({
    Title = GradientText("Current Hub"),
    Content = "Welcome to Current Hub!",
    Icon = "crown",
    Buttons = {
        { Title = "Continue", Variant = "Primary", Icon = "arrow-right" }
    }
})

local Window = WindUI:CreateWindow({
    Title = "Current Hub",
    Author = "Current Hub",
    Folder = "CurrentHub",
    Icon = "crown",
    Theme = "ShadowPurple",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open Current Hub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(
            Color3.fromHex("#9d4edd"),
            Color3.fromHex("#3c096c")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },
})

Window:Tag({
    Title = "v1.0",
    Icon = "tag",
    Color = Color3.fromHex("#9d4edd"),
    Border = true,
})

----------------------------------------------------------------
-- UI STRUCTURE
----------------------------------------------------------------
local MainTab = Window:Tab({ Title = "Main", Icon = "sparkles", Border = true })

local TechsSectionContainer = Window:Section({ Title = "Techs" })
local MiscSectionContainer = Window:Section({ Title = "Misc" })

local KingTab = TechsSectionContainer:Tab({ Title = "King Tech", Icon = "crown", Border = true })
local OreoTab = TechsSectionContainer:Tab({ Title = "Oreo Tech", Icon = "cookie", Border = true })
local BoomyTab = TechsSectionContainer:Tab({ Title = "Boomy Lethal", Icon = "flame", Border = true })
local FlingTab = TechsSectionContainer:Tab({ Title = "Fling Tech", Icon = "zap", Border = true })
local SupaTab = TechsSectionContainer:Tab({ Title = "Supa Tech", Icon = "zap", Border = true })
local DashTab = TechsSectionContainer:Tab({ Title = "Perfect Loopdash", Icon = "repeat", Border = true })
local M1ResetTab = TechsSectionContainer:Tab({ Title = "M1 Reset", Icon = "swords", Border = true })
local AutoKyotoTab = TechsSectionContainer:Tab({ Title = "Auto Kyoto", Icon = "sword", Border = true })
local AutoBlockTab = TechsSectionContainer:Tab({ Title = "Auto Block", Icon = "shield", Border = true })

local UtilityTab = MiscSectionContainer:Tab({ Title = "Utilities", Icon = "wrench", Border = true })
local SettingsTab = MiscSectionContainer:Tab({ Title = "Settings", Icon = "settings", Border = true })
local CreditsTab = MiscSectionContainer:Tab({ Title = "Credits", Icon = "heart", Border = true })

----------------------------------------------------------------
-- CREDITS TAB CONTENT
----------------------------------------------------------------
CreditsTab:Paragraph({
    Title = "CURRENT HUB OFFICIAL",
    Desc = "Made by kirus, unauthorized, and imtojisans."
})

CreditsTab:Space()

CreditsTab:Paragraph({
    Title = "ABOUT CURRENT HUB",
    Desc = "Best tech script for TSBG. Join the Discord to get early updates and fix logs."
})

CreditsTab:Space()

CreditsTab:Button({
    Title = "Copy Discord Link",
    Desc = "Copies our Discord invite to clipboard",
    Icon = "link",
    Callback = function()
        local discordUrl = "https://discord.gg/jVvfAjZx3h"
        if setclipboard then
            setclipboard(discordUrl)
            WindUI:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 3 })
        elseif toclipboard then
            toclipboard(discordUrl)
            WindUI:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Your executor doesn't support clipboard functions.", Duration = 3 })
        end
    end
})

----------------------------------------------------------------
-- GLOBAL STATE & CONNECTIONS
----------------------------------------------------------------
local cooldownEnabled = false
local noStunEnabled = true
local Connections = {}
local mainCam = workspace.CurrentCamera

----------------------------------------------------------------
-- SHARED UTILITY & HELPER FUNCTIONS
----------------------------------------------------------------
local UPPERCUT_ANIMS = {
    ["rbxassetid://10503381238"] = true,
    ["rbxassetid://13379003796"] = true,
}
local TARGET_LETHAL_ANIM_ID = 12296113986
local DASH_ANIM_ID = "rbxassetid://10480793962"

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") 
        or char:FindFirstChild("UpperTorso") 
        or char:FindFirstChild("LowerTorso") 
        or char:FindFirstChild("Torso"))
end

local function getClosestEnemy(maxDist)
    local char = player.Character
    local hrp = getRoot(char)
    if not hrp then return nil end

    local liveFolder = workspace:FindFirstChild("Live")
    if not liveFolder then return nil end

    local best, bestDist = nil, maxDist
    for _, model in ipairs(liveFolder:GetChildren()) do
        if model:IsA("Model") and model ~= char then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = getRoot(model)
                if root then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < bestDist then
                        best = root
                        bestDist = dist
                    end
                end
            end
        end
    end
    return best
end

local function autoPressQ()
    if VirtualInputManager and type(VirtualInputManager.SendKeyEvent) == "function" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    else
        local char = player.Character
        if char and char:FindFirstChild("Communicate") then
            char.Communicate:FireServer({ Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" })
        end
    end
end

local function forceJump(height)
    height = height or 50
    local char = player.Character
    local hrp = getRoot(char)
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, height, hrp.AssemblyLinearVelocity.Z)
    end
end

local function flipCamera()
    local cam = workspace.CurrentCamera
    if cam then
        local cf = cam.CFrame
        local look = cf.LookVector
        local newLook = Vector3.new(-look.X, look.Y, -look.Z)
        cam.CFrame = CFrame.new(cf.Position, cf.Position + newLook)
    end
end

----------------------------------------------------------------
-- HEADLESS FUNCTIONALITY
----------------------------------------------------------------
local headlessEnabled = false

local function setHeadlessState(state)
    headlessEnabled = state
    local char = player.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = state and 1 or 0
            local face = head:FindFirstChildOfClass("Decal")
            if face then face.Transparency = state and 1 or 0 end
        end
    end
end

----------------------------------------------------------------
-- OVERHEAD BILLBOARD SYSTEM
----------------------------------------------------------------
local HeadBillboard, CooldownFill
local isCooldown = false

local function setupHeadUI(char)
    if HeadBillboard then HeadBillboard:Destroy() end
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    
    if headlessEnabled then
        head.Transparency = 1
        local face = head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 1 end
    end

    HeadBillboard = Instance.new("BillboardGui")
    HeadBillboard.Name = "CurrentHubOverhead"
    HeadBillboard.Adornee = head
    HeadBillboard.Size = UDim2.new(0, 100, 0, 14)
    HeadBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
    HeadBillboard.AlwaysOnTop = true
    HeadBillboard.Enabled = false
    HeadBillboard.Parent = head

    local bgFrame = Instance.new("Frame", HeadBillboard)
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    bgFrame.BackgroundTransparency = 0.25
    bgFrame.BorderSizePixel = 0
    Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(1, 0)

    CooldownFill = Instance.new("Frame", bgFrame)
    CooldownFill.Name = "Fill"
    CooldownFill.Size = UDim2.new(1, 0, 1, 0)
    CooldownFill.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    CooldownFill.BorderSizePixel = 0
    Instance.new("UICorner", CooldownFill).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", bgFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "COOLDOWN"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 8
    label.ZIndex = 2
end

local function startCooldown(duration)
    if not cooldownEnabled or isCooldown then return end
    isCooldown = true
    
    if HeadBillboard and CooldownFill then
        HeadBillboard.Enabled = true
        CooldownFill.Size = UDim2.new(1, 0, 1, 0)
        local tween = TweenService:Create(CooldownFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
        tween:Play()
        task.delay(duration, function()
            isCooldown = false
            HeadBillboard.Enabled = false
        end)
    else
        task.wait(duration)
        isCooldown = false
    end
end

----------------------------------------------------------------
-- TOUCH BUTTON SYSTEM
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CurrentHubTouchGui"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local function createTouchButton(name, text, position, callback)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Name = name
    btn.Size = UDim2.new(0, 55, 0, 55)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Visible = false
    btn.Active = true
    btn.Draggable = true
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5

    btn.MouseButton1Click:Connect(callback)
    return btn
end

----------------------------------------------------------------
-- CAMLOCK ENGINE
----------------------------------------------------------------
local camlockActive = false
local predictionAmount = 0.16
local camlockKey = Enum.KeyCode.C
local camlockTargetPart = nil

local function FindNearestEnemyCamlock()
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(GuiService:GetScreenResolution().X / 2, GuiService:GetScreenResolution().Y / 2)
    local closestEnemyPart = nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local magnitude = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if magnitude < shortestDistance then
                        closestEnemyPart = p.Character.HumanoidRootPart
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end

    local liveFolder = workspace:FindFirstChild("Live")
    if liveFolder then
        local dummy = liveFolder:FindFirstChild("Weakest Dummy")
        if dummy and dummy:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(dummy.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if magnitude < shortestDistance then
                    closestEnemyPart = dummy.HumanoidRootPart
                end
            end
        end
    end

    return closestEnemyPart
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if camlockActive and camlockTargetPart then
        local camera = workspace.CurrentCamera
        camera.CFrame = CFrame.new(camera.CFrame.Position, camlockTargetPart.Position + (camlockTargetPart.Velocity * predictionAmount))
    end
end))

----------------------------------------------------------------
-- KING TECH, OREO TECH & BOOMY LETHAL VARIABLES
----------------------------------------------------------------
local KingTechEnabled = true
local kingstart = 0.3
local kingwait = 0.2

local dripzEnabled = true
local oreostart = 0.3
local oreowait = 0.5
local oreocam = 1
local oreojump = 54

local boomyEnabled = true
local boomystart = 1.7
local boomyjump = 65
local boomywait = 0.1
local boomycam = 3

----------------------------------------------------------------
-- AUTO BLOCK ENGINE
----------------------------------------------------------------
local autoBlockEnabled = false
local closeRangeDistance = 14
local longRangeDistance = 35
local isBlocking = false

local meleeMoveAnimationIDs = {
    "rbxassetid://16552234590", "rbxassetid://17889290569", "rbxassetid://17889461810",
    "rbxassetid://17889458563", "rbxassetid://17889471098", "rbxassetid://16515448089",
    "rbxassetid://16515520431", "rbxassetid://15162694192", "rbxassetid://15240176873",
    "rbxassetid://14136436157", "rbxassetid://14001963401", "rbxassetid://13997092940",
    "rbxassetid://10469643643", "rbxassetid://10469630950", "rbxassetid://10479335397"
}

local rangedMoveAnimationIDs = {
    "rbxassetid://10479335397", "rbxassetid://10468665991", "rbxassetid://12684185971",
    "rbxassetid://12509505723", "rbxassetid://17275150809", "rbxassetid://13362587853"
}

local function IsPlayingAnimation(humanoid, animList)
    if not humanoid then return false end
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        if table.find(animList, track.Animation.AnimationId) then
            return true
        end
    end
    return false
end

local function SendBlockInput()
    local character = player.Character
    if character and character:FindFirstChild("Communicate") then
        character.Communicate:FireServer({ Goal = "KeyPress", Key = Enum.KeyCode.F })
    end
end

local function SendUnblockInput()
    local character = player.Character
    if character and character:FindFirstChild("Communicate") then
        character.Communicate:FireServer({ Goal = "KeyRelease", Key = Enum.KeyCode.F })
    end
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if autoBlockEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = player.Character.HumanoidRootPart.Position
        local nearestMeleeTarget = nil
        local nearestRangedTarget = nil
        local shortestMeleeDist = math.huge
        local shortestRangedDist = math.huge

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = p.Character.HumanoidRootPart.Position
                local distance = (myPos - targetPos).Magnitude

                if distance < closeRangeDistance and distance < shortestMeleeDist then
                    nearestMeleeTarget = p
                    shortestMeleeDist = distance
                end

                if distance < longRangeDistance and distance < shortestRangedDist then
                    nearestRangedTarget = p
                    shortestRangedDist = distance
                end
            end
        end

        if nearestRangedTarget and nearestRangedTarget.Character:FindFirstChild("Humanoid") and IsPlayingAnimation(nearestRangedTarget.Character.Humanoid, rangedMoveAnimationIDs) then
            if not isBlocking then
                isBlocking = true
                SendBlockInput()
                task.wait(0.15)
                isBlocking = false
                SendUnblockInput()
            end
        elseif nearestMeleeTarget and nearestMeleeTarget.Character:FindFirstChild("Humanoid") and IsPlayingAnimation(nearestMeleeTarget.Character.Humanoid, meleeMoveAnimationIDs) then
            if not isBlocking then
                isBlocking = true
                SendBlockInput()
                task.wait(0.15)
                isBlocking = false
                SendUnblockInput()
            end
        end
    end
end))

----------------------------------------------------------------
-- FLING TECH ENGINE
----------------------------------------------------------------
local FlingTechEnabled = true
local flingStart = 0.3
local flingDuration = 0.3
local followConnection
local attached = false
local attachCooldown = false
local DashRemote = ReplicatedStorage:FindFirstChild("Resources") and ReplicatedStorage.Resources:FindFirstChild("Brother") and ReplicatedStorage.Resources.Brother:FindFirstChild("#Friend") and ReplicatedStorage.Resources.Brother["#Friend"]:FindFirstChild("Communicate")

local function fireQ()
    if DashRemote then
        DashRemote:FireServer({
            [1] = {Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}
        })
    end
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

local function detach()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    attached = false
end

local function attachTo(enemyHRP, duration)
    if attached then return end
    local char = player.Character
    local hrp = getRoot(char)
    enemyHRP = enemyHRP and getRoot(enemyHRP.Parent)
    if not hrp or not enemyHRP then return end

    attached = true
    local start = tick()
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not enemyHRP or not enemyHRP.Parent then
            detach()
            return
        end
        hrp.CFrame = CFrame.new(enemyHRP.Position + Vector3.new(0, 1, 0)) * CFrame.Angles(math.rad(90), 0, 0)
        if tick() - start >= (duration or 0.3) then
            detach()
        end
    end)
end

----------------------------------------------------------------
-- AUTO KYOTO ENGINE
----------------------------------------------------------------
local kyotoEnabled = false
local kyotoActivationDelay = 1.510
local kyotoDashDistance = 22.5
local kyotoTriggerAnim = "12273188754"
local kyotoCooldown = 0.6
local lastKyotoTime = 0
local kyotoTweenDuration = 0.08
local facingAngleDegrees = -90
local kyotoLeftAnim = "10479335397"

local function playKyotoSideAnim(humanoid, animId)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Priority == Enum.AnimationPriority.Action then
            track:Stop()
        end
    end

    local animObj = Instance.new("Animation")
    animObj.AnimationId = "rbxassetid://" .. tostring(animId)

    local track = animator:LoadAnimation(animObj)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1.3)
    return track
end

local function executeKyotoStepTwo()
    if (os.clock() - lastKyotoTime) < kyotoCooldown then return end
    lastKyotoTime = os.clock()

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")

    if rootPart and hum then
        playKyotoSideAnim(hum, kyotoLeftAnim)

        local straightForwardPosition = rootPart.Position + (rootPart.CFrame.LookVector * kyotoDashDistance)
        local rotatedOrientation = rootPart.CFrame * CFrame.Angles(0, math.rad(facingAngleDegrees), 0)
        
        local targetCFrame = CFrame.new(straightForwardPosition) * (rotatedOrientation - rotatedOrientation.Position)

        local clampedTweenDuration = math.min(1.0, math.max(0.01, kyotoTweenDuration))
        local tweenInfo = TweenInfo.new(clampedTweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCFrame })
        tween:Play()

        pcall(function()
            if VirtualInputManager and type(VirtualInputManager.SendKeyEvent) == "function" then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
            else
                local communicate = char:FindFirstChild("Communicate")
                if communicate then
                    communicate:FireServer({ Goal = "KeyPress", Key = Enum.KeyCode.Two })
                end
            end
        end)
    end
end

----------------------------------------------------------------
-- M1 RESET ENGINE
----------------------------------------------------------------
local m1ResetEnabled = true
local dashDuration = 0.2
local dashforce = 150
local m1ResetDebounce = false
local m1Key = Enum.KeyCode.C
local m1TouchEnabled = false

local function executeM1Reset()
    local char = player.Character
    local hrp = getRoot(char)
    local humanoid = char and char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera
    if m1ResetDebounce or not m1ResetEnabled or not char or not hrp or not humanoid or humanoid.Health <= 0 then return end

    m1ResetDebounce = true

    local disabled = {}
    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") and v.Name ~= "moveme" then
            disabled[v] = v.MaxForce
            v.MaxForce = Vector3.zero
        end
    end

    local connect = RunService.Heartbeat:Connect(function()
        hrp.AssemblyLinearVelocity = hrp.CFrame.RightVector * dashforce
    end)

    local originalCamCF = cam.CFrame
    cam.CFrame = originalCamCF * CFrame.Angles(0, math.rad(-90), 0)

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        local anim = Instance.new("Animation")
        anim.AnimationId = DASH_ANIM_ID
        local track = animator:LoadAnimation(anim)
        track:Play()
    end

    task.wait(dashDuration)

    autoPressQ()

    hrp.AssemblyLinearVelocity = Vector3.zero
    cam.CFrame = originalCamCF

    if connect then connect:Disconnect() end

    for bv, maxForce in pairs(disabled) do
        if bv and bv.Parent then
            bv.MaxForce = maxForce
        end
    end

    m1ResetDebounce = false
end

local m1ResetTouchBtn = createTouchButton("M1ResetTouchBtn", "M1 RESET", UDim2.new(0.85, -25, 0.25, -25), function()
    executeM1Reset()
end)

----------------------------------------------------------------
-- SUPERJUMP LOGIC
----------------------------------------------------------------
local jumpHeightStuds = 50
local jumpKey = Enum.KeyCode.Space
local jumpTouchEnabled = false

local function launchUpward()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local gravity = workspace.Gravity
        local requiredVelocity = math.sqrt(2 * gravity * jumpHeightStuds)
        
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
            humanoidRootPart.AssemblyLinearVelocity.X,
            requiredVelocity,
            humanoidRootPart.AssemblyLinearVelocity.Z
        )
    end
end

local jumpTouchBtn = createTouchButton("JumpTouchBtn", "JUMP", UDim2.new(0.85, -25, 0.4, -25), function()
    launchUpward()
end)

----------------------------------------------------------------
-- SUPA TECH ENGINE
----------------------------------------------------------------
local supaEnabled = false
local supaAnim1 = "10503381238"
local supaAnim2 = "13379003796"
local supaDelay = 0.3
local supaRange = 20
local supaKey = Enum.KeyCode.E
local supaTouchEnabled = false
local lastSupaTick = 0
local supaCooldown = 0.3
local supaInCooldown = false

local function findClosestModelWithRootPart()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closestModel = nil
    local smallestDistance = supaRange

    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("HumanoidRootPart") and descendant ~= char then
            local ok, distance = pcall(function()
                return (root.Position - descendant.HumanoidRootPart.Position).Magnitude
            end)

            if ok and distance and distance < smallestDistance then
                closestModel = descendant
                smallestDistance = distance
            end
        end
    end

    return closestModel
end

local function sendDashAndRemoveVelocity()
    local char = player.Character
    pcall(function()
        local payload = {
            {
                Dash = Enum.KeyCode.W,
                Key = Enum.KeyCode.Q,
                Goal = "KeyPress"
            }
        }
        if char and char:FindFirstChild("Communicate") then
            char.Communicate:FireServer(unpack(payload))
        end
    end)

    local function findNilInstanceByNameClass(name, className)
        if type(getnilinstances) ~= "function" then return nil end
        for _, inst in pairs(getnilinstances()) do
            if inst.ClassName == className and inst.Name == name then
                return inst
            end
        end
        return nil
    end

    pcall(function()
        local payload = {
            {
                Goal = "delete bv",
                BV = findNilInstanceByNameClass("moveme", "BodyVelocity")
            }
        }
        if char and char:FindFirstChild("Communicate") then
            char.Communicate:FireServer(unpack(payload))
        end
    end)
end

local function performStickDash()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root then return end

    local targetModel = findClosestModelWithRootPart()
    if not targetModel then return end

    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local savedState = {}
    pcall(function()
        savedState.WalkSpeed = hum.WalkSpeed
        savedState.JumpPower = hum.JumpPower
        savedState.PlatformStand = hum.PlatformStand
        savedState.AutoRotate = hum.AutoRotate
    end)

    local heartbeatConnection = nil

    local function restoreCharacterState()
        if heartbeatConnection and heartbeatConnection.Disconnect then
            pcall(function() heartbeatConnection:Disconnect() end)
        end

        pcall(function()
            if hum then
                hum.WalkSpeed = savedState.WalkSpeed or 16
                hum.JumpPower = savedState.JumpPower or 50
                hum.PlatformStand = savedState.PlatformStand or false
                if savedState.AutoRotate ~= nil then
                    pcall(function() hum.AutoRotate = savedState.AutoRotate end)
                end
            end

            if root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.PlatformStand = true
        pcall(function() hum.AutoRotate = false end)

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    for _, d in pairs(char:GetDescendants()) do
        local className = d.ClassName
        if className == "BodyVelocity" or className == "BodyPosition" or className == "BodyGyro"
            or className == "VectorForce" or className == "AlignPosition" or className == "AlignOrientation"
            or className == "LinearVelocity" or className == "AngularVelocity" then
            pcall(function() d:Destroy() end)
        end
    end

    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if root then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        if hum and hum.WalkSpeed then
            pcall(function() hum.WalkSpeed = 0 end)
        end
    end)

    pcall(sendDashAndRemoveVelocity)
    task.wait(0.2)
    pcall(function()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    end)

    if root then
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(60), 0, 0)
    end

    local followDuration = 0.2
    local startTick = tick()

    local followConnection
    followConnection = RunService.Heartbeat:Connect(function()
        if followDuration > tick() - startTick then
            local ok, targetCFrame = pcall(function()
                return CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 0.3) * CFrame.Angles(math.rad(60), 0, 0)
            end)
            if ok and targetCFrame and root then
                pcall(function() root.CFrame = targetCFrame end)
            end
        else
            if followConnection and followConnection.Disconnect then
                pcall(function() followConnection:Disconnect() end)
            end
        end
    end)

    repeat task.wait() until followDuration <= tick() - startTick

    pcall(function()
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end)

    restoreCharacterState()
end

local function executeSupa()
    if not supaEnabled or supaInCooldown then return end
    if supaCooldown <= tick() - lastSupaTick then
        lastSupaTick = tick()
        supaInCooldown = true
        task.spawn(function()
            pcall(performStickDash)
        end)
        task.delay(supaCooldown, function()
            supaInCooldown = false
        end)
    end
end

local supaTouchBtn = createTouchButton("SupaTouchBtn", "SUPA", UDim2.new(0.85, -25, 0.55, -25), function()
    executeSupa()
end)

----------------------------------------------------------------
-- PERFECT LOOPDASH ENGINE
----------------------------------------------------------------
local dashEnabled = false
local dashAnim = "10503381238"
local dashDelay = 0.285
local dashJump = 55
local dashAccuracy = 15
local dashSmoothness = 30
local dashCancelDelay = 0.4
local dashRange = 8
local dashKey = Enum.KeyCode.R
local dashTouchEnabled = false

local dashExecuting = false
local isNoclipping = false

local cooldownAnims = {
    ["10491993682"] = true,
    ["10479335397"] = true,
    ["13380255751"] = true,
}

local function fireDash()
    local char = player.Character
    if not char then return end
    local communicate = char:FindFirstChild("Communicate")
    if communicate then
        local args = {{
            Dash = Enum.KeyCode.W,
            Key = Enum.KeyCode.Q,
            Goal = "KeyPress"
        }}
        communicate:FireServer(unpack(args))
    end
end

local function clip()
    isNoclipping = false
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local function forceCancel()
    clip()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, obj in pairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("LinearVelocity") or obj:IsA("Attachment") or obj:IsA("BodyAngularVelocity") then
                obj:Destroy()
            end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function getTorsoTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    
    local parts = workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position, dashRange, params)
    local target = nil
    local dist = dashRange
    
    for _, part in pairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") and model ~= char then
            local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
            if torso then
                local d = (char.HumanoidRootPart.Position - torso.Position).Magnitude
                if d < dist then 
                    dist = d 
                    target = torso 
                end
            end
        end
    end
    return target
end

local function executeLethal()
    if not dashEnabled or dashExecuting or isCooldown then return end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local torso = getTorsoTarget()
    if not torso then clip() return end
    
    dashExecuting = true
    
    task.wait(math.max(0, dashDelay))
    if not torso.Parent or not root.Parent then dashExecuting = false return end
    
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, dashJump, root.AssemblyLinearVelocity.Z)
    isNoclipping = true
    
    task.wait(0)
    if not torso.Parent or not root.Parent then dashExecuting = false return end
    fireDash()
    
    local startT = os.clock()
    local forwardDir = (torso.Position - root.Position).Unit
    local sideVec = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
    
    hum.AutoRotate = false

    local bav = root:FindFirstChild("CurrentHubBAV") or Instance.new("BodyAngularVelocity")
    bav.Name = "CurrentHubBAV"
    bav.MaxTorque = Vector3.new(0, math.huge, 0)
    bav.P = 100000
    bav.AngularVelocity = Vector3.zero
    bav.Parent = root
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not torso or not torso.Parent or not root or not root.Parent then 
            if bav then bav:Destroy() end 
            clip()
            dashExecuting = false
            if conn then conn:Disconnect() end
            return 
        end
        
        hum.AutoRotate = false

        local elapsed = os.clock() - startT
        local torsoPos, rootPos = torso.Position, root.Position
        
        local angle = (elapsed / 0.45) * (math.pi / 1.5)
        local radius = dashAccuracy * (1 - math.clamp(elapsed / 0.45, 0, 1))
        local targetLookPos = torsoPos + (sideVec * math.cos(angle) + forwardDir * math.sin(angle)) * radius
        local lookAtCF = CFrame.lookAt(rootPos, Vector3.new(targetLookPos.X, rootPos.Y, targetLookPos.Z))
        local relativeCF = root.CFrame:Inverse() * lookAtCF
        local _, y, _ = relativeCF:ToEulerAnglesXYZ()
        if bav and bav.Parent then 
            bav.AngularVelocity = Vector3.new(0, y * dashSmoothness, 0) 
        end

        local distXZ = (Vector2.new(rootPos.X, rootPos.Z) - Vector2.new(torsoPos.X, torsoPos.Z)).Magnitude
        if (elapsed > dashCancelDelay and distXZ < 2.2) or elapsed > 1.5 or not dashEnabled then
            if bav then bav:Destroy() end
            forceCancel()
            dashExecuting = false
            conn:Disconnect()
            return
        end
    end)
end

local dashTouchBtn = createTouchButton("DashTouchBtn", "DASH", UDim2.new(0.85, -25, 0.7, -25), function()
    executeLethal()
end)

----------------------------------------------------------------
-- LISTENERS & EVENT CONNECTIONS
----------------------------------------------------------------
local function getId(str)
    return tostring(str):match("%d+")
end

local function setupCharacter(char)
    setupHeadUI(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid

    attached = false
    attachCooldown = false
    detach()

    table.insert(Connections, humanoid.Died:Connect(function()
        detach()
    end))

    table.insert(Connections, animator.AnimationPlayed:Connect(function(track)
        local anim = track and track.Animation
        if not anim then return end
        local rawAnimId = tostring(anim.AnimationId or "")
        local animId = getId(rawAnimId)
        local animIdNumber = tonumber(animId)

        if cooldownAnims[animId] then
            startCooldown(5)
        end

        ----------------------------------------------------
        -- FLING TECH LOGIC
        ----------------------------------------------------
        if FlingTechEnabled and UPPERCUT_ANIMS[anim.AnimationId] and not attachCooldown then
            local enemy = getClosestEnemy(10)
            if enemy then
                task.delay(flingStart, function()
                    fireQ()
                    attachTo(enemy, flingDuration)
                end)
            end
        end

        ----------------------------------------------------
        -- 1. KING TECH LOGIC
        ----------------------------------------------------
        if KingTechEnabled and UPPERCUT_ANIMS[anim.AnimationId] then
            local enemy = getClosestEnemy(10)
            if enemy then
                task.delay(kingstart, function()
                    autoPressQ()
                    forceJump(50)
                    task.delay(kingwait, flipCamera)
                end)
            end
        end

        ----------------------------------------------------
        -- 2. OREO TECH LOGIC
        ----------------------------------------------------
        if dripzEnabled and UPPERCUT_ANIMS[anim.AnimationId] then
            local enemy = getClosestEnemy(10)
            if enemy then
                task.delay(oreostart, function()
                    autoPressQ()
                    forceJump(oreojump)
                end)

                task.delay(oreowait, function()
                    local startTime = tick()
                    local targetChar = enemy.Parent
                    local targetPart = targetChar and (targetChar:FindFirstChild("Right Arm") or getRoot(targetChar))

                    local connection
                    connection = RunService.RenderStepped:Connect(function()
                        if not targetPart or not targetPart.Parent then
                            connection:Disconnect()
                            return
                        end
                        local cam = workspace.CurrentCamera
                        local camCF = cam.CFrame
                        local camPos = camCF.Position
                        local armCF = targetPart.CFrame
                        
                        local backOffset = armCF:VectorToWorldSpace(Vector3.new(0, 0, -1))
                        local backPosition = armCF.Position + backOffset
                        local dir = Vector3.new(backPosition.X - camPos.X, 0, backPosition.Z - camPos.Z)

                        if dir.Magnitude > 0 then
                            dir = dir.Unit
                            local targetYaw = math.atan2(dir.Z, dir.X)
                            local currentYaw = math.atan2(camCF.LookVector.Z, camCF.LookVector.X)
                            local newYaw = currentYaw + (targetYaw - currentYaw) * oreocam
                            local pitch = math.asin(camCF.LookVector.Y)
                            local newLook = Vector3.new(
                                math.cos(newYaw) * math.cos(pitch),
                                math.sin(pitch),
                                math.sin(newYaw) * math.cos(pitch)
                            )
                            cam.CFrame = CFrame.new(camPos, camPos + newLook)
                        end

                        if tick() - startTime >= 0.2 then
                            connection:Disconnect()
                        end
                    end)
                end)
            end
        end

        ----------------------------------------------------
        -- 3. BOOMY LETHAL LOGIC
        ----------------------------------------------------
        if boomyEnabled and animIdNumber == TARGET_LETHAL_ANIM_ID then
            local enemy = getClosestEnemy(10)
            if enemy then
                task.delay(boomystart, function()
                    autoPressQ()
                    flipCamera()
                    forceJump(boomyjump)
                    
                    task.wait(boomywait)

                    local startTime = tick()
                    local targetChar = enemy.Parent
                    local targetPart = targetChar and (targetChar:FindFirstChild("Right Arm") or getRoot(targetChar))

                    local connection
                    connection = RunService.RenderStepped:Connect(function()
                        if not targetPart or not targetPart.Parent then
                            connection:Disconnect()
                            return
                        end
                        local cam = workspace.CurrentCamera
                        local camCF = cam.CFrame
                        local camPos = camCF.Position
                        local lookCF = targetPart.CFrame
                        local backPosition = lookCF.Position
                        local dir = Vector3.new(backPosition.X - camPos.X, 0, backPosition.Z - camPos.Z)

                        if dir.Magnitude > 0 then
                            dir = dir.Unit
                            local targetYaw = math.atan2(dir.Z, dir.X)
                            local currentYaw = math.atan2(camCF.LookVector.Z, camCF.LookVector.X)
                            local newYaw = currentYaw + (targetYaw - currentYaw) * boomycam
                            local pitch = math.asin(camCF.LookVector.Y)
                            local newLook = Vector3.new(
                                math.cos(newYaw) * math.cos(pitch),
                                math.sin(pitch),
                                math.sin(newYaw) * math.cos(pitch)
                            )
                            cam.CFrame = CFrame.new(camPos, camPos + newLook)
                        end

                        if tick() - startTime >= 0.2 then
                            connection:Disconnect()
                        end
                    end)
                end)
            end
        end

        ----------------------------------------------------
        -- 4. OTHER TECH TRIPPERS
        ----------------------------------------------------
        if kyotoEnabled and (rawAnimId == kyotoTriggerAnim or animId == getId(kyotoTriggerAnim)) then
            local clampedDelay = math.max(1.510, kyotoActivationDelay)
            task.delay(clampedDelay, function()
                if kyotoEnabled then
                    executeKyotoStepTwo()
                end
            end)
        end

        if supaEnabled and (animId == supaAnim1 or animId == supaAnim2) then
            task.delay(supaDelay, executeSupa)
        end

        if dashEnabled and (animId == dashAnim) then
            executeLethal()
        end
    end))
end

if player.Character then setupCharacter(player.Character) end
table.insert(Connections, player.CharacterAdded:Connect(setupCharacter))

table.insert(Connections, RunService.Stepped:Connect(function()
    if not noStunEnabled then return end
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.PlatformStand then
                hum.PlatformStand = false
            end
            
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end

        for _, child in pairs(char:GetChildren()) do
            if child.Name:lower():find("stun") or child.Name:lower():find("freeze") or child.Name == "Freeze" or child.Name == "Stun" then
                pcall(function() child:Destroy() end)
            end
        end
    end
end))

table.insert(Connections, UIS.InputBegan:Connect(function(input, gpe)
    if gpe or UIS:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == supaKey then
            executeSupa()
        elseif input.KeyCode == dashKey then
            executeLethal()
        elseif input.KeyCode == jumpKey then
            launchUpward()
        elseif input.KeyCode == m1Key then
            executeM1Reset()
        elseif input.KeyCode == camlockKey then
            camlockActive = not camlockActive
            if camlockActive then
                camlockTargetPart = FindNearestEnemyCamlock()
            else
                camlockTargetPart = nil
            end
        end
    end
end))

table.insert(Connections, RunService.Stepped:Connect(function()
    if not isNoclipping then return end
    local char = player.Character
    if char then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

----------------------------------------------------------------
-- TAB INTERFACE CONFIGURATIONS
----------------------------------------------------------------

-- Main Tab
MainTab:Toggle({
    Title = "Enable Camlock",
    Desc = "Locks your camera onto the closest target with prediction",
    Value = false,
    Callback = function(state)
        camlockActive = state
        if state then
            camlockTargetPart = FindNearestEnemyCamlock()
        else
            camlockTargetPart = nil
        end
    end
})

MainTab:Slider({
    Title = "Camlock Prediction",
    Desc = "Adjust how far ahead camlock aims",
    Step = 0.01,
    Value = { Min = 0, Max = 1, Default = 0.16 },
    Callback = function(val)
        predictionAmount = val
    end
})

MainTab:Keybind({
    Title = "Camlock Keybind",
    Desc = "Key to toggle camlock on and off",
    Value = "C",
    Callback = function(key)
        camlockKey = Enum.KeyCode[key]
    end
})

MainTab:Space()

MainTab:Slider({
    Title = "Camera FOV",
    Desc = "Adjust field of view",
    Step = 1,
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(val)
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = val
        end
    end
})

MainTab:Space()

MainTab:Toggle({
    Title = "No Stun",
    Desc = "Instantly clears ragdolls, stuns, and freeze effects",
    Value = true,
    Callback = function(state)
        noStunEnabled = state
    end
})

MainTab:Space()

MainTab:Toggle({
    Title = "Infinite Dash",
    Desc = "Removes dash cooldowns",
    Value = false,
    Callback = function(state)
        workspace:SetAttribute("EffectAffects", 1)
        workspace:SetAttribute("NoDashCooldown", state)
    end
})

MainTab:Space()

MainTab:Button({
    Title = "Super Jump",
    Desc = "Launches your character into the air",
    Callback = function()
        launchUpward()
    end
})

MainTab:Toggle({
    Title = "Super Jump Mobile Button",
    Desc = "Shows an on-screen button for mobile super jump",
    Value = false,
    Callback = function(state)
        jumpTouchEnabled = state
        jumpTouchBtn.Visible = state
    end
})

MainTab:Space()

MainTab:Slider({
    Title = "Jump Height",
    Desc = "How high super jump launches you",
    Step = 1,
    Value = { Min = 10, Max = 500, Default = 50 },
    Callback = function(val)
        jumpHeightStuds = val
    end
})

MainTab:Keybind({
    Title = "Super Jump Keybind",
    Desc = "Key to trigger super jump",
    Value = "Space",
    Callback = function(key)
        jumpKey = Enum.KeyCode[key]
    end
})

-- King Tech Tab
KingTab:Toggle({
    Title = "Enable King Tech",
    Desc = "Auto jump, Q-dash, and camera flip on uppercut animation",
    Value = true,
    Callback = function(state)
        KingTechEnabled = state
    end
})

KingTab:Space()

KingTab:Slider({
    Title = "Execution Delay",
    Desc = "Delay before triggering King Tech (seconds)",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.3 },
    Callback = function(val)
        kingstart = val
    end
})

KingTab:Slider({
    Title = "Camera Flip Delay",
    Desc = "Delay before flipping camera (seconds)",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.2 },
    Callback = function(val)
        kingwait = val
    end
})

-- Oreo Tech Tab
OreoTab:Toggle({
    Title = "Enable Oreo Tech",
    Desc = "Auto dash, jump, and arm tracking routine on uppercuts",
    Value = true,
    Callback = function(state)
        dripzEnabled = state
    end
})

OreoTab:Space()

OreoTab:Slider({
    Title = "Execution Delay",
    Desc = "Time before auto dash & jump",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.3 },
    Callback = function(val)
        oreostart = val
    end
})

OreoTab:Slider({
    Title = "Arm Tracking Delay",
    Desc = "Time before camera snaps to target arm",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.5 },
    Callback = function(val)
        oreowait = val
    end
})

OreoTab:Slider({
    Title = "Jump Height",
    Desc = "Force jump height applied during Oreo Tech",
    Step = 1,
    Value = { Min = 10, Max = 100, Default = 54 },
    Callback = function(val)
        oreojump = val
    end
})

-- Boomy Lethal Tab
BoomyTab:Toggle({
    Title = "Enable Boomy Lethal",
    Desc = "Instant lethal trigger routine on Garou animation",
    Value = true,
    Callback = function(state)
        boomyEnabled = state
    end
})

BoomyTab:Space()

BoomyTab:Slider({
    Title = "Trigger Delay",
    Desc = "Delay before auto dash, flip, and force jump",
    Step = 0.05,
    Value = { Min = 0, Max = 3, Default = 1.7 },
    Callback = function(val)
        boomystart = val
    end
})

BoomyTab:Slider({
    Title = "Launch Force",
    Desc = "Upward force applied on trigger",
    Step = 1,
    Value = { Min = 10, Max = 150, Default = 65 },
    Callback = function(val)
        boomyjump = val
    end
})

BoomyTab:Slider({
    Title = "Arm Snap Delay",
    Desc = "Delay before camera tracks enemy arm",
    Step = 0.05,
    Value = { Min = 0, Max = 1, Default = 0.1 },
    Callback = function(val)
        boomywait = val
    end
})

-- Fling Tech Tab
FlingTab:Toggle({
    Title = "Enable Fling Tech",
    Desc = "Triggers Q-Dash attach logic on uppercuts",
    Value = true,
    Callback = function(state)
        FlingTechEnabled = state
    end
})

FlingTab:Space()

FlingTab:Slider({
    Title = "Fling Start Delay",
    Desc = "Delay before triggering fling tech",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.3 },
    Callback = function(val)
        flingStart = val
    end
})

FlingTab:Slider({
    Title = "Fling Duration",
    Desc = "Duration spent attached to target",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.3 },
    Callback = function(val)
        flingDuration = val
    end
})

-- Supa Tech Tab
SupaTab:Toggle({
    Title = "Supa Tech",
    Desc = "Automates stick dash combo routines on hit",
    Value = false,
    Callback = function(state)
        supaEnabled = state
    end
})

SupaTab:Toggle({
    Title = "Supa Mobile Button",
    Desc = "Shows on-screen button for Supa Tech",
    Value = false,
    Callback = function(state)
        supaTouchEnabled = state
        supaTouchBtn.Visible = state
    end
})

SupaTab:Space()

SupaTab:Slider({
    Title = "Execution Delay",
    Desc = "Delay before triggering Supa Tech",
    Step = 0.05,
    Value = { Min = 0, Max = 2, Default = 0.3 },
    Callback = function(val)
        supaDelay = val
    end
})

SupaTab:Slider({
    Title = "Target Range",
    Desc = "How close players need to be to activate",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = 20 },
    Callback = function(val)
        supaRange = val
    end
})

SupaTab:Keybind({
    Title = "Supa Keybind",
    Desc = "Key to trigger Supa Tech manually",
    Value = "E",
    Callback = function(key)
        supaKey = Enum.KeyCode[key]
    end
})

-- Perfect Loopdash Tab
DashTab:Toggle({
    Title = "Perfect Loopdash",
    Desc = "Circles around targets using precision dash velocity",
    Value = false,
    Callback = function(state)
        dashEnabled = state
    end
})

DashTab:Toggle({
    Title = "Loopdash Mobile Button",
    Desc = "Shows on-screen button for Loopdash",
    Value = false,
    Callback = function(state)
        dashTouchEnabled = state
        dashTouchBtn.Visible = state
    end
})

DashTab:Space()

DashTab:Slider({
    Title = "Dash Delay",
    Desc = "Execution delay before loop start",
    Step = 0.005,
    Value = { Min = 0, Max = 1, Default = 0.285 },
    Callback = function(val) dashDelay = val end
})

DashTab:Slider({
    Title = "Upward Burst",
    Desc = "Height jump applied during the loop",
    Step = 1,
    Value = { Min = 0, Max = 100, Default = 55 },
    Callback = function(val) dashJump = val end
})

DashTab:Slider({
    Title = "Tracking Radius",
    Desc = "Radius around target during spin",
    Step = 1,
    Value = { Min = 1, Max = 30, Default = 15 },
    Callback = function(val) dashAccuracy = val end
})

DashTab:Slider({
    Title = "Rotation Speed",
    Desc = "Smoothness of orbital angular velocity",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = 30 },
    Callback = function(val) dashSmoothness = val end
})

DashTab:Slider({
    Title = "Detection Range",
    Desc = "Distance to detect target torsos",
    Step = 1,
    Value = { Min = 1, Max = 25, Default = 8 },
    Callback = function(val) dashRange = val end
})

DashTab:Keybind({
    Title = "Loopdash Keybind",
    Desc = "Key to trigger Perfect Loopdash",
    Value = "R",
    Callback = function(key)
        dashKey = Enum.KeyCode[key]
    end
})

-- M1 Reset Tab
M1ResetTab:Toggle({
    Title = "Enable M1 Reset",
    Desc = "Enables M1 animation cancel tech",
    Value = true,
    Callback = function(state)
        m1ResetEnabled = state
    end
})

M1ResetTab:Toggle({
    Title = "M1 Reset Mobile Button",
    Desc = "Shows on-screen button for M1 Reset",
    Value = false,
    Callback = function(state)
        m1TouchEnabled = state
        m1ResetTouchBtn.Visible = state
    end
})

M1ResetTab:Space()

M1ResetTab:Slider({
    Title = "Dash Force",
    Desc = "Side velocity applied during reset",
    Step = 10,
    Value = { Min = 50, Max = 300, Default = 150 },
    Callback = function(val)
        dashforce = val
    end
})

M1ResetTab:Slider({
    Title = "Dash Duration",
    Desc = "Side thrust duration before auto Q-dash",
    Step = 0.05,
    Value = { Min = 0.05, Max = 1.0, Default = 0.2 },
    Callback = function(val)
        dashDuration = val
    end
})

M1ResetTab:Button({
    Title = "Trigger M1 Reset",
    Desc = "Stops M1 animations and performs reset shift",
    Callback = function()
        executeM1Reset()
    end
})

M1ResetTab:Space()

M1ResetTab:Keybind({
    Title = "M1 Reset Keybind",
    Desc = "Key to trigger M1 reset",
    Value = "C",
    Callback = function(key)
        m1Key = Enum.KeyCode[key]
    end
})

-- Auto Kyoto Tab
AutoKyotoTab:Toggle({
    Title = "Auto Kyoto",
    Desc = "Auto executes side dash combo into Kyoto alignment",
    Value = false,
    Callback = function(state)
        kyotoEnabled = state
    end
})

AutoKyotoTab:Space()

AutoKyotoTab:Slider({
    Title = "Trigger Delay",
    Desc = "Delay before Kyoto triggers",
    Step = 0.005,
    Value = { Min = 1.510, Max = 3.0, Default = 1.510 },
    Callback = function(val)
        kyotoActivationDelay = math.max(1.510, val)
    end
})

AutoKyotoTab:Slider({
    Title = "Dash Speed",
    Desc = "Speed of position tweening",
    Step = 0.01,
    Value = { Min = 0.01, Max = 1.0, Default = 0.08 },
    Callback = function(val)
        kyotoTweenDuration = math.clamp(val, 0.01, 1.0)
    end
})

AutoKyotoTab:Slider({
    Title = "Dash Distance",
    Desc = "Forward displacement distance",
    Step = 0.5,
    Value = { Min = 5, Max = 50, Default = 22.5 },
    Callback = function(val)
        kyotoDashDistance = val
    end
})

-- Auto Block Tab
AutoBlockTab:Toggle({
    Title = "Auto Block",
    Desc = "Automatically blocks nearby enemy attacks",
    Value = false,
    Callback = function(state)
        autoBlockEnabled = state
    end
})

AutoBlockTab:Space()

AutoBlockTab:Slider({
    Title = "Melee Range",
    Desc = "Block distance for close-range M1s and moves",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = 14 },
    Callback = function(val)
        closeRangeDistance = val
    end
})

AutoBlockTab:Slider({
    Title = "Ranged Distance",
    Desc = "Block distance for ranged projectiles",
    Step = 1,
    Value = { Min = 10, Max = 100, Default = 35 },
    Callback = function(val)
        longRangeDistance = val
    end
})

-- Utilities Tab
UtilityTab:Toggle({
    Title = "Headless Mode",
    Desc = "Makes your head invisible client-side",
    Value = false,
    Callback = function(state)
        setHeadlessState(state)
    end
})

UtilityTab:Space()

UtilityTab:Button({
    Title = "FPS Boost / Clean Map",
    Desc = "Removes trees, grass, debris, and particles to boost performance",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("tree") or v.Name:lower():find("grass") or v.Name:lower():find("bench")) then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        WindUI:Notify({ Title = "FPS Booster", Content = "Map cleaned successfully!", Duration = 3 })
    end
})

-- Settings Tab
SettingsTab:Toggle({
    Title = "Overhead Cooldown Bar",
    Desc = "Shows cooldown progress bar above your head",
    Value = false,
    Callback = function(state)
        cooldownEnabled = state
        if not state then
            isCooldown = false
            if HeadBillboard then HeadBillboard.Enabled = false end
        end
    end
})

SettingsTab:Space()

SettingsTab:Keybind({
    Title = "Menu Toggle Keybind",
    Desc = "Key to open or close the Current Hub menu",
    Value = "LeftControl",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})
