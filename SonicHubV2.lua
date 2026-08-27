local a = loadstring(game:HttpGet("https://raw.githubusercontent.com/junin275/Library/main/ShadowHubLibrary.lua"))()
local Players = game:GetService("Players")
local b = game:GetService("RunService")
local c = game:GetService("UserInputService")
local d = game:GetService("Workspace")
local e = game:GetService("Lighting")
local f = game:GetService("StarterGui")
local g = Players.LocalPlayer
local h = d.CurrentCamera
local i = {ESP = true, ESPTracer = true, ESPDot = true, AimAssist = false, TargetLock = false, WallCheck = true, FFAMode = true, MaxDistance = 2000, TargetPart = "HumanoidRootPart", AutoHeadshot = false, KillNotify = true, MiniGPS = false, Noclip = false, Fullbright = false, SpeedBoost = false, SpinBot = false, SpinSpeed = 30, SpinAngle = 0, FOV = 70, HitSound = true, AimSmooth = 0.15}
local j = {ESP = {}, Target = nil, Kills = 0, Streak = 0, LastHP = {}}
local k = {Enemy = Color3.fromRGB(255, 45, 45), EnemyBright = Color3.fromRGB(255, 85, 85), EnemyDark = Color3.fromRGB(180, 25, 25), Ally = Color3.fromRGB(0, 170, 255), AllyBright = Color3.fromRGB(80, 200, 255), AllyDark = Color3.fromRGB(0, 100, 180), Accent = Color3.fromRGB(160, 80, 255), AccentBright = Color3.fromRGB(200, 140, 255), Green = Color3.fromRGB(50, 255, 120), Yellow = Color3.fromRGB(255, 220, 50), Red = Color3.fromRGB(255, 60, 60), Dark = Color3.fromRGB(12, 12, 20), Dark2 = Color3.fromRGB(20, 20, 32), Dark3 = Color3.fromRGB(30, 30, 48), Text = Color3.fromRGB(220, 220, 235), TextDim = Color3.fromRGB(140, 140, 160)}
local function l(m, n, o)
  o = (o or 0.15)
  return (((math.abs((m.R - n.R)) < o) and (math.abs((m.G - n.G)) < o)) and (math.abs((m.B - n.B)) < o))
end
local function p(q)
  if i.FFAMode then
    return true
  end
  if (q == g) then
    return false
  end
  local r = q.Character
  if not r then
    return false
  end
  for s, t in ipairs(r:GetDescendants()) do
    if (t:IsA("Highlight") and t.OutlineColor) then
      if l(t.OutlineColor, Color3.fromRGB(255, 0, 0), 0.3) then
        return true
      end
      if l(t.OutlineColor, Color3.fromRGB(0, 255, 100), 0.3) then
        return false
      end
    end
  end
  return false
end
local function u(v)
  local w = (g.Character and g.Character:FindFirstChild("HumanoidRootPart"))
  local x = (v.Character and v.Character:FindFirstChild("HumanoidRootPart"))
  if (w and x) then
    return ((w.Position - x.Position)).Magnitude
  end
  return 9999
end
local function y(z)
  local aa = g.Character
  local ab = z.Character
  local ac = (aa and aa:FindFirstChild("HumanoidRootPart"))
  local ad = (ab and ab:FindFirstChild("HumanoidRootPart"))
  if (not ac or not ad) then
    return false
  end
  local ae = RaycastParams.new()
  ae.FilterType = Enum.RaycastFilterType.Exclude
  ae.FilterDescendantsInstances = {aa, ab}
  local af = d:Raycast(ac.Position, ((ad.Position - ac.Position)), ae)
  return (af == nil)
end
local function ag(ah)
  if not ah then
    return false
  end
  local ai = ah.Character
  local aj = (ai and ai:FindFirstChildOfClass("Humanoid"))
  local ak = (ai and ai:FindFirstChild("HumanoidRootPart"))
  return ((aj and ak) and (aj.Health > 0))
end
local function al()
  local am, an = nil, math.huge
  local ao = g.Character
  local ap = (ao and ao:FindFirstChild("HumanoidRootPart"))
  if not ap then
    return nil
  end
  for aq, ar in ipairs(Players:GetPlayers()) do
    if ((ar ~= g) and p(ar)) then
      local as = ar.Character
      local at = (as and as:FindFirstChildOfClass("Humanoid"))
      local au = (as and as:FindFirstChild("HumanoidRootPart"))
      if ((at and au) and (at.Health > 0)) then
        local av = ((ap.Position - au.Position)).Magnitude
        if ((av < an) and (av <= i.MaxDistance)) then
          if (not i.WallCheck or y(ar)) then
            an = av
            am = ar
          end
        end
      end
    end
  end
  return am
end
local function aw(ax)
  if not i.AimAssist then
    return
  end
  if (not ax or not ag(ax)) then
    return
  end
  local ay = ((i.AutoHeadshot and "Head") or i.TargetPart)
  local az = ax.Character:FindFirstChild(ay)
  if not az then
    return
  end
  h.CFrame = h.CFrame:Lerp(CFrame.new(h.CFrame.Position, az.Position), i.AimSmooth)
end
local ba = Instance.new("ScreenGui")
ba.Name = "E"
ba.ResetOnSpawn = false
ba.IgnoreGuiInset = true
ba.DisplayOrder = 998
ba.Parent = g:WaitForChild("PlayerGui")
local function bb(bc)
  local bd = j.ESP[bc]
  if bd then
    pcall(function()
      bd.Frame:Destroy()
    end)
    pcall(function()
      bd.Highlight:Destroy()
    end)
    pcall(function()
      bd.Tracer:Destroy()
    end)
    pcall(function()
      bd.Dot:Destroy()
    end)
    pcall(function()
      bd.DotGlow:Destroy()
    end)
    pcall(function()
      bd.Glow:Destroy()
    end)
    j.ESP[bc] = nil
  end
end
local function be(bf)
  local bg = j.ESP[bf]
  if bg then
    pcall(function()
      bg.Frame.Enabled = false
      bg.Highlight.Enabled = false
      bg.Tracer.Visible = false
      bg.Dot.Visible = false
      bg.Glow.Enabled = false
    end)
  end
end
local function bh(bi)
  local bj = j.ESP[bi]
  if bj then
    pcall(function()
      bj.Frame.Enabled = true
      bj.Highlight.Enabled = true
      bj.Glow.Enabled = true
    end)
  end
end
local function bk(bl)
  if (bl == g) then
    return
  end
  if j.ESP[bl] then
    return
  end
  local bm = bl.Character
  if not bm then
    return
  end
  local bn = bm:FindFirstChild("Head")
  local bo = bm:FindFirstChild("HumanoidRootPart")
  local bp = bm:FindFirstChildOfClass("Humanoid")
  if ((not bn or not bo) or not bp) then
    return
  end
  local bq = p(bl)
  local br = ((bq and k.Enemy) or k.Ally)
  local bs = ((bq and k.EnemyBright) or k.AllyBright)
  local bt = ((bq and k.EnemyDark) or k.AllyDark)
  local bu = Instance.new("BillboardGui")
  bu.Name = "B"
  bu.Adornee = bn
  bu.Size = UDim2.new(0, 180, 0, 65)
  bu.StudsOffset = Vector3.new(0, 3, 0)
  bu.AlwaysOnTop = true
  bu.MaxDistance = i.MaxDistance
  bu.Parent = ba
  local bv = Instance.new("Frame", bu)
  bv.Name = "Glow"
  bv.Size = UDim2.new(1, 8, 1, 8)
  bv.Position = UDim2.new(0, -4, 0, -4)
  bv.BackgroundColor3 = br
  bv.BackgroundTransparency = 0.9
  bv.BorderSizePixel = 0
  bv.ZIndex = 0
  Instance.new("UICorner", bv).CornerRadius = UDim.new(0, 12)
  local bw = Instance.new("Frame", bu)
  bw.Name = "Card"
  bw.Size = UDim2.new(1, 0, 1, 0)
  bw.BackgroundColor3 = k.Dark
  bw.BackgroundTransparency = 0.55
  bw.BorderSizePixel = 0
  bw.ZIndex = 2
  Instance.new("UICorner", bw).CornerRadius = UDim.new(0, 10)
  Instance.new("UIStroke", bw).Color = br
  Instance.new("UIStroke", bw).Thickness = 1.5
  Instance.new("UIStroke", bw).Transparency = 0.4
  local bx = Instance.new("Frame", bw)
  bx.Size = UDim2.new(1, 0, 0.5, 0)
  bx.BackgroundColor3 = Color3.new(1, 1, 1)
  bx.BackgroundTransparency = 0.92
  bx.BorderSizePixel = 0
  bx.ZIndex = 3
  local by = Instance.new("Frame", bw)
  by.Name = "Bar"
  by.Size = UDim2.new(0, 4, 0.7, 0)
  by.Position = UDim2.new(0, 6, 0.15, 0)
  by.BackgroundColor3 = br
  by.BorderSizePixel = 0
  by.ZIndex = 4
  Instance.new("UICorner", by).CornerRadius = UDim.new(0, 2)
  local bz = Instance.new("Frame", bw)
  bz.Size = UDim2.new(0, 44, 0, 13)
  bz.Position = UDim2.new(1, -50, 0, 5)
  bz.BackgroundColor3 = bt
  bz.BackgroundTransparency = 0.3
  bz.BorderSizePixel = 0
  bz.ZIndex = 4
  Instance.new("UICorner", bz).CornerRadius = UDim.new(0, 6)
  Instance.new("UIStroke", bz).Color = br
  Instance.new("UIStroke", bz).Thickness = 1
  Instance.new("UIStroke", bz).Transparency = 0.5
  local ca = Instance.new("TextLabel", bz)
  ca.Size = UDim2.new(1, 0, 1, 0)
  ca.BackgroundTransparency = 1
  ca.Text = ((bq and "ENEMY") or "ALLY")
  ca.TextColor3 = bs
  ca.Font = Enum.Font.GothamBlack
  ca.TextSize = 8
  ca.ZIndex = 5
  local cb = Instance.new("TextLabel", bw)
  cb.Name = "Name"
  cb.Size = UDim2.new(1, -60, 0, 16)
  cb.Position = UDim2.new(0, 16, 0, 6)
  cb.BackgroundTransparency = 1
  cb.Text = bl.DisplayName
  cb.TextColor3 = k.Text
  cb.TextStrokeTransparency = 0
  cb.TextStrokeColor3 = Color3.new(0, 0, 0)
  cb.Font = Enum.Font.GothamBold
  cb.TextSize = 13
  cb.TextXAlignment = Enum.TextXAlignment.Left
  cb.TextTruncate = Enum.TextTruncate.AtEnd
  cb.ZIndex = 4
  local cc = Instance.new("TextLabel", bw)
  cc.Name = "Dist"
  cc.Size = UDim2.new(0, 50, 0, 12)
  cc.Position = UDim2.new(1, -55, 0, 20)
  cc.BackgroundTransparency = 1
  cc.Text = "0m"
  cc.TextColor3 = k.TextDim
  cc.TextStrokeTransparency = 0
  cc.TextStrokeColor3 = Color3.new(0, 0, 0)
  cc.Font = Enum.Font.GothamBold
  cc.TextSize = 10
  cc.TextXAlignment = Enum.TextXAlignment.Right
  cc.ZIndex = 4
  local cd = Instance.new("Frame", bw)
  cd.Size = UDim2.new(0.82, 0, 0, 7)
  cd.Position = UDim2.new(0.09, 0, 0, 28)
  cd.BackgroundColor3 = k.Dark3
  cd.BorderSizePixel = 0
  cd.ZIndex = 4
  Instance.new("UICorner", cd).CornerRadius = UDim.new(0, 4)
  local ce = Instance.new("Frame", cd)
  ce.Name = "Fill"
  ce.Size = UDim2.new(1, 0, 1, 0)
  ce.BackgroundColor3 = k.Green
  ce.BorderSizePixel = 0
  ce.ZIndex = 5
  Instance.new("UICorner", ce).CornerRadius = UDim.new(0, 4)
  local cf = Instance.new("Frame", ce)
  cf.Size = UDim2.new(1, 0, 0.4, 0)
  cf.Position = UDim2.new(0, 0, 0, 0)
  cf.BackgroundColor3 = Color3.new(1, 1, 1)
  cf.BackgroundTransparency = 0.7
  cf.BorderSizePixel = 0
  cf.ZIndex = 6
  Instance.new("UICorner", cf).CornerRadius = UDim.new(0, 4)
  local cg = Instance.new("TextLabel", bw)
  cg.Name = "HP"
  cg.Size = UDim2.new(0.82, 0, 0, 10)
  cg.Position = UDim2.new(0.09, 0, 0, 37)
  cg.BackgroundTransparency = 1
  cg.Text = "100 HP"
  cg.TextColor3 = k.TextDim
  cg.TextStrokeTransparency = 0
  cg.TextStrokeColor3 = Color3.new(0, 0, 0)
  cg.Font = Enum.Font.Gotham
  cg.TextSize = 9
  cg.TextXAlignment = Enum.TextXAlignment.Left
  cg.ZIndex = 4
  local ch = Instance.new("TextLabel", bw)
  ch.Name = "Status"
  ch.Size = UDim2.new(0.82, 0, 0, 8)
  ch.Position = UDim2.new(0.09, 0, 0, 48)
  ch.BackgroundTransparency = 1
  ch.Text = ""
  ch.TextColor3 = bs
  ch.TextStrokeTransparency = 0
  ch.TextStrokeColor3 = Color3.new(0, 0, 0)
  ch.Font = Enum.Font.GothamBold
  ch.TextSize = 8
  ch.TextXAlignment = Enum.TextXAlignment.Left
  ch.ZIndex = 4
  local ci = Instance.new("Highlight")
  ci.Name = "H"
  ci.Adornee = bm
  ci.FillColor = br
  ci.FillTransparency = 0.75
  ci.OutlineColor = bs
  ci.OutlineTransparency = 0.15
  ci.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  ci.Parent = ba
  local cj = Instance.new("Frame", ba)
  cj.Name = "T"
  cj.AnchorPoint = Vector2.new(0.5, 0.5)
  cj.BackgroundColor3 = br
  cj.BackgroundTransparency = 0.4
  cj.BorderSizePixel = 0
  cj.Visible = false
  local ck = Instance.new("UIGradient", cj)
  ck.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0)})
  ck.Rotation = 90
  local cl = Instance.new("Frame", ba)
  cl.Name = "D"
  cl.AnchorPoint = Vector2.new(0.5, 0.5)
  cl.Size = UDim2.fromOffset(8, 8)
  cl.BackgroundColor3 = bs
  cl.BorderSizePixel = 0
  cl.Visible = false
  Instance.new("UICorner", cl).CornerRadius = UDim.new(1, 0)
  local cm = Instance.new("Frame", ba)
  cm.Name = "DG"
  cm.AnchorPoint = Vector2.new(0.5, 0.5)
  cm.Size = UDim2.fromOffset(14, 14)
  cm.BackgroundColor3 = br
  cm.BackgroundTransparency = 0.7
  cm.BorderSizePixel = 0
  cm.Visible = false
  Instance.new("UICorner", cm).CornerRadius = UDim.new(1, 0)
  j.ESP[bl] = {Frame = bu, Highlight = ci, Tracer = cj, Dot = cl, Glow = bv, DotGlow = cm, NameLabel = cb, DistLabel = cc, HPLabel = cg, HPFill = ce, StatusLabel = ch, Badge = bz, BadgeText = ca, Bar = by, EspColor = br, EspColorBright = bs, EspColorDark = bt, IsEnemy = bq}
end
local function cn(co)
  if (co == g) then
    return
  end
  local cp = co.Character
  local cq = (cp and cp:FindFirstChildOfClass("Humanoid"))
  local cr = (cp and cp:FindFirstChild("HumanoidRootPart"))
  if (((not cp or not cq) or not cr) or (cq.Health <= 0)) then
    bb(co)
    return
  end
  local cs = u(co)
  if (cs > i.MaxDistance) then
    be(co)
    return
  end
  local ct = j.ESP[co]
  local cu = p(co)
  if (ct and (ct.IsEnemy ~= cu)) then
    bb(co)
    ct = nil
  end
  if not ct then
    bk(co)
    ct = j.ESP[co]
  end
  if not ct then
    return
  end
  bh(co)
  local cv = ct.EspColor
  local cw = ct.EspColorBright
  local cx = ct.EspColorDark
  pcall(function()
    ct.Highlight.Adornee = cp
    ct.Highlight.FillColor = cv
    ct.Highlight.OutlineColor = cw
    ct.Bar.BackgroundColor3 = cv
    ct.Badge.BackgroundColor3 = cx
    ct.BadgeText.TextColor3 = cw
    ct.BadgeText.Text = ((cu and "ENEMY") or "ALLY")
    ct.Tracer.BackgroundColor3 = cv
    ct.Dot.BackgroundColor3 = cw
    ct.DotGlow.BackgroundColor3 = cv
  end)
  local cy = math.clamp((cq.Health / math.max(cq.MaxHealth, 1)), 0, 1)
  pcall(function()
    ct.DistLabel.Text = (math.floor(cs) .. "m")
    ct.HPLabel.Text = (math.floor(cq.Health) .. " HP")
    if (cy > 0.6) then
      ct.HPFill.BackgroundColor3 = k.Green
    elseif (cy > 0.3) then
      ct.HPFill.BackgroundColor3 = k.Yellow
    else
      ct.HPFill.BackgroundColor3 = k.Red
    end
    ct.HPFill.Size = UDim2.new(cy, 0, 1, 0)
    if (cy <= 0) then
      ct.StatusLabel.Text = "ELIMINATED"
    elseif (cy < 0.3) then
      ct.StatusLabel.Text = "CRITICAL"
    else
      ct.StatusLabel.Text = ""
    end
  end)
  pcall(function()
    local cz, da = h:WorldToViewportPoint(cr.Position)
    if (da and (cz.Z > 0)) then
      local db = Vector2.new((h.ViewportSize.X / 2), h.ViewportSize.Y)
      local dc = Vector2.new(cz.X, cz.Y)
      local dd = (dc - db)
      ct.Tracer.Position = UDim2.fromOffset((((db.X + dc.X)) / 2), (((db.Y + dc.Y)) / 2))
      ct.Tracer.Size = UDim2.fromOffset(2, dd.Magnitude)
      ct.Tracer.Rotation = (math.deg(math.atan2(dd.Y, dd.X)) + 90)
      ct.Tracer.Visible = i.ESPTracer
      ct.Dot.Position = UDim2.fromOffset(cz.X, cz.Y)
      ct.Dot.Visible = i.ESPDot
      ct.DotGlow.Position = UDim2.fromOffset(cz.X, cz.Y)
      ct.DotGlow.Visible = i.ESPDot
    else
      ct.Tracer.Visible = false
      ct.Dot.Visible = false
      ct.DotGlow.Visible = false
    end
  end)
end
local function de()
  if not i.ESP then
    for df in pairs(j.ESP) do
      bb(df)
    end
    return
  end
  for dg, dh in ipairs(Players:GetPlayers()) do
    if (dh ~= g) then
      cn(dh)
    end
  end
end
local di = Instance.new("Frame")
di.Size = UDim2.new(0, 140, 0, 80)
di.Position = UDim2.new(1, -155, 0, 15)
di.BackgroundColor3 = k.Dark
di.BackgroundTransparency = 0.2
di.BorderSizePixel = 0
di.Visible = false
di.Parent = ba
Instance.new("UICorner", di).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", di).Color = k.Accent
Instance.new("UIStroke", di).Thickness = 1.5
Instance.new("UIStroke", di).Transparency = 0.3
local dj = Instance.new("Frame", di)
dj.Size = UDim2.new(1, 0, 0.4, 0)
dj.BackgroundColor3 = Color3.new(1, 1, 1)
dj.BackgroundTransparency = 0.92
dj.BorderSizePixel = 0
local dk = Instance.new("TextLabel", di)
dk.Size = UDim2.new(1, 0, 0, 28)
dk.Position = UDim2.new(0, 0, 0, 6)
dk.BackgroundTransparency = 1
dk.Text = "â"
dk.TextColor3 = k.Green
dk.TextStrokeTransparency = 0
dk.TextStrokeColor3 = Color3.new(0, 0, 0)
dk.Font = Enum.Font.GothamBlack
dk.TextSize = 22
local dl = Instance.new("TextLabel", di)
dl.Size = UDim2.new(1, 0, 0, 16)
dl.Position = UDim2.new(0, 0, 0, 36)
dl.BackgroundTransparency = 1
dl.Text = "--"
dl.TextColor3 = k.AccentBright
dl.TextStrokeTransparency = 0
dl.TextStrokeColor3 = Color3.new(0, 0, 0)
dl.Font = Enum.Font.GothamBold
dl.TextSize = 12
local dm = Instance.new("TextLabel", di)
dm.Size = UDim2.new(1, -10, 0, 14)
dm.Position = UDim2.new(0, 5, 0, 55)
dm.BackgroundTransparency = 1
dm.Text = "procurando..."
dm.TextColor3 = k.TextDim
dm.TextStrokeTransparency = 0
dm.TextStrokeColor3 = Color3.new(0, 0, 0)
dm.Font = Enum.Font.Gotham
dm.TextSize = 9
dm.TextTruncate = Enum.TextTruncate.AtEnd
b.Stepped:Connect(function()
  if i.Noclip then
    local dn = g.Character
    if dn then
      for dp, dq in ipairs(dn:GetDescendants()) do
        if dq:IsA("BasePart") then
          dq.CanCollide = false
        end
      end
    end
  end
end)
local function dr(ds)
  i.Fullbright = ds
  if ds then
    e.Brightness = 2
    e.Ambient = Color3.fromRGB(178, 178, 178)
    e.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    e.FogEnd = 100000
  else
    e.Brightness = 1
    e.Ambient = Color3.fromRGB(70, 70, 70)
    e.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    e.FogEnd = 100000
  end
end
local function dt(du)
  i.SpeedBoost = du
  local dv = (g.Character and g.Character:FindFirstChildOfClass("Humanoid"))
  if dv then
    dv.WalkSpeed = ((du and 32) or 16)
  end
end
local function dw()
  local dx = (g.Character and g.Character:FindFirstChild("HumanoidRootPart"))
  if not dx then
    return
  end
  local dy, dz
  for ea, eb in ipairs(Players:GetPlayers()) do
    if ((eb ~= g) and p(eb)) then
      local ec = (eb.Character and eb.Character:FindFirstChild("HumanoidRootPart"))
      local ed = (eb.Character and eb.Character:FindFirstChildOfClass("Humanoid"))
      if ((ec and ed) and (ed.Health > 0)) then
        local ee = ((dx.Position - ec.Position)).Magnitude
        if ((ee < i.MaxDistance) and ((not dz or (ee < dz)))) then
          dy = eb
          dz = ee
        end
      end
    end
  end
  if ((dy and dy.Character) and dy.Character:FindFirstChild("HumanoidRootPart")) then
    dx.CFrame = (dy.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4))
    a:Notify("Teleport", dy.DisplayName, "success", 2)
  end
end
local function ef(eg)
  if (eg == g) then
    return
  end
  j.LastHP[eg] = 100
  local function eh(ei)
    local ej = ei:WaitForChild("Humanoid", 10)
    if not ej then
      return
    end
    j.LastHP[eg] = ej.Health
    ej.HealthChanged:Connect(function(ek)
      local el = (j.LastHP[eg] or ek)
      j.LastHP[eg] = ek
      if ((el > 0) and (ek <= 0)) then
        task.delay(0.1, function()
          bb(eg)
        end)
        local em = u(eg)
        if ((j.Target == eg) or (em < 80)) then
          j.Kills += 1
          j.Streak += 1
          if i.HitSound then
            pcall(function()
              local en = Instance.new("Sound")
              en.SoundId = "rbxassetid://5765660795"
              en.Volume = 0.5
              en.Parent = h
              en:Play()
              game:GetService("Debris"):AddItem(en, 2)
            end)
          end
          if i.KillNotify then
            a:Notify("Kill", eg.DisplayName, "kill", 3)
          end
          if (j.Target == eg) then
            j.Target = nil
          end
          if (j.Streak == 3) then
            a:Notify("Streak!", "3x", "streak", 3)
          end
          if (j.Streak == 5) then
            a:Notify("Streak!", "5x", "streak", 3)
          end
          if (j.Streak == 10) then
            a:Notify("Unstoppable!", "10x", "streak", 4)
          end
        end
      end
    end)
  end
  if eg.Character then
    task.spawn(eh, eg.Character)
  end
  eg.CharacterAdded:Connect(function(eo)
    task.wait(0.5)
    eh(eo)
    task.wait(0.3)
    bb(eg)
  end)
end
for ep, eq in ipairs(Players:GetPlayers()) do
  ef(eq)
end
Players.PlayerAdded:Connect(ef)
g.CharacterAdded:Connect(function(er)
  j.Streak = 0
  local es = er:WaitForChild("Humanoid", 10)
  if es then
    es.Died:Connect(function()
      j.Streak = 0
    end)
  end
  if i.SpeedBoost then
    local et = er:WaitForChild("Humanoid", 5)
    if et then
      et.WalkSpeed = 32
    end
  end
end)
Players.PlayerRemoving:Connect(function(eu)
  bb(eu)
  if (j.Target == eu) then
    j.Target = nil
  end
  j.LastHP[eu] = nil
end)
local ev = a:CreateWindow("SH")
local ew = ev:Section("COMBATE")
ev:Toggle(ew, "ESP", true, function(ex)
  i.ESP = ex
  if not ex then
    for ey in pairs(j.ESP) do
      bb(ey)
    end
  end
end)
ev:Toggle(ew, "  Tracer", true, function(ez)
  i.ESPTracer = ez
end)
ev:Toggle(ew, "  Dot", true, function(fa)
  i.ESPDot = fa
end)
ev:Toggle(ew, "Aimbot", false, function(fb)
  i.AimAssist = fb
end)
ev:Label(ew, "Sempre ativo quando ligado")
ev:Toggle(ew, "Target Lock", false, function(fc)
  i.TargetLock = fc
  if fc then
    j.Target = al()
  else
    j.Target = nil
  end
end)
ev:Toggle(ew, "Wall Check", true, function(fd)
  i.WallCheck = fd
end)
ev:Label(ew, "Nao mira atraves de parede")
ev:Toggle(ew, "Auto Headshot", false, function(fe)
  i.AutoHeadshot = fe
end)
ev:Slider(ew, "Smoothness", 1, 50, 15, function(ff)
  i.AimSmooth = (ff / 100)
end)
ev:Label(ew, "Mais alto = mais grude")
ev:Slider(ew, "Distance", 50, 5000, 2000, function(fg)
  i.MaxDistance = fg
end)
local fh = ev:Section("UTIL")
ev:Toggle(fh, "GPS", false, function(fi)
  i.MiniGPS = fi
  di.Visible = fi
end)
ev:Toggle(fh, "Kill Notif", true, function(fj)
  i.KillNotify = fj
end)
ev:Toggle(fh, "Hit Sound", true, function(fk)
  i.HitSound = fk
end)
ev:Toggle(fh, "FFA Mode", true, function(fl)
  i.FFAMode = fl
end)
ev:Button(fh, "Teleport", dw)
local fm = ev:Section("EXPLOITS")
ev:Toggle(fm, "Noclip", false, function(fn)
  i.Noclip = fn
end)
ev:Toggle(fm, "Fullbright", false, function(fo)
  dr(fo)
end)
ev:Toggle(fm, "Speed", false, function(fp)
  dt(fp)
end)
ev:Toggle(fm, "Spin Bot", false, function(fq)
  i.SpinBot = fq
  j.SpinAngle = 0
end)
ev:Slider(fm, "Spin", 5, 120, 30, function(fr)
  i.SpinSpeed = fr
end)
ev:Slider(fm, "FOV", 30, 120, 70, function(fs)
  i.FOV = fs
  h.FieldOfView = fs
end)
local ft = ev:StatusBar("K: 0 | S: 0")
b.RenderStepped:Connect(function(fu)
  de()
  if i.AimAssist then
    local fv = al()
    if i.TargetLock then
      if not ag(j.Target) then
        j.Target = fv
      end
    else
      j.Target = fv
    end
    aw(j.Target)
  else
    j.Target = nil
  end
  if i.SpinBot then
    local fw = g.Character
    local fx = (fw and fw:FindFirstChild("HumanoidRootPart"))
    if fx then
      j.SpinAngle += (i.SpinSpeed * fu)
      fx.CFrame = (CFrame.new(fx.Position) * CFrame.Angles(0, math.rad(j.SpinAngle), 0))
    end
  end
  if i.MiniGPS then
    di.Visible = true
    local fy = g.Character
    local fz = (fy and fy:FindFirstChild("HumanoidRootPart"))
    local ga = (j.Target or al())
    if (ga and fz) then
      local gb = (ga.Character and ga.Character:FindFirstChild("HumanoidRootPart"))
      if gb then
        local gc = ((fz.Position - gb.Position)).Magnitude
        local gd = ((gb.Position - fz.Position)).Unit
        local ge = fz.CFrame.LookVector
        local gf = math.atan2(((gd.X * ge.Z) - (gd.Z * ge.X)), ((gd.X * ge.X) + (gd.Z * ge.Z)))
        dk.Rotation = -math.deg(gf)
        dl.Text = (math.floor(gc) .. "m")
        dm.Text = ga.DisplayName
      end
    end
  else
    di.Visible = false
  end
  pcall(function()
    h.FieldOfView = i.FOV
  end)
  ft:SetText(("K: " .. (j.Kills .. (" | S: " .. j.Streak))))
end)
f:SetCore("SendNotification", {Title = "SH", Text = "Pronto!", Duration = 2})
print("[SH] Ready!")
