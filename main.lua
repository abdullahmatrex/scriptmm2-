-- [[ CYBER DRAGON V22 - OFFICIAL RELEASE ]]
-- المطور الفعلي: عبد الله (Dev=abdullah)
-- الحقوق: جميع الحقوق محفوظة لـ Cyber Dragon 🐉

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- [ نظام إرسال الحقوق في الشات ]
local function SendChat(msg)
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        chatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

-- إعلان الحقوق عند تشغيل السكربت
SendChat("🐉 CYBER DRAGON V22 Loaded! Developed by: Dev=abdullah")
SendChat("🔥 Get ready to dominate with the best MM2 Script!")

-- [ مصفوفة الميزات ]
_G.Settings = { WalkSpeed = 65, FlySpeed = 70 }
local Features = { 
    ESP = false, NoClip = false, Fly = false, Speed = false, 
    InfiniteJump = false, KillAura = false, AutoPickup = false, 
    AutoFarm = false, GodMode = false, AntiKick = true, RGB = false
}
local flyConn, moveDir, savedPos = nil, Vector3.zero, nil

-- [ وظائف المساعدة ]
local function GetRoot() return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") end
local function GetHum() return Player.Character and Player.Character:FindFirstChild("Humanoid") end

-- [ 1. حماية Anti-Kick ]
pcall(function()
    local mt = getrawmetatable(game); setreadonly(mt, false); local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" then return nil end
        return old(self, ...)
    end)
end)

-- [ 2. نظام الطيران السداسي ]
local function ToggleFly(state)
    if state then
        local fg = Instance.new("ScreenGui", PlayerGui); fg.Name = "DragonFly"
        local main = Instance.new("Frame", fg); main.Size = UDim2.new(0, 160, 0, 160); main.Position = UDim2.new(0.05, 0, 0.4, 0); main.BackgroundTransparency = 1
        local btns = {
            {N="▲", P=UDim2.new(0.35,0,0,0), D=Vector3.new(0,1,0)}, {N="▼", P=UDim2.new(0.35,0,0.7,0), D=Vector3.new(0,-1,0)},
            {N="⇧", P=UDim2.new(0.35,0,0.35,0), D=Vector3.new(0,0,-1)}, {N="⇩", P=UDim2.new(0.35,0,-0.35,0), D=Vector3.new(0,0,1)},
            {N="◄", P=UDim2.new(0,0,0.35,0), D=Vector3.new(-1,0,0)}, {N="►", P=UDim2.new(0.7,0,0.35,0), D=Vector3.new(1,0,0)}
        }
        for _, i in pairs(btns) do
            local b = Instance.new("TextButton", main); b.Size = UDim2.new(0, 40, 0, 40); b.Position = i.P; b.Text = i.N; b.BackgroundColor3 = Color3.fromRGB(138, 43, 226); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
            b.MouseButton1Down:Connect(function() moveDir = i.D end); b.MouseButton1Up:Connect(function() moveDir = Vector3.zero end)
        end
        flyConn = RunService.Heartbeat:Connect(function()
            if GetRoot() and Features.Fly then
                local bv = GetRoot():FindFirstChild("DragonVel") or Instance.new("BodyVelocity", GetRoot()); bv.Name = "DragonVel"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                local cam = workspace.CurrentCamera
                bv.Velocity = moveDir == Vector3.zero and Vector3.new(0, 0.1, 0) or ((moveDir.Z ~= 0 and cam.CFrame.LookVector * -moveDir.Z) + (moveDir.X ~= 0 and cam.CFrame.RightVector * moveDir.X) + (moveDir.Y ~= 0 and Vector3.new(0, moveDir.Y, 0))).Unit * _G.Settings.FlySpeed
            end
        end)
    else
        if flyConn then flyConn:Disconnect() end
        if PlayerGui:FindFirstChild("DragonFly") then PlayerGui.DragonFly:Destroy() end
        if GetRoot() and GetRoot():FindFirstChild("DragonVel") then GetRoot().DragonVel:Destroy() end
    end
end

-- [ 3. الواجهة وتوزيع الأزرار ]
local MainGui = Instance.new("ScreenGui", PlayerGui); MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", MainGui); MainFrame.Size = UDim2.new(0, 350, 0, 500); MainFrame.Position = UDim2.new(0.5,-175,0.5,-250); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 20); MainFrame.Active = true; MainFrame.Draggable = true; Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1,0,0,50); Title.Text = "🐉 CYBER DRAGON V22"; Title.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", MainFrame); Scroll.Size = UDim2.new(1,0,1,-60); Scroll.Position = UDim2.new(0,0,0,55); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0,0,12,0); Scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", Scroll); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function AddToggle(txt, feat, cb)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0.9,0,0,40); b.Text = txt .. " [OFF]"; b.BackgroundColor3 = Color3.fromRGB(30,20,45); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Down:Connect(function() 
        Features[feat] = not Features[feat]
        b.Text = txt .. (Features[feat] and " [ON]" or " [OFF]")
        b.BackgroundColor3 = Features[feat] and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,20,45)
        if cb then cb(Features[feat]) end 
    end)
end

local function AddButton(txt, cb)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0.9,0,0,40); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(55,35,80); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b); b.MouseButton1Down:Connect(cb)
end

-- [[ الأزرار شاملة كل الميزات السابقة والجديدة ]]
AddToggle("💀 القتل المحيطي (KillAura)", "KillAura", nil)
AddButton("❄️ تجميد القاتل الفوري", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) then
            v.Character.HumanoidRootPart.Anchored = true
        end
    end
end)
AddButton("🧲 سحب المسدس لموقعك", function()
    local g = workspace:FindFirstChild("GunDrop")
    if g then g.CFrame = GetRoot().CFrame end
end)
AddToggle("🦅 نظام الطيران", "Fly", function(s) ToggleFly(s) end)
AddToggle("⚡ السرعة الخارقة", "Speed", nil)
AddToggle("👻 اختراق الجدران", "NoClip", nil)
AddToggle("👁️ كاشف الأدوار (ESP)", "ESP", nil)
AddToggle("💰 تجميع كوينز تلقائي", "AutoFarm", nil)
AddToggle("🔫 لقط مسدس تلقائي", "AutoPickup", nil)
AddToggle("🏥 وضع الخلود", "GodMode", nil)
AddToggle("🌈 ثيم RGB المتحرك", "RGB", nil)
AddButton("🇮🇶 ثيم أسود الرافدين", function() Title.BackgroundColor3 = Color3.new(1,0,0); MainFrame.BackgroundColor3 = Color3.new(0,0,0) end)
AddButton("📍 حفظ موقعك", function() savedPos = GetRoot().CFrame end)
AddButton("🏠 العودة لموقعك", function() if savedPos then GetRoot().CFrame = savedPos end end)
AddButton("📢 إعلان الحقوق في الشات", function() SendChat("🐉 Powered by Cyber Dragon Script | Dev: Abdullah") end)

-- [ 4. المحرك الرئيسي ]
RunService.Heartbeat:Connect(function()
    pcall(function()
        local h = GetHum(); local r = GetRoot()
        if Features.Speed and h then h.WalkSpeed = _G.Settings.WalkSpeed end
        if Features.NoClip then for _, v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if Features.GodMode and h then h.MaxHealth = 9e9; h.Health = 9e9 end
        if Features.InfiniteJump and UIS:IsKeyDown(Enum.KeyCode.Space) then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        if Features.RGB then Title.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
        
        if Features.KillAura then
            local tool = Player.Character:FindFirstChild("Knife") or Player.Character:FindFirstChild("Gun")
            if tool then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        if (r.Position - v.Character.HumanoidRootPart.Position).Magnitude < 18 then tool:Activate() end
                    end
                end
            end
        end

        if Features.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    local hl = p.Character:FindFirstChild("DragonHL") or Instance.new("Highlight", p.Character)
                    hl.Name = "DragonHL"; hl.FillColor = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) and Color3.new(1,0,0) or Color3.new(0,1,0)
                end
            end
        end
    end)
end)

-- زر التنين العائم
local Float = Instance.new("ImageButton", MainGui); Float.Size = UDim2.new(0,60,0,60); Float.Position = UDim2.new(0.85,0,0.8,0); Float.BackgroundColor3 = Color3.fromRGB(138,43,226); Float.Draggable = true; Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)
local FloatTxt = Instance.new("TextLabel", Float); FloatTxt.Size = UDim2.new(1,0,1,0); FloatTxt.Text = "🐉"; FloatTxt.TextSize = 30; FloatTxt.BackgroundTransparency = 1; FloatTxt.TextColor3 = Color3.new(1,1,1)
Float.MouseButton1Down:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
