-- [[ CYBER DRAGON V23 - THE LEGEND - PERFECTED ]]
-- Dev: Abdullah
-- TikTok: 7_v4n3x | Telegram: abood_7ro
-- Roblox: eonsali07807863909

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

_G.Settings = { WalkSpeed = 65, FlySpeed = 70, ReachSize = 40 }
local Features = { 
    ESP = false, NoClip = false, Fly = false, Speed = false, 
    InfJump = false, KillAura = false, AutoPickup = false, 
    AutoFarm = false, GodMode = false, RGB = false,
    PanicHide = false, FreezeMurderer = false, VisualTrails = false
}
local flyConn, moveDir, savedPos = nil, Vector3.zero, nil

local function GetChar() return Player.Character end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHum() return GetChar() and GetChar():FindFirstChild("Humanoid") end

local function Notify(t, m)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = t, Text = m, Duration = 3})
end

-- [ حقوق تلقائية ]
local function Announce()
    task.spawn(function()
        while true do
            task.wait(30)
            pcall(function()
                local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chat and chat:FindFirstChild("SayMessageRequest") then
                    chat.SayMessageRequest:FireServer("🐉 CYBER DRAGON V23 | Dev: Abdullah | TikTok: 7_v4n3x | Telegram: abood_7ro", "All")
                end
            end)
        end
    end)
end
Announce()

-- [ ANTI-KICK ]
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" then return nil end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- [ MURDERER TARGET ]
local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
            if isM then return p end
        end
    end
    return nil
end

-- [ SMART COIN FARM - الأقرب فالأقرب ]
local function SmartCoinFarm()
    if not Features.AutoFarm then return end
    local root = GetRoot()
    if not root then return end
    local nearest, nearestDist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name == "Coin" or v.Name == "CoinContainer") and v:IsA("BasePart") then
            local dist = (root.Position - v.Position).Magnitude
            if dist < nearestDist then nearestDist = dist; nearest = v end
        end
    end
    if nearest then
        root.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.01)
        firetouchinterest(root, nearest, 0)
        firetouchinterest(root, nearest, 1)
    end
end

-- [ GUN MAGNET - مع خيار Backup للانتقال والرجوع ]
local function GunMagnet()
    local root = GetRoot()
    if not root then return false end
    local gun = workspace:FindFirstChild("GunDrop")
    if not gun then return false end
    
    -- الطريقة 1: firetouchinterest
    local oldPos = root.CFrame
    root.CFrame = gun.CFrame + Vector3.new(0, 2, 0)
    task.wait(0.1)
    pcall(function()
        firetouchinterest(root, gun, 0)
        firetouchinterest(root, gun, 1)
    end)
    
    -- التحقق إذا أخذ المسدس
    task.wait(0.3)
    local hasGun = Player.Backpack:FindFirstChild("Gun") or GetChar():FindFirstChild("Gun")
    
    if not hasGun then
        -- الطريقة 2 (Backup): الانتقال للمسدس والرجوع
        root.CFrame = gun.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.5)
        root.CFrame = oldPos
        Notify("Gun", "Backup method used!")
    else
        root.CFrame = oldPos
    end
    return true
end

-- [ AUTO VICTORY ]
local function AutoVictory()
    local m = GetMurderer()
    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
        local root = GetRoot()
        if root then
            root.CFrame = m.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            local tool = GetChar():FindFirstChildWhichIsA("Tool")
            if tool then
                local rem = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot")
                if rem then rem:FireServer(m.Character.Head.Position) else tool:Activate() end
            end
        end
    end
end

-- [ MURDERER FREEZE ]
local function FreezeMurderer()
    local m = GetMurderer()
    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
        m.Character.HumanoidRootPart.Anchored = true
        m.Character.Humanoid.WalkSpeed = 0
        Notify("تجميد", "تم شل حركة القاتل!")
    end
end

-- [ SERVER HOP ]
local function ServerHop()
    local servers = {}
    pcall(function()
        local data = game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=100")
        local json = HttpService:JSONDecode(data)
        for _, v in pairs(json.data) do
            if v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
    end)
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end

-- [ VISUAL TRAILS ]
local function CreateTrail()
    local root = GetRoot()
    if not root then return nil end
    local trail = Instance.new("ParticleEmitter", root)
    trail.Texture = "rbxassetid://1234567890"
    trail.Rate = 50
    trail.Lifetime = NumberRange.new(0.5)
    trail.Color = ColorSequence.new(Color3.new(1, 0.3, 0))
    return trail
end

-- [ FLY - مع BodyGyro لتثبيت التوازن + أزرار للموبايل ]
local function HandleFly()
    if Features.Fly then
        if flyConn then flyConn:Disconnect() end
        if PlayerGui:FindFirstChild("DragonFly") then PlayerGui.DragonFly:Destroy() end
        
        -- أزرار للموبايل
        local fg = Instance.new("ScreenGui", PlayerGui)
        fg.Name = "DragonFly"; fg.DisplayOrder = 999; fg.ResetOnSpawn = false
        
        local btnFrame = Instance.new("Frame", fg)
        btnFrame.Size = UDim2.new(0, 150, 0, 150)
        btnFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
        btnFrame.BackgroundTransparency = 1
        
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
            b.Size = UDim2.new(0, 45, 0, 45); b.Position = i.P; b.Text = i.N
            b.BackgroundColor3 = Color3.fromRGB(138, 43, 226); b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.GothamBold; b.TextSize = 20; b.ZIndex = 10
            Instance.new("UICorner", b)
            b.MouseButton1Down:Connect(function() moveDir = i.D end)
            b.MouseButton1Up:Connect(function() moveDir = Vector3.zero end)
            b.TouchStarted:Connect(function() moveDir = i.D end)
            b.TouchEnded:Connect(function() moveDir = Vector3.zero end)
        end
        
        flyConn = RunService.Heartbeat:Connect(function()
            local root = GetRoot()
            if not root then return end
            
            -- BodyGyro للتثبيت
            local bg = root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", root)
            bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = workspace.CurrentCamera.CFrame
            
            -- BodyVelocity للحركة
            local bv = root:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", root)
            bv.Name = "FlyVel"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            if moveDir == Vector3.zero then
                bv.Velocity = Vector3.new(0, 0.1, 0)
            else
                local cam = workspace.CurrentCamera
                local vel = Vector3.zero
                if moveDir.Z ~= 0 then vel += cam.CFrame.LookVector * -moveDir.Z end
                if moveDir.X ~= 0 then vel += cam.CFrame.RightVector * moveDir.X end
                if moveDir.Y ~= 0 then vel += Vector3.new(0, moveDir.Y, 0) end
                bv.Velocity = vel * _G.Settings.FlySpeed
            end
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if PlayerGui:FindFirstChild("DragonFly") then PlayerGui.DragonFly:Destroy() end
        local r = GetRoot()
        if r then
            if r:FindFirstChild("FlyVel") then r.FlyVel:Destroy() end
            if r:FindFirstChild("FlyGyro") then r.FlyGyro:Destroy() end
        end
    end
end

-- [ PANIC HIDE ]
local function PanicHide()
    Features.PanicHide = not Features.PanicHide
    MainFrame.Visible = not Features.PanicHide
    Float.Visible = not Features.PanicHide
    Notify("Panic", Features.PanicHide and "Interface Hidden!" or "Interface Visible!")
end

-- [ UI - 7 TABS ]
local MainGui = Instance.new("ScreenGui", PlayerGui); MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 520, 0, 400); MainFrame.Position = UDim2.new(0.5,-260,0.5,-200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 20); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "🐉 CYBER DRAGON V23 | Dev: Abdullah"
Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1; Title.TextSize = 16

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -55); Sidebar.Position = UDim2.new(0, 5, 0, 50); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 4)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -150, 1, -55); Content.Position = UDim2.new(0, 150, 0, 50); Content.BackgroundTransparency = 1

local Tabs = {}
local function NewTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 40); b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 35); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local f = Instance.new("ScrollingFrame", Content)
    f.Size = UDim2.new(1, 0, 1, 0); f.Visible = false; f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0,0,8,0); f.ScrollBarThickness = 2
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    
    b.MouseButton1Down:Connect(function()
        for _, v in pairs(Tabs) do v.Visible = false end
        f.Visible = true
    end)
    table.insert(Tabs, f)
    return f
end

local function AddToggle(parent, txt, feat, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt .. " [OFF]"
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Down:Connect(function()
        Features[feat] = not Features[feat]
        b.Text = txt .. (Features[feat] and " [ON]" or " [OFF]")
        b.BackgroundColor3 = Features[feat] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(35, 35, 50)
        if cb then cb(Features[feat]) end
    end)
end

local function AddButton(parent, txt, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(138, 43, 226); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Down:Connect(cb)
end

local function AddSlider(parent, txt, minVal, maxVal, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 55); frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 18); label.Text = txt .. ": " .. tostring(_G.Settings.WalkSpeed)
    label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 12
    
    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new(1, 0, 0, 22); slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 11)
    
    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new(0.3, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 11)
    
    local thumb = Instance.new("TextButton", slider)
    thumb.Size = UDim2.new(0, 25, 0, 22); thumb.Position = UDim2.new(0.3, -12, 0, 0); thumb.Text = ""
    thumb.BackgroundColor3 = Color3.new(1,1,1); thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 11)
    
    local dragging = false
    thumb.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
            local value = math.floor(minVal + (maxVal - minVal) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, -12, 0, 0)
            label.Text = txt .. ": " .. tostring(value)
            callback(value)
        end
    end)
end

-- [ CREATE ALL 7 TABS ]
local T1 = NewTab("🏠 الرئيسية"); T1.Visible = true
local T2 = NewTab("⚡ الحركة")
local T3 = NewTab("⚔️ الهجوم")
local T4 = NewTab("💰 الاقتصاد")
local T5 = NewTab("🔫 السلاح")
local T6 = NewTab("🌐 السيرفر")
local T7 = NewTab("👑 الهيبة")

-- TAB 1 - الرئيسية
AddToggle(T1, "👁️ ESP Master", "ESP", nil)
AddToggle(T1, "🛡️ God Mode", "GodMode", nil)
AddToggle(T1, "🌈 RGB Theme", "RGB", nil)
AddSlider(T1, "🏃 Walk Speed", 16, 200, function(v) _G.Settings.WalkSpeed = v; local h = GetHum(); if h then h.WalkSpeed = v end end)

-- TAB 2 - الحركة
AddToggle(T2, "🕊️ Fly (Mobile)", "Fly", function() HandleFly() end)
AddToggle(T2, "🚪 NoClip", "NoClip", nil)
AddToggle(T2, "🦘 Inf Jump", "InfJump", nil)
AddButton(T2, "🚨 Panic Hide", PanicHide)

-- TAB 3 - الهجوم
AddToggle(T3, "⚔️ Kill Aura", "KillAura", nil)
AddButton(T3, "❄️ تجميد القاتل", FreezeMurderer)
AddButton(T3, "🎯 Auto Victory", AutoVictory)

-- TAB 4 - الاقتصاد
AddToggle(T4, "💰 Smart Farm", "AutoFarm", nil)
AddToggle(T4, "🔫 Auto Pickup", "AutoPickup", nil)

-- TAB 5 - السلاح
AddButton(T5, "🧲 Gun Magnet", GunMagnet)

-- TAB 6 - السيرفر
AddButton(T6, "🌐 Server Hop", ServerHop)

-- TAB 7 - الهيبة
AddButton(T7, "📢 Chat Identity", Announce)
AddToggle(T7, "🔥 Visual Trails", "VisualTrails", function(s)
    if s then CreateTrail() end
end)

-- [ FLOAT BUTTON ]
local Float = Instance.new("ImageButton", MainGui)
Float.Size = UDim2.new(0, 55, 0, 55); Float.Position = UDim2.new(0.83, 0, 0.78, 0)
Float.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Float.Draggable = true
Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)
local FloatTxt = Instance.new("TextLabel", Float)
FloatTxt.Size = UDim2.new(1, 0, 1, 0); FloatTxt.Text = "🐉"
FloatTxt.TextSize = 30; FloatTxt.BackgroundTransparency = 1; FloatTxt.TextColor3 = Color3.new(1, 1, 1)
Float.MouseButton1Down:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ MAIN HEARTBEAT LOOP ]
RunService.Heartbeat:Connect(function()
    pcall(function()
        local h = GetHum(); local r = GetRoot(); local char = GetChar()
        if not char or not r then return end
        
        if Features.Speed and h then h.WalkSpeed = _G.Settings.WalkSpeed end
        if Features.GodMode and h then h.MaxHealth = 9e9; h.Health = 9e9 end
        if Features.NoClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if Features.InfJump and UIS:IsKeyDown(Enum.KeyCode.Space) then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        if Features.RGB then TopBar.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
        if Features.AutoFarm then SmartCoinFarm() end
        if Features.AutoPickup then GunMagnet() end
        
        -- KillAura
        if Features.KillAura then
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        if (r.Position - v.Character.HumanoidRootPart.Position).Magnitude < 20 then
                            local rem = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot")
                            if rem then rem:FireServer(v.Character.Head.Position) else tool:Activate() end
                        end
                    end
                end
            end
        end
        
        -- ESP Master
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
    end)
end)

UIS.JumpRequest:Connect(function()
    if Features.InfJump and GetHum() then GetHum():ChangeState(Enum.HumanoidStateType.Jumping) end
end)

Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid")
    if Features.Speed and hum then hum.WalkSpeed = _G.Settings.WalkSpeed end
    if Features.GodMode and hum then hum.MaxHealth = 9e9; hum.Health = 9e9 end
    if Features.NoClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end)

Notify("CYBER DRAGON V23", "Perfect 10/10! 🐉🔥", 5)