-- [[ CYBER DRAGON V22 - FINAL PERFECT ]]
-- Dev: Abdullah
-- TikTok: 7_v4n3x | Telegram: abood_7ro
-- Roblox: eonsali07807863909

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

_G.Settings = { WalkSpeed = 65, FlySpeed = 70, ReachSize = 40 }
local Features = { 
    ESP = false, SmartESP = false, Invisible = false, NoClip = false, 
    Fly = false, Speed = false, InfiniteJump = false, GodMode = false, 
    AutoFarm = false, AutoPickup = false, KillAura = false, Reach = false, 
    AimLock = false, AntiLag = false, HideName = false, Blur = false 
}
local flyConn, moveDir, savedPos = nil, Vector3.zero, nil

local function GetChar() return Player.Character end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHum() return GetChar() and GetChar():FindFirstChild("Humanoid") end

local function Notify(t, m)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = t, Text = m, Duration = 2})
end

-- [ هدف ذكي - القاتل فقط ]
local function GetMurdererTarget()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
            if isM then return p end
        end
    end
    return nil
end

-- [ FLY للجوال - نسخة الأزرار الظاهرة ]
local function HandleFly()
    if Features.Fly then
        if flyConn then flyConn:Disconnect() end
        if PlayerGui:FindFirstChild("FlyUI") then PlayerGui.FlyUI:Destroy() end
        
        local fg = Instance.new("ScreenGui", PlayerGui)
        fg.Name = "FlyUI"
        fg.DisplayOrder = 999
        fg.ResetOnSpawn = false
        
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
            b.Size = UDim2.new(0, 45, 0, 45)
            b.Position = i.P
            b.Text = i.N
            b.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 20
            b.ZIndex = 10
            Instance.new("UICorner", b)
            
            b.MouseButton1Down:Connect(function() moveDir = i.D end)
            b.MouseButton1Up:Connect(function() moveDir = Vector3.zero end)
            b.TouchStarted:Connect(function() moveDir = i.D end)
            b.TouchEnded:Connect(function() moveDir = Vector3.zero end)
        end
        
        flyConn = RunService.Heartbeat:Connect(function()
            local r = GetRoot()
            if not r then return end
            local bv = r:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", r)
            bv.Name = "FlyVel"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            
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
        if PlayerGui:FindFirstChild("FlyUI") then PlayerGui.FlyUI:Destroy() end
        local r = GetRoot()
        if r and r:FindFirstChild("FlyVel") then r.FlyVel:Destroy() end
    end
end

-- [ AUTO FARM - تجميع العملات ]
local function AutoFarmCoins()
    if not Features.AutoFarm then return end
    local root = GetRoot()
    if not root then return end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if (v.Name == "Coin" or v.Name == "CoinContainer") and v:IsA("BasePart") then
            if Features.AutoFarm then
                root.CFrame = v.CFrame
                firetouchinterest(root, v, 0)
                firetouchinterest(root, v, 1)
                task.wait(0.01) 
            end
        end
    end
end

-- [ AUTO PICKUP ]
local function AutoPickupGun()
    local root = GetRoot()
    if not root then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "GunDrop" then
            root.CFrame = v.CFrame + Vector3.new(0,3,0)
            return
        end
    end
end

-- [ إطلاق نار - يجمد القاتل وما يرجع ]
local function ShootAndFreeze()
    local target = GetMurdererTarget()
    if not target or not target.Character then
        Notify("خطأ", "لا يوجد قاتل!")
        return
    end
    
    local tool = GetChar():FindFirstChildWhichIsA("Tool")
    if not tool then
        Notify("خطأ", "امسك السلاح أولاً!")
        return
    end
    
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local tHum = target.Character:FindFirstChild("Humanoid")
    local head = target.Character:FindFirstChild("Head")
    if not tRoot or not head then return end
    
    tRoot.Anchored = true
    tRoot.CFrame = GetRoot().CFrame * CFrame.new(0, 0, -3)
    if tHum then tHum.WalkSpeed = 0 end
    
    GetRoot().CFrame = CFrame.lookAt(GetRoot().Position, head.Position)
    task.wait(0.02)
    
    local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot") or tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("Attack")
    if remote then
        for i = 1, 3 do
            remote:FireServer(head.Position)
            task.wait(0.05)
        end
    else
        for i = 1, 3 do
            tool:Activate()
            task.wait(0.05)
        end
    end
    
    Notify("إطلاق نار", "تم القضاء على القاتل! 💀")
end

-- [ قتل الجميع ]
local function KillAll()
    local tool = GetChar():FindFirstChildOfClass("Tool")
    if not tool then
        Notify("خطأ", "لازم تمسك السلاح بيدك أولاً!")
        return
    end
    for _, victim in pairs(Players:GetPlayers()) do
        if victim ~= Player and victim.Character and victim.Character:FindFirstChild("Head") then
            pcall(function()
                local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot") or tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("Attack")
                if remote then
                    remote:FireServer(victim.Character.Head.Position)
                else
                    tool:Activate()
                end
            end)
        end
    end
    Notify("قتل", "تم إعدام السيرفر بنجاح!")
end

-- [ كاشف الأدوار المطور - شريف وقاتل ]
local function MurdererAlert()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
            local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
            
            if head:FindFirstChild("RoleTag") then head.RoleTag:Destroy() end

            if isM or isS then
                local bg = Instance.new("BillboardGui", head)
                bg.Name = "RoleTag"
                bg.Size = UDim2.new(0, 200, 0, 50)
                bg.StudsOffset = Vector3.new(0, 3, 0)
                bg.AlwaysOnTop = true
                
                local tl = Instance.new("TextLabel", bg)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.TextSize = 16
                tl.Font = Enum.Font.GothamBold
                tl.TextStrokeTransparency = 0
                
                if isM then
                    tl.Text = "⚠️ تحذير: هذا القاتل! ⚠️"
                    tl.TextColor3 = Color3.new(1, 0, 0)
                elseif isS then
                    tl.Text = "🛡️ الشريف (معه سلاح) 🛡️"
                    tl.TextColor3 = Color3.new(0, 0, 1)
                end
            end
        end
    end
end

-- [ NoClip مستمر ]
RunService.Stepped:Connect(function()
    if Features.NoClip then
        local char = GetChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide == true then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- [ UI ]
local MainGui = Instance.new("ScreenGui", PlayerGui); MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 340, 0, 480); MainFrame.Position = UDim2.new(0.5,-170,0.45,-240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 20); MainFrame.Draggable = true; MainFrame.Active = true; MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,45); Title.Text = "🐉 CYBER DRAGON V22"
Title.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextSize = 18

local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Size = UDim2.new(1,0,0,40); TabHolder.Position = UDim2.new(0,0,0,45); TabHolder.BackgroundTransparency = 1
local list = Instance.new("UIListLayout", TabHolder); list.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1,0,1,-95); Pages.Position = UDim2.new(0,0,0,90); Pages.BackgroundTransparency = 1

local function CreatePage()
    local s = Instance.new("ScrollingFrame", Pages); s.Size = UDim2.new(1,0,1,0); s.Visible = false
    s.BackgroundTransparency = 1; s.CanvasSize = UDim2.new(0,0,6,0); s.ScrollBarThickness = 2
    Instance.new("UIListLayout", s).Padding = UDim.new(0,4); return s
end

local P1, P2, P3, P4 = CreatePage(), CreatePage(), CreatePage(), CreatePage()
P1.Visible = true

local function AddTab(n, p)
    local b = Instance.new("TextButton", TabHolder); b.Size = UDim2.new(0.25,0,1,0); b.Text = n
    b.BackgroundColor3 = Color3.fromRGB(25,15,45); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 11
    b.MouseButton1Down:Connect(function() for _,v in pairs(Pages:GetChildren()) do v.Visible = false end; p.Visible = true end)
end
AddTab("⚡رئيسي", P1); AddTab("🎯قتال", P2); AddTab("⚙️منوع", P3); AddTab("🎨ثيم", P4)

local function AddToggle(parent, text, feat, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.9,0,0,35)
    b.Text = text .. (Features[feat] and " [✅]" or " [❌]")
    b.BackgroundColor3 = Features[feat] and Color3.fromRGB(0,150,0) or Color3.fromRGB(35,25,55)
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
    b.MouseButton1Down:Connect(function() 
        Features[feat] = not Features[feat]
        b.Text = text .. (Features[feat] and " [✅]" or " [❌]")
        b.BackgroundColor3 = Features[feat] and Color3.fromRGB(0,150,0) or Color3.fromRGB(35,25,55)
        if cb then cb(Features[feat]) end 
    end)
end

local function AddButton(parent, text, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.9,0,0,35); b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(55,40,90); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7); b.MouseButton1Down:Connect(cb)
end

-- [ تبويب رئيسي ]
AddToggle(P1, "👁️ SmartESP", "SmartESP", nil)
AddToggle(P1, "👁️ ESP", "ESP", nil)
AddToggle(P1, "👻 Invisible", "Invisible", function(s) 
    local char = GetChar()
    if char then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = s and 1 or 0 end end end
end)
AddToggle(P1, "🚪 NoClip", "NoClip", nil)
AddToggle(P1, "🕊️ Fly", "Fly", function() HandleFly() end)
AddToggle(P1, "🏃 Speed", "Speed", nil)
AddToggle(P1, "🦘 Jump", "InfiniteJump", nil)
AddToggle(P1, "🛡️ GodMode", "GodMode", nil)
AddToggle(P1, "🎯 AimLock", "AimLock", nil)

-- [ تبويب قتال ]
AddButton(P2, "🔫 إطلاق نار (تجميد + قتل)", ShootAndFreeze)
AddToggle(P2, "⚔️ KillAura", "KillAura", nil)
AddToggle(P2, "📏 Reach", "Reach", nil)
AddToggle(P2, "🔫 AutoPickup", "AutoPickup", nil)
AddToggle(P2, "💰 AutoFarm", "AutoFarm", nil)
AddButton(P2, "💀 قتل الجميع", KillAll)
AddButton(P2, "🔫 اذهب للمسدس", function()
    for _,v in pairs(Workspace:GetDescendants()) do if v.Name == "GunDrop" then GetRoot().CFrame = v.CFrame + Vector3.new(0,3,0) end end
end)
AddButton(P2, "📌 سحب الأقرب", function()
    local t = GetMurdererTarget(); if t then t.Character.HumanoidRootPart.CFrame = GetRoot().CFrame * CFrame.new(0,0,-3) end
end)
AddButton(P2, "🔄 خلف القاتل", function()
    local t = GetMurdererTarget()
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        local tRoot = t.Character.HumanoidRootPart
        local behindPos = tRoot.CFrame * CFrame.new(0, 0, -3)
        GetRoot().CFrame = CFrame.lookAt(behindPos.Position, tRoot.Position)
        Notify("تم", "أنت خلف القاتل والمسدس موجه عليه!")
    end
end)

-- [ تبويب منوع ]
AddToggle(P3, "🚫 HideName", "HideName", nil)
AddToggle(P3, "⚡ AntiLag", "AntiLag", function(s) 
    if s then for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end end end
end)
AddButton(P3, "💾 حفظ", function() savedPos = GetRoot().CFrame end)
AddButton(P3, "🔄 استرجاع", function() if savedPos then GetRoot().CFrame = savedPos end end)
AddButton(P3, "🎭 تنكر عشوائي (للکل)", function()
    local allPlayers = Players:GetPlayers()
    local target = nil
    for i = 1, 10 do
        local p = allPlayers[math.random(1, #allPlayers)]
        if p ~= Player then target = p; break end
    end
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        pcall(function()
            local hum = GetHum()
            local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
            if hum and desc then
                hum:ApplyDescription(desc)
                Player.DisplayName = target.DisplayName
                Notify("تنكر", "أنت الآن تتنكر بشكل: " .. target.DisplayName)
            end
        end)
    else
        Notify("خطأ", "لم نجد لاعب مناسب للتنكر!")
    end
end)
AddButton(P3, "🔓 إعادة اسم", function() Player.DisplayName = Player.Name end)

-- [ تبويب ثيم ]
AddToggle(P4, "🌫️ Blur", "Blur", function(s) 
    local b = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect", Lighting); b.Size = s and 15 or 0
end)
AddButton(P4, "🌌 فضاء كوني (زحل والأرض)", function() 
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end
    end
    local sky = Instance.new("Sky", Lighting)
    sky.SkyboxBk = "rbxassetid://12064107"
    sky.SkyboxDn = "rbxassetid://12064115"
    sky.SkyboxFt = "rbxassetid://12064121"
    sky.SkyboxLf = "rbxassetid://12064127"
    sky.SkyboxRt = "rbxassetid://12064133"
    sky.SkyboxUp = "rbxassetid://12064139"
    Lighting.ClockTime = 14
    Lighting.Brightness = 3
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.GlobalShadows = false
    Notify("الثيم", "تم تفعيل فضاء السايبر دراغون! 🪐🌍")
end)
AddButton(P4, "🌈 RGB", function() 
    spawn(function() while task.wait(0.1) do Title.TextColor3 = Color3.fromHSV(tick()%5/5, 1, 1) end end)
end)
AddButton(P4, "🗑️ تنظيف", function() collectgarbage("collect") end)

-- [ Float Button ]
local Float = Instance.new("ImageButton", MainGui)
Float.Size = UDim2.new(0,55,0,55); Float.Position = UDim2.new(0.83,0,0.78,0)
Float.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Float.Draggable = true
Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)
local FloatTxt = Instance.new("TextLabel", Float)
FloatTxt.Size = UDim2.new(1,0,1,0); FloatTxt.BackgroundTransparency = 1; FloatTxt.Text = "🐉"
FloatTxt.TextSize = 25; FloatTxt.TextColor3 = Color3.new(1,1,1)
Float.MouseButton1Down:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ AimLock قوي - ما يترك القاتل أبداً ]
RunService.RenderStepped:Connect(function()
    if Features.AimLock then
        local t = GetMurdererTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(
                workspace.CurrentCamera.CFrame.Position, 
                t.Character.Head.Position
            )
        end
    end
end)

-- [ حلقة التشغيل ]
RunService.Heartbeat:Connect(function()
    pcall(function()
        local h = GetHum(); local r = GetRoot()
        if not r then return end
        
        if Features.GodMode and h then h.MaxHealth = 9e9; h.Health = 9e9 end
        if Features.Speed and h then h.WalkSpeed = _G.Settings.WalkSpeed end
        if Features.Reach then local t = GetChar():FindFirstChildWhichIsA("Tool"); if t and t:FindFirstChild("Handle") then t.Handle.Size = Vector3.new(_G.Settings.ReachSize,_G.Settings.ReachSize,_G.Settings.ReachSize); t.Handle.CanCollide = false end end
        if Features.KillAura then local t = GetMurdererTarget(); if t and (r.Position - t.Character.HumanoidRootPart.Position).Magnitude < 15 then
            local tool = GetChar():FindFirstChildWhichIsA("Tool")
            if tool then
                local rem = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot")
                if rem then rem:FireServer(t.Character.Head.Position) else tool:Activate() end
            end
        end end
        if Features.AutoPickup then AutoPickupGun() end
        if Features.AutoFarm then AutoFarmCoins() end
        
        if Features.HideName and GetChar():FindFirstChild("Head") then
            for _,v in pairs(GetChar().Head:GetChildren()) do if v:IsA("BillboardGui") then v.Enabled = false end end
        end
        
        MurdererAlert()
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local hl = p.Character:FindFirstChild("BeastHighlight") or Instance.new("Highlight", p.Character)
                hl.Name = "BeastHighlight"; hl.Enabled = (Features.SmartESP or Features.ESP)
                local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                if Features.SmartESP then
                    hl.FillColor = isM and Color3.new(1,0,0) or Color3.new(1,1,1)
                else 
                    hl.FillColor = Color3.new(0,1,0.5) 
                end
            end
        end
    end)
end)

UIS.JumpRequest:Connect(function() if Features.InfiniteJump and GetHum() then GetHum():ChangeState(Enum.HumanoidStateType.Jumping) end end)

Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    if Features.Invisible then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 1 end end end
    if Features.Fly then flyConn = nil; if PlayerGui:FindFirstChild("FlyUI") then PlayerGui.FlyUI:Destroy() end; Features.Fly = true; HandleFly() end
    if Features.Speed and hum then hum.WalkSpeed = _G.Settings.WalkSpeed end
    if Features.GodMode and hum then hum.MaxHealth = 9e9; hum.Health = 9e9 end
end)

Notify("Cyber Dragon V22", "جاهز يا عبدالله! 🐉", 3)
