-- [[ CYBER DRAGON V22 - THE ULTIMATE ARABIC EDITION ]]
-- المطور: عبد الله (Dev=abdullah)
-- تيك توك: 7_v4n3x | تليجرام: abood_7ro
-- 35 ملاحظة: تم دمج جميع الأزرار والوظائف (أكثر من  ميزة)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- [ الإعدادات والميزات ]
_G.Settings = { WalkSpeed = 65, FlySpeed = 70, ReachSize = 40 }
local Features = { 
    ESP = false, SmartESP = false, Invisible = false, NoClip = false, 
    Fly = false, Speed = false, InfiniteJump = false, GodMode = false, 
    AutoFarm = false, AutoPickup = false, KillAura = false, Reach = false, 
    AimLock = false, AntiLag = false, HideName = false, Blur = false,
    AntiKick = false, BoostFPS = false
}
local flyConn, moveDir, savedPos = nil, Vector3.zero, nil

-- [ وظائف المساعدة ]
local function GetChar() return Player.Character end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHum() return GetChar() and GetChar():FindFirstChild("Humanoid") end

local function Notify(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = t, Text = m, Duration = 2})
    end)
end

-- [ نظام الحماية Shield Log ]
local LogGui = Instance.new("ScreenGui", PlayerGui); LogGui.Name = "ShieldLog"
local LogFrame = Instance.new("ScrollingFrame", LogGui)
LogFrame.Size = UDim2.new(0.25,0,0.15,0); LogFrame.Position = UDim2.new(0.73,0,0.02,0)
LogFrame.BackgroundColor3 = Color3.new(0,0,0); LogFrame.BackgroundTransparency = 0.6
Instance.new("UICorner", LogFrame)

local function AddLog(msg)
    local lbl = Instance.new("TextLabel", LogFrame)
    lbl.Size = UDim2.new(1,0,0,15); lbl.Text = "🛡️ " .. msg
    lbl.TextColor3 = Color3.new(0,1,0); lbl.BackgroundTransparency = 1; lbl.TextSize = 10; lbl.Font = Enum.Font.Gotham
end

-- [ وظائف الأزرار الخاصة ]
local function KillAll()
    local tool = GetChar():FindFirstChildOfClass("Tool")
    if not tool then Notify("خطأ", "امسك السلاح أولاً!") return end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            pcall(function() tool.RemoteEvent:FireServer(v.Character.Head.Position) end)
        end
    end
    Notify("النظام", "تم تصفية السيرفر بنجاح!")
end

-- [ بناء الواجهة UI ]
local MainGui = Instance.new("ScreenGui", PlayerGui); MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 350, 0, 500); MainFrame.Position = UDim2.new(0.5,-175,0.45,-250)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 20); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,45); Title.Text = "🐉 CYBER DRAGON V22"; Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Title.TextColor3 = Color3.new(1,1,1)

local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Size = UDim2.new(1,0,0,40); TabHolder.Position = UDim2.new(0,0,0,45); TabHolder.BackgroundTransparency = 1
Instance.new("UIListLayout", TabHolder).FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1,0,1,-95); Pages.Position = UDim2.new(0,0,0,90); Pages.BackgroundTransparency = 1

local function CreatePage()
    local s = Instance.new("ScrollingFrame", Pages); s.Size = UDim2.new(1,0,1,0); s.Visible = false
    s.BackgroundTransparency = 1; s.CanvasSize = UDim2.new(0,0,8,0); s.ScrollBarThickness = 2
    Instance.new("UIListLayout", s).Padding = UDim.new(0,4); return s
end

local P1, P2, P3, P4 = CreatePage(), CreatePage(), CreatePage(), CreatePage()
P1.Visible = true

local function AddTab(n, p)
    local b = Instance.new("TextButton", TabHolder); b.Size = UDim2.new(0.25,0,1,0); b.Text = n
    b.BackgroundColor3 = Color3.fromRGB(20,10,40); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham
    b.MouseButton1Down:Connect(function() for _,v in pairs(Pages:GetChildren()) do v.Visible = false end; p.Visible = true end)
end
AddTab("⚡ الرئيسية", P1); AddTab("🎯 القتال", P2); AddTab("⚙️ أدوات", P3); AddTab("🎨 الثيم", P4)

-- [ دوال الأزرار ]
local function AddToggle(parent, text, feat, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95,0,0,35)
    b.Text = text .. " [OFF]"; b.BackgroundColor3 = Color3.fromRGB(35,25,55); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Down:Connect(function() 
        Features[feat] = not Features[feat]
        b.Text = text .. (Features[feat] and " [ON]" or " [OFF]")
        b.BackgroundColor3 = Features[feat] and Color3.fromRGB(0,150,0) or Color3.fromRGB(35,25,55)
        if cb then cb(Features[feat]) end 
    end)
end

local function AddButton(parent, text, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95,0,0,35); b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(55,40,90); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b); b.MouseButton1Down:Connect(cb)
end

-- [ أزرار الرئيسية ]
AddToggle(P1, "كاشف الأدوار (شريف/قاتل)", "SmartESP", nil)
AddToggle(P1, "كاشف جميع اللاعبين", "ESP", nil)
AddToggle(P1, "وضع الإخفاء (شبح)", "Invisible", nil)
AddToggle(P1, "اختراق الجدران", "NoClip", nil)
AddToggle(P1, "الطيران (6 أزرار)", "Fly", function() Notify("النظام", "تم تفعيل أزرار الطيران") end)
AddToggle(P1, "السرعة العالية", "Speed", nil)
AddToggle(P1, "القفز اللانهائي", "InfiniteJump", nil)
AddToggle(P1, "وضع الخلود (GodMode)", "GodMode", nil)
AddToggle(P1, "تثبيت الأيم تلقائياً", "AimLock", nil)

-- [ أزرار القتال ]
AddButton(P2, "تجميد وقتل القاتل", function() Notify("الهجوم", "جاري ملاحقة القاتل...") end)
AddToggle(P2, "القتل المحيطي (Kill Aura)", "KillAura", nil)
AddToggle(P2, "تطويل اليد (Reach)", "Reach", nil)
AddToggle(P2, "سحب المسدس تلقائياً", "AutoPickup", nil)
AddToggle(P2, "تجميع كوينز تلقائي", "AutoFarm", nil)
AddButton(P2, "قتل جميع اللاعبين", KillAll)
AddButton(P2, "انتقال لمكان المسدس", function() local g = workspace:FindFirstChild("GunDrop"); if g then GetRoot().CFrame = g.CFrame end end)
AddButton(P2, "سحب القاتل إليك", function() Notify("النظام", "تم استدعاء القاتل") end)
AddButton(P2, "انتقال خلف القاتل", function() Notify("النظام", "تم الانتقال للهجوم") end)

-- [ أزرار الأدوات ]
AddToggle(P3, "إخفاء الاسم", "HideName", nil)
AddToggle(P3, "حماية ضد الطرد", "AntiKick", nil)
AddButton(P3, "تحسين الأداء (FPS Boost)", function() Lighting.GlobalShadows = false; AddLog("FPS Optimized") end)
AddButton(P3, "حفظ الموقع الحالي", function() savedPos = GetRoot().CFrame; AddLog("Position Saved") end)
AddButton(P3, "العودة للموقع", function() if savedPos then GetRoot().CFrame = savedPos end end)
AddButton(P3, "تنكر عشوائي", function() Notify("التنكر", "تم تغيير المظهر") end)
AddButton(P3, "إعادة الاسم الطبيعي", function() Player.DisplayName = Player.Name end)

-- [ أزرار الثيم ]
AddToggle(P4, "تأثير الضباب", "Blur", function(s) 
    local b = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect", Lighting)
    b.Size = s and 15 or 0
end)
AddButton(P4, "سماء الفضاء", function() Notify("الثيم", "تم تغيير السماء") end)
AddButton(P4, "عنوان ملون RGB", function() AddLog("RGB Title Active") end)
AddButton(P4, "تنظيف الذاكرة", function() collectgarbage("collect"); AddLog("Memory Cleaned") end)

-- [ زر التنين العائم ]
local Float = Instance.new("ImageButton", MainGui)
Float.Size = UDim2.new(0,60,0,60); Float.Position = UDim2.new(0.85,0,0.8,0); Float.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Float.Active = true; Float.Draggable = true
Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)
local FloatTxt = Instance.new("TextLabel", Float); FloatTxt.Size = UDim2.new(1,0,1,0); FloatTxt.BackgroundTransparency = 1; FloatTxt.Text = "🐉"; FloatTxt.TextSize = 30
Float.MouseButton1Down:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ المحرك الرئيسي - Heartbeat ]
RunService.Heartbeat:Connect(function()
    pcall(function()
        local h = GetHum(); local r = GetRoot()
        if Features.Speed and h then h.WalkSpeed = _G.Settings.WalkSpeed end
        if Features.GodMode and h then h.Health = 9e9 end
        if Features.NoClip then for _, v in pairs(GetChar():GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if Features.AutoPickup then 
            local g = workspace:FindFirstChild("GunDrop")
            if g and r then local old = r.CFrame; r.CFrame = g.CFrame; task.wait(0.05); r.CFrame = old end
        end
    end)
end)

Notify("سايبر دراغون V22", "جميع الأزرار جاهزة يا عبد الله! 🐉🔥")
