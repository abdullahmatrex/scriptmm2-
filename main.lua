-- [[ CYBER DRAGON V24 – FINAL SUPREME GOLD EDITION ]]
-- المطور: عبدالله
-- TikTok: 7_v4n3x | Telegram: abood_7ro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ==============================================
-- نظام الحماية المطلق (Supreme Shield)
-- ==============================================
local SafeCFrame = CFrame.new(0, 1500, 0)
local LogGui = Instance.new("ScreenGui", PlayerGui)
local LogFrame = Instance.new("ScrollingFrame", LogGui)
LogFrame.Size = UDim2.new(0.25,0,0.15,0); LogFrame.Position = UDim2.new(0.73,0,0.05,0)
LogFrame.BackgroundColor3 = Color3.new(0,0,0); LogFrame.BackgroundTransparency = 0.7
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0,6)
Instance.new("UIListLayout", LogFrame)

local function AddLog(msg)
    local lbl = Instance.new("TextLabel", LogFrame)
    lbl.Size = UDim2.new(1,0,0,14); lbl.Text = os.date("[%H:%M:%S] ") .. msg
    lbl.TextColor3 = Color3.new(0,1,0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- الحماية من الطرد (Anti-Kick + CheaterCheck) + تزييف القيم
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old_nc = mt.__namecall
    local old_idx = mt.__index
    
    mt.__index = newcclosure(function(t, k)
        if not checkcaller() then
            if k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
            if k == "JumpPower" and t:IsA("Humanoid") then return 50 end
            if k == "Health" and t:IsA("Humanoid") and Features.GodMode then return 100 end
        end
        return old_idx(t, k)
    end)

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if method == "FireServer" and tostring(self) == "MainEvent" then
            if args[1] == "Check" or args[1] == "Stomp" then return nil end
        end

        if method == "Kick" or method == "kick" then
            AddLog("Anti-Kick: Blocked")
            return nil
        end
        return old_nc(self, unpack(args))
    end)
    setreadonly(mt, true)
end)

local function SupremeShield()
    pcall(function()
        local root = GetRoot()
        local hum = GetHum()
        if root and root.Velocity.Magnitude > 140 then
            root.CFrame = SafeCFrame
            AddLog("AntiKick: SafeZone")
        end
        if hum and hum.PlatformStand then
            hum.PlatformStand = false
            AddLog("AntiFreeze")
        end
        if hum and hum.WalkSpeed > 120 then
            hum.WalkSpeed = _G.Settings.WalkSpeed
            AddLog("SpeedMonitor")
        end
    end)
end

-- ==============================================
-- الإعدادات والميزات
-- ==============================================
_G.Settings = { WalkSpeed = 65, FlySpeed = 70, ReachSize = 40 }
local Features = { 
    ESP = false, NoClip = false, Fly = false, Speed = false, 
    InfJump = false, KillAura = false, AutoPickup = false, 
    AutoFarm = false, GodMode = false, RGB = false,
    PanicHide = false, VisualTrails = false,
    AimLockBelly = false, AntiLag = false, Blur = false,
    FakeDeath = false, AntiAFK = false, FPSUnlocker = false,
    Invisible = false, HideName = false, SmartESP = false
}
local flyConn, moveDir, savedPos = nil, Vector3.zero, nil
local farmSpeed = 300 -- 5x أسرع من المشي العادي

local function GetChar() return Player.Character end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHum() return GetChar() and GetChar():FindFirstChild("Humanoid") end

local function Notify(t, m) game:GetService("StarterGui"):SetCore("SendNotification", {Title = t, Text = m, Duration = 2}) end

-- حقوق تلقائية كل 5 ثوانٍ
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chat and chat:FindFirstChild("SayMessageRequest") then
                chat.SayMessageRequest:FireServer("🐉 CYBER DRAGON V24 | المطور: عبدالله | TikTok: 7_v4n3x | Telegram: abood_7ro", "All")
            end
        end)
    end
end)

-- دوال الأهداف
local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then return p end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then return p end
        end
    end
    return nil
end

-- AUTO FARM الذهبي (يمشي بسرعة 5x ثم يقفز للالتقاط)
local function SmartCoinFarm()
    if not Features.AutoFarm then return end
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum then return end
    
    hum.WalkSpeed = farmSpeed
    
    local nearest, nearestDist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name == "Coin" or v.Name == "CoinContainer" or v.Name:find("Coin")) then
            local dist = (root.Position - v.Position).Magnitude
            if dist < nearestDist then nearestDist = dist; nearest = v end
        end
    end
    
    if nearest then
        hum:MoveTo(nearest.Position + Vector3.new(0, 2, 0))
        if nearestDist < 8 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.2)
        end
    else
        hum.WalkSpeed = _G.Settings.WalkSpeed
    end
end

-- AUTO PICKUP مضمون
local function GunMagnet()
    if not Features.AutoPickup then return end
    local root = GetRoot()
    if not root then return end
    local gun = nil
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and (v.Name == "Gun" or v.Name == "Revolver" or v.Name == "Pistol") then
            gun = v; break
        end
    end
    if gun then
        local oldPos = root.CFrame
        root.CFrame = gun:GetPivot() + Vector3.new(0, 2, 0)
        task.wait(0.2)
        pcall(function() firetouchinterest(root, gun, 0) firetouchinterest(root, gun, 1) end)
        root.CFrame = oldPos
    end
end

-- سحب وتجميد
local function PullAndFreeze(target)
    if not target or not target.Character then return end
    local root = GetRoot()
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if root and tRoot then
        tRoot.CFrame = root.CFrame * CFrame.new(0, 0, -3)
        tRoot.Anchored = true
        if target.Character:FindFirstChild("Humanoid") then target.Character.Humanoid.WalkSpeed = 0 end
    end
end

-- قتل لاعب
local function KillTarget(target)
    if not target or not target.Character then return end
    local tool = GetChar():FindFirstChildWhichIsA("Tool")
    if not tool then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    local root = GetRoot()
    if root then
        root.CFrame = CFrame.lookAt(root.Position, head.Position)
        task.wait(0.02)
        local rem = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot")
        if rem then rem:FireServer(head.Position) else tool:Activate() end
    end
end

-- قائمة اللاعبين
local function ShowPlayerList()
    local plist = Instance.new("ScreenGui", PlayerGui); plist.Name = "PlayerList"; plist.ResetOnSpawn = false
    local frame = Instance.new("Frame", plist)
    frame.Size = UDim2.new(0,200,0,300); frame.Position = UDim2.new(0.5,-100,0.5,-150)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,30); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,30); title.Text = "قائمة اللاعبين"; title.BackgroundColor3 = Color3.fromRGB(138,43,226)
    title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 14
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,0,1,-40); scroll.Position = UDim2.new(0,0,0,35)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,3)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local row = Instance.new("Frame", scroll)
            row.Size = UDim2.new(1,0,0,35); row.BackgroundColor3 = Color3.fromRGB(30,30,40)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
            local name = Instance.new("TextLabel", row)
            name.Size = UDim2.new(0.4,0,1,0); name.Text = p.Name; name.TextColor3 = Color3.new(1,1,1)
            name.BackgroundTransparency = 1; name.Font = Enum.Font.Gotham; name.TextSize = 11
            local killBtn = Instance.new("TextButton", row)
            killBtn.Size = UDim2.new(0,40,0,25); killBtn.Position = UDim2.new(0.45,0,0.1,0)
            killBtn.Text = "💀"; killBtn.BackgroundColor3 = Color3.fromRGB(200,0,0); killBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0,5)
            killBtn.MouseButton1Down:Connect(function() KillTarget(p) end)
            local pullBtn = Instance.new("TextButton", row)
            pullBtn.Size = UDim2.new(0,40,0,25); pullBtn.Position = UDim2.new(0.7,0,0.1,0)
            pullBtn.Text = "📌"; pullBtn.BackgroundColor3 = Color3.fromRGB(0,100,200); pullBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", pullBtn).CornerRadius = UDim.new(0,5)
            pullBtn.MouseButton1Down:Connect(function() PullAndFreeze(p) end)
        end
    end
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0,30,0,30); closeBtn.Position = UDim2.new(1,-35,0,0)
    closeBtn.Text = "✕"; closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0); closeBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,5)
    closeBtn.MouseButton1Down:Connect(function() plist:Destroy() end)
end

-- باقي الميزات (Fly, ESP, NoClip..)
local function HandleFly()
    if Features.Fly then
        if flyConn then flyConn:Disconnect() end
        if PlayerGui:FindFirstChild("DragonFly") then PlayerGui.DragonFly:Destroy() end
        local fg = Instance.new("ScreenGui", PlayerGui); fg.Name = "DragonFly"; fg.DisplayOrder = 999; fg.ResetOnSpawn = false
        local btnFrame = Instance.new("Frame", fg)
        btnFrame.Size = UDim2.new(0,150,0,150); btnFrame.Position = UDim2.new(0.05,0,0.4,0); btnFrame.BackgroundTransparency = 1
        local btns = {
            {N="▲", P=UDim2.new(0.35,0,0,0), D=Vector3.new(0,1,0)},
            {N="▼", P=UDim2.new(0.35,0,0.7,0), D=Vector3.new(0,-1,0)},
            {N="⇧", P=UDim2.new(0.35,0,0.35,0), D=Vector3.new(0,0,-1)},
            {N="⇩", P=UDim2.new(0.35,0,-0.35,0), D=Vector3.new(0,0,1)},
            {N="◄", P=UDim2.new(0,0,0.35,0), D=Vector3.new(-1,0,0)},
            {N="►", P=UDim2.new(0.7,0,0.35,0), D=Vector3.new(1,0,0)},
        }
        for _, i in pairs(btns) do
            local b = Instance.new("TextButton", btnFrame)
            b.Size = UDim2.new(0,45,0,45); b.Position = i.P; b.Text = i.N
            b.BackgroundColor3 = Color3.fromRGB(138,43,226); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 20; b.ZIndex = 10
            Instance.new("UICorner", b)
            b.MouseButton1Down:Connect(function() moveDir = i.D end); b.MouseButton1Up:Connect(function() moveDir = Vector3.zero end)
            b.TouchStarted:Connect(function() moveDir = i.D end); b.TouchEnded:Connect(function() moveDir = Vector3.zero end)
        end
        flyConn = RunService.Heartbeat:Connect(function()
            local root = GetRoot() if not root then return end
            local bg = root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", root)
            bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.CFrame = workspace.CurrentCamera.CFrame
            local bv = root:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", root)
            bv.Name = "FlyVel"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            if moveDir == Vector3.zero then bv.Velocity = Vector3.new(0,0.1,0)
            else
                local cam = workspace.CurrentCamera; local vel = Vector3.zero
                if moveDir.Z ~= 0 then vel += cam.CFrame.LookVector * -moveDir.Z end
                if moveDir.X ~= 0 then vel += cam.CFrame.RightVector * moveDir.X end
                if moveDir.Y ~= 0 then vel += Vector3.new(0,moveDir.Y,0) end
                bv.Velocity = vel * _G.Settings.FlySpeed
            end
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if PlayerGui:FindFirstChild("DragonFly") then PlayerGui.DragonFly:Destroy() end
        local r = GetRoot()
        if r then if r:FindFirstChild("FlyVel") then r.FlyVel:Destroy() end if r:FindFirstChild("FlyGyro") then r.FlyGyro:Destroy() end end
    end
end

local function FakeDeath()
    local char = GetChar() if not char then return end
    for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    local root = GetRoot(); local hum = GetHum()
    if root then root.Anchored = true end
    if hum then hum.PlatformStand = true end
    task.delay(3, function()
        if root then root.Anchored = false end
        if hum then hum.PlatformStand = false end
    end)
end

local function AntiAFK() if not Features.AntiAFK then return end; Player.Idled:Connect(function() VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(2) VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end
local function FPSUnlocker() if Features.FPSUnlocker then setfpscap(144) else setfpscap(60) end end
local function ServerHop() pcall(function() local data = game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=100") local json = HttpService:JSONDecode(data) local servers = {} for _, v in pairs(json.data) do if v.id ~= game.JobId then table.insert(servers, v.id) end end if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)]) end end) end
local function RejoinServer() TeleportService:Teleport(game.PlaceId, Player) end
local function PanicHide() Features.PanicHide = not Features.PanicHide; MainFrame.Visible = not Features.PanicHide; Float.Visible = not Features.PanicHide end

local function RoleWarnings()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
            local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
            if head:FindFirstChild("RoleWarning") then head.RoleWarning:Destroy() end
            if isM or isS then
                local bg = Instance.new("BillboardGui", head)
                bg.Name = "RoleWarning"; bg.Size = UDim2.new(0,180,0,25)
                bg.StudsOffset = Vector3.new(0, 3.5, 0); bg.AlwaysOnTop = true
                local tl = Instance.new("TextLabel", bg)
                tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
                tl.TextSize = 14; tl.Font = Enum.Font.GothamBold; tl.TextStrokeTransparency = 0
                if isM then tl.Text = "⚠️ القاتل!"; tl.TextColor3 = Color3.new(1,0,0)
                elseif isS then tl.Text = "🛡️ الشريف!"; tl.TextColor3 = Color3.new(0,0.4,1) end
            end
        end
    end
end

-- ==============================================
-- الواجهة العربية الكاملة
-- ==============================================
local MainGui = Instance.new("ScreenGui", PlayerGui); MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 520, 0, 420); MainFrame.Position = UDim2.new(0.5,-260,0.5,-210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10,5,20); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1,0,0,45); TopBar.BackgroundColor3 = Color3.fromRGB(138,43,226)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0,10)
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1,0,1,0); Title.Text = "🐉 CYBER DRAGON V24 | المطور: عبدالله"
Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1; Title.TextSize = 15

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0,130,1,-55); Sidebar.Position = UDim2.new(0,5,0,50); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0,3)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1,-140,1,-55); Content.Position = UDim2.new(0,140,0,50); Content.BackgroundTransparency = 1

local Tabs = {}
local function NewTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1,0,0,36); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25,25,35); b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham; b.TextSize = 10; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local f = Instance.new("ScrollingFrame", Content)
    f.Size = UDim2.new(1,0,1,0); f.Visible = false; f.BackgroundTransparency = 1; f.CanvasSize = UDim2.new(0,0,12,0); f.ScrollBarThickness = 2
    Instance.new("UIListLayout", f).Padding = UDim.new(0,3)
    b.MouseButton1Down:Connect(function() for _, v in pairs(Tabs) do v.Visible = false end f.Visible = true end)
    table.insert(Tabs, f); return f
end

local function AddToggle(parent, txt, feat, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95,0,0,33); b.Text = txt .. " [إيقاف]"
    b.BackgroundColor3 = Color3.fromRGB(35,35,50); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
    b.MouseButton1Down:Connect(function()
        Features[feat] = not Features[feat]
        b.Text = txt .. (Features[feat] and " [تشغيل]" or " [إيقاف]")
        b.BackgroundColor3 = Features[feat] and Color3.fromRGB(0,170,0) or Color3.fromRGB(35,35,50)
        if cb then cb(Features[feat]) end
    end)
end

local function AddButton(parent, txt, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95,0,0,33); b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(138,43,226); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
    b.MouseButton1Down:Connect(cb)
end

local function AddSlider(parent, txt, minVal, maxVal, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(0.95,0,0,50); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,16); label.Text = txt .. ": " .. tostring(_G.Settings.WalkSpeed)
    label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 11
    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new(1,0,0,20); slider.Position = UDim2.new(0,0,0,22); slider.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0,10)
    local fill = Instance.new("Frame", slider); fill.Size = UDim2.new(0.3,0,1,0); fill.BackgroundColor3 = Color3.fromRGB(138,43,226); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,10)
    local thumb = Instance.new("TextButton", slider)
    thumb.Size = UDim2.new(0,22,0,20); thumb.Position = UDim2.new(0.3,-11,0,0); thumb.Text = ""
    thumb.BackgroundColor3 = Color3.new(1,1,1); thumb.BorderSizePixel = 0; Instance.new("UICorner", thumb).CornerRadius = UDim.new(0,10)
    local dragging = false
    thumb.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation()
            local percent = math.clamp((mousePos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor(minVal + (maxVal - minVal) * percent)
            fill.Size = UDim2.new(percent,0,1,0); thumb.Position = UDim2.new(percent,-11,0,0)
            label.Text = txt .. ": " .. tostring(value); callback(value)
        end
    end)
end

-- التبويبات
local T1 = NewTab("🏠 الرئيسية"); T1.Visible = true
local T2 = NewTab("⚡ الحركة")
local T3 = NewTab("⚔️ الصيد")
local T4 = NewTab("💰 الاقتصاد")
local T5 = NewTab("🌐 السيرفر")
local T6 = NewTab("👑 الهيبة")
local T7 = NewTab("⚙️ الإعدادات")

AddToggle(T1, "👁️ ESP", "ESP")
AddToggle(T1, "🛡️ God Mode", "GodMode")
AddToggle(T1, "🌈 RGB", "RGB")
AddToggle(T1, "🎯 AimLock", "AimLockBelly")
AddToggle(T1, "🏃 السرعة", "Speed")
AddSlider(T1, "🏃 السرعة", 16, 200, function(v) _G.Settings.WalkSpeed = v; local h = GetHum(); if h then h.WalkSpeed = v end end)

AddToggle(T2, "🕊️ طيران", "Fly", function() HandleFly() end)
AddToggle(T2, "🚪 NoClip", "NoClip")
AddToggle(T2, "🦘 قفز لا نهائي", "InfJump")
AddToggle(T2, "👻 تظاهر بالموت", "FakeDeath", function() if Features.FakeDeath then FakeDeath() end end)
AddButton(T2, "🚨 إخفاء القائمة", PanicHide)

AddButton(T3, "📌 سحب القاتل", function() local m = GetMurderer(); if m then PullAndFreeze(m) end end)
AddButton(T3, "📌 سحب الشريف", function() local s = GetSheriff(); if s then PullAndFreeze(s) end end)
AddButton(T3, "📋 قائمة اللاعبين", ShowPlayerList)

AddToggle(T4, "💰 Auto Farm السريع", "AutoFarm")
AddToggle(T4, "🔫 Auto Pickup", "AutoPickup")

AddButton(T5, "🌐 Server Hop", ServerHop)
AddButton(T5, "🔄 Rejoin", RejoinServer)

AddButton(T6, "📢 إعلان", function()
    pcall(function()
        local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chat and chat:FindFirstChild("SayMessageRequest") then
            chat.SayMessageRequest:FireServer("🐉 CYBER DRAGON V24 | المطور: عبدالله", "All")
        end
    end)
end)
AddToggle(T6, "🔥 Visual Trails", "VisualTrails", function(s) if s then CreateTrail() end end)
AddButton(T6, "🌌 فضاء", function()
    for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Sky") or v:IsA("Atmosphere") then v:Destroy() end end
    local sky = Instance.new("Sky", Lighting)
    sky.SkyboxBk = "rbxassetid://12064107"; sky.SkyboxDn = "rbxassetid://12064115"
    sky.SkyboxFt = "rbxassetid://12064121"; sky.SkyboxLf = "rbxassetid://12064127"
    sky.SkyboxRt = "rbxassetid://12064133"; sky.SkyboxUp = "rbxassetid://12064139"
    Lighting.ClockTime = 14; Lighting.Brightness = 3; Lighting.GlobalShadows = false
end)
AddToggle(T6, "🌫️ Blur", "Blur", function(s)
    local b = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect", Lighting); b.Size = s and 15 or 0
end)
AddToggle(T6, "⚡ Anti Lag", "AntiLag", function(s)
    Lighting.GlobalShadows = not s; settings().Rendering.QualityLevel = s and 1 or 2
end)
AddButton(T6, "🗑️ Memory", function() collectgarbage("collect") end)

AddToggle(T7, "⏰ Anti AFK", "AntiAFK", function() if Features.AntiAFK then AntiAFK() end end)
AddToggle(T7, "⚡ FPS", "FPSUnlocker", FPSUnlocker)

-- معلومات الحساب
local info = Instance.new("Frame", T7)
info.Size = UDim2.new(0.95,0,0,180); info.BackgroundColor3 = Color3.fromRGB(25,25,35)
Instance.new("UICorner", info).CornerRadius = UDim.new(0,8)
local avatar = Instance.new("ImageLabel", info)
avatar.Size = UDim2.new(0,50,0,50); avatar.Position = UDim2.new(0.05,0,0.05,0)
pcall(function() avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)
local infoText = Instance.new("TextLabel", info)
infoText.Size = UDim2.new(0.6,0,0.7,0); infoText.Position = UDim2.new(0.35,0,0.05,0)
infoText.Text = "👤 " .. Player.Name .. "\n🆔 " .. Player.UserId .. "\n📅 عمر الحساب: " .. Player.AccountAge .. " يوم"
infoText.TextColor3 = Color3.new(1,1,1); infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham; infoText.TextSize = 11; infoText.TextXAlignment = Enum.TextXAlignment.Left; infoText.TextYAlignment = Enum.TextYAlignment.Center
local fpsLabel = Instance.new("TextLabel", info)
fpsLabel.Size = UDim2.new(1,0,0,20); fpsLabel.Position = UDim2.new(0,0,0,0.75)
fpsLabel.Text = "FPS: -- | Ping: --ms"
fpsLabel.TextColor3 = Color3.new(0,1,0); fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.Gotham; fpsLabel.TextSize = 12; fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
spawn(function() while task.wait(1) do pcall(function() local fps = math.floor(1 / RunService.RenderStepped:Wait()) local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) fpsLabel.Text = "FPS: " .. fps .. " | Ping: " .. ping .. "ms" end) end end)

-- زر التنين العائم
local Float = Instance.new("ImageButton", MainGui)
Float.Size = UDim2.new(0,55,0,55); Float.Position = UDim2.new(0.83,0,0.78,0)
Float.BackgroundColor3 = Color3.fromRGB(138,43,226); Float.Draggable = true
Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)
local FloatTxt = Instance.new("TextLabel", Float)
FloatTxt.Size = UDim2.new(1,0,1,0); FloatTxt.Text = "🐉"; FloatTxt.TextSize = 30; FloatTxt.BackgroundTransparency = 1; FloatTxt.TextColor3 = Color3.new(1,1,1)
Float.MouseButton1Down:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ==============================================
-- الحلقة الرئيسية
-- ==============================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        local h = GetHum(); local r = GetRoot(); local char = GetChar()
        if not char or not r then return end
        
        if Features.Speed and h then h.WalkSpeed = _G.Settings.WalkSpeed end
        if Features.GodMode and h then h.MaxHealth = 9e9; h.Health = 9e9 end
        if Features.NoClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if Features.InfJump and UIS:IsKeyDown(Enum.KeyCode.Space) then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        if Features.RGB then TopBar.BackgroundColor3 = Color3.fromHSV(tick()%5/5, 1, 1) end
        
        if Features.AutoFarm then SmartCoinFarm() end
        if Features.AutoPickup then GunMagnet() end
        
        if Features.AimLockBelly then
            local target = GetMurderer() or GetSheriff()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
        
        if Features.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    local hl = p.Character:FindFirstChild("DragonHL") or Instance.new("Highlight", p.Character)
                    hl.Name = "DragonHL"; hl.Enabled = true
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    hl.FillColor = isM and Color3.new(1,0,0) or (isS and Color3.new(0,0.4,1) or Color3.new(0,1,0))
                end
            end
        end
        
        SupremeShield()
        RoleWarnings()
    end)
end)

UIS.JumpRequest:Connect(function() if Features.InfJump and GetHum() then GetHum():ChangeState(Enum.HumanoidStateType.Jumping) end end)

Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid")
    if Features.Speed and hum then hum.WalkSpeed = _G.Settings.WalkSpeed end
    if Features.GodMode and hum then hum.MaxHealth = 9e9; hum.Health = 9e9 end
    if Features.NoClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end)

Notify("CYBER DRAGON V24", "النسخة الذهبية النهائية جاهزة! 🐉🔥", 5)