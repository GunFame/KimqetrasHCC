-- v6.11: immediate bootstrap UI. This runs BEFORE the backend so execution can
-- never look like a silent no-op, even if an older/internal feature chunk fails.
do
    local okBoot, bootErr = pcall(function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local pg = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui",10))
        if not pg then return end

        local old = pg:FindFirstChild("KimqetrasHC_ImmediateBoot")
        if old then old:Destroy() end

        local g = Instance.new("ScreenGui")
        g.Name = "KimqetrasHC_ImmediateBoot"
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = false
        g.DisplayOrder = 999999
        g.Parent = pg

        local f = Instance.new("Frame")
        f.Name = "Card"
        f.Size = UDim2.fromOffset(330,72)
        f.Position = UDim2.new(.5,-165,.08,0)
        f.BackgroundColor3 = Color3.fromRGB(22,22,28)
        f.BorderSizePixel = 0
        f.Parent = g

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0,12)
        c.Parent = f

        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(169,116,235)
        st.Thickness = 2
        st.Transparency = .1
        st.Parent = f

        local t = Instance.new("TextLabel")
        t.Name = "Status"
        t.BackgroundTransparency = 1
        t.Position = UDim2.fromOffset(12,8)
        t.Size = UDim2.new(1,-24,1,-16)
        t.Font = Enum.Font.GothamSemibold
        t.TextSize = 14
        t.TextWrapped = true
        t.TextColor3 = Color3.fromRGB(245,238,255)
        t.Text = "Kimqetras HC\nStarting v6.11..."
        t.Parent = f

        _G.KimqBootSetStatus = function(msg)
            pcall(function()
                if t and t.Parent then t.Text = "Kimqetras HC\n"..tostring(msg) end
            end)
        end
        _G.KimqBootGui = g
    end)
    if not okBoot then
        warn("[Kimqetras HC bootstrap] "..tostring(bootErr))
    end
end

local __KIMQ_REUSE_BACKEND = _G.KimqCameraFixVersion == "camera-off-v1" and type(_G.KimqConfigControls)=="table" and next(_G.KimqConfigControls)~=nil and type(_G.KimpetrasKIMBackend)=="table"
if not __KIMQ_REUSE_BACKEND then
-- Kimqetras HC v2.108 • grouped feature sections • Purple default
-- Rebuilt from the last known-good v2.19 base instead of stacking patches from v2.20-v2.28.
-- Macro/Speed behavior is sourced only from the script supplied by the user.

local KIMQ_SINGLE_KEY = "KimqHC_LasionExactLite"
local KIMQ_BUILD = "v6.11-never-silent-boot"
warn("[Kimqetras HC] v6 original Lasion colors starting...")

local function kimqFindExistingGui()
    local Players0 = game:GetService("Players")
    local CoreGui0 = game:GetService("CoreGui")
    local lp0 = Players0.LocalPlayer
    local pg0 = lp0 and lp0:FindFirstChildOfClass("PlayerGui")
    return CoreGui0:FindFirstChild("KimqetrasHC_Lasion")
        or (pg0 and pg0:FindFirstChild("KimqetrasHC_Lasion"))
        or CoreGui0:FindFirstChild("KimpetrasHC")
        or (pg0 and pg0:FindFirstChild("KimpetrasHC"))
end

do
    local StarterGui0 = game:GetService("StarterGui")
    local RunService0 = game:GetService("RunService")
    local SHARED0 = (type(getgenv)=="function" and getgenv()) or _G

    local running = rawget(SHARED0, KIMQ_SINGLE_KEY)
    local runningBuild = rawget(SHARED0, "KimqHC_CurrentBuild")
    local runtimeState = rawget(SHARED0, "KimqHC_RuntimeState")
    local runtimeStartedAt = tonumber(rawget(SHARED0, "KimqHC_RuntimeStartedAt"))
    local runningGui = kimqFindExistingGui()

    local function notifyBoot(text,duration)
        pcall(function()
            StarterGui0:SetCore("SendNotification",{
                Title="Kimqetras HC",
                Text=text,
                Duration=duration or 5,
            })
        end)
    end

    local function clearRuntimeClaim()
        SHARED0[KIMQ_SINGLE_KEY]=nil
        SHARED0.KimqHC_CurrentBuild=nil
        SHARED0.KimqHC_RuntimeState=nil
        SHARED0.KimqHC_RuntimeStartedAt=nil
        _G[KIMQ_SINGLE_KEY]=nil
        _G.KimqHC_CurrentBuild=nil
        _G.KimqHC_RuntimeState=nil
        _G.KimqHC_RuntimeStartedAt=nil
    end

    -- v2.69 startup recovery:
    -- v2.68 claimed the single-runtime flag BEFORE the GUI was guaranteed to exist.
    -- If that first boot failed, executing it again could immediately return forever
    -- even though there was literally no Kimqetras GUI to reopen.
    if running and runningBuild == KIMQ_BUILD then
        if runningGui then
            pcall(function()
                runningGui.Enabled = true
                local main0 = runningGui:FindFirstChild("Main")
                local explicitVisible=rawget(SHARED0,"KimqMainUserVisibleState")
                if main0 and explicitVisible~=false then main0.Visible = true end
            end)
            notifyBoot((runtimeState=="ready") and "v2.99 is already running ♡" or "v2.99 is already starting ♡",4)
            return
        end

        -- Same-build claim with no GUI is a failed/stale boot, not a live runtime.
        -- Clear only the claim and retry normally; no feature callbacks are touched.
        clearRuntimeClaim()
        running=false
        runningBuild=nil
        runtimeState=nil
        runtimeStartedAt=nil
        notifyBoot("Recovering a failed v2.99 boot ♡",4)
    end

    -- A DIFFERENT fully-running build may still have hidden input/heartbeat callbacks,
    -- so we still refuse to stack on top of a real older runtime.
    -- But an older build that died while booting and never created a GUI is safe to
    -- treat as stale after a short grace period.
    local oldRuntimeDetected =
        (running and runningBuild and runningBuild ~= KIMQ_BUILD)
        or (running and not runningBuild)
        or (rawget(SHARED0,"KimqHC_v21_PerformanceLoaded")==true and runningBuild~=KIMQ_BUILD)

    if oldRuntimeDetected then
        local age = runtimeStartedAt and math.max(0,os.clock()-runtimeStartedAt) or math.huge
        local staleBoot = (not runningGui) and runtimeState=="booting" and age>6
        if staleBoot then
            clearRuntimeClaim()
            running=false
            runningBuild=nil
            runtimeState=nil
            notifyBoot("Cleared a stale Kimqetras boot and retrying ♡",5)
        else
            notifyBoot("STOP: another Kimqetras HC build is already active. v2.99 DID NOT LOAD. Rejoin once, then run only v2.99.",9)
            warn("[Kimqetras HC v2.99] Another build is active. v2.99 DID NOT LOAD; rejoin once before testing.")
            return
        end
    end

    -- GUI with no runtime owner = stale/failed boot. Safe to remove.
    if runningGui then
        pcall(function() runningGui:Destroy() end)
    end

    local Players0=game:GetService("Players")
    local CoreGui0=game:GetService("CoreGui")
    local lp0=Players0.LocalPlayer
    local pg0=lp0 and lp0:FindFirstChildOfClass("PlayerGui")
    for _,root in ipairs({CoreGui0,pg0}) do
        if root then
            for _,name in ipairs({"KimpetrasHC_Boot","KimqetrasHC_Error","KimpetrasHC_Error"}) do
                local g=root:FindFirstChild(name)
                if g then pcall(function() g:Destroy() end) end
            end
        end
    end

    -- Clean only named render bindings from failed old boots, after confirming
    -- that no real old runtime is active.
    local knownRenderBindings = {
        "KimqMacroSpeedV240","KimqMacroSpeedV241","KimqMacroSpeedV242","KimqMacroSpeedV261",
        "KimqPermanentTimeV229","KimqPermanentTimeV230","KimqPermanentTimeV231",
        "KimqPermanentTimeV232","KimqPermanentTimeV233","KimqPermanentTimeV234",
        "KimqPermanentTimeV235","KimqPermanentTimeV236","KimqPermanentTimeV237",
        "KimqPermanentTimeV238","KimqPermanentTimeV239","KimqPermanentTimeV240",
        "KimqPermanentTimeV241","KimqPermanentTimeV242","KimqPermanentTimeV261",
    }
    for _,binding in ipairs(knownRenderBindings) do
        pcall(function() RunService0:UnbindFromRenderStep(binding) end)
    end

    -- Claim the runtime immediately so two executes cannot create two copies.
    SHARED0[KIMQ_SINGLE_KEY] = true
    SHARED0.KimqHC_CurrentBuild = KIMQ_BUILD
    SHARED0.KimqHC_RuntimeState = "booting"
    SHARED0.KimqHC_RuntimeStartedAt = os.clock()

    -- Mirror into this script's _G too for old internal code.
    _G[KIMQ_SINGLE_KEY] = true
    _G.KimqHC_CurrentBuild = KIMQ_BUILD
    _G.KimqHC_RuntimeState = "booting"
    _G.KimqHC_RuntimeStartedAt = SHARED0.KimqHC_RuntimeStartedAt

    _G.KimqShotCameraSwapEnabled = false
    _G.KimqRandomCameraZoomEnabled = false
    _G.KimqV26FeaturesReady = false
    _G.KimqBasePagesReady = false
    _G.KimqPageRepairReady = false
    _G.KimqThemeEngineReady = false
    _G.KimqAccessoryUIReady = false
    _G.KimqV26Loader = nil
    _G.KimqRefreshWingMiniTheme = nil
    -- v2.80: nil means the user has not explicitly opened/closed the main GUI yet.
    -- Late startup/watchdog passes must never override a real user choice.
    _G.KimqMainUserVisibleState = nil
    SHARED0.KimqMainUserVisibleState = nil
end


-- v2.1 uses native GUI/text hearts only; obsolete mascot/decal table removed.
-- Working safe backend + completely reorganized feature pages.

-- v2.29 keeps the v2.19 working base and adds only the requested audited features.
_G.KimqSectionRoutingVersion = "v2.1-strict-sections"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

pcall(function()
    for _, root in ipairs({CoreGui, playerGui}) do
        local old = root:FindFirstChild("KimpetrasHC")
        if old then old:Destroy() end
        local oldBoot = root:FindFirstChild("KimpetrasHC_Boot")
        if oldBoot then oldBoot:Destroy() end
    end
end)

local LIME = Color3.fromRGB(246, 239, 255) -- Purple theme background
local LIME2 = Color3.fromRGB(251, 247, 255) -- Purple theme soft background
local PINK = Color3.fromRGB(169, 116, 235) -- Purple theme accent
local PINK2 = Color3.fromRGB(229, 210, 251) -- Purple theme light accent
local INK = Color3.fromRGB(102, 77, 126)
local SOFT = Color3.fromRGB(143, 119, 164)
local WHITE = Color3.fromRGB(255, 255, 255)

-- No boot overlay: the Lasion window appears when its backend is ready.
local Status = {Text = ""} -- Keeps optional startup error reporting intact.

local failures = {}
local completed = 0
local total = 8

local function setProgress(_name)
    completed += 1
end

local function runChunk(name, source, required)
    setProgress(name)
    pcall(function()
        if type(_G.KimqBootSetStatus)=="function" then
            _G.KimqBootSetStatus("Loading "..tostring(name).."...")
        end
    end)
    task.wait(0.03)
    local fn, compileErr = loadstring(source)
    if not fn then
        local msg = name .. " COMPILE: " .. tostring(compileErr)
        table.insert(failures, msg)
        warn("[Kimqetras HC startup] " .. msg)
        Status.Text = msg
        pcall(function()
            if type(_G.KimqBootSetStatus)=="function" then _G.KimqBootSetStatus(msg) end
        end)
        if required then
            Status.Text = Status.Text .. "\ncore could not compile"
            return false
        end
        task.wait(0.2)
        return true
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        local msg = name .. " RUNTIME: " .. tostring(runtimeErr)
        table.insert(failures, msg)
        warn("[Kimqetras HC startup] " .. msg)
        Status.Text = msg
        pcall(function()
            if type(_G.KimqBootSetStatus)=="function" then _G.KimqBootSetStatus(msg) end
        end)
        if required then
            Status.Text = Status.Text .. "\ncore could not start"
            return false
        end
        task.wait(0.2)
    end
    return true
end

task.wait(0.08)

if not runChunk("core", [=====[
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Shared whitelist used by targeting + ESP
_G.KHWhitelist = _G.KHWhitelist or {}
local mouse = lp:GetMouse()

local cfg = {
    silentAim = true,
    useKeybind = false,
    silentAimKey = Enum.KeyCode.V,
    uiToggleKey = Enum.KeyCode.RightControl,

    -- v2.63: all Silent Aim controls below now feed the SAME target resolver.
    silentAimHitChance = 100,
    silentAimFOV = 150,
    silentAimFOVShow = false,
    silentAimFOVFilled = false,
    silentAimFOVOpacity = 0.58,
    silentAimFOVColor = Color3.fromRGB(255, 20, 147),
    silentAimStrictFOV = true,
    silentAimStickiness = 18,
    silentAimPriority = "Closest Cursor",

    silentAimPart = "Head",
    silentAimClosestPart = false,

    silentAimTeamCheck = false,
    silentAimWallCheck = false,
    -- v2.80: stop redirecting bullets into K.O/downed/dead targets.
    silentAimKnockCheck = true,
    silentAimMaxDist = 1000,

    -- Manual prediction is always available. Auto Prediction adds a ping-aware
    -- lead on top of these values instead of silently replacing them.
    silentAimPredX = 0,
    silentAimPredY = 0,
    silentAimAutoPrediction = true,
    silentAimAutoPredictionStrength = 1.00,

    bypassRevolver = false,
}

local bodyPartsList = {
    "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"
}

local Stats=nil
pcall(function() Stats=game:GetService("Stats") end)

-- Drawing is optional. Target selection still works even if the executor cannot
-- draw a circle; only the visual circle is unavailable in that case.
local fovCircle = {
    Thickness = 1.5,
    NumSides = 72,
    Radius = cfg.silentAimFOV,
    Color = cfg.silentAimFOVColor,
    Filled = cfg.silentAimFOVFilled,
    Visible = false,
    Transparency = cfg.silentAimFOVOpacity,
    Position = Vector2.new(0, 0),
}
if type(Drawing) == "table" and type(Drawing.new) == "function" then
    pcall(function()
        local realCircle = Drawing.new("Circle")
        realCircle.Thickness = 1.5
        realCircle.NumSides = 72
        realCircle.Radius = cfg.silentAimFOV
        realCircle.Color = cfg.silentAimFOVColor
        realCircle.Filled = cfg.silentAimFOVFilled
        realCircle.Visible = cfg.silentAimFOVShow
        realCircle.Transparency = cfg.silentAimFOVOpacity
        fovCircle = realCircle
    end)
end

local silentAimCachedPart = nil
local silentAimCachedPoint = nil
local silentAimVelocityCache = setmetatable({}, {__mode="k"})
local hitChancePart=nil
local hitChanceUntil=0
local hitChancePass=true
local lastPingRead=0
local cachedPingSeconds=.065

local function getSmoothedAimVelocity(part)
    if not part or not part:IsA("BasePart") then return Vector3.zero end
    local now=part.AssemblyLinearVelocity
    local old=silentAimVelocityCache[part]
    -- Slightly stronger smoothing than v2.62: less jitter without flattening
    -- legitimate movement/prediction.
    local smooth=old and old:Lerp(now,.48) or now
    silentAimVelocityCache[part]=smooth
    return smooth
end

local function pingSeconds()
    local now=os.clock()
    if now-lastPingRead<.35 then return cachedPingSeconds end
    lastPingRead=now

    local ms=nil
    if Stats then
        pcall(function()
            local net=Stats:FindFirstChild("Network")
            local server=net and net:FindFirstChild("ServerStatsItem")
            local ping=server and server:FindFirstChild("Data Ping")
            if ping then
                local ok,v=pcall(function() return ping:GetValue() end)
                if ok and type(v)=="number" then ms=v end
                if not ms then
                    local ok2,s=pcall(function() return ping:GetValueString() end)
                    if ok2 and s then ms=tonumber(tostring(s):match("[%d%.]+")) end
                end
            end
        end)
    end

    if type(ms)=="number" then
        cachedPingSeconds=math.clamp(ms/1000,.018,.240)
    end
    return cachedPingSeconds
end

local function isHoldingRevolver()
    if not cfg.bypassRevolver then return false end
    local char = lp.Character
    if not char then return false end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = string.lower(tool.Name)
        if string.find(toolName, "revolver",1,true) or string.find(toolName, "rev",1,true) then
            return true
        end
    end
    return false
end

local function getHum(p)
    local c = p and p.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getHRP(p)
    local c = p and p.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isAlive(p)
    local h = getHum(p)
    return h and h.Health > 0
end

local function silentAimIsKnocked(p)
    if not cfg.silentAimKnockCheck then return false end
    local char=p and p.Character
    if not char then return true end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 or hum:GetState()==Enum.HumanoidStateType.Dead then return true end

    -- Primary game convention used elsewhere in Kimqetras HC.
    local bodyEffects=char:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko=bodyEffects:FindFirstChild("K.O") or bodyEffects:FindFirstChild("KO")
            or bodyEffects:FindFirstChild("Knocked") or bodyEffects:FindFirstChild("Downed")
        if ko then
            if ko:IsA("BoolValue") and ko.Value then return true end
            if (ko:IsA("IntValue") or ko:IsA("NumberValue")) and ko.Value~=0 then return true end
        end
    end

    -- Small direct fallback for games that store the flag on the character.
    for _,name in ipairs({"K.O","KO","Knocked","Downed","Dead","Unconscious"}) do
        local flag=char:FindFirstChild(name)
        if flag then
            if flag:IsA("BoolValue") and flag.Value then return true end
            if (flag:IsA("IntValue") or flag:IsA("NumberValue")) and flag.Value~=0 then return true end
        end
    end
    return false
end

local function sameTeam(p)
    return lp.Team and p.Team and lp.Team == p.Team
end

-- v2.63 Wall Check:
-- Trace repeatedly past purely visual/non-collidable clutter instead of treating
-- a transparent effect as a concrete wall. A solid obstruction still rejects
-- the target immediately.
local function wallBetween(pos,targetCharacter)
    if not cfg.silentAimWallCheck then return false end
    local camera=workspace.CurrentCamera
    if not camera then return true end

    local origin=camera.CFrame.Position
    local ignore={}
    if lp.Character then table.insert(ignore,lp.Character) end

    for _=1,7 do
        local direction=pos-origin
        if direction.Magnitude<=.05 then return false end

        local params=RaycastParams.new()
        params.FilterDescendantsInstances=ignore
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.IgnoreWater=true

        local hit=workspace:Raycast(origin,direction,params)
        if not hit then return false end
        local inst=hit.Instance
        if targetCharacter and inst and inst:IsDescendantOf(targetCharacter) then
            return false
        end

        local ignorable=false
        if inst and inst:IsA("BasePart") then
            ignorable=(inst.Transparency>=.86 and not inst.CanCollide)
                or (not inst.CanQuery)
        end

        if ignorable then
            table.insert(ignore,inst)
            origin=hit.Position + direction.Unit*.03
        else
            return true
        end
    end
    return false
end

-- Use screen-space coordinates consistently for BOTH the target radius and the
-- Drawing circle. This fixes the "circle says they're inside but aim says no"
-- behavior caused by mixing viewport and screen coordinate spaces.
local function screenPoint(pos)
    local camera=workspace.CurrentCamera
    if not camera then return Vector3.zero,false end
    local sp,on=Vector3.zero,false
    pcall(function()
        sp,on=camera:WorldToScreenPoint(pos)
    end)
    return sp,on
end

-- v2.65 TRUE CLOSEST POINT
-- "Closest Point" now follows the actual cursor ray. If the cursor is physically
-- over a leg/arm/head, the ray resolves that exact body part AND the exact world
-- point underneath the cursor instead of comparing only the centers of parts.
local function cursorDistancePoint(point)
    if typeof(point)~="Vector3" then return math.huge,false end
    local sp,on=screenPoint(point)
    if not on or sp.Z<=0 then return math.huge,false end
    local mousePos=UIS:GetMouseLocation()
    return (Vector2.new(sp.X,sp.Y)-mousePos).Magnitude,true
end

local function fovAllowsPoint(point,extraScale)
    local d,on=cursorDistancePoint(point)
    if not on then return false,d end
    local scale=extraScale or 1
    return d <= math.max(1,cfg.silentAimFOV)*scale,d
end

local function cursorWorldRay()
    local camera=workspace.CurrentCamera
    if not camera then return nil,nil end
    local m=UIS:GetMouseLocation()
    local ray=nil

    -- ScreenPointToRay matches UIS:GetMouseLocation on normal desktop clients.
    local ok=pcall(function()
        ray=camera:ScreenPointToRay(m.X,m.Y,0)
    end)
    if (not ok or not ray) then
        pcall(function()
            ray=camera:ViewportPointToRay(m.X,m.Y,0)
        end)
    end
    if not ray or ray.Direction.Magnitude<=.001 then return nil,nil end
    return ray.Origin,ray.Direction.Unit
end

local function characterBodyParts(char)
    local parts={}
    if not char then return parts end

    -- Scan direct character body parts instead of assuming R15 names only.
    -- This also makes Closest Point work on R6/custom rigs while naturally
    -- ignoring Accessory/Tool handles because those live under child containers.
    for _,p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            table.insert(parts,p)
        end
    end

    -- Very unusual rigs can keep body parts nested; retain the known-name
    -- fallback without inserting duplicates.
    if #parts==0 then
        for _,name in ipairs(bodyPartsList) do
            local bp=char:FindFirstChild(name,true)
            if bp and bp:IsA("BasePart") then
                table.insert(parts,bp)
            end
        end
    end
    return parts
end

local function closestPointForCharacter(char,rayOrigin,rayDir)
    if not char then return nil,nil end
    local parts=characterBodyParts(char)
    if #parts==0 then
        local fallback=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        return fallback,fallback and fallback.Position or nil
    end

    -- First choice: exact cursor intersection with one of the character's real
    -- body parts. This is what makes cursor-on-leg -> leg, cursor-on-arm -> arm.
    if rayOrigin and rayDir then
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances=parts
        params.IgnoreWater=true
        local length=math.max(5000,(tonumber(cfg.silentAimMaxDist) or 1000)+500)
        local result=workspace:Raycast(rayOrigin,rayDir*length,params)
        if result and result.Instance and result.Instance:IsA("BasePart") then
            return result.Instance,result.Position
        end
    end

    -- If the cursor is just beside the character, fall back to the nearest
    -- body-part center. The expensive surface solver is intentionally avoided
    -- here: exact surface targeting already happened above when the cursor was
    -- actually over the avatar, while this fallback keeps large servers smooth.
    local bestPart,bestPoint=nil,nil
    local bestDist=math.huge
    for _,part in ipairs(parts) do
        local point=part.Position
        local dist,on=cursorDistancePoint(point)
        if on and dist<bestDist then
            bestDist=dist
            bestPart=part
            bestPoint=point
        end
    end

    if bestPart then return bestPart,bestPoint end
    local fallback=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    return fallback,fallback and fallback.Position or nil
end

local function getTargetPartAndPoint(char,rayOrigin,rayDir)
    if not char then return nil,nil end
    if cfg.silentAimClosestPart then
        return closestPointForCharacter(char,rayOrigin,rayDir)
    end
    local part=char:FindFirstChild(cfg.silentAimPart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
    return part,part and part.Position or nil
end

local function targetScore(pl,part,cursorDist,dist3D)
    local mode=tostring(cfg.silentAimPriority or "Closest Cursor")
    if mode=="Closest Distance" then
        -- Still obeys the FOV; this only decides WHO wins inside it.
        return dist3D + cursorDist*.02
    elseif mode=="Lowest Health" then
        local h=getHum(pl)
        local ratio=1
        if h and h.MaxHealth>0 then ratio=math.clamp(h.Health/h.MaxHealth,0,1) end
        return ratio*10000 + cursorDist
    end
    return cursorDist
end

local function validCandidate(pl,part,aimPoint,fovScale)
    if not pl or pl==lp or not part or not part.Parent or typeof(aimPoint)~="Vector3" then
        return false,nil,nil
    end
    if _G.KHWhitelist[pl.UserId] then return false,nil,nil end
    if not isAlive(pl) then return false,nil,nil end
    if silentAimIsKnocked(pl) then return false,nil,nil end
    if cfg.silentAimTeamCheck and sameTeam(pl) then return false,nil,nil end

    local camera=workspace.CurrentCamera
    if not camera then return false,nil,nil end
    local dist3D=(aimPoint-camera.CFrame.Position).Magnitude
    if dist3D>cfg.silentAimMaxDist then return false,nil,nil end

    local fovOK,cursorDist=fovAllowsPoint(aimPoint,fovScale)
    if not fovOK then return false,nil,nil end
    if wallBetween(aimPoint,pl.Character) then return false,nil,nil end
    return true,cursorDist,dist3D
end

local function getClosestPlayerToCursor()
    local rageTargetId=tonumber(rawget(_G,"KimqRageSilentAimTargetId"))
    if isHoldingRevolver() and not rageTargetId then return nil,nil end

    local bestPart,bestPoint=nil,nil
    local bestScore=math.huge
    -- Resolve the cursor ray once per frame, then reuse it for every candidate.
    local rayOrigin,rayDir=cursorWorldRay()

    -- v2.107 RAGE bridge: RAGE no longer has its own Force Hit aim pipeline.
    -- While RAGE Auto Shoot is actively attacking, it only tells the existing
    -- Silent Aim resolver WHICH player is current. Part choice, prediction,
    -- FOV, wall/knock/team checks and Mouse.Hit/Target handling stay here.
    if rageTargetId then
        local ragePlayer=Players:GetPlayerByUserId(rageTargetId)
        local rageChar=ragePlayer and ragePlayer.Character
        if ragePlayer and rageChar then
            local ragePart,ragePoint=getTargetPartAndPoint(rageChar,rayOrigin,rayDir)
            local ok=validCandidate(ragePlayer,ragePart,ragePoint,1)
            if ok then return ragePart,ragePoint end
        end
    end

    -- Stickiness belongs to the PLAYER, not a frozen body part. In Closest Point
    -- mode we recalculate the exact point every frame so moving the cursor from
    -- torso -> leg immediately changes the selected hit location.
    local stickyPart,stickyPoint=nil,nil
    local stickyScore=math.huge
    if silentAimCachedPart and silentAimCachedPart.Parent then
        local stickyChar=silentAimCachedPart:FindFirstAncestorOfClass("Model")
        local stickyPlayer=stickyChar and Players:GetPlayerFromCharacter(stickyChar)
        if stickyPlayer and stickyChar then
            stickyPart,stickyPoint=getTargetPartAndPoint(stickyChar,rayOrigin,rayDir)
            local stickyScale=cfg.silentAimStrictFOV and 1 or 1.12
            local ok,cursorDist,dist3D=validCandidate(stickyPlayer,stickyPart,stickyPoint,stickyScale)
            if ok then
                stickyScore=targetScore(stickyPlayer,stickyPart,cursorDist,dist3D)
            else
                stickyPart,stickyPoint=nil,nil
            end
        end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and not _G.KHWhitelist[p.UserId] and isAlive(p) and not silentAimIsKnocked(p) then
            if cfg.silentAimTeamCheck and sameTeam(p) then continue end
            local part,point=getTargetPartAndPoint(p.Character,rayOrigin,rayDir)
            local ok,cursorDist,dist3D=validCandidate(p,part,point,1)
            if ok then
                local score=targetScore(p,part,cursorDist,dist3D)
                if score<bestScore then
                    bestScore=score
                    bestPart=part
                    bestPoint=point
                end
            end
        end
    end

    if stickyPart then
        if not bestPart then return stickyPart,stickyPoint end
        local stick=math.clamp(tonumber(cfg.silentAimStickiness) or 0,0,80)/100
        local stealThreshold=stickyScore*(1-stick)
        if bestScore>=stealThreshold then
            return stickyPart,stickyPoint
        end
    end
    return bestPart,bestPoint
end

local function predictedHitPosition(part,basePoint)
    if not part then return nil end
    local velocity=getSmoothedAimVelocity(part)
    local leadX=tonumber(cfg.silentAimPredX) or 0
    local leadY=tonumber(cfg.silentAimPredY) or 0

    if cfg.silentAimAutoPrediction then
        local auto=pingSeconds()*math.clamp(tonumber(cfg.silentAimAutoPredictionStrength) or 1,.25,2.5)
        -- Horizontal movement generally benefits from the full lead; vertical
        -- movement gets a slightly calmer lead so jumps do not over-shoot.
        leadX+=auto
        leadY+=auto*.82
    end

    local originPoint=(typeof(basePoint)=="Vector3") and basePoint or part.Position
    return originPoint + Vector3.new(
        velocity.X*leadX,
        velocity.Y*leadY,
        velocity.Z*leadX
    )
end

local function passesHitChance(part)
    local now=os.clock()
    -- Cache the roll briefly so Mouse.Hit / Target / UnitRay from the SAME shot
    -- all agree. v2.62 could roll three different answers for one click.
    if part~=hitChancePart or now>=hitChanceUntil then
        hitChancePart=part
        hitChanceUntil=now+.055
        hitChancePass=math.random(1,100)<=math.clamp(tonumber(cfg.silentAimHitChance) or 100,1,100)
    end
    return hitChancePass
end

-- HOOK METAMETHOD (kept narrow: it changes only targeting mouse reads and leaves all
-- unrelated remotes/sections untouched).
pcall(function()
    if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function" or type(checkcaller) ~= "function" then
        return
    end
    local _grm = getrawmetatable(game)
    local _oldIndex = _grm.__index
    setreadonly(_grm, false)

    _grm.__index = function(self, key)
        if not checkcaller() and self == mouse and cfg.silentAim
            and (not isHoldingRevolver() or tonumber(rawget(_G,"KimqRageSilentAimTargetId"))) then
            local part=silentAimCachedPart
            local targetChar=part and part:FindFirstAncestorOfClass("Model")
            local targetPlayer=targetChar and Players:GetPlayerFromCharacter(targetChar)
            if (key == "Hit" or key == "Target" or key == "UnitRay")
                and part
                and (not targetPlayer or not silentAimIsKnocked(targetPlayer))
                and passesHitChance(part)
            then
                local camera=workspace.CurrentCamera
                local hitPos=predictedHitPosition(part,silentAimCachedPoint)
                if camera and hitPos then
                    local origin=camera.CFrame.Position
                    if key == "UnitRay" then
                        local delta=hitPos-origin
                        if delta.Magnitude>.001 then
                            return Ray.new(origin,delta.Unit)
                        end
                    elseif key == "Hit" then
                        return CFrame.new(hitPos)
                    elseif key == "Target" then
                        return part
                    end
                end
            end
        end
        return _oldIndex(self, key)
    end
    setreadonly(_grm, true)
end)

-- v2.64: Silent Aim is permanently enabled for this runtime.
-- There is no master ON/OFF toggle or keybind anymore; the controls below
-- only tune how the already-active Silent Aim behaves.
cfg.silentAim = true

RunService.RenderStepped:Connect(function()
    local mousePos=UIS:GetMouseLocation()

    fovCircle.Position=mousePos
    fovCircle.Radius=math.max(1,cfg.silentAimFOV)
    fovCircle.Color=cfg.silentAimFOVColor
    fovCircle.Filled=cfg.silentAimFOVFilled
    fovCircle.Transparency=math.clamp(cfg.silentAimFOVOpacity,0.05,1)

    if not cfg.silentAim then
        fovCircle.Visible=false
        silentAimCachedPart=nil
        silentAimCachedPoint=nil
        return
    end

    fovCircle.Visible=cfg.silentAimFOVShow and not isHoldingRevolver()
    silentAimCachedPart,silentAimCachedPoint=getClosestPlayerToCursor()
end)

-- Small read-only bridge for the GUI/debug layer; no other combat section is
-- changed to depend on Silent Aim.
_G.KimqSilentAimCurrentPart=function()
    return silentAimCachedPart
end
_G.KimqSilentAimCurrentPoint=function()
    return silentAimCachedPoint
end


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KimpetrasHC"
pcall(function()
    ScreenGui:SetAttribute("KimqBuild",KIMQ_BUILD)
    ScreenGui:SetAttribute("KimqSingleRuntime",true)
end)
ScreenGui.ResetOnSpawn = false
-- Keep the unfinished legacy/base interface completely hidden while all redesign passes build.
ScreenGui.Enabled = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 980, 0, 620)
Main.Position = UDim2.new(0.5, -490, 0.5, -310)
Main.BackgroundColor3 = Color3.fromRGB(255, 214, 232)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui


-- Drag only from the small bottom-right corner handle.
local dragging, dragInput, dragStart, startPos

local DragCorner = Instance.new("TextButton", Main)
DragCorner.Name = "DragCorner"
DragCorner.Size = UDim2.fromOffset(34,34)
DragCorner.Position = UDim2.new(1,-40,1,-40)
DragCorner.BackgroundTransparency = 1
DragCorner.Text = ""
DragCorner.AutoButtonColor = false
DragCorner.ZIndex = 20

-- tiny cute corner grip
for i=0,2 do
    local dot = Instance.new("Frame", DragCorner)
    dot.Size = UDim2.fromOffset(4,4)
    dot.Position = UDim2.new(1,-8-i*7,1,-8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    dot.BorderSizePixel = 0
    dot.ZIndex = 21
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
end

local function updateDrag(input)
    local delta = input.Position - dragStart
    local newX = startPos.X.Offset + delta.X
    local newY = startPos.Y.Offset + delta.Y
    local viewport = cam.ViewportSize
    newX = math.clamp(newX, 0, math.max(0, viewport.X - Main.AbsoluteSize.X))
    newY = math.clamp(newY, 0, math.max(0, viewport.Y - Main.AbsoluteSize.Y))
    Main.Position = UDim2.new(0, newX, 0, newY)
end

DragCorner.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

DragCorner.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 14)

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Color = Color3.fromRGB(255, 20, 147)
UIStroke.Thickness = 2

local Header = Instance.new("Frame", Main)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundTransparency = 1

-- No logo/image in the header: branding is text-only.
for _, child in ipairs(Header:GetChildren()) do
    if child:IsA("ImageLabel") or child:IsA("ImageButton") then
        child:Destroy()
    end
end

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kimqetras HC"
Title.TextColor3 = Color3.fromRGB(230, 40, 135)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left


local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -36, 0.5, -13)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 175, 215)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(230, 40, 135)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = false

local MiniCorner = Instance.new("UICorner", MinimizeBtn)
MiniCorner.CornerRadius = UDim.new(0, 8)


local MiniBubble = Instance.new("TextButton", ScreenGui)
MiniBubble.Name = "MiniBubble"
MiniBubble.Size = UDim2.new(0, 48, 0, 48)
MiniBubble.Position = UDim2.new(0.5, -24, 0.5, -24)
MiniBubble.BackgroundColor3 = Color3.fromRGB(255, 211, 230)
MiniBubble.Text = "𝑲"
MiniBubble.TextSize = 25
MiniBubble.TextColor3 = Color3.fromRGB(230, 40, 135)
MiniBubble.Font = Enum.Font.GothamBold
MiniBubble.Visible = false
MiniBubble.Active = true

local bDragging, bDragStart, bStartPos
MiniBubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bDragging = true
        bDragStart = input.Position
        bStartPos = MiniBubble.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                bDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if bDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - bDragStart
        local newX = math.clamp(bStartPos.X.Offset + delta.X, 0, cam.ViewportSize.X - 48)
        local newY = math.clamp(bStartPos.Y.Offset + delta.Y, 0, cam.ViewportSize.Y - 48)
        MiniBubble.Position = UDim2.new(0, newX, 0, newY)
    end
end)

local BubbleCorner = Instance.new("UICorner", MiniBubble)
BubbleCorner.CornerRadius = UDim.new(1, 0)

local BubbleStroke = Instance.new("UIStroke", MiniBubble)
BubbleStroke.Color = Color3.fromRGB(255, 20, 147)
BubbleStroke.Thickness = 2

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(0, 360, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(231, 92, 154)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Give every original top-level control a permanent creation order.
-- The v2.1 page builder uses this to separate sections reliably instead of
-- depending on AbsolutePosition while Roblox is still laying the GUI out.
local ScrollOrderCounter = 0
Scroll.ChildAdded:Connect(function(child)
    if child ~= UIList and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
        ScrollOrderCounter = ScrollOrderCounter + 1
        child.LayoutOrder = ScrollOrderCounter
    end
end)

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)


local function minimizeUI()
    local x = math.clamp(Main.AbsolutePosition.X + (Main.AbsoluteSize.X / 2) - 24, 0, cam.ViewportSize.X - 48)
    local y = math.clamp(Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y / 2) - 24, 0, cam.ViewportSize.Y - 48)
    MiniBubble.Position = UDim2.new(0, x, 0, y)
    _G.KimqMainUserVisibleState = false
    pcall(function() if type(getgenv)=="function" then getgenv().KimqMainUserVisibleState=false end end)
    Main.Visible = false
    MiniBubble.Visible = true
end

local function restoreUI()
    local x = math.clamp(MiniBubble.AbsolutePosition.X - (Main.AbsoluteSize.X / 2) + 24, 0, cam.ViewportSize.X - Main.AbsoluteSize.X)
    local y = math.clamp(MiniBubble.AbsolutePosition.Y - (Main.AbsoluteSize.Y / 2) + 24, 0, cam.ViewportSize.Y - Main.AbsoluteSize.Y)
    Main.Position = UDim2.new(0, x, 0, y)
    MiniBubble.Visible = false
    _G.KimqMainUserVisibleState = true
    pcall(function() if type(getgenv)=="function" then getgenv().KimqMainUserVisibleState=true end end)
    Main.Visible = true
end

MinimizeBtn.MouseButton1Click:Connect(minimizeUI)
MiniBubble.MouseButton1Click:Connect(restoreUI)

-- Every control is stamped with its real feature section at creation time.
-- This is the authoritative ownership system for the v2.1 pages; later page
-- builders no longer have to guess from screen position or nearby headers.
_G.KimqBuildSection = _G.KimqBuildSection or "silent"

local function createCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, height or 40)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BorderSizePixel = 0
    card.Parent = Scroll
    local section = tostring(_G.KimqBuildSection or "")
    if section ~= "" then
        card:SetAttribute("KimqSection", section)
    end
    
    local c = Instance.new("UICorner", card)
    c.CornerRadius = UDim.new(0, 8)
    
    local s = Instance.new("UIStroke", card)
    s.Color = Color3.fromRGB(255, 212, 243)
    s.Thickness = 1
    return card
end


-- Central control registry used by the v2.1 config system.
-- Each helper registers a getter + setter so loading a config updates BOTH
-- the GUI control and the feature's local variable/callback (Macro included).
-- v2.1 uses one authoritative config registry. Rebuild it for this execution so
-- stale setters from an older injected copy cannot leak into new presets.
_G.KimqConfigControls = {}
local KimqConfigControls = _G.KimqConfigControls

local function registerConfigControl(name, kind, getter, setter, meta)
    if type(name) ~= "string" or name == "" then return end
    KimqConfigControls[name] = {
        kind = kind,
        get = getter,
        set = setter,
        meta = type(meta)=="table" and meta or nil,
    }
end
_G.KimqRegisterConfigControl = registerConfigControl

local function addToggle(text, default, callback)
    local card = createCard(40)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(82, 116, 94)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 44, 0, 22)
    btn.Position = UDim2.new(1, -54, 0.5, -11)
    btn.Text = ""
    btn.AutoButtonColor = false

    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local cc = Instance.new("UICorner", circle)
    cc.CornerRadius = UDim.new(1, 0)

    local state = not not default
    local function paint()
        local live = _G.KimqThemeLivePalette
        local onColor = (live and live.hot) or Color3.fromRGB(243, 161, 211)
        local offColor = (live and (live.bg2 or live.bg)) or Color3.fromRGB(236, 255, 243)
        btn.BackgroundColor3 = state and onColor or offColor
        circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    end
    local function setState(v, fireCallback)
        state = not not v
        paint()
        if fireCallback ~= false then pcall(callback, state) end
    end

    paint()
    btn.MouseButton1Click:Connect(function()
        state = not state
        local live = _G.KimqThemeLivePalette
        local onColor = (live and live.hot) or Color3.fromRGB(243, 161, 211)
        local offColor = (live and (live.bg2 or live.bg)) or Color3.fromRGB(236, 255, 243)
        btn.BackgroundColor3 = state and onColor or offColor
        circle:TweenPosition(state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        callback(state)
    end)

    registerConfigControl(text, "toggle", function() return state end, function(v) setState(v, true) end, {default=default})
    return card, btn
end

local function addSlider(text, min, max, default, callback)
    local card = createCard(50)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.6, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(82, 116, 94)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size = UDim2.new(0.3, 0, 0, 20)
    valLbl.Position = UDim2.new(0.7, -10, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = Color3.fromRGB(212, 105, 169)
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 14
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame", card)
    bg.Size = UDim2.new(1, -20, 0, 8)
    bg.Position = UDim2.new(0, 10, 0, 30)
    bg.BackgroundColor3 = Color3.fromRGB(255, 212, 243)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bg)
    fill.BackgroundColor3 = Color3.fromRGB(243, 161, 211)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local currentValue = math.clamp(tonumber(default) or min, min, max)
    local function setValue(v, fireCallback)
        v = math.clamp(tonumber(v) or currentValue, min, max)
        currentValue = math.floor(v + 0.5)
        local pos = (currentValue - min) / math.max(max - min, 1e-6)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        valLbl.Text = tostring(currentValue)
        if fireCallback ~= false then pcall(callback, currentValue) end
    end
    setValue(currentValue, false)

    local sDragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / math.max(bg.AbsoluteSize.X, 1), 0, 1)
        setValue(min + (max - min) * pos, true)
    end
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = true update(input) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if sDragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)

    registerConfigControl(text, "slider", function() return currentValue end, function(v) setValue(v, true) end, {min=min,max=max,step=1})
    return card
end

local function addDecimalSlider(text, min, max, default, decimals, callback)
    decimals = decimals or 3
    local card = createCard(50)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.6, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(82, 116, 94)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size = UDim2.new(0.3, 0, 0, 20)
    valLbl.Position = UDim2.new(0.7, -10, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = Color3.fromRGB(212, 105, 169)
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 14
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame", card)
    bg.Size = UDim2.new(1, -20, 0, 8)
    bg.Position = UDim2.new(0, 10, 0, 30)
    bg.BackgroundColor3 = Color3.fromRGB(255, 212, 243)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bg)
    fill.BackgroundColor3 = Color3.fromRGB(243, 161, 211)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local scale = 10 ^ decimals
    local currentValue = tonumber(default) or min
    local function setValue(v, fireCallback)
        v = math.clamp(tonumber(v) or currentValue, min, max)
        currentValue = math.floor(v * scale + 0.5) / scale
        local pos = (currentValue - min) / math.max(max - min, 1e-6)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        valLbl.Text = string.format("%." .. decimals .. "f", currentValue)
        if fireCallback ~= false then pcall(callback, currentValue) end
    end
    setValue(currentValue, false)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / math.max(bg.AbsoluteSize.X, 1), 0, 1)
        setValue(min + (max - min) * pos, true)
    end
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)

    registerConfigControl(text, "decimal", function() return currentValue end, function(v) setValue(v, true) end, {min=min,max=max,decimals=decimals})
    return card
end

local function addButton(text, callback)
    local card = createCard(38)
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(1, -16, 1, -10)
    btn.Position = UDim2.fromOffset(8, 5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 190, 220)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(225, 55, 135)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    registerConfigControl(text, "button", function() return false end, function() pcall(callback) end, {})
    return card, btn
end

local function addDropdown(text, list, default, callback)
    local card = createCard(40)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(82, 116, 94)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0.55, 0, 0, 26)
    btn.Position = UDim2.new(0.43, 0, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(255, 190, 220)
    btn.Text = tostring(default)
    btn.TextColor3 = Color3.fromRGB(230, 40, 135)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(255, 105, 180)

    -- Keep the dropdown INSIDE its own control card.  Older builds parented
    -- every option list directly to the master Scroll, so hidden dropdowns
    -- were sorted into Silent Aim and appeared on the wrong page.
    local closedHeight, openHeight = 40, 168
    local dropFrame = Instance.new("ScrollingFrame", card)
    dropFrame.Name = "KimqDropdownOptions"
    dropFrame.Size = UDim2.new(1, -16, 0, 120)
    dropFrame.Position = UDim2.new(0, 8, 0, 40)
    dropFrame.BackgroundColor3 = Color3.fromRGB(255, 225, 238)
    dropFrame.Visible = false
    dropFrame.BorderSizePixel = 0
    dropFrame.ScrollBarThickness = 3
    dropFrame.ZIndex = 25
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 8)
    local dList = Instance.new("UIListLayout", dropFrame)
    dList.SortOrder = Enum.SortOrder.LayoutOrder
    dList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropFrame.CanvasSize = UDim2.new(0, 0, 0, dList.AbsoluteContentSize.Y)
    end)

    local currentValue = tostring(default)
    local valid = {}
    for _,v in ipairs(list) do valid[tostring(v)] = true end

    local function setOpen(open)
        dropFrame.Visible = open == true
        card.Size = UDim2.new(1, -6, 0, open and openHeight or closedHeight)
    end

    local function setValue(v, fireCallback)
        v = tostring(v)
        if not valid[v] then return false end
        currentValue = v
        btn.Text = v
        setOpen(false)
        if fireCallback ~= false then pcall(callback, v) end
        return true
    end

    for _, v in ipairs(list) do
        local item = Instance.new("TextButton", dropFrame)
        item.Size = UDim2.new(1, 0, 0, 24)
        item.BackgroundTransparency = 1
        item.Text = tostring(v)
        item.TextColor3 = Color3.fromRGB(166, 55, 105)
        item.Font = Enum.Font.Gotham
        item.TextSize = 13
        item.ZIndex = 26
        item.MouseButton1Click:Connect(function() setValue(v, true) end)
    end
    btn.MouseButton1Click:Connect(function() setOpen(not dropFrame.Visible) end)

    registerConfigControl(text, "dropdown", function() return currentValue end, function(v) setValue(v, true) end, {options=list})
    return card, btn
end

local function addKeybind(text, defaultKey, callback)
    local card = createCard(40)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(82, 116, 94)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 80, 0, 24)
    btn.Position = UDim2.new(1, -90, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(255, 190, 220)
    btn.TextColor3 = Color3.fromRGB(230, 40, 135)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", btn)
    st.Color = Color3.fromRGB(255, 105, 180)

    local currentKey = defaultKey
    btn.Text = currentKey.Name
    local listening = false

    local function resolveKey(v)
        if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then return v end
        local key = nil
        pcall(function() key = Enum.KeyCode[tostring(v)] end)
        return key
    end
    local function setKey(v, fireCallback)
        local key = resolveKey(v)
        if not key or key == Enum.KeyCode.Unknown then return false end
        currentKey = key
        btn.Text = key.Name
        if fireCallback ~= false then pcall(callback, key) end
        return true
    end

    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
    end)
    UIS.InputBegan:Connect(function(input, gpe)
        if listening and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            setKey(input.KeyCode, true)
        end
    end)

    registerConfigControl(text, "keybind", function() return currentKey.Name end, function(v) setKey(v, true) end, {})
    return card, btn
end


_G.KimpetrasCtx = {
    UIS = UIS,
    Players = Players,
    RunService = RunService,
    CoreGui = CoreGui,
    lp = lp,
    cam = cam,
    mouse = mouse,
    cfg = cfg,
    ScreenGui = ScreenGui,
    Main = Main,
    Scroll = Scroll,
    createCard = createCard,
    addToggle = addToggle,
    addSlider = addSlider,
    addDecimalSlider = addDecimalSlider,
    addButton = addButton,
    addDropdown = addDropdown,
    addKeybind = addKeybind,
}

]=====], false) then return end

-- Primary Silent Aim page controls. v2.63 keeps this section isolated, but
-- every control now feeds the same resolver used by Mouse.Hit/Target/UnitRay.
if not runChunk("silent_ui", [=====[
local C = _G.KimpetrasCtx
if not C then error("Kimqetras core context missing") end
local cfg = C.cfg
local addToggle = C.addToggle
local addSlider = C.addSlider
local addDecimalSlider = C.addDecimalSlider
local addDropdown = C.addDropdown
local addKeybind = C.addKeybind
_G.KimqBuildSection = "silent"

local silentParts = {
    "Closest Point",
    "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"
}

-- v2.64: Silent Aim is already active when the script loads.
-- Do not register a "Silent Aim" config control, so loading an older config
-- cannot switch the resolver off behind the user's back.
cfg.silentAim = true

addToggle("Show FOV Circle", cfg.silentAimFOVShow, function(v) cfg.silentAimFOVShow = v end)
addSlider("FOV Size", 10, 1000, cfg.silentAimFOV, function(v) cfg.silentAimFOV = v end)
addToggle("Strict FOV", cfg.silentAimStrictFOV, function(v) cfg.silentAimStrictFOV=v end)
addToggle("Filled FOV", cfg.silentAimFOVFilled, function(v) cfg.silentAimFOVFilled=v end)
addSlider("FOV Opacity", 5, 100, math.floor(cfg.silentAimFOVOpacity*100+.5), function(v)
    cfg.silentAimFOVOpacity=math.clamp(v/100,.05,1)
end)

addSlider("Hit Chance", 1, 100, cfg.silentAimHitChance, function(v) cfg.silentAimHitChance = v end)
addSlider("Target Stickiness", 0, 80, cfg.silentAimStickiness, function(v) cfg.silentAimStickiness=v end)
addDropdown("Target Priority", {"Closest Cursor","Closest Distance","Lowest Health"}, cfg.silentAimPriority, function(v)
    cfg.silentAimPriority=v
end)

addToggle("Bypass Revolver", cfg.bypassRevolver, function(v) cfg.bypassRevolver = v end)
addToggle("Wall Check", cfg.silentAimWallCheck, function(v) cfg.silentAimWallCheck = v end)
addToggle("Team Check", cfg.silentAimTeamCheck, function(v) cfg.silentAimTeamCheck = v end)
addToggle("Knock Check", cfg.silentAimKnockCheck, function(v) cfg.silentAimKnockCheck = v end)

local initialSilentPart = cfg.silentAimClosestPart and "Closest Point" or cfg.silentAimPart
addDropdown("Hit Part", silentParts, initialSilentPart, function(v)
    if v=="Closest Point" or v=="Closest Part" then
        cfg.silentAimClosestPart=true
    else
        cfg.silentAimClosestPart=false
        cfg.silentAimPart=v
    end
end)

-- Saved v2.63/v2.64 configs used the old string "Closest Part".
-- Transparently migrate that value instead of breaking old presets.
pcall(function()
    local reg=_G.KimqConfigControls and _G.KimqConfigControls["Hit Part"]
    if reg and type(reg.set)=="function" then
        local oldSet=reg.set
        reg.set=function(v)
            if tostring(v)=="Closest Part" then v="Closest Point" end
            return oldSet(v)
        end
    end
end)

addSlider("Max Target Distance", 50, 5000, cfg.silentAimMaxDist, function(v) cfg.silentAimMaxDist = v end)

addToggle("Auto Prediction", cfg.silentAimAutoPrediction, function(v) cfg.silentAimAutoPrediction=v end)
addDecimalSlider("Auto Prediction Strength", .25, 2.5, cfg.silentAimAutoPredictionStrength, 2, function(v)
    cfg.silentAimAutoPredictionStrength=v
end)
addDecimalSlider("Silent Prediction X", 0, 0.5, cfg.silentAimPredX, 3, function(v) cfg.silentAimPredX = v end)
addDecimalSlider("Silent Prediction Y", 0, 0.5, cfg.silentAimPredY, 3, function(v) cfg.silentAimPredY = v end)


-- Optional alternating camera swap on each local gun shot.
-- It only reacts while a real gun Tool is equipped in the Character.
-- Normal camera rotation/zoom remains available between shots; scrolling during
-- a transition cancels the scripted zoom immediately and gives control back.
-- Defaults: Zoom Speed 8 / Zoom Min 5 / Zoom Max 25 / Stay Min .500 /
-- Stay Max .500 / Frequency 2.000. Shift+4 toggles the feature.
_G.KimqShotCameraSwapEnabled = false
-- v2.80: independent ambient/random zoom mode. It uses the same speed/min/max/
-- stay/frequency tuning but does not require a shot or even an equipped gun.
_G.KimqRandomCameraZoomEnabled = false
_G.KimqCameraFixVersion = "camera-off-v1"
_G.KimqCameraZoomSpeed = tonumber(_G.KimqCameraZoomSpeed) or 8
_G.KimqCameraZoomMin = tonumber(_G.KimqCameraZoomMin) or 5
_G.KimqCameraZoomMax = tonumber(_G.KimqCameraZoomMax) or 25
_G.KimqCameraStayMin = tonumber(_G.KimqCameraStayMin) or 0.500
_G.KimqCameraStayMax = tonumber(_G.KimqCameraStayMax) or 0.500
_G.KimqCameraFrequency = tonumber(_G.KimqCameraFrequency) or 2.000

local lp = C.lp
local RunService = C.RunService
local UIS = C.UIS
local hookedCameraTools = setmetatable({}, {__mode="k"})
local hookedCameraContainers = setmetatable({}, {__mode="k"})
local cameraSwapToken = 0
local lastThirdDistance = 10
local nextCameraSwapAllowed = 0
local savedZoomMin, savedZoomMax, savedCameraMode = nil, nil, nil
local cameraOwned = false
local equippedCameraGun = nil
local randomCameraLoopToken = 0
local lastShotCameraSwapAt = 0

local function cameraTuning()
    local speed=math.clamp(tonumber(_G.KimqCameraZoomSpeed) or 8,1,20)
    local zmin=math.clamp(tonumber(_G.KimqCameraZoomMin) or 5,1,60)
    local zmax=math.clamp(tonumber(_G.KimqCameraZoomMax) or 25,1,60)
    if zmin>zmax then zmin,zmax=zmax,zmin end
    local smin=math.clamp(tonumber(_G.KimqCameraStayMin) or .5,0,3)
    local smax=math.clamp(tonumber(_G.KimqCameraStayMax) or .5,0,3)
    if smin>smax then smin,smax=smax,smin end
    local freq=math.clamp(tonumber(_G.KimqCameraFrequency) or 2,.25,10)
    return speed,zmin,zmax,smin,smax,freq
end

local function cameraDistance()
    local cam = workspace.CurrentCamera
    if not cam then return 10 end
    local ok,dist = pcall(function() return (cam.CFrame.Position-cam.Focus.Position).Magnitude end)
    if ok and type(dist)=="number" and dist==dist then return math.clamp(dist,0.5,128) end
    return 10
end

local function inFirstPerson()
    return lp.CameraMode==Enum.CameraMode.LockFirstPerson or cameraDistance()<=1.05
end

local function saveCameraDefaults()
    if savedZoomMin==nil then
        savedZoomMin=lp.CameraMinZoomDistance
        savedZoomMax=lp.CameraMaxZoomDistance
        savedCameraMode=lp.CameraMode
    end
end

local function restoreCameraLimits(restoreMode)
    -- Only release a camera this controller actually changed. Off-state input,
    -- equip and respawn callbacks must never rewrite the game's camera.
    if cameraOwned then
        pcall(function()
            if savedZoomMin > lp.CameraMaxZoomDistance then
                lp.CameraMaxZoomDistance = savedZoomMax
                lp.CameraMinZoomDistance = savedZoomMin
            else
                lp.CameraMinZoomDistance = savedZoomMin
                lp.CameraMaxZoomDistance = savedZoomMax
            end
            if restoreMode and savedCameraMode ~= nil then lp.CameraMode = savedCameraMode end
        end)
    end
    cameraOwned = false
    savedZoomMin, savedZoomMax, savedCameraMode = nil, nil, nil
end

local function cancelCameraTween(_restoreMode)
    cameraSwapToken += 1
    restoreCameraLimits(true)
end

local function setExactZoom(z)
    if not (_G.KimqShotCameraSwapEnabled or _G.KimqRandomCameraZoomEnabled) then return end
    saveCameraDefaults()
    z = math.clamp(tonumber(z) or 0.5, 0.5, 128)
    cameraOwned = true
    pcall(function()
        lp.CameraMode = Enum.CameraMode.Classic
        if z > lp.CameraMaxZoomDistance then
            lp.CameraMaxZoomDistance = z
            lp.CameraMinZoomDistance = z
        else
            lp.CameraMinZoomDistance = z
            lp.CameraMaxZoomDistance = z
        end
    end)
end

local function isLikelyGun(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n=tostring(tool.Name or ""):lower()
    if n:find("knife",1,true) or n:find("wallet",1,true) or n:find("phone",1,true) then return false end
    local gunWords={"revolver","shotgun","silencer","smg","pistol","rifle","gun","tactical","double","glock","uzi","ak"}
    for _,word in ipairs(gunWords) do if n:find(word,1,true) then return true end end
    for _,d in ipairs(tool:GetDescendants()) do
        local dn=tostring(d.Name or ""):lower()
        if dn=="ammo" or dn=="clip" or dn=="muzzle" or dn=="muzzleflash" then return true end
    end
    return false
end

local function gunIsActuallyEquipped(tool)
    return tool and tool==equippedCameraGun and tool.Parent==lp.Character and isLikelyGun(tool)
end

local function smoothZoomTo(target,token,tool)
    local start=cameraDistance()
    local speed,_,_,_,_,freq=cameraTuning()
    local duration=math.clamp(.32*(8/speed)*(2/freq),.08,.9)
    local t0=os.clock()
    while token==cameraSwapToken and _G.KimqShotCameraSwapEnabled and gunIsActuallyEquipped(tool) do
        local a=math.clamp((os.clock()-t0)/duration,0,1)
        local eased=a*a*(3-2*a)
        setExactZoom(start+(target-start)*eased)
        if a>=1 then break end
        RunService.RenderStepped:Wait()
    end
    -- A superseded coroutine cannot release or write the newer owner's camera.
    if token ~= cameraSwapToken then return end
    if not _G.KimqShotCameraSwapEnabled or not gunIsActuallyEquipped(tool) then
        restoreCameraLimits(true)
        return
    end
    setExactZoom(target)
    RunService.RenderStepped:Wait()
    if token ~= cameraSwapToken then return end
    restoreCameraLimits(true)
end

local function cameraSwapBlockedTool(tool)
    if not tool then return false end
    local n=tostring(tool.Name or ""):lower():gsub("[%[%]_%-%s]","")
    return n:find("revolver",1,true)~=nil
end

local function doShotCameraSwap(tool)
    if cameraSwapBlockedTool(tool) then return end
    if not _G.KimqShotCameraSwapEnabled or not gunIsActuallyEquipped(tool) then return end

    local now=os.clock()
    lastShotCameraSwapAt=now
    if now<nextCameraSwapAllowed then return end

    local _,zmin,zmax,stayMin,stayMax,freq=cameraTuning()
    local stay=stayMin
    if stayMax>stayMin then stay=stayMin+(stayMax-stayMin)*math.random() end
    nextCameraSwapAllowed=now+math.max(stay,1/freq)

    saveCameraDefaults()
    local dist=cameraDistance()
    local first=inFirstPerson()

    -- Your actual current view decides the next direction. So you can freely
    -- zoom anywhere between shots and the next shot still behaves naturally.
    local target
    if first then
        target=math.clamp(lastThirdDistance or zmin,zmin,zmax)
    else
        if dist>1.1 then lastThirdDistance=math.clamp(dist,zmin,zmax) end
        target=0.5
    end

    cameraSwapToken+=1
    local token=cameraSwapToken
    task.spawn(function() smoothZoomTo(target,token,tool) end)
end

local function randomCameraCanRun()
    if not _G.KimqRandomCameraZoomEnabled then return false end
    local camera=workspace.CurrentCamera
    if not camera or camera.CameraType==Enum.CameraType.Scriptable then return false end
    -- Let an actual shot-camera transition win briefly if both modes are enabled.
    if os.clock()-lastShotCameraSwapAt<.65 then return false end
    return true
end

local function smoothRandomZoomTo(target,token)
    local start=cameraDistance()
    local speed=select(1,cameraTuning())
    local duration=math.clamp(.34*(8/speed),.08,.9)
    local t0=os.clock()
    while token==cameraSwapToken and randomCameraCanRun() do
        local a=math.clamp((os.clock()-t0)/duration,0,1)
        local eased=a*a*(3-2*a)
        setExactZoom(start+(target-start)*eased)
        if a>=1 then break end
        RunService.RenderStepped:Wait()
    end
    if token ~= cameraSwapToken then return end
    restoreCameraLimits(true)
end

local function doRandomCameraZoom()
    if not randomCameraCanRun() then return end
    local _,zmin,zmax=cameraTuning()
    if zmax-zmin<.25 then return end
    saveCameraDefaults()
    local dist=cameraDistance()
    local midpoint=(zmin+zmax)*.5
    local target
    -- Alternate based on current distance so it visibly goes IN and OUT instead
    -- of repeatedly choosing nearly-identical random distances.
    if dist<=midpoint then
        target=midpoint+(zmax-midpoint)*(.35+.65*math.random())
    else
        target=zmin+(midpoint-zmin)*(.65*math.random())
    end
    cameraSwapToken+=1
    local token=cameraSwapToken
    task.spawn(function() smoothRandomZoomTo(target,token) end)
end

local function startRandomCameraLoop()
    randomCameraLoopToken+=1
    local loopToken=randomCameraLoopToken
    if not _G.KimqRandomCameraZoomEnabled then return end
    task.spawn(function()
        while loopToken==randomCameraLoopToken and _G.KimqRandomCameraZoomEnabled do
            local _,_,_,stayMin,stayMax,freq=cameraTuning()
            local waitTime=stayMin
            if stayMax>stayMin then waitTime=stayMin+(stayMax-stayMin)*math.random() end
            waitTime=math.max(waitTime,1/math.max(freq,.25),.12)
            task.wait(waitTime)
            if loopToken~=randomCameraLoopToken or not _G.KimqRandomCameraZoomEnabled then break end
            doRandomCameraZoom()
        end
    end)
end

addToggle("Random Camera Zoom", _G.KimqRandomCameraZoomEnabled, function(v)
    _G.KimqRandomCameraZoomEnabled=v==true
    randomCameraLoopToken+=1
    cancelCameraTween(false)
    if _G.KimqRandomCameraZoomEnabled then
        saveCameraDefaults()
        startRandomCameraLoop()
    end
end)

addToggle("Shot Camera Swap", _G.KimqShotCameraSwapEnabled, function(v)
    _G.KimqShotCameraSwapEnabled=v==true
    cancelCameraTween(not _G.KimqShotCameraSwapEnabled)
    nextCameraSwapAllowed=0
    if _G.KimqShotCameraSwapEnabled then
        local _,zmin,zmax=cameraTuning()
        local d=cameraDistance()
        if d>1.1 then lastThirdDistance=math.clamp(d,zmin,zmax) end
    end
end)

addSlider("Zoom Speed", 1, 20, _G.KimqCameraZoomSpeed, function(v)
    _G.KimqCameraZoomSpeed=v
end)
addSlider("Zoom Min", 1, 30, _G.KimqCameraZoomMin, function(v)
    _G.KimqCameraZoomMin=v
end)
addSlider("Zoom Max", 5, 50, _G.KimqCameraZoomMax, function(v)
    _G.KimqCameraZoomMax=v
end)
addDecimalSlider("Stay Min", 0, 2, _G.KimqCameraStayMin, 3, function(v)
    _G.KimqCameraStayMin=v
end)
addDecimalSlider("Stay Max", 0, 2, _G.KimqCameraStayMax, 3, function(v)
    _G.KimqCameraStayMax=v
end)
addDecimalSlider("Frequency", 0.25, 8, _G.KimqCameraFrequency, 3, function(v)
    _G.KimqCameraFrequency=v
end)

if _G.KimqRandomCameraZoomEnabled then
    task.defer(startRandomCameraLoop)
end

UIS.InputBegan:Connect(function(input,gpe)
    if gpe or input.UserInputType~=Enum.UserInputType.Keyboard then return end
    if input.KeyCode==Enum.KeyCode.Four and (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then
        local nextValue=not _G.KimqShotCameraSwapEnabled
        local reg=rawget(_G,"KimqConfigControls")
        local control=reg and reg["Shot Camera Swap"]
        if control and type(control.set)=="function" then
            pcall(control.set,nextValue)
        else
            _G.KimqShotCameraSwapEnabled=nextValue
            cancelCameraTween(not nextValue)
            nextCameraSwapAllowed=0
            -- cancelCameraTween already released this controller's camera.
        end
    end
end)

-- If you scroll while a scripted zoom is moving, manual control wins instantly.
UIS.InputChanged:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseWheel and equippedCameraGun then
        cancelCameraTween(false)
        task.defer(function()
            local _,zmin,zmax=cameraTuning()
            local d=cameraDistance()
            if d>1.1 then lastThirdDistance=math.clamp(d,zmin,zmax) end
        end)
    end
end)

local function hookCameraTool(tool)
    if not tool or not tool:IsA("Tool") or hookedCameraTools[tool] then return end
    hookedCameraTools[tool]=true
    tool.Equipped:Connect(function()
        if isLikelyGun(tool) then
            equippedCameraGun=tool
            local _,zmin,zmax=cameraTuning()
            local d=cameraDistance()
            if d>1.1 then lastThirdDistance=math.clamp(d,zmin,zmax) end
        end
    end)
    tool.Unequipped:Connect(function()
        if equippedCameraGun==tool then
            equippedCameraGun=nil
            cancelCameraTween(false)
            nextCameraSwapAllowed=0
        end
    end)
    tool.Activated:Connect(function()
        doShotCameraSwap(tool)
    end)
end

local function hookCameraContainer(container)
    if not container or hookedCameraContainers[container] then return end
    hookedCameraContainers[container]=true
    for _,ch in ipairs(container:GetChildren()) do hookCameraTool(ch) end
    container.ChildAdded:Connect(hookCameraTool)
end

hookCameraContainer(lp:FindFirstChildOfClass("Backpack"))
if lp.Character then
    hookCameraContainer(lp.Character)
    for _,ch in ipairs(lp.Character:GetChildren()) do
        if ch:IsA("Tool") and isLikelyGun(ch) then equippedCameraGun=ch break end
    end
end
lp.CharacterAdded:Connect(function(char)
    equippedCameraGun=nil
    cancelCameraTween(false)
    nextCameraSwapAllowed=0
    task.delay(0.15,function()
        hookCameraContainer(char)
        hookCameraContainer(lp:FindFirstChildOfClass("Backpack"))
    end)
end)
]=====], false) then return end




if not runChunk("macro", [=====[
local C = _G.KimpetrasCtx
if not C then error("Kimqetras core context missing") end
local UIS, RunService, lp, Scroll = C.UIS, C.RunService, C.lp, C.Scroll
local createCard, addToggle, addSlider, addKeybind = C.createCard, C.addToggle, C.addSlider, C.addKeybind
_G.KimqBuildSection = "macro"

-- ========================================================
-- MACRO / SPEED + I/O
-- Restored from the older working Kimqetras macro.
-- ========================================================
local MacroMaster = false
local MacroActive = false
local MacroSpeed = 50
local MacroKey = Enum.KeyCode.X

local MacroIOSpam = false
local MacroIOInterval = 0.022
local MacroIOFlip = false
local MacroIOAccumulator = 0

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

-- Compatibility globals for configs / other Kimqetras modules.
_G.SpeedMaster = MacroMaster
_G.SpeedActive = MacroActive
_G.SpeedValue = MacroSpeed
_G.SpeedKey = MacroKey

local MacroHeader = Instance.new("TextLabel", Scroll)
MacroHeader.Size = UDim2.new(1,-6,0,34)
MacroHeader.BackgroundTransparency = 1
MacroHeader.Text = "♥  Macro"
MacroHeader.TextColor3 = Color3.fromRGB(225,73,140)
MacroHeader.Font = Enum.Font.GothamBold
MacroHeader.TextSize = 18
MacroHeader.TextXAlignment = Enum.TextXAlignment.Left

addToggle("Macro / Speed Master", MacroMaster, function(v)
    MacroMaster = not not v
    _G.SpeedMaster = MacroMaster
    if not MacroMaster then
        MacroActive = false
        _G.SpeedActive = false
        MacroIOAccumulator = 0
        MacroIOFlip = false
    end
end)

addKeybind("Macro Key", MacroKey, function(v)
    MacroKey = v
    _G.SpeedKey = v
end)

addSlider("Macro Speed", 16, 1000, MacroSpeed, function(v)
    MacroSpeed = v
    _G.SpeedValue = v
end)

addToggle("I / O Spam While Macroing", MacroIOSpam, function(v)
    MacroIOSpam = not not v
    MacroIOAccumulator = 0
    MacroIOFlip = false
end)

local MacroHintCard = createCard(54)
local MacroHint = Instance.new("TextLabel", MacroHintCard)
MacroHint.Size = UDim2.new(1,-20,1,0)
MacroHint.Position = UDim2.fromOffset(10,0)
MacroHint.BackgroundTransparency = 1
MacroHint.Text = "Turn Master on, press your Macro Key to toggle it. I / O spam alternates I and O while the macro is active."
MacroHint.TextColor3 = Color3.fromRGB(197,112,145)
MacroHint.Font = Enum.Font.Gotham
MacroHint.TextSize = 11
MacroHint.TextXAlignment = Enum.TextXAlignment.Left
MacroHint.TextWrapped = true

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == MacroKey then
        if MacroMaster then
            MacroActive = not MacroActive
            _G.SpeedActive = MacroActive
            if MacroActive then
                task.defer(function()
                    local char=lp.Character
                    local hum=char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local wanted=math.clamp(tonumber(MacroSpeed) or 50,16,1000)
                        pcall(function() hum.WalkSpeed=wanted end)
                    end
                end)
            end
        end
    end
end)

local function sendMacroIO(keyCode)
    local sent = false

    if VirtualInputManager then
        sent = pcall(function()
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.delay(.006, function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                end)
            end)
        end)
    end
    if sent then return end

    -- Executor fallback used by the older working build.
    local vk = (keyCode == Enum.KeyCode.I) and 0x49 or 0x4F
    if type(keypress) == "function" and type(keyrelease) == "function" then
        pcall(function()
            keypress(vk)
            keyrelease(vk)
        end)
    end
end

local macroHumanoid=nil
local macroWalkConn=nil
local macroCharConn=nil
local macroApplying=false

local function desiredMacroSpeed()
    return math.clamp(tonumber(MacroSpeed) or 50,16,1000)
end

local function enforceMacroSpeed()
    if macroApplying or not (MacroMaster and MacroActive) then return end
    local char=lp.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local wanted=desiredMacroSpeed()
    if hum.WalkSpeed~=wanted then
        macroApplying=true
        pcall(function() hum.WalkSpeed=wanted end)
        macroApplying=false
    end
end

local function bindMacroHumanoid(char)
    if macroWalkConn then pcall(function() macroWalkConn:Disconnect() end); macroWalkConn=nil end
    macroHumanoid=nil
    if not char then return end

    local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",6)
    if not hum then return end
    macroHumanoid=hum

    -- FFA's round controller changes WalkSpeed after the character initially
    -- spawns. Re-assert immediately whenever that happens.
    macroWalkConn=hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if MacroMaster and MacroActive and not macroApplying then
            enforceMacroSpeed()
        end
    end)

    if MacroMaster and MacroActive then
        task.defer(enforceMacroSpeed)
    end
end

if lp.Character then task.defer(bindMacroHumanoid,lp.Character) end
macroCharConn=lp.CharacterAdded:Connect(function(char)
    task.defer(bindMacroHumanoid,char)
end)

-- PreSimulation affects the next physics step.
pcall(function()
    RunService.PreSimulation:Connect(function()
        enforceMacroSpeed()
    end)
end)

-- Heartbeat catches round scripts that update during simulation.
RunService.Heartbeat:Connect(function(dt)
    enforceMacroSpeed()

    if MacroMaster and MacroActive and MacroIOSpam then
        MacroIOAccumulator += dt
        while MacroIOAccumulator >= MacroIOInterval do
            MacroIOAccumulator -= MacroIOInterval
            MacroIOFlip = not MacroIOFlip
            sendMacroIO(MacroIOFlip and Enum.KeyCode.I or Enum.KeyCode.O)
        end
    else
        MacroIOAccumulator = 0
        MacroIOFlip = false
    end

    _G.SpeedMaster = MacroMaster
    _G.SpeedActive = MacroActive
    _G.SpeedValue = MacroSpeed
    _G.SpeedKey = MacroKey
end)

-- A late render pass catches client round controllers that clamp speed
-- after Heartbeat. This still uses Humanoid.WalkSpeed only; no CFrame macro.
pcall(function()
    RunService:BindToRenderStep("KimqMacroSpeedV261",Enum.RenderPriority.Last.Value,function()
        enforceMacroSpeed()
    end)
end)

]=====], false) then return end

if not runChunk("extras", [=====[
local C = _G.KimpetrasCtx
if not C then error("Kimqetras core context missing") end
local Players, RunService, lp, cam, Scroll = C.Players, C.RunService, C.lp, C.cam, C.Scroll
local createCard, addToggle, addSlider, addDecimalSlider, addButton = C.createCard, C.addToggle, C.addSlider, C.addDecimalSlider, C.addButton
-- ========================================================
-- KIM.CHAR / AVATAR - MERGED INTO KIMQETRAS
-- ========================================================

-- v2.84: Avatar subsystem intentionally reverted to the exact v2.82 implementation.
local AvatarEnabled = false
local AvatarHeadless = false
local AvatarTarget = ""

-- ========================================================
-- EXTRA FEATURES FROM DOCUMENT (3)
-- Whitelist / Protection / Anti Fall / Delay Changer / ESP
-- ========================================================

local ExtraAntiAimView = true
local ExtraAntiFall = false
local ExtraDelayChanger = false
local ExtraDelayRevolver = 0.03
local ExtraDelayDoubleBarrel = 0.3
local ExtraDelayTactical = 0.0
local ExtraDelayOthers = 0.095

local ExtraESPEnabled = false
local ExtraESPBoxes = false
local ExtraESPNames = false
local ExtraESPDistance = false
local ExtraESPHealth = false
local ExtraESPTracer = false
local ExtraESPSkeleton = false
local ExtraESPColor = _G.KimqESPColor or Color3.fromRGB(243, 161, 211)
_G.KimqESPColor = ExtraESPColor
_G.KimqSetESPColor = function(color)
    if typeof(color) == "Color3" then
        ExtraESPColor = color
        _G.KimqESPColor = color
    end
end

-- Anti Aim View logic adapted from document (3)
local extraAntiAimConnections = {}
local function setExtraAntiAimView(enable)
    ExtraAntiAimView = enable
    for _, conn in ipairs(extraAntiAimConnections) do
        pcall(function() conn:Disconnect() end)
    end
    extraAntiAimConnections = {}
    if not enable then return end

    local dataFolder = lp:FindFirstChild("DataFolder") or lp:WaitForChild("DataFolder", 5)
    if not dataFolder then return end

    local shotLand = dataFolder:FindFirstChild("ShotLand")
    local shotTotal = dataFolder:FindFirstChild("ShotTotal")
    local warning = dataFolder:FindFirstChild("Warning")
    local lockFlagged = dataFolder:FindFirstChild("LockFlagged")

    local function safeConnect(obj, callback)
        if obj then
            local c = obj:GetPropertyChangedSignal("Value"):Connect(callback)
            table.insert(extraAntiAimConnections, c)
        end
    end

    safeConnect(shotTotal, function()
        if shotTotal and shotLand and shotTotal.Value > 0 then
            shotLand.Value = 0
        end
    end)
    safeConnect(warning, function() if warning then warning.Value = 0 end end)
    safeConnect(lockFlagged, function() if lockFlagged then lockFlagged.Value = 0 end end)

    local function hookCharacter(char)
        local bodyEffects = char:FindFirstChild("BodyEffects")
        if not bodyEffects then return end
        local gunFiring = bodyEffects:FindFirstChild("GunFiring")
        local gunShotChanges = bodyEffects:FindFirstChild("GunShotChanges")
        safeConnect(gunFiring, function() if gunFiring then gunFiring.Value = false end end)
        safeConnect(gunShotChanges, function() if gunShotChanges then gunShotChanges.Value = 0 end end)
    end

    if lp.Character then hookCharacter(lp.Character) end
    table.insert(extraAntiAimConnections, lp.CharacterAdded:Connect(function(char)
        task.wait(0.25)
        hookCharacter(char)
    end))
end

-- Anti Fall logic from document (3)
-- Event-driven instead of polling every Heartbeat.
local extraAntiFallStateConn
local function hookExtraAntiFall(char)
    if extraAntiFallStateConn then pcall(function() extraAntiFallStateConn:Disconnect() end); extraAntiFallStateConn=nil end
    local hum=char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",5))
    if not hum then return end
    extraAntiFallStateConn=hum.StateChanged:Connect(function(_,newState)
        if ExtraAntiFall and hum.Health>1 and newState==Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end
if lp.Character then hookExtraAntiFall(lp.Character) end
lp.CharacterAdded:Connect(hookExtraAntiFall)

-- Delay Changer logic adapted from document (3)
local extraDelayConnections = setmetatable({}, {__mode = "k"})
local function getExtraDelayForValue(v)
    local tool = v:FindFirstAncestorOfClass("Tool")
    if tool then
        if tool.Name == "[Revolver]" then return ExtraDelayRevolver end
        if tool.Name == "[Double-Barrel SG]" then return ExtraDelayDoubleBarrel end
        if tool.Name == "[TacticalShotgun]" then return ExtraDelayTactical end
    end
    return ExtraDelayOthers
end

local function applyExtraDelay(v)
    if not ExtraDelayChanger then return end
    if not ((v.Name == "ShootingCooldown" or v.Name == "ToleranceCooldown") and v:IsA("ValueBase")) then return end
    local function enforce()
        if ExtraDelayChanger and v.Parent then
            local wanted = getExtraDelayForValue(v)
            if v.Value ~= wanted then v.Value = wanted end
        end
    end
    enforce()
    if not extraDelayConnections[v] then
        extraDelayConnections[v] = v:GetPropertyChangedSignal("Value"):Connect(enforce)
    end
end

local function applyAllExtraDelays()
    if not ExtraDelayChanger then return end
    local backpack=lp:FindFirstChildOfClass("Backpack")
    if backpack then for _,v in ipairs(backpack:GetDescendants()) do applyExtraDelay(v) end end
    local char=lp.Character
    if char then for _,v in ipairs(char:GetDescendants()) do applyExtraDelay(v) end end
end

local extraDelayBackpack=lp:FindFirstChildOfClass("Backpack")
if extraDelayBackpack then extraDelayBackpack.DescendantAdded:Connect(function(v) if ExtraDelayChanger then applyExtraDelay(v) end end) end
lp.CharacterAdded:Connect(function(char)
    char.DescendantAdded:Connect(function(v) if ExtraDelayChanger then applyExtraDelay(v) end end)
    if ExtraDelayChanger then task.defer(applyAllExtraDelays) end
end)

-- ESP logic adapted from document (3)
local extraESPObjects = {}
local extraBoneConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local function hideExtraESP(objs)
    if not objs then return end
    objs.Box.Visible = false
    objs.Name.Visible = false
    objs.Health.Visible = false
    objs.Distance.Visible = false
    objs.Tracer.Visible = false
    for _, line in pairs(objs.Skeleton) do line.Visible = false end
end

local function createExtraESP(plr)
    if extraESPObjects[plr] or not Drawing or not Drawing.new then return end
    local box = Drawing.new("Square") box.Thickness = 1 box.Filled = false box.Color = ExtraESPColor box.Visible = false
    local name = Drawing.new("Text") name.Size = 13 name.Center = true name.Outline = true name.Color = ExtraESPColor name.Visible = false
    local health = Drawing.new("Text") health.Size = 13 health.Center = false health.Outline = true health.Color = Color3.fromRGB(50,255,50) health.Visible = false
    local distance = Drawing.new("Text") distance.Size = 12 distance.Center = true distance.Outline = true distance.Color = ExtraESPColor distance.Visible = false
    local tracer = Drawing.new("Line") tracer.Thickness = 1 tracer.Color = ExtraESPColor tracer.Visible = false
    extraESPObjects[plr] = {Box=box, Name=name, Health=health, Distance=distance, Tracer=tracer, Skeleton={}}
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then createExtraESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= lp then createExtraESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    local objs = extraESPObjects[p]
    if objs then
        pcall(function() objs.Box:Remove() end) pcall(function() objs.Name:Remove() end)
        pcall(function() objs.Health:Remove() end) pcall(function() objs.Distance:Remove() end)
        pcall(function() objs.Tracer:Remove() end)
        for _, line in pairs(objs.Skeleton) do pcall(function() line:Remove() end) end
        extraESPObjects[p] = nil
    end
end)

local extraESPWasEnabled = false
RunService.RenderStepped:Connect(function()
    if not ExtraESPEnabled then
        if extraESPWasEnabled then
            for _, objs in pairs(extraESPObjects) do hideExtraESP(objs) end
            extraESPWasEnabled = false
        end
        return
    end
    extraESPWasEnabled = true
    for plr, objs in pairs(extraESPObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if ExtraESPEnabled and not _G.KHWhitelist[plr.UserId] and hrp and hum and hum.Health > 0 then
            local rootPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local head = char:FindFirstChild("Head") or hrp
                local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local topLeft = Vector2.new(rootPos.X - (boxHeight / 4), rootPos.Y - boxHeight / 2)

                if ExtraESPBoxes then
                    objs.Box.Size = Vector2.new(boxHeight / 2, boxHeight)
                    objs.Box.Position = topLeft objs.Box.Color = ExtraESPColor objs.Box.Visible = true
                else objs.Box.Visible = false end

                if ExtraESPNames then
                    objs.Name.Position = Vector2.new(rootPos.X, topLeft.Y - 16)
                    objs.Name.Text = plr.Name objs.Name.Color = ExtraESPColor objs.Name.Visible = true
                else objs.Name.Visible = false end

                if ExtraESPHealth then
                    local hp = hum.Health / math.max(hum.MaxHealth, 1)
                    objs.Health.Position = Vector2.new(topLeft.X - 26, topLeft.Y)
                    objs.Health.Text = tostring(math.floor(hp * 100)) .. "%"
                    objs.Health.Color = hp > 0.5 and Color3.fromRGB(50,255,50) or (hp > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,50,50))
                    objs.Health.Visible = true
                else objs.Health.Visible = false end

                if ExtraESPDistance then
                    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and math.floor((myRoot.Position - hrp.Position).Magnitude) or 0
                    objs.Distance.Position = Vector2.new(rootPos.X, topLeft.Y + boxHeight + 4)
                    objs.Distance.Text = tostring(dist) .. "m" objs.Distance.Color = ExtraESPColor objs.Distance.Visible = true
                else objs.Distance.Visible = false end

                if ExtraESPTracer then
                    objs.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    objs.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    objs.Tracer.Color = ExtraESPColor objs.Tracer.Visible = true
                else objs.Tracer.Visible = false end

                if ExtraESPSkeleton then
                    for _, pair in ipairs(extraBoneConnections) do
                        local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                        if a and b then
                            local p1, on1 = cam:WorldToViewportPoint(a.Position)
                            local p2, on2 = cam:WorldToViewportPoint(b.Position)
                            local key = pair[1] .. pair[2]
                            if on1 and on2 then
                                if not objs.Skeleton[key] then
                                    local line = Drawing.new("Line") line.Thickness = 1.5 line.Transparency = 0.6
                                    objs.Skeleton[key] = line
                                end
                                local line = objs.Skeleton[key]
                                line.From = Vector2.new(p1.X,p1.Y) line.To = Vector2.new(p2.X,p2.Y)
                                line.Color = ExtraESPColor line.Visible = true
                            elseif objs.Skeleton[key] then objs.Skeleton[key].Visible = false end
                        end
                    end
                else
                    for _, line in pairs(objs.Skeleton) do line.Visible = false end
                end
            else hideExtraESP(objs) end
        else hideExtraESP(objs) end
    end
end)

-- Whitelist section
_G.KimqBuildSection = "whitelist"
local WhitelistHeader = Instance.new("TextLabel", Scroll)
WhitelistHeader.Size = UDim2.new(1,-6,0,34)
WhitelistHeader.BackgroundTransparency = 1
WhitelistHeader.Text = "♥  Whitelist"
WhitelistHeader.TextColor3 = Color3.fromRGB(225,73,140)
WhitelistHeader.Font = Enum.Font.GothamBold
WhitelistHeader.TextSize = 18
WhitelistHeader.TextXAlignment = Enum.TextXAlignment.Left

local whitelistCards = {}
local function addWhitelistPlayer(plr)
    if plr == lp or whitelistCards[plr] then return end
    local card = createCard(38)
    card:SetAttribute("KimqSection", "whitelist")
    whitelistCards[plr] = card
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1,-70,1,0) lbl.Position = UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency = 1 lbl.Text = plr.Name
    lbl.TextColor3 = Color3.fromRGB(166,55,105) lbl.Font = Enum.Font.GothamSemibold lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.fromOffset(48,22) btn.Position = UDim2.new(1,-58,0.5,-11)
    btn.AutoButtonColor = false btn.Font = Enum.Font.GothamSemibold btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    local function refresh()
        local on = _G.KHWhitelist[plr.UserId] == true
        btn.Text = on and "ON" or "OFF"
        local live = _G.KimqThemeLivePalette
        local hot = (live and live.hot) or Color3.fromRGB(243,161,211)
        local soft = (live and (live.soft or live.bg2)) or Color3.fromRGB(236,255,243)
        local white = (live and live.white) or Color3.new(1,1,1)
        local text = (live and live.text) or Color3.fromRGB(82,116,94)
        btn.BackgroundColor3 = on and hot or soft
        btn.TextColor3 = on and white or text
    end
    btn.MouseButton1Click:Connect(function()
        _G.KHWhitelist[plr.UserId] = not _G.KHWhitelist[plr.UserId]
        refresh()
    end)
    refresh()
end
for _, p in ipairs(Players:GetPlayers()) do addWhitelistPlayer(p) end
Players.PlayerAdded:Connect(addWhitelistPlayer)
Players.PlayerRemoving:Connect(function(p)
    if whitelistCards[p] then whitelistCards[p]:Destroy() whitelistCards[p] = nil end
end)
addButton("Clear Whitelist", function()
    table.clear(_G.KHWhitelist)
    for p, card in pairs(whitelistCards) do
        if card and card.Parent then
            local btn = card:FindFirstChildOfClass("TextButton")
            if btn then
                local live = _G.KimqThemeLivePalette
                btn.Text = "OFF"
                btn.BackgroundColor3 = (live and (live.soft or live.bg2)) or Color3.fromRGB(236,255,243)
                btn.TextColor3 = (live and live.text) or Color3.fromRGB(82,116,94)
            end
        end
    end
end)

-- Protection section
_G.KimqBuildSection = "protection"
local ProtectionHeader = Instance.new("TextLabel", Scroll)
ProtectionHeader.Size = UDim2.new(1,-6,0,34)
ProtectionHeader.BackgroundTransparency = 1
ProtectionHeader.Text = "♥  Protection"
ProtectionHeader.TextColor3 = Color3.fromRGB(225,73,140)
ProtectionHeader.Font = Enum.Font.GothamBold
ProtectionHeader.TextSize = 18
ProtectionHeader.TextXAlignment = Enum.TextXAlignment.Left
addToggle("Anti Aim View", ExtraAntiAimView, function(v) setExtraAntiAimView(v) end)
addToggle("0% Aim Accuracy", true, function() end)

-- Anti Fall section
_G.KimqBuildSection = "antifall"
local AntiFallHeader = Instance.new("TextLabel", Scroll)
AntiFallHeader.Size = UDim2.new(1,-6,0,34)
AntiFallHeader.BackgroundTransparency = 1
AntiFallHeader.Text = "♥  Anti Fall"
AntiFallHeader.TextColor3 = Color3.fromRGB(225,73,140)
AntiFallHeader.Font = Enum.Font.GothamBold
AntiFallHeader.TextSize = 18
AntiFallHeader.TextXAlignment = Enum.TextXAlignment.Left
addToggle("Anti Fall", ExtraAntiFall, function(v) ExtraAntiFall = v end)

-- Delay Changer section
_G.KimqBuildSection = "delay"
local DelayHeader = Instance.new("TextLabel", Scroll)
DelayHeader.Size = UDim2.new(1,-6,0,34)
DelayHeader.BackgroundTransparency = 1
DelayHeader.Text = "♥  Delay Changer"
DelayHeader.TextColor3 = Color3.fromRGB(225,73,140)
DelayHeader.Font = Enum.Font.GothamBold
DelayHeader.TextSize = 18
DelayHeader.TextXAlignment = Enum.TextXAlignment.Left
addToggle("Delay Changer", ExtraDelayChanger, function(v)
    ExtraDelayChanger = v
    if v then applyAllExtraDelays() end
end)
addDecimalSlider("[Revolver] Delay", 0, 0.5, ExtraDelayRevolver, 3, function(v) ExtraDelayRevolver = v if ExtraDelayChanger then applyAllExtraDelays() end end)
addDecimalSlider("[Double-Barrel SG] Delay", 0, 0.5, ExtraDelayDoubleBarrel, 3, function(v) ExtraDelayDoubleBarrel = v if ExtraDelayChanger then applyAllExtraDelays() end end)
addDecimalSlider("[TacticalShotgun] Delay", 0, 0.5, ExtraDelayTactical, 3, function(v) ExtraDelayTactical = v if ExtraDelayChanger then applyAllExtraDelays() end end)
addDecimalSlider("Others Delay", 0, 0.5, ExtraDelayOthers, 3, function(v) ExtraDelayOthers = v if ExtraDelayChanger then applyAllExtraDelays() end end)

-- ESP section
_G.KimqBuildSection = "esp"
local ESPHeader = Instance.new("TextLabel", Scroll)
ESPHeader.Size = UDim2.new(1,-6,0,34)
ESPHeader.BackgroundTransparency = 1
ESPHeader.Text = "♥  ESP"
ESPHeader.TextColor3 = Color3.fromRGB(225,73,140)
ESPHeader.Font = Enum.Font.GothamBold
ESPHeader.TextSize = 18
ESPHeader.TextXAlignment = Enum.TextXAlignment.Left
addToggle("ESP", ExtraESPEnabled, function(v) ExtraESPEnabled = v end)
addToggle("Box", ExtraESPBoxes, function(v) ExtraESPBoxes = v end)
addToggle("Name", ExtraESPNames, function(v) ExtraESPNames = v end)
addToggle("Distance", ExtraESPDistance, function(v) ExtraESPDistance = v end)
addToggle("Health", ExtraESPHealth, function(v) ExtraESPHealth = v end)
addToggle("Snapline", ExtraESPTracer, function(v) ExtraESPTracer = v end)
addToggle("Skeleton", ExtraESPSkeleton, function(v) ExtraESPSkeleton = v end)

-- Full RGB ESP picker: 0-255 on each channel can create any RGB color.
local ESP_R = math.floor(ExtraESPColor.R*255 + .5)
local ESP_G = math.floor(ExtraESPColor.G*255 + .5)
local ESP_B = math.floor(ExtraESPColor.B*255 + .5)
local ESPColorPreview
local function applyESPColorRGB()
    ExtraESPColor = Color3.fromRGB(
        math.clamp(math.floor(ESP_R+.5),0,255),
        math.clamp(math.floor(ESP_G+.5),0,255),
        math.clamp(math.floor(ESP_B+.5),0,255)
    )
    _G.KimqESPColor = ExtraESPColor
    if type(_G.KimqSetESPColor)=="function" then pcall(_G.KimqSetESPColor,ExtraESPColor) end
    if ESPColorPreview and ESPColorPreview.Parent then ESPColorPreview.BackgroundColor3=ExtraESPColor end
end

local espColorCard=createCard(54)
espColorCard.Name="KimqESPColorPreviewCard"
local espColorLabel=Instance.new("TextLabel",espColorCard)
espColorLabel.Size=UDim2.new(1,-78,1,0); espColorLabel.Position=UDim2.fromOffset(10,0)
espColorLabel.BackgroundTransparency=1; espColorLabel.Text="ESP Color  •  RGB"
espColorLabel.TextColor3=Color3.fromRGB(82,116,94); espColorLabel.Font=Enum.Font.GothamSemibold
espColorLabel.TextSize=11; espColorLabel.TextXAlignment=Enum.TextXAlignment.Left
ESPColorPreview=Instance.new("Frame",espColorCard)
ESPColorPreview.Size=UDim2.fromOffset(46,30); ESPColorPreview.Position=UDim2.new(1,-58,.5,-15)
ESPColorPreview.BorderSizePixel=0; ESPColorPreview.BackgroundColor3=ExtraESPColor
Instance.new("UICorner",ESPColorPreview).CornerRadius=UDim.new(0,8)
local espStroke=Instance.new("UIStroke",ESPColorPreview); espStroke.Color=Color3.new(1,1,1); espStroke.Transparency=.15; espStroke.Thickness=1
addSlider("ESP Red",0,255,ESP_R,function(v) ESP_R=v; applyESPColorRGB() end)
addSlider("ESP Green",0,255,ESP_G,function(v) ESP_G=v; applyESPColorRGB() end)
addSlider("ESP Blue",0,255,ESP_B,function(v) ESP_B=v; applyESPColorRGB() end)
applyESPColorRGB()

-- document (3) starts Anti Aim View enabled
setExtraAntiAimView(ExtraAntiAimView)

_G.KimqBuildSection = "avatar"
local AvatarHeader = Instance.new("TextLabel", Scroll)
AvatarHeader.Size = UDim2.new(1,-6,0,34)
AvatarHeader.BackgroundTransparency = 1
AvatarHeader.Text = "♥  Avatar"
AvatarHeader.TextColor3 = Color3.fromRGB(225, 73, 140)
AvatarHeader.Font = Enum.Font.GothamBold
AvatarHeader.TextSize = 18
AvatarHeader.TextXAlignment = Enum.TextXAlignment.Left

local AvatarIntro = createCard(58)
local AvatarIntroTitle = Instance.new("TextLabel", AvatarIntro)
AvatarIntroTitle.Size = UDim2.new(1,-20,0,22)
AvatarIntroTitle.Position = UDim2.fromOffset(10,7)
AvatarIntroTitle.BackgroundTransparency = 1
AvatarIntroTitle.Text = "Copy a Roblox avatar"
AvatarIntroTitle.TextColor3 = Color3.fromRGB(230,40,135)
AvatarIntroTitle.Font = Enum.Font.GothamBold
AvatarIntroTitle.TextSize = 14
AvatarIntroTitle.TextXAlignment = Enum.TextXAlignment.Left
local AvatarIntroSub = Instance.new("TextLabel", AvatarIntro)
AvatarIntroSub.Size = UDim2.new(1,-20,0,18)
AvatarIntroSub.Position = UDim2.fromOffset(10,31)
AvatarIntroSub.BackgroundTransparency = 1
AvatarIntroSub.Text = "Paste a username or user ID. Changes are visual/local."
AvatarIntroSub.TextColor3 = Color3.fromRGB(197,112,145)
AvatarIntroSub.Font = Enum.Font.Gotham
AvatarIntroSub.TextSize = 11
AvatarIntroSub.TextXAlignment = Enum.TextXAlignment.Left

local AvatarTargetCard = createCard(70)
local AvatarTargetLabel = Instance.new("TextLabel", AvatarTargetCard)
AvatarTargetLabel.Size = UDim2.new(1,-20,0,20)
AvatarTargetLabel.Position = UDim2.fromOffset(10,6)
AvatarTargetLabel.BackgroundTransparency = 1
AvatarTargetLabel.Text = "Username / User ID"
AvatarTargetLabel.TextColor3 = Color3.fromRGB(230,40,135)
AvatarTargetLabel.Font = Enum.Font.GothamBold
AvatarTargetLabel.TextSize = 13
AvatarTargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local AvatarTargetBox = Instance.new("TextBox", AvatarTargetCard)
AvatarTargetBox.Size = UDim2.new(1,-20,0,31)
AvatarTargetBox.Position = UDim2.fromOffset(10,32)
AvatarTargetBox.BackgroundColor3 = Color3.fromRGB(255,225,238)
AvatarTargetBox.BorderSizePixel = 0
AvatarTargetBox.Text = ""
AvatarTargetBox.PlaceholderText = "@username or user id"
AvatarTargetBox.PlaceholderColor3 = Color3.fromRGB(197,112,145)
AvatarTargetBox.TextColor3 = Color3.fromRGB(230,40,135)
AvatarTargetBox.Font = Enum.Font.Gotham
AvatarTargetBox.TextSize = 13
AvatarTargetBox.TextXAlignment = Enum.TextXAlignment.Left
AvatarTargetBox.ClearTextOnFocus = false
Instance.new("UICorner", AvatarTargetBox).CornerRadius = UDim.new(0,8)
local AvatarPad = Instance.new("UIPadding", AvatarTargetBox)
AvatarPad.PaddingLeft = UDim.new(0,9)
AvatarPad.PaddingRight = UDim.new(0,9)

if type(_G.KimqRegisterConfigControl) == "function" then
    _G.KimqRegisterConfigControl("Avatar Target", "text",
        function() return tostring(AvatarTargetBox.Text or "") end,
        function(v)
            AvatarTargetBox.Text = tostring(v or "")
            AvatarTarget = AvatarTargetBox.Text
        end
    )
end

-- This replaces the old confusing "Enable Avatar" gate. Apply always works;
-- this toggle only controls whether the chosen look comes back after respawn.
addToggle("Keep Avatar After Respawn", false, function(v) AvatarEnabled = v end)

local function setAvatarKeepEnabled(v)
    v = not not v
    -- v2.77: the local persistence flag is authoritative.  Update it FIRST so
    -- respawn logic cannot depend on whether a config/UI setter succeeds.
    AvatarEnabled = v
    local reg = _G.KimqConfigControls and _G.KimqConfigControls["Keep Avatar After Respawn"]
    if reg and type(reg.set)=="function" then
        pcall(reg.set, v)
    end
end

addToggle("Visual Headless", false, function(v) AvatarHeadless = v end)

local AvatarActions = createCard(50)
local ApplyAvatarBtn = Instance.new("TextButton", AvatarActions)
ApplyAvatarBtn.Size = UDim2.new(.5,-14,0,34)
ApplyAvatarBtn.Position = UDim2.new(0,10,.5,-17)
ApplyAvatarBtn.BackgroundColor3 = Color3.fromRGB(255,20,147)
ApplyAvatarBtn.BorderSizePixel = 0
ApplyAvatarBtn.Text = "♥  Apply User Avatar"
ApplyAvatarBtn.TextColor3 = Color3.fromRGB(255,240,247)
ApplyAvatarBtn.Font = Enum.Font.GothamBold
ApplyAvatarBtn.TextSize = 12
ApplyAvatarBtn.AutoButtonColor = false
Instance.new("UICorner", ApplyAvatarBtn).CornerRadius = UDim.new(0,9)

local ResetAvatarBtn = Instance.new("TextButton", AvatarActions)
ResetAvatarBtn.Size = UDim2.new(.5,-14,0,34)
ResetAvatarBtn.Position = UDim2.new(.5,4,.5,-17)
ResetAvatarBtn.BackgroundColor3 = Color3.fromRGB(255,205,228)
ResetAvatarBtn.BorderSizePixel = 0
ResetAvatarBtn.Text = "Reset to My Avatar"
ResetAvatarBtn.TextColor3 = Color3.fromRGB(230,40,135)
ResetAvatarBtn.Font = Enum.Font.GothamBold
ResetAvatarBtn.TextSize = 12
ResetAvatarBtn.AutoButtonColor = false
Instance.new("UICorner", ResetAvatarBtn).CornerRadius = UDim.new(0,9)

local AvatarStatusCard = createCard(42)
local AvatarStatus = Instance.new("TextLabel", AvatarStatusCard)
AvatarStatus.Size = UDim2.new(1,-20,1,0)
AvatarStatus.Position = UDim2.fromOffset(10,0)
AvatarStatus.BackgroundTransparency = 1
AvatarStatus.Text = "Ready ♡"
AvatarStatus.TextColor3 = Color3.fromRGB(197,112,145)
AvatarStatus.Font = Enum.Font.Gotham
AvatarStatus.TextSize = 12
AvatarStatus.TextXAlignment = Enum.TextXAlignment.Left

local function setAvatarStatus(text, positive)
    AvatarStatus.Text = tostring(text or "")
    local p=_G.KimqThemeLivePalette
    AvatarStatus.TextColor3 = positive and ((p and p.hot) or Color3.fromRGB(230,40,135))
        or ((p and p.sub) or Color3.fromRGB(197,112,145))
end

local function resolveAvatarUserId(value)
    value = tostring(value or ""):gsub("%s+",""):gsub("^@","")
    if value == "" then return nil end
    local n = tonumber(value)
    if n then return math.floor(n) end
    local ok,id = pcall(function() return Players:GetUserIdFromNameAsync(value) end)
    return ok and id or nil
end

local function applyHeadless(char)
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    local visualHead = char:FindFirstChild("KimqAvatarVisualHead")
    if visualHead and visualHead:IsA("BasePart") then
        -- Keep the gameplay head intact/invisible and show the copied user's exact
        -- visual head on top. This preserves dynamic-head faces without replacing
        -- the real Head that the game may depend on.
        head.Transparency = 1
        for _,d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
        end
        local original = visualHead:GetAttribute("KimqOriginalTransparency")
        visualHead.Transparency = AvatarHeadless and 1 or (type(original)=="number" and original or 0)
        for _,d in ipairs(visualHead:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                local base=d:GetAttribute("KimqOriginalTransparency")
                d.Transparency = AvatarHeadless and 1 or (type(base)=="number" and base or 0)
            end
        end
    else
        head.Transparency = AvatarHeadless and 1 or 0
        for _,d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = AvatarHeadless and 1 or 0
            end
        end
    end
end

local function reapplySavedLocalAccessories(char)
    local controller = _G.KimqAccessoryController
    local ids = _G.KimqLocalVisualAccessoriesV15
    if not controller or type(controller.Equip)~="function" or type(ids)~="table" then return end
    task.defer(function()
        task.wait(.15)
        for _,assetId in ipairs(ids) do
            pcall(controller.Equip, tonumber(assetId), char, true)
            task.wait(.03)
        end
    end)
end

local function copyAnimationsFromDummy(char, dummy)
    local myAnimate = char and char:FindFirstChild("Animate")
    local dummyAnimate = dummy and dummy:FindFirstChild("Animate")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not myAnimate or not dummyAnimate or not humanoid then return end

    -- v2.80: do not stop currently-playing tracks here. Repeatedly killing every
    -- animation track was the source of random stiff/idle-looking moments while
    -- the avatar persistence guard repaired visuals. Updating the Animate IDs is
    -- enough; Roblox naturally uses them on the next animation state transition.
    for _,folder in ipairs(dummyAnimate:GetChildren()) do
        local mine=myAnimate:FindFirstChild(folder.Name)
        if mine then
            for _,anim in ipairs(folder:GetChildren()) do
                if anim:IsA("Animation") then
                    local existing=mine:FindFirstChild(anim.Name)
                    if existing and existing:IsA("Animation") then
                        pcall(function() existing.AnimationId=anim.AnimationId end)
                    else
                        pcall(function() anim:Clone().Parent=mine end)
                    end
                end
            end
        end
    end
end

-- v2.85: copying someone else's visual avatar must NOT replace the local/game
-- locomotion package. Some avatar animation packages make movement look like the
-- character is drifting/turning in circles. Preserve the currently active movement
-- animation IDs before applying a copied HumanoidDescription.
local AVATAR_MOVEMENT_ANIMATION_PROPERTIES={
    "ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation",
    "RunAnimation","SwimAnimation","WalkAnimation","MoodAnimation"
}

local function preserveCurrentMovementAnimations(humanoid,desc)
    if not humanoid or not desc then return end
    local current=nil
    pcall(function() current=humanoid:GetAppliedDescription() end)
    if not current then return end
    for _,prop in ipairs(AVATAR_MOVEMENT_ANIMATION_PROPERTIES) do
        pcall(function() desc[prop]=current[prop] end)
    end
    pcall(function() current:Destroy() end)
end


-- v2.67: freeze the exact applied avatar inside saved configs instead of
-- re-querying the source user's CURRENT Roblox avatar later.
local activeAvatarSnapshot=nil
-- v2.78: remember HOW the current copied avatar was applied.  Manual Apply User
-- Avatar uses applyAvatarUser(), and that is the path confirmed to work in this game.
-- Respawns now use that same path instead of relying only on snapshot restoration.
local activeAvatarUserId=nil
local avatarPersistenceMode="snapshot" -- "user" for manual char-into, "snapshot" for frozen config snapshots
-- v2.79: keep a complete local clone of the successfully-applied avatar model.
-- Respawn restoration uses this cached model instead of re-fetching Roblox data.
local avatarPersistTemplate=nil

-- v2.68: isolated visibility editor for accessories that belong to the copied
-- avatar. This never deletes the accessory; it only hides/shows its local
-- visual descendants, so the copied avatar can be customized safely.
local avatarHiddenAccessoryKeys={}
local avatarAccessoryVisualBackup=setmetatable({}, {__mode="k"})
local avatarAccessoryRows={}
local avatarAccessoryRefreshToken=0

local function avatarAccessoryKey(acc)
    if not acc or not acc:IsA("Accessory") then return nil end
    local bits={tostring(acc.Name or "Accessory")}
    local okType,accessoryType=pcall(function() return acc.AccessoryType end)
    if okType and accessoryType then table.insert(bits,tostring(accessoryType.Name or accessoryType)) end
    local handle=acc:FindFirstChild("Handle")
    if handle then
        if handle:IsA("MeshPart") then
            table.insert(bits,tostring(handle.MeshId or ""))
            table.insert(bits,tostring(handle.TextureID or ""))
        else
            local mesh=handle:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                table.insert(bits,tostring(mesh.MeshId or ""))
                table.insert(bits,tostring(mesh.TextureId or ""))
            end
        end
    end
    return table.concat(bits,"|")
end

local function copiedAvatarAccessory(acc)
    if not acc or not acc:IsA("Accessory") then return false end
    if acc:GetAttribute("KimqLocalV15") then return false end
    if acc:GetAttribute("KimqWornEquippable") then return false end
    if acc.Name=="KimqWornAngelWings" or tostring(acc.Name):match("^KimqLocal_") then return false end
    return true
end

local function rememberAccessoryVisual(obj,property,value)
    local rec=avatarAccessoryVisualBackup[obj]
    if not rec then rec={}; avatarAccessoryVisualBackup[obj]=rec end
    if rec[property]==nil then rec[property]=value end
end

local function setOneAccessoryHidden(acc,hidden)
    if not copiedAvatarAccessory(acc) then return end
    for _,obj in ipairs(acc:GetDescendants()) do
        if obj:IsA("BasePart") then
            if hidden then
                rememberAccessoryVisual(obj,"Transparency",obj.Transparency)
                local okLTM,ltm=pcall(function() return obj.LocalTransparencyModifier end)
                if okLTM then rememberAccessoryVisual(obj,"LocalTransparencyModifier",ltm) end
                obj.Transparency=1
                pcall(function() obj.LocalTransparencyModifier=1 end)
            else
                local rec=avatarAccessoryVisualBackup[obj]
                if rec then
                    if rec.Transparency~=nil then pcall(function() obj.Transparency=rec.Transparency end) end
                    if rec.LocalTransparencyModifier~=nil then pcall(function() obj.LocalTransparencyModifier=rec.LocalTransparencyModifier end) end
                    avatarAccessoryVisualBackup[obj]=nil
                end
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if hidden then
                rememberAccessoryVisual(obj,"Transparency",obj.Transparency)
                obj.Transparency=1
            else
                local rec=avatarAccessoryVisualBackup[obj]
                if rec and rec.Transparency~=nil then pcall(function() obj.Transparency=rec.Transparency end) end
                avatarAccessoryVisualBackup[obj]=nil
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")
            or obj:IsA("Highlight") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if hidden then
                local okEnabled,enabled=pcall(function() return obj.Enabled end)
                if okEnabled then
                    rememberAccessoryVisual(obj,"Enabled",enabled)
                    pcall(function() obj.Enabled=false end)
                end
            else
                local rec=avatarAccessoryVisualBackup[obj]
                if rec and rec.Enabled~=nil then pcall(function() obj.Enabled=rec.Enabled end) end
                avatarAccessoryVisualBackup[obj]=nil
            end
        end
    end
end

local function hiddenAccessoryArray()
    local out={}
    for key,hidden in pairs(avatarHiddenAccessoryKeys) do
        if hidden then table.insert(out,key) end
    end
    table.sort(out)
    return out
end

local function syncHiddenAccessoriesIntoSnapshot()
    if type(activeAvatarSnapshot)=="table" then
        activeAvatarSnapshot.HiddenAccessories=hiddenAccessoryArray()
    end
end

local function loadHiddenAccessoriesFromSnapshot(state)
    table.clear(avatarHiddenAccessoryKeys)
    if type(state)=="table" and type(state.HiddenAccessories)=="table" then
        for _,key in ipairs(state.HiddenAccessories) do
            if type(key)=="string" and key~="" then avatarHiddenAccessoryKeys[key]=true end
        end
    end
end

local function collectCopiedAvatarAccessories(char)
    local groups={}
    char=char or lp.Character
    if not char then return groups end
    for _,acc in ipairs(char:GetChildren()) do
        if copiedAvatarAccessory(acc) then
            local key=avatarAccessoryKey(acc)
            if key then
                local group=groups[key]
                if not group then
                    group={key=key,name=tostring(acc.Name or "Accessory"),items={}}
                    groups[key]=group
                end
                table.insert(group.items,acc)
            end
        end
    end
    return groups
end

local function applyHiddenAccessoryState(char)
    local groups=collectCopiedAvatarAccessories(char)
    for key,group in pairs(groups) do
        local hidden=avatarHiddenAccessoryKeys[key]==true
        for _,acc in ipairs(group.items) do
            setOneAccessoryHidden(acc,hidden)
        end
    end
end

-- Cute editor card. It lives only on Avatar and uses the normal Kimq theme roles.
local AvatarAccessoryEditor=createCard(244)
AvatarAccessoryEditor.Name="KimqCopiedAvatarAccessoryEditor"

local AvatarAccessoryEditorTitle=Instance.new("TextLabel",AvatarAccessoryEditor)
AvatarAccessoryEditorTitle.BackgroundTransparency=1
AvatarAccessoryEditorTitle.Position=UDim2.fromOffset(12,8)
AvatarAccessoryEditorTitle.Size=UDim2.new(1,-104,0,22)
AvatarAccessoryEditorTitle.Text="♥  Avatar Accessories"
AvatarAccessoryEditorTitle.Font=Enum.Font.GothamBold
AvatarAccessoryEditorTitle.TextSize=13
AvatarAccessoryEditorTitle.TextXAlignment=Enum.TextXAlignment.Left
AvatarAccessoryEditorTitle.TextColor3=Color3.fromRGB(230,40,135)
AvatarAccessoryEditorTitle:SetAttribute("KimqV26Role","hotText")

local AvatarAccessoryEditorSub=Instance.new("TextLabel",AvatarAccessoryEditor)
AvatarAccessoryEditorSub.BackgroundTransparency=1
AvatarAccessoryEditorSub.Position=UDim2.fromOffset(12,30)
AvatarAccessoryEditorSub.Size=UDim2.new(1,-24,0,28)
AvatarAccessoryEditorSub.Text="Hide or show pieces from the copied avatar. Hidden pieces stay saved with configs."
AvatarAccessoryEditorSub.TextWrapped=true
AvatarAccessoryEditorSub.Font=Enum.Font.Gotham
AvatarAccessoryEditorSub.TextSize=10
AvatarAccessoryEditorSub.TextXAlignment=Enum.TextXAlignment.Left
AvatarAccessoryEditorSub.TextColor3=Color3.fromRGB(197,112,145)
AvatarAccessoryEditorSub:SetAttribute("KimqV26Role","subText")

local AvatarAccessoryRefresh=Instance.new("TextButton",AvatarAccessoryEditor)
AvatarAccessoryRefresh.Position=UDim2.new(1,-84,0,7)
AvatarAccessoryRefresh.Size=UDim2.fromOffset(72,26)
AvatarAccessoryRefresh.BackgroundColor3=Color3.fromRGB(255,225,238)
AvatarAccessoryRefresh.BorderSizePixel=0
AvatarAccessoryRefresh.Text="refresh"
AvatarAccessoryRefresh.Font=Enum.Font.GothamSemibold
AvatarAccessoryRefresh.TextSize=10
AvatarAccessoryRefresh.TextColor3=Color3.fromRGB(225,55,135)
AvatarAccessoryRefresh.AutoButtonColor=false
AvatarAccessoryRefresh:SetAttribute("KimqV26Role","lightBg")
Instance.new("UICorner",AvatarAccessoryRefresh).CornerRadius=UDim.new(0,8)

local AvatarAccessoryList=Instance.new("ScrollingFrame",AvatarAccessoryEditor)
AvatarAccessoryList.Position=UDim2.fromOffset(10,66)
AvatarAccessoryList.Size=UDim2.new(1,-20,1,-76)
AvatarAccessoryList.BackgroundColor3=Color3.fromRGB(255,245,250)
AvatarAccessoryList.BorderSizePixel=0
AvatarAccessoryList.ScrollBarThickness=3
AvatarAccessoryList.ScrollBarImageColor3=Color3.fromRGB(243,161,211)
AvatarAccessoryList.CanvasSize=UDim2.new()
AvatarAccessoryList:SetAttribute("KimqV26Role","lightBg")
Instance.new("UICorner",AvatarAccessoryList).CornerRadius=UDim.new(0,10)
local AvatarAccessoryPad=Instance.new("UIPadding",AvatarAccessoryList)
AvatarAccessoryPad.PaddingTop=UDim.new(0,6)
AvatarAccessoryPad.PaddingBottom=UDim.new(0,6)
AvatarAccessoryPad.PaddingLeft=UDim.new(0,6)
AvatarAccessoryPad.PaddingRight=UDim.new(0,6)
local AvatarAccessoryLayout=Instance.new("UIListLayout",AvatarAccessoryList)
AvatarAccessoryLayout.SortOrder=Enum.SortOrder.LayoutOrder
AvatarAccessoryLayout.Padding=UDim.new(0,5)
AvatarAccessoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    AvatarAccessoryList.CanvasSize=UDim2.new(0,0,0,AvatarAccessoryLayout.AbsoluteContentSize.Y+12)
end)

local function paintAvatarAccessoryRow(row,button,hidden)
    local p=_G.KimqThemeLivePalette
    local soft=(p and (p.soft or p.bg2)) or Color3.fromRGB(255,225,238)
    local panel=(p and p.panel) or Color3.fromRGB(255,255,255)
    local hot=(p and p.hot) or Color3.fromRGB(243,161,211)
    local text=(p and p.text) or Color3.fromRGB(82,116,94)
    local white=(p and p.white) or Color3.fromRGB(255,255,255)
    if row then row.BackgroundColor3=panel end
    if button then
        button.BackgroundColor3=hidden and hot or soft
        button.TextColor3=hidden and white or text
        button.Text=hidden and "HIDDEN" or "VISIBLE"
    end
end

local function refreshAvatarAccessoryTheme()
    for _,rec in pairs(avatarAccessoryRows) do
        if rec.row and rec.row.Parent then
            paintAvatarAccessoryRow(rec.row,rec.button,avatarHiddenAccessoryKeys[rec.key]==true)
        end
    end
    local p=_G.KimqThemeLivePalette
    if p and AvatarAccessoryList then
        AvatarAccessoryList.BackgroundColor3=p.soft or p.bg2 or AvatarAccessoryList.BackgroundColor3
        AvatarAccessoryList.ScrollBarImageColor3=p.hot or AvatarAccessoryList.ScrollBarImageColor3
        AvatarAccessoryRefresh.BackgroundColor3=p.soft or p.bg2 or AvatarAccessoryRefresh.BackgroundColor3
        AvatarAccessoryRefresh.TextColor3=p.hot or AvatarAccessoryRefresh.TextColor3
    end
end
_G.KimqRefreshAvatarAccessoryTheme=refreshAvatarAccessoryTheme

local function clearAvatarAccessoryRows()
    table.clear(avatarAccessoryRows)
    for _,child in ipairs(AvatarAccessoryList:GetChildren()) do
        if child~=AvatarAccessoryLayout and child~=AvatarAccessoryPad then child:Destroy() end
    end
end

local function refreshAvatarAccessoryList()
    avatarAccessoryRefreshToken+=1
    local myToken=avatarAccessoryRefreshToken
    clearAvatarAccessoryRows()
    local groups=collectCopiedAvatarAccessories(lp.Character)
    local ordered={}
    for _,group in pairs(groups) do table.insert(ordered,group) end
    table.sort(ordered,function(a,b) return a.name:lower()<b.name:lower() end)

    if #ordered==0 then
        local empty=Instance.new("TextLabel",AvatarAccessoryList)
        empty.Name="KimqAvatarAccessoryEmpty"
        empty.Size=UDim2.new(1,-8,0,42)
        empty.BackgroundTransparency=1
        empty.Text="apply a user avatar to edit its accessories ♡"
        empty.TextWrapped=true
        empty.Font=Enum.Font.Gotham
        empty.TextSize=10
        empty.TextColor3=(_G.KimqThemeLivePalette and _G.KimqThemeLivePalette.sub) or Color3.fromRGB(197,112,145)
        empty:SetAttribute("KimqV26Role","subText")
        return
    end

    for index,group in ipairs(ordered) do
        if myToken~=avatarAccessoryRefreshToken then return end
        local row=Instance.new("Frame",AvatarAccessoryList)
        row.Name="Accessory_"..tostring(index)
        row.Size=UDim2.new(1,-4,0,34)
        row.BorderSizePixel=0
        row.LayoutOrder=index
        row:SetAttribute("KimqV26Role","panel")
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

        local nameLabel=Instance.new("TextLabel",row)
        nameLabel.BackgroundTransparency=1
        nameLabel.Position=UDim2.fromOffset(9,0)
        nameLabel.Size=UDim2.new(1,-100,1,0)
        nameLabel.Text=group.name
        nameLabel.TextTruncate=Enum.TextTruncate.AtEnd
        nameLabel.Font=Enum.Font.GothamSemibold
        nameLabel.TextSize=10
        nameLabel.TextXAlignment=Enum.TextXAlignment.Left
        nameLabel.TextColor3=(_G.KimqThemeLivePalette and _G.KimqThemeLivePalette.text) or Color3.fromRGB(82,116,94)
        nameLabel:SetAttribute("KimqV26Role","textText")

        local visibility=Instance.new("TextButton",row)
        visibility.Size=UDim2.fromOffset(78,24)
        visibility.Position=UDim2.new(1,-84,.5,-12)
        visibility.BorderSizePixel=0
        visibility.Font=Enum.Font.GothamBold
        visibility.TextSize=9
        visibility.AutoButtonColor=false
        Instance.new("UICorner",visibility).CornerRadius=UDim.new(0,7)

        avatarAccessoryRows[group.key]={row=row,button=visibility,key=group.key}
        paintAvatarAccessoryRow(row,visibility,avatarHiddenAccessoryKeys[group.key]==true)

        visibility.MouseButton1Click:Connect(function()
            local hidden=not (avatarHiddenAccessoryKeys[group.key]==true)
            avatarHiddenAccessoryKeys[group.key]=hidden or nil
            for _,acc in ipairs(group.items) do
                if acc and acc.Parent then setOneAccessoryHidden(acc,hidden) end
            end
            syncHiddenAccessoriesIntoSnapshot()
            paintAvatarAccessoryRow(row,visibility,hidden)
            setAvatarStatus((hidden and "Hidden " or "Showing ")..group.name.." ♡",true)
        end)
    end
    refreshAvatarAccessoryTheme()
end
_G.KimqRefreshAvatarAccessoryList=refreshAvatarAccessoryList

AvatarAccessoryRefresh.MouseButton1Click:Connect(function()
    applyHiddenAccessoryState(lp.Character)
    refreshAvatarAccessoryList()
end)

local AVATAR_DESCRIPTION_PROPERTIES={
    "AccessoryBlob","BackAccessory","FaceAccessory","FrontAccessory","HairAccessory","HatAccessory","NeckAccessory","ShouldersAccessory","WaistAccessory",
    "Shirt","Pants","GraphicTShirt","Face","Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg",
    "BodyTypeScale","DepthScale","HeadScale","HeightScale","ProportionScale","WidthScale",
    "HeadColor","TorsoColor","LeftArmColor","RightArmColor","LeftLegColor","RightLegColor",
    "ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation","WalkAnimation","MoodAnimation"
}

local function avatarColorToState(c)
    return {__type="Color3",r=c.R,g=c.G,b=c.B}
end

local function avatarStateToColor(t)
    if type(t)~="table" or t.__type~="Color3" then return nil end
    return Color3.new(
        math.clamp(tonumber(t.r) or 0,0,1),
        math.clamp(tonumber(t.g) or 0,0,1),
        math.clamp(tonumber(t.b) or 0,0,1)
    )
end

local function snapshotHumanoidDescription(desc,sourceUserId)
    if not desc then return nil end
    local state={Version=1,SourceUserId=tonumber(sourceUserId),Properties={}}
    for _,prop in ipairs(AVATAR_DESCRIPTION_PROPERTIES) do
        local ok,v=pcall(function() return desc[prop] end)
        if ok then
            if typeof(v)=="Color3" then
                state.Properties[prop]=avatarColorToState(v)
            elseif type(v)=="number" or type(v)=="string" or type(v)=="boolean" then
                state.Properties[prop]=v
            end
        end
    end

    pcall(function()
        local accessories=desc:GetAccessories(true)
        local out={}
        for _,entry in ipairs(accessories or {}) do
            local rec={}
            for k,v in pairs(entry) do
                if typeof(v)=="EnumItem" then
                    rec[k]={__type="EnumItem",enum=tostring(v.EnumType),name=v.Name}
                elseif type(v)=="number" or type(v)=="string" or type(v)=="boolean" then
                    rec[k]=v
                end
            end
            table.insert(out,rec)
        end
        state.Accessories=out
    end)
    pcall(function() state.Emotes=desc:GetEmotes() end)
    pcall(function() state.EquippedEmotes=desc:GetEquippedEmotes() end)
    return state
end

local function enumFromAvatarState(v)
    if type(v)~="table" or v.__type~="EnumItem" then return nil end
    local enumName=tostring(v.enum or ""):match("Enum%.(.+)")
    local enumType=enumName and Enum[enumName] or nil
    return enumType and enumType[tostring(v.name or "")] or nil
end

local function descriptionFromAvatarSnapshot(state)
    if type(state)~="table" then return nil end
    local desc=Instance.new("HumanoidDescription")
    for prop,v in pairs(type(state.Properties)=="table" and state.Properties or {}) do
        pcall(function()
            local c=avatarStateToColor(v)
            if c then desc[prop]=c else desc[prop]=v end
        end)
    end
    if type(state.Accessories)=="table" then
        pcall(function()
            local accessories={}
            for _,rec in ipairs(state.Accessories) do
                if type(rec)=="table" then
                    local entry={}
                    for k,v in pairs(rec) do
                        local enumItem=enumFromAvatarState(v)
                        entry[k]=enumItem or v
                    end
                    table.insert(accessories,entry)
                end
            end
            desc:SetAccessories(accessories,true)
        end)
    end
    if type(state.Emotes)=="table" then pcall(function() desc:SetEmotes(state.Emotes) end) end
    if type(state.EquippedEmotes)=="table" then pcall(function() desc:SetEquippedEmotes(state.EquippedEmotes) end) end
    return desc
end


local AvatarVisual = {}

function AvatarVisual.applyDescription(humanoid, desc)
    if not humanoid or not desc then return false end
    local ok=pcall(function()
        humanoid:ApplyDescription(desc)
    end)
    if not ok then
        ok=pcall(function()
            if humanoid.ApplyDescriptionReset then humanoid:ApplyDescriptionReset(desc) end
        end)
    end
    return ok
end

function AvatarVisual.createDummyFromDescription(desc, rigType)
    if not desc then return nil end
    local ok,dummy=pcall(function()
        return Players:CreateHumanoidModelFromDescription(desc, rigType or Enum.HumanoidRigType.R15)
    end)
    return ok and dummy or nil
end

function AvatarVisual.createDummyFromUser(userId, rigType)
    local desc=nil
    pcall(function() desc=Players:GetHumanoidDescriptionFromUserId(userId) end)
    local dummy=desc and AvatarVisual.createDummyFromDescription(desc,rigType) or nil
    if not dummy then
        local ok,fallback=pcall(function() return Players:CreateHumanoidModelFromUserId(userId) end)
        if ok then dummy=fallback end
    end
    if not desc and dummy then
        local h=dummy:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() desc=h:GetAppliedDescription() end) end
    end
    return dummy,desc
end

function AvatarVisual.copyBodyColors(char, dummy)
    if not char or not dummy then return end
    local src=dummy:FindFirstChildOfClass("BodyColors")
    if not src then return end
    local dst=char:FindFirstChildOfClass("BodyColors")
    if dst then
        pcall(function()
            dst.HeadColor3=src.HeadColor3; dst.TorsoColor3=src.TorsoColor3
            dst.LeftArmColor3=src.LeftArmColor3; dst.RightArmColor3=src.RightArmColor3
            dst.LeftLegColor3=src.LeftLegColor3; dst.RightLegColor3=src.RightLegColor3
        end)
    else
        pcall(function() src:Clone().Parent=char end)
    end
end

function AvatarVisual.makeVisualHead(char, dummy)
    if not char or not dummy then return nil end
    local base=char:FindFirstChild("Head")
    local source=dummy:FindFirstChild("Head")
    if not base or not source or not source:IsA("BasePart") then return nil end
    local old=char:FindFirstChild("KimqAvatarVisualHead")
    if old then pcall(function() old:Destroy() end) end

    local visual=source:Clone()
    visual.Name="KimqAvatarVisualHead"

    -- v2.80: some dynamic/custom heads clone with a black tint in this game even
    -- though the copied BodyColors are correct. Force the visual shell to the
    -- copied avatar's actual head skin tone while keeping its face/mesh assets.
    local skinTone=base.Color
    local sourceColors=dummy:FindFirstChildOfClass("BodyColors")
    if sourceColors then pcall(function() skinTone=sourceColors.HeadColor3 end) end
    pcall(function() visual.Color=skinTone end)

    visual:SetAttribute("KimqOriginalTransparency",visual.Transparency)
    for _,d in ipairs(visual:GetDescendants()) do
        if d:IsA("JointInstance") or d:IsA("WeldConstraint") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("Decal") or d:IsA("Texture") then
            d:SetAttribute("KimqOriginalTransparency",d.Transparency)
        elseif d:IsA("SpecialMesh") then
            pcall(function()
                local vc=d.VertexColor
                if vc.X+vc.Y+vc.Z<.18 then d.VertexColor=Vector3.new(1,1,1) end
            end)
        elseif d:IsA("SurfaceAppearance") then
            -- Newer SurfaceAppearance versions expose Color. If unavailable the
            -- pcall simply leaves the source appearance untouched.
            pcall(function()
                local c=d.Color
                if typeof(c)=="Color3" and c.R+c.G+c.B<.18 then d.Color=skinTone end
            end)
        end
    end
    visual.Anchored=false
    visual.CanCollide=false
    visual.CanTouch=false
    pcall(function() visual.CanQuery=false end)
    visual.Massless=true
    visual.CFrame=base.CFrame
    visual.Parent=char
    local weld=Instance.new("WeldConstraint")
    weld.Name="KimqAvatarVisualHeadWeld"
    weld.Part0=base
    weld.Part1=visual
    weld.Parent=visual
    return visual
end

function AvatarVisual.findBodyAttachment(char, name)
    if not char or not name then return nil end
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name~="KimqAvatarVisualHead" then
            local a=part:FindFirstChild(name)
            if a and a:IsA("Attachment") then return a end
        end
    end
    return nil
end

function AvatarVisual.forceAttach(char, acc, sourceAcc)
    if not char or not acc or not acc:IsA("Accessory") then return false end
    local handle=acc:FindFirstChild("Handle")
    local sourceHandle=sourceAcc and sourceAcc:FindFirstChild("Handle") or nil
    if not handle or not handle:IsA("BasePart") then return false end
    handle.CanCollide=false; handle.Massless=true
    pcall(function() handle.CanTouch=false; handle.CanQuery=false end)

    local old=handle:FindFirstChild("AccessoryWeld")
    if old then pcall(function() old:Destroy() end) end

    local handleAttachment=nil
    for _,d in ipairs(handle:GetChildren()) do
        if d:IsA("Attachment") then handleAttachment=d break end
    end
    if handleAttachment then
        local bodyAttachment=AvatarVisual.findBodyAttachment(char,handleAttachment.Name)
        if bodyAttachment and bodyAttachment.Parent and bodyAttachment.Parent:IsA("BasePart") then
            handle.CFrame=bodyAttachment.WorldCFrame*handleAttachment.CFrame:Inverse()
            local w=Instance.new("Weld")
            w.Name="AccessoryWeld"
            w.Part0=handle; w.Part1=bodyAttachment.Parent
            w.C0=handleAttachment.CFrame; w.C1=bodyAttachment.CFrame
            w.Parent=handle
            return true
        end
    end

    local sourceWeld=sourceHandle and sourceHandle:FindFirstChild("AccessoryWeld")
    if sourceWeld and sourceWeld:IsA("Weld") and sourceWeld.Part1 then
        local body=char:FindFirstChild(sourceWeld.Part1.Name)
        if body and body:IsA("BasePart") then
            local w=Instance.new("Weld")
            w.Name="AccessoryWeld"
            w.Part0=handle; w.Part1=body
            w.C0=sourceWeld.C0; w.C1=sourceWeld.C1
            w.Parent=handle
            pcall(function() handle.CFrame=body.CFrame*w.C1*w.C0:Inverse() end)
            return true
        end
    end
    return false
end

function AvatarVisual.findMatchingAccessory(char, sourceAcc)
    local wanted=avatarAccessoryKey(sourceAcc)
    if not wanted then return nil end
    for _,obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") and avatarAccessoryKey(obj)==wanted then return obj end
    end
    return nil
end

function AvatarVisual.copyAccessories(char, humanoid, dummy)
    if not char or not dummy then return 0 end
    local count=0
    for _,sourceAcc in ipairs(dummy:GetChildren()) do
        if sourceAcc:IsA("Accessory") then
            count+=1
            local acc=AvatarVisual.findMatchingAccessory(char,sourceAcc)
            if not acc then
                acc=sourceAcc:Clone()
                acc:SetAttribute("KimqCopiedAvatarAccessory",true)
                acc.Parent=char
            else
                pcall(function() acc:SetAttribute("KimqCopiedAvatarAccessory",true) end)
            end
            local attached=AvatarVisual.forceAttach(char,acc,sourceAcc)
            if not attached and humanoid and humanoid.AddAccessory then
                pcall(function()
                    if acc.Parent then acc.Parent=nil end
                    humanoid:AddAccessory(acc)
                    acc:SetAttribute("KimqCopiedAvatarAccessory",true)
                end)
            end
        end
    end
    return count
end

function AvatarVisual.copyClassicVisuals(char,dummy)
    if not char or not dummy then return end

    -- Clothing can be overwritten by a game's own appearance loader without
    -- removing the character. Replace only classic avatar clothing with the
    -- copied avatar's exact classic pieces and mark them for integrity checks.
    local classes={"Shirt","Pants","ShirtGraphic","BodyColors","CharacterMesh"}
    for _,className in ipairs(classes) do
        for _,existing in ipairs(char:GetChildren()) do
            if existing.ClassName==className and not existing:GetAttribute("KimqLocalV15") then
                pcall(function() existing:Destroy() end)
            end
        end
        for _,source in ipairs(dummy:GetChildren()) do
            if source.ClassName==className then
                pcall(function()
                    local clone=source:Clone()
                    clone:SetAttribute("KimqCopiedAvatarVisual",true)
                    clone.Parent=char
                end)
            end
        end
    end
end

function AvatarVisual.finish(char, humanoid, dummy)
    if not char or not char.Parent then return 0 end
    AvatarVisual.copyClassicVisuals(char,dummy)
    AvatarVisual.copyBodyColors(char,dummy)
    AvatarVisual.makeVisualHead(char,dummy)
    local count=AvatarVisual.copyAccessories(char,humanoid,dummy)
    applyHeadless(char)
    applyHiddenAccessoryState(char)
    reapplySavedLocalAccessories(char)
    if type(_G.KimqRefreshAvatarAccessoryList)=="function" then pcall(_G.KimqRefreshAvatarAccessoryList) end
    return count
end

local function applyAvatarSnapshot(state,char,quiet)
    char=char or lp.Character
    if type(state)~="table" or not char then return false end
    local humanoid=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",5)
    if not humanoid then return false end
    local desc=descriptionFromAvatarSnapshot(state)
    if not desc then return false end

    -- v2.82 config-load fix: applying a saved outfit onto an ALREADY spawned
    -- character used to leave the current Roblox avatar's accessories/head pieces
    -- mixed in until the next reset.  Clear only replaceable avatar visuals first,
    -- exactly like the working respawn restore does. Local try-on pieces/wings stay.
    local oldVisualHead=char:FindFirstChild("KimqAvatarVisualHead")
    if oldVisualHead then pcall(function() oldVisualHead:Destroy() end) end
    for _,obj in ipairs(char:GetChildren()) do
        local remove=false
        if obj:IsA("Accessory") then
            remove=not (obj:GetAttribute("KimqLocalV15")
                or obj:GetAttribute("KimqWornEquippable")
                or obj.Name=="KimqWornAngelWings"
                or tostring(obj.Name):match("^KimqLocal_"))
        elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic")
            or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") then
            remove=true
        end
        if remove then pcall(function() obj:Destroy() end) end
    end

    -- Build the fallback model from the SAVED description itself.  v2.77 does
    -- not depend on ApplyDescription succeeding: some games reject/overwrite it
    -- during fresh spawn, so the manual visual path must still run.
    local dummy=AvatarVisual.createDummyFromDescription(desc,humanoid.RigType)
    if dummy then
        pcall(function()
            if avatarPersistTemplate then avatarPersistTemplate:Destroy() end
            avatarPersistTemplate=dummy:Clone()
            avatarPersistTemplate.Name="KimqAvatarPersistTemplate"
            avatarPersistTemplate.Parent=nil
        end)
    end
    preserveCurrentMovementAnimations(humanoid,desc)
    local descriptionOk=AvatarVisual.applyDescription(humanoid,desc)
    pcall(function() desc:Destroy() end)

    activeAvatarSnapshot=state
    loadHiddenAccessoriesFromSnapshot(state)

    local visualOk=false
    if dummy then
        visualOk=true
        -- Immediate pass plus delayed settle passes.  These restore face/head,
        -- accessories and classic clothing even if the game's avatar loader won.
        pcall(function() AvatarVisual.finish(char,humanoid,dummy) end)
        task.defer(function()
            task.wait(.16)
            if char and char.Parent and char==lp.Character then
                pcall(function() AvatarVisual.finish(char,humanoid,dummy) end)
                task.wait(.42)
                if char and char.Parent and char==lp.Character then
                    pcall(function() AvatarVisual.finish(char,humanoid,dummy) end)
                end
            end
            pcall(function() dummy:Destroy() end)
        end)
    end

    local ok=descriptionOk or visualOk
    if not quiet then
        setAvatarStatus(ok and "Saved avatar restored ♡" or "Saved avatar could not be restored",ok)
    end
    return ok
end

local avatarApplySerial=0

local function applyAvatarUser(userId, char, quiet)
    char=char or lp.Character
    if not char then
        if not quiet then setAvatarStatus("Character is not ready",false) end
        return
    end

    avatarApplySerial+=1
    local serial=avatarApplySerial

    task.spawn(function()
        if not quiet then setAvatarStatus("Loading full avatar...",false) end
        local humanoid=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",5)
        if not humanoid or serial~=avatarApplySerial then
            if not quiet then setAvatarStatus("Humanoid not found",false) end
            return
        end

        local dummy,desc=AvatarVisual.createDummyFromUser(userId,humanoid.RigType)
        if not dummy or serial~=avatarApplySerial then
            if dummy then pcall(function() dummy:Destroy() end) end
            if desc then pcall(function() desc:Destroy() end) end
            if not quiet then setAvatarStatus("Avatar could not be loaded",false) end
            return
        end

        -- Cache the exact fully-built model that made manual Apply work. This clone
        -- survives character death because it is held only by this script, not the Character.
        if AvatarEnabled and avatarPersistenceMode=="user"
            and tonumber(activeAvatarUserId)==tonumber(userId) then
            pcall(function()
                if avatarPersistTemplate then avatarPersistTemplate:Destroy() end
                avatarPersistTemplate=dummy:Clone()
                avatarPersistTemplate.Name="KimqAvatarPersistTemplate"
                avatarPersistTemplate.Parent=nil
            end)
        end

        -- Clear only avatar visuals that this feature replaces. Gameplay folders,
        -- scripts and tools remain untouched.
        local oldVisualHead=char:FindFirstChild("KimqAvatarVisualHead")
        if oldVisualHead then pcall(function() oldVisualHead:Destroy() end) end
        for _,obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
                or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors")
                or obj:IsA("CharacterMesh") then
                pcall(function() obj:Destroy() end)
            end
        end

        if not desc then
            local dh=dummy:FindFirstChildOfClass("Humanoid")
            if dh then pcall(function() desc=dh:GetAppliedDescription() end) end
        end
        if desc then
            activeAvatarSnapshot=snapshotHumanoidDescription(desc,userId)
            if activeAvatarSnapshot then activeAvatarSnapshot.HiddenAccessories={} end
            loadHiddenAccessoriesFromSnapshot(activeAvatarSnapshot)
            preserveCurrentMovementAnimations(humanoid,desc)
            AvatarVisual.applyDescription(humanoid,desc)
        end

        -- Keep the older classic/body mesh fallbacks too.
        for _,item in ipairs(dummy:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic")
                or item:IsA("CharacterMesh") or item:IsA("BodyColors") then
                pcall(function() item:Clone().Parent=char end)
            end
        end
        for _,dPart in ipairs(dummy:GetChildren()) do
            if dPart:IsA("MeshPart") and dPart.Name~="Head" then
                local myPart=char:FindFirstChild(dPart.Name)
                if myPart and myPart:IsA("MeshPart") then
                    pcall(function() myPart.MeshId=dPart.MeshId; myPart.TextureID=dPart.TextureID end)
                end
            end
        end

        local accessoryCount=AvatarVisual.finish(char,humanoid,dummy)
        -- Keep this game's/local player's movement animations unchanged.
        task.defer(function()
            task.wait(.18)
            if char and char.Parent then accessoryCount=AvatarVisual.finish(char,humanoid,dummy) end
            task.wait(.28)
            if char and char.Parent then AvatarVisual.finish(char,humanoid,dummy) end
            pcall(function() dummy:Destroy() end)
        end)
        if desc then pcall(function() desc:Destroy() end) end

        if not quiet then
            setAvatarStatus("Full avatar applied ♡ • "..tostring(accessoryCount).." accessories",true)
        end
    end)
end

local function applyTargetAvatar(quiet)
    AvatarTarget=tostring(AvatarTargetBox.Text or "")
    if AvatarTarget=="" then
        if not quiet then setAvatarStatus("Enter a username or user ID",false) end
        return
    end
    local userId=resolveAvatarUserId(AvatarTarget)
    if not userId then
        if not quiet then setAvatarStatus("User not found",false) end
        return
    end
    -- Once a valid copied avatar is chosen, keep it through death/reset until
    -- Reset to My Avatar (or the keep toggle) explicitly turns persistence off.
    -- v2.78 stores the exact user id so respawn can run the SAME applyAvatarUser
    -- path as this button instead of a different snapshot-only path.
    activeAvatarUserId=tonumber(userId)
    avatarPersistenceMode="user"
    setAvatarKeepEnabled(true)
    applyAvatarUser(userId,lp.Character,quiet)
end

ApplyAvatarBtn.MouseButton1Click:Connect(function()
    applyTargetAvatar(false)
end)

ResetAvatarBtn.MouseButton1Click:Connect(function()
    setAvatarStatus("Restoring your avatar...",false)
    setAvatarKeepEnabled(false)
    table.clear(avatarHiddenAccessoryKeys)
    activeAvatarSnapshot=nil
    activeAvatarUserId=nil
    avatarPersistenceMode="snapshot"
    if avatarPersistTemplate then pcall(function() avatarPersistTemplate:Destroy() end) end
    avatarPersistTemplate=nil
    applyAvatarUser(lp.UserId,lp.Character,false)
end)

local avatarRespawnGuardSerial=0
local avatarVisualRepairBusy=false
local avatarSuppressRepairUntil=0
-- v2.80: repeated ApplyDescription + animation resets were what could make the
-- character randomly stiff. Full humanoid/animation setup runs once per spawn;
-- later repairs repaint only the cached visual pieces.
local avatarRespawnFullApplied=setmetatable({}, {__mode="k"})

local function expectedCopiedAccessoryCount()
    local state=activeAvatarSnapshot
    if type(state)=="table" and type(state.Accessories)=="table" then
        return #state.Accessories
    end
    return 0
end

local function countCopiedAccessories(char)
    local n=0
    if not char then return 0 end
    for _,obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") and obj:GetAttribute("KimqCopiedAvatarAccessory") then n+=1 end
    end
    return n
end

local function avatarVisualLooksIntact(char)
    if not AvatarEnabled or not char or char~=lp.Character then return true end
    if not activeAvatarSnapshot and not avatarPersistTemplate then return false end

    local visualHead=char:FindFirstChild("KimqAvatarVisualHead")
    if not visualHead or not visualHead:IsA("BasePart") then return false end

    local expected=expectedCopiedAccessoryCount()
    if expected>0 and countCopiedAccessories(char)<expected then return false end

    -- If Roblox/the game adds the local player's original accessories again after
    -- our restore, treat that as an overwrite even if our copied pieces still exist.
    for _,obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") then
            local allowed=obj:GetAttribute("KimqCopiedAvatarAccessory")
                or obj:GetAttribute("KimqLocalV15")
                or obj:GetAttribute("KimqWornEquippable")
                or obj.Name=="KimqWornAngelWings"
                or tostring(obj.Name):match("^KimqLocal_")
            if not allowed then return false end
        end
    end

    local props=(activeAvatarSnapshot and activeAvatarSnapshot.Properties) or {}
    if tonumber(props.Shirt or 0)>0 then
        local shirt=char:FindFirstChildOfClass("Shirt")
        if not shirt or not shirt:GetAttribute("KimqCopiedAvatarVisual") then return false end
    end
    if tonumber(props.Pants or 0)>0 then
        local pants=char:FindFirstChildOfClass("Pants")
        if not pants or not pants:GetAttribute("KimqCopiedAvatarVisual") then return false end
    end

    -- Detect a late game pass that silently restores the original BodyColors.
    local expectedColors=avatarPersistTemplate and avatarPersistTemplate:FindFirstChildOfClass("BodyColors")
    local liveColors=char:FindFirstChildOfClass("BodyColors")
    if expectedColors and liveColors then
        local function colorDiff(a,b)
            return math.abs(a.R-b.R)+math.abs(a.G-b.G)+math.abs(a.B-b.B)
        end
        if colorDiff(expectedColors.HeadColor3,liveColors.HeadColor3)>.08
            or colorDiff(expectedColors.TorsoColor3,liveColors.TorsoColor3)>.08 then
            return false
        end
    end
    return true
end

local function restoreKeptAvatar(char)
    if not AvatarEnabled or not char or char~=lp.Character or not char.Parent then return false end
    if avatarVisualRepairBusy then return false end
    avatarVisualRepairBusy=true
    avatarSuppressRepairUntil=os.clock()+.55

    -- Cancel any older async avatar request from the previous character. Respawn
    -- restore below is synchronous and uses the already-cached successful model.
    avatarApplySerial+=1

    local humanoid=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",6)
    local head=char:FindFirstChild("Head") or char:WaitForChild("Head",6)
    if not humanoid or not head or char~=lp.Character then
        avatarVisualRepairBusy=false
        return false
    end
    -- Never fight the game's death cleanup on the old character. The new
    -- CharacterAdded guard will restore the cached avatar on the respawned model.
    if humanoid.Health<=0 or humanoid:GetState()==Enum.HumanoidStateType.Dead then
        avatarVisualRepairBusy=false
        return false
    end

    -- Snapshot configs can rebuild a template locally with no user/network lookup.
    if not avatarPersistTemplate and activeAvatarSnapshot then
        local rebuildDesc=descriptionFromAvatarSnapshot(activeAvatarSnapshot)
        if rebuildDesc then
            local rebuilt=AvatarVisual.createDummyFromDescription(rebuildDesc,humanoid.RigType)
            pcall(function() rebuildDesc:Destroy() end)
            if rebuilt then
                avatarPersistTemplate=rebuilt
                avatarPersistTemplate.Name="KimqAvatarPersistTemplate"
                avatarPersistTemplate.Parent=nil
            end
        end
    end

    if not avatarPersistTemplate then
        -- Last-resort recovery only. Normally manual Apply already cached the model.
        local userId=tonumber(activeAvatarUserId)
        if not userId and tostring(AvatarTargetBox.Text or "")~="" then
            userId=resolveAvatarUserId(AvatarTargetBox.Text)
            activeAvatarUserId=userId and tonumber(userId) or activeAvatarUserId
        end
        avatarVisualRepairBusy=false
        if userId then applyAvatarUser(userId,char,true) end
        return userId~=nil
    end

    -- Remove the current Roblox avatar visuals before putting the cached look back.
    -- Local try-on accessories / wings are kept and the normal local-accessory helper
    -- is still called by AvatarVisual.finish.
    local oldVisualHead=char:FindFirstChild("KimqAvatarVisualHead")
    if oldVisualHead then pcall(function() oldVisualHead:Destroy() end) end
    for _,obj in ipairs(char:GetChildren()) do
        local remove=false
        if obj:IsA("Accessory") then
            remove=not (obj:GetAttribute("KimqLocalV15")
                or obj:GetAttribute("KimqWornEquippable")
                or obj.Name=="KimqWornAngelWings"
                or tostring(obj.Name):match("^KimqLocal_"))
        elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic")
            or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") then
            remove=true
        end
        if remove then pcall(function() obj:Destroy() end) end
    end

    -- Apply body/package/scales only ONCE on this newly-spawned Humanoid. Repeating
    -- ApplyDescription during integrity repairs can interrupt the Animate pipeline.
    local firstFullRestore=avatarRespawnFullApplied[char]~=true
    if firstFullRestore and activeAvatarSnapshot then
        local desc=descriptionFromAvatarSnapshot(activeAvatarSnapshot)
        if desc then
            preserveCurrentMovementAnimations(humanoid,desc)
            pcall(function() AvatarVisual.applyDescription(humanoid,desc) end)
            pcall(function() desc:Destroy() end)
        end
    end

    for _,dPart in ipairs(avatarPersistTemplate:GetChildren()) do
        if dPart:IsA("MeshPart") and dPart.Name~="Head" then
            local myPart=char:FindFirstChild(dPart.Name)
            if myPart and myPart:IsA("MeshPart") then
                pcall(function() myPart.MeshId=dPart.MeshId; myPart.TextureID=dPart.TextureID end)
            end
        end
    end

    pcall(function() AvatarVisual.finish(char,humanoid,avatarPersistTemplate) end)
    if firstFullRestore then
        avatarRespawnFullApplied[char]=true
        -- Movement animation IDs are intentionally preserved from the live character.
    end

    -- One local settle pass. No Roblox avatar re-fetch and no competing serials.
    task.delay(.28,function()
        if AvatarEnabled and char==lp.Character and char.Parent and avatarPersistTemplate then
            pcall(function() AvatarVisual.finish(char,humanoid,avatarPersistTemplate) end)
        end
    end)

    task.delay(.42,function()
        avatarVisualRepairBusy=false
    end)
    return true
end

local function startKeptAvatarRespawnGuard(char)
    if not AvatarEnabled or not char then return end
    avatarRespawnGuardSerial+=1
    local serial=avatarRespawnGuardSerial

    task.spawn(function()
        local t0=os.clock()
        while os.clock()-t0<6 and (lp.Character~=char or not char.Parent) do task.wait(.05) end
        if serial~=avatarRespawnGuardSerial or not AvatarEnabled or lp.Character~=char then return end
        char:WaitForChild("Humanoid",8)
        char:WaitForChild("Head",8)

        -- Games can apply the player's original appearance several times after spawn.
        -- Reassert the cached avatar at spaced points; each pass is local/cached, not a
        -- new Roblox web/avatar request. The copied look therefore wins the final pass.
        local checkpoints={.18,.65,1.35,2.35,3.8,5.8,8.0}
        local elapsed=0
        for _,targetTime in ipairs(checkpoints) do
            task.wait(math.max(0,targetTime-elapsed))
            elapsed=targetTime
            if serial~=avatarRespawnGuardSerial or not AvatarEnabled or lp.Character~=char or not char.Parent then return end
            if not avatarVisualLooksIntact(char) then restoreKeptAvatar(char) end
        end

        -- After spawn settles, only repair when something actually overwrites it.
        while serial==avatarRespawnGuardSerial and AvatarEnabled and lp.Character==char and char.Parent do
            task.wait(1.5)
            if not avatarVisualLooksIntact(char) then restoreKeptAvatar(char) end
        end
    end)

    char.ChildRemoved:Connect(function(obj)
        if serial~=avatarRespawnGuardSerial or not AvatarEnabled or lp.Character~=char then return end
        if os.clock()<avatarSuppressRepairUntil then return end
        local visual=obj.Name=="KimqAvatarVisualHead"
            or obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
            or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") or obj:IsA("CharacterMesh")
        if visual then
            task.delay(.12,function()
                if serial==avatarRespawnGuardSerial and AvatarEnabled and lp.Character==char
                    and not avatarVisualLooksIntact(char) then restoreKeptAvatar(char) end
            end)
        end
    end)

    char.ChildAdded:Connect(function(obj)
        if serial~=avatarRespawnGuardSerial or not AvatarEnabled or lp.Character~=char then return end
        if os.clock()<avatarSuppressRepairUntil then return end
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("BodyColors") then
            task.delay(.16,function()
                if serial==avatarRespawnGuardSerial and AvatarEnabled and lp.Character==char
                    and not avatarVisualLooksIntact(char) then restoreKeptAvatar(char) end
            end)
        end
    end)
end

lp.CharacterAdded:Connect(function(char)
    if not AvatarEnabled then return end
    startKeptAvatarRespawnGuard(char)
end)

lp.CharacterAppearanceLoaded:Connect(function(char)
    if not AvatarEnabled or not char then return end
    task.delay(.12,function()
        if AvatarEnabled and lp.Character==char and not avatarVisualLooksIntact(char) then
            restoreKeptAvatar(char)
        end
    end)
end)


_G.KimqAvatarController = {
    GetTarget=function() return tostring(AvatarTargetBox.Text or "") end,
    GetKeepAfterRespawn=function() return AvatarEnabled==true end,
    SetTarget=function(v)
        AvatarTargetBox.Text=tostring(v or "")
        AvatarTarget=AvatarTargetBox.Text
    end,
    GetSnapshot=function()
        syncHiddenAccessoriesIntoSnapshot()
        return activeAvatarSnapshot
    end,
    SetSnapshot=function(state)
        activeAvatarSnapshot=type(state)=="table" and state or nil
        if activeAvatarSnapshot then
            avatarPersistenceMode="snapshot"
            activeAvatarUserId=nil
            if avatarPersistTemplate then pcall(function() avatarPersistTemplate:Destroy() end) end
            avatarPersistTemplate=nil
        end
        loadHiddenAccessoriesFromSnapshot(activeAvatarSnapshot)
        if type(_G.KimqRefreshAvatarAccessoryList)=="function" then pcall(_G.KimqRefreshAvatarAccessoryList) end
    end,
    ApplySnapshot=function(state,quiet)
        if type(state)=="table" then activeAvatarSnapshot=state end
        if activeAvatarSnapshot then
            avatarPersistenceMode="snapshot"
            activeAvatarUserId=nil
            if avatarPersistTemplate then pcall(function() avatarPersistTemplate:Destroy() end) end
            avatarPersistTemplate=nil
            setAvatarKeepEnabled(true)
        end
        return applyAvatarSnapshot(activeAvatarSnapshot,lp.Character,quiet==true)
    end,
    ApplySaved=function()
        if activeAvatarSnapshot and lp.Character then
            setAvatarKeepEnabled(true)
            return applyAvatarSnapshot(activeAvatarSnapshot,lp.Character,true)
        end
        AvatarTarget=AvatarTargetBox.Text
        if AvatarTarget~="" and lp.Character then
            local userId=resolveAvatarUserId(AvatarTarget)
            if userId then
                activeAvatarUserId=tonumber(userId)
                avatarPersistenceMode="user"
                setAvatarKeepEnabled(true)
                applyAvatarUser(userId,lp.Character,true)
            end
        end
    end,
    Apply=function(v)
        if v~=nil then
            AvatarTargetBox.Text=tostring(v)
            AvatarTarget=AvatarTargetBox.Text
            activeAvatarSnapshot=nil
            activeAvatarUserId=nil
            avatarPersistenceMode="user"
        end
        setAvatarKeepEnabled(true)
        applyTargetAvatar(false)
    end,
    Reset=function()
        setAvatarKeepEnabled(false)
        activeAvatarSnapshot=nil
        activeAvatarUserId=nil
        avatarPersistenceMode="snapshot"
        if avatarPersistTemplate then pcall(function() avatarPersistTemplate:Destroy() end) end
        avatarPersistTemplate=nil
        table.clear(avatarHiddenAccessoryKeys)
        applyAvatarUser(lp.UserId,lp.Character,false)
    end,
}

]=====], false) then return end

if not runChunk("fog", [=====[
local C = _G.KimpetrasCtx
if not C then error("Kimqetras core context missing") end
local UIS, Main = C.UIS, C.Main
-- ========================================================
-- UNIFIED FOG COLOR PANEL - FIXED
-- ========================================================

local FogLighting = game:GetService("Lighting")

local FogH, FogS, FogV = 335, 65, 82
local FogAmount = 55 -- 0 = almost no fog, 100 = very strong fog
local FogSelected = Color3.fromRGB(255, 170, 205)

-- Use our own Atmosphere so another Atmosphere does not prevent
-- the selected color from being visible.
local FogAtmosphere = FogLighting:FindFirstChild("SilentHCFogAtmosphere")
if not FogAtmosphere then
    FogAtmosphere = Instance.new("Atmosphere")
    FogAtmosphere.Name = "SilentHCFogAtmosphere"
    FogAtmosphere.Parent = FogLighting
end

-- Save existing atmosphere settings so Reset/cleanup can restore them.
local OriginalAtmospheres = {}
for _, obj in ipairs(FogLighting:GetChildren()) do
    if obj:IsA("Atmosphere") and obj ~= FogAtmosphere then
        OriginalAtmospheres[obj] = {
            Color = obj.Color,
            Density = obj.Density,
            Haze = obj.Haze,
            Glare = obj.Glare,
            Offset = obj.Offset
        }
    end
end

local function fogHSV(h,s,v)
    return Color3.fromHSV((h % 360)/360, math.clamp(s,0,100)/100, math.clamp(v,0,100)/100)
end

local function applyUnifiedFog()
    FogSelected = fogHSV(FogH,FogS,FogV)

    -- Legacy Roblox fog.
    pcall(function()
        FogLighting.FogColor = FogSelected
        FogLighting.FogStart = 0
        FogLighting.FogEnd = 900 - (FogAmount * 8.2)
    end)

    -- Dedicated Atmosphere. This is the part that makes the
    -- selected color visible in games that already use Atmosphere.
    pcall(function()
        FogAtmosphere.Color = FogSelected
        FogAtmosphere.Density = 0.02 + (FogAmount / 100) * 0.68
        FogAtmosphere.Haze = (FogAmount / 100) * 3.5
        FogAtmosphere.Glare = 0
        FogAtmosphere.Offset = 0
    end)

    -- Reduce competing Atmospheres while the picker is active.
    for _, obj in ipairs(FogLighting:GetChildren()) do
        if obj:IsA("Atmosphere") and obj ~= FogAtmosphere then
            pcall(function()
                obj.Density = 0
            end)
        end
    end
end

-- UI
local FogPanel = Instance.new("Frame", Main)
FogPanel.Name = "FogPanel"
FogPanel.Size = UDim2.new(0, 570, 1, -50)
FogPanel.Position = UDim2.new(0, 390, 0, 40)
FogPanel.BackgroundColor3 = Color3.fromRGB(255, 225, 238)
FogPanel.BorderSizePixel = 0

Instance.new("UICorner", FogPanel).CornerRadius = UDim.new(0, 12)

local FogPanelStroke = Instance.new("UIStroke", FogPanel)
FogPanelStroke.Color = Color3.fromRGB(255, 20, 147)

local FogHeader = Instance.new("TextLabel", FogPanel)
FogHeader.Size = UDim2.new(1, -30, 0, 40)
FogHeader.Position = UDim2.fromOffset(15, 5)
FogHeader.BackgroundTransparency = 1
FogHeader.Text = "♥  Fog Color Picker"
FogHeader.TextColor3 = Color3.fromRGB(230, 40, 135)
FogHeader.TextSize = 18
FogHeader.Font = Enum.Font.GothamBold
FogHeader.TextXAlignment = Enum.TextXAlignment.Left

local FogDivider = Instance.new("Frame", FogPanel)
FogDivider.Size = UDim2.new(1, -30, 0, 1)
FogDivider.Position = UDim2.fromOffset(15, 45)
FogDivider.BackgroundColor3 = Color3.fromRGB(255, 175, 215)
FogDivider.BorderSizePixel = 0

-- Color square
local FogSquare = Instance.new("Frame", FogPanel)
FogSquare.Size = UDim2.fromOffset(300, 300)
FogSquare.Position = UDim2.fromOffset(18, 65)
FogSquare.BackgroundColor3 = Color3.fromHSV(FogH/360,1,1)
FogSquare.BorderSizePixel = 0
FogSquare.ClipsDescendants = true
Instance.new("UICorner", FogSquare).CornerRadius = UDim.new(0, 14)

local FogWhite = Instance.new("Frame", FogSquare)
FogWhite.Size = UDim2.fromScale(1,1)
FogWhite.BackgroundColor3 = Color3.new(1,1,1)
FogWhite.BorderSizePixel = 0
local FogWhiteGrad = Instance.new("UIGradient", FogWhite)
FogWhiteGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0),
    NumberSequenceKeypoint.new(1,1)
})

local FogBlack = Instance.new("Frame", FogSquare)
FogBlack.Size = UDim2.fromScale(1,1)
FogBlack.BackgroundColor3 = Color3.new(0,0,0)
FogBlack.BorderSizePixel = 0
local FogBlackGrad = Instance.new("UIGradient", FogBlack)
FogBlackGrad.Rotation = 90
FogBlackGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1),
    NumberSequenceKeypoint.new(1,0)
})

local FogSelector = Instance.new("Frame", FogSquare)
FogSelector.Size = UDim2.fromOffset(17,17)
FogSelector.AnchorPoint = Vector2.new(.5,.5)
FogSelector.Position = UDim2.new(FogS/100,0,1-FogV/100,0)
FogSelector.BackgroundTransparency = 1
FogSelector.ZIndex = 5
Instance.new("UICorner", FogSelector).CornerRadius = UDim.new(1,0)

local FogSelectorStroke = Instance.new("UIStroke", FogSelector)
FogSelectorStroke.Color = Color3.new(1,1,1)
FogSelectorStroke.Thickness = 2

-- Hue bar
local FogHueBar = Instance.new("Frame", FogPanel)
FogHueBar.Size = UDim2.fromOffset(24,300)
FogHueBar.Position = UDim2.fromOffset(328,65)
FogHueBar.BorderSizePixel = 0
Instance.new("UICorner", FogHueBar).CornerRadius = UDim.new(0,12)

local FogHueGrad = Instance.new("UIGradient", FogHueBar)
FogHueGrad.Rotation = 90
-- Full rainbow hue strip. The square below controls saturation/brightness.
FogHueGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1/6,  Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(2/6,  Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(3/6,  Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(4/6,  Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(5/6,  Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
})

local FogHueKnob = Instance.new("Frame", FogHueBar)
FogHueKnob.Size = UDim2.fromOffset(34,13)
FogHueKnob.AnchorPoint = Vector2.new(.5,.5)
FogHueKnob.Position = UDim2.new(.5,0,1-FogH/360,0)
FogHueKnob.BackgroundColor3 = Color3.fromHSV(FogH/360, 1, 1)
FogHueKnob.ZIndex = 5
Instance.new("UICorner", FogHueKnob).CornerRadius = UDim.new(1,0)

local FogHueStroke = Instance.new("UIStroke", FogHueKnob)
FogHueStroke.Color = Color3.new(1,1,1)
FogHueStroke.Thickness = 2

local FogCurrent = Instance.new("TextLabel", FogPanel)
FogCurrent.Size = UDim2.fromOffset(190,25)
FogCurrent.Position = UDim2.fromOffset(365,65)
FogCurrent.BackgroundTransparency = 1
FogCurrent.Text = "Current Color"
FogCurrent.TextColor3 = Color3.fromRGB(230, 40, 135)
FogCurrent.TextSize = 14
FogCurrent.Font = Enum.Font.GothamMedium
FogCurrent.TextXAlignment = Enum.TextXAlignment.Left

local FogPreview = Instance.new("Frame", FogPanel)
FogPreview.Size = UDim2.fromOffset(185,58)
FogPreview.Position = UDim2.fromOffset(365,92)
FogPreview.BackgroundColor3 = FogSelected
FogPreview.BorderSizePixel = 0
Instance.new("UICorner", FogPreview).CornerRadius = UDim.new(0,14)

local FogHexLabel = Instance.new("TextLabel", FogPanel)
FogHexLabel.Size = UDim2.fromOffset(50,20)
FogHexLabel.Position = UDim2.fromOffset(365,160)
FogHexLabel.BackgroundTransparency = 1
FogHexLabel.Text = "HEX"
FogHexLabel.TextColor3 = Color3.fromRGB(230, 40, 135)
FogHexLabel.TextSize = 13
FogHexLabel.Font = Enum.Font.GothamBold
FogHexLabel.TextXAlignment = Enum.TextXAlignment.Left

local FogHex = Instance.new("TextBox", FogPanel)
FogHex.Size = UDim2.fromOffset(185,35)
FogHex.Position = UDim2.fromOffset(365,183)
FogHex.BackgroundColor3 = Color3.fromRGB(255, 231, 241)
FogHex.Text = "#FF6BB5"
FogHex.TextColor3 = Color3.fromRGB(230, 40, 135)
FogHex.TextSize = 13
FogHex.Font = Enum.Font.Gotham
FogHex.ClearTextOnFocus = false
FogHex.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", FogHex).CornerRadius = UDim.new(0,10)
local FogHexPad = Instance.new("UIPadding", FogHex)
FogHexPad.PaddingLeft = UDim.new(0,10)
local FogHexStroke = Instance.new("UIStroke", FogHex)
FogHexStroke.Color = Color3.fromRGB(248,190,205)

local function fogValueBox(y, letter, value)
    local label = Instance.new("TextLabel", FogPanel)
    label.Size = UDim2.fromOffset(20,25)
    label.Position = UDim2.fromOffset(365,y)
    label.BackgroundTransparency = 1
    label.Text = letter
    label.TextColor3 = Color3.fromRGB(230, 40, 135)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold

    local box = Instance.new("TextBox", FogPanel)
    box.Size = UDim2.fromOffset(130,32)
    box.Position = UDim2.fromOffset(390,y-4)
    box.BackgroundColor3 = Color3.fromRGB(255, 231, 241)
    box.Text = tostring(math.floor(value))
    box.TextColor3 = Color3.fromRGB(230, 40, 135)
    box.TextSize = 13
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Color3.fromRGB(248,190,205)
    return box
end

local FogHBox = fogValueBox(230,"H",FogH)
local FogSBox = fogValueBox(272,"S",FogS)
local FogVBox = fogValueBox(314,"V",FogV)

-- Fog amount slider
local FogAmountLabel = Instance.new("TextLabel", FogPanel)
FogAmountLabel.Size = UDim2.fromOffset(200,25)
FogAmountLabel.Position = UDim2.fromOffset(18,375)
FogAmountLabel.BackgroundTransparency = 1
FogAmountLabel.Text = "Fog Amount"
FogAmountLabel.TextColor3 = Color3.fromRGB(230, 40, 135)
FogAmountLabel.TextSize = 14
FogAmountLabel.Font = Enum.Font.GothamBold
FogAmountLabel.TextXAlignment = Enum.TextXAlignment.Left

local FogAmountValue = Instance.new("TextLabel", FogPanel)
FogAmountValue.Size = UDim2.fromOffset(60,25)
FogAmountValue.Position = UDim2.fromOffset(285,375)
FogAmountValue.BackgroundTransparency = 1
FogAmountValue.Text = tostring(FogAmount).."%"
FogAmountValue.TextColor3 = Color3.fromRGB(210, 65, 135)
FogAmountValue.TextSize = 13
FogAmountValue.Font = Enum.Font.GothamMedium
FogAmountValue.TextXAlignment = Enum.TextXAlignment.Right

local FogAmountTrack = Instance.new("Frame", FogPanel)
FogAmountTrack.Size = UDim2.fromOffset(327,8)
FogAmountTrack.Position = UDim2.fromOffset(18,405)
FogAmountTrack.BackgroundColor3 = Color3.fromRGB(255, 175, 215)
FogAmountTrack.BorderSizePixel = 0
Instance.new("UICorner", FogAmountTrack).CornerRadius = UDim.new(1,0)

local FogAmountFill = Instance.new("Frame", FogAmountTrack)
FogAmountFill.Size = UDim2.new(FogAmount/100,0,1,0)
FogAmountFill.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
FogAmountFill.BorderSizePixel = 0
Instance.new("UICorner", FogAmountFill).CornerRadius = UDim.new(1,0)

local FogAmountKnob = Instance.new("Frame", FogAmountTrack)
FogAmountKnob.Size = UDim2.fromOffset(16,16)
FogAmountKnob.AnchorPoint = Vector2.new(.5,.5)
FogAmountKnob.Position = UDim2.new(FogAmount/100,0,.5,0)
FogAmountKnob.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
FogAmountKnob.BorderSizePixel = 0
Instance.new("UICorner", FogAmountKnob).CornerRadius = UDim.new(1,0)
local FogAmountKnobStroke=Instance.new("UIStroke",FogAmountKnob)
FogAmountKnobStroke.Color=Color3.fromRGB(255, 240, 247)
FogAmountKnobStroke.Thickness=2

local FogAmountDown=false
local function updateFogAmount(input)
    local x=math.clamp((input.Position.X-FogAmountTrack.AbsolutePosition.X)/FogAmountTrack.AbsoluteSize.X,0,1)
    FogAmount=math.floor(x*100+0.5)
    FogAmountFill.Size=UDim2.new(x,0,1,0)
    FogAmountKnob.Position=UDim2.new(x,0,.5,0)
    FogAmountValue.Text=tostring(FogAmount).."%"
    applyUnifiedFog()
end
FogAmountTrack.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        FogAmountDown=true
        updateFogAmount(input)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then FogAmountDown=false end
end)
UIS.InputChanged:Connect(function(input)
    if FogAmountDown and input.UserInputType==Enum.UserInputType.MouseMovement then
        updateFogAmount(input)
    end
end)

local FogAmountHint = Instance.new("TextLabel", FogPanel)
FogAmountHint.Size = UDim2.fromOffset(330,22)
FogAmountHint.Position = UDim2.fromOffset(18,418)
FogAmountHint.BackgroundTransparency = 1
FogAmountHint.Text = "less fog  ·  ·  ·  ·  ·  ·  more fog"
FogAmountHint.TextColor3 = Color3.fromRGB(210, 65, 135)
FogAmountHint.TextSize = 11
FogAmountHint.Font = Enum.Font.Gotham
FogAmountHint.TextXAlignment = Enum.TextXAlignment.Center

local FogStatus = Instance.new("TextLabel", FogPanel)
FogStatus.Size = UDim2.fromOffset(520,28)
FogStatus.Position = UDim2.fromOffset(18,525)
FogStatus.BackgroundTransparency = 1
FogStatus.Text = "♥ Fog lock enabled    ♥ Legacy Fog    ♥ Dedicated Atmosphere"
FogStatus.TextColor3 = Color3.fromRGB(230, 40, 135)
FogStatus.TextSize = 12
FogStatus.Font = Enum.Font.Gotham
FogStatus.TextXAlignment = Enum.TextXAlignment.Left

local FogReset = Instance.new("TextButton", FogPanel)
FogReset.Size = UDim2.fromOffset(90,34)
FogReset.Position = UDim2.fromOffset(455,520)
FogReset.BackgroundColor3 = Color3.fromRGB(255, 231, 241)
FogReset.Text = "Reset"
FogReset.TextColor3 = Color3.fromRGB(230, 40, 135)
FogReset.TextSize = 13
FogReset.Font = Enum.Font.GothamBold
Instance.new("UICorner", FogReset).CornerRadius = UDim.new(0,7)

local FogSquareDown=false
local FogHueDown=false

local function refreshFogUI()
    FogPreview.BackgroundColor3=FogSelected
    FogHex.Text=string.format("#%02X%02X%02X",
        math.floor(FogSelected.R*255),
        math.floor(FogSelected.G*255),
        math.floor(FogSelected.B*255))

    FogHBox.Text=tostring(math.floor(FogH))
    FogSBox.Text=tostring(math.floor(FogS))
    FogVBox.Text=tostring(math.floor(FogV))

    FogSquare.BackgroundColor3=Color3.fromHSV(FogH/360,1,1)
    FogSelector.Position=UDim2.new(FogS/100,0,1-FogV/100,0)
    FogHueKnob.Position=UDim2.new(.5,0,1-FogH/360,0)
    FogHueKnob.BackgroundColor3=Color3.fromHSV(FogH/360,1,1)
    FogAmountValue.Text=tostring(FogAmount).."%"
    FogAmountFill.Size=UDim2.new(FogAmount/100,0,1,0)
    FogAmountKnob.Position=UDim2.new(FogAmount/100,0,.5,0)
end

FogSquare.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        FogSquareDown=true
    end
end)

FogHueBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        FogHueDown=true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        FogSquareDown=false
        FogHueDown=false
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseMovement then return end

    if FogSquareDown then
        local x=math.clamp(
            (input.Position.X-FogSquare.AbsolutePosition.X)/
            FogSquare.AbsoluteSize.X,0,1
        )
        local y=math.clamp(
            (input.Position.Y-FogSquare.AbsolutePosition.Y)/
            FogSquare.AbsoluteSize.Y,0,1
        )

        FogS=x*100
        FogV=(1-y)*100

        applyUnifiedFog()
        refreshFogUI()
    end

    if FogHueDown then
        local y=math.clamp(
            (input.Position.Y-FogHueBar.AbsolutePosition.Y)/
            FogHueBar.AbsoluteSize.Y,0,1
        )

        FogH=(1-y)*360

        applyUnifiedFog()
        refreshFogUI()
    end
end)

local function connectFogBox(box,kind,max)
    box.FocusLost:Connect(function()
        local n=tonumber(box.Text)

        if n then
            n=math.clamp(n,0,max)
            if kind=="H" then FogH=n end
            if kind=="S" then FogS=n end
            if kind=="V" then FogV=n end
        end

        applyUnifiedFog()
        refreshFogUI()
    end)
end

connectFogBox(FogHBox,"H",360)
connectFogBox(FogSBox,"S",100)
connectFogBox(FogVBox,"V",100)

FogHex.FocusLost:Connect(function()
    local t=FogHex.Text:gsub("#","")

    if #t==6 then
        local r=tonumber(t:sub(1,2),16)
        local g=tonumber(t:sub(3,4),16)
        local b=tonumber(t:sub(5,6),16)

        if r and g and b then
            local c = Color3.fromRGB(r,g,b)
            local h, ss, vv = c:ToHSV()
            FogH=h*360
            FogS=ss*100
            FogV=vv*100

            applyUnifiedFog()
            refreshFogUI()
        end
    end
end)

FogReset.MouseButton1Click:Connect(function()
    FogH=335
    FogS=65
    FogV=82
    FogAmount=55
    applyUnifiedFog()
    refreshFogUI()
end)

local function fogPackColor(c)
    if typeof(c) ~= "Color3" then return nil end
    return {r=c.R, g=c.G, b=c.B}
end

local function fogUnpackColor(t)
    if type(t) ~= "table" then return nil end
    local r,g,b=tonumber(t.r),tonumber(t.g),tonumber(t.b)
    if not (r and g and b) then return nil end
    return Color3.new(math.clamp(r,0,1), math.clamp(g,0,1), math.clamp(b,0,1))
end

local function getFogConfigState()
    -- Save both picker values and the exact Lighting/Atmosphere values that are
    -- currently visible. Keeping both makes config restores deterministic.
    local state = {
        h=FogH, s=FogS, v=FogV, amount=FogAmount,
        selected=fogPackColor(FogSelected),
        lighting={},
        atmosphere={}
    }
    pcall(function()
        state.lighting.color=fogPackColor(FogLighting.FogColor)
        state.lighting.start=FogLighting.FogStart
        state.lighting.finish=FogLighting.FogEnd
    end)
    pcall(function()
        state.atmosphere.color=fogPackColor(FogAtmosphere.Color)
        state.atmosphere.density=FogAtmosphere.Density
        state.atmosphere.haze=FogAtmosphere.Haze
        state.atmosphere.glare=FogAtmosphere.Glare
        state.atmosphere.offset=FogAtmosphere.Offset
    end)
    return state
end

local function setFogConfigState(state)
    if type(state) ~= "table" then return end

    FogH = math.clamp(tonumber(state.h) or FogH, 0, 360)
    FogS = math.clamp(tonumber(state.s) or FogS, 0, 100)
    FogV = math.clamp(tonumber(state.v) or FogV, 0, 100)
    FogAmount = math.clamp(tonumber(state.amount) or FogAmount, 0, 100)

    -- First rebuild from the picker values so every UI element matches.
    applyUnifiedFog()

    -- Then restore the exact saved values. This prevents rounding/formula changes
    -- or another preset loaded earlier in the config from changing the result.
    local selected=fogUnpackColor(state.selected)
    if selected then FogSelected=selected end

    if type(state.lighting)=="table" then
        pcall(function()
            local c=fogUnpackColor(state.lighting.color)
            if c then FogLighting.FogColor=c end
            if tonumber(state.lighting.start) then FogLighting.FogStart=tonumber(state.lighting.start) end
            if tonumber(state.lighting.finish) then FogLighting.FogEnd=tonumber(state.lighting.finish) end
        end)
    end

    if type(state.atmosphere)=="table" then
        pcall(function()
            local c=fogUnpackColor(state.atmosphere.color)
            if c then FogAtmosphere.Color=c end
            if tonumber(state.atmosphere.density) then FogAtmosphere.Density=tonumber(state.atmosphere.density) end
            if tonumber(state.atmosphere.haze) then FogAtmosphere.Haze=tonumber(state.atmosphere.haze) end
            if tonumber(state.atmosphere.glare) then FogAtmosphere.Glare=tonumber(state.atmosphere.glare) end
            if tonumber(state.atmosphere.offset) then FogAtmosphere.Offset=tonumber(state.atmosphere.offset) end
        end)
    end

    -- The custom fog owns the visible atmosphere while active.
    for _, obj in ipairs(FogLighting:GetChildren()) do
        if obj:IsA("Atmosphere") and obj ~= FogAtmosphere then
            pcall(function() obj.Density=0 end)
        end
    end

    refreshFogUI()
end
_G.KimqFogController = {GetState=getFogConfigState, SetState=setFogConfigState}
if type(_G.KimqRegisterConfigControl) == "function" then
    _G.KimqRegisterConfigControl("Fog / Atmosphere State", "state", getFogConfigState, setFogConfigState)
end

]=====], false) then return end

if not runChunk("backend", [=====[
(function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UIS = game:GetService('UserInputService')
local cam = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")

local function SafeDrawing(kind)
    if type(Drawing) == "table" and type(Drawing.new) == "function" then
        local ok, obj = pcall(Drawing.new, kind)
        if ok and obj then return obj end
    end
    local dummy = {Visible = false}
    function dummy:Remove() end
    return dummy
end

-- Kimqetras HC owner presence notification.
-- Owner presence notification for Kimqetras HC.
local KIMQ_OWNER_USER_ID = 11150537473
local ownerNoticeSeen = {}
local function notifyKimqOwner(player)
    if not player or player.UserId ~= KIMQ_OWNER_USER_ID or ownerNoticeSeen[player] then return end
    ownerNoticeSeen[player] = true
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Kimqetras HC ♡",
            Text = "Kimqetras owner joined ♡",
            Duration = 8
        })
    end)
end

for _,player in ipairs(Players:GetPlayers()) do
    notifyKimqOwner(player)
end
Players.PlayerAdded:Connect(function(player)
    if player.UserId == KIMQ_OWNER_USER_ID then
        task.wait(0.35)
        notifyKimqOwner(player)
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kimqetras HC ♡",
        Text = "Kimqetras owner build loaded ♡",
        Duration = 2
    })
end)

_G.FOV_RADIUS = 100
_G.ShowFOV = false
_G.RevolverBypass = false
_G.WallCheck = false
_G.SilentAimEnabled = true
_G.KnockCheck = false
_G.DeathPositions = {}
_G.ESP_Boxes = false
_G.ESP_Names = false
_G.ESP_Health = false
_G.ESP_Distance = false
_G.ESP_Tracer = false
_G.ESP_Skeleton = false
_G.ESP_Color = Color3.fromRGB(255, 255, 255)
_G.FlamelockEnabled = false
_G.FlameMode = "Hold"
_G.FlameKey = Enum.KeyCode.Z
_G.FlameRightClick = false
_G.FlameSmoothness = 0
_G.FlamePrediction = 0
_G.FlameLeftOffset = 0
_G.FlameUpOffset = 0
_G.FlameHitPart = "HumanoidRootPart"
_G.FlameActive = false
_G.FPSUnlocker = true
_G.FPSTarget = 240
task.defer(function() if _G.FPSUnlocker and type(setfpscap) == "function" then pcall(setfpscap, _G.FPSTarget) end end)
_G.UIToggleKey = Enum.KeyCode.Unknown
_G.UIVisible = true
_G.ESP_Enabled = false
_G.Whitelist = _G.Whitelist or {}
_G.BulletSpreadAmount = 100

_G.ForceHitEnabled = false
_G.ForceHitMode = "Fov"
_G.ForceHitFOV = 100
_G.ForceHitTracerEnabled = true
_G.ForceHitFullAutoEnabled = false
_G.ForceHitFireRate = 0.067
_G.ForceHitOneClickFinish = true
_G.ForceHitFinishShots = 6
_G.ForceHitAutoReload = true

_G.HCSilentAimEnabled = false
_G.HCRevolverBypass = false
_G.HCWallCheck = false
_G.HCKnockCheck = false
_G.HCPrediction = false
_G.HCPredictionAmount = 0.165
_G.HCFOVRadius = 100
_G.HCHitPart = "Head"

_G.HCGodmodeEnabled = false

_G.ColorCorrectionEnabled = false
_G.CurrentTheme = "Cinnamoroll"

_G.CamlockEnabled = false
_G.CamlockToggleKey = "C"
_G.CamlockMode = "Toggle"
_G.CamlockAutoToggle = false
_G.CamlockHitPart = "HumanoidRootPart"
_G.CamlockEasingStyle = "Quad"
_G.CamlockEasingDirection = "Out"
_G.CamlockFOVRadius = 0
_G.CamlockClosestPointMode = "Default"
_G.CamlockClosestPointScale = 0
_G.CamlockSmoothness = 0
_G.CamlockPullStrengthEnabled = false
_G.CamlockPullStrengthBaseValue = 0
_G.CamlockPullStrengthMoveValue = 0
_G.CamlockPredictionEnabled = false
_G.CamlockPredictionX = 0
_G.CamlockPredictionY = 0
_G.CamlockPredictionZ = 0
_G.CamlockMaxDistance = 0
_G.CamlockConditionsForceField = false
_G.CamlockConditionsVisible = false
_G.CamlockConditionsCarried = false
_G.CamlockConditionsKnocked = false
_G.CamlockConditionsSelfKnocked = false

_G.AntiAimViewEnabled = true
_G.AntiModNotification = true
_G.AntiModKick = true
_G.AntiModKickDelay = 3
_G.AntiFallEnabled = false -- duplicate backend path disabled; visible Anti Fall page owns this feature

_G.DelayChangerEnabled = false
_G.DelayChangerRevolver = 0.03
_G.DelayChangerDoubleBarrel = 0.3
_G.DelayChangerTacticalShotgun = 0.0
_G.DelayChangerOthers = 0.095

_G.HitboxEnabled = false
_G.HitboxSize = 2
_G.HitboxTransparency = 0
_G.HitboxColor = Color3.fromRGB(145, 210, 240)

local HCGodmode_Active = false
local HCGodmode_Track = nil
local HCGodmode_Heartbeat = nil
local HCGodmode_AnimConn = nil
local HCGodmode_EmoteID = "rbxassetid://70883871260184"
local HCGodmode_FreezeTime = 0.1265

local function HCGodmode_Cleanup()
    if HCGodmode_Track then HCGodmode_Track:Stop() HCGodmode_Track:Destroy() HCGodmode_Track = nil end
    if HCGodmode_Heartbeat then HCGodmode_Heartbeat:Disconnect() HCGodmode_Heartbeat = nil end
    if HCGodmode_AnimConn then HCGodmode_AnimConn:Disconnect() HCGodmode_AnimConn = nil end
end

local function HCGodmode_GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function HCGodmode_Animate()
    if not HCGodmode_Active then return end
    local hum = HCGodmode_GetHumanoid()
    if not hum then return end
    HCGodmode_Cleanup()
    local anim = Instance.new("Animation")
    anim.AnimationId = HCGodmode_EmoteID
    HCGodmode_Track = hum:LoadAnimation(anim)
    HCGodmode_Track:Play(0, 1, 1)
    HCGodmode_Heartbeat = RunService.Heartbeat:Connect(function()
        if HCGodmode_Track and HCGodmode_Active then
            HCGodmode_Track.TimePosition = HCGodmode_FreezeTime
            HCGodmode_Track:AdjustSpeed(0)
        end
    end)
    HCGodmode_AnimConn = hum.AnimationPlayed:Connect(function(newtrack)
        if HCGodmode_Active and HCGodmode_Track and newtrack ~= HCGodmode_Track then
            task.delay(0.02 + math.random() * 0.03, HCGodmode_Animate)
        end
    end)
end

local function HCGodmode_Stop()
    HCGodmode_Cleanup()
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.25)
    if HCGodmode_Active then HCGodmode_Animate() end
end)

local ColorPresets = {
    ["Cinnamoroll"] = {
        AccentColor = Color3.fromRGB(145, 210, 240),
        DimColor = Color3.fromRGB(180, 215, 235),
        HighlightColor = Color3.fromRGB(255, 255, 255),
        BgColor = Color3.fromRGB(255, 255, 255),
        SectionBg = Color3.fromRGB(245, 250, 252),
        TrayColor = Color3.fromRGB(200, 225, 240),
        TextColor = Color3.fromRGB(100, 160, 200),
        DimTextColor = Color3.fromRGB(180, 205, 220),
        BorderColor = Color3.fromRGB(210, 230, 240),
        DarkBg = Color3.fromRGB(240, 248, 252),
        HeaderBg = Color3.fromRGB(220, 238, 248)
    },
    ["Default"] = {
        AccentColor = Color3.fromRGB(230, 180, 255),
        DimColor = Color3.fromRGB(200, 200, 210),
        HighlightColor = Color3.fromRGB(255, 255, 255),
        BgColor = Color3.fromRGB(25, 22, 28),
        SectionBg = Color3.fromRGB(32, 28, 36),
        TrayColor = Color3.fromRGB(55, 50, 60),
        TextColor = Color3.fromRGB(229, 229, 229),
        DimTextColor = Color3.fromRGB(74, 74, 74),
        BorderColor = Color3.fromRGB(31, 31, 31),
        DarkBg = Color3.fromRGB(11, 11, 11),
        HeaderBg = Color3.fromRGB(19, 19, 19)
    },
    ["Rose Gold"] = {
        AccentColor = Color3.fromRGB(255, 179, 186),
        DimColor = Color3.fromRGB(200, 195, 195),
        HighlightColor = Color3.fromRGB(255, 240, 245),
        BgColor = Color3.fromRGB(30, 22, 24),
        SectionBg = Color3.fromRGB(38, 28, 30),
        TrayColor = Color3.fromRGB(60, 50, 52),
        TextColor = Color3.fromRGB(235, 225, 225),
        DimTextColor = Color3.fromRGB(85, 70, 75),
        BorderColor = Color3.fromRGB(50, 35, 40),
        DarkBg = Color3.fromRGB(18, 12, 14),
        HeaderBg = Color3.fromRGB(25, 18, 20)
    },
    ["Ocean Blue"] = {
        AccentColor = Color3.fromRGB(130, 200, 255),
        DimColor = Color3.fromRGB(180, 190, 200),
        HighlightColor = Color3.fromRGB(220, 240, 255),
        BgColor = Color3.fromRGB(18, 22, 28),
        SectionBg = Color3.fromRGB(24, 28, 36),
        TrayColor = Color3.fromRGB(45, 50, 60),
        TextColor = Color3.fromRGB(220, 230, 240),
        DimTextColor = Color3.fromRGB(65, 75, 85),
        BorderColor = Color3.fromRGB(30, 35, 45),
        DarkBg = Color3.fromRGB(10, 12, 18),
        HeaderBg = Color3.fromRGB(15, 18, 24)
    },
    ["Mint Green"] = {
        AccentColor = Color3.fromRGB(150, 255, 200),
        DimColor = Color3.fromRGB(180, 200, 190),
        HighlightColor = Color3.fromRGB(220, 255, 235),
        BgColor = Color3.fromRGB(20, 28, 24),
        SectionBg = Color3.fromRGB(26, 36, 30),
        TrayColor = Color3.fromRGB(48, 60, 52),
        TextColor = Color3.fromRGB(220, 235, 225),
        DimTextColor = Color3.fromRGB(65, 80, 70),
        BorderColor = Color3.fromRGB(30, 42, 36),
        DarkBg = Color3.fromRGB(10, 16, 14),
        HeaderBg = Color3.fromRGB(16, 22, 20)
    },
    ["Neon Pink"] = {
        AccentColor = Color3.fromRGB(255, 100, 180),
        DimColor = Color3.fromRGB(210, 180, 195),
        HighlightColor = Color3.fromRGB(255, 200, 230),
        BgColor = Color3.fromRGB(28, 18, 24),
        SectionBg = Color3.fromRGB(36, 24, 30),
        TrayColor = Color3.fromRGB(58, 45, 50),
        TextColor = Color3.fromRGB(240, 215, 225),
        DimTextColor = Color3.fromRGB(90, 65, 75),
        BorderColor = Color3.fromRGB(48, 30, 40),
        DarkBg = Color3.fromRGB(18, 10, 14),
        HeaderBg = Color3.fromRGB(24, 15, 20)
    },
    ["Sunset Orange"] = {
        AccentColor = Color3.fromRGB(255, 160, 100),
        DimColor = Color3.fromRGB(210, 190, 180),
        HighlightColor = Color3.fromRGB(255, 230, 210),
        BgColor = Color3.fromRGB(28, 22, 18),
        SectionBg = Color3.fromRGB(36, 28, 24),
        TrayColor = Color3.fromRGB(58, 50, 45),
        TextColor = Color3.fromRGB(235, 225, 215),
        DimTextColor = Color3.fromRGB(85, 70, 60),
        BorderColor = Color3.fromRGB(46, 36, 30),
        DarkBg = Color3.fromRGB(16, 12, 10),
        HeaderBg = Color3.fromRGB(24, 18, 15)
    },
    ["Amethyst"] = {
        AccentColor = Color3.fromRGB(200, 140, 255),
        DimColor = Color3.fromRGB(190, 180, 205),
        HighlightColor = Color3.fromRGB(235, 220, 255),
        BgColor = Color3.fromRGB(24, 20, 30),
        SectionBg = Color3.fromRGB(30, 26, 38),
        TrayColor = Color3.fromRGB(52, 48, 62),
        TextColor = Color3.fromRGB(225, 220, 235),
        DimTextColor = Color3.fromRGB(75, 70, 85),
        BorderColor = Color3.fromRGB(38, 34, 48),
        DarkBg = Color3.fromRGB(14, 12, 20),
        HeaderBg = Color3.fromRGB(20, 17, 26)
    },
    ["Blood Red"] = {
        AccentColor = Color3.fromRGB(255, 80, 80),
        DimColor = Color3.fromRGB(200, 170, 170),
        HighlightColor = Color3.fromRGB(255, 200, 200),
        BgColor = Color3.fromRGB(28, 18, 18),
        SectionBg = Color3.fromRGB(36, 22, 22),
        TrayColor = Color3.fromRGB(58, 40, 40),
        TextColor = Color3.fromRGB(235, 210, 210),
        DimTextColor = Color3.fromRGB(90, 60, 60),
        BorderColor = Color3.fromRGB(48, 28, 28),
        DarkBg = Color3.fromRGB(18, 10, 10),
        HeaderBg = Color3.fromRGB(24, 14, 14)
    },
    ["Cyber Yellow"] = {
        AccentColor = Color3.fromRGB(255, 230, 50),
        DimColor = Color3.fromRGB(200, 195, 150),
        HighlightColor = Color3.fromRGB(255, 250, 200),
        BgColor = Color3.fromRGB(25, 24, 15),
        SectionBg = Color3.fromRGB(32, 30, 20),
        TrayColor = Color3.fromRGB(55, 52, 38),
        TextColor = Color3.fromRGB(235, 230, 200),
        DimTextColor = Color3.fromRGB(80, 75, 50),
        BorderColor = Color3.fromRGB(42, 40, 26),
        DarkBg = Color3.fromRGB(15, 14, 8),
        HeaderBg = Color3.fromRGB(22, 20, 12)
    },
    ["Monochrome"] = {
        AccentColor = Color3.fromRGB(200, 200, 200),
        DimColor = Color3.fromRGB(150, 150, 155),
        HighlightColor = Color3.fromRGB(240, 240, 240),
        BgColor = Color3.fromRGB(20, 20, 22),
        SectionBg = Color3.fromRGB(28, 28, 30),
        TrayColor = Color3.fromRGB(50, 50, 52),
        TextColor = Color3.fromRGB(220, 220, 220),
        DimTextColor = Color3.fromRGB(70, 70, 72),
        BorderColor = Color3.fromRGB(36, 36, 38),
        DarkBg = Color3.fromRGB(10, 10, 12),
        HeaderBg = Color3.fromRGB(16, 16, 18)
    }
}

local BulletSpreadSettings = { Enabled = true }
local headlessActive = false
local espObjects = {}
local aimPart = "Head"

local AllHitPartOptions = {
    "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
    "LeftFoot", "RightFoot", "LeftHand", "RightHand", "Closest Point"
}

local HCForceHitParts = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
    "HumanoidRootPart"
}

local FogPresets = {
    ["Red"] = {Color = Color3.fromRGB(255, 60, 60), Density = 0.45},
    ["Light Red"] = {Color = Color3.fromRGB(255, 120, 120), Density = 0.44},
    ["Dark Red"] = {Color = Color3.fromRGB(180, 20, 20), Density = 0.48},
    ["Orange"] = {Color = Color3.fromRGB(255, 140, 0), Density = 0.43},
    ["Light Orange"] = {Color = Color3.fromRGB(255, 190, 80), Density = 0.42},
    ["Dark Orange"] = {Color = Color3.fromRGB(200, 90, 0), Density = 0.46},
    ["Yellow"] = {Color = Color3.fromRGB(255, 240, 60), Density = 0.41},
    ["Lime"] = {Color = Color3.fromRGB(140, 255, 60), Density = 0.45},
    ["Green"] = {Color = Color3.fromRGB(50, 255, 50), Density = 0.49},
    ["Cyan"] = {Color = Color3.fromRGB(60, 255, 220), Density = 0.47},
    ["Electric Blue"] = {Color = Color3.fromRGB(0, 255, 255), Density = 0.51},
    ["Blue"] = {Color = Color3.fromRGB(60, 140, 255), Density = 0.50},
    ["Purple"] = {Color = Color3.fromRGB(180, 60, 255), Density = 0.52},
    ["Violet"] = {Color = Color3.fromRGB(138, 43, 226), Density = 0.56},
    ["Pink"] = {Color = Color3.fromRGB(255, 100, 200), Density = 0.48},
    ["Hot Pink"] = {Color = Color3.fromRGB(255, 20, 147), Density = 0.49}
}

local OrigLighting = {
    FogStart = game:GetService("Lighting").FogStart,
    FogEnd = game:GetService("Lighting").FogEnd,
    FogColor = game:GetService("Lighting").FogColor
}

local boneConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
}

local function IsKnocked(character)
    if not character then return false end
    local bodyEffects = character:FindFirstChild('BodyEffects')
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild('K.O')
        return ko and ko.Value == true
    end
    return false
end

local function isKnocked(character)
    local bodyEffects = character:FindFirstChild("BodyEffects")
    if bodyEffects and bodyEffects:FindFirstChild("K.O") then return bodyEffects["K.O"].Value end
    return false
end

local function IsGrabbed(player)
    return player and player.Character and player.Character:FindFirstChild('GRABBING_CONSTRAINT') ~= nil
end

local function getClosestPartToMouse(char)
    local m = UIS:GetMouseLocation()
    local nearestPart, nearestDist = nil, math.huge
    local parts = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
        "HumanoidRootPart"
    }
    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part then
            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(m.X, m.Y)).Magnitude
                if dist < nearestDist then nearestDist = dist nearestPart = part end
            end
        end
    end
    return nearestPart
end

local function getTargetPosition(player, character)
    if not character then return nil end
    if _G.KnockCheck and isKnocked(character) then return nil end
    if aimPart == "Closest Point" then
        local part = getClosestPartToMouse(character)
        if part then return part.Position end
    else
        local part = character:FindFirstChild(aimPart) or character:FindFirstChild("HumanoidRootPart")
        if part then return part.Position end
    end
    return nil
end

local function setupKnockTracking(player)
    local function onKnockChanged()
        local character = player.Character
        if not character then return end
        local bodyEffects = character:FindFirstChild("BodyEffects")
        if not bodyEffects then return end
        local KO = bodyEffects:FindFirstChild("K.O")
        if not KO then return end
        if KO.Value then
            local part = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            if part then _G.DeathPositions[player] = part.Position end
        else
            _G.DeathPositions[player] = nil
        end
    end
    player.CharacterAdded:Connect(function(char)
        local bodyEffects = char:WaitForChild("BodyEffects", 5)
        if bodyEffects then
            local KO = bodyEffects:WaitForChild("K.O", 5)
            if KO then
                KO:GetPropertyChangedSignal("Value"):Connect(onKnockChanged)
                if KO.Value then
                    local part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                    if part then _G.DeathPositions[player] = part.Position end
                end
            end
        end
    end)
end

for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then setupKnockTracking(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr ~= LocalPlayer then setupKnockTracking(plr) end end)
Players.PlayerRemoving:Connect(function(plr) _G.DeathPositions[plr] = nil end)

local function getClosest()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local best, bestDist = nil, _G.FOV_RADIUS
    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer or (_G.Whitelist and _G.Whitelist[v.UserId]) then continue end
        local char = v.Character; if not char then continue end
        local targetPos = getTargetPosition(v, char); if not targetPos then continue end
        local screenPos, onScreen = cam:WorldToScreenPoint(targetPos)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < bestDist then
                if _G.WallCheck then
                    local ray = Ray.new(cam.CFrame.Position, (targetPos - cam.CFrame.Position).Unit * 500)
                    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, cam})
                    if hit and hit:IsDescendantOf(char) then bestDist = dist; best = targetPos end
                else
                    bestDist = dist; best = targetPos
                end
            end
        end
    end
    return best
end

local handler, oldFunc = nil, nil
pcall(function()
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    if modules then
        local gunHandler = modules:FindFirstChild("GunHandler")
        if gunHandler then
            handler = require(gunHandler)
            if handler and handler.getAim then oldFunc = handler.getAim end
        end
    end
end)

if handler and oldFunc then
    handler.getAim = function(origin, maxDist)
        -- v2.101 Force Hit bridge: when a Force Hit shot is armed, let the
        -- game's own gun handler aim that real weapon shot at the chosen part.
        local forcedPart = rawget(_G, "KimqForceHitPart")
        local forcedUntil = tonumber(rawget(_G, "KimqForceHitUntil")) or 0
        if forcedPart and forcedPart.Parent and os.clock() <= forcedUntil then
            local forcedPos = rawget(_G, "KimqForceHitPosition")
            if typeof(forcedPos) ~= "Vector3" then forcedPos = forcedPart.Position end
            local delta = forcedPos - origin
            if delta.Magnitude > 0.001 then
                return delta.Unit, math.min(delta.Magnitude, maxDist or 200)
            end
        end

        if not _G.SilentAimEnabled then return oldFunc(origin, maxDist) end
        if _G.RevolverBypass then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and (tool.Name == "[Revolver]" or tool.Name == "Revolver") then return oldFunc(origin, maxDist) end
        end
        local targetPos = getClosest()
        if targetPos then return (targetPos - origin).Unit, math.min((targetPos - origin).Magnitude, maxDist or 200) end
        return oldFunc(origin, maxDist)
    end
end

local function getKeyCode(keyName)
    local keyMap = {
        A = Enum.KeyCode.A, B = Enum.KeyCode.B, C = Enum.KeyCode.C,
        D = Enum.KeyCode.D, E = Enum.KeyCode.E, F = Enum.KeyCode.F,
        G = Enum.KeyCode.G, H = Enum.KeyCode.H, I = Enum.KeyCode.I,
        J = Enum.KeyCode.J, K = Enum.KeyCode.K, L = Enum.KeyCode.L,
        M = Enum.KeyCode.M, N = Enum.KeyCode.N, O = Enum.KeyCode.O,
        P = Enum.KeyCode.P, Q = Enum.KeyCode.Q, R = Enum.KeyCode.R,
        S = Enum.KeyCode.S, T = Enum.KeyCode.T, U = Enum.KeyCode.U,
        V = Enum.KeyCode.V, W = Enum.KeyCode.W, X = Enum.KeyCode.X,
        Y = Enum.KeyCode.Y, Z = Enum.KeyCode.Z,
    }
    return keyMap[keyName] or Enum.KeyCode[keyName] or Enum.KeyCode.V
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

local function isPartVisible(origin, targetPart, ignoreList)
    if not origin or not targetPart then return false end
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    local filter = {LocalPlayer.Character}
    if ignoreList then for _, v in ipairs(ignoreList) do table.insert(filter, v) end end
    raycastParams.FilterDescendantsInstances = filter
    local result = workspace:Raycast(origin, direction * distance, raycastParams)
    if not result then return true end
    return result.Instance == targetPart or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetClosestPointOnPart(Part, Scale)
    local PartCFrame = Part.CFrame
    local PartSize = Part.Size
    local PartSizeTransformed = PartSize * (Scale / 2)
    local MousePosition = UIS:GetMouseLocation()
    local CurrentCamera = Workspace.CurrentCamera
    local MouseRay = CurrentCamera:ViewportPointToRay(MousePosition.X, MousePosition.Y)
    local Transformed = PartCFrame:PointToObjectSpace(MouseRay.Origin + (MouseRay.Direction * MouseRay.Direction:Dot(PartCFrame.Position - MouseRay.Origin)))
    if mouse.Target == Part then return Vector3.new(mouse.Hit.X, mouse.Hit.Y, mouse.Hit.Z) end
    return PartCFrame * Vector3.new(
        math.clamp(Transformed.X, -PartSizeTransformed.X, PartSizeTransformed.X),
        math.clamp(Transformed.Y, -PartSizeTransformed.Y, PartSizeTransformed.Y),
        math.clamp(Transformed.Z, -PartSizeTransformed.Z, PartSizeTransformed.Z)
    )
end

local function GetClosestPointOnPartBasic(Part)
    if Part then
        local MouseRay = mouse.UnitRay
        MouseRay = MouseRay.Origin + (MouseRay.Direction * (Part.Position - MouseRay.Origin).Magnitude)
        local Point = (MouseRay.Y >= (Part.Position - Part.Size / 2).Y and MouseRay.Y <= (Part.Position + Part.Size / 2).Y) and (Part.Position + Vector3.new(0, -Part.Position.Y + MouseRay.Y, 0)) or Part.Position
        local Check = RaycastParams.new()
        Check.FilterType = Enum.RaycastFilterType.Whitelist
        Check.FilterDescendantsInstances = {Part}
        local Ray = Workspace:Raycast(MouseRay, (Point - MouseRay), Check)
        if mouse.Target == Part then return mouse.Hit.Position end
        if Ray then return Ray.Position else return mouse.Hit.Position end
    end
end

local function GetCamlockHitPosition(Target)
    if not Target or not Target.Character then return nil end
    local Character = Target.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return nil end
    local NearestPart = getClosestPartToMouse(Character)
    if not NearestPart then return nil end
    local HitPosition
    if _G.CamlockHitPart == "Closest Point" then
        if _G.CamlockClosestPointMode == "Default" then
            HitPosition = GetClosestPointOnPart(NearestPart, _G.CamlockClosestPointScale)
        else
            HitPosition = GetClosestPointOnPartBasic(NearestPart)
        end
    elseif _G.CamlockHitPart == "Closest Part" then
        HitPosition = NearestPart.Position
    else
        local part = Character:FindFirstChild(_G.CamlockHitPart)
        HitPosition = part and part.Position
    end
    if not HitPosition then return nil end
    if _G.CamlockPredictionEnabled then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            local Velocity = RootPart.Velocity
            local PredictionVector = Vector3.new(_G.CamlockPredictionX, _G.CamlockPredictionY, _G.CamlockPredictionZ)
            HitPosition = HitPosition + Velocity * PredictionVector
        end
    end
    return HitPosition
end

local function GetBestCamlockTarget()
    local Closest = nil
    local Distance = _G.CamlockFOVRadius > 0 and _G.CamlockFOVRadius or math.huge
    local MousePosition = UIS:GetMouseLocation()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if not Player.Character then continue end
        local Character = Player.Character
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then continue end
        local Position, OnScreen = cam:WorldToViewportPoint(HumanoidRootPart.Position)
        if not OnScreen then continue end
        if _G.CamlockConditionsForceField and Character:FindFirstChild("Forcefield") then continue end
        if _G.CamlockConditionsVisible then
            local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if localHead and not isPartVisible(localHead.Position, HumanoidRootPart, {Character}) then continue end
        end
        if _G.CamlockConditionsCarried and IsGrabbed(Player) then continue end
        if _G.CamlockConditionsKnocked and IsKnocked(Character) then continue end
        if _G.CamlockConditionsSelfKnocked and IsKnocked(LocalPlayer.Character) then continue end
        local Magnitude = (Vector2.new(Position.X, Position.Y) - MousePosition).Magnitude
        if Magnitude < Distance then Closest = Player Distance = Magnitude end
    end
    return Closest
end

local Camlock = {
    Target = nil,
    Active = false,
    Connection = nil,
    ResumeAfterRespawn = false,
}

local function IsHoldingGun()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    if tool:FindFirstChild("Ammo") then return true end
    if tool:FindFirstChild("Magazine") then return true end
    local gunModule = ReplicatedStorage:FindFirstChild("Modules")
    if gunModule then
        local gunHandler = gunModule:FindFirstChild("GunHandler")
        if gunHandler then
            local success, module = pcall(function() return require(gunHandler) end)
            if success and module and module.getGun then
                local success2, gun = pcall(function() return module.getGun(tool) end)
                if success2 and gun then return true end
            end
        end
    end
    return false
end

local function UpdateCamlock()
    if not _G.CamlockEnabled then
        Camlock.Active = false
        Camlock.Target = nil
        return
    end
    if _G.CamlockAutoToggle then
        if not IsHoldingGun() then
            Camlock.Active = false
            Camlock.Target = nil
            return
        end
        if not Camlock.Active or not Camlock.Target or not Camlock.Target.Character then
            local target = GetBestCamlockTarget()
            if target then
                Camlock.Target = target
                Camlock.Active = true
                Camlock.ResumeAfterRespawn = true
            else
                Camlock.Active = false
                Camlock.Target = nil
            end
            return
        end
    else
        if not Camlock.Active then return end
    end
    if not Camlock.Active then return end
    if not Camlock.Target or not Camlock.Target.Character then Camlock.Active = false return end
    local Character = Camlock.Target.Character
    if not Character:FindFirstChild("HumanoidRootPart") then Camlock.Active = false return end
    if _G.CamlockConditionsForceField and Character:FindFirstChild("Forcefield") then return end
    if _G.CamlockConditionsKnocked and IsKnocked(Character) then return end
    if _G.CamlockConditionsSelfKnocked and IsKnocked(LocalPlayer.Character) then return end
    if _G.CamlockConditionsCarried and IsGrabbed(Camlock.Target) then return end
    local HitPosition = GetCamlockHitPosition(Camlock.Target)
    if not HitPosition then return end
    local Smoothing = _G.CamlockSmoothness
    if _G.CamlockPullStrengthEnabled then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            local VelocityMagnitude = RootPart.Velocity.Magnitude
            if VelocityMagnitude > 15 then Smoothing = _G.CamlockPullStrengthMoveValue
            else Smoothing = _G.CamlockPullStrengthBaseValue end
        end
    end
    local EasedSmoothing = TweenService:GetValue(Smoothing, Enum.EasingStyle[_G.CamlockEasingStyle], Enum.EasingDirection[_G.CamlockEasingDirection])
    cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, HitPosition), EasedSmoothing)
end

local function EnableCamlock()
    if not _G.CamlockEnabled then return end
    local target = GetBestCamlockTarget()
    if target then
        Camlock.Target = target
        Camlock.Active = true
        Camlock.ResumeAfterRespawn = true
        if not Camlock.Connection then Camlock.Connection = RunService.RenderStepped:Connect(UpdateCamlock) end
    end
end

local function DisableCamlock()
    Camlock.Active = false
    Camlock.ResumeAfterRespawn = false
    Camlock.Target = nil
end

if not Camlock.Connection then Camlock.Connection = RunService.RenderStepped:Connect(UpdateCamlock) end

local oldMouseIndex_HC = nil
local function enableHCSilentAim(enable)
    _G.HCSilentAimEnabled = not not enable
    if type(hookmetamethod) ~= "function" or type(checkcaller) ~= "function" then
        if not _G.ForceHitEnabled then _G.HCSilentAimEnabled = false end
        return
    end

    -- Keep one mouse hook alive whenever either HC Silent Aim OR Force Hit
    -- needs it. This prevents toggling one feature from breaking the other.
    local shouldHook = _G.HCSilentAimEnabled or _G.ForceHitEnabled or os.clock() <= (tonumber(rawget(_G, "KimqForceHitUntil")) or 0)

    if shouldHook then
        if oldMouseIndex_HC then return end
        oldMouseIndex_HC = hookmetamethod(game, "__index", function(self, idx)
            if not checkcaller() and self == mouse and (idx == "Hit" or idx == "Target") then
                -- Force Hit gets first priority only for the tiny window in
                -- which a real weapon shot is being fired.
                local forcedPart = rawget(_G, "KimqForceHitPart")
                local forcedUntil = tonumber(rawget(_G, "KimqForceHitUntil")) or 0
                if forcedPart and forcedPart.Parent and os.clock() <= forcedUntil then
                    if idx == "Target" then return forcedPart end
                    local forcedPos = rawget(_G, "KimqForceHitPosition")
                    if typeof(forcedPos) ~= "Vector3" then forcedPos = forcedPart.Position end
                    return CFrame.new(forcedPos)
                end

                if _G.HCSilentAimEnabled then
                    local mousePos = Vector2.new(mouse.X, mouse.Y)
                    local targetPart = nil
                    local targetChar = nil
                    local bestDist = _G.HCFOVRadius
                    local HC_HIT_PARTS = {
                        "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso",
                        "LeftUpperArm", "LeftLowerArm", "LeftHand",
                        "RightUpperArm", "RightLowerArm", "RightHand",
                        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
                        "RightUpperLeg", "RightLowerLeg", "RightFoot",
                    }
                    for _, v in pairs(Players:GetPlayers()) do
                        if v == LocalPlayer then continue end
                        local char = v.Character
                        if not char then continue end
                        local hum = char:FindFirstChild("Humanoid")
                        if hum and hum.Health <= 0 then continue end
                        if _G.HCKnockCheck then
                            local bodyEffects = char:FindFirstChild("BodyEffects")
                            if bodyEffects and bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value then continue end
                        end
                        if _G.Whitelist and _G.Whitelist[v.UserId] then continue end
                        for _, partName in ipairs(HC_HIT_PARTS) do
                            local part = char:FindFirstChild(partName)
                            if part then
                                local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
                                if onScreen then
                                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                    if dist < bestDist then
                                        bestDist = dist
                                        targetPart = part
                                        targetChar = char
                                    end
                                end
                            end
                        end
                    end
                    if targetPart and targetChar then
                        return (idx == "Hit" and CFrame.new(targetPart.Position) or targetChar:FindFirstChild("HumanoidRootPart"))
                    end
                end
            end
            return oldMouseIndex_HC(self, idx)
        end)
    elseif oldMouseIndex_HC then
        hookmetamethod(game, "__index", oldMouseIndex_HC)
        oldMouseIndex_HC = nil
    end
end

-- v2.101 Force Hit rebuild.
-- The old version forged a hard-coded MainEvent "Shoot" payload. That packet
-- can be ignored by the server/game when its weapon protocol changes, which
-- made Force Hit appear to fire while doing no real weapon damage.
-- This version arms a short aim override and then lets the equipped Tool use
-- its own normal firing code / remotes / ammo / cooldowns.
local ForceHit = {
    HighlightLine = SafeDrawing("Line"),
    IsHoldingMouse = false,
    LastFireTime = 0,
    BurstToken = 0,
    AllowedTools = {
        "[DoubleBarrel]", "[Revolver]", "[Shotgun]",
        "[SMG]", "[Silencer]", "[TacticalShotgun]"
    },
    WeaponProfiles = {
        ["[Revolver]"]={delay=.115,part="Head"},
        ["[DoubleBarrel]"]={delay=.155,part="UpperTorso"},
        ["[Shotgun]"]={delay=.150,part="UpperTorso"},
        ["[TacticalShotgun]"]={delay=.105,part="UpperTorso"},
        ["[SMG]"]={delay=.055,part="UpperTorso"},
        ["[Silencer]"]={delay=.070,part="Head"},
    }
}
ForceHit.HighlightLine.Thickness = 1.5
ForceHit.HighlightLine.Color = Color3.fromRGB(165, 201, 255)
ForceHit.HighlightLine.Transparency = 0.3
ForceHit.HighlightLine.Visible = false

function ForceHit.IsWeaponTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if table.find(ForceHit.AllowedTools, tool.Name) then return true end

    local low = string.lower(tostring(tool.Name or ""))
    if low:find("angel wing", 1, true) or low:find("knife", 1, true)
        or low:find("wallet", 1, true) or low:find("phone", 1, true)
        or low:find("food", 1, true) then
        return false
    end

    for _, name in ipairs({"Clip","Magazine","Mag","CurrentAmmo","Ammo","Bullets"}) do
        local o = tool:FindFirstChild(name, true)
        if o and (o:IsA("IntValue") or o:IsA("NumberValue") or o:IsA("StringValue")) then
            return true
        end
        local attr = nil
        pcall(function() attr = tool:GetAttribute(name) end)
        if type(attr) == "number" then return true end
    end

    return low:find("gun",1,true) ~= nil or low:find("pistol",1,true) ~= nil
        or low:find("revolver",1,true) ~= nil or low:find("shotgun",1,true) ~= nil
        or low:find("smg",1,true) ~= nil or low:find("rifle",1,true) ~= nil
        or low:find("silencer",1,true) ~= nil or low:find("drum",1,true) ~= nil
        or low:find("glock",1,true) ~= nil or low:find("uzi",1,true) ~= nil
end

function ForceHit.GetFireDelay(tool)
    local p = tool and ForceHit.WeaponProfiles[tool.Name]
    return math.max(0.045, tonumber(p and p.delay) or tonumber(_G.ForceHitFireRate) or 0.067)
end

function ForceHit.GetAmmo(tool)
    if not tool then return nil end
    for _, name in ipairs({"Clip","Magazine","Mag","CurrentAmmo","Ammo","Bullets"}) do
        local o = tool:FindFirstChild(name, true)
        if o then
            if o:IsA("IntValue") or o:IsA("NumberValue") then return tonumber(o.Value) end
            if o:IsA("StringValue") then
                local n = tonumber(tostring(o.Value):match("%-?%d+%.?%d*"))
                if n ~= nil then return n end
            end
        end
        local attr = nil
        pcall(function() attr = tool:GetAttribute(name) end)
        if type(attr) == "number" then return attr end
    end
    return nil
end

function ForceHit.TryReload(tool)
    if not _G.ForceHitAutoReload or not tool then return false end
    local ammo = ForceHit.GetAmmo(tool)
    if ammo == nil or ammo > 0 then return false end
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(.025)
        vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)
    local ev = ReplicatedStorage:FindFirstChild("MainEvent")
    if ev and ev:IsA("RemoteEvent") then pcall(function() ev:FireServer("Reload", tool) end) end
    return true
end

function ForceHit.GetLiveFinishPart(pl, tool)
    if not pl or not pl.Character then return nil end
    local profile = tool and ForceHit.WeaponProfiles[tool.Name]
    local wanted = profile and profile.part or tostring(_G.HCHitPart or "Head")
    if wanted == "Closest Point" then wanted = "Head" end
    local part = pl.Character:FindFirstChild(wanted)
        or pl.Character:FindFirstChild("UpperTorso")
        or pl.Character:FindFirstChild("HumanoidRootPart")
        or pl.Character:FindFirstChild("Head")
    if not part or not part:IsA("BasePart") then return nil end
    local _, onScreen = cam:WorldToScreenPoint(part.Position)
    if not onScreen or not ForceHit.HasLineOfSight(pl, part) then return nil end
    return part
end

function ForceHit.TargetFinished(pl)
    if not pl or not pl.Character then return true end
    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    return isKnocked(pl.Character) == true
end

function ForceHit.IsValidTarget(pl)
    if not pl or pl == LocalPlayer then return false end
    if _G.Whitelist and _G.Whitelist[pl.UserId] then return false end
    local char = pl.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if (_G.HCKnockCheck or _G.KnockCheck) and isKnocked(char) then return false end
    return true
end

function ForceHit.GetClosestPartToMouse(pl)
    local char = pl and pl.Character
    if not char then return nil end

    -- Honor the HC hit-part selector when it names a real body part.
    local preferred = tostring(_G.HCHitPart or "")
    if preferred ~= "" and preferred ~= "Closest Point" then
        local chosen = char:FindFirstChild(preferred)
        if chosen and chosen:IsA("BasePart") then
            local p, on = cam:WorldToScreenPoint(chosen.Position)
            if on then return chosen end
        end
    end

    -- ScreenPoint + mouse.X/Y are the same coordinate space. The old code
    -- mixed GetMouseLocation with ViewportPoint, which could offset the FOV.
    local m = Vector2.new(mouse.X, mouse.Y)
    local nearestPart, nearestDist = nil, math.huge
    for _, name in ipairs(HCForceHitParts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - m).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPart = part
                end
            end
        end
    end
    return nearestPart
end

function ForceHit.HasLineOfSight(pl, part)
    if not _G.HCWallCheck then return true end
    if not pl or not pl.Character or not part then return false end
    local origin = cam.CFrame.Position
    local direction = part.Position - origin
    if direction.Magnitude < 0.01 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, cam}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, params)
    return not result or (result.Instance and result.Instance:IsDescendantOf(pl.Character))
end

function ForceHit.GetFovTarget()
    local m = Vector2.new(mouse.X, mouse.Y)
    local bestPart, bestDist = nil, tonumber(_G.ForceHitFOV) or 100
    for _, pl in ipairs(Players:GetPlayers()) do
        if ForceHit.IsValidTarget(pl) then
            local part = ForceHit.GetClosestPartToMouse(pl)
            if part and ForceHit.HasLineOfSight(pl, part) then
                local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - m).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPart = part
                    end
                end
            end
        end
    end
    return bestPart
end

function ForceHit.GetManualTarget()
    -- Manual mode means the real cursor must actually be on that character.
    local rawTarget = nil
    if oldMouseIndex_HC then pcall(function() rawTarget = oldMouseIndex_HC(mouse, "Target") end) end
    if not rawTarget then pcall(function() rawTarget = mouse.Target end) end
    if not rawTarget then return nil end
    local model = rawTarget:FindFirstAncestorOfClass("Model")
    local pl = model and Players:GetPlayerFromCharacter(model)
    if not ForceHit.IsValidTarget(pl) then return nil end
    local part = ForceHit.GetClosestPartToMouse(pl)
    if part and ForceHit.HasLineOfSight(pl, part) then return part end
    return nil
end

function ForceHit.GetTarget()
    if _G.ForceHitMode == "Manual" then return ForceHit.GetManualTarget() end
    return ForceHit.GetFovTarget()
end

function ForceHit.GetBarrelPosition()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local h = tool:FindFirstChild("Handle") or tool:FindFirstChild("Barrel") or tool:FindFirstChild("Muzzle")
        if h and h:IsA("BasePart") then return h.Position end
    end
    local arm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
    if arm and arm:IsA("BasePart") then return arm.Position end
    return char:GetPivot().Position
end

function ForceHit.SpawnTracer(startPos, endPos)
    if (endPos - startPos).Magnitude < 0.1 then return end
    local beam = Instance.new("Beam")
    local attach0 = Instance.new("Attachment")
    local attach1 = Instance.new("Attachment")
    beam.Segments = 1
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 200, 0))
    beam.Transparency = NumberSequence.new(0.4)
    beam.FaceCamera = true
    attach0.Position = startPos
    attach1.Position = endPos
    attach0.Parent = workspace.Terrain
    attach1.Parent = workspace.Terrain
    beam.Attachment0 = attach0
    beam.Attachment1 = attach1
    beam.Parent = workspace.Terrain
    task.delay(0.08, function()
        pcall(function() beam:Destroy() end)
        pcall(function() attach0:Destroy() end)
        pcall(function() attach1:Destroy() end)
    end)
end

function ForceHit.Prime(targetPart, life)
    if not targetPart or not targetPart.Parent then return false end
    local pos = targetPart.Position
    if _G.HCPrediction then
        local velocity = Vector3.zero
        pcall(function() velocity = targetPart.AssemblyLinearVelocity end)
        pos += velocity * (tonumber(_G.HCPredictionAmount) or 0)
    end
    _G.KimqForceHitPart = targetPart
    _G.KimqForceHitPosition = pos
    _G.KimqForceHitUntil = os.clock() + math.clamp(tonumber(life) or 0.24, 0.08, 0.5)
    return true
end

function ForceHit.Fire(targetPart, tool)
    if not targetPart or not targetPart.Parent then return false end
    local char = LocalPlayer.Character
    tool = tool or (char and char:FindFirstChildOfClass("Tool"))
    if not ForceHit.IsWeaponTool(tool) then return false end
    if not ForceHit.Prime(targetPart, 0.28) then return false end
    -- RAGE can use this engine even when the standalone Force Hit toggle is
    -- off, so make sure the passive mouse redirect hook exists for this shot.
    enableHCSilentAim(_G.HCSilentAimEnabled)

    if _G.ForceHitTracerEnabled then
        local barrelPos = ForceHit.GetBarrelPosition()
        local endPos = rawget(_G, "KimqForceHitPosition") or targetPart.Position
        if barrelPos then ForceHit.SpawnTracer(barrelPos, endPos) end
    end

    -- Use the weapon's real Activated path instead of manufacturing a
    -- game-specific Shoot remote payload.
    local ok = pcall(function() tool:Activate() end)
    return ok
end

function ForceHit.RunOneClickFinish(pl, tool)
    if not _G.ForceHitOneClickFinish or not pl or not tool then return end
    ForceHit.BurstToken += 1
    local token = ForceHit.BurstToken
    local total = math.clamp(math.floor(tonumber(_G.ForceHitFinishShots) or 6), 2, 10)
    task.spawn(function()
        -- The user's normal click is shot #1. Follow-ups are only sent if the
        -- same target is still alive/not K.O. after that real weapon shot.
        task.wait(ForceHit.GetFireDelay(tool))
        for _ = 2, total do
            if token ~= ForceHit.BurstToken or not _G.ForceHitEnabled then break end
            if ForceHit.TargetFinished(pl) then break end
            if not tool.Parent or not ForceHit.IsWeaponTool(tool) then break end

            local ammo = ForceHit.GetAmmo(tool)
            if ammo ~= nil and ammo <= 0 then
                if not ForceHit.TryReload(tool) then break end
                local deadline = os.clock() + 2.2
                repeat
                    task.wait(.07)
                    if token ~= ForceHit.BurstToken then return end
                    ammo = ForceHit.GetAmmo(tool)
                until ammo == nil or ammo > 0 or os.clock() >= deadline
                if ammo ~= nil and ammo <= 0 then break end
            end

            local hit = ForceHit.GetLiveFinishPart(pl, tool)
            if not hit then break end
            ForceHit.Fire(hit, tool)
            task.wait(ForceHit.GetFireDelay(tool))
        end
    end)
end

function ForceHit.MouseClick(action, state, input)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    if not _G.ForceHitEnabled then return Enum.ContextActionResult.Pass end
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not ForceHit.IsWeaponTool(tool) then return Enum.ContextActionResult.Pass end

    local part = ForceHit.GetTarget()
    if part then
        -- Prime BEFORE the game's normal click reaches the equipped Tool.
        -- Return Pass so the actual weapon script still performs shot #1.
        ForceHit.Prime(part, 0.34)
        ForceHit.LastFireTime = tick()
        if _G.ForceHitTracerEnabled then
            local barrelPos = ForceHit.GetBarrelPosition()
            if barrelPos then
                local endPos = rawget(_G, "KimqForceHitPosition") or part.Position
                ForceHit.SpawnTracer(barrelPos, endPos)
            end
        end
        -- A literal one-bullet kill cannot be forced when damage is server-side.
        -- One Click Finish instead confirms the same target with real follow-up
        -- weapon activations only until they are K.O./dead, then immediately stops.
        if _G.ForceHitOneClickFinish and not _G.ForceHitFullAutoEnabled then
            local pl = Players:GetPlayerFromCharacter(part.Parent)
            if pl then ForceHit.RunOneClickFinish(pl, tool) end
        end
    end
    return Enum.ContextActionResult.Pass
end

pcall(function() CAS:UnbindAction("NHForceHit") end)
if CAS.BindActionAtPriority then
    CAS:BindActionAtPriority(
        "NHForceHit",
        ForceHit.MouseClick,
        false,
        Enum.ContextActionPriority.High.Value + 50,
        Enum.UserInputType.MouseButton1
    )
else
    CAS:BindAction("NHForceHit", ForceHit.MouseClick, false, Enum.UserInputType.MouseButton1)
end

local function getFlameTarget()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local closestPart = nil
    local closestDist = math.huge
    
    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        if _G.Whitelist and _G.Whitelist[v.UserId] then continue end
        local char = v.Character
        if not char then continue end
        
        local part = char:FindFirstChild(_G.FlameHitPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        
        local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPart = part
            end
        end
    end
    
    return closestPart
end

local flameTargetPart = nil

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then ForceHit.IsHoldingMouse = true end
    if gameProcessed then return end
    if _G.CamlockEnabled and not _G.CamlockAutoToggle then
        local camlockKey = getKeyCode(_G.CamlockToggleKey)
        if input.KeyCode == camlockKey then
            if _G.CamlockMode == "Toggle" then
                if Camlock.Active then DisableCamlock() else EnableCamlock() end
            elseif _G.CamlockMode == "Hold" then EnableCamlock() end
        end
    end
    if input.KeyCode == _G.UIToggleKey then
        _G.UIVisible = not _G.UIVisible
        -- old KIM window removed in Kimpetras merge
    end
    if _G.FlamelockEnabled then
        local isTriggered = (_G.FlameRightClick and input.UserInputType == Enum.UserInputType.MouseButton2) or (not _G.FlameRightClick and input.KeyCode == _G.FlameKey)
        if isTriggered then
            if _G.FlameMode == "Hold" then
                _G.FlameActive = true
            else
                _G.FlameActive = not _G.FlameActive
            end
            if _G.FlameActive then
                local target = getFlameTarget()
                if target then
                    flameTargetPart = target
                else
                    _G.FlameActive = false
                    flameTargetPart = nil
                end
            else
                flameTargetPart = nil
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then ForceHit.IsHoldingMouse = false end
    if _G.CamlockEnabled and not _G.CamlockAutoToggle then
        local camlockKey = getKeyCode(_G.CamlockToggleKey)
        if input.KeyCode == camlockKey and _G.CamlockMode == "Hold" then DisableCamlock() end
    end
    if _G.FlamelockEnabled and _G.FlameMode == "Hold" then
        local isTriggered = (_G.FlameRightClick and input.UserInputType == Enum.UserInputType.MouseButton2) or (not _G.FlameRightClick and input.KeyCode == _G.FlameKey)
        if isTriggered then
            _G.FlameActive = false
            flameTargetPart = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Camlock.Target == player then DisableCamlock() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    -- v2.62: dying no longer clears the COMBAT Camlock target.
    -- Keep the exact selected Player object and resume the same lock after
    -- our new character finishes spawning.
    local savedTarget = Camlock.Target
    local shouldResume = Camlock.ResumeAfterRespawn and savedTarget ~= nil

    Camlock.Active = false

    task.delay(.40, function()
        if shouldResume
            and _G.CamlockEnabled
            and savedTarget
            and savedTarget.Parent == Players
        then
            Camlock.Target = savedTarget
            Camlock.Active = true
            Camlock.ResumeAfterRespawn = true
        end
    end)

    if headlessActive then
        local char = LocalPlayer.Character
        if char then
            local head = char:WaitForChild("Head", 5)
            if head then head.Transparency = 1 end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    -- This backend loop is only needed while Force Hit full-auto is actively firing.
    if not (_G.ForceHitFullAutoEnabled and ForceHit.IsHoldingMouse and _G.ForceHitEnabled) then return end
    do
        local now = tick()
        if now - ForceHit.LastFireTime < _G.ForceHitFireRate then return end
        ForceHit.LastFireTime = now
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not ForceHit.IsWeaponTool(tool) then return end
        local part = ForceHit.GetTarget()
        if part then ForceHit.Fire(part, tool) end
    end
end)

RunService.RenderStepped:Connect(function()
    if _G.ForceHitEnabled and _G.ForceHitMode == "Manual" then
        local part = ForceHit.GetManualTarget()
        if part then
            local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
            if onScreen then
                ForceHit.HighlightLine.From = Vector2.new(mouse.X, mouse.Y)
                ForceHit.HighlightLine.To = Vector2.new(screenPos.X, screenPos.Y)
                ForceHit.HighlightLine.Visible = true
            else
                ForceHit.HighlightLine.Visible = false
            end
        else
            ForceHit.HighlightLine.Visible = false
        end
    else
        ForceHit.HighlightLine.Visible = false
    end
end)

local _0x9ba38e
if type(hookfunction) == "function" and type(checkcaller) == "function" then
    pcall(function()
        _0x9ba38e = hookfunction(math.random, function(...)
            local args = {...}
            if checkcaller() then return _0x9ba38e(...) end
            if (#args == 0) or (args[1] == -0.05 and args[2] == 0.05) or (args[1] == -0.1) or (args[1] == -0.05) then
                if BulletSpreadSettings.Enabled then return _0x9ba38e(...) * (_G.BulletSpreadAmount / 100) end
            end
            return _0x9ba38e(...)
        end)
    end)
end

local function createESP(plr)
    if espObjects[plr] then return end
    local box = SafeDrawing("Square") box.Thickness = 1 box.Filled = false box.Color = _G.ESP_Color box.Visible = false
    local name = SafeDrawing("Text") name.Size = 13 name.Center = true name.Outline = true name.Color = _G.ESP_Color name.Visible = false
    local health = SafeDrawing("Text") health.Size = 13 health.Center = false health.Outline = true health.Color = Color3.fromRGB(50, 255, 50) health.Visible = false
    local distance = SafeDrawing("Text") distance.Size = 12 distance.Center = true distance.Outline = true distance.Color = Color3.fromRGB(200, 200, 200) distance.Visible = false
    local tracer = SafeDrawing("Line") tracer.Thickness = 1 tracer.Color = _G.ESP_Color tracer.Visible = false
    local skeleton = {}
    espObjects[plr] = {Box = box, Name = name, Health = health, Distance = distance, Tracer = tracer, Skeleton = skeleton}
end

-- Duplicate legacy ESP renderer disabled. The visible ESP page uses ExtraESP only.

local fovCircle = SafeDrawing("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 60
fovCircle.Radius = _G.FOV_RADIUS
fovCircle.Filled = false
fovCircle.Color = ColorPresets[_G.CurrentTheme].AccentColor
fovCircle.Visible = false

-- Lightweight visual loop: FOV + Flamelock only.
-- The second hidden ESP renderer and per-frame FPS-cap call were removed.
RunService.RenderStepped:Connect(function()
    local needFov = _G.ShowFOV == true
    local needFlame = _G.FlamelockEnabled and _G.FlameActive
    if not needFov then fovCircle.Visible = false end
    if not needFov and not needFlame then return end

    if needFov then
        fovCircle.Radius = _G.FOV_RADIUS
        local currentTheme = ColorPresets[_G.CurrentTheme] or ColorPresets["Cinnamoroll"]
        fovCircle.Color = currentTheme.AccentColor
        fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovCircle.Visible = true
    end

    if needFlame then
        if not flameTargetPart or not flameTargetPart.Parent then
            local target = getFlameTarget()
            if target then
                flameTargetPart = target
            else
                _G.FlameActive = false
                return
            end
        end
        if flameTargetPart and flameTargetPart.Parent then
            local targetPlayer = Players:GetPlayerFromCharacter(flameTargetPart.Parent)
            if targetPlayer and not (_G.Whitelist and _G.Whitelist[targetPlayer.UserId]) then
                local predPos = flameTargetPart.Position + (flameTargetPart.Velocity * _G.FlamePrediction)
                local offsetPos = predPos + (cam.CFrame.RightVector * _G.FlameLeftOffset) + Vector3.new(0, _G.FlameUpOffset, 0)
                local sp, on = cam:WorldToViewportPoint(offsetPos)
                if on then
                    local deltaX = (sp.X - mouse.X) * _G.FlameSmoothness
                    local deltaY = (sp.Y - mouse.Y) * _G.FlameSmoothness
                    mousemoverel(deltaX, deltaY)
                end
            else
                flameTargetPart = nil
                _G.FlameActive = false
            end
        end
    end
end)

local CONFIG_ROOT = "KimqetrasHC"
local CONFIG_DIR = CONFIG_ROOT .. "/configs"
_G.KimqMemoryConfigs = _G.KimqMemoryConfigs or {}
local KimqMemoryConfigs = _G.KimqMemoryConfigs

local function notifyConfig(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "KIM ♡",
            Text = text,
            Duration = 3
        })
    end)
end

local function cleanConfigName(name)
    name = tostring(name or "")
    name = name:gsub("[%c/\\:*?\"<>|]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Kimqetras" end
    return name:sub(1, 48)
end

local function ensureConfigFolder()
    if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return false end
    pcall(function() if not isfolder(CONFIG_ROOT) then makefolder(CONFIG_ROOT) end end)
    pcall(function() if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end end)
    local ok, exists = pcall(isfolder, CONFIG_DIR)
    return ok and exists == true
end

local function configPath(name)
    return CONFIG_DIR .. "/" .. cleanConfigName(name) .. ".json"
end

local function serializable(v)
    local t = type(v)
    return t == "boolean" or t == "number" or t == "string"
end

-- JSON-safe deep copy for custom GUI state (avatar/accessories/fog/environment/skins).
-- This intentionally accepts only primitive values and tables made from them.
local function configSafeValue(v, depth)
    depth = depth or 0
    if depth > 8 then return nil end
    if serializable(v) then return v end
    if type(v) ~= "table" then return nil end
    local out = {}
    for k, child in pairs(v) do
        local kt=type(k)
        if kt=="string" or kt=="number" then
            local safe=configSafeValue(child, depth+1)
            if safe ~= nil then out[k]=safe end
        end
    end
    return out
end

local CONFIG_EXCLUDED_CONTROLS = {
    ["Fog / Atmosphere State"] = true,
    ["Atmosphere Preset"] = true,
    ["Reset Atmosphere"] = true,
    ["Color Correction"] = true,
    ["Saturation"] = true,
}

local function snapshotControls()
    local out = {}
    for name, entry in pairs(_G.KimqConfigControls or {}) do
        if not CONFIG_EXCLUDED_CONTROLS[name] and type(entry) == "table" and type(entry.get) == "function" then
            local ok, value = pcall(entry.get)
            if ok then
                local safe=configSafeValue(value)
                if safe ~= nil then out[name] = safe end
            end
        end
    end
    return out
end

local WHOLE_DIFFERENT_ANIMAL = "WholeDifferentAnimal"

local function applyConfigControlValue(name, value)
    local entry = (_G.KimqConfigControls or {})[name]
    if type(entry) == "table" and type(entry.set) == "function" then
        local ok = pcall(entry.set, value)
        return ok
    end
    return false
end

local function ApplyWholeDifferentAnimal()
    -- Personal built-in preset: strong, stable defaults without touching Avatar,
    -- themes, custom cursor art, saved outfits, whitelist, or RAGE target queue.
    local values = {
        ["Show FOV Circle"] = false,
        ["FOV Size"] = 185,
        ["Strict FOV"] = true,
        ["Hit Chance"] = 100,
        ["Target Stickiness"] = 42,
        ["Target Priority"] = "Closest Cursor",
        ["Bypass Revolver"] = false,
        ["Wall Check"] = true,
        ["Team Check"] = false,
        ["Knock Check"] = true,
        ["Hit Part"] = "Closest Point",
        ["Max Target Distance"] = 3000,
        ["Auto Prediction"] = true,
        ["Auto Prediction Strength"] = 1.00,
        ["HC Silent Aim"] = false,
        ["HC Revolver Bypass"] = false,
        ["HC Wall Check"] = true,
        ["HC Knock Check"] = true,
        ["HC FOV Radius"] = 200,
        ["HC Hit Part"] = "Head",
        ["HC Prediction"] = true,
        ["HC Prediction Amount"] = 0.165,
        ["Force Hit"] = true,
        ["Force Hit Mode"] = "Fov",
        ["Force Hit FOV"] = 200,
        ["Force Hit Tracer"] = false,
        ["Force Hit Full Auto"] = false,
        ["Force Hit Fire Rate"] = 0.067,
        ["Force Hit One Click Finish"] = true,
        ["Force Hit Finish Shots"] = 6,
        ["Force Hit Auto Reload"] = true,
        ["Macro / Speed Master"] = true,
        ["Macro Speed"] = 85,
        ["I / O Spam While Macroing"] = false,
        ["Anti Fall"] = true,
        ["Delay Changer"] = false,
        ["ESP"] = true,
        ["Box"] = true,
        ["Name"] = true,
        ["Distance"] = true,
        ["Health"] = true,
        ["Snapline"] = false,
        ["Skeleton"] = false,
        ["Random Camera Zoom"] = false,
        ["Shot Camera Swap"] = false,
        ["Hitbox Expander"] = false,
        ["Flamelock"] = false,
        ["Camlock Enabled"] = false,
        ["FPS Unlocker"] = true,
        ["Target FPS"] = 240,
    }
    for controlName, value in pairs(values) do applyConfigControlValue(controlName, value) end
    _G.BulletSpreadAmount = 0
    _G.KimqSelectedConfig = WHOLE_DIFFERENT_ANIMAL
    notifyConfig("WholeDifferentAnimal loaded ♡")
    if type(_G.KimqRefreshConfigList) == "function" then pcall(_G.KimqRefreshConfigList) end
    return true
end

_G.KimqApplyWholeDifferentAnimal = ApplyWholeDifferentAnimal

local function SaveConfig(configName)
    local name = cleanConfigName(configName)
    if name == WHOLE_DIFFERENT_ANIMAL then
        notifyConfig("WholeDifferentAnimal is a protected built-in preset ♡")
        return false
    end
    local configData = {
        format = "KimqetrasHC-v2.68-all-settings",
        name = name,
        controls = snapshotControls(),
        theme = tostring(_G.KimqCuteTheme or "Matcha Pink"),
        whitelist = {},
        backendWhitelist = {},
    }

    -- Freeze the exact CURRENT copied avatar into this config. The config does
    -- not depend on the source user keeping the same Roblox outfit later.
    if _G.KimqAvatarController and type(_G.KimqAvatarController.GetSnapshot)=="function" then
        local ok,snapshot=pcall(_G.KimqAvatarController.GetSnapshot)
        if ok and type(snapshot)=="table" then
            configData.avatarSnapshot=configSafeValue(snapshot)
        end
    end

    -- Fog is saved separately from normal controls so environment/theme setters
    -- cannot race it during load. This snapshot includes exact visible values.
    if _G.KimqFogController and type(_G.KimqFogController.GetState)=="function" then
        local ok, fogState = pcall(_G.KimqFogController.GetState)
        if ok then configData.fog = configSafeValue(fogState) end
    end

    for uid, value in pairs(_G.KHWhitelist or {}) do
        if value then configData.whitelist[tostring(uid)] = true end
    end
    for uid, value in pairs(_G.Whitelist or {}) do
        if value then configData.backendWhitelist[tostring(uid)] = true end
    end

    -- Save the current window size too, so a compact layout can be restored with a preset.
    pcall(function()
        local root = game:GetService("CoreGui"):FindFirstChild("KimpetrasHC") or LocalPlayer.PlayerGui:FindFirstChild("KimpetrasHC")
        local main = root and root:FindFirstChild("Main")
        if main then
            configData.window = {
                w = main.AbsoluteSize.X, h = main.AbsoluteSize.Y,
                x = main.AbsolutePosition.X, y = main.AbsolutePosition.Y
            }
        end
    end)

    local okJson, json = pcall(function() return game:GetService("HttpService"):JSONEncode(configData) end)
    if not okJson then notifyConfig("Could not save config") return false end

    local wrote = false
    if ensureConfigFolder() and type(writefile) == "function" then
        wrote = pcall(writefile, configPath(name), json)
    end
    if not wrote then KimqMemoryConfigs[name] = json end

    _G.KimqSelectedConfig = name
    notifyConfig("Saved config: " .. name)
    if type(_G.KimqRefreshConfigList) == "function" then pcall(_G.KimqRefreshConfigList) end
    return true
end

local function readConfigText(name)
    name = cleanConfigName(name)
    local path = configPath(name)
    if type(isfile) == "function" and type(readfile) == "function" then
        local okExists, exists = pcall(isfile, path)
        if okExists and exists then
            local ok, data = pcall(readfile, path)
            if ok and type(data) == "string" then return data end
        end
    end
    return KimqMemoryConfigs[name]
end

local function configValuesEqual(a,b,depth)
    depth=(depth or 0)+1
    if depth>8 then return false end
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not configValuesEqual(v,b[k],depth) then return false end end
    for k,_ in pairs(b) do if a[k]==nil then return false end end
    return true
end

local function LoadConfig(configName)
    local name = cleanConfigName(configName)
    if name == WHOLE_DIFFERENT_ANIMAL then return ApplyWholeDifferentAnimal() end
    local json = readConfigText(name)
    if not json then notifyConfig("Config not found: " .. name) return false end

    local okDecode, configData = pcall(function() return game:GetService("HttpService"):JSONDecode(json) end)
    if not okDecode or type(configData) ~= "table" then notifyConfig("That config could not be read") return false end

    -- New configs keep Fog / Atmosphere separate and apply it LAST. Older builds
    -- that happened to store it in controls are still supported as a fallback.
    local savedFogState = type(configData.fog)=="table" and configData.fog or
        (type(configData.controls)=="table" and configData.controls["Fog / Atmosphere State"] or nil)

    -- New v2.1 configs apply through registered control setters. This matters for
    -- local states such as MacroMaster/MacroSpeed: changing only _G would not update them.
    if type(configData.controls) == "table" then
        for controlName, value in pairs(configData.controls) do
            if not CONFIG_EXCLUDED_CONTROLS[controlName] then
                local entry = (_G.KimqConfigControls or {})[controlName]
                if type(entry) == "table" and type(entry.set) == "function" then
                    -- Do not fire expensive callbacks for settings that are already identical.
                    local same=false
                    if type(entry.get)=="function" then
                        local okCur,cur=pcall(entry.get)
                        if okCur then same=configValuesEqual(configSafeValue(cur),configSafeValue(value)) end
                    end
                    if not same then pcall(entry.set, value) end
                end
            end
        end
    else
        -- Compatibility with very old primitive-global configs.
        for k, v in pairs(configData) do
            if k ~= "Whitelist" and serializable(v) then _G[k] = v end
        end
    end

    if type(configData.whitelist) == "table" then
        table.clear(_G.KHWhitelist)
        for uid, value in pairs(configData.whitelist) do
            if value then _G.KHWhitelist[tonumber(uid) or uid] = true end
        end
    end
    if type(configData.backendWhitelist) == "table" then
        table.clear(_G.Whitelist)
        for uid, value in pairs(configData.backendWhitelist) do
            if value then _G.Whitelist[tonumber(uid) or uid] = true end
        end
    end

    if type(configData.theme) == "string" then
        -- Store it now; paint once at the end after controls finish restoring.
        _G.KimqCuteTheme = configData.theme
    end

    -- v2.67: configs store the avatar's HumanoidDescription snapshot. Loading it
    -- restores THAT saved look even if the source user has changed their avatar.
    if _G.KimqAvatarController then
        local savedAvatarSnapshot=type(configData.avatarSnapshot)=="table" and configData.avatarSnapshot or nil
        -- v2.82: restore the saved avatar NOW on the live character. The snapshot
        -- routine already does its own short settle passes, so no reset is required.
        if savedAvatarSnapshot and type(_G.KimqAvatarController.ApplySnapshot)=="function" then
            pcall(_G.KimqAvatarController.ApplySnapshot,savedAvatarSnapshot,true)
        elseif type(_G.KimqAvatarController.ApplySaved)=="function" then
            -- Backward compatibility for old configs that only stored username/id.
            pcall(_G.KimqAvatarController.ApplySaved)
        end
    end

    -- Applying a saved avatar can replace accessories. Re-apply the saved local
    -- accessories afterward so a preset containing BOTH avatar + accessories
    -- restores the final look rather than losing the local accessories.
    local savedAccessoryState = type(configData.controls)=="table" and configData.controls["Local Accessories"] or nil
    if savedAccessoryState and _G.KimqAccessoryController and type(_G.KimqAccessoryController.SetState)=="function" then
        task.delay(2.0, function()
            pcall(_G.KimqAccessoryController.SetState, savedAccessoryState)
        end)
    end

    if type(configData.window) == "table" then
        pcall(function()
            local w = math.clamp(tonumber(configData.window.w) or 980, 720, 1800)
            local h = math.clamp(tonumber(configData.window.h) or 620, 460, 1100)
            local root = game:GetService("CoreGui"):FindFirstChild("KimpetrasHC") or LocalPlayer.PlayerGui:FindFirstChild("KimpetrasHC")
            local main = root and root:FindFirstChild("Main")
            if main then
                main.Size = UDim2.fromOffset(w, h)
                if tonumber(configData.window.x) and tonumber(configData.window.y) then
                    local cam = workspace.CurrentCamera
                    local vp = cam and cam.ViewportSize or Vector2.new(1920,1080)
                    local x = math.clamp(tonumber(configData.window.x), 0, math.max(0, vp.X-w))
                    local y = math.clamp(tonumber(configData.window.y), 0, math.max(0, vp.Y-h))
                    main.Position = UDim2.fromOffset(x, y)
                end
            end
        end)
    end

    _G.KimqSelectedConfig = name
    if type(_G.KimqApplyTheme) == "function" then pcall(_G.KimqApplyTheme, _G.KimqCuteTheme or "Matcha Pink") end

    -- Restore fog after every other setting, especially Environment Preset.
    -- A few short re-applies handle games that rewrite Lighting for a frame or two
    -- when their own atmosphere scripts react to a preset/config load.
    if savedFogState and _G.KimqFogController and type(_G.KimqFogController.SetState)=="function" then
        _G.KimqFogLoadToken = (_G.KimqFogLoadToken or 0) + 1
        local token = _G.KimqFogLoadToken
        local function restoreSavedFog()
            if _G.KimqFogLoadToken ~= token then return end
            pcall(_G.KimqFogController.SetState, savedFogState)
        end
        restoreSavedFog()
        -- One delayed settle handles late Lighting writes without hammering the fog UI.
        task.delay(0.18, restoreSavedFog)
    end

    notifyConfig("Loaded config: " .. name)
    if type(_G.KimqRefreshConfigList) == "function" then pcall(_G.KimqRefreshConfigList) end
    return true
end

local function DeleteConfig(configName)
    local name = cleanConfigName(configName)
    if name == WHOLE_DIFFERENT_ANIMAL then
        notifyConfig("WholeDifferentAnimal is built in and cannot be deleted ♡")
        return false
    end
    local removed = false
    local path = configPath(name)
    if type(isfile) == "function" and type(delfile) == "function" then
        local okExists, exists = pcall(isfile, path)
        if okExists and exists then removed = pcall(delfile, path) end
    end
    if KimqMemoryConfigs[name] then KimqMemoryConfigs[name] = nil removed = true end
    if removed then
        if _G.KimqSelectedConfig == name then _G.KimqSelectedConfig = nil end
        notifyConfig("Deleted config: " .. name)
    else
        notifyConfig("Config not found: " .. name)
    end
    if type(_G.KimqRefreshConfigList) == "function" then pcall(_G.KimqRefreshConfigList) end
    return removed
end

local function GetConfigs()
    local names, seen = {}, {}
    local function add(name)
        name = cleanConfigName(name)
        if name ~= "" and not seen[name] then seen[name] = true table.insert(names, name) end
    end

    if ensureConfigFolder() and type(listfiles) == "function" then
        local ok, files = pcall(listfiles, CONFIG_DIR)
        if ok and type(files) == "table" then
            for _, filePath in ipairs(files) do
                local filename = tostring(filePath):match("([^/\\]+)%.json$")
                if filename then add(filename) end
            end
        end
    end
    for name in pairs(KimqMemoryConfigs) do add(name) end
    add(WHOLE_DIFFERENT_ANIMAL)
    table.sort(names, function(a,b) return a:lower() < b:lower() end)
    for i, name in ipairs(names) do
        if name == WHOLE_DIFFERENT_ANIMAL then
            table.remove(names, i)
            table.insert(names, 1, WHOLE_DIFFERENT_ANIMAL)
            break
        end
    end
    return names
end

local function UpdateHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not _G.Whitelist[plr.UserId] and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if _G.HitboxEnabled then
                    hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                    hrp.Transparency = 1 - _G.HitboxTransparency
                    hrp.Color = Color3.fromRGB(145, 210, 240)
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            UpdateHitboxes()
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.HitboxEnabled then
            UpdateHitboxes()
        end
    end
end)

local DelayChanger = { 
    Enabled = true, 
    ["[Revolver]"] = 0.03, 
    ["[Double-Barrel SG]"] = 0.3, 
    ["[TacticalShotgun]"] = 0.0, 
    ["Others"] = 0.095 
}

local function applyCustomDelay(v)
    if not _G.DelayChangerEnabled then return end
    if (v.Name == "ShootingCooldown" or v.Name == "ToleranceCooldown") and v:IsA("ValueBase") then
        local tool = v:FindFirstAncestorOfClass("Tool")
        local delayValue = _G.DelayChangerOthers
        if tool then
            if tool.Name == "[Revolver]" then delayValue = _G.DelayChangerRevolver
            elseif tool.Name == "[Double-Barrel SG]" then delayValue = _G.DelayChangerDoubleBarrel
            elseif tool.Name == "[TacticalShotgun]" then delayValue = _G.DelayChangerTacticalShotgun end
        end
        v.Value = delayValue
        v:GetPropertyChangedSignal("Value"):Connect(function()
            if v.Value ~= delayValue then v.Value = delayValue end
        end)
    end
end

local function scanOwnDelayValues()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetDescendants()) do applyCustomDelay(v) end
    end
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do applyCustomDelay(v) end
    end
end

-- Do not scan every instance in the entire game on startup.
-- Delay values only matter on the local player's tools.
if _G.DelayChangerEnabled then scanOwnDelayValues() end
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if backpack then backpack.DescendantAdded:Connect(applyCustomDelay) end
LocalPlayer.CharacterAdded:Connect(function(char)
    char.DescendantAdded:Connect(applyCustomDelay)
    if _G.DelayChangerEnabled then task.defer(scanOwnDelayValues) end
end)

task.spawn(function()
    task.wait(2)
    local antiStaffGroupId = 10604500
    local function antiStaffNotify(message)
        if _G.AntiModNotification then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Anti-Mod", Text = message, Duration = 5 })
            end)
        end
    end

    local function isStaff(player)
        if not player or not player:IsInGroup(antiStaffGroupId) then return false end
        local success, role = pcall(function() return player:GetRoleInGroup(antiStaffGroupId) end)
        return success and role ~= "" and role ~= "Guest"
    end

    local function handleStaffDetected(player)
        local staffName = player.Name
        antiStaffNotify(string.format("STAFF DETECTED: %s has joined!", staffName))
        if _G.AntiModKick then
            task.wait(_G.AntiModKickDelay)
            if isStaff(player) and player.Parent then
                LocalPlayer:Kick(string.format("Anti-Mod: Staff member %s detected. Protection activated.", staffName))
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isStaff(player) then
            antiStaffNotify(string.format("STAFF ALREADY IN GAME: %s", player.Name))
            if _G.AntiModKick then
                task.wait(_G.AntiModKickDelay)
                LocalPlayer:Kick(string.format("Anti-Mod: Staff member %s is already in game.", player.Name))
            end
            break
        end
    end

    Players.PlayerAdded:Connect(function(player)
        task.wait(0.5)
        if isStaff(player) then handleStaffDetected(player) end
        player:GetPropertyChangedSignal("GroupRank"):Connect(function()
            task.wait(0.5)
            if isStaff(player) then antiStaffNotify(string.format("STAFF DETECTED: %s was promoted!", player.Name)) handleStaffDetected(player) end
        end)
    end)
end)

local AntiAimViewEnabled = false
local AccuracyTarget = 0

local antiAimConnections = {}

local function toggleAntiAimView(enable)
    for _, conn in ipairs(antiAimConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    antiAimConnections = {}

    if not enable then
        return
    end

    local dataFolder = LocalPlayer:FindFirstChild("DataFolder")
    if not dataFolder then
        dataFolder = LocalPlayer:WaitForChild("DataFolder", 5)
    end
    if not dataFolder then
        return
    end

    local shotland = dataFolder:FindFirstChild("ShotLand")
    local shottotal = dataFolder:FindFirstChild("ShotTotal")
    local warning = dataFolder:FindFirstChild("Warning")
    local lockflagged = dataFolder:FindFirstChild("LockFlagged")

    local function safeConnect(obj, callback)
        if obj then
            local conn = obj:GetPropertyChangedSignal("Value"):Connect(callback)
            table.insert(antiAimConnections, conn)
        end
    end

    safeConnect(shottotal, function()
        if shottotal and shotland then
            local total = shottotal.Value
            if total > 0 then
                local targetLand = math.floor(total * (AccuracyTarget / 100))
                shotland.Value = targetLand
            end
        end
    end)

    safeConnect(warning, function()
        if warning then
            warning.Value = 0
        end
    end)

    safeConnect(lockflagged, function()
        if lockflagged then
            lockflagged.Value = 0
        end
    end)

    local function onCharacterAdded(char)
        local bodyEffects = char:FindFirstChild("BodyEffects")
        if bodyEffects then
            local gf = bodyEffects:FindFirstChild("GunFiring")
            local gsc = bodyEffects:FindFirstChild("GunShotChanges")
            if gf then
                local conn = gf:GetPropertyChangedSignal("Value"):Connect(function()
                    if gf then
                        gf.Value = false
                    end
                end)
                table.insert(antiAimConnections, conn)
            end
            if gsc then
                local conn = gsc:GetPropertyChangedSignal("Value"):Connect(function()
                    if gsc then
                        gsc.Value = 0
                    end
                end)
                table.insert(antiAimConnections, conn)
            end
        end
    end

    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end

    local playerAddedConn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(antiAimConnections, playerAddedConn)
end

local antiModConnections = {}

local function setupAntiMod()
    for _, conn in ipairs(antiModConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    antiModConnections = {}

    local function adjustAccuracy()
        local dataFolder = LocalPlayer:FindFirstChild("DataFolder")
        if not dataFolder then
            return
        end

        local shotland = dataFolder:FindFirstChild("ShotLand")
        local shottotal = dataFolder:FindFirstChild("ShotTotal")
        local warning = dataFolder:FindFirstChild("Warning")
        local lockflagged = dataFolder:FindFirstChild("LockFlagged")

        pcall(function()
            if shottotal and shotland then
                local total = shottotal.Value
                if total > 0 then
                    local targetLand = math.floor(total * (AccuracyTarget / 100))
                    shotland.Value = targetLand
                end
            end
        end)
        pcall(function()
            if warning then warning.Value = 0 end
        end)
        pcall(function()
            if lockflagged then lockflagged.Value = 0 end
        end)

        local ReportersFolder = dataFolder:FindFirstChild("Reporters")
        if ReportersFolder then
            for _, reporter in ipairs(ReportersFolder:GetChildren()) do
                pcall(function()
                    reporter:Destroy()
                end)
            end
        end
    end

    local function onCharacterAdded(char)
        task.wait(0.5)
        adjustAccuracy()

        local bodyEffects = char:FindFirstChild("BodyEffects")
        if bodyEffects then
            local gf = bodyEffects:FindFirstChild("GunFiring")
            local gsc = bodyEffects:FindFirstChild("GunShotChanges")

            if gf then
                local conn = gf:GetPropertyChangedSignal("Value"):Connect(function()
                    if gf then
                        gf.Value = false
                    end
                end)
                table.insert(antiModConnections, conn)
            end
            if gsc then
                local conn = gsc:GetPropertyChangedSignal("Value"):Connect(function()
                    if gsc then
                        gsc.Value = 0
                    end
                end)
                table.insert(antiModConnections, conn)
            end
        end
    end

    adjustAccuracy()

    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end

    local conn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(antiModConnections, conn)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if AntiAimViewEnabled then
        toggleAntiAimView(true)
    end
    setupAntiMod()
end)

task.spawn(function()
    task.wait(1)
    if AntiAimViewEnabled then
        toggleAntiAimView(true)
    end
    setupAntiMod()
end)

-- Export the Force Hit engine for the outer RAGE module, then backend helpers.
_G.KimqForceHitEngine = ForceHit

-- Export backend helpers to the Kimqetras interface.
_G.KimpetrasKIMBackend = {
    enableHCSilentAim = enableHCSilentAim,
    DisableCamlock = DisableCamlock,
    UpdateHitboxes = UpdateHitboxes,
    toggleAntiAimView = toggleAntiAimView,
    SaveConfig = SaveConfig,
    LoadConfig = LoadConfig,
    DeleteConfig = DeleteConfig,
    GetConfigs = GetConfigs,
    HCGodmodeStart = function()
        HCGodmode_Active = true
        HCGodmode_Animate()
    end,
    HCGodmodeStop = function()
        HCGodmode_Active = false
        HCGodmode_Stop()
    end,
}

end)()

_G.AntiModNotification = false
_G.AntiModKick = false


]=====], false) then return end

if not runChunk("controls", [=====[
local C = _G.KimpetrasCtx
if not C then error("Kimqetras core context missing") end
local UIS, lp, cfg = C.UIS, C.lp, C.cfg
local createCard, addToggle, addSlider, addDecimalSlider, addButton, addDropdown, addKeybind =
    C.createCard, C.addToggle, C.addSlider, C.addDecimalSlider, C.addButton, C.addDropdown, C.addKeybind
-- ========================================================
-- CLEAN KIM FEATURE SECTIONS
-- Remaining document (3) controls, styled for Kimpetras HC.
-- ========================================================

local sectionKeyByTitle = {
    ["Combat"] = "hcsilent",
    ["Force Hit"] = "hcsilent",
    ["Hitbox Expander"] = "hitbox",
    ["Flamelock"] = "flamelock",
    ["Camlock"] = "camlock",
    ["Visuals"] = "fog",
    ["Headless"] = "avatar",
    ["Protection + Anti Mod"] = "antimod",
    ["Settings"] = "settings",
    ["Credits"] = "info",
}

local function addCleanSection(title, subtitle)
    local key = sectionKeyByTitle[title]
    if key then _G.KimqBuildSection = key end
    -- v2.62: pageHead already displays the section name.
    -- Do not add another title card inside the page.
    return nil
end

local function addSmallNote(text)
    local card = createCard(32)
    card.BackgroundColor3 = Color3.fromRGB(255, 242, 206)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1,-18,1,0)
    lbl.Position = UDim2.fromOffset(9,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextWrapped = true
    lbl.TextColor3 = Color3.fromRGB(176, 99, 122)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function addTextInput(labelText, placeholder, callback)
    local card = createCard(66)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1,-20,0,20)
    lbl.Position = UDim2.fromOffset(10,4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(166,55,105)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", card)
    box.Size = UDim2.new(1,-20,0,28)
    box.Position = UDim2.fromOffset(10,30)
    box.BackgroundColor3 = Color3.fromRGB(255,225,238)
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(197,112,145)
    box.TextColor3 = Color3.fromRGB(225,55,135)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,7)
    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end

local KIM = _G.KimpetrasKIMBackend or {}
local allParts = {
    "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
    "LeftFoot", "RightFoot", "LeftHand", "RightHand", "Closest Point"
}

-- COMBAT -------------------------------------------------
addCleanSection("Combat", "HC Silent Aim + Force Hit")

addToggle("HC Silent Aim", _G.HCSilentAimEnabled, function(v)
    _G.HCSilentAimEnabled = v
    if KIM.enableHCSilentAim then KIM.enableHCSilentAim(v) end
end)
addToggle("HC Revolver Bypass", _G.HCRevolverBypass, function(v) _G.HCRevolverBypass = v end)
addToggle("HC Wall Check", _G.HCWallCheck, function(v) _G.HCWallCheck = v end)
addToggle("HC Knock Check", _G.HCKnockCheck, function(v) _G.HCKnockCheck = v end)
addSlider("HC FOV Radius", 10, 1000, _G.HCFOVRadius, function(v) _G.HCFOVRadius = v end)
addDropdown("HC Hit Part", allParts, _G.HCHitPart, function(v) _G.HCHitPart = v end)
addToggle("HC Prediction", _G.HCPrediction, function(v) _G.HCPrediction = v end)
addDecimalSlider("HC Prediction Amount", 0, 0.5, _G.HCPredictionAmount, 3, function(v) _G.HCPredictionAmount = v end)
addToggle("HC Godmode", _G.HCGodmodeEnabled, function(v)
    _G.HCGodmodeEnabled = v
    if v then
        if KIM.HCGodmodeStart then KIM.HCGodmodeStart() end
    else
        if KIM.HCGodmodeStop then KIM.HCGodmodeStop() end
    end
end)

addCleanSection("Force Hit", "Force-hit controls")
addToggle("Force Hit", _G.ForceHitEnabled, function(v)
    _G.ForceHitEnabled = v
    if not v then
        _G.KimqForceHitPart = nil
        _G.KimqForceHitPosition = nil
        _G.KimqForceHitUntil = 0
    end
    if KIM.enableHCSilentAim then KIM.enableHCSilentAim(_G.HCSilentAimEnabled) end
end)
addDropdown("Force Hit Mode", {"Fov", "Manual"}, _G.ForceHitMode, function(v) _G.ForceHitMode = v end)
addSlider("Force Hit FOV", 10, 1000, _G.ForceHitFOV, function(v) _G.ForceHitFOV = v end)
addToggle("Force Hit Tracer", _G.ForceHitTracerEnabled, function(v) _G.ForceHitTracerEnabled = v end)
addToggle("Force Hit Full Auto", _G.ForceHitFullAutoEnabled, function(v) _G.ForceHitFullAutoEnabled = v end)
addDecimalSlider("Force Hit Fire Rate", 0.01, 0.5, _G.ForceHitFireRate, 3, function(v) _G.ForceHitFireRate = v end)
addToggle("Force Hit One Click Finish", _G.ForceHitOneClickFinish, function(v) _G.ForceHitOneClickFinish = v end)
addSlider("Force Hit Finish Shots", 2, 10, _G.ForceHitFinishShots, function(v) _G.ForceHitFinishShots = math.floor(v + .5) end)
addToggle("Force Hit Auto Reload", _G.ForceHitAutoReload, function(v) _G.ForceHitAutoReload = v end)

addCleanSection("Hitbox Expander", "Adjust hitbox settings")
addToggle("Hitbox Expander", _G.HitboxEnabled, function(v)
    _G.HitboxEnabled = v
    if KIM.UpdateHitboxes then KIM.UpdateHitboxes() end
end)
addSlider("Hitbox Size", 1, 20, _G.HitboxSize, function(v) _G.HitboxSize = v end)
addDecimalSlider("Hitbox Visibility", 0, 1, _G.HitboxTransparency, 2, function(v) _G.HitboxTransparency = v end)

addCleanSection("Flamelock", "Customize flamelock settings")
addToggle("Flamelock", _G.FlamelockEnabled, function(v)
    _G.FlamelockEnabled = v
    if not v then _G.FlameActive = false end
end)
addToggle("Right Click Lock", _G.FlameRightClick, function(v) _G.FlameRightClick = v end)
addDropdown("Activation Mode", {"Hold", "Toggle"}, _G.FlameMode, function(v) _G.FlameMode = v end)
addKeybind("Flamelock Key", _G.FlameKey, function(v) _G.FlameKey = v end)
addDropdown("Flame Hit Part", {"HumanoidRootPart","Head","UpperTorso","LowerTorso"}, _G.FlameHitPart, function(v) _G.FlameHitPart = v end)
addDecimalSlider("Flame Smoothness", 0, 1, _G.FlameSmoothness, 2, function(v) _G.FlameSmoothness = v end)
addDecimalSlider("Flame Prediction", 0, 0.5, _G.FlamePrediction, 3, function(v) _G.FlamePrediction = v end)
addDecimalSlider("Flame Left Offset", -5, 5, _G.FlameLeftOffset, 2, function(v) _G.FlameLeftOffset = v end)
addDecimalSlider("Flame Up Offset", -20, 5, _G.FlameUpOffset, 2, function(v) _G.FlameUpOffset = v end)

-- CAMLOCK ------------------------------------------------
addCleanSection("Camlock", "Customize camlock settings")
addToggle("Camlock Enabled", _G.CamlockEnabled, function(v)
    _G.CamlockEnabled = v
    if not v and KIM.DisableCamlock then KIM.DisableCamlock() end
end)
addToggle("Auto Toggle (Gun)", _G.CamlockAutoToggle, function(v) _G.CamlockAutoToggle = v end)
addKeybind("Camlock Key", Enum.KeyCode[_G.CamlockToggleKey] or Enum.KeyCode.C, function(v) _G.CamlockToggleKey = v.Name end)
addDropdown("Camlock Mode", {"Hold","Toggle"}, _G.CamlockMode, function(v)
    _G.CamlockMode = v
    if KIM.DisableCamlock then KIM.DisableCamlock() end
end)
addDropdown("Camlock Hit Part", allParts, _G.CamlockHitPart, function(v) _G.CamlockHitPart = v end)
addDropdown("Closest Point Mode", {"Default","Basic"}, _G.CamlockClosestPointMode, function(v) _G.CamlockClosestPointMode = v end)
addDecimalSlider("Closest Point Scale", 0, 1, _G.CamlockClosestPointScale, 2, function(v) _G.CamlockClosestPointScale = v end)
addSlider("Camlock FOV", 0, 1000, _G.CamlockFOVRadius, function(v) _G.CamlockFOVRadius = v end)
addSlider("Max Distance", 0, 100000, _G.CamlockMaxDistance, function(v) _G.CamlockMaxDistance = v end)
addDropdown("Easing Style", {"Linear","Quad","Sine","Back","Elastic","Bounce"}, _G.CamlockEasingStyle, function(v) _G.CamlockEasingStyle = v end)
addDropdown("Easing Direction", {"In","Out","InOut"}, _G.CamlockEasingDirection, function(v) _G.CamlockEasingDirection = v end)
addDecimalSlider("Camlock Smoothness", 0, 1, _G.CamlockSmoothness, 3, function(v) _G.CamlockSmoothness = v end)
addToggle("Pull Strength", _G.CamlockPullStrengthEnabled, function(v) _G.CamlockPullStrengthEnabled = v end)
addDecimalSlider("Pull Base Value", 0.001, 0.2, _G.CamlockPullStrengthBaseValue, 3, function(v) _G.CamlockPullStrengthBaseValue = v end)
addDecimalSlider("Pull Move Value", 0.001, 0.2, _G.CamlockPullStrengthMoveValue, 3, function(v) _G.CamlockPullStrengthMoveValue = v end)
addToggle("Camlock Prediction", _G.CamlockPredictionEnabled, function(v) _G.CamlockPredictionEnabled = v end)
addDecimalSlider("Prediction X", 0.001, 0.1, math.max(_G.CamlockPredictionX,0.001), 3, function(v) _G.CamlockPredictionX = v end)
addDecimalSlider("Prediction Y", 0.001, 0.1, math.max(_G.CamlockPredictionY,0.001), 3, function(v) _G.CamlockPredictionY = v end)
addDecimalSlider("Prediction Z", 0.001, 0.1, math.max(_G.CamlockPredictionZ,0.001), 3, function(v) _G.CamlockPredictionZ = v end)
addToggle("Force Field Check", _G.CamlockConditionsForceField, function(v) _G.CamlockConditionsForceField = v end)
addToggle("Visible Check", _G.CamlockConditionsVisible, function(v) _G.CamlockConditionsVisible = v end)
addToggle("Carried Check", _G.CamlockConditionsCarried, function(v) _G.CamlockConditionsCarried = v end)
addToggle("Knocked Check", _G.CamlockConditionsKnocked, function(v) _G.CamlockConditionsKnocked = v end)
addToggle("Self Knocked Check", _G.CamlockConditionsSelfKnocked, function(v) _G.CamlockConditionsSelfKnocked = v end)

-- VISUALS ------------------------------------------------
addCleanSection("Visuals", "Customize the look of the game")
local Lighting = game:GetService("Lighting")
local originalFogStart, originalFogEnd, originalFogColor = Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor
local atmospherePresets = {
    ["Pink"] = {Color3.fromRGB(255,100,200),0.48},
    ["Hot Pink"] = {Color3.fromRGB(255,20,147),0.49},
    ["Yellow"] = {Color3.fromRGB(255,240,60),0.41},
    ["Blue"] = {Color3.fromRGB(60,140,255),0.50},
    ["Purple"] = {Color3.fromRGB(180,60,255),0.52},
    ["Red"] = {Color3.fromRGB(255,60,60),0.45},
    ["Green"] = {Color3.fromRGB(50,255,50),0.49},
    ["Cyan"] = {Color3.fromRGB(60,255,220),0.47},
}
addDropdown("Atmosphere Preset", {"Pink","Hot Pink","Yellow","Blue","Purple","Red","Green","Cyan"}, "Pink", function(name)
    for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") then v:Destroy() end end
    local cfgp = atmospherePresets[name]
    local atm = Instance.new("Atmosphere", Lighting)
    atm.Color = cfgp[1]
    atm.Density = cfgp[2]
    atm.Haze = 4
    Lighting.FogStart = 30
    Lighting.FogEnd = 200
end)
addButton("Reset Atmosphere", function()
    for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") then v:Destroy() end end
    Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = originalFogStart, originalFogEnd, originalFogColor
end)
addToggle("Color Correction", _G.ColorCorrectionEnabled, function(v)
    _G.ColorCorrectionEnabled = v
    local effect = Lighting:FindFirstChild("ValColorEffect")
    if v then
        if not effect then effect = Instance.new("ColorCorrectionEffect", Lighting) end
        effect.Name = "ValColorEffect"
        effect.Enabled = true
        effect.Saturation = 0.5
    elseif effect then effect.Enabled = false end
end)
addDecimalSlider("Saturation", 0, 2, 0.5, 2, function(v)
    local effect = Lighting:FindFirstChild("ValColorEffect") or Instance.new("ColorCorrectionEffect", Lighting)
    effect.Name = "ValColorEffect"
    effect.Enabled = true
    effect.Saturation = v
end)

-- AVATAR / HEADLESS --------------------------------------
-- Headless is built directly into the revamped Avatar page as "Visual Headless".

-- PROTECTION ---------------------------------------------
addCleanSection("Protection + Anti Mod", "Extra protection options")
addToggle("KIM Anti Aim View", _G.AntiAimViewEnabled, function(v)
    _G.AntiAimViewEnabled = v
    if KIM.toggleAntiAimView then KIM.toggleAntiAimView(v) end
end)
addToggle("Anti Mod Notify", false, function(v) _G.AntiModNotification = v end)
addToggle("Anti Mod Kick", false, function(v) _G.AntiModKick = v end)
addSlider("Anti Mod Kick Delay", 1, 10, _G.AntiModKickDelay, function(v) _G.AntiModKickDelay = v end)
addSmallNote("Anti Mod controls are OFF here by default so the script does not kick you unless you choose to enable it.")

-- SETTINGS -----------------------------------------------
addCleanSection("Settings", "Performance and saved setup options")
addToggle("FPS Unlocker", _G.FPSUnlocker, function(v)
    _G.FPSUnlocker = v
    if v and type(setfpscap) == "function" then pcall(setfpscap, _G.FPSTarget) end
end)
addSlider("Target FPS", 240, 1000, _G.FPSTarget, function(v)
    _G.FPSTarget = v
    if _G.FPSUnlocker and type(setfpscap) == "function" then pcall(setfpscap, v) end
end)

-- CUSTOM CURSOR ------------------------------------------------------------
-- Completely visual and isolated from targeting logic.
do
    cfg.customCursorEnabled = cfg.customCursorEnabled == true
    cfg.customCursorStyle = tostring(cfg.customCursorStyle or "Heart")
    cfg.customCursorSize = math.clamp(tonumber(cfg.customCursorSize) or 24,12,52)
    cfg.customCursorAsset = tostring(cfg.customCursorAsset or "")

    local cursorGuiName="KimqetrasCustomCursor"
    local CoreGui=game:GetService("CoreGui")
    local RunService=game:GetService("RunService")
    local pg=lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui")
    for _,root0 in ipairs({CoreGui,pg}) do
        local old=root0 and root0:FindFirstChild(cursorGuiName)
        if old then pcall(function() old:Destroy() end) end
    end

    local cursorGui=Instance.new("ScreenGui")
    cursorGui.Name=cursorGuiName
    cursorGui.ResetOnSpawn=false
    cursorGui.IgnoreGuiInset=true
    cursorGui.DisplayOrder=1000000
    pcall(function() cursorGui.Parent=CoreGui end)
    if not cursorGui.Parent then cursorGui.Parent=pg end

    local holder=Instance.new("Frame",cursorGui)
    holder.Name="Cursor"
    holder.AnchorPoint=Vector2.new(.5,.5)
    holder.BackgroundTransparency=1
    holder.ZIndex=1000000

    local heart=Instance.new("TextLabel",holder)
    heart.Name="Heart"
    heart.Size=UDim2.fromScale(1,1)
    heart.BackgroundTransparency=1
    heart.Text="♡"
    heart.TextColor3=Color3.fromRGB(255,105,180)
    heart.TextStrokeColor3=Color3.fromRGB(255,245,251)
    heart.TextStrokeTransparency=.2
    heart.Font=Enum.Font.GothamBold
    heart.TextScaled=true
    heart.ZIndex=1000001

    local dot=Instance.new("Frame",holder)
    dot.Name="Dot";dot.AnchorPoint=Vector2.new(.5,.5);dot.Position=UDim2.fromScale(.5,.5)
    dot.BackgroundColor3=Color3.fromRGB(255,105,180);dot.BorderSizePixel=0;dot.ZIndex=1000001
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local ring=Instance.new("Frame",holder)
    ring.Name="Ring";ring.AnchorPoint=Vector2.new(.5,.5);ring.Position=UDim2.fromScale(.5,.5)
    ring.Size=UDim2.fromScale(.78,.78);ring.BackgroundTransparency=1;ring.ZIndex=1000001
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    local ringStroke=Instance.new("UIStroke",ring);ringStroke.Color=Color3.fromRGB(255,105,180);ringStroke.Thickness=2

    local crossH=Instance.new("Frame",holder)
    crossH.Name="CrossH";crossH.AnchorPoint=Vector2.new(.5,.5);crossH.Position=UDim2.fromScale(.5,.5)
    crossH.BackgroundColor3=Color3.fromRGB(255,105,180);crossH.BorderSizePixel=0;crossH.ZIndex=1000001
    local crossV=Instance.new("Frame",holder)
    crossV.Name="CrossV";crossV.AnchorPoint=Vector2.new(.5,.5);crossV.Position=UDim2.fromScale(.5,.5)
    crossV.BackgroundColor3=Color3.fromRGB(255,105,180);crossV.BorderSizePixel=0;crossV.ZIndex=1000001

    local customImage=Instance.new("ImageLabel",holder)
    customImage.Name="CustomImage";customImage.Size=UDim2.fromScale(1,1)
    customImage.BackgroundTransparency=1;customImage.ScaleType=Enum.ScaleType.Fit;customImage.ZIndex=1000001

    local function cursorAssetUri(v)
        local raw=tostring(v or ""):gsub("%s+","")
        if raw=="" then return "" end
        local id=raw:match("(%d+)")
        if id then return "rbxassetid://"..id end
        return raw
    end
    local function refreshCursorVisual()
        local style=tostring(cfg.customCursorStyle or "Heart")
        local size=math.clamp(tonumber(cfg.customCursorSize) or 24,12,52)
        holder.Size=UDim2.fromOffset(size,size)
        dot.Size=UDim2.fromOffset(math.max(4,math.floor(size*.22)),math.max(4,math.floor(size*.22)))
        crossH.Size=UDim2.fromOffset(math.max(10,math.floor(size*.8)),math.max(2,math.floor(size*.10)))
        crossV.Size=UDim2.fromOffset(math.max(2,math.floor(size*.10)),math.max(10,math.floor(size*.8)))
        customImage.Image=cursorAssetUri(cfg.customCursorAsset)
        heart.Visible=style=="Heart"
        dot.Visible=style=="Dot"
        ring.Visible=style=="Ring"
        crossH.Visible=style=="Cross";crossV.Visible=style=="Cross"
        customImage.Visible=style=="Custom Image" and customImage.Image~=""
        local customReady=style~="Custom Image" or customImage.Image~=""
        holder.Visible=cfg.customCursorEnabled and style~="Default" and customReady
        UIS.MouseIconEnabled=not holder.Visible
    end
    _G.KimqRefreshCustomCursor=refreshCursorVisual
    refreshCursorVisual()

    RunService.RenderStepped:Connect(function()
        refreshCursorVisual()
        local mp=UIS:GetMouseLocation()
        holder.Position=UDim2.fromOffset(mp.X,mp.Y)
        -- Re-assert only cursor visibility; MouseBehavior/camera input are untouched.
        local shouldHide=holder.Visible==true
        if UIS.MouseIconEnabled==shouldHide then UIS.MouseIconEnabled=not shouldHide end
    end)

    addToggle("Custom Cursor",cfg.customCursorEnabled,function(v)
        cfg.customCursorEnabled=v==true;refreshCursorVisual()
    end)
    addDropdown("Cursor Style",{"Default","Heart","Dot","Cross","Ring","Custom Image"},cfg.customCursorStyle,function(v)
        cfg.customCursorStyle=tostring(v);refreshCursorVisual()
    end)
    addSlider("Cursor Size",12,52,cfg.customCursorSize,function(v)
        cfg.customCursorSize=v;refreshCursorVisual()
    end)
    local cursorAssetBox=addTextInput("Custom Cursor Asset ID","paste image/decal asset id",function(v)
        cfg.customCursorAsset=tostring(v or "");refreshCursorVisual()
    end)
    cursorAssetBox.Text=cfg.customCursorAsset
end

local configName = "Kimqetras"
local selectedConfig = _G.KimqSelectedConfig

-- v2.67: one compact Saved Configs card instead of five separate action cards.
local savedCard = createCard(322)
savedCard.Name = "KimqSavedConfigsCard"
savedCard:SetAttribute("KimqSection", "settings")
local savedTitle = Instance.new("TextLabel", savedCard)
savedTitle.Size = UDim2.new(1,-96,0,22)
savedTitle.Position = UDim2.fromOffset(10,7)
savedTitle.BackgroundTransparency = 1
savedTitle.Text = "♥  Saved Configs"
savedTitle.TextColor3 = Color3.fromRGB(220,45,125)
savedTitle.Font = Enum.Font.GothamBold
savedTitle.TextSize = 15
savedTitle.TextXAlignment = Enum.TextXAlignment.Left
savedTitle:SetAttribute("KimqV26Role","hotText")

local savedHint = Instance.new("TextLabel", savedCard)
savedHint.Size = UDim2.new(1,-20,0,17)
savedHint.Position = UDim2.fromOffset(10,30)
savedHint.BackgroundTransparency = 1
savedHint.Text = "save, update, load, or delete one setup ♡"
savedHint.TextColor3 = Color3.fromRGB(184,100,125)
savedHint.Font = Enum.Font.Gotham
savedHint.TextSize = 10
savedHint.TextXAlignment = Enum.TextXAlignment.Left
savedHint:SetAttribute("KimqV26Role","subText")

local refreshConfigButton = Instance.new("TextButton", savedCard)
refreshConfigButton.Size = UDim2.fromOffset(74,26)
refreshConfigButton.Position = UDim2.new(1,-84,0,7)
refreshConfigButton.BackgroundColor3 = Color3.fromRGB(255,225,238)
refreshConfigButton.BorderSizePixel = 0
refreshConfigButton.Text = "refresh"
refreshConfigButton.TextColor3 = Color3.fromRGB(225,55,135)
refreshConfigButton.Font = Enum.Font.GothamSemibold
refreshConfigButton.TextSize = 10
Instance.new("UICorner", refreshConfigButton).CornerRadius = UDim.new(0,8)
refreshConfigButton:SetAttribute("KimqV26Role","lightBg")

local configNameLabel = Instance.new("TextLabel", savedCard)
configNameLabel.Size = UDim2.new(1,-20,0,18)
configNameLabel.Position = UDim2.fromOffset(10,51)
configNameLabel.BackgroundTransparency = 1
configNameLabel.Text = "Config Name"
configNameLabel.TextColor3 = Color3.fromRGB(166,55,105)
configNameLabel.Font = Enum.Font.GothamSemibold
configNameLabel.TextSize = 11
configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
configNameLabel:SetAttribute("KimqV26Role","textText")

local configBox = Instance.new("TextBox", savedCard)
configBox.Size = UDim2.new(1,-20,0,30)
configBox.Position = UDim2.fromOffset(10,72)
configBox.BackgroundColor3 = Color3.fromRGB(255,225,238)
configBox.BorderSizePixel = 0
configBox.PlaceholderText = "Kimqetras"
configBox.PlaceholderColor3 = Color3.fromRGB(197,112,145)
configBox.TextColor3 = Color3.fromRGB(225,55,135)
configBox.Font = Enum.Font.Gotham
configBox.TextSize = 12
configBox.ClearTextOnFocus = false
Instance.new("UICorner", configBox).CornerRadius = UDim.new(0,8)
configBox:SetAttribute("KimqV26Role","lightBg")
local configBoxPad=Instance.new("UIPadding",configBox); configBoxPad.PaddingLeft=UDim.new(0,9); configBoxPad.PaddingRight=UDim.new(0,9)
configBox.FocusLost:Connect(function()
    local v=tostring(configBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if v~="" then configName=v end
end)

local savedList = Instance.new("ScrollingFrame", savedCard)
savedList.Name = "KimqSavedConfigList"
savedList.Size = UDim2.new(1,-20,0,112)
savedList.Position = UDim2.fromOffset(10,111)
savedList.BackgroundColor3 = Color3.fromRGB(255,245,250)
savedList.BorderSizePixel = 0
savedList.ScrollBarThickness = 3
savedList.ScrollBarImageColor3 = Color3.fromRGB(243,161,211)
Instance.new("UICorner", savedList).CornerRadius = UDim.new(0,9)
local savedLayout = Instance.new("UIListLayout", savedList)
savedLayout.Padding = UDim.new(0,5)
savedLayout.SortOrder = Enum.SortOrder.LayoutOrder
local savedPad = Instance.new("UIPadding", savedList)
savedPad.PaddingTop = UDim.new(0,6)
savedPad.PaddingBottom = UDim.new(0,6)
savedPad.PaddingLeft = UDim.new(0,6)
savedPad.PaddingRight = UDim.new(0,6)
savedLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    savedList.CanvasSize = UDim2.new(0,0,0,savedLayout.AbsoluteContentSize.Y + 12)
end)

local function settingsAction(text,pos,callback)
    local b=Instance.new("TextButton",savedCard)
    b.Size=UDim2.new(.5,-15,0,34)
    b.Position=pos
    b.BackgroundColor3=Color3.fromRGB(255,225,238)
    b.BorderSizePixel=0
    b.Text=text
    b.TextColor3=Color3.fromRGB(225,55,135)
    b.Font=Enum.Font.GothamSemibold
    b.TextSize=11
    b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
    b:SetAttribute("KimqV26Role","lightBg")
    local st=Instance.new("UIStroke",b); st.Color=Color3.fromRGB(255,190,220); st.Transparency=.35; st.Thickness=1
    b.MouseButton1Click:Connect(callback)
    return b
end

local function refreshConfigList()
    for _,ch in ipairs(savedList:GetChildren()) do
        if ch:IsA("TextButton") or ch:IsA("TextLabel") then ch:Destroy() end
    end
    local configs = (KIM.GetConfigs and KIM.GetConfigs()) or {}
    if #configs == 0 then
        local empty = Instance.new("TextLabel", savedList)
        empty.Size = UDim2.new(1,-4,0,30)
        empty.BackgroundTransparency = 1
        empty.Text = "no saved configs yet ♡"
        empty.TextColor3 = Color3.fromRGB(184,100,125)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 11
    else
        for i,name in ipairs(configs) do
            local row = Instance.new("TextButton", savedList)
            row.Name = "Config_" .. tostring(i)
            row.LayoutOrder = i
            row.Size = UDim2.new(1,-4,0,30)
            row.BackgroundColor3 = (selectedConfig == name) and Color3.fromRGB(243,161,211) or Color3.fromRGB(236,255,243)
            row.BorderSizePixel = 0
            row.Text = (name == "WholeDifferentAnimal") and (((selectedConfig == name) and "♥  " or "★  ") .. name) or (((selectedConfig == name) and "♥  " or "♡  ") .. name)
            row.TextColor3 = (selectedConfig == name) and Color3.fromRGB(255,255,255) or Color3.fromRGB(82,116,94)
            row.Font = Enum.Font.GothamSemibold
            row.TextSize = 11
            row.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
            local rowPad = Instance.new("UIPadding", row)
            rowPad.PaddingLeft = UDim.new(0,10)
            row.MouseButton1Click:Connect(function()
                selectedConfig = name
                _G.KimqSelectedConfig = name
                configName = name
                configBox.Text = name
                refreshConfigList()
            end)
        end
    end
end
_G.KimqRefreshConfigList = refreshConfigList

local saveConfigButton=settingsAction("Save",UDim2.fromOffset(10,232),function()
    if configBox.Text ~= "" then configName = configBox.Text end
    if KIM.SaveConfig and KIM.SaveConfig(configName) then
        selectedConfig = configName
        _G.KimqSelectedConfig = configName
        refreshConfigList()
    end
end)
local updateConfigButton=settingsAction("Update",UDim2.new(.5,5,0,232),function()
    if not selectedConfig or selectedConfig == "" then
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="KIM ♡",Text="Select a saved config first",Duration=3}) end)
        return
    end
    local oldName = selectedConfig
    local wantedName = tostring(configBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if wantedName == "" then wantedName = oldName end
    if KIM.SaveConfig and KIM.SaveConfig(wantedName) then
        if wantedName ~= oldName and KIM.DeleteConfig then pcall(function() KIM.DeleteConfig(oldName) end) end
        selectedConfig=wantedName; configName=wantedName; configBox.Text=wantedName; _G.KimqSelectedConfig=wantedName
        refreshConfigList()
    end
end)
local loadConfigButton=settingsAction("Load",UDim2.fromOffset(10,276),function()
    local name = selectedConfig or configName
    if KIM.LoadConfig and KIM.LoadConfig(name) then
        selectedConfig=name; _G.KimqSelectedConfig=name; configBox.Text=name; refreshConfigList()
    end
end)
local deleteConfigButton=settingsAction("Delete",UDim2.new(.5,5,0,276),function()
    local name = selectedConfig or configName
    if KIM.DeleteConfig and KIM.DeleteConfig(name) then
        if selectedConfig == name then selectedConfig=nil end
        _G.KimqSelectedConfig=selectedConfig
        refreshConfigList()
    end
end)
refreshConfigButton.MouseButton1Click:Connect(refreshConfigList)
refreshConfigList()

-- Keep Emergency Restore at the very bottom with no extra description card.
local emergencyCard=createCard(48)
emergencyCard.Name="KimqEmergencyRestoreCard"
emergencyCard:SetAttribute("KimqSection","settings")
local emergencyRestoreButton=Instance.new("TextButton",emergencyCard)
emergencyRestoreButton.Name="KimqEmergencyRestoreButton"
emergencyRestoreButton.Size=UDim2.new(1,-16,1,-10)
emergencyRestoreButton.Position=UDim2.fromOffset(8,5)
emergencyRestoreButton.BackgroundColor3=Color3.fromRGB(255,205,228)
emergencyRestoreButton.BorderSizePixel=0
emergencyRestoreButton.Text="♥  Emergency Restore"
emergencyRestoreButton.TextColor3=Color3.fromRGB(225,55,135)
emergencyRestoreButton.Font=Enum.Font.GothamBold
emergencyRestoreButton.TextSize=12
emergencyRestoreButton.AutoButtonColor=false
Instance.new("UICorner",emergencyRestoreButton).CornerRadius=UDim.new(0,9)
emergencyRestoreButton:SetAttribute("KimqV26Role","lightBg")
local emergencyStroke=Instance.new("UIStroke",emergencyRestoreButton); emergencyStroke.Color=Color3.fromRGB(255,170,210); emergencyStroke.Transparency=.28; emergencyStroke.Thickness=1
emergencyRestoreButton.MouseButton1Click:Connect(function()
    pcall(function()
        if type(_G.KimqRageEmergencyRestore)=="function" then _G.KimqRageEmergencyRestore() end
    end)
    pcall(function()
        _G.FlameActive=false
        if KIM and KIM.DisableCamlock then KIM.DisableCamlock() end
    end)
    pcall(function()
        local c=workspace.CurrentCamera
        local char=Players.LocalPlayer.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand=false; hum.Sit=false; hum.AutoRotate=true end
        if root then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
        if c then c.CameraType=Enum.CameraType.Custom; if hum then c.CameraSubject=hum end end
        UIS.MouseBehavior=Enum.MouseBehavior.Default
        UIS.MouseIconEnabled=true
    end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="KIM ♡",Text="Emergency Restore complete ♡",Duration=3})
    end)
end)

]=====], false) then return end

if #failures > 0 then
    for _, issue in ipairs(failures) do
        warn("[Kimqetras HC] " .. issue)
    end
end


-- ========================================================
-- KIMQETRAS HC PAGE CONSTRUCTION
-- One page shell is created; feature controls are moved into it once.
-- ========================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local lp = Players.LocalPlayer
    local playerGui = lp:WaitForChild("PlayerGui")

    local gui = CoreGui:FindFirstChild("KimpetrasHC") or playerGui:FindFirstChild("KimpetrasHC")
    if not gui then return end
    local main = gui:FindFirstChild("Main")
    if not main or main:FindFirstChild("KimqetrasCuteBlueReady") then return end

    local readyMark = Instance.new("BoolValue")
    readyMark.Name = "KimqetrasCuteBlueReady"
    readyMark.Parent = main

    local C = rawget(_G, "KimpetrasCtx")
    local oldScroll = C and C.Scroll or main:FindFirstChildWhichIsA("ScrollingFrame")
    local oldHeader = main:FindFirstChild("Header")
    local oldFog = main:FindFirstChild("FogPanel")
    local oldDrag = main:FindFirstChild("DragCorner")
    local oldBubble = gui:FindFirstChild("MiniBubble")

    if not oldScroll then return end

    -- Let the original UIListLayout finish positioning the controls before sorting them.
    for _ = 1, 3 do RunService.Heartbeat:Wait() end

    local T = {
        bg = Color3.fromRGB(246, 239, 255),
        bg2 = Color3.fromRGB(251, 247, 255),
        panel = Color3.fromRGB(255, 255, 255),
        card = Color3.fromRGB(255, 255, 255),
        card2 = Color3.fromRGB(252, 249, 255),
        hot = Color3.fromRGB(169, 116, 235),
        hot2 = Color3.fromRGB(229, 210, 251),
        text = Color3.fromRGB(102, 77, 126),
        sub = Color3.fromRGB(143, 119, 164),
        stroke = Color3.fromRGB(226, 208, 244),
        white = Color3.fromRGB(255, 255, 255),
    }
    -- Keep a live reference so the final theme engine can update callbacks that use T.
    _G.KimqThemePaletteRefs = _G.KimqThemePaletteRefs or {}
    table.insert(_G.KimqThemePaletteRefs, T)

    local function corner(obj, r)
        local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 14)
        c.Parent = obj
        return c
    end

    local function stroke(obj, color, tr, thickness)
        local s = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        s.Color = color or T.stroke
        s.Transparency = tr or 0
        s.Thickness = thickness or 1
        s.Parent = obj
        return s
    end

    local function textLabel(parent, text, size, pos, font, textSize, color, align)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = parent
        lbl.Size = size
        lbl.Position = pos
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = font or Enum.Font.Gotham
        lbl.TextSize = textSize or 13
        lbl.TextColor3 = color or T.text
        lbl.TextXAlignment = align or Enum.TextXAlignment.Left
        return lbl
    end

    local function assetFromWorkspace()
        local names = {
            "KimqetrasBanner.png", "KimqetrasBanner.webp", "KimqetrasBanner.gif",
            "kimqetras_banner.png", "kimqetras_banner.webp", "kimqetras_banner.gif",
            "banner.png", "banner.webp", "banner.gif"
        }
        for _, name in ipairs(names) do
            if type(getcustomasset) == "function" then
                local ok, asset = pcall(getcustomasset, name)
                if ok and asset then return asset end
            end
            if type(getsynasset) == "function" then
                local ok, asset = pcall(getsynasset, name)
                if ok and asset then return asset end
            end
        end
        return nil
    end

    if oldHeader then oldHeader.Visible = false end
    if oldBubble then pcall(function() oldBubble:Destroy() end) end
    if oldDrag then oldDrag.Visible = false end

    main.Size = UDim2.fromOffset(1040, 650)
    main.Position = UDim2.new(0.5, -520, 0.5, -325)
    main.BackgroundColor3 = T.bg
    main.BorderSizePixel = 0
    corner(main, 24)
    stroke(main, T.hot, 0.22, 2)

    -- Drag from the custom top area.
    local shell = Instance.new("Frame")
    shell.Name = "CuteBlueShell"
    shell.Parent = main
    shell.Size = UDim2.fromScale(1, 1)
    shell.BackgroundTransparency = 1

    local top = Instance.new("Frame")
    top.Parent = shell
    top.Size = UDim2.new(1, -28, 0, 70)
    top.Position = UDim2.fromOffset(14, 10)
    top.BackgroundTransparency = 1
    top.Active = true

    local title = textLabel(top, "♥  Kimqetras HC", UDim2.new(0, 360, 0, 36), UDim2.fromOffset(12, 3), Enum.Font.GothamBold, 29, T.hot)
    local subtitle = textLabel(top, "cute controls, clean pages, zero clutter ♡", UDim2.new(0, 420, 0, 20), UDim2.fromOffset(14, 38), Enum.Font.Gotham, 12, T.sub)

    local topProfile = Instance.new("Frame")
    topProfile.Parent = top
    topProfile.Size = UDim2.fromOffset(220, 46)
    topProfile.Position = UDim2.new(1, -232, 0.5, -23)
    topProfile.BackgroundColor3 = T.panel
    topProfile.BorderSizePixel = 0
    corner(topProfile, 15)
    stroke(topProfile, T.stroke, 0.28, 1)

    local topAvatar = Instance.new("ImageLabel")
    topAvatar.Parent = topProfile
    topAvatar.Size = UDim2.fromOffset(32, 32)
    topAvatar.Position = UDim2.new(0, 8, 0.5, -16)
    topAvatar.BackgroundColor3 = T.card2
    topAvatar.BorderSizePixel = 0
    corner(topAvatar, 999)
    task.spawn(function()
        local ok,img=pcall(function()
            return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and topAvatar and topAvatar.Parent then topAvatar.Image=img end
    end)

    local topName = textLabel(topProfile, lp.DisplayName, UDim2.new(1, -52, 0, 18), UDim2.fromOffset(48, 7), Enum.Font.GothamBold, 14, T.text)
    local topUser = textLabel(topProfile, "@" .. lp.Name, UDim2.new(1, -52, 0, 16), UDim2.fromOffset(48, 24), Enum.Font.Gotham, 10, T.sub)

    local dashTop = textLabel(shell, "-   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -", UDim2.new(1, -36, 0, 18), UDim2.fromOffset(18, 72), Enum.Font.GothamBold, 11, T.stroke, Enum.TextXAlignment.Center)

    local side = Instance.new("Frame")
    side.Parent = shell
    side.Size = UDim2.new(0, 205, 1, -104)
    side.Position = UDim2.fromOffset(14, 94)
    side.BackgroundColor3 = T.bg2
    side.BorderSizePixel = 0
    corner(side, 20)
    stroke(side, T.stroke, 0.18, 1)

    local sideHeart = textLabel(side, "♡  pages  ♡", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 12), Enum.Font.GothamBold, 18, T.text, Enum.TextXAlignment.Center)
    local sideDash = textLabel(side, "-  -  -  -  -  -  -", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(10, 38), Enum.Font.GothamBold, 10, T.stroke, Enum.TextXAlignment.Center)

    local navSearch = Instance.new("TextBox")
    navSearch.Name = "PageSearch"
    navSearch.Parent = side
    navSearch.Size = UDim2.new(1, -16, 0, 30)
    navSearch.Position = UDim2.fromOffset(8, 56)
    navSearch.BackgroundColor3 = T.panel
    navSearch.BorderSizePixel = 0
    navSearch.PlaceholderText = "♡  find a page..."
    navSearch.PlaceholderColor3 = T.sub
    navSearch.Text = ""
    navSearch.TextColor3 = T.text
    navSearch.Font = Enum.Font.Gotham
    navSearch.TextSize = 11
    navSearch.ClearTextOnFocus = false
    navSearch.TextXAlignment = Enum.TextXAlignment.Left
    corner(navSearch, 10)
    stroke(navSearch, T.stroke, .28, 1)
    local navSearchPad=Instance.new("UIPadding",navSearch)
    navSearchPad.PaddingLeft=UDim.new(0,10)
    navSearchPad.PaddingRight=UDim.new(0,10)

    local nav = Instance.new("ScrollingFrame")
    nav.Parent = side
    nav.Size = UDim2.new(1, -14, 1, -144)
    nav.Position = UDim2.fromOffset(7, 92)
    nav.BackgroundTransparency = 1
    nav.BorderSizePixel = 0
    nav.ScrollBarThickness = 2
    nav.ScrollBarImageColor3 = T.hot
    local navLayout = Instance.new("UIListLayout", nav)
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 6)
    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        nav.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 16)
    end)

    local rightShiftHint = Instance.new("Frame")
    rightShiftHint.Parent = side
    rightShiftHint.Size = UDim2.new(1, -16, 0, 30)
    rightShiftHint.Position = UDim2.new(0, 8, 1, -38)
    rightShiftHint.BackgroundColor3 = T.panel
    rightShiftHint.BorderSizePixel = 0
    corner(rightShiftHint, 12)
    stroke(rightShiftHint, T.stroke, 0.3, 1)
    local hint = textLabel(rightShiftHint, "♥  F1 = hide / show", UDim2.new(1, -12, 1, 0), UDim2.fromOffset(6, 0), Enum.Font.GothamSemibold, 10, T.hot, Enum.TextXAlignment.Center)

    local content = Instance.new("Frame")
    content.Parent = shell
    content.Size = UDim2.new(1, -247, 1, -104)
    content.Position = UDim2.fromOffset(233, 94)
    content.BackgroundTransparency = 1

    local pageHead = Instance.new("Frame")
    pageHead.Parent = content
    pageHead.Size = UDim2.new(1, 0, 0, 76)
    pageHead.BackgroundColor3 = T.panel
    pageHead.BorderSizePixel = 0
    corner(pageHead, 18)
    stroke(pageHead, T.stroke, 0.22, 1)

    local pageHeart = textLabel(pageHead, "♥", UDim2.fromOffset(30, 30), UDim2.fromOffset(14, 10), Enum.Font.GothamBold, 24, T.hot, Enum.TextXAlignment.Center)
    local pageTitle = textLabel(pageHead, "overview", UDim2.new(1, -60, 0, 28), UDim2.fromOffset(46, 10), Enum.Font.GothamBold, 23, T.text)
    local pageDesc = textLabel(pageHead, "your account, quick notes, and a little welcome page", UDim2.new(1, -40, 0, 18), UDim2.fromOffset(18, 42), Enum.Font.Gotham, 11, T.sub)
    local dashHead = textLabel(pageHead, "-  -  -  -  -  -  -  -  -  -  -  -", UDim2.new(0, 250, 0, 16), UDim2.new(1, -270, 0, 44), Enum.Font.GothamBold, 9, T.stroke, Enum.TextXAlignment.Right)

    local pageHost = Instance.new("Frame")
    pageHost.Parent = content
    pageHost.Size = UDim2.new(1, 0, 1, -88)
    pageHost.Position = UDim2.fromOffset(0, 88)
    pageHost.BackgroundTransparency = 1

    -- v2.62: pages are grouped by what they actually do so the sidebar is
    -- easier to understand. Environment + Weapon Skins are canonical pages now,
    -- not late-added special buttons that can disappear during startup.
    local pageDefs = {
        -- HOME
        {"overview", "overview", "your account, quick notes, and a little welcome page", "HOME"},
        {"theme", "theme", "change the colors of the whole interface", "HOME"},
        {"settings", "settings", "performance and saved setup options", "HOME"},

        -- COMBAT
        {"hcsilent", "HC silent aim", "HC targeting and force-hit controls together", "COMBAT"},
        {"silent", "silent aim", "adjust your targeting settings", "COMBAT"},
        {"camlock", "camlock", "customize camlock settings", "COMBAT"},
        {"flamelock", "flamelock", "customize flamelock settings", "COMBAT"},
        {"hitbox", "hitbox expander", "adjust hitbox settings", "COMBAT"},
        {"delay", "delay changer", "adjust weapon delay settings", "COMBAT"},

        -- VISUALS
        {"fog", "fog / atmosphere", "customize fog, atmosphere, and colors", "VISUALS"},
        {"environment", "environment", "day/night and seasonal map styles", "VISUALS"},
        {"esp", "ESP", "customize player ESP", "VISUALS"},

        -- PLAYER
        {"avatar", "avatar", "copy an avatar, wear local items, and use headless", "PLAYER"},
        {"weaponskins", "weapon skins", "wraps, bullets, knives, and equippable items", "PLAYER"},
        {"whitelist", "whitelist", "choose players you want to ignore", "PLAYER"},
        {"protection", "protection", "extra protection options", "PLAYER"},
        {"antifall", "anti fall", "helps with unwanted falling states", "PLAYER"},
        {"antimod", "anti mod", "extra anti-mod options", "PLAYER"},
        {"spawn", "spawn point", "choose where you return after respawning", "PLAYER"},
        {"macro", "macro", "control how your macro behaves", "PLAYER"},

        -- RAGE
        {"ragecam", "rage camlock", "select one or more players and keep target lock through respawn", "RAGE"},
        {"rageorbit", "target orbit", "teleport to and orbit your current queued target", "RAGE"},
        {"ragecombat", "rage combat", "auto attack, finish, and advance through your target queue", "RAGE"},
        {"ragepresets", "rage presets", "OP Silent Aim targeting, queue wipe, orbit hunt, or calm mode", "RAGE"},

        -- CREDITS
        {"info", "information", "credits and roles for this build", "CREDITS"},
    }

    local pages, pageMeta = {}, {}
    for _, d in ipairs(pageDefs) do
        pageMeta[d[1]] = {label = d[2], desc = d[3]}
        local p = Instance.new("ScrollingFrame")
        p.Name = d[1] .. "Page"
        p.Parent = pageHost
        p.Size = UDim2.fromScale(1, 1)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.Visible = false
        p.ScrollBarThickness = 3
        p.ScrollBarImageColor3 = T.hot
        local pad = Instance.new("UIPadding", p)
        pad.PaddingRight = UDim.new(0, 4)
        local list = Instance.new("UIListLayout", p)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 10)
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            p.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12)
        end)
        pages[d[1]] = p
    end

    local function sectionNameFromObject(obj)
        local function cleanText(txt)
            txt = tostring(txt or "")
            txt = txt:gsub("^%s+", "")
            local first = txt:sub(1, 1)
            if first ~= "♥" and first ~= "♡" then return nil end
            txt = txt:gsub("^[♥♡]%s*", "")
            txt = txt:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            return txt:lower()
        end
        if obj:IsA("TextLabel") then
            return cleanText(obj.Text), obj
        elseif obj:IsA("Frame") then
            for _, ch in ipairs(obj:GetDescendants()) do
                if ch:IsA("TextLabel") then
                    local name = cleanText(ch.Text)
                    if name then return name, ch end
                end
            end
        end
        return nil, nil
    end

    local map = {
        ["silent aim"] = "silent",
        ["macro"] = "macro",
        ["whitelist"] = "whitelist",
        ["protection"] = "protection",
        ["anti fall"] = "antifall",
        ["delay changer"] = "delay",
        ["esp"] = "esp",
        ["avatar"] = "avatar",
        ["combat"] = "hcsilent",
        ["force hit"] = "hcsilent",
        ["hitbox expander"] = "hitbox",
        ["flamelock"] = "flamelock",
        ["camlock"] = "camlock",
        ["visuals"] = "fog",
        ["headless"] = "avatar",
        ["protection + anti mod"] = "antimod",
        ["settings"] = "settings",
        ["credits"] = "info",
    }

    local rename = {
        ["combat"] = "♥  HC Silent Aim",
        ["visuals"] = "♥  Atmosphere Presets",
        ["protection + anti mod"] = "♥  Anti Mod",
        ["credits"] = "♥  Information",
    }

    -- Gather in the exact visual order produced by the original UIListLayout.
    local ordered = {}
    for _, child in ipairs(oldScroll:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            table.insert(ordered, child)
        end
    end
    table.sort(ordered, function(a, b)
        -- All original controls now receive a unique LayoutOrder at creation.
        -- This is deterministic even when an item (such as a dropdown) is hidden.
        if a.LayoutOrder ~= b.LayoutOrder then
            return a.LayoutOrder < b.LayoutOrder
        end
        local ay, by = a.AbsolutePosition.Y, b.AbsolutePosition.Y
        if ay ~= by then return ay < by end
        return a.Name < b.Name
    end)

    local function isOldPink(c)
        return c.R > 0.72 and c.B > 0.45 and c.R > c.G + 0.1
    end

    local function styleToggleButton(btn)
        local knob=btn:FindFirstChildWhichIsA("Frame")
        if knob then
            local on=(knob.Position.X.Scale>.45) or (knob.Position.X.Offset>8)
            btn.BackgroundColor3=on and T.hot or T.bg2
            knob.BackgroundColor3=T.white
        elseif isOldPink(btn.BackgroundColor3) then
            btn.BackgroundColor3=T.hot
        end
    end

    local function styleObject(root)
        local all = {root}
        for _, d in ipairs(root:GetDescendants()) do table.insert(all, d) end
        for _, obj in ipairs(all) do
            if obj:IsA("Frame") then
                if obj:FindFirstChildOfClass("UIGradient") then
                    -- keep actual color-pickers / hue gradients functional
                elseif obj.Size.Y.Offset > 12 or obj.Size.Y.Scale > 0 then
                    if obj.Name ~= "FogPreview" and obj.Name ~= "FogSquare" and obj.Name ~= "FogHueBar" then
                        obj.BackgroundColor3 = T.card
                    end
                    obj.BorderSizePixel = 0
                    corner(obj, math.min(14, math.max(7, obj.Size.Y.Offset > 70 and 14 or 10)))
                elseif isOldPink(obj.BackgroundColor3) then
                    obj.BackgroundColor3 = T.hot
                end
            elseif obj:IsA("TextLabel") then
                local isHeader = obj.Text and obj.Text:sub(1, 1) == "♥"
                if isHeader then
                    obj.TextColor3 = T.hot
                    obj.Font = Enum.Font.GothamBold
                    obj.TextSize = math.max(obj.TextSize, 18)
                else
                    if obj.TextSize >= 14 then
                        obj.TextColor3 = T.text
                    else
                        obj.TextColor3 = T.sub
                    end
                    if obj.Font == Enum.Font.GothamSemibold then obj.Font = Enum.Font.GothamSemibold end
                    if obj.Font == Enum.Font.Gotham then obj.Font = Enum.Font.Gotham end
                end
            elseif obj:IsA("TextButton") then
                if obj.Text == "" then
                    styleToggleButton(obj)
                else
                    obj.BackgroundColor3 = T.bg2
                    obj.TextColor3 = T.hot
                    if obj.Font == Enum.Font.GothamSemibold then obj.Font = Enum.Font.GothamSemibold end
                    if obj.Font == Enum.Font.Gotham then obj.Font = Enum.Font.Gotham end
                    corner(obj, 10)
                end
            elseif obj:IsA("TextBox") then
                obj.BackgroundColor3 = T.bg2
                obj.TextColor3 = T.hot
                obj.PlaceholderColor3 = T.sub
                obj.BorderSizePixel = 0
                obj.Font = Enum.Font.Gotham
                corner(obj, 10)
            elseif obj:IsA("UIStroke") then
                if isOldPink(obj.Color) then obj.Color = T.stroke end
            elseif obj:IsA("ScrollingFrame") then
                obj.ScrollBarImageColor3 = T.hot
            end
        end
    end

    local current = "silent"
    local orderCount = {}
    for _, child in ipairs(ordered) do
        local sec, headerLbl = sectionNameFromObject(child)
        if sec and map[sec] then
            current = map[sec]
            if rename[sec] and headerLbl then headerLbl.Text = rename[sec] end

            -- Standalone labels such as "♥ Avatar", "♥ Macro", etc. were
            -- section dividers in the old one-page GUI. The new page header
            -- already says this, so discard those duplicates.
            if child:IsA("TextLabel") then
                pcall(function() child:Destroy() end)
                continue
            end
        end

        -- Cards created by v2.1 know exactly which page owns them.  Use that
        -- stamp first; only legacy header-only objects fall back to `current`.
        local stamped = child:GetAttribute("KimqSection")
        if stamped=="forcehit" then stamped="hcsilent" end
        if stamped=="headless" then stamped="avatar" end
        local target = (stamped and pages[stamped]) and stamped or current
        local page = pages[target]
        if page then
            orderCount[target] = (orderCount[target] or 0) + 1
            child.LayoutOrder = orderCount[target]
            child.Parent = page
        end
    end

    -- Remove the obsolete hide/show keybind card; Right Shift is fixed globally now.
    for _, obj in ipairs(pages.silent:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text == "Hide/Show UI Key" then
            local card = obj.Parent
            if card and card:IsA("Frame") then card:Destroy() end
            break
        end
    end

    -- Fog picker is a direct child of Main in the original build.
    if oldFog then
        oldFog.Parent = pages.fog
        oldFog.LayoutOrder = 1
        oldFog.Position = UDim2.fromOffset(0, 0)
        oldFog.Size = UDim2.new(1, -6, 0, 560)
        oldFog.BackgroundColor3 = T.card
        oldFog.BorderSizePixel = 0
        corner(oldFog, 16)
        stroke(oldFog, T.stroke, 0.18, 1)
        -- Restore color-picker pieces that should show colors rather than theme blue.
        local square = oldFog:FindFirstChild("FogSquare")
        local hue = oldFog:FindFirstChild("FogHueBar")
        local prev = oldFog:FindFirstChild("FogPreview")
        if square then square.BackgroundColor3 = Color3.fromHSV(335/360, 1, 1) end
        if prev then prev.BackgroundColor3 = Color3.fromRGB(255,170,205) end
        if hue then hue.BackgroundColor3 = Color3.new(1,1,1) end
    end

    oldScroll.Visible = false
    oldScroll.Parent = gui

    -- Overview is intentionally left empty here. The final v2.1 builder creates it once.

    -- Navigation ----------------------------------------------------------
    local navButtons = {}
    local function showPage(key)
        for k, p in pairs(pages) do p.Visible = (k == key) end
        local meta = pageMeta[key]
        pageTitle.Text = meta and meta.label or key
        pageDesc.Text = (meta and meta.desc) or ""
        for _, entry in ipairs(navButtons) do
            local active = entry.key == key
            entry.button.BackgroundColor3 = active and T.hot or T.panel
            entry.button.TextColor3 = active and T.white or T.text
            local heart = entry.button:FindFirstChild("Heart")
            if heart then heart.TextColor3 = active and T.white or T.hot end
            local st = entry.button:FindFirstChildOfClass("UIStroke")
            if st then st.Color = active and T.hot or T.stroke end
        end
    end

    local navGroupLabels = {}
    local lastGroup = nil
    for i, d in ipairs(pageDefs) do
        local groupName = tostring(d[4] or "PAGES")
        if groupName ~= lastGroup then
            lastGroup = groupName
            local group = Instance.new("TextLabel")
            group.Name = "Group_" .. groupName
            group.Parent = nav
            group.LayoutOrder = i * 10 - 1
            group.Size = UDim2.new(1, -4, 0, 18)
            group.BackgroundTransparency = 1
            group.Text = "   " .. groupName
            group.TextColor3 = T.sub
            group.Font = Enum.Font.GothamBold
            group.TextSize = 9
            group.TextXAlignment = Enum.TextXAlignment.Left
            navGroupLabels[groupName] = group
        end

        local btn = Instance.new("TextButton")
        btn.Parent = nav
        btn.LayoutOrder = i * 10
        btn.Size = UDim2.new(1, -4, 0, 35)
        btn.BackgroundColor3 = T.panel
        btn.BorderSizePixel = 0
        btn.Text = "      " .. d[2]
        btn.TextColor3 = T.text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        corner(btn, 11)
        stroke(btn, T.stroke, 0.28, 1)

        local h = textLabel(btn, "♡", UDim2.fromOffset(28, 35), UDim2.fromOffset(7, 0), Enum.Font.GothamBold, 16, T.hot, Enum.TextXAlignment.Center)
        h.Name = "Heart"

        btn.MouseButton1Click:Connect(function() showPage(d[1]) end)
        table.insert(navButtons, {button = btn, key = d[1], label = d[2], group = groupName})
    end

    local function refreshPageSearch()
        local q = tostring(navSearch.Text or ""):lower():gsub("^%s+",""):gsub("%s+$","")
        local groupHasVisible = {}
        for _, entry in ipairs(navButtons) do
            local aliases=""
            if entry.key=="hcsilent" then aliases=" force hit forcehit" end
            if entry.key=="avatar" then aliases=" headless catalog limited accessory" end
            if entry.key=="ragecam" then aliases=" target targets multi queue player list select all preview view spectate" end
            if entry.key=="rageorbit" then aliases=" auto teleport circle fly angel wings" end
            if entry.key=="ragecombat" then aliases=" auto shoot silent aim stomp finish queue" end
            if entry.key=="ragepresets" then aliases=" preset presets op solo all targets queue wipe close hunt stop calm" end
            local hay = (tostring(entry.label) .. " " .. tostring(entry.key) .. aliases):lower()
            local visible = q == "" or hay:find(q, 1, true) ~= nil
            entry.button.Visible = visible
            if visible then groupHasVisible[entry.group] = true end
        end
        for groupName, label in pairs(navGroupLabels) do
            label.Visible = q == "" or groupHasVisible[groupName] == true
        end
    end
    navSearch:GetPropertyChangedSignal("Text"):Connect(refreshPageSearch)
    refreshPageSearch()

    -- ================================================================
    -- v2.84 RAGE V3 MODULE
    -- Full RAGE rewrite. Isolated from the rest of Kimqetras HC.
    -- Multi-target queue, deterministic attack/KO/stomp/advance state machine,
    -- non-PlatformStand orbit, aggressive presets, and cute themed mini HUD.
    -- ================================================================
    task.defer(function()
        local rageOK,rageERR=pcall(function()
            local R={}
            R.pages={cam=pages.ragecam,orbit=pages.rageorbit,combat=pages.ragecombat,presets=pages.ragepresets}
            if not (R.pages.cam and R.pages.orbit and R.pages.combat and R.pages.presets) then return end

            R.Players=game:GetService("Players")
            R.RunService=game:GetService("RunService")
            R.UIS=game:GetService("UserInputService")
            R.ReplicatedStorage=game:GetService("ReplicatedStorage")
            R.StarterGui=game:GetService("StarterGui")
            pcall(function() R.VIM=game:GetService("VirtualInputManager") end)

            -- One state table keeps the module under Luau's local-register ceiling.
            R.queue={}
            R.selected={}
            R.activeIndex=1
            R.runIds={}
            R.runIndex=1
            R.completed={}
            R.runScope="all"
            R.phase="IDLE"
            R.loopKills=false
            R.presetLoopKills=true
            R.presetAutoShoot=true
            R.useMyWeapons=true
            R.knownWeapons={"[DoubleBarrel]","[Revolver]","[Shotgun]","[SMG]","[Silencer]","[TacticalShotgun]"}
            R.loopCycle=0
            R.phaseTarget=nil
            R.master=false
            R.autoShoot=false
            R.autoReload=true
            R.autoStomp=true
            R.autoAdvance=true
            R.orbitMaster=false
            R.antiLock=true
            R.camLock=false
            R.freeView=false
            R.hudEnabled=false
            R.autoWings=true
            R.queueOrder="Lowest Health"
            R.skipDowned=true
            R.skipWhitelisted=true
            R.hitPart="Head"
            R.fireDelay=.035
            R.stompAttempts=2
            R.stompLock=true
            R.stompLockTime=.34
            R.orbitSpeed=14
            R.orbitRadius=4.0
            R.orbitHeight=2.7
            R.camSmooth=1
            R.orbitAngle=0
            R.fireClock=0
            R.hudClock=0
            R.reloadBusy=false
            R.shotBusy=false
            R.lastReload=0
            R.finishBusy=false
            R.runToken=0
            R.lastWingTry=0
            R.savedAutoRotate=nil
            R.savedHumanoid=nil
            R.movementOwned=false
            R.camOffset=nil
            R.camTargetId=nil
            R.prevCamType=nil
            R.prevCamSubject=nil
            R.ui={rows={},selectedLabels={},controls={}}

            function R.pal()
                return _G.KimqThemeLivePalette or T
            end

            function R.role(obj,name)
                if obj then obj:SetAttribute("KimqV26Role",name) end
                return obj
            end

            function R.notify(text,duration)
                pcall(function()
                    R.StarterGui:SetCore("SendNotification",{Title="KIM ♡",Text=tostring(text),Duration=duration or 3})
                end)
            end

            function R.sectionName(page)
                if page==R.pages.cam then return "ragecam" end
                if page==R.pages.orbit then return "rageorbit" end
                if page==R.pages.combat then return "ragecombat" end
                if page==R.pages.presets then return "ragepresets" end
                return "rage"
            end

            R.order={}
            function R.card(page,height)
                R.order[page]=(R.order[page] or 0)+1
                local p=R.pal()
                local f=Instance.new("Frame")
                f.Parent=page
                f.LayoutOrder=R.order[page]
                f.Size=UDim2.new(1,-6,0,height)
                f.BackgroundColor3=p.panel or T.panel
                f.BorderSizePixel=0
                f:SetAttribute("KimqSection",R.sectionName(page))
                R.role(f,"panel")
                corner(f,10)
                stroke(f,p.line or p.stroke or T.stroke,.24,1)
                return f
            end

            function R.label(parent,text,size,pos,font,textSize,color,align)
                return textLabel(
                    parent,text,size,pos,
                    font or Enum.Font.Gotham,
                    textSize or 11,
                    color or R.pal().text or T.text,
                    align or Enum.TextXAlignment.Left
                )
            end

            function R.button(parent,text,pos,size,fn)
                local p=R.pal()
                local b=Instance.new("TextButton")
                b.Parent=parent
                b.Position=pos
                b.Size=size
                b.BackgroundColor3=p.soft or p.bg2 or T.bg2
                b.BorderSizePixel=0
                b.Text=text
                b.TextColor3=p.hot or T.hot
                b.Font=Enum.Font.GothamSemibold
                b.TextSize=11
                b.AutoButtonColor=false
                R.role(b,"lightBg")
                corner(b,9)
                stroke(b,p.line or T.stroke,.28,1)
                b.MouseButton1Click:Connect(function()
                    local ok,err=pcall(fn)
                    if not ok then warn("[Kimqetras HC v2.89 RAGE button] "..tostring(err)) end
                end)
                return b
            end

            function R.makeToggle(page,text,default,callback)
                local state=not not default
                local c=R.card(page,48)
                R.role(R.label(c,text,UDim2.new(1,-88,1,0),UDim2.fromOffset(12,0),Enum.Font.GothamSemibold,12,R.pal().text or T.text),"textText")
                local b
                local function paint()
                    if not b then return end
                    b.Text=state and "ON" or "OFF"
                    if state then
                        b.BackgroundColor3=R.pal().hot or T.hot
                        b.TextColor3=R.pal().white or Color3.new(1,1,1)
                        b:SetAttribute("KimqV26Role","hotBg")
                    else
                        b.BackgroundColor3=R.pal().soft or T.bg2
                        b.TextColor3=R.pal().hot or T.hot
                        b:SetAttribute("KimqV26Role","lightBg")
                    end
                end
                local function setValue(v,quiet)
                    state=not not v
                    paint()
                    if callback then callback(state) end
                    return state
                end
                b=R.button(c,"",UDim2.new(1,-74,.5,-15),UDim2.fromOffset(62,30),function() setValue(not state) end)
                paint()
                if callback then callback(state) end
                return b,setValue
            end

            function R.makeCycle(page,text,items,default,callback)
                local idx=table.find(items,default) or 1
                local c=R.card(page,48)
                R.role(R.label(c,text,UDim2.new(.48,-12,1,0),UDim2.fromOffset(12,0),Enum.Font.GothamSemibold,12,R.pal().text or T.text),"textText")
                local b
                local function setValue(v,quiet)
                    local found=type(v)=="number" and math.clamp(math.floor(v),1,#items) or table.find(items,v)
                    idx=found or idx
                    if b then b.Text=tostring(items[idx]) end
                    if callback then callback(items[idx]) end
                    return items[idx]
                end
                b=R.button(c,tostring(items[idx]),UDim2.new(.48,0,.5,-15),UDim2.new(.52,-12,0,30),function()
                    setValue((idx%#items)+1)
                end)
                setValue(items[idx],true)
                return b,setValue
            end

            function R.makeSlider(page,text,min,max,default,callback,format)
                local value=math.clamp(tonumber(default) or min,min,max)
                local c=R.card(page,56)
                R.role(R.label(c,text,UDim2.new(.68,-12,0,22),UDim2.fromOffset(12,5),Enum.Font.GothamSemibold,12,R.pal().text or T.text),"textText")
                local valueLabel=R.role(R.label(c,"",UDim2.new(.32,-12,0,22),UDim2.new(.68,0,0,5),Enum.Font.Gotham,10,R.pal().sub or T.sub,Enum.TextXAlignment.Right),"subText")
                local track=Instance.new("Frame")
                track.Parent=c
                track.Position=UDim2.fromOffset(18,36)
                track.Size=UDim2.new(1,-36,0,9)
                track.BorderSizePixel=0
                track.Active=true
                R.role(track,"lightBg")
                corner(track,999)
                local fill=Instance.new("Frame")
                fill.Parent=track
                fill.BorderSizePixel=0
                R.role(fill,"hotBg")
                corner(fill,999)
                local hit=Instance.new("TextButton")
                hit.Parent=track
                hit.Size=UDim2.fromScale(1,1)
                hit.BackgroundTransparency=1
                hit.Text=""
                local dragging=false
                local function paint()
                    local a=(value-min)/(max-min)
                    fill.Size=UDim2.new(a,0,1,0)
                    valueLabel.Text=format and format(value) or tostring(math.floor(value*100+.5)/100)
                end
                local function setValue(v,quiet)
                    value=math.clamp(tonumber(v) or value,min,max)
                    paint()
                    if callback then callback(value) end
                    return value
                end
                local function setX(x)
                    local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
                    setValue(min+(max-min)*a)
                end
                hit.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setX(i.Position.X) end
                end)
                R.UIS.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X) end
                end)
                R.UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
                end)
                setValue(value,true)
                return c,setValue
            end

            function R.isWhitelisted(pl)
                if not pl then return false end
                local a=rawget(_G,"KHWhitelist")
                local b=rawget(_G,"Whitelist")
                return (type(a)=="table" and a[pl.UserId])==true or (type(b)=="table" and b[pl.UserId])==true
            end

            function R.downState(pl)
                local char=pl and pl.Character
                if not char then return true,"missing" end
                local known=false
                pcall(function() known=IsKnocked(char)==true end)
                if known then return true,"ko" end
                local hum=char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health<=0 then return true,"dead" end
                local names={ko=true,["k.o"]=true,knocked=true,downed=true,dead=true,unconscious=true}
                for _,d in ipairs(char:GetDescendants()) do
                    if names[d.Name:lower()] then
                        if d:IsA("BoolValue") and d.Value then return true,"ko" end
                        if (d:IsA("IntValue") or d:IsA("NumberValue")) and d.Value~=0 then return true,"ko" end
                    end
                end
                return false,"alive"
            end

            function R.stompable(pl)
                local down,kind=R.downState(pl)
                return down and kind~="missing"
            end

            function R.selectable(pl)
                return pl and pl~=lp and pl.Parent==R.Players and not (R.skipWhitelisted and R.isWhitelisted(pl))
            end

            function R.targetRoot(pl)
                local c=pl and pl.Character
                return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("LowerTorso")) or nil
            end

            function R.localRoot()
                local c=lp.Character
                return c and c:FindFirstChild("HumanoidRootPart") or nil
            end

            function R.distance(pl)
                local a,b=R.localRoot(),R.targetRoot(pl)
                return (a and b) and (a.Position-b.Position).Magnitude or math.huge
            end

            function R.health(pl)
                local h=pl and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
                return h and h.Health or math.huge
            end

            function R.queueIndex(id)
                for i,v in ipairs(R.queue) do if v==id then return i end end
                return nil
            end

            function R.selectedCount()
                return #R.queue
            end

            function R.currentId()
                if R.master and #R.runIds>0 then
                    R.runIndex=math.clamp(R.runIndex,1,#R.runIds)
                    return R.runIds[R.runIndex]
                end
                if #R.queue==0 then return nil end
                R.activeIndex=math.clamp(R.activeIndex,1,#R.queue)
                return R.queue[R.activeIndex]
            end

            function R.currentPlayer()
                local id=R.currentId()
                return id and R.Players:GetPlayerByUserId(id) or nil
            end

            function R.activeText()
                local pl=R.currentPlayer()
                if not pl then return "No active target" end
                return pl.DisplayName.."  (@"..pl.Name..")"
            end

            function R.refreshSelectedLabels()
                local txt=("Selected %d  ♡  %s"):format(#R.queue,R.activeText())
                for _,l in ipairs(R.ui.selectedLabels) do if l and l.Parent then l.Text=txt end end
            end

            function R.sortIds(ids)
                if R.queueOrder=="Closest" then
                    table.sort(ids,function(a,b) return R.distance(R.Players:GetPlayerByUserId(a))<R.distance(R.Players:GetPlayerByUserId(b)) end)
                elseif R.queueOrder=="Lowest Health" then
                    table.sort(ids,function(a,b)
                        local pa,pb=R.Players:GetPlayerByUserId(a),R.Players:GetPlayerByUserId(b)
                        local ha,hb=R.health(pa),R.health(pb)
                        if math.abs(ha-hb)<.001 then return R.distance(pa)<R.distance(pb) end
                        return ha<hb
                    end)
                elseif R.queueOrder=="Random" then
                    for i=#ids,2,-1 do local j=math.random(1,i); ids[i],ids[j]=ids[j],ids[i] end
                end
                return ids
            end

            function R.addTarget(pl)
                if not R.selectable(pl) or R.selected[pl.UserId] then return false end
                R.selected[pl.UserId]=true
                table.insert(R.queue,pl.UserId)
                if #R.queue==1 then R.activeIndex=1 end
                R.refreshQueueUI()
                if R.showPreview then R.showPreview(pl) end
                return true
            end

            function R.removeTarget(id)
                local idx=R.queueIndex(id)
                if not idx then return false end
                R.selected[id]=nil
                table.remove(R.queue,idx)
                if #R.queue==0 then R.activeIndex=1 else R.activeIndex=math.clamp(R.activeIndex,1,#R.queue) end
                R.refreshQueueUI()
                return true
            end

            function R.toggleTarget(pl)
                if not pl or pl==lp then return end
                if R.selected[pl.UserId] then R.removeTarget(pl.UserId) else
                    R.addTarget(pl)
                    local idx=R.queueIndex(pl.UserId)
                    if idx then R.activeIndex=idx end
                    R.refreshQueueUI()
                end
            end

            function R.selectAll()
                R.queue={}
                R.selected={}
                for _,pl in ipairs(R.Players:GetPlayers()) do
                    if R.selectable(pl) then R.selected[pl.UserId]=true; table.insert(R.queue,pl.UserId) end
                end
                R.sortIds(R.queue)
                R.activeIndex=1
                R.refreshQueueUI()
            end

            function R.clearQueue()
                R.queue={}
                R.selected={}
                R.activeIndex=1
                if R.master then R.stopRun("Queue cleared") end
                R.refreshQueueUI()
                if R.showPreview then R.showPreview(nil) end
            end

            function R.setActiveById(id)
                local idx=R.queueIndex(id)
                if idx then
                    R.activeIndex=idx
                    R.refreshQueueUI()
                    if R.showPreview then R.showPreview(R.currentPlayer()) end
                    return true
                end
                return false
            end

            function R.manualAdvance(step)
                if R.master or #R.queue<1 then return end
                R.activeIndex=((R.activeIndex-1+(step or 1))%#R.queue)+1
                R.camTargetId=nil
                R.refreshQueueUI()
            end

            function R.buildRun(scope)
                local ids={}
                if scope=="solo" then
                    local id=R.currentId()
                    if id then table.insert(ids,id) end
                else
                    for _,id in ipairs(R.queue) do table.insert(ids,id) end
                end
                R.sortIds(ids)
                R.runIds=ids
                R.runIndex=1
                R.completed={}
                R.runScope=scope or "all"
                return #ids>0
            end

            function R.findNextRunIndex(from)
                if #R.runIds==0 then return nil end
                for i=from or 1,#R.runIds do
                    local id=R.runIds[i]
                    if not R.completed[id] then
                        local pl=R.Players:GetPlayerByUserId(id)
                        if pl and pl~=lp and pl.Parent==R.Players and not (R.skipWhitelisted and R.isWhitelisted(pl)) then
                            local down=R.downState(pl)
                            if not (R.skipDowned and down) then return i end
                        else
                            R.completed[id]=true
                        end
                    end
                end
                return nil
            end

            function R.releaseMovement()
                -- v2.86: RAGE must be completely passive while it does not own
                -- character movement. The older V3 heartbeat called this every
                -- frame while idle, which continuously zeroed the local root's
                -- angular velocity and made normal turning/circle movement feel
                -- constrained even with RAGE switched off.
                if not R.movementOwned and R.savedHumanoid==nil and R.savedAutoRotate==nil then
                    return
                end
                local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if R.savedHumanoid and R.savedHumanoid.Parent and R.savedAutoRotate~=nil then
                    pcall(function() R.savedHumanoid.AutoRotate=R.savedAutoRotate end)
                elseif hum then
                    pcall(function() hum.AutoRotate=true end)
                end
                R.savedHumanoid=nil
                R.savedAutoRotate=nil
                R.movementOwned=false
                local root=R.localRoot()
                if root then pcall(function() root.AssemblyAngularVelocity=Vector3.zero end) end
            end

            function R.captureMovement(hum)
                if hum and R.savedHumanoid~=hum then
                    R.releaseMovement()
                    R.savedHumanoid=hum
                    R.savedAutoRotate=hum.AutoRotate
                    R.movementOwned=true
                elseif hum and R.savedHumanoid==hum then
                    R.movementOwned=true
                end
            end

            function R.restoreCamera()
                local cam=workspace.CurrentCamera
                if not cam then return end
                local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                pcall(function()
                    cam.CameraType=Enum.CameraType.Custom
                    if hum then cam.CameraSubject=hum end
                end)
                R.camOffset=nil
                R.camTargetId=nil
                R.freeView=false
            end

            function R.startCamFor(pl)
                local cam=workspace.CurrentCamera
                local part=R.getPart(pl,R.hitPart)
                if not cam or not part then return false end
                if R.camTargetId~=pl.UserId or not R.camOffset then
                    local delta=cam.CFrame.Position-part.Position
                    if delta.Magnitude<6 or delta.Magnitude>35 then delta=-cam.CFrame.LookVector*12+Vector3.new(0,2.4,0) end
                    R.camOffset=delta
                    R.camTargetId=pl.UserId
                end
                R.camLock=true
                return true
            end

            function R.getPart(pl,choice)
                local char=pl and pl.Character
                if not char then return nil end
                choice=choice or R.hitPart
                if choice=="Closest Part" then
                    local mouse=R.UIS:GetMouseLocation()
                    local best,bestD=nil,math.huge
                    for _,n in ipairs({"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}) do
                        local part=char:FindFirstChild(n)
                        if part and part:IsA("BasePart") then
                            local v,on=workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                            if on then
                                local d=(Vector2.new(v.X,v.Y)-mouse).Magnitude
                                if d<bestD then bestD=d; best=part end
                            end
                        end
                    end
                    if best then return best end
                end
                return char:FindFirstChild(choice) or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            end

            function R.isWeaponTool(tool)
                if not tool or not tool:IsA("Tool") then return false end
                local low=string.lower(tostring(tool.Name or ""))
                if low:find("angel wing",1,true) or low:find("knife",1,true) or low:find("wallet",1,true)
                    or low:find("phone",1,true) or low:find("food",1,true) then return false end
                if table.find(R.knownWeapons,tool.Name) then return true end
                if not R.useMyWeapons then return false end
                local ammo=R.ammo and R.ammo(tool) or nil
                if ammo~=nil then return true end
                return low:find("gun",1,true)~=nil or low:find("pistol",1,true)~=nil
                    or low:find("revolver",1,true)~=nil or low:find("shotgun",1,true)~=nil
                    or low:find("smg",1,true)~=nil or low:find("rifle",1,true)~=nil
                    or low:find("silencer",1,true)~=nil or low:find("drum",1,true)~=nil
                    or low:find("glock",1,true)~=nil or low:find("uzi",1,true)~=nil
            end

            function R.findGun()
                local char=lp.Character
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hum then return nil end

                -- Always respect the weapon the user already has equipped first.
                local equipped=char:FindFirstChildOfClass("Tool")
                if equipped and R.isWeaponTool(equipped) then return equipped end

                local backpack=lp:FindFirstChildOfClass("Backpack")
                if not backpack then return nil end

                -- Prefer the game's known combat weapons so their profiles still apply.
                for _,name in ipairs(R.knownWeapons) do
                    local tool=backpack:FindFirstChild(name)
                    if tool and tool:IsA("Tool") then
                        pcall(function() hum:EquipTool(tool) end)
                        return tool
                    end
                end

                -- Then allow the user's other ammo-bearing / gun-like tools.
                if R.useMyWeapons then
                    for _,tool in ipairs(backpack:GetChildren()) do
                        if R.isWeaponTool(tool) then
                            pcall(function() hum:EquipTool(tool) end)
                            return tool
                        end
                    end
                end
                return nil
            end

            R.ammoNames={"Clip","Magazine","Mag","CurrentAmmo","Ammo","Bullets"}
            function R.ammo(tool)
                if not tool then return nil end
                for _,name in ipairs(R.ammoNames) do
                    local o=tool:FindFirstChild(name,true)
                    if o then
                        if o:IsA("IntValue") or o:IsA("NumberValue") then return tonumber(o.Value) end
                        if o:IsA("StringValue") then
                            local n=tonumber(tostring(o.Value):match("%-?%d+%.?%d*")); if n~=nil then return n end
                        end
                    end
                    local attr=nil; pcall(function() attr=tool:GetAttribute(name) end)
                    if type(attr)=="number" then return attr end
                end
                return nil
            end

            function R.pressKey(code,virtual)
                if R.VIM then
                    pcall(function() R.VIM:SendKeyEvent(true,code,false,game); task.wait(.028); R.VIM:SendKeyEvent(false,code,false,game) end)
                end
                if type(keytap)=="function" then pcall(keytap,virtual) elseif type(keypress)=="function" then
                    pcall(keypress,virtual); task.wait(.028); if type(keyrelease)=="function" then pcall(keyrelease,virtual) end
                end
            end

            function R.reload(tool)
                if not R.autoReload or not tool then return false end
                local ammo=R.ammo(tool)
                if ammo==nil or ammo>0 then return false end
                if R.reloadBusy or os.clock()-R.lastReload<.55 then return true end
                R.reloadBusy=true
                R.lastReload=os.clock()
                task.spawn(function()
                    R.pressKey(Enum.KeyCode.R,0x52)
                    local ev=R.ReplicatedStorage:FindFirstChild("MainEvent")
                    if ev and ev:IsA("RemoteEvent") then pcall(function() ev:FireServer("Reload",tool) end) end
                    local deadline=os.clock()+2.6
                    repeat
                        task.wait(.08)
                        if not tool.Parent then break end
                        local n=R.ammo(tool)
                        if n==nil or n>0 then break end
                    until os.clock()>=deadline
                    R.reloadBusy=false
                end)
                return true
            end

            R.weaponProfiles={
                ["[Revolver]"]={delay=.105},
                ["[DoubleBarrel]"]={delay=.14},
                ["[Shotgun]"]={delay=.135},
                ["[TacticalShotgun]"]={delay=.095},
                ["[SMG]"]={delay=.045},
                ["[Silencer]"]={delay=.06},
            }

            function R.profile(tool)
                return tool and R.weaponProfiles[tool.Name] or nil
            end

            function R.effectiveDelay(tool)
                local p=R.profile(tool)
                return math.max(.020,p and math.min(R.fireDelay,p.delay) or R.fireDelay)
            end

            function R.shoot(pl)
                if not pl or R.finishBusy or R.shotBusy or R.downState(pl) then return false end
                local tool=R.findGun()
                if not tool or R.reload(tool) then return false end

                -- v2.107: RAGE has no Force Hit / forced-damage firing path.
                -- It selects the current queued player for the EXISTING Silent Aim
                -- resolver, then fires the user's equipped weapon normally.
                _G.KimqRageSilentAimTargetId=pl.UserId
                pcall(function() tool:Activate() end)
                return true
            end

            function R.tryWings()
                if not R.autoWings or os.clock()-R.lastWingTry<1.2 then return end
                R.lastWingTry=os.clock()
                local char=lp.Character
                if not char or char:FindFirstChild("KimqWornAngelWings") then return end
                pcall(function()
                    local ctl=_G.KimqWeaponExtrasController
                    if not ctl and type(getgenv)=="function" then ctl=getgenv().KimqWeaponExtrasController end
                    if ctl and type(ctl.EquipItem)=="function" then ctl.EquipItem("Angel Wings") end
                end)
            end

            function R.stompCFrame(pl)
                local tr=R.targetRoot(pl)
                local root=R.localRoot()
                if not (tr and root) then return nil end
                local look=Vector3.new(tr.CFrame.LookVector.X,0,tr.CFrame.LookVector.Z)
                if look.Magnitude<.05 then look=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
                if look.Magnitude<.05 then look=Vector3.new(0,0,-1) else look=look.Unit end
                local pos=tr.Position+Vector3.new(0,1.35,0)
                return CFrame.lookAt(pos,pos+look)
            end

            function R.placeForStomp(pl)
                local cf=R.stompCFrame(pl)
                local char=lp.Character
                local root=R.localRoot()
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if not (cf and char and root and hum) then return false end
                R.captureMovement(hum)
                pcall(function()
                    hum.PlatformStand=false
                    hum.Sit=false
                    hum.AutoRotate=false
                    char:PivotTo(cf)
                    root.CFrame=cf
                    root.AssemblyLinearVelocity=Vector3.zero
                    root.AssemblyAngularVelocity=Vector3.zero
                end)
                return true
            end

            function R.lockOnStompTarget(pl,duration,pressAt,token)
                duration=math.max(.10,tonumber(duration) or .34)
                pressAt=math.clamp(tonumber(pressAt) or .08,.02,duration)
                local started=os.clock()
                local pressed=false
                while R.master and token==R.runToken and pl and pl.Parent and os.clock()-started<duration do
                    if not R.stompable(pl) then break end
                    if not R.placeForStomp(pl) then break end
                    local elapsed=os.clock()-started
                    if not pressed and elapsed>=pressAt then
                        if R.autoStomp then R.pressStomp() end
                        pressed=true
                    end
                    R.RunService.Heartbeat:Wait()
                end
                if not pressed and R.master and token==R.runToken and R.stompable(pl) and R.placeForStomp(pl) then
                    if R.autoStomp then R.pressStomp() end
                    pressed=true
                end
                return pressed
            end

            function R.pressStomp()
                R.pressKey(Enum.KeyCode.E,0x45)
                local ev=R.ReplicatedStorage:FindFirstChild("MainEvent")
                if ev and ev:IsA("RemoteEvent") then pcall(function() ev:FireServer("Stomp") end) end
            end

            function R.readyForFreshAttack(pl)
                if not pl or pl==lp or not pl.Parent then return false end
                if R.skipWhitelisted and R.isWhitelisted(pl) then return false end
                local char=pl.Character
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                local root=char and char:FindFirstChild("HumanoidRootPart")
                if not char or not hum or not root or hum.Health<=0 then return false end
                return not R.downState(pl)
            end

            function R.findLoopReadyIndex()
                if #R.runIds==0 then return nil end
                for i,id in ipairs(R.runIds) do
                    local pl=R.Players:GetPlayerByUserId(id)
                    if pl and not R.completed[id] and R.readyForFreshAttack(pl) then return i end
                end
                return nil
            end

            function R.beginLoopCycle()
                if not R.master or not R.loopKills then return false end
                R.completed={}
                R.loopCycle=(R.loopCycle or 0)+1
                R.runIndex=1
                R.phase="WAIT RESPAWN"
                R.phaseTarget=nil
                _G.KimqRageSilentAimTargetId=nil
                R.finishBusy=false
                R.shotBusy=false
                R.fireClock=0
                R.camTargetId=nil
                R.orbitAngle=0
                R.releaseMovement()
                R.refreshQueueUI()
                return true
            end

            function R.completeCurrent(id)
                R.completed[id]=true
                R.finishBusy=false
                if not R.master then return end

                if R.runScope=="solo" then
                    if R.loopKills then
                        R.beginLoopCycle()
                    else
                        R.stopRun("Target finished ♡")
                    end
                    return
                end

                if not R.autoAdvance then
                    if R.loopKills then R.beginLoopCycle() else R.stopRun("Target finished ♡") end
                    return
                end

                local nextIndex=R.findNextRunIndex(R.runIndex+1)
                if not nextIndex then
                    if R.loopKills then
                        R.beginLoopCycle()
                    else
                        R.stopRun("Queue complete ♡")
                        R.notify("RAGE queue finished ♡",3)
                    end
                    return
                end

                R.runIndex=nextIndex
                R.phase="ACQUIRE"
                R.phaseTarget=R.runIds[R.runIndex]
                R.camTargetId=nil
                R.orbitAngle=0
                task.wait(.06)
                R.refreshQueueUI()
            end

            function R.finishTarget(pl)
                if R.finishBusy or not pl then return end
                local id=pl.UserId
                R.finishBusy=true
                R.phase="STOMP"
                R.phaseTarget=id
                R.fireClock=0
                _G.KimqRageSilentAimTargetId=nil
                R.releaseMovement()
                R.runToken+=1
                local token=R.runToken

                -- v2.88: stop orbit/fire, then stay directly above the knocked
                -- target for the entire E-input window. Retry only once if needed.
                task.spawn(function()
                    local maxAttempts=math.clamp(math.floor(tonumber(R.stompAttempts) or 2),1,2)
                    local attempts=0
                    while R.master and token==R.runToken and pl.Parent and attempts<maxAttempts do
                        if not R.stompable(pl) then break end
                        attempts+=1
                        if R.stompLock then
                            R.lockOnStompTarget(pl,R.stompLockTime,.075,token)
                        else
                            if not R.placeForStomp(pl) then break end
                            task.wait(.04)
                            if R.autoStomp then R.pressStomp() end
                        end
                        task.wait(.12)
                        local char=pl.Character
                        local hum=char and char:FindFirstChildOfClass("Humanoid")
                        if not char or not hum or hum.Health<=0 or not R.stompable(pl) then break end
                    end
                    if token~=R.runToken then return end
                    R.phase="CONFIRM"
                    R.releaseMovement()
                    task.wait(.05)
                    R.completeCurrent(id)
                end)
            end

            function R.stopRun(reason)
                R.master=false
                R.loopKills=false
                R.phase="IDLE"
                R.phaseTarget=nil
                _G.KimqRageSilentAimTargetId=nil
                R.finishBusy=false
                R.shotBusy=false
                R.runToken+=1
                R.runIds={}
                R.runIndex=1
                R.fireClock=0
                R.releaseMovement()
                if not R.orbitMaster then R.orbitAngle=0 end
                if not R.camLock and not R.freeView then R.restoreCamera() end
                local ctl=R.ui.controls.master
                if ctl then pcall(ctl,false,true) end
                R.refreshQueueUI()
                if reason then R.notify(reason,2.5) end
            end

            function R.startRun(scope)
                if #R.queue==0 then R.notify("Pick RAGE targets first ♡",3); return false end
                if not R.buildRun(scope or "all") then return false end
                local idx=R.findNextRunIndex(1)
                if not idx then R.notify("No valid targets in queue ♡",3); return false end
                R.runIndex=idx
                R.master=true
                R.phase="ACQUIRE"
                R.phaseTarget=R.runIds[R.runIndex]
                R.finishBusy=false
                R.runToken+=1
                R.camTargetId=nil
                R.orbitAngle=0
                R.refreshQueueUI()
                return true
            end

            function R.applyOpSettings(scope,style)
                -- MAX preset owns the complete loop: acquire/equip user's weapon ->
                -- orbit -> auto shoot/reload -> K.O. -> lock on top -> stomp -> next ->
                -- wait for respawn -> repeat until STOP / CALM.
                R.loopKills=R.presetLoopKills==true
                R.autoShoot=R.presetAutoShoot==true
                R.useMyWeapons=true
                R.autoReload=true
                R.autoStomp=true
                R.autoAdvance=scope~="solo"
                R.antiLock=true
                R.camLock=true
                R.hudEnabled=false
                R.skipDowned=false
                R.skipWhitelisted=true
                R.stompLock=true
                R.autoWings=false
                R.hitPart="Head"
                R.fireDelay=.020
                R.stompAttempts=2
                R.stompLockTime=.42
                if style=="close" then
                    R.orbitSpeed=20
                    R.orbitRadius=2.6
                    R.orbitHeight=2.05
                    R.queueOrder="Closest"
                elseif style=="health" then
                    R.orbitSpeed=20
                    R.orbitRadius=2.85
                    R.orbitHeight=2.15
                    R.queueOrder="Lowest Health"
                else
                    R.orbitSpeed=19
                    R.orbitRadius=3.0
                    R.orbitHeight=2.2
                end
                for name,setter in pairs(R.ui.controls) do
                    if type(setter)=="function" then
                        if name=="autoShoot" then pcall(setter,R.autoShoot,true)
                        elseif name=="autoReload" then pcall(setter,true,true)
                        elseif name=="autoStomp" then pcall(setter,true,true)
                        elseif name=="autoAdvance" then pcall(setter,R.autoAdvance,true)
                        elseif name=="skipDown" then pcall(setter,false,true)
                        elseif name=="skipWL" then pcall(setter,true,true)
                        elseif name=="stompLock" then pcall(setter,true,true)
                        elseif name=="antiLock" then pcall(setter,true,true)
                        elseif name=="camLock" then pcall(setter,true,true)
                        elseif name=="hitPart" then pcall(setter,"Head",true)
                        elseif name=="queueOrder" then pcall(setter,R.queueOrder,true)
                        elseif name=="fireDelay" then pcall(setter,R.fireDelay,true)
                        elseif name=="stompAttempts" then pcall(setter,R.stompAttempts,true)
                        elseif name=="orbitSpeed" then pcall(setter,R.orbitSpeed,true)
                        elseif name=="orbitRadius" then pcall(setter,R.orbitRadius,true)
                        elseif name=="orbitHeight" then pcall(setter,R.orbitHeight,true)
                        elseif name=="wings" then pcall(setter,false,true) end
                    end
                end
                R.startRun(scope)
                if R.ui.controls.master then pcall(R.ui.controls.master,true,true) end
            end

            R.previewToken=0
            R.previewViewport=nil
            R.previewTitle=nil
            R.previewWorld=nil
            R.previewPoseResolved=nil
            R.previewPoseTrack=nil

            function R.resolvePreviewPoseId()
                if R.previewPoseResolved then return R.previewPoseResolved end
                local direct="rbxassetid://114788518778194"
                local resolved=direct
                local ok,objs=pcall(function() return game:GetObjects(direct) end)
                if ok and type(objs)=="table" then
                    for _,obj in ipairs(objs) do
                        local anim=obj:IsA("Animation") and obj or obj:FindFirstChildWhichIsA("Animation",true)
                        if anim and tostring(anim.AnimationId or "")~="" then
                            resolved=tostring(anim.AnimationId)
                            break
                        end
                    end
                    for _,obj in ipairs(objs) do pcall(function() obj:Destroy() end) end
                end
                R.previewPoseResolved=resolved
                return resolved
            end

            function R.playPreviewPose(model)
                local hum=model and model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.RigType~=Enum.HumanoidRigType.R15 then return nil end
                local animator=hum:FindFirstChildOfClass("Animator")
                if not animator then animator=Instance.new("Animator"); animator.Parent=hum end
                pcall(function()
                    for _,tr in ipairs(animator:GetPlayingAnimationTracks()) do tr:Stop(0) end
                end)
                local anim=Instance.new("Animation")
                anim.AnimationId=R.resolvePreviewPoseId()
                local ok,track=pcall(function() return animator:LoadAnimation(anim) end)
                anim:Destroy()
                if ok and track then
                    pcall(function()
                        track.Looped=true
                        track.Priority=Enum.AnimationPriority.Action4
                        track:Play(.08,1,1)
                    end)
                    R.previewPoseTrack=track
                    return track
                end
                return nil
            end

            function R.resetPreviewPose(model,track)
                if track then pcall(function() track:Stop(.05) end) end
                if model then
                    for _,d in ipairs(model:GetDescendants()) do
                        if d:IsA("Motor6D") then pcall(function() d.Transform=CFrame.new() end) end
                    end
                end
                R.previewPoseTrack=nil
            end

            function R.previewPoseLooksBroken(model,baseSize,posedSize)
                if not model or not baseSize or not posedSize then return false end
                if posedSize.X>math.max(baseSize.X*1.85,baseSize.X+4)
                    or posedSize.Y>math.max(baseSize.Y*1.55,baseSize.Y+4)
                    or posedSize.Z>math.max(baseSize.Z*2.0,baseSize.Z+5) then
                    return true
                end
                local root=model:FindFirstChild("HumanoidRootPart")
                if root then
                    local limit=math.max(baseSize.Magnitude*1.35,12)
                    for _,d in ipairs(model:GetDescendants()) do
                        if d:IsA("BasePart") and (d.Position-root.Position).Magnitude>limit then return true end
                    end
                end
                return false
            end

            function R.clearPreview()
                R.previewToken+=1
                if R.previewPoseTrack then pcall(function() R.previewPoseTrack:Stop(.05) end) end
                R.previewPoseTrack=nil
                if R.previewWorld then pcall(function() R.previewWorld:Destroy() end) end
                R.previewWorld=nil
                if R.previewViewport and R.previewViewport.Parent then
                    for _,ch in ipairs(R.previewViewport:GetChildren()) do
                        if ch:IsA("WorldModel") or ch:IsA("Camera") then
                            pcall(function() ch:Destroy() end)
                        end
                    end
                    R.previewViewport.CurrentCamera=nil
                end
            end

            function R.showPreview(pl)
                if not R.previewViewport or not R.previewViewport.Parent then return end
                R.clearPreview()
                local token=R.previewToken
                if not pl then
                    if R.previewTitle then R.previewTitle.Text="Hover a player" end
                    return
                end
                if R.previewTitle then R.previewTitle.Text="loading "..pl.DisplayName.."..." end

                task.spawn(function()
                    local model=nil
                    local ok=pcall(function()
                        model=R.Players:CreateHumanoidModelFromUserId(pl.UserId)
                    end)
                    if not ok or not model or token~=R.previewToken or not R.previewViewport or not R.previewViewport.Parent then
                        if model then pcall(function() model:Destroy() end) end
                        if token==R.previewToken and R.previewTitle and R.previewTitle.Parent then
                            R.previewTitle.Text="hover again • preview didn't load"
                        end
                        return
                    end

                    if R.previewTitle then R.previewTitle.Text=pl.DisplayName.."  •  @"..pl.Name end
                    local world=Instance.new("WorldModel")
                    world.Name="KimqRagePreviewWorld"
                    world.Parent=R.previewViewport
                    R.previewWorld=world
                    model.Parent=world

                    local root=model:FindFirstChild("HumanoidRootPart")
                    for _,d in ipairs(model:GetDescendants()) do
                        if d:IsA("BasePart") then
                            d.CanCollide=false
                            d.CastShadow=false
                            d.Massless=true
                            d.Anchored=(d==root)
                        elseif d:IsA("Humanoid") then
                            pcall(function()
                                d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
                                d.AutoRotate=false
                            end)
                        end
                    end

                    local okBox,cf,size=pcall(function() return model:GetBoundingBox() end)
                    if not okBox then pcall(function() world:Destroy() end); return end
                    local bottom=cf.Position.Y-(size.Y*.5)
                    pcall(function()
                        model:PivotTo(CFrame.new(-cf.Position.X,-bottom+.08,-cf.Position.Z)*model:GetPivot())
                    end)
                    local okBox2,cf2,size2=pcall(function() return model:GetBoundingBox() end)
                    if okBox2 then cf,size=cf2,size2 end

                    local p=R.pal()
                    local platform=Instance.new("Part")
                    platform.Name="KimqRagePreviewPlatform"
                    platform.Shape=Enum.PartType.Cylinder
                    platform.Size=Vector3.new(.30,5.6,5.6)
                    platform.Material=Enum.Material.SmoothPlastic
                    platform.Color=p.soft or T.bg2
                    platform.Transparency=.04
                    platform.Anchored=true
                    platform.CanCollide=false
                    platform.CastShadow=false
                    platform.CFrame=CFrame.new(0,-.14,0)*CFrame.Angles(0,0,math.rad(90))
                    platform.Parent=world
                    R.role(platform,"lightBg")

                    local ring=Instance.new("Part")
                    ring.Name="KimqRagePreviewRing"
                    ring.Shape=Enum.PartType.Cylinder
                    ring.Size=Vector3.new(.08,6.05,6.05)
                    ring.Material=Enum.Material.Neon
                    ring.Color=p.hot or T.hot
                    ring.Transparency=.12
                    ring.Anchored=true
                    ring.CanCollide=false
                    ring.CastShadow=false
                    ring.CFrame=CFrame.new(0,.025,0)*CFrame.Angles(0,0,math.rad(90))
                    ring.Parent=world
                    R.role(ring,"hotBg")

                    -- Restore the animated R15 hover pose from the classic preview.
                    -- If a package is incompatible and stretches apart, fall back to
                    -- the normal standing model rather than showing a broken preview.
                    local baseSize=size
                    local poseTrack=R.playPreviewPose(model)
                    if poseTrack then
                        task.wait(.12)
                        if token~=R.previewToken or not model.Parent then return end
                        local okPose,poseCF,poseSize=pcall(function() return model:GetBoundingBox() end)
                        if okPose then
                            local poseBottom=poseCF.Position.Y-(poseSize.Y*.5)
                            pcall(function()
                                model:PivotTo(CFrame.new(-poseCF.Position.X,-poseBottom+.08,-poseCF.Position.Z)*model:GetPivot())
                            end)
                            local okPose2,poseCF2,poseSize2=pcall(function() return model:GetBoundingBox() end)
                            if okPose2 then poseCF,poseSize=poseCF2,poseSize2 end
                            if R.previewPoseLooksBroken(model,baseSize,poseSize) then
                                R.resetPreviewPose(model,poseTrack)
                                task.wait(.05)
                                local okReset,resetCF,resetSize=pcall(function() return model:GetBoundingBox() end)
                                if okReset then
                                    local resetBottom=resetCF.Position.Y-(resetSize.Y*.5)
                                    pcall(function()
                                        model:PivotTo(CFrame.new(-resetCF.Position.X,-resetBottom+.08,-resetCF.Position.Z)*model:GetPivot())
                                    end)
                                    local okReset2,resetCF2,resetSize2=pcall(function() return model:GetBoundingBox() end)
                                    if okReset2 then cf,size=resetCF2,resetSize2 else cf,size=resetCF,resetSize end
                                end
                            else
                                cf,size=poseCF,poseSize
                            end
                        end
                    end

                    local cam=Instance.new("Camera")
                    cam.Name="KimqRagePreviewCamera"
                    cam.FieldOfView=27
                    cam.Parent=R.previewViewport
                    R.previewViewport.CurrentCamera=cam
                    local vfov=math.rad(cam.FieldOfView)
                    local abs=R.previewViewport.AbsoluteSize
                    local aspect=math.max(abs.X/math.max(abs.Y,1),.45)
                    local tanV=math.tan(vfov*.5)
                    local tanH=tanV*aspect
                    local fitHeight=size.Y/(2*math.max(tanV,.01))
                    local fitWidth=math.max(size.X,size.Z*.70)/(2*math.max(tanH,.01))
                    local dist=math.clamp(math.max(fitHeight,fitWidth)*1.27,7,40)
                    local focus=Vector3.new(0,math.max(size.Y*.47,1.45),0)
                    cam.CFrame=CFrame.lookAt(Vector3.new(0,focus.Y,-dist),focus,Vector3.yAxis)
                end)
            end

            function R.refreshQueueUI()
                R.refreshSelectedLabels()
                if R.ui.playerList and R.ui.playerList.Parent then
                    for _,ch in ipairs(R.ui.playerList:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
                    local list={}
                    for _,pl in ipairs(R.Players:GetPlayers()) do if pl~=lp then table.insert(list,pl) end end
                    table.sort(list,function(a,b) return a.DisplayName:lower()<b.DisplayName:lower() end)
                    local active=R.currentId()
                    for i,pl in ipairs(list) do
                        local targetPl=pl
                        local selected=R.selected[targetPl.UserId]==true
                        local isActive=active==targetPl.UserId
                        local b=R.button(R.ui.playerList,"",UDim2.new(),UDim2.new(1,-2,0,48),function() R.toggleTarget(targetPl) end)
                        b.LayoutOrder=i
                        if selected then
                            b.BackgroundColor3=R.pal().hot or T.hot
                            b:SetAttribute("KimqV26Role","hotBg")
                        end
                        if isActive then
                            local st=b:FindFirstChildOfClass("UIStroke")
                            if st then st.Thickness=2 end
                        end
                        local prefix=selected and ("✓ #"..tostring(R.queueIndex(targetPl.UserId) or "")) or "+"
                        local col=selected and (R.pal().white or Color3.new(1,1,1)) or (R.pal().hot or T.hot)
                        R.role(R.label(b,prefix,UDim2.fromOffset(48,48),UDim2.fromOffset(6,0),Enum.Font.GothamBold,10,col,Enum.TextXAlignment.Center),selected and "whiteText" or "hotText")
                        R.role(R.label(b,targetPl.DisplayName,UDim2.new(1,-58,0,22),UDim2.fromOffset(54,4),Enum.Font.GothamBold,11,selected and (R.pal().white or Color3.new(1,1,1)) or (R.pal().text or T.text)),selected and "whiteText" or "textText")
                        R.role(R.label(b,"@"..targetPl.Name,UDim2.new(1,-58,0,16),UDim2.fromOffset(54,26),Enum.Font.Gotham,9,selected and (R.pal().white or Color3.new(1,1,1)) or (R.pal().sub or T.sub)),selected and "whiteText" or "subText")
                        b.MouseEnter:Connect(function() R.showPreview(targetPl) end)
                        b.MouseLeave:Connect(function() R.showPreview(R.currentPlayer()) end)
                    end
                end
                R.updateHud()
            end

            function R.destroyMiniHud()
                R.hudEnabled=false
                if R.ui.hud then pcall(function() R.ui.hud:Destroy() end) end
                R.ui.hud=nil
                for _,old in ipairs(gui:GetChildren()) do
                    if old.Name=="KimqRageMiniHUD" then pcall(function() old:Destroy() end) end
                end
            end

            function R.buildHud()
                R.destroyMiniHud()
            end

            function R.refreshHudTheme()
                local p=R.pal()
                if R.previewWorld and R.previewWorld.Parent then
                    local platform=R.previewWorld:FindFirstChild("KimqRagePreviewPlatform")
                    local ring=R.previewWorld:FindFirstChild("KimqRagePreviewRing")
                    if platform and platform:IsA("BasePart") then platform.Color=p.soft or T.bg2 end
                    if ring and ring:IsA("BasePart") then ring.Color=p.hot or T.hot end
                end
            end
            _G.KimqRefreshRageMiniTheme=R.refreshHudTheme

            function R.updateHud()
                -- Mini hubs are intentionally removed in v2.89.
                return
            end

            -- ---------------- RAGE CAM / MULTI TARGET QUEUE ----------------
            do
                local chooser=R.card(R.pages.cam,338)

                local previewBox=Instance.new("Frame")
                previewBox.Parent=chooser
                previewBox.Position=UDim2.fromOffset(8,8)
                previewBox.Size=UDim2.new(.43,-12,1,-16)
                previewBox.BackgroundColor3=R.pal().panel or T.panel
                previewBox.BorderSizePixel=0
                R.role(previewBox,"panel")
                corner(previewBox,10)
                stroke(previewBox,R.pal().line or T.stroke,.28,1)

                R.previewTitle=R.role(R.label(previewBox,"Hover a player",UDim2.new(1,-12,0,34),UDim2.fromOffset(6,5),Enum.Font.GothamBold,11,R.pal().text or T.text,Enum.TextXAlignment.Center),"textText")

                local gradientBack=Instance.new("Frame")
                gradientBack.Parent=previewBox
                gradientBack.Position=UDim2.fromOffset(7,43)
                gradientBack.Size=UDim2.new(1,-14,0,220)
                gradientBack.BackgroundColor3=R.pal().soft or T.bg2
                gradientBack.BorderSizePixel=0
                R.role(gradientBack,"lightBg")
                corner(gradientBack,10)
                local grad=Instance.new("UIGradient")
                grad.Name="V26BannerGradient"
                grad.Parent=gradientBack
                grad.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,R.pal().soft or T.bg2),
                    ColorSequenceKeypoint.new(1,R.pal().hot or T.hot)
                })
                grad.Rotation=90

                R.previewViewport=Instance.new("ViewportFrame")
                R.previewViewport.Parent=gradientBack
                R.previewViewport.Size=UDim2.fromScale(1,1)
                R.previewViewport.BackgroundTransparency=1
                R.previewViewport.BorderSizePixel=0
                R.previewViewport.Ambient=Color3.new(1,1,1)
                R.previewViewport.LightColor=Color3.new(1,1,1)
                R.previewViewport.LightDirection=Vector3.new(-1,-1,-1)

                local sel=R.role(R.label(previewBox,"No targets selected",UDim2.new(1,-12,0,54),UDim2.fromOffset(6,270),Enum.Font.GothamSemibold,10,R.pal().sub or T.sub,Enum.TextXAlignment.Center),"subText")
                sel.TextWrapped=true
                table.insert(R.ui.selectedLabels,sel)

                local listBox=Instance.new("Frame")
                listBox.Parent=chooser
                listBox.Position=UDim2.new(.43,4,0,8)
                listBox.Size=UDim2.new(.57,-12,1,-16)
                listBox.BackgroundColor3=R.pal().panel or T.panel
                listBox.BorderSizePixel=0
                R.role(listBox,"panel")
                corner(listBox,10)
                stroke(listBox,R.pal().line or T.stroke,.28,1)

                R.role(R.label(listBox,"Target Queue",UDim2.new(1,-74,0,30),UDim2.fromOffset(10,5),Enum.Font.GothamBold,12,R.pal().text or T.text),"textText")
                R.button(listBox,"refresh",UDim2.new(1,-68,0,5),UDim2.fromOffset(58,28),function() R.refreshQueueUI() end)

                local list=Instance.new("ScrollingFrame")
                list.Parent=listBox
                list.Position=UDim2.fromOffset(8,40)
                list.Size=UDim2.new(1,-16,1,-48)
                list.BackgroundTransparency=1
                list.BorderSizePixel=0
                list.ScrollBarThickness=2
                list.ScrollBarImageColor3=R.pal().hot or T.hot
                R.ui.playerList=list
                local layout=Instance.new("UIListLayout")
                layout.Parent=list
                layout.Padding=UDim.new(0,5)
                layout.SortOrder=Enum.SortOrder.LayoutOrder
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+6)
                end)

                local actions=R.card(R.pages.cam,96)
                R.button(actions,"Select All",UDim2.fromOffset(10,8),UDim2.new(.25,-13,0,34),R.selectAll)
                R.button(actions,"Clear",UDim2.new(.25,3,0,8),UDim2.new(.25,-13,0,34),R.clearQueue)
                R.button(actions,"◀ Prev",UDim2.new(.5,6,0,8),UDim2.new(.25,-13,0,34),function() R.manualAdvance(-1) end)
                R.button(actions,"Next ▶",UDim2.new(.75,9,0,8),UDim2.new(.25,-19,0,34),function() R.manualAdvance(1) end)

                local viewButton
                viewButton=R.button(actions,"View",UDim2.fromOffset(10,52),UDim2.new(.5,-15,0,34),function()
                    local pl=R.currentPlayer()
                    local hum=pl and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
                    local cam=workspace.CurrentCamera
                    if not (hum and cam) then return end
                    R.freeView=not R.freeView
                    if R.freeView then
                        R.camLock=false
                        cam.CameraType=Enum.CameraType.Custom
                        cam.CameraSubject=hum
                        viewButton.Text="Unview"
                    else
                        R.restoreCamera()
                        viewButton.Text="View"
                    end
                end)
                R.button(actions,"Clear + Stop",UDim2.new(.5,5,0,52),UDim2.new(.5,-15,0,34),function()
                    R.clearQueue()
                    R.stopRun()
                    R.orbitMaster=false
                    R.camLock=false
                    R.freeView=false
                    R.releaseMovement()
                    R.restoreCamera()
                    R.updateHud()
                end)

                local _,setOrder=R.makeCycle(R.pages.cam,"Queue Order",{"Manual","Closest","Lowest Health","Random"},R.queueOrder,function(v) R.queueOrder=v end)
                R.ui.controls.queueOrder=setOrder
                local _,setSkipDown=R.makeToggle(R.pages.cam,"Skip Downed / Dead Targets",R.skipDowned,function(v) R.skipDowned=v end)
                R.ui.controls.skipDown=setSkipDown
                local _,setSkipWL=R.makeToggle(R.pages.cam,"Skip Whitelisted Targets",R.skipWhitelisted,function(v) R.skipWhitelisted=v end)
                R.ui.controls.skipWL=setSkipWL
                local _,setCam=R.makeToggle(R.pages.cam,"RAGE Target Camera",R.camLock,function(v) R.camLock=v; if not v and not R.freeView then R.restoreCamera() end end)
                R.ui.controls.camLock=setCam

                R.refreshQueueUI()
                R.showPreview(R.currentPlayer())
            end

            -- ---------------- TARGET ORBIT ----------------
            do
                local head=R.card(R.pages.orbit,76)
                R.role(R.label(head,"♥  Orbit Target",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,13,R.pal().hot or T.hot),"hotText")
                local sel=R.role(R.label(head,"No active target",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,37),Enum.Font.GothamSemibold,10,R.pal().sub or T.sub),"subText")
                table.insert(R.ui.selectedLabels,sel)
                local _,setOrbit=R.makeToggle(R.pages.orbit,"Target Orbit Master",R.orbitMaster,function(v) R.orbitMaster=v; if not v and not R.master then R.releaseMovement() end end)
                R.ui.controls.orbit=setOrbit
                local _,setAnti=R.makeToggle(R.pages.orbit,"Anti Lock / Evasive Orbit",R.antiLock,function(v) R.antiLock=v end)
                R.ui.controls.antiLock=setAnti
                local _,setWings=R.makeToggle(R.pages.orbit,"Use Angel Wings While Orbiting",R.autoWings,function(v) R.autoWings=v end)
                R.ui.controls.wings=setWings
                local _,setSpeed=R.makeSlider(R.pages.orbit,"Orbit Speed",.5,20,R.orbitSpeed,function(v) R.orbitSpeed=v end,function(v) return string.format("%.1fx",v) end)
                R.ui.controls.orbitSpeed=setSpeed
                local _,setRadius=R.makeSlider(R.pages.orbit,"Orbit Radius",2.5,18,R.orbitRadius,function(v) R.orbitRadius=v end,function(v) return string.format("%.1f",v) end)
                R.ui.controls.orbitRadius=setRadius
                local _,setHeight=R.makeSlider(R.pages.orbit,"Orbit Height",-1,12,R.orbitHeight,function(v) R.orbitHeight=v end,function(v) return string.format("%.1f",v) end)
                R.ui.controls.orbitHeight=setHeight
            end

            -- ---------------- RAGE COMBAT ----------------
            do
                local head=R.card(R.pages.combat,82)
                R.role(R.label(head,"♥  RAGE Combat",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,13,R.pal().hot or T.hot),"hotText")
                local sel=R.role(R.label(head,"Select targets in RAGE Camlock first ♡",UDim2.new(1,-24,0,30),UDim2.fromOffset(12,37),Enum.Font.GothamSemibold,10,R.pal().sub or T.sub),"subText")
                sel.TextWrapped=true
                table.insert(R.ui.selectedLabels,sel)

                local _,setMaster=R.makeToggle(R.pages.combat,"Rage Combat Master",false,function(v)
                    if v and not R.master then R.startRun("all") elseif not v and R.master then R.stopRun() end
                end)
                R.ui.controls.master=setMaster
                local _,setShoot=R.makeToggle(R.pages.combat,"Auto Shoot Current Target",R.autoShoot,function(v) R.autoShoot=v end)
                R.ui.controls.autoShoot=setShoot
                local _,setReload=R.makeToggle(R.pages.combat,"Auto Reload When Empty",R.autoReload,function(v) R.autoReload=v end)
                R.ui.controls.autoReload=setReload
                local _,setStomp=R.makeToggle(R.pages.combat,"Auto Stomp With E",R.autoStomp,function(v) R.autoStomp=v end)
                R.ui.controls.autoStomp=setStomp
                local _,setStompLock=R.makeToggle(R.pages.combat,"Lock On Top While Stomping",R.stompLock,function(v) R.stompLock=v end)
                R.ui.controls.stompLock=setStompLock
                local _,setAdvance=R.makeToggle(R.pages.combat,"Auto Advance After Finish",R.autoAdvance,function(v) R.autoAdvance=v end)
                R.ui.controls.autoAdvance=setAdvance
                local _,setPart=R.makeCycle(R.pages.combat,"RAGE Camera Focus",{"Head","UpperTorso","HumanoidRootPart","Closest Part"},R.hitPart,function(v) R.hitPart=v end)
                R.ui.controls.hitPart=setPart
                local _,setDelay=R.makeSlider(R.pages.combat,"Weapon Fire Interval",.020,.5,R.fireDelay,function(v) R.fireDelay=v end,function(v) return string.format("%.3fs",v) end)
                R.ui.controls.fireDelay=setDelay
                local _,setAttempts=R.makeSlider(R.pages.combat,"Stomp Attempts (1 + retry)",1,2,R.stompAttempts,function(v) R.stompAttempts=math.clamp(math.floor(v+.5),1,2) end,function(v) return tostring(math.clamp(math.floor(v+.5),1,2)) end)
                R.ui.controls.stompAttempts=setAttempts
            end

            -- ---------------- OP PRESETS ----------------
            do
                local c=R.card(R.pages.presets,238)
                R.role(R.label(c,"♥  MAX RAGE Presets",UDim2.new(1,-24,0,26),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,R.pal().hot or T.hot),"hotText")

                local autoShootBtn
                autoShootBtn=R.button(c,"AUTO SHOOT: ON",UDim2.fromOffset(12,44),UDim2.new(.5,-23,0,32),function()
                    R.presetAutoShoot=not R.presetAutoShoot
                    autoShootBtn.Text=R.presetAutoShoot and "AUTO SHOOT: ON" or "AUTO SHOOT: OFF"
                end)
                autoShootBtn.Text=R.presetAutoShoot and "AUTO SHOOT: ON" or "AUTO SHOOT: OFF"

                local loopBtn
                loopBtn=R.button(c,"LOOP KILLS: ON",UDim2.new(.5,5,0,44),UDim2.new(.5,-17,0,32),function()
                    R.presetLoopKills=not R.presetLoopKills
                    loopBtn.Text=R.presetLoopKills and "LOOP KILLS: ON" or "LOOP KILLS: OFF"
                end)
                loopBtn.Text=R.presetLoopKills and "LOOP KILLS: ON" or "LOOP KILLS: OFF"

                R.button(c,"OP ALL TARGETS",UDim2.fromOffset(12,88),UDim2.new(.5,-23,0,40),function()
                    if #R.queue==0 then R.selectAll() end
                    R.applyOpSettings("all","health")
                    R.notify("MAX ALL TARGETS armed ♡",2.4)
                end)
                R.button(c,"OP SOLO",UDim2.new(.5,5,0,88),UDim2.new(.5,-17,0,40),function()
                    R.applyOpSettings("solo","health")
                    R.notify("MAX SOLO armed ♡",2.4)
                end)
                R.button(c,"OP CLOSE HUNT",UDim2.fromOffset(12,138),UDim2.new(.5,-23,0,40),function()
                    if #R.queue==0 then R.selectAll() end
                    R.applyOpSettings("all","close")
                    R.notify("MAX CLOSE HUNT armed ♡",2.4)
                end)
                R.button(c,"STOP / CALM",UDim2.new(.5,5,0,138),UDim2.new(.5,-17,0,40),function()
                    R.stopRun()
                    R.autoShoot=false
                    R.orbitMaster=false
                    R.camLock=false
                    R.releaseMovement()
                    R.restoreCamera()
                    if R.ui.controls.autoShoot then pcall(R.ui.controls.autoShoot,false,true) end
                    if R.ui.controls.orbit then pcall(R.ui.controls.orbit,false,true) end
                    if R.ui.controls.camLock then pcall(R.ui.controls.camLock,false,true) end
                    R.updateHud()
                end)
            end

            R.destroyMiniHud()
            R.refreshQueueUI()
            R.Players.PlayerAdded:Connect(function() task.defer(R.refreshQueueUI) end)
            R.Players.PlayerRemoving:Connect(function(pl)
                if R.selected[pl.UserId] then R.removeTarget(pl.UserId) end
                R.completed[pl.UserId]=true
                task.defer(R.refreshQueueUI)
            end)

            -- Camera controller. Only owns the camera while RAGE camera/view is enabled.
            R.RunService.RenderStepped:Connect(function(dt)
                local ok,err=pcall(function()
                    local pl=R.currentPlayer()
                    local cam=workspace.CurrentCamera
                    if not cam then return end
                    if R.freeView then
                        local hum=pl and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
                        if hum then cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=hum end
                        return
                    end
                    if not R.camLock then return end
                    if R.phase=="WAIT RESPAWN" then return end
                    if not pl then return end
                    local part=R.getPart(pl,R.hitPart)
                    if not part then return end
                    R.startCamFor(pl)
                    if not R.camOffset then return end
                    cam.CameraType=Enum.CameraType.Scriptable
                    local desired=part.Position+R.camOffset
                    local a=math.clamp(R.camSmooth,.1,1)
                    local pos=a>=.995 and desired or cam.CFrame.Position:Lerp(desired,a)
                    cam.CFrame=CFrame.lookAt(pos,part.Position,Vector3.yAxis)
                    cam.Focus=CFrame.new(part.Position)
                end)
                if not ok then warn("[Kimqetras HC v2.89 RAGE camera] "..tostring(err)) end
            end)

            -- Single heartbeat owns movement, acquisition, fire, K.O detection and HUD.
            R.RunService.Heartbeat:Connect(function(dt)
                local ok,err=pcall(function()
                    local pl=R.currentPlayer()

                    if R.master then
                        if R.phase=="WAIT RESPAWN" then
                            local readyIndex=R.findLoopReadyIndex()
                            if readyIndex then
                                R.runIndex=readyIndex
                                R.phase="ACQUIRE"
                                R.phaseTarget=R.runIds[readyIndex]
                                R.camTargetId=nil
                                R.orbitAngle=0
                                pl=R.currentPlayer()
                            else
                                pl=nil
                            end
                        elseif not pl then
                            local ni=R.findNextRunIndex(R.runIndex+1)
                            if ni then
                                R.runIndex=ni
                                R.phase="ACQUIRE"
                                R.phaseTarget=R.runIds[ni]
                                pl=R.currentPlayer()
                            elseif R.loopKills then
                                R.beginLoopCycle()
                                pl=nil
                            else
                                R.stopRun("Queue complete ♡")
                                return
                            end
                        end

                        if R.phase=="ACQUIRE" and pl then
                            local down=R.downState(pl)
                            if down and R.skipDowned then
                                R.completed[pl.UserId]=true
                                R.completeCurrent(pl.UserId)
                                return
                            end
                            R.phase="ATTACK"
                            R.phaseTarget=pl.UserId
                            R.camTargetId=nil
                            R.orbitAngle=0
                            R.tryWings()
                        end

                        if R.phase=="ATTACK" and pl then
                            local down=R.downState(pl)
                            if down then R.finishTarget(pl); return end
                        end
                    end

                    local shouldOrbit=(R.orbitMaster or R.master) and R.phase~="STOMP" and R.phase~="CONFIRM" and R.phase~="WAIT RESPAWN" and not R.finishBusy
                    if shouldOrbit and pl then
                        local tr=R.targetRoot(pl)
                        local char=lp.Character
                        local root=R.localRoot()
                        local hum=char and char:FindFirstChildOfClass("Humanoid")
                        if tr and char and root and hum then
                            R.tryWings()
                            R.captureMovement(hum)
                            hum.AutoRotate=false
                            local jitter=R.antiLock and (1+math.sin(os.clock()*9.1)*.09) or 1
                            local radius=math.max(2.5,R.orbitRadius+(R.antiLock and math.sin(os.clock()*12.7)*.55 or 0))
                            local height=R.orbitHeight+(R.antiLock and math.sin(os.clock()*7.6)*.6 or 0)
                            R.orbitAngle=(R.orbitAngle+dt*R.orbitSpeed*math.pi*2*jitter)%(math.pi*2)
                            local focus=tr.Position+Vector3.new(0,1.3,0)
                            local pos=Vector3.new(tr.Position.X+math.cos(R.orbitAngle)*radius,tr.Position.Y+height,tr.Position.Z+math.sin(R.orbitAngle)*radius)
                            local cf=CFrame.lookAt(pos,focus)
                            char:PivotTo(cf)
                            root.CFrame=cf
                            root.AssemblyAngularVelocity=Vector3.zero
                            root.AssemblyLinearVelocity=R.antiLock and Vector3.new(-math.sin(R.orbitAngle),0,math.cos(R.orbitAngle))*math.min(80,R.orbitSpeed*radius*1.8) or Vector3.zero
                        end
                    elseif not R.finishBusy and (R.movementOwned or R.savedHumanoid~=nil or R.savedAutoRotate~=nil) then
                        -- Only restore once after RAGE actually owned movement.
                        -- Do not touch the player's angular velocity every idle frame.
                        R.releaseMovement()
                    end

                    if pl and R.autoShoot and R.phase=="ATTACK" and not R.finishBusy then
                        _G.KimqRageSilentAimTargetId=pl.UserId
                        local tool=R.findGun()
                        if tool then R.reload(tool) end
                        R.fireClock+=dt
                        if not R.reloadBusy and R.fireClock>=R.effectiveDelay(tool) then
                            R.fireClock=0
                            R.shoot(pl)
                        end
                    else
                        R.fireClock=0
                        _G.KimqRageSilentAimTargetId=nil
                    end

                end)
                if not ok then warn("[Kimqetras HC v2.89 RAGE heartbeat] "..tostring(err)) end
            end)

            -- RAGE survives your respawn but never leaves PlatformStand or stale body locks.
            lp.CharacterAdded:Connect(function(char)
                R.releaseMovement()
                R.camTargetId=nil
                R.orbitAngle=0
                task.delay(.65,function()
                    if R.master then
                        R.phase="ACQUIRE"
                        R.phaseTarget=R.currentId()
                    end
                end)
            end)

            _G.KimqRageEmergencyRestore=function()
                R.master=false
                R.loopKills=false
                R.autoShoot=false
                R.orbitMaster=false
                R.camLock=false
                R.freeView=false
                R.finishBusy=false
                R.runToken+=1
                R.phase="IDLE"
                R.phaseTarget=nil
                R.reloadBusy=false
                R.shotBusy=false
                R.releaseMovement()
                R.restoreCamera()
                if R.ui.hud then R.ui.hud.Visible=false end
            end

            _G.KimqRageV3={
                SelectAll=R.selectAll,
                ClearQueue=R.clearQueue,
                StartAll=function() R.applyOpSettings("all","health") end,
                StartSolo=function() R.applyOpSettings("solo","health") end,
                Stop=R.stopRun,
                GetSelected=function() local out={} for _,id in ipairs(R.queue) do table.insert(out,id) end return out end,
                GetPhase=function() return R.phase end,
                SetControl=function(name,value)
                    local setter=R.ui and R.ui.controls and R.ui.controls[name]
                    if type(setter)=="function" then return setter(value,true) end
                end,
                GetState=function()
                    return {
                        queueOrder=R.queueOrder,skipDown=R.skipDowned,skipWL=R.skipWhitelisted,
                        camLock=R.camLock,orbit=R.orbitMaster,antiLock=R.antiLock,wings=R.autoWings,
                        orbitSpeed=R.orbitSpeed,orbitRadius=R.orbitRadius,orbitHeight=R.orbitHeight,
                        master=R.master,autoShoot=R.autoShoot,autoReload=R.autoReload,
                        autoStomp=R.autoStomp,stompLock=R.stompLock,autoAdvance=R.autoAdvance,
                        hitPart=R.hitPart,fireDelay=R.fireDelay,stompAttempts=R.stompAttempts,
                    }
                end,
            }
        end)

        if not rageOK then
            for _,old in ipairs(gui:GetChildren()) do
                if old.Name=="KimqRageMiniHUD" then pcall(function() old:Destroy() end) end
            end
            warn("[Kimqetras HC v2.89] RAGE isolated error: "..tostring(rageERR))
        end
    end)

    -- ================================================================
    -- v2.14 SPAWN POINT
    -- A lightweight selector for the map's real spawn locations. It does
    -- no constant workspace scanning: the list is refreshed only when the
    -- page is opened or the user presses Refresh.
    -- ================================================================
    do
        local spawnPage = pages.spawn
        if spawnPage then
            local selectedSpawn = nil
            local selectedPath = nil
            local selectedName = "Game Default"
            local fallbackPosition = nil
            local useSelectedSpawn = false
            local scannedOnce = false
            local spawnEntries = {}

            local function palette()
                return _G.KimqThemeLivePalette or T
            end

            local function makeCard(height, order)
                local p = palette()
                local f = Instance.new("Frame")
                f.Parent = spawnPage
                f.LayoutOrder = order or 1
                f.Size = UDim2.new(1, -6, 0, height)
                f.BackgroundColor3 = p.panel or T.panel
                f.BorderSizePixel = 0
                f:SetAttribute("KimqV26Role", "panel")
                corner(f, 14)
                stroke(f, p.line or p.stroke or T.stroke, .22, 1)
                return f
            end

            local intro = makeCard(76, 1)
            local introTitle = textLabel(intro, "♥  Spawn Point", UDim2.new(1,-24,0,28), UDim2.fromOffset(12,9), Enum.Font.GothamBold, 20, palette().hot or T.hot)
            introTitle:SetAttribute("KimqV26Role", "hotText")
            local introSub = textLabel(intro, "Choose where your character returns after respawning.", UDim2.new(1,-24,0,28), UDim2.fromOffset(12,40), Enum.Font.Gotham, 12, palette().sub or T.sub)
            introSub.TextWrapped = true
            introSub:SetAttribute("KimqV26Role", "subText")

            local listCard = makeCard(330, 2)
            local listTitle = textLabel(listCard, "Available Spawn Points", UDim2.new(1,-130,0,24), UDim2.fromOffset(12,8), Enum.Font.GothamBold, 14, palette().text or T.text)
            listTitle:SetAttribute("KimqV26Role", "textText")

            local refreshBtn = Instance.new("TextButton")
            refreshBtn.Parent = listCard
            refreshBtn.Size = UDim2.fromOffset(104, 30)
            refreshBtn.Position = UDim2.new(1,-116,0,6)
            refreshBtn.BackgroundColor3 = palette().soft or T.bg2
            refreshBtn.BorderSizePixel = 0
            refreshBtn.Text = "refresh"
            refreshBtn.TextColor3 = palette().hot or T.hot
            refreshBtn.Font = Enum.Font.GothamSemibold
            refreshBtn.TextSize = 11
            refreshBtn:SetAttribute("KimqV26Role", "soft")
            corner(refreshBtn, 9)
            stroke(refreshBtn, palette().line or palette().stroke or T.stroke, .34, 1)

            local selectedLabel = textLabel(listCard, "Selected: Game Default", UDim2.new(1,-24,0,20), UDim2.fromOffset(12,38), Enum.Font.GothamSemibold, 11, palette().sub or T.sub)
            selectedLabel:SetAttribute("KimqV26Role", "subText")

            local spawnList = Instance.new("ScrollingFrame")
            spawnList.Parent = listCard
            spawnList.Size = UDim2.new(1,-20,0,218)
            spawnList.Position = UDim2.fromOffset(10,68)
            spawnList.BackgroundTransparency = 1
            spawnList.BorderSizePixel = 0
            spawnList.ScrollBarThickness = 3
            spawnList.ScrollBarImageColor3 = palette().hot or T.hot
            local spawnGrid = Instance.new("UIGridLayout", spawnList)
            spawnGrid.CellPadding = UDim2.fromOffset(7,7)
            spawnGrid.CellSize = UDim2.new(.5,-5,0,36)
            spawnGrid.SortOrder = Enum.SortOrder.LayoutOrder
            spawnGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                spawnList.CanvasSize = UDim2.new(0,0,0,spawnGrid.AbsoluteContentSize.Y+8)
            end)

            local hint = textLabel(listCard, "Pick a point below, or use Game Default.", UDim2.new(1,-24,0,18), UDim2.fromOffset(12,302), Enum.Font.Gotham, 10, palette().sub or T.sub)
            hint:SetAttribute("KimqV26Role", "subText")

            local actionCard = makeCard(132, 3)
            local actionTitle = textLabel(actionCard, "Spawn Behavior", UDim2.new(1,-24,0,22), UDim2.fromOffset(12,8), Enum.Font.GothamBold, 14, palette().text or T.text)
            actionTitle:SetAttribute("KimqV26Role", "textText")
            local actionSub = textLabel(actionCard, "Use your selected point whenever your character respawns.", UDim2.new(1,-24,0,18), UDim2.fromOffset(12,31), Enum.Font.Gotham, 10, palette().sub or T.sub)
            actionSub:SetAttribute("KimqV26Role", "subText")

            local toggleLabel = textLabel(actionCard, "Use Selected Spawn", UDim2.new(0,220,0,28), UDim2.fromOffset(12,54), Enum.Font.GothamSemibold, 12, palette().text or T.text)
            toggleLabel:SetAttribute("KimqV26Role", "textText")
            local toggle = Instance.new("TextButton")
            toggle.Parent = actionCard
            toggle.Size = UDim2.fromOffset(48,24)
            toggle.Position = UDim2.new(0,228,0,56)
            toggle.Text = ""
            toggle.AutoButtonColor = false
            toggle.BorderSizePixel = 0
            corner(toggle, 999)
            local knob = Instance.new("Frame", toggle)
            knob.Size = UDim2.fromOffset(18,18)
            knob.Position = UDim2.new(0,3,.5,-9)
            knob.BackgroundColor3 = Color3.new(1,1,1)
            knob.BorderSizePixel = 0
            corner(knob, 999)

            local nowBtn = Instance.new("TextButton")
            nowBtn.Parent = actionCard
            nowBtn.Size = UDim2.fromOffset(150,32)
            nowBtn.Position = UDim2.new(1,-162,0,53)
            nowBtn.BackgroundColor3 = palette().soft or T.bg2
            nowBtn.BorderSizePixel = 0
            nowBtn.Text = "spawn here now"
            nowBtn.TextColor3 = palette().hot or T.hot
            nowBtn.Font = Enum.Font.GothamSemibold
            nowBtn.TextSize = 11
            nowBtn:SetAttribute("KimqV26Role", "soft")
            corner(nowBtn, 9)
            stroke(nowBtn, palette().line or palette().stroke or T.stroke, .34, 1)

            local behaviorStatus = textLabel(actionCard, "Game Default is active.", UDim2.new(1,-24,0,20), UDim2.fromOffset(12,98), Enum.Font.GothamSemibold, 10, palette().sub or T.sub)
            behaviorStatus:SetAttribute("KimqV26Role", "subText")

            local function normalizeName(v)
                return tostring(v or ""):lower():gsub("[%s_%-%[%]%(%)]+", "")
            end

            local function isSpawnContainerName(name)
                local n = normalizeName(name)
                return n=="spawns" or n=="spawnpoints" or n=="spawnlocations" or n=="playerspawns" or n=="teamspawns"
            end

            local function isSpawnCandidate(obj)
                if obj:IsA("SpawnLocation") then return true end
                if not obj:IsA("BasePart") then return false end
                local n = normalizeName(obj.Name)
                if n=="spawn" or n=="spawnpoint" or n=="spawnlocation" or n=="playerspawn" or n=="teamspawn" then return true end
                local p = obj.Parent
                if p and isSpawnContainerName(p.Name) then return true end
                local pp = p and p.Parent
                if pp and isSpawnContainerName(pp.Name) then return true end
                return false
            end

            local function pathFor(obj)
                local parts = {}
                local cur = obj
                while cur and cur ~= workspace do
                    table.insert(parts, 1, cur.Name)
                    cur = cur.Parent
                end
                return cur == workspace and parts or nil
            end

            local function resolvePath(parts)
                if type(parts) ~= "table" then return nil end
                local cur = workspace
                for _,name in ipairs(parts) do
                    if not cur then return nil end
                    cur = cur:FindFirstChild(tostring(name))
                end
                return cur
            end

            local function targetCFrame(obj)
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then return obj.CFrame end
                    if obj:IsA("Model") then
                        local ok,cf = pcall(function() return obj:GetPivot() end)
                        if ok then return cf end
                    end
                end
                if type(fallbackPosition)=="table" then
                    local x,y,z=tonumber(fallbackPosition.X),tonumber(fallbackPosition.Y),tonumber(fallbackPosition.Z)
                    if x and y and z then return CFrame.new(x,y,z) end
                end
                return nil
            end

            local function setRespawnLocationProperty(obj)
                pcall(function()
                    if useSelectedSpawn then
                        if obj and obj:IsA("SpawnLocation") then
                            lp.RespawnLocation = obj
                        else
                            -- Generic map markers are handled by our one-time
                            -- post-respawn correction. Do not leave an older
                            -- Roblox SpawnLocation stuck here.
                            lp.RespawnLocation = nil
                        end
                    else
                        lp.RespawnLocation = nil
                    end
                end)
            end

            local function paintToggle()
                local p = palette()
                toggle.BackgroundColor3 = useSelectedSpawn and (p.hot or T.hot) or (p.soft or p.bg2 or T.bg2)
                knob.Position = useSelectedSpawn and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
                behaviorStatus.Text = useSelectedSpawn and ("Respawning at: "..tostring(selectedName)) or "Game Default is active."
                behaviorStatus.TextColor3 = useSelectedSpawn and (p.hot or T.hot) or (p.sub or T.sub)
                selectedLabel.Text = "Selected: " .. tostring(selectedName)
            end

            local function zeroSpawnVelocity(char)
                if not char then return end
                for _,part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.AssemblyLinearVelocity=Vector3.zero
                            part.AssemblyAngularVelocity=Vector3.zero
                        end)
                    end
                end
            end

            local function moveCharacter(char, forcePhysicalMove)
                if not useSelectedSpawn then return false end
                local obj = selectedSpawn
                if not (obj and obj.Parent) then obj = resolvePath(selectedPath); selectedSpawn = obj end
                if obj and obj:IsA("SpawnLocation") and not forcePhysicalMove then
                    setRespawnLocationProperty(obj)
                    return true
                end
                local cf = targetCFrame(obj)
                if not cf then return false end
                local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not (root and root:IsA("BasePart")) then return false end
                local wasAnchored=root.Anchored
                zeroSpawnVelocity(char)
                pcall(function() root.Anchored=true end)
                local lift=math.max(4.5,(hum and hum.HipHeight or 2)+2.5)
                local ok=pcall(function() char:PivotTo(cf*CFrame.new(0,lift,0)) end)
                RunService.Heartbeat:Wait()
                zeroSpawnVelocity(char)
                pcall(function() root.Anchored=wasAnchored end)
                return ok
            end

            local function applySelected(obj, label, enable)
                selectedSpawn = obj
                selectedPath = obj and pathFor(obj) or nil
                selectedName = label or (obj and obj.Name) or "Game Default"
                if obj and obj:IsA("BasePart") then
                    fallbackPosition = {X=obj.Position.X,Y=obj.Position.Y,Z=obj.Position.Z}
                elseif not obj then
                    fallbackPosition = nil
                end
                if enable ~= nil then useSelectedSpawn = not not enable end
                setRespawnLocationProperty(obj)
                paintToggle()

                if useSelectedSpawn then
                    behaviorStatus.Text="Selected spawn locked: "..tostring(selectedName)
                    behaviorStatus.TextColor3=palette().hot or T.hot
                end
            end

            local function clearSpawnButtons()
                for _,ch in ipairs(spawnList:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                table.clear(spawnEntries)
            end

            local function makeSpawnButton(label, obj, order, defaultButton)
                local p = palette()
                local b = Instance.new("TextButton")
                b.Parent = spawnList
                b.LayoutOrder = order
                b.BackgroundColor3 = p.soft or p.bg2 or T.bg2
                b.BorderSizePixel = 0
                b.Text = label
                b.TextColor3 = p.text or T.text
                b.Font = Enum.Font.GothamSemibold
                b.TextSize = 11
                b.TextWrapped = true
                b.AutoButtonColor = false
                b:SetAttribute("KimqV26Role", "soft")
                corner(b, 9)
                stroke(b, p.line or p.stroke or T.stroke, .38, 1)
                b.MouseButton1Click:Connect(function()
                    if defaultButton then
                        applySelected(nil, "Game Default", false)
                    else
                        applySelected(obj, label, true)
                    end
                    for _,entry in ipairs(spawnEntries) do
                        if entry.Button and entry.Button.Parent then
                            local chosen = (not defaultButton and entry.Object==selectedSpawn) or (defaultButton and entry.Default and not useSelectedSpawn)
                            local live = palette()
                            entry.Button.BackgroundColor3 = chosen and (live.hot or T.hot) or (live.soft or live.bg2 or T.bg2)
                            entry.Button.TextColor3 = chosen and Color3.new(1,1,1) or (live.text or T.text)
                        end
                    end
                end)
                table.insert(spawnEntries,{Button=b,Object=obj,Default=defaultButton})
                return b
            end

            local function displayNameFor(obj, used)
                local generic = normalizeName(obj.Name)
                local label = obj.Name
                if generic=="spawn" or generic=="spawnpoint" or generic=="spawnlocation" then
                    if obj.Parent and obj.Parent~=workspace then label = obj.Parent.Name end
                end
                local base = label
                local n = (used[base] or 0) + 1
                used[base] = n
                if n > 1 then label = base .. " #" .. n end
                return label
            end

            local function scanSpawnPoints()
                clearSpawnButtons()
                local found = {}
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if isSpawnCandidate(obj) then table.insert(found,obj) end
                end
                table.sort(found,function(a,b)
                    local an,bn=tostring(a.Name):lower(),tostring(b.Name):lower()
                    if an~=bn then return an<bn end
                    return tostring(a:GetFullName())<tostring(b:GetFullName())
                end)
                local used = {}
                makeSpawnButton("Game Default", nil, 1, true)
                local order = 2
                for _,obj in ipairs(found) do
                    local label = displayNameFor(obj, used)
                    makeSpawnButton(label, obj, order, false)
                    order += 1
                end
                if #found==0 then
                    local p=palette()
                    local empty=Instance.new("TextButton")
                    empty.Parent=spawnList; empty.LayoutOrder=2; empty.BackgroundColor3=p.soft or T.bg2; empty.BorderSizePixel=0
                    empty.Text="No spawn points found"; empty.TextColor3=p.sub or T.sub; empty.Font=Enum.Font.GothamSemibold; empty.TextSize=11; empty.AutoButtonColor=false
                    corner(empty,9); stroke(empty,p.line or p.stroke or T.stroke,.45,1)
                end
                scannedOnce = true

                if selectedPath then
                    local resolved = resolvePath(selectedPath)
                    if resolved then selectedSpawn = resolved end
                end
                for _,entry in ipairs(spawnEntries) do
                    if entry.Button and entry.Button.Parent then
                        local chosen = (useSelectedSpawn and entry.Object==selectedSpawn) or ((not useSelectedSpawn) and entry.Default)
                        local p=palette()
                        entry.Button.BackgroundColor3=chosen and (p.hot or T.hot) or (p.soft or p.bg2 or T.bg2)
                        entry.Button.TextColor3=chosen and Color3.new(1,1,1) or (p.text or T.text)
                    end
                end
                paintToggle()
            end

            refreshBtn.MouseButton1Click:Connect(scanSpawnPoints)
            spawnPage:GetPropertyChangedSignal("Visible"):Connect(function()
                if spawnPage.Visible and not scannedOnce then task.defer(scanSpawnPoints) end
            end)

            toggle.MouseButton1Click:Connect(function()
                if not selectedSpawn and not selectedPath then
                    useSelectedSpawn = false
                    selectedName = "Game Default"
                else
                    useSelectedSpawn = not useSelectedSpawn
                end
                setRespawnLocationProperty(selectedSpawn)
                paintToggle()
            end)

            nowBtn.MouseButton1Click:Connect(function()
                if not selectedSpawn and not selectedPath then
                    behaviorStatus.Text = "Pick a spawn point first."
                    behaviorStatus.TextColor3 = palette().sub or T.sub
                    return
                end
                useSelectedSpawn = true
                setRespawnLocationProperty(selectedSpawn)
                local ok = moveCharacter(lp.Character,true)
                behaviorStatus.Text = ok and ("Moved to and locked: "..tostring(selectedName)) or "Could not move to that point."
                behaviorStatus.TextColor3 = ok and (palette().hot or T.hot) or (palette().sub or T.sub)
                task.delay(1.2,paintToggle)
            end)

            local spawnDeathConn=nil

            local function bindSpawnDeath(char)
                if spawnDeathConn then
                    pcall(function() spawnDeathConn:Disconnect() end)
                    spawnDeathConn=nil
                end
                if not char then return end
                local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",5)
                if not hum then return end
                spawnDeathConn=hum.Died:Connect(function()
                    if not useSelectedSpawn then return end
                    local obj=selectedSpawn
                    if not (obj and obj.Parent) then
                        obj=resolvePath(selectedPath)
                        selectedSpawn=obj
                    end
                    -- Set this before Roblox chooses the next spawn.
                    setRespawnLocationProperty(obj)
                end)
            end

            if lp.Character then task.defer(bindSpawnDeath,lp.Character) end

            local spawnCorrectionSerial=0

            local function selectedTargetCFrame()
                local obj=selectedSpawn
                if not (obj and obj.Parent) then
                    obj=resolvePath(selectedPath)
                    if obj then selectedSpawn=obj end
                end
                return targetCFrame(obj)
            end

            local function isNearSelectedSpawn(char,maxDistance)
                local root=char and (char:FindFirstChild("HumanoidRootPart")
                    or char:FindFirstChild("UpperTorso")
                    or char:FindFirstChild("Torso"))
                local cf=selectedTargetCFrame()
                if not (root and root:IsA("BasePart") and cf) then return false end
                return (root.Position-cf.Position).Magnitude <= (maxDistance or 12)
            end

            local function beginSpawnCorrectionWindow(char)
                spawnCorrectionSerial += 1
                local mySerial=spawnCorrectionSerial

                task.spawn(function()
                    local root=char:WaitForChild("HumanoidRootPart",6)
                        or char:FindFirstChild("UpperTorso")
                        or char:FindFirstChild("Torso")
                    local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",6)
                    if not root or not hum then return end

                    -- Let the game's own spawn/FFA logic settle, then do ONE
                    -- correction only if it ignored the selected point.
                    task.wait(1.35)

                    if mySerial~=spawnCorrectionSerial
                        or char~=lp.Character
                        or not char.Parent
                        or not useSelectedSpawn then
                        return
                    end

                    local obj=selectedSpawn
                    if not (obj and obj.Parent) then
                        obj=resolvePath(selectedPath)
                        if obj then selectedSpawn=obj end
                    end
                    setRespawnLocationProperty(obj)

                    if not isNearSelectedSpawn(char,18) then
                        moveCharacter(char,true)
                    end
                end)
            end
            lp.CharacterAdded:Connect(function(char)
                task.defer(bindSpawnDeath,char)
                if not useSelectedSpawn then return end

                local obj=selectedSpawn
                if not (obj and obj.Parent) then
                    obj=resolvePath(selectedPath)
                    if obj then selectedSpawn=obj end
                end

                -- Set the Roblox property as early as possible, then keep a
                -- short correction window in case the game's own round script
                -- teleports the character back to its normal spawn afterward.
                setRespawnLocationProperty(obj)
                beginSpawnCorrectionWindow(char)
            end)

            local function getSpawnConfig()
                return {
                    Enabled=useSelectedSpawn,
                    Name=selectedName,
                    Path=selectedPath,
                    Position=fallbackPosition,
                }
            end
            local function setSpawnConfig(v)
                if type(v)~="table" then return end
                useSelectedSpawn = not not v.Enabled
                selectedName = tostring(v.Name or "Game Default")
                selectedPath = type(v.Path)=="table" and v.Path or nil
                fallbackPosition = type(v.Position)=="table" and v.Position or nil
                selectedSpawn = resolvePath(selectedPath)
                if not selectedSpawn and not selectedPath then
                    useSelectedSpawn=false; selectedName="Game Default"
                end
                setRespawnLocationProperty(selectedSpawn)
                paintToggle()
                if scannedOnce then task.defer(scanSpawnPoints) end
            end
            if type(_G.KimqRegisterConfigControl)=="function" then
                _G.KimqRegisterConfigControl("Spawn Point", "state", getSpawnConfig, setSpawnConfig)
            end

            _G.KimqSpawnPointController = {
                Refresh=scanSpawnPoints,
                GetState=getSpawnConfig,
                SetState=setSpawnConfig,
                SpawnNow=function() return moveCharacter(lp.Character,true) end,
            }

            paintToggle()
        end
    end

    -- v2.1 canonical GUI hide/show: F1 ONLY.
    -- Do not rely on a separate uiShown boolean, because later visual passes can
    -- change Main.Visible and leave that boolean out of sync.
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode == Enum.KeyCode.F1 then
            if main and main.Parent then
                local nextVisible=not main.Visible
                _G.KimqMainUserVisibleState=nextVisible
                pcall(function() if type(getgenv)=="function" then getgenv().KimqMainUserVisibleState=nextVisible end end)
                main.Visible=nextVisible
            end
        end
    end)

    -- Custom drag from the top bar.
    local dragging = false
    local dragStart, startPos, dragInput
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    showPage("overview")
    _G.KimqBasePagesReady = true
end)


-- v2.1: legacy BlueFix2 visual pass removed for performance.

-- KIMQETRAS HC PAGE ASSIGNMENT REPAIR
-- One lightweight pass sorts controls by their own labels; it does not build another GUI.
task.spawn(function()
    local baseWait=tick()
    while not _G.KimqBasePagesReady and tick()-baseWait<8 do task.wait(.02) end

    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local lp = Players.LocalPlayer
    local playerGui = lp:WaitForChild("PlayerGui")

    local gui = CoreGui:FindFirstChild("KimpetrasHC") or playerGui:FindFirstChild("KimpetrasHC")
    local main = gui and gui:FindFirstChild("Main")
    if not main then return end
    if main:FindFirstChild("KimqV3ForcePages") then return end
    local marker = Instance.new("BoolValue")
    marker.Name = "KimqV3ForcePages"
    marker.Parent = main

    local T = {
        hot = Color3.fromRGB(243, 161, 211),
        hot2 = Color3.fromRGB(255, 212, 243),
        panel = Color3.fromRGB(255, 255, 255),
        bg2 = Color3.fromRGB(236, 255, 243),
        text = Color3.fromRGB(82, 116, 94),
        sub = Color3.fromRGB(122, 153, 133),
        stroke = Color3.fromRGB(255, 212, 243),
        white = Color3.fromRGB(255, 255, 255),
    }
    -- Keep a live reference so the final theme engine can update callbacks that use T.
    _G.KimqThemePaletteRefs = _G.KimqThemePaletteRefs or {}
    table.insert(_G.KimqThemePaletteRefs, T)

    local function corner(obj, r)
        local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 12)
        c.Parent = obj
        return c
    end
    local function stroke(obj, color, tr, th)
        local s = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        s.Color = color or T.stroke
        s.Transparency = tr or 0
        s.Thickness = th or 1
        s.Parent = obj
        return s
    end
    local function label(parent, text, size, pos, font, textSize, color, align)
        local l = Instance.new("TextLabel")
        l.Parent = parent
        l.BackgroundTransparency = 1
        l.Size = size
        l.Position = pos
        l.Text = text
        l.Font = font or Enum.Font.Gotham
        l.TextSize = textSize or 14
        l.TextColor3 = color or T.text
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        return l
    end

    -- Find all already-created page frames.
    local pages = {}
    for _, obj in ipairs(main:GetDescendants()) do
        if obj:IsA("ScrollingFrame") and obj.Name:match("Page$") then
            pages[obj.Name:gsub("Page$", ""):lower()] = obj
        end
    end
    if not pages.overview or not pages.silent or not pages.macro then return end

    -- Every visible control gets assigned by its OWN label, not by a previous header.
    local exact = {
        ["Silent Aim"] = "silent",
        ["Use Silent Aim Keybind"] = "silent",
        ["Silent Aim Key"] = "silent",
        ["Show FOV Circle"] = "silent",
        ["FOV Size"] = "silent",
        ["Strict FOV"] = "silent",
        ["Filled FOV"] = "silent",
        ["FOV Opacity"] = "silent",
        ["Target Stickiness"] = "silent",
        ["Target Priority"] = "silent",
        ["Auto Prediction"] = "silent",
        ["Auto Prediction Strength"] = "silent",
        ["Silent Prediction X"] = "silent",
        ["Silent Prediction Y"] = "silent",
        ["Hit Chance"] = "silent",
        ["Bypass Revolver"] = "silent",
        ["Wall Check"] = "silent",
        ["Team Check"] = "silent",
        ["Target Closest Part"] = "silent",
        ["Hit Part"] = "silent",
        ["Max Target Distance"] = "silent",
        ["Prediction X"] = "silent",
        ["Prediction Y"] = "silent",
        ["Shot Camera Swap"] = "silent",
        ["Random Camera Zoom"] = "silent",
        ["Knock Check"] = "silent",

        -- compatibility with older labels
        ["HitPart (16 Parts)"] = "silent",
        ["Enable Keybind"] = "silent",
        ["Toggle Aim Key"] = "silent",
        ["Hide/Show UI Key"] = "silent",

        ["Macro / Speed Master"] = "macro",
        ["Macro Key"] = "macro",
        ["Macro Speed"] = "macro",
        ["Turn Master on, then press the Macro Key"] = "macro",

        ["Clear Whitelist"] = "whitelist",

        ["Anti Aim View"] = "protection",
        ["0% Aim Accuracy"] = "protection",

        ["Anti Fall"] = "antifall",

        ["Delay Changer"] = "delay",
        ["[Revolver] Delay"] = "delay",
        ["[Double-Barrel SG] Delay"] = "delay",
        ["[TacticalShotgun] Delay"] = "delay",
        ["Others Delay"] = "delay",

        ["ESP"] = "esp",
        ["Box"] = "esp",
        ["Name"] = "esp",
        ["Distance"] = "esp",
        ["Health"] = "esp",
        ["Snapline"] = "esp",
        ["Skeleton"] = "esp",

        ["User ID / Username"] = "avatar",
        ["Keep Avatar After Respawn"] = "avatar",
        ["Visual Headless"] = "avatar",
        ["♥  Apply User Avatar"] = "avatar",
        ["Apply User Avatar"] = "avatar",
        ["Reset to My Avatar"] = "avatar",

        ["HC Silent Aim"] = "hcsilent",
        ["HC Revolver Bypass"] = "hcsilent",
        ["HC Wall Check"] = "hcsilent",
        ["HC Knock Check"] = "hcsilent",
        ["HC FOV Radius"] = "hcsilent",
        ["HC Hit Part"] = "hcsilent",
        ["HC Prediction"] = "hcsilent",
        ["HC Prediction Amount"] = "hcsilent",
        ["HC Godmode"] = "hcsilent",

        ["Force Hit"] = "hcsilent",
        ["Force Hit Mode"] = "hcsilent",
        ["Force Hit FOV"] = "hcsilent",
        ["Force Hit Tracer"] = "hcsilent",
        ["Force Hit Full Auto"] = "hcsilent",
        ["Force Hit Fire Rate"] = "hcsilent",

        ["Hitbox Expander"] = "hitbox",
        ["Hitbox Size"] = "hitbox",
        ["Hitbox Visibility"] = "hitbox",

        ["Flamelock"] = "flamelock",
        ["Right Click Lock"] = "flamelock",
        ["Activation Mode"] = "flamelock",
        ["Flamelock Key"] = "flamelock",
        ["Flame Hit Part"] = "flamelock",
        ["Flame Smoothness"] = "flamelock",
        ["Flame Prediction"] = "flamelock",
        ["Flame Left Offset"] = "flamelock",
        ["Flame Up Offset"] = "flamelock",

        ["Camlock Enabled"] = "camlock",
        ["Auto Toggle (Gun)"] = "camlock",
        ["Camlock Key"] = "camlock",
        ["Camlock Mode"] = "camlock",
        ["Camlock Hit Part"] = "camlock",
        ["Closest Point Mode"] = "camlock",
        ["Closest Point Scale"] = "camlock",
        ["Camlock FOV"] = "camlock",
        ["Max Distance"] = "camlock",
        ["Easing Style"] = "camlock",
        ["Easing Direction"] = "camlock",
        ["Camlock Smoothness"] = "camlock",
        ["Pull Strength"] = "camlock",
        ["Pull Base Value"] = "camlock",
        ["Pull Move Value"] = "camlock",
        ["Camlock Prediction"] = "camlock",
        ["Prediction X"] = "camlock",
        ["Prediction Y"] = "camlock",
        ["Prediction Z"] = "camlock",
        ["Force Field Check"] = "camlock",
        ["Visible Check"] = "camlock",
        ["Carried Check"] = "camlock",
        ["Knocked Check"] = "camlock",
        ["Self Knocked Check"] = "camlock",

        ["Atmosphere Preset"] = "fog",
        ["Reset Atmosphere"] = "fog",
        ["Color Correction"] = "fog",
        ["Saturation"] = "fog",

        ["Headless Mode"] = "avatar",

        ["KIM Anti Aim View"] = "antimod",
        ["Anti Mod Notify"] = "antimod",
        ["Anti Mod Kick"] = "antimod",
        ["Anti Mod Kick Delay"] = "antimod",
        ["Anti Mod controls are OFF here by default so the script does not kick you unless you choose to enable it."] = "antimod",

        ["FPS Unlocker"] = "settings",
        ["Target FPS"] = "settings",
        ["Config Name"] = "settings",
        ["Save KIM Config"] = "settings",
        ["Load KIM Config"] = "settings",
        ["Delete KIM Config"] = "settings",
        ["Saved Configs"] = "settings",
        ["Save Current Config"] = "settings",
        ["Update Selected Config"] = "settings",
        ["Load Selected Config"] = "settings",
        ["Delete Selected Config"] = "settings",
        ["Refresh Config List"] = "settings",
        ["Configs save your setup, including the exact fog color and amount, so it comes back the same when loaded."] = "settings",
    }

    local sectionHeaderNames = {
        ["Silent Aim"] = true, ["Macro"] = true, ["Whitelist"] = true,
        ["Protection"] = true, ["Anti Fall"] = true, ["Delay Changer"] = true,
        ["ESP"] = true, ["Avatar"] = true, ["HC Silent Aim"] = true,
        ["Combat"] = true, ["Force Hit"] = true, ["Hitbox Expander"] = true,
        ["Flamelock"] = true, ["Camlock"] = true, ["Visuals"] = true,
        ["Headless"] = true, ["Protection + Anti Mod"] = true,
        ["Settings"] = true, ["Credits"] = true, ["Information"] = true,
        ["Atmosphere Presets"] = true,
    }

    local function cleanText(t)
        t = tostring(t or "")
        t = t:gsub("^%s*[♡♥]%s*", "")
        t = t:gsub("%s+", " ")
        t = t:gsub("^%s+", ""):gsub("%s+$", "")
        return t
    end

    local function controlLabel(container)
        -- Prefer direct labels/buttons so nested toggle knob text does not confuse the mapper.
        for _, ch in ipairs(container:GetChildren()) do
            if ch:IsA("TextLabel") or ch:IsA("TextButton") then
                local t = cleanText(ch.Text)
                if exact[t] then return t end
            end
        end
        for _, ch in ipairs(container:GetDescendants()) do
            if ch:IsA("TextLabel") or ch:IsA("TextButton") then
                local t = cleanText(ch.Text)
                if exact[t] then return t end
            end
        end
        return nil
    end

    local function isSectionHeader(obj)
        if not obj:IsA("TextLabel") then return false end
        return sectionHeaderNames[cleanText(obj.Text)] == true
    end

    -- Gather every control/card currently living in any page.
    local all = {}
    for key, page in pairs(pages) do
        if key ~= "overview" then
            for _, ch in ipairs(page:GetChildren()) do
                if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                    table.insert(all, ch)
                end
            end
        end
    end

    -- Delete the old section-heading objects. The page header already says which page you're on.
    for _, obj in ipairs(all) do
        if isSectionHeader(obj) then
            pcall(function() obj:Destroy() end)
        end
    end

    -- Move cards by their creation-time ownership stamp.  Exact label mapping
    -- remains only as a compatibility fallback for truly old untagged cards.
    for _, obj in ipairs(all) do
        if obj.Parent and not isSectionHeader(obj) then
            local stamped = obj:GetAttribute("KimqSection")
            if stamped=="forcehit" then stamped="hcsilent" end
            if stamped=="headless" then stamped="avatar" end
            local key = stamped
            if not (key and pages[key]) then
                local t = controlLabel(obj)
                key = t and exact[t]
            end
            if key and pages[key] then
                obj.Parent = pages[key]
            end
        end
    end

    -- Legacy builds created dropdown option ScrollingFrames as standalone page rows.
    -- The current addDropdown no longer does that; remove any orphan leftovers so
    -- an option list can never appear in Silent Aim or another unrelated page.
    for _, page in pairs(pages) do
        for _, obj in ipairs(page:GetChildren()) do
            if obj:IsA("ScrollingFrame") and obj.Name == "KimqDropdownOptions" then
                -- New dropdowns are children of their card, never direct children of a page.
                obj:Destroy()
            end
        end
    end

    -- Dynamic Whitelist player cards already receive KimqSection="whitelist"
    -- when they are created. Use that exact ownership stamp only.
    --
    -- IMPORTANT: do NOT infer Whitelist from an ON/OFF button. RAGE, Anti Fall,
    -- Protection, etc. also contain ON/OFF toggles and must stay on their pages.
    if pages.whitelist then
        for _, page in pairs(pages) do
            if page ~= pages.overview and page ~= pages.whitelist then
                local moving = {}
                for _, obj in ipairs(page:GetChildren()) do
                    if obj:IsA("Frame") and obj:GetAttribute("KimqSection")=="whitelist" then
                        table.insert(moving,obj)
                    end
                end
                for _,obj in ipairs(moving) do
                    obj.Parent=pages.whitelist
                end
            end
        end
    end

    -- Move avatar custom button cards by their text if they were missed.
    for _, page in pairs(pages) do
        if page ~= pages.avatar and page ~= pages.overview then
            local moving = {}
            for _, obj in ipairs(page:GetChildren()) do
                if obj:IsA("Frame") then
                    for _, d in ipairs(obj:GetDescendants()) do
                        if d:IsA("TextButton") then
                            local t = cleanText(d.Text)
                            if t == "Apply Avatar" or t == "Reset Character" then
                                table.insert(moving, obj)
                                break
                            end
                        end
                    end
                end
            end
            for _, obj in ipairs(moving) do obj.Parent = pages.avatar end
        end
    end

    -- Keep the large fog picker on Fog / Atmosphere.
    local fogPanel = main:FindFirstChild("FogPanel", true)
    if fogPanel and pages.fog then
        fogPanel.Parent = pages.fog
        fogPanel.LayoutOrder = 1
    end

    -- Re-number visual order on each page.
    for _, page in pairs(pages) do
        local objs = {}
        for _, ch in ipairs(page:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then table.insert(objs, ch) end
        end
        table.sort(objs, function(a,b)
            if a.LayoutOrder ~= b.LayoutOrder then return a.LayoutOrder < b.LayoutOrder end
            return a.Name < b.Name
        end)
        for i, ch in ipairs(objs) do ch.LayoutOrder = i end
    end

    -- Fix sidebar hearts permanently: one heart inside the button text, no separate overlay label.
    for _, btn in ipairs(main:GetDescendants()) do
        if btn:IsA("TextButton") then
            local heart = btn:FindFirstChild("Heart")
            if heart then
                local txt = tostring(btn.Text or "")
                txt = txt:gsub("^%s+", "")
                txt = txt:gsub("^[♡♥]%s*", "")
                btn.Text = "♡   " .. txt
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.TextSize = 13
                pcall(function() heart:Destroy() end)
            end
        end
    end

    -- Overview rendering is owned by the final v2.1 builder; no temporary V3 overview is created.

    -- Clean Information page: text-only credits, intentionally simple and theme-safe.
    local info = pages.info
    if info then
        for _, ch in ipairs(info:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then pcall(function() ch:Destroy() end) end
        end

        local cardInfo = Instance.new("Frame")
        cardInfo.Name = "KimqInformationCard"
        cardInfo.Parent = info
        cardInfo.Size = UDim2.new(1,-6,0,104)
        cardInfo.LayoutOrder = -100
        cardInfo.BackgroundColor3 = T.panel
        cardInfo.BorderSizePixel = 0
        cardInfo:SetAttribute("KimqV26Role","panel")
        corner(cardInfo,18)
        stroke(cardInfo,T.stroke,0.2,1)

        local infoTitle=label(cardInfo,"♥  information",UDim2.new(1,-24,0,28),UDim2.fromOffset(12,10),Enum.Font.GothamSemibold,20,T.hot)
        infoTitle:SetAttribute("KimqV26Role","hotText")
        local infoSub=label(cardInfo,"Kimqetras HC ♡",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,38),Enum.Font.Gotham,12,T.sub)
        infoSub:SetAttribute("KimqV26Role","subText")

        local kimName=label(cardInfo,"kimqetras",UDim2.new(0,160,0,25),UDim2.fromOffset(16,67),Enum.Font.GothamSemibold,14,T.hot)
        kimName:SetAttribute("KimqV26Role","hotText")
        local kimRole=label(cardInfo,"owner ♡",UDim2.new(1,-202,0,25),UDim2.fromOffset(188,67),Enum.Font.Gotham,12,T.sub,Enum.TextXAlignment.Right)
        kimRole:SetAttribute("KimqV26Role","subText")


    end

    -- Add a visible V3 badge so the user can immediately tell this file loaded.
    local badge = Instance.new("TextLabel")
    badge.Name = "V3Badge"
    badge.Parent = main
    badge.Size = UDim2.fromOffset(54,22)
    badge.Position = UDim2.new(1,-68,0,76)
    badge.BackgroundColor3 = T.hot
    badge.BorderSizePixel = 0
    badge.Text = "v2.4 ♡"
    badge.TextColor3 = T.white
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 12
    badge.ZIndex = 60
    corner(badge,999)
    _G.KimqPageRepairReady = true
end)

-- ========================================================
-- v2.1 CLEAN BUILD: legacy V5/V6/V7/V8 visual/theme layers removed.
-- The page/backend layer remains intact; a single lightweight v2.1 theme pass runs at the end.

-- v2.62 module: local catalog / limited accessory try-on.
task.spawn(function()
    _G.KimqAccessoryUIReady=false
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local InsertService = game:GetService("InsertService")

    local lp = Players.LocalPlayer
    local playerGui = lp:WaitForChild("PlayerGui")
    _G.KimqLocalVisualAccessoriesV15 = _G.KimqLocalVisualAccessoriesV15 or {}

    local pageReadyStart=tick()
    while not _G.KimqBasePagesReady and tick()-pageReadyStart<8 do task.wait(.02) end

    local function waitForMain(timeout)
        local t0 = tick()
        while tick() - t0 < (timeout or 20) do
            local root = CoreGui:FindFirstChild("KimpetrasHC") or playerGui:FindFirstChild("KimpetrasHC")
            local main = root and root:FindFirstChild("Main")
            if main then return root, main end
            task.wait(0.08)
        end
    end

    local rootGui, main = waitForMain(10)
    if not rootGui or not main then _G.KimqAccessoryUIReady=true; return end
    if main:FindFirstChild("KimqV15AccessoryApplied") then _G.KimqAccessoryUIReady=true; return end

    local marker = Instance.new("BoolValue")
    marker.Name = "KimqV15AccessoryApplied"
    marker.Parent = main

    local avatarPage
    for _, obj in ipairs(main:GetDescendants()) do
        if obj:IsA("ScrollingFrame") and obj.Name:lower() == "avatarpage" then
            avatarPage = obj
            break
        end
    end
    if not avatarPage then _G.KimqAccessoryUIReady=true; return end

    local function corner(obj, radius)
        local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 12)
        c.Parent = obj
        return c
    end
    local function stroke(obj, color, transparency, thickness)
        local s = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        s.Color = color
        s.Transparency = transparency or 0.22
        s.Thickness = thickness or 1
        s.Parent = obj
        return s
    end

    local function findCardContaining(text)
        local needle = string.lower(text)
        for _, child in ipairs(avatarPage:GetChildren()) do
            if child:IsA("Frame") then
                for _, d in ipairs(child:GetDescendants()) do
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and string.find(string.lower(tostring(d.Text or "")), needle, 1, true) then
                        return child
                    end
                end
            end
        end
    end

    local applyCard = findCardContaining("apply avatar")
    local referenceCard = applyCard or findCardContaining("reset character")
    local badge
    for _, d in ipairs(main:GetDescendants()) do
        if d:IsA("TextLabel") and tostring(d.Text or ""):match("^[Vv]%d") then
            badge = d
            break
        end
    end

    local function sampleTheme()
        local panel = referenceCard and referenceCard.BackgroundColor3 or Color3.fromRGB(242,247,255)
        local line = Color3.fromRGB(255,212,243)
        local hot = badge and badge.BackgroundColor3 or Color3.fromRGB(243,161,211)
        local light = panel:Lerp(hot, 0.12)
        local text = Color3.fromRGB(82,116,94)
        local sub = Color3.fromRGB(122,153,133)
        if referenceCard then
            local rs = referenceCard:FindFirstChildOfClass("UIStroke")
            if rs then line = rs.Color end
            for _, d in ipairs(referenceCard:GetDescendants()) do
                if d:IsA("TextLabel") and d.TextSize >= 13 and d.TextColor3 ~= sub then
                    text = d.TextColor3
                    break
                end
            end
        end
        return panel, line, hot, light, text, sub
    end

    local panelColor, lineColor, hotColor, lightColor, textColor, subColor = sampleTheme()
    local ROW_H = referenceCard and math.clamp(referenceCard.Size.Y.Offset, 52, 56) or 54

    -- remove older accessory UI rows
    for _, child in ipairs(avatarPage:GetChildren()) do
        if child.Name:find("Accessory") or child.Name == "LocalAccessoryTryOn" then
            pcall(function() child:Destroy() end)
        end
    end

    local function makeRow(name)
        local row = Instance.new("Frame")
        row.Name = name
        row.Parent = avatarPage
        row.Size = UDim2.new(1, -6, 0, ROW_H)
        row.BackgroundColor3 = panelColor
        row.BorderSizePixel = 0
        corner(row, 12)
        stroke(row, lineColor, 0.2, 1)
        return row
    end

    -- consistent row layout matching the rest of the page
    local titleRow = makeRow("V15AccessoryTitle")
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = titleRow
    titleLbl.Size = UDim2.new(0.38, -12, 1, 0)
    titleLbl.Position = UDim2.fromOffset(12, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Wear Item by ID"
    titleLbl.TextColor3 = textColor
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local titleSub = Instance.new("TextLabel")
    titleSub.Parent = titleRow
    titleSub.Size = UDim2.new(0.62, -20, 1, 0)
    titleSub.Position = UDim2.new(0.38, 8, 0, 0)
    titleSub.BackgroundTransparency = 1
    titleSub.Text = "catalog / limited accessory • local only"
    titleSub.TextColor3 = subColor
    titleSub.Font = Enum.Font.Gotham
    titleSub.TextSize = 12
    titleSub.TextXAlignment = Enum.TextXAlignment.Right

    local inputRow = makeRow("V15AccessoryInput")
    local inputLbl = Instance.new("TextLabel")
    inputLbl.Parent = inputRow
    inputLbl.Size = UDim2.new(0, 145, 1, 0)
    inputLbl.Position = UDim2.fromOffset(12, 0)
    inputLbl.BackgroundTransparency = 1
    inputLbl.Text = "Catalog Item ID"
    inputLbl.TextColor3 = textColor
    inputLbl.Font = Enum.Font.GothamBold
    inputLbl.TextSize = 14
    inputLbl.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox")
    input.Parent = inputRow
    input.Size = UDim2.new(1, -172, 0, 34)
    input.Position = UDim2.new(0, 160, 0.5, -17)
    input.BackgroundColor3 = lightColor
    input.BorderSizePixel = 0
    input.PlaceholderText = "paste ID or catalog link..."
    input.PlaceholderColor3 = subColor
    input.Text = ""
    input.TextColor3 = textColor
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.ClearTextOnFocus = false
    input.TextXAlignment = Enum.TextXAlignment.Left
    corner(input, 10)
    local inputStroke = stroke(input, lineColor, 0.3, 1)
    local inputPad = Instance.new("UIPadding", input)
    inputPad.PaddingLeft = UDim.new(0, 10)
    inputPad.PaddingRight = UDim.new(0, 10)

    local actionRow = makeRow("V15AccessoryActions")
    local equip = Instance.new("TextButton")
    equip.Parent = actionRow
    equip.Size = UDim2.new(0.5, -14, 0, 34)
    equip.Position = UDim2.new(0, 10, 0.5, -17)
    equip.BackgroundColor3 = hotColor
    equip.BorderSizePixel = 0
    equip.Text = "♥  Wear Item"
    equip.TextColor3 = Color3.fromRGB(250,252,255)
    equip.Font = Enum.Font.GothamBold
    equip.TextSize = 13
    equip.AutoButtonColor = false
    corner(equip, 10)

    local remove = Instance.new("TextButton")
    remove.Parent = actionRow
    remove.Size = UDim2.new(0.5, -14, 0, 34)
    remove.Position = UDim2.new(0.5, 4, 0.5, -17)
    remove.BackgroundColor3 = lightColor
    remove.BorderSizePixel = 0
    remove.Text = "Remove All"
    remove.TextColor3 = textColor
    remove.Font = Enum.Font.GothamBold
    remove.TextSize = 13
    remove.AutoButtonColor = false
    corner(remove, 10)
    local removeStroke = stroke(remove, lineColor, 0.3, 1)

    local statusRow = makeRow("V15AccessoryStatus")
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Parent = statusRow
    statusLbl.Size = UDim2.new(0, 92, 1, 0)
    statusLbl.Position = UDim2.fromOffset(12, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Status"
    statusLbl.TextColor3 = textColor
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextSize = 14
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    local status = Instance.new("TextLabel")
    status.Parent = statusRow
    status.Size = UDim2.new(1, -124, 1, 0)
    status.Position = UDim2.fromOffset(110, 0)
    status.BackgroundTransparency = 1
    status.Text = "Ready"
    status.TextColor3 = subColor
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left

    local rows = {titleRow, inputRow, actionRow, statusRow}
    local baseOrder = applyCard and applyCard.LayoutOrder or 100
    for _, child in ipairs(avatarPage:GetChildren()) do
        if not table.find(rows, child)
            and not child:IsA("UIListLayout")
            and not child:IsA("UIPadding")
            and child.LayoutOrder > baseOrder then
            child.LayoutOrder += #rows
        end
    end
    for i, row in ipairs(rows) do
        row.LayoutOrder = baseOrder + i
    end

    local function setStatus(text, ok)
        status.Text = text
        status.TextColor3 = ok and hotColor or subColor
    end

    local function clearAccessoryPhysics(acc)
        for _, d in ipairs(acc:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
                pcall(function() d:Destroy() end)
            elseif d:IsA("BasePart") then
                d.CanCollide = false
                d.CanTouch = false
                d.CanQuery = false
                d.Massless = true
                d.Anchored = false
                pcall(function()
                    d.AssemblyLinearVelocity = Vector3.zero
                    d.AssemblyAngularVelocity = Vector3.zero
                end)
            elseif d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D") then
                pcall(function() d:Destroy() end)
            end
        end
    end

    local function findAccessory(root)
        if not root then return nil end
        if root:IsA("Accessory") then return root end
        return root:FindFirstChildWhichIsA("Accessory", true)
    end

    local function loadAccessory(assetId)
        local loaders = {
            function()
                local objs = game:GetObjects("rbxassetid://" .. tostring(assetId))
                for _, root in ipairs(objs or {}) do
                    local acc = findAccessory(root)
                    if acc then
                        local clone = acc:Clone()
                        for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
                        return clone, "getobjects"
                    end
                end
                for _, o in ipairs(objs or {}) do pcall(function() o:Destroy() end) end
            end,
            function()
                local model = InsertService:LoadAsset(assetId)
                if model then
                    local acc = findAccessory(model)
                    if acc then
                        local clone = acc:Clone()
                        pcall(function() model:Destroy() end)
                        return clone, "insertservice"
                    end
                    pcall(function() model:Destroy() end)
                end
            end,
        }
        for _, loader in ipairs(loaders) do
            local ok, acc, method = pcall(loader)
            if ok and acc then return acc, method end
        end
        return nil, nil
    end

    local function findAvatarAttachPair(character, handle)
        if not character or not handle then return nil end

        -- Match ANY normal Roblox accessory attachment (hat/hair/face/back/waist/
        -- shoulder/neck/front/etc.) instead of restricting the feature to head items.
        for _,handleAtt in ipairs(handle:GetChildren()) do
            if handleAtt:IsA("Attachment") then
                for _,bodyAtt in ipairs(character:GetDescendants()) do
                    if bodyAtt:IsA("Attachment")
                        and bodyAtt.Name==handleAtt.Name
                        and bodyAtt.Parent
                        and bodyAtt.Parent:IsA("BasePart") then
                        return bodyAtt.Parent, bodyAtt, handleAtt
                    end
                end
            end
        end

        -- Classic fallback.
        local head=character:FindFirstChild("Head")
        local handleHat=handle:FindFirstChild("HatAttachment")
        local headHat=head and head:FindFirstChild("HatAttachment")
        if head and handleHat and headHat then return head,headHat,handleHat end
        return nil
    end

    local function removeExistingOnChar(char, assetId)
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Accessory") and child:GetAttribute("KimqLocalV15") and child:GetAttribute("KimqAssetId") == assetId then
                pcall(function() child:Destroy() end)
            end
        end
    end

    local function attachAccessory(assetId, character, quiet)
        local char = character or lp.Character
        if not char then
            if not quiet then setStatus("Character not ready", false) end
            return false
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 6)
        if not humanoid or not head then
            if not quiet then setStatus("Character not ready", false) end
            return false
        end

        removeExistingOnChar(char, assetId)

        local info
        pcall(function()
            info = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
        end)

        local acc, method = loadAccessory(assetId)
        if not acc then
            if not quiet then setStatus("Could not load that accessory", false) end
            return false
        end

        local handle = acc:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then
            pcall(function() acc:Destroy() end)
            if not quiet then setStatus("That item is not a wearable accessory", false) end
            return false
        end

        local bodyPart, bodyAtt, handleAtt = findAvatarAttachPair(char, handle)
        if not bodyPart or not bodyAtt or not handleAtt then
            pcall(function() acc:Destroy() end)
            if not quiet then setStatus("That accessory attachment is not supported", false) end
            return false
        end

        clearAccessoryPhysics(acc)
        acc.Name = "KimqLocal_" .. tostring(assetId)
        acc:SetAttribute("KimqLocalV15", true)
        acc:SetAttribute("KimqAssetId", assetId)
        acc.Parent = char

        handle.CFrame = bodyPart.CFrame * bodyAtt.CFrame * handleAtt.CFrame:Inverse()
        local weld = Instance.new("Weld")
        weld.Name = "KimqLocalWeldV15"
        weld.Part0 = bodyPart
        weld.Part1 = handle
        weld.C0 = bodyAtt.CFrame
        weld.C1 = handleAtt.CFrame
        weld.Parent = handle

        local displayName = (info and info.Name) or "Accessory"
        if not quiet then
            setStatus("Wearing " .. displayName .. " locally", true)
        end
        return true
    end

    local function saveId(assetId)
        for _, id in ipairs(_G.KimqLocalVisualAccessoriesV15) do
            if id == assetId then return end
        end
        table.insert(_G.KimqLocalVisualAccessoriesV15, assetId)
    end

    local function removeAll(character)
        local char = character or lp.Character
        if not char then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Accessory") and child:GetAttribute("KimqLocalV15") then
                pcall(function() child:Destroy() end)
            end
        end
    end

    equip.MouseButton1Click:Connect(function()
        local assetId = tonumber((tostring(input.Text or ""):match("%d+")))
        if not assetId then
            setStatus("Enter an item ID or catalog link", false)
            return
        end
        equip.Text = "Loading..."
        setStatus("Loading accessory...", false)
        task.spawn(function()
            local ok = attachAccessory(assetId, nil, false)
            if ok then
                saveId(assetId)
                equip.Text = "Equipped ♥"
            else
                equip.Text = "Try Again"
            end
            task.wait(1.0)
            if equip.Parent then equip.Text = "♥  Wear Item" end
        end)
    end)

    remove.MouseButton1Click:Connect(function()
        removeAll()
        table.clear(_G.KimqLocalVisualAccessoriesV15)
        setStatus("Removed all local accessories", true)
    end)

    lp.CharacterAdded:Connect(function(char)
        task.spawn(function()
            char:WaitForChild("Head", 8)
            task.wait(0.9)
            for _, assetId in ipairs(_G.KimqLocalVisualAccessoriesV15) do
                attachAccessory(assetId, char, true)
                task.wait(0.08)
            end
        end)
    end)

    local function getAccessoryConfigState()
        local ids = {}
        for _, assetId in ipairs(_G.KimqLocalVisualAccessoriesV15 or {}) do
            if tonumber(assetId) then table.insert(ids, tonumber(assetId)) end
        end
        return {input=tostring(input.Text or ""), ids=ids}
    end
    local function setAccessoryConfigState(state)
        if type(state) ~= "table" then return end
        input.Text = tostring(state.input or "")
        removeAll()
        table.clear(_G.KimqLocalVisualAccessoriesV15)
        for _, rawId in ipairs(type(state.ids)=="table" and state.ids or {}) do
            local assetId = tonumber(rawId)
            if assetId then saveId(assetId) end
        end
        if lp.Character and #_G.KimqLocalVisualAccessoriesV15 > 0 then
            task.spawn(function()
                for _, assetId in ipairs(_G.KimqLocalVisualAccessoriesV15) do
                    attachAccessory(assetId, lp.Character, true)
                    task.wait(0.08)
                end
                setStatus("Restored saved accessories", true)
            end)
        end
    end
    _G.KimqAccessoryController = {
        GetState=getAccessoryConfigState,
        SetState=setAccessoryConfigState,
        Equip=attachAccessory,
        RemoveAll=removeAll,
    }
    if type(_G.KimqRegisterConfigControl) == "function" then
        _G.KimqRegisterConfigControl("Local Accessories", "state", getAccessoryConfigState, setAccessoryConfigState)
    end

    local function syncTheme()
        panelColor, lineColor, hotColor, lightColor, textColor, subColor = sampleTheme()
        for _, row in ipairs(rows) do
            row.BackgroundColor3 = panelColor
            local rs = row:FindFirstChildOfClass("UIStroke")
            if rs then rs.Color = lineColor end
        end
        titleLbl.TextColor3 = textColor
        titleSub.TextColor3 = subColor
        inputLbl.TextColor3 = textColor
        input.BackgroundColor3 = lightColor
        input.TextColor3 = textColor
        input.PlaceholderColor3 = subColor
        inputStroke.Color = lineColor
        equip.BackgroundColor3 = hotColor
        remove.BackgroundColor3 = lightColor
        remove.TextColor3 = textColor
        removeStroke.Color = lineColor
        statusLbl.TextColor3 = textColor
        local isPositive = status.Text ~= "Ready" and status.TextColor3 ~= subColor
        status.TextColor3 = isPositive and hotColor or subColor
    end

    if badge then
        badge.Text = "v2.1 ♡"
        if badge:IsA("TextLabel") then
            badge:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                task.defer(syncTheme)
            end)
        end
    end

    for _, button in ipairs({equip, remove}) do
        local scale = Instance.new("UIScale")
        scale.Parent = button
        button.MouseEnter:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.02}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
        end)
    end

    syncTheme()
    _G.KimqAccessoryUIReady=true
end)


-- ========================================================


-- v2.62 module: Environment + Weapon Skins (canonical sidebar pages).
task.spawn(function()
    local pageReadyStart=tick()
    while not _G.KimqBasePagesReady and tick()-pageReadyStart<8 do task.wait(.02) end

    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Lighting = game:GetService("Lighting")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    local loader = nil -- legacy cover loader removed in V26 Lite

    local function setProgress(text, n)
        if loader and loader.Status and loader.Status.Parent then loader.Status.Text = text end
        if loader and loader.Bar and loader.Bar.Parent then TweenService:Create(loader.Bar,TweenInfo.new(.32,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(n,0,1,0)}):Play() end
        if loader and loader.Tip and loader.Tip.Parent then TweenService:Create(loader.Tip,TweenInfo.new(.32,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(n,0,.5,0)}):Play() end
    end

    setProgress("fixing the final pages...", .91)

    local root = CoreGui:FindFirstChild("KimpetrasHC") or pg:FindFirstChild("KimpetrasHC")
    local main = root and root:FindFirstChild("Main")
    if not main then
        _G.KimqV26FeaturesReady=true
        return
    end

    local function norm(s)
        s=tostring(s or ""):lower():gsub("[♥♡❤]","")
        s=s:gsub("^%s+",""):gsub("%s+$",""):gsub("%s+"," ")
        return s
    end
    local function corner(o,r)
        local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius=UDim.new(0,r or 12); c.Parent=o; return c
    end
    local function stroke(o,color,tr,th)
        local s=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        s.Color=color; s.Transparency=tr or .22; s.Thickness=th or 1; s.Parent=o; return s
    end
    local function txt(parent,text,size,pos,font,ts,color,align)
        local l=Instance.new("TextLabel",parent)
        l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=text; l.Font=font; l.TextSize=ts; l.TextColor3=color; l.TextXAlignment=align or Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Center
        return l
    end

    local pages, pageHost = {}, nil
    for _,d in ipairs(main:GetDescendants()) do
        if d:IsA("ScrollingFrame") and d.Name:match("Page$") then pages[d.Name:gsub("Page$",""):lower()] = d; pageHost=d.Parent end
    end
    if not pageHost then
        _G.KimqV26FeaturesReady=true; return
    end

    local nav
    for _,d in ipairs(main:GetDescendants()) do
        if d:IsA("ScrollingFrame") and not d.Name:match("Page$") then
            for _,b in ipairs(d:GetChildren()) do
                if b:IsA("TextButton") and norm(b.Text)=="overview" then nav=d break end
            end
        end
        if nav then break end
    end
    if not nav then
        _G.KimqV26FeaturesReady=true; return
    end

    local badge
    for _,d in ipairs(main:GetDescendants()) do
        if d:IsA("TextLabel") and tostring(d.Text or ""):match("^[Vv]%d") then
            d.Text="v2.1 ♡"
            if not badge or d.Visible then badge=d end
        end
    end

    local pageTitle,pageDesc
    for _,d in ipairs(main:GetDescendants()) do
        if d:IsA("TextLabel") then
            if norm(d.Text)=="overview" and d.TextSize>=18 then pageTitle=d end
            if tostring(d.Text or ""):lower():find("your account",1,true) then pageDesc=d end
        end
    end

    -- Find normal sidebar buttons before deleting the V21 specials.
    local normalButtons={}
    for _,b in ipairs(nav:GetChildren()) do
        if b:IsA("TextButton") and norm(b.Text)~="environment" and norm(b.Text)~="weapon skins" then
            table.insert(normalButtons,b)
        end
    end
    local function chooseInactiveTemplate()
        local hot = badge and badge.BackgroundColor3
        for _,b in ipairs(normalButtons) do
            if norm(b.Text)~="overview" and (not hot or math.sqrt((b.BackgroundColor3.R-hot.R)^2 + (b.BackgroundColor3.G-hot.G)^2 + (b.BackgroundColor3.B-hot.B)^2) > .08) then return b end
        end
        return normalButtons[2] or normalButtons[1]
    end
    local function chooseActiveTemplate()
        local hot = badge and badge.BackgroundColor3
        if hot then
            for _,b in ipairs(normalButtons) do if math.sqrt((b.BackgroundColor3.R-hot.R)^2 + (b.BackgroundColor3.G-hot.G)^2 + (b.BackgroundColor3.B-hot.B)^2) < .08 then return b end end
        end
        for _,b in ipairs(normalButtons) do if norm(b.Text)=="overview" then return b end end
        return normalButtons[1]
    end
    local inactiveTemplate=chooseInactiveTemplate()
    local activeTemplate=chooseActiveTemplate()
    if not inactiveTemplate then _G.KimqV26FeaturesReady=true; return end

    local function copyVisual(dst,src)
        if not dst or not src then return end
        dst.BackgroundColor3=src.BackgroundColor3; dst.BackgroundTransparency=src.BackgroundTransparency
        dst.TextColor3=src.TextColor3; dst.TextStrokeColor3=src.TextStrokeColor3; dst.TextStrokeTransparency=src.TextStrokeTransparency
        dst.Font=src.Font; dst.TextSize=src.TextSize
        local ss=src:FindFirstChildOfClass("UIStroke"); local ds=dst:FindFirstChildOfClass("UIStroke")
        if ss then ds=ds or Instance.new("UIStroke",dst); ds.Color=ss.Color; ds.Transparency=ss.Transparency; ds.Thickness=ss.Thickness end
    end

    local function sampleTheme()
        inactiveTemplate=chooseInactiveTemplate() or inactiveTemplate
        activeTemplate=chooseActiveTemplate() or activeTemplate
        local hot=(badge and badge.BackgroundColor3) or (activeTemplate and activeTemplate.BackgroundColor3) or Color3.fromRGB(243,161,211)
        local panel=inactiveTemplate.BackgroundColor3
        local line=(inactiveTemplate:FindFirstChildOfClass("UIStroke") and inactiveTemplate:FindFirstChildOfClass("UIStroke").Color) or hot:Lerp(Color3.new(1,1,1),.55)
        local text=inactiveTemplate.TextColor3
        local sub=text:Lerp(panel,.42)
        local light=panel:Lerp(hot,.12)
        return panel,line,hot,light,text,sub
    end
    local panelColor,lineColor,hotColor,lightColor,textColor,subColor=sampleTheme()
    local function pcolor(key,fallback)
        local p=_G.KimqThemeLivePalette
        if type(p)=="table" and p[key] then return p[key] end
        return fallback
    end

    -- v2.62: Environment and Weapon Skins are already real canonical pages/buttons.
    -- Populate those pages instead of deleting/recreating navigation after startup.
    local function card(page,h)
        local f=Instance.new("Frame",page); f.Size=UDim2.new(1,-6,0,h or 56); f.BackgroundColor3=panelColor; f.BorderSizePixel=0; corner(f,14); stroke(f,lineColor,.2,1); return f
    end

    local envPage=pages.environment
    local skinsPage=pages.weaponskins
    if not envPage or not skinsPage then
        _G.KimqV26FeaturesReady=true
        return
    end

    -- Clear only old content frames if this module is ever rebuilt; keep layout/padding.
    for _,page in ipairs({envPage,skinsPage}) do
        for _,ch in ipairs(page:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                pcall(function() ch:Destroy() end)
            end
        end
    end

    local envBtn,skinsBtn
    for _,b in ipairs(nav:GetChildren()) do
        if b:IsA("TextButton") then
            local n=norm(b.Text)
            if n=="environment" then envBtn=b end
            if n=="weapon skins" then skinsBtn=b end
        end
    end
    if not envBtn or not skinsBtn then
        _G.KimqV26FeaturesReady=true
        return
    end

    local envBuildOk, envBuildErr = pcall(function()
    -- Environment ----------------------------------------------------------
    pcall(function() if _G.KimqEnvironmentController and _G.KimqEnvironmentController.Restore then _G.KimqEnvironmentController.Restore() end end)
    for _,n in ipairs({"KimqV20Environment","KimqV21Environment","KimqV26Environment"}) do local x=workspace:FindFirstChild(n); if x then x:Destroy() end end
    local oldCC=Lighting:FindFirstChild("KimqV21SeasonColor"); if oldCC then oldCC:Destroy() end

    local ei=card(envPage,48)
    local eiTitle=txt(ei,"♥  environment",UDim2.new(1,-24,1,0),UDim2.fromOffset(12,0),Enum.Font.GothamBold,20,hotColor)

    local original={Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,Exposure=Lighting.ExposureCompensation,GlobalShadows=Lighting.GlobalShadows,ShadowSoftness=Lighting.ShadowSoftness,EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale,LightingStyle=Lighting.LightingStyle,PrioritizeLightingQuality=Lighting.PrioritizeLightingQuality,Grass=terrain and terrain:GetMaterialColor(Enum.Material.Grass),Ground=terrain and terrain:GetMaterialColor(Enum.Material.Ground)}
    local changedParts={}; local seasonFolder=Instance.new("Folder",workspace); seasonFolder.Name="KimqV26Environment"; local followConn; local activePreset="Normal"

    -- Corner/contact shadows are layered on top of the active Environment preset.
    -- This intentionally does NOT darken Ambient/OutdoorAmbient, Atmosphere, Sky,
    -- Brightness, or Exposure, so the sky keeps the game's existing look.
    local shadowEnabled=false
    local shadowDarkness=65
    local shadowSoftness=28
    -- v2.105: public cleanup can restore any map-light changes too. The real
    -- implementation is assigned after the day/night light helpers are created.
    local restoreLightBoost=function() end
    local function applyShadowLook()
        if shadowEnabled then
            local d=math.clamp(tonumber(shadowDarkness) or 65,0,150)
            local fillFactor
            if d<=100 then
                -- Preserve the v2.104 look from 0-100%.
                fillFactor=1-(d/100)*.90
            else
                -- Extra-deep range: 100% leaves 10% diffuse fill, 150% can
                -- remove the remaining fill for much darker corners/creases.
                fillFactor=.10*(1-((d-100)/50))
            end
            Lighting.GlobalShadows=true
            Lighting.ShadowSoftness=math.clamp(shadowSoftness/100,0,1)
            Lighting.EnvironmentDiffuseScale=math.clamp(original.EnvironmentDiffuseScale*fillFactor,0,1)
            pcall(function() Lighting.LightingStyle=Enum.LightingStyle.Realistic end)
            pcall(function() Lighting.PrioritizeLightingQuality=true end)
        else
            Lighting.GlobalShadows=original.GlobalShadows
            Lighting.ShadowSoftness=original.ShadowSoftness
            Lighting.EnvironmentDiffuseScale=original.EnvironmentDiffuseScale
            pcall(function() Lighting.LightingStyle=original.LightingStyle end)
            pcall(function() Lighting.PrioritizeLightingQuality=original.PrioritizeLightingQuality end)
        end
    end

    local function grassLike(p)
        if not p:IsA("BasePart") or p:IsDescendantOf(seasonFolder) then return false end
        local n=p.Name:lower()
        if p.Material==Enum.Material.Grass or n:find("grass",1,true) or n:find("lawn",1,true) or n:find("turf",1,true) then return true end
        local c=p.Color; local flat=p.Size.Y<=5 and (p.Size.X>=6 or p.Size.Z>=6); local green=c.G>c.R*1.12 and c.G>c.B*1.08 and c.G>.22
        return flat and green
    end
    local function savePart(p)
        if changedParts[p] then return end
        local rec={Color=p.Color,Material=p.Material,Children={}}
        for _,d in ipairs(p:GetDescendants()) do
            if d:IsA("Texture") or d:IsA("Decal") then table.insert(rec.Children,{Obj=d,Transparency=d.Transparency}) end
        end
        changedParts[p]=rec
    end
    local function recolorGrass(color,material,hideTextures)
        local count=0
        for _,p in ipairs(workspace:GetDescendants()) do
            if grassLike(p) then
                savePart(p); p.Color=color; if material then p.Material=material end
                if hideTextures then for _,r in ipairs(changedParts[p].Children) do if r.Obj and r.Obj.Parent then r.Obj.Transparency=1 end end end
                count+=1; if count>4500 then break end
            end
        end
    end
    local function clearSeasonFX()
        if followConn then pcall(function() followConn:Disconnect() end); followConn=nil end
        seasonFolder:ClearAllChildren()
        for _,n in ipairs({"KimqV21SeasonColor","KimqV26SeasonColor"}) do local cc=Lighting:FindFirstChild(n); if cc then cc:Destroy() end end
    end
    local function restoreEnvBase()
        clearSeasonFX()
        for p,rec in pairs(changedParts) do
            if p and p.Parent then
                pcall(function() p.Color=rec.Color; p.Material=rec.Material end)
                for _,r in ipairs(rec.Children or {}) do if r.Obj and r.Obj.Parent then pcall(function() r.Obj.Transparency=r.Transparency end) end end
            end
        end
        table.clear(changedParts)
        Lighting.Ambient=original.Ambient; Lighting.OutdoorAmbient=original.OutdoorAmbient; Lighting.Brightness=original.Brightness; Lighting.ClockTime=original.ClockTime; Lighting.ExposureCompensation=original.Exposure
        Lighting.GlobalShadows=original.GlobalShadows; Lighting.ShadowSoftness=original.ShadowSoftness; Lighting.EnvironmentDiffuseScale=original.EnvironmentDiffuseScale
        pcall(function() Lighting.LightingStyle=original.LightingStyle end); pcall(function() Lighting.PrioritizeLightingQuality=original.PrioritizeLightingQuality end)
        if terrain then pcall(function() terrain:SetMaterialColor(Enum.Material.Grass,original.Grass) end); pcall(function() terrain:SetMaterialColor(Enum.Material.Ground,original.Ground) end) end
        activePreset="Normal"
    end
    local function restoreEnv()
        -- Public restore is a true cleanup for re-execution.
        shadowEnabled=false
        pcall(restoreLightBoost)
        restoreEnvBase()
    end
    local function addSnow()
        local holder=Instance.new("Part",seasonFolder); holder.Name="CuteSnowCloud"; holder.Size=Vector3.new(150,1,150); holder.Transparency=1; holder.Anchored=true; holder.CanCollide=false; holder.CanTouch=false; holder.CanQuery=false
        local function emit(rate,sizeA,sizeB,speedA,speedB,spread,alpha)
            local e=Instance.new("ParticleEmitter",holder)
            e.Texture="rbxasset://textures/particles/sparkles_main.dds"; e.Rate=rate; e.Lifetime=NumberRange.new(7,10); e.Speed=NumberRange.new(speedA,speedB); e.Acceleration=Vector3.new(.3,-1.25,.15); e.Drag=.4; e.LightInfluence=0; e.EmissionDirection=Enum.NormalId.Bottom; e.SpreadAngle=Vector2.new(spread,spread); e.Rotation=NumberRange.new(0,360); e.RotSpeed=NumberRange.new(-9,9); e.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(225,241,255)); e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,sizeA),NumberSequenceKeypoint.new(.55,sizeB),NumberSequenceKeypoint.new(1,sizeA*.55)}); e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,alpha),NumberSequenceKeypoint.new(.88,alpha+.1),NumberSequenceKeypoint.new(1,1)})
        end
        emit(185,.06,.11,1.7,3.0,22,.05); emit(72,.12,.20,1.15,2.3,30,.16); emit(24,.21,.31,.8,1.6,36,.30)
        local function follow() local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if hrp and holder.Parent then holder.CFrame=CFrame.new(hrp.Position+Vector3.new(0,48,0)) end end
        follow(); followConn=RunService.RenderStepped:Connect(follow)
    end

    local presetRows={}
    local envStatusValue
    local function refreshPreset()
        for name,p in pairs(presetRows) do
            local on=name==activePreset
            p.Button.Text=on and (name.."  ♥") or name
            p.Button.BackgroundColor3=on and pcolor("hot",hotColor) or pcolor("soft",lightColor)
            p.Button.TextColor3=on and Color3.fromRGB(250,252,255) or pcolor("text",textColor)
        end
        if envStatusValue then
            envStatusValue.Text="current: "..activePreset:lower()
            envStatusValue.TextColor3=activePreset=="Normal" and pcolor("sub",subColor) or pcolor("hot",hotColor)
        end
    end
    local function applyEnv(name)
        restoreEnvBase(); activePreset=name
        if name=="Christmas" then
            if terrain then pcall(function() terrain:SetMaterialColor(Enum.Material.Grass,Color3.fromRGB(239,246,252)) end); pcall(function() terrain:SetMaterialColor(Enum.Material.Ground,Color3.fromRGB(229,238,247)) end) end
            recolorGrass(Color3.fromRGB(241,247,252),Enum.Material.Snow,true)
            Lighting.Ambient=original.Ambient:Lerp(Color3.fromRGB(222,234,247),.18); Lighting.OutdoorAmbient=original.OutdoorAmbient:Lerp(Color3.fromRGB(235,244,252),.22); Lighting.Brightness=math.max(original.Brightness,1.85); Lighting.ExposureCompensation=original.Exposure+.02
            addSnow()
        elseif name=="Halloween" then
            if terrain then pcall(function() terrain:SetMaterialColor(Enum.Material.Grass,Color3.fromRGB(191,132,78)) end) end
            recolorGrass(Color3.fromRGB(196,129,70),nil,false)
            Lighting.Ambient=original.Ambient:Lerp(Color3.fromRGB(190,135,132),.12); Lighting.OutdoorAmbient=original.OutdoorAmbient:Lerp(Color3.fromRGB(218,158,121),.13); Lighting.Brightness=math.max(original.Brightness*.98,1.8); Lighting.ClockTime=16.6; Lighting.ExposureCompensation=original.Exposure
        end
        -- No fog, Atmosphere, or color-correction properties are touched here.
        applyShadowLook()
        refreshPreset()
    end

    -- v2.105 compact preset card: one card instead of four separate rows.
    local presetCard=card(envPage,102); presetCard.Name="KimqEnvironmentPresetCard"
    presetCard:SetAttribute("KimqV26Role","panel")
    local presetTitle=txt(presetCard,"♥  Environment Preset",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor); presetTitle:SetAttribute("KimqV26Role","hotText")
    local function presetButton(name,x,w)
        local b=Instance.new("TextButton",presetCard)
        b.Size=UDim2.new(w,-6,0,32); b.Position=UDim2.new(x,6,0,39)
        b.BackgroundColor3=pcolor("soft",lightColor); b.BorderSizePixel=0; b.Text=name; b.TextColor3=textColor
        b.Font=Enum.Font.GothamSemibold; b.TextSize=10; b.AutoButtonColor=false; corner(b,9); stroke(b,lineColor,.3,1)
        b:SetAttribute("KimqV26Role","lightBg")
        presetRows[name]={Button=b}
        b.MouseButton1Click:Connect(function() applyEnv(name) end)
        return b
    end
    presetButton("Normal",0,.34)
    presetButton("Christmas",.34,.33)
    presetButton("Halloween",.67,.33)
    envStatusValue=txt(presetCard,"current: normal",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,77),Enum.Font.Gotham,9,subColor); envStatusValue:SetAttribute("KimqV26Role","subText")
    refreshPreset()

    _G.KimqEnvironmentController={Apply=applyEnv,Restore=restoreEnv,GetPreset=function() return activePreset end}
    if type(_G.KimqRegisterConfigControl) == "function" then
        _G.KimqRegisterConfigControl("Environment Preset", "dropdown",
            function() return activePreset end,
            function(v)
                v=tostring(v or "Normal")
                if v~="Normal" and v~="Christmas" and v~="Halloween" then v="Normal" end
                applyEnv(v)
            end
        )
    end

    -- Permanent Day / Night. Only ClockTime is locked; the game's own sky, colors,
    -- fog and environment remain intact. This prevents competing time loops from flashing.
    local timeMode="Game Default"
    local nightLights=false
    local DAY_CLOCK=tonumber(original.ClockTime) or 14
    if DAY_CLOCK<6 or DAY_CLOCK>18 then DAY_CLOCK=14 end
    local NIGHT_CLOCK=0
    local forcingClock=false
    local lightOriginal=setmetatable({}, {__mode="k"})
    local lightConnections=setmetatable({}, {__mode="k"})
    local lightBrightnessOriginal=setmetatable({}, {__mode="k"})
    local lightBoostEnabled=false
    local lightBrightness=180
    local lightGlow=20
    local lightBloom=nil

    local function isMapLight(light)
        if not (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then return false end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Character and light:IsDescendantOf(plr.Character) then return false end
        end
        local cur=light.Parent
        while cur and cur~=workspace do
            local n=tostring(cur.Name):lower()
            if n:find("bullet",1,true) or n:find("tracer",1,true) or n:find("projectile",1,true) or n:find("muzzle",1,true) or n=="ignore" then return false end
            cur=cur.Parent
        end
        return true
    end
    local function rememberMapLight(light)
        if not isMapLight(light) then return end
        if lightOriginal[light]==nil then lightOriginal[light]=light.Enabled end
        if lightBrightnessOriginal[light]==nil then lightBrightnessOriginal[light]=light.Brightness end
        if not lightConnections[light] then
            lightConnections[light]=light:GetPropertyChangedSignal("Enabled"):Connect(function()
                if timeMode=="Night" and nightLights and light.Parent and not light.Enabled then
                    pcall(function() light.Enabled=true end)
                end
            end)
        end
        if timeMode=="Night" and nightLights then pcall(function() light.Enabled=true end) end
        if lightBoostEnabled then
            local base=lightBrightnessOriginal[light]
            if base~=nil then pcall(function() light.Brightness=math.max(0,base*(lightBrightness/100)) end) end
        end
    end
    local function scanMapLights()
        for _,d in ipairs(workspace:GetDescendants()) do if isMapLight(d) then rememberMapLight(d) end end
    end
    local function refreshLightBloom()
        if not lightBoostEnabled or lightGlow<=0 then
            if lightBloom then pcall(function() lightBloom:Destroy() end); lightBloom=nil end
            return
        end
        if not lightBloom or not lightBloom.Parent then
            lightBloom=Instance.new("BloomEffect")
            lightBloom.Name="KimqWorldLightGlow"
            lightBloom.Parent=Lighting
        end
        lightBloom.Intensity=math.clamp(lightGlow/100,0,1)*1.25
        lightBloom.Size=24
        lightBloom.Threshold=1.35
    end
    local function applyLightBoost()
        scanMapLights()
        local mult=math.clamp(lightBrightness/100,1,4)
        for light,base in pairs(lightBrightnessOriginal) do
            if light and light.Parent then
                pcall(function() light.Brightness=lightBoostEnabled and math.max(0,base*mult) or base end)
            end
        end
        refreshLightBloom()
    end
    restoreLightBoost=function()
        lightBoostEnabled=false
        for light,base in pairs(lightBrightnessOriginal) do
            if light and light.Parent then pcall(function() light.Brightness=base end) end
        end
        if lightBloom then pcall(function() lightBloom:Destroy() end); lightBloom=nil end
    end
    workspace.DescendantAdded:Connect(function(d)
        if (d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")) then
            task.defer(function() if d.Parent then rememberMapLight(d) end end)
        end
    end)
    local function applyNightLights()
        if nightLights and timeMode=="Night" then scanMapLights() end
        local forceOn=nightLights and timeMode=="Night"
        for light,wasEnabled in pairs(lightOriginal) do
            if light and light.Parent then pcall(function() light.Enabled=forceOn and true or wasEnabled end) end
        end
    end
    local function wantedClock()
        if timeMode=="Day" then return DAY_CLOCK end
        if timeMode=="Night" then return NIGHT_CLOCK end
        return nil
    end
    local function enforceClock()
        local wanted=wantedClock(); if wanted==nil then return end
        if math.abs(Lighting.ClockTime-wanted)>.005 then
            forcingClock=true
            pcall(function() Lighting.ClockTime=wanted end)
            forcingClock=false
        end
    end

    local timeCard=card(envPage,144); timeCard.Name="KimqTimeOfDayCard"
    txt(timeCard,"♥  Day / Night",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor)
    local function timeButton(label,x,w)
        local b=Instance.new("TextButton",timeCard); b.Size=UDim2.new(w,-6,0,32); b.Position=UDim2.new(x,6,0,38); b.BackgroundColor3=lightColor; b.BorderSizePixel=0; b.Text=label; b.TextColor3=textColor; b.Font=Enum.Font.GothamSemibold; b.TextSize=11; b.AutoButtonColor=false; corner(b,9); stroke(b,lineColor,.3,1); return b
    end
    local defaultTimeBtn=timeButton("game default",0,.34)
    local dayTimeBtn=timeButton("day",.34,.33)
    local nightTimeBtn=timeButton("night",.67,.33)
    txt(timeCard,"Night Lights",UDim2.new(0,180,0,24),UDim2.fromOffset(12,82),Enum.Font.GothamSemibold,11,textColor)
    local nightToggle=Instance.new("TextButton",timeCard); nightToggle.Size=UDim2.fromOffset(48,24); nightToggle.Position=UDim2.new(1,-60,0,82); nightToggle.Text=""; nightToggle.AutoButtonColor=false; nightToggle.BorderSizePixel=0; corner(nightToggle,999)
    local nightKnob=Instance.new("Frame",nightToggle); nightKnob.Size=UDim2.fromOffset(18,18); nightKnob.Position=UDim2.new(0,3,.5,-9); nightKnob.BackgroundColor3=Color3.new(1,1,1); nightKnob.BorderSizePixel=0; corner(nightKnob,999)
    local timeStatus=txt(timeCard,"Game clock is unchanged.",UDim2.new(1,-24,0,26),UDim2.fromOffset(12,112),Enum.Font.Gotham,9,subColor); timeStatus.TextWrapped=true
    local function refreshTimeUI()
        local function style(b,on) b.BackgroundColor3=on and pcolor("hot",hotColor) or pcolor("soft",lightColor); b.TextColor3=on and Color3.new(1,1,1) or pcolor("text",textColor) end
        style(defaultTimeBtn,timeMode=="Game Default"); style(dayTimeBtn,timeMode=="Day"); style(nightTimeBtn,timeMode=="Night")
        nightToggle.BackgroundColor3=nightLights and pcolor("hot",hotColor) or pcolor("soft",lightColor)
        nightKnob.Position=nightLights and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
        if timeMode=="Day" then timeStatus.Text="Day is locked to the game's normal daylight look."
        elseif timeMode=="Night" then timeStatus.Text=nightLights and "Midnight locked • map lights on ♡" or "Midnight locked."
        else timeStatus.Text="Game clock is unchanged." end
        timeStatus.TextColor3=timeMode=="Game Default" and pcolor("sub",subColor) or pcolor("hot",hotColor)
    end
    local function setTimeMode(mode)
        if mode~="Day" and mode~="Night" then mode="Game Default" end
        timeMode=mode
        if timeMode=="Game Default" then
            forcingClock=true; pcall(function() Lighting.ClockTime=original.ClockTime end); forcingClock=false
        else enforceClock() end
        applyNightLights(); refreshTimeUI()
    end
    defaultTimeBtn.MouseButton1Click:Connect(function() setTimeMode("Game Default") end)
    dayTimeBtn.MouseButton1Click:Connect(function() setTimeMode("Day") end)
    nightTimeBtn.MouseButton1Click:Connect(function() setTimeMode("Night") end)
    nightToggle.MouseButton1Click:Connect(function() nightLights=not nightLights; applyNightLights(); refreshTimeUI() end)
    Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function() if not forcingClock and wantedClock()~=nil then enforceClock() end end)
    pcall(function()
        RunService:BindToRenderStep("KimqPermanentTimeV261",Enum.RenderPriority.Last.Value,function()
            if wantedClock()~=nil then enforceClock() end
        end)
    end)
    refreshTimeUI()
    _G.KimqEnvironmentController.SetTimeMode=setTimeMode
    _G.KimqEnvironmentController.GetTimeMode=function() return timeMode end
    _G.KimqEnvironmentController.SetNightLights=function(v) nightLights=not not v; applyNightLights(); refreshTimeUI() end
    _G.KimqEnvironmentController.GetNightLights=function() return nightLights end
    if type(_G.KimqRegisterConfigControl)=="function" then
        _G.KimqRegisterConfigControl("Time of Day","dropdown",function() return timeMode end,function(v) setTimeMode(tostring(v or "Game Default")) end)
        _G.KimqRegisterConfigControl("Night Lights","toggle",function() return nightLights end,function(v) nightLights=not not v; applyNightLights(); refreshTimeUI() end)
    end

    -- World Lights ---------------------------------------------------------
    do
        local lightCard=card(envPage,190); lightCard.Name="KimqWorldLightsCard"
        lightCard:SetAttribute("KimqV26Role","panel")
        local lightTitle=txt(lightCard,"♥  World Lights",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor)
        lightTitle:SetAttribute("KimqV26Role","hotText")
        local boostLabel=txt(lightCard,"Enhanced Lights",UDim2.fromOffset(170,24),UDim2.fromOffset(12,38),Enum.Font.GothamSemibold,11,textColor)
        boostLabel:SetAttribute("KimqV26Role","textText")
        local boostToggle=Instance.new("TextButton",lightCard)
        boostToggle.Size=UDim2.fromOffset(48,24); boostToggle.Position=UDim2.new(1,-60,0,38); boostToggle.Text=""; boostToggle.AutoButtonColor=false; boostToggle.BorderSizePixel=0; corner(boostToggle,999)
        local boostKnob=Instance.new("Frame",boostToggle); boostKnob.Size=UDim2.fromOffset(18,18); boostKnob.Position=UDim2.new(0,3,.5,-9); boostKnob.BackgroundColor3=Color3.new(1,1,1); boostKnob.BorderSizePixel=0; corner(boostKnob,999)

        local function makeLightSlider(y,label,minv,maxv,getter,setter,suffix)
            local row=Instance.new("Frame",lightCard); row.Size=UDim2.new(1,-24,0,46); row.Position=UDim2.fromOffset(12,y); row.BackgroundTransparency=1
            local lab=txt(row,label,UDim2.new(.56,0,0,20),UDim2.fromOffset(0,0),Enum.Font.GothamSemibold,10,textColor); lab:SetAttribute("KimqV26Role","textText")
            local val=txt(row,"",UDim2.new(.42,0,0,20),UDim2.new(.58,0,0,0),Enum.Font.GothamBold,10,hotColor,Enum.TextXAlignment.Right); val:SetAttribute("KimqV26Role","hotText")
            local track=Instance.new("Frame",row); track.Active=true; track.Size=UDim2.new(1,0,0,7); track.Position=UDim2.fromOffset(0,29); track.BackgroundColor3=pcolor("soft",lightColor); track.BorderSizePixel=0; corner(track,999); track:SetAttribute("KimqV26Role","lightBg")
            local fill=Instance.new("Frame",track); fill.Size=UDim2.fromScale(0,1); fill.BackgroundColor3=pcolor("hot",hotColor); fill.BorderSizePixel=0; corner(fill,999); fill:SetAttribute("KimqV26Role","hotBg")
            local knob=Instance.new("Frame",track); knob.Active=true; knob.AnchorPoint=Vector2.new(.5,.5); knob.Size=UDim2.fromOffset(15,15); knob.Position=UDim2.new(0,0,.5,0); knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0; corner(knob,999); stroke(knob,pcolor("hot",hotColor),.1,1)
            local dragging=false
            local function refresh()
                local v=math.clamp(tonumber(getter()) or minv,minv,maxv); local a=(v-minv)/(maxv-minv)
                fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0); val.Text=tostring(math.floor(v+.5))..(suffix or "%")
            end
            local function setFromX(x)
                local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
                setter(minv+(maxv-minv)*a); refresh()
            end
            track.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
            knob.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            refresh(); return refresh
        end

        local refreshBrightness=makeLightSlider(70,"Light Brightness",100,400,function() return lightBrightness end,function(v) lightBrightness=math.clamp(v,100,400); if lightBoostEnabled then applyLightBoost() end end,"%")
        local refreshGlow=makeLightSlider(116,"Light Glow",0,100,function() return lightGlow end,function(v) lightGlow=math.clamp(v,0,100); if lightBoostEnabled then refreshLightBloom() end end,"%")
        local resetLight=Instance.new("TextButton",lightCard); resetLight.Size=UDim2.fromOffset(96,24); resetLight.Position=UDim2.new(1,-108,1,-28); resetLight.BackgroundColor3=pcolor("soft",lightColor); resetLight.BorderSizePixel=0; resetLight.Text="reset"; resetLight.TextColor3=textColor; resetLight.Font=Enum.Font.GothamBold; resetLight.TextSize=10; resetLight.AutoButtonColor=false; corner(resetLight,8); stroke(resetLight,lineColor,.3,1); resetLight:SetAttribute("KimqV26Role","lightBg")

        local function refreshLightUI()
            boostToggle.BackgroundColor3=lightBoostEnabled and pcolor("hot",hotColor) or pcolor("soft",lightColor)
            boostToggle:SetAttribute("KimqV26Role",lightBoostEnabled and "hotBg" or "lightBg")
            boostKnob.Position=lightBoostEnabled and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
            refreshBrightness(); refreshGlow()
        end
        local function setLightBoost(v) lightBoostEnabled=not not v; applyLightBoost(); refreshLightUI() end
        local function setLightBrightness(v) lightBrightness=math.clamp(tonumber(v) or 180,100,400); if lightBoostEnabled then applyLightBoost() end; refreshLightUI() end
        local function setLightGlow(v) lightGlow=math.clamp(tonumber(v) or 20,0,100); if lightBoostEnabled then refreshLightBloom() end; refreshLightUI() end
        boostToggle.MouseButton1Click:Connect(function() setLightBoost(not lightBoostEnabled) end)
        resetLight.MouseButton1Click:Connect(function() lightBoostEnabled=false; lightBrightness=180; lightGlow=20; restoreLightBoost(); refreshLightUI() end)
        refreshLightUI()

        _G.KimqEnvironmentController.SetLightBoost=setLightBoost
        _G.KimqEnvironmentController.GetLightBoost=function() return lightBoostEnabled end
        _G.KimqEnvironmentController.SetLightBrightness=setLightBrightness
        _G.KimqEnvironmentController.GetLightBrightness=function() return lightBrightness end
        _G.KimqEnvironmentController.SetLightGlow=setLightGlow
        _G.KimqEnvironmentController.GetLightGlow=function() return lightGlow end
        if type(_G.KimqRegisterConfigControl)=="function" then
            _G.KimqRegisterConfigControl("Enhanced Lights","toggle",function() return lightBoostEnabled end,function(v) setLightBoost(v) end)
            _G.KimqRegisterConfigControl("Light Brightness","slider",function() return lightBrightness end,function(v) setLightBrightness(v) end)
            _G.KimqRegisterConfigControl("Light Glow","slider",function() return lightGlow end,function(v) setLightGlow(v) end)
        end
    end

    -- Shadows --------------------------------------------------------------
    do
        local shadowCard=card(envPage,190); shadowCard.Name="KimqShadowsCard"
        shadowCard:SetAttribute("KimqV26Role","panel")
        local shadowTitle=txt(shadowCard,"♥  Corner Shadows",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor)
        shadowTitle:SetAttribute("KimqV26Role","hotText")

        local shadowToggleLabel=txt(shadowCard,"Corner / Contact Shadows",UDim2.fromOffset(180,24),UDim2.fromOffset(12,38),Enum.Font.GothamSemibold,11,textColor)
        shadowToggleLabel:SetAttribute("KimqV26Role","textText")
        local shadowToggle=Instance.new("TextButton",shadowCard)
        shadowToggle.Size=UDim2.fromOffset(48,24); shadowToggle.Position=UDim2.new(1,-60,0,38); shadowToggle.Text=""; shadowToggle.AutoButtonColor=false; shadowToggle.BorderSizePixel=0; corner(shadowToggle,999)
        local shadowKnob=Instance.new("Frame",shadowToggle); shadowKnob.Size=UDim2.fromOffset(18,18); shadowKnob.Position=UDim2.new(0,3,.5,-9); shadowKnob.BackgroundColor3=Color3.new(1,1,1); shadowKnob.BorderSizePixel=0; corner(shadowKnob,999)

        local function makeShadowSlider(y,label,minv,maxv,getter,setter)
            local row=Instance.new("Frame",shadowCard); row.Size=UDim2.new(1,-24,0,46); row.Position=UDim2.fromOffset(12,y); row.BackgroundTransparency=1
            local lab=txt(row,label,UDim2.new(.56,0,0,20),UDim2.fromOffset(0,0),Enum.Font.GothamSemibold,10,textColor); lab:SetAttribute("KimqV26Role","textText")
            local val=txt(row,"",UDim2.new(.42,0,0,20),UDim2.new(.58,0,0,0),Enum.Font.GothamBold,10,hotColor,Enum.TextXAlignment.Right); val:SetAttribute("KimqV26Role","hotText")
            local track=Instance.new("Frame",row); track.Active=true; track.Size=UDim2.new(1,0,0,7); track.Position=UDim2.fromOffset(0,29); track.BackgroundColor3=pcolor("soft",lightColor); track.BorderSizePixel=0; corner(track,999); track:SetAttribute("KimqV26Role","lightBg")
            local fill=Instance.new("Frame",track); fill.Size=UDim2.fromScale(0,1); fill.BackgroundColor3=pcolor("hot",hotColor); fill.BorderSizePixel=0; corner(fill,999); fill:SetAttribute("KimqV26Role","hotBg")
            local knob=Instance.new("Frame",track); knob.Active=true; knob.AnchorPoint=Vector2.new(.5,.5); knob.Size=UDim2.fromOffset(15,15); knob.Position=UDim2.new(0,0,.5,0); knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0; corner(knob,999); stroke(knob,pcolor("hot",hotColor),.1,1)
            local dragging=false
            local function refresh()
                local v=math.clamp(tonumber(getter()) or minv,minv,maxv)
                local a=(v-minv)/(maxv-minv)
                fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0); val.Text=tostring(math.floor(v+.5)).."%"
            end
            local function setFromX(x)
                local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
                setter(minv+(maxv-minv)*a); refresh()
            end
            track.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
            knob.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X) end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            refresh(); return refresh
        end

        local refreshDark=makeShadowSlider(70,"Corner Darkness",0,150,function() return shadowDarkness end,function(v) shadowDarkness=math.clamp(v,0,150); applyShadowLook() end)
        local refreshSoft=makeShadowSlider(116,"Shadow Edge Softness",0,100,function() return shadowSoftness end,function(v) shadowSoftness=math.clamp(v,0,100); applyShadowLook() end)

        local resetShadow=Instance.new("TextButton",shadowCard); resetShadow.Size=UDim2.fromOffset(96,24); resetShadow.Position=UDim2.new(1,-108,1,-28); resetShadow.BackgroundColor3=pcolor("soft",lightColor); resetShadow.BorderSizePixel=0; resetShadow.Text="reset"; resetShadow.TextColor3=textColor; resetShadow.Font=Enum.Font.GothamBold; resetShadow.TextSize=10; resetShadow.AutoButtonColor=false; corner(resetShadow,8); stroke(resetShadow,lineColor,.3,1); resetShadow:SetAttribute("KimqV26Role","lightBg")

        local function refreshShadowUI()
            shadowToggle.BackgroundColor3=shadowEnabled and pcolor("hot",hotColor) or pcolor("soft",lightColor)
            shadowToggle:SetAttribute("KimqV26Role",shadowEnabled and "hotBg" or "lightBg")
            shadowKnob.Position=shadowEnabled and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
            refreshDark(); refreshSoft()
        end
        local function setShadowEnabled(v) shadowEnabled=not not v; applyShadowLook(); refreshShadowUI() end
        local function setShadowDarkness(v) shadowDarkness=math.clamp(tonumber(v) or 65,0,150); applyShadowLook(); refreshShadowUI() end
        local function setShadowSoftness(v) shadowSoftness=math.clamp(tonumber(v) or 28,0,100); applyShadowLook(); refreshShadowUI() end

        shadowToggle.MouseButton1Click:Connect(function() setShadowEnabled(not shadowEnabled) end)
        resetShadow.MouseButton1Click:Connect(function() shadowEnabled=false; shadowDarkness=65; shadowSoftness=28; applyShadowLook(); refreshShadowUI() end)
        refreshShadowUI()

        _G.KimqEnvironmentController.SetShadows=setShadowEnabled
        _G.KimqEnvironmentController.GetShadows=function() return shadowEnabled end
        _G.KimqEnvironmentController.SetShadowDarkness=setShadowDarkness
        _G.KimqEnvironmentController.GetShadowDarkness=function() return shadowDarkness end
        _G.KimqEnvironmentController.SetShadowSoftness=setShadowSoftness
        _G.KimqEnvironmentController.GetShadowSoftness=function() return shadowSoftness end
        if type(_G.KimqRegisterConfigControl)=="function" then
            _G.KimqRegisterConfigControl("Corner / Contact Shadows","toggle",function() return shadowEnabled end,function(v) setShadowEnabled(v) end)
            _G.KimqRegisterConfigControl("Corner Darkness","slider",function() return shadowDarkness end,function(v) setShadowDarkness(v) end)
            _G.KimqRegisterConfigControl("Shadow Edge Softness","slider",function() return shadowSoftness end,function(v) setShadowSoftness(v) end)
        end
    end

    end)

    if not envBuildOk then
        warn("[Kimqetras HC v2.63] Environment page fallback: "..tostring(envBuildErr))

        -- If a seasonal/environment-specific part fails in a particular game,
        -- keep the core Day / Night controls available instead of aborting the
        -- entire Weapon Skins builder.
        for _,ch in ipairs(envPage:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                pcall(function() ch:Destroy() end)
            end
        end

        local fallbackTitle=card(envPage,70)
        txt(fallbackTitle,"♥  environment",UDim2.new(1,-24,0,26),UDim2.fromOffset(12,8),Enum.Font.GothamBold,20,hotColor)
        local fbSub=txt(fallbackTitle,"Day / night controls are available. Seasonal effects were skipped for compatibility.",UDim2.new(1,-24,0,28),UDim2.fromOffset(12,35),Enum.Font.Gotham,11,subColor)
        fbSub.TextWrapped=true

        local fallbackMode="Game Default"
        local fallbackDay=Lighting.ClockTime
        if fallbackDay < 6 or fallbackDay >= 18 then fallbackDay=12 end
        local fallbackLocked=false
        local fallbackNightLights=false
        local rememberedLights=setmetatable({}, {__mode="k"})

        local function lightLooksGameplay(light)
            local n=tostring(light.Name or ""):lower()
            if n:find("bullet",1,true) or n:find("tracer",1,true) or n:find("muzzle",1,true)
                or n:find("ray",1,true) or n:find("projectile",1,true) then
                return true
            end
            local p=light.Parent
            if p then
                local pn=tostring(p.Name or ""):lower()
                if pn:find("bullet",1,true) or pn:find("tracer",1,true) or pn:find("muzzle",1,true)
                    or pn:find("ray",1,true) or pn:find("projectile",1,true) then
                    return true
                end
            end
            return false
        end

        local function restoreRememberedLights()
            for light,enabled in pairs(rememberedLights) do
                if light and light.Parent then pcall(function() light.Enabled=enabled end) end
            end
            table.clear(rememberedLights)
        end

        local function applyFallbackLights()
            if not fallbackNightLights or fallbackMode~="Night" then
                restoreRememberedLights()
                return
            end
            for _,rootObj in ipairs({workspace,Lighting}) do
                for _,d in ipairs(rootObj:GetDescendants()) do
                    if d:IsA("Light") and not lightLooksGameplay(d) then
                        if rememberedLights[d]==nil then rememberedLights[d]=d.Enabled end
                        pcall(function() d.Enabled=true end)
                    end
                end
            end
        end

        local function setFallbackMode(mode)
            mode=tostring(mode or "Game Default")
            if mode~="Game Default" and mode~="Day" and mode~="Night" then mode="Game Default" end
            fallbackMode=mode
            fallbackLocked=mode~="Game Default"
            if mode=="Day" then Lighting.ClockTime=fallbackDay end
            if mode=="Night" then Lighting.ClockTime=0 end
            if mode=="Game Default" then restoreRememberedLights() end
            applyFallbackLights()
        end

        local fallbackConn=RunService.RenderStepped:Connect(function()
            if fallbackLocked then
                local wanted=(fallbackMode=="Night") and 0 or fallbackDay
                if math.abs(Lighting.ClockTime-wanted)>.01 then
                    Lighting.ClockTime=wanted
                end
            end
        end)

        local modeCard=card(envPage,112)
        txt(modeCard,"Time of Day",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor)

        local modeButtons={}
        local modes={"Game Default","Day","Night"}
        for i,name in ipairs(modes) do
            local b=Instance.new("TextButton",modeCard)
            b.Size=UDim2.new(1/3,-10,0,34)
            b.Position=UDim2.new((i-1)/3,6+(i-1)*2,0,39)
            b.BackgroundColor3=(name=="Game Default") and hotColor or lightColor
            b.BorderSizePixel=0
            b.Text=name
            b.TextColor3=(name=="Game Default") and Color3.new(1,1,1) or textColor
            b.Font=Enum.Font.GothamBold
            b.TextSize=11
            corner(b,9)
            stroke(b,lineColor,.3,1)
            modeButtons[name]=b
            b.MouseButton1Click:Connect(function()
                setFallbackMode(name)
                for _,modeName in ipairs(modes) do
                    local mb=modeButtons[modeName]
                    local on=modeName==fallbackMode
                    mb.BackgroundColor3=on and hotColor or lightColor
                    mb.TextColor3=on and Color3.new(1,1,1) or textColor
                end
            end)
        end

        local lightButton=Instance.new("TextButton",modeCard)
        lightButton.Size=UDim2.new(1,-24,0,28)
        lightButton.Position=UDim2.fromOffset(12,79)
        lightButton.BackgroundColor3=lightColor
        lightButton.BorderSizePixel=0
        lightButton.Text="Night Lights: OFF"
        lightButton.TextColor3=textColor
        lightButton.Font=Enum.Font.GothamBold
        lightButton.TextSize=11
        corner(lightButton,9)
        stroke(lightButton,lineColor,.3,1)
        lightButton.MouseButton1Click:Connect(function()
            fallbackNightLights=not fallbackNightLights
            lightButton.Text="Night Lights: "..(fallbackNightLights and "ON" or "OFF")
            applyFallbackLights()
        end)

        _G.KimqEnvironmentController={
            Apply=function() end,
            Restore=function()
                fallbackLocked=false
                fallbackMode="Game Default"
                restoreRememberedLights()
            end,
            GetPreset=function() return "Normal" end,
            SetTimeMode=setFallbackMode,
            GetTimeMode=function() return fallbackMode end,
            SetNightLights=function(v)
                fallbackNightLights=not not v
                lightButton.Text="Night Lights: "..(fallbackNightLights and "ON" or "OFF")
                applyFallbackLights()
            end,
            GetNightLights=function() return fallbackNightLights end,
        }

        if type(_G.KimqRegisterConfigControl)=="function" then
            _G.KimqRegisterConfigControl("Time of Day","dropdown",
                function() return fallbackMode end,
                function(v) setFallbackMode(tostring(v or "Game Default")) end)
            _G.KimqRegisterConfigControl("Night Lights","toggle",
                function() return fallbackNightLights end,
                function(v)
                    fallbackNightLights=not not v
                    lightButton.Text="Night Lights: "..(fallbackNightLights and "ON" or "OFF")
                    applyFallbackLights()
                end)
        end
    end

    setProgress("finding all of the weapon skins...", .95)

    -- Weapon skins --------------------------------------------------------
    local wi=card(skinsPage,76)
    local wiTitle=txt(wi,"♥  weapon skins",UDim2.new(1,-24,0,28),UDim2.fromOffset(12,9),Enum.Font.GothamBold,21,hotColor)
    local wiSub=txt(wi,"Customize the look of your weapons and items.",UDim2.new(1,-24,0,28),UDim2.fromOffset(12,40),Enum.Font.Gotham,12,subColor)

    local weaponCard=card(skinsPage,154)
    txt(weaponCard,"Weapon",UDim2.new(0,150,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor)
    local refresh=Instance.new("TextButton",weaponCard); refresh.Size=UDim2.fromOffset(90,28); refresh.Position=UDim2.new(1,-102,0,6); refresh.BackgroundColor3=lightColor; refresh.BorderSizePixel=0; refresh.Text="refresh"; refresh.TextColor3=textColor; refresh.Font=Enum.Font.GothamBold; refresh.TextSize=11; corner(refresh,9); stroke(refresh,lineColor,.32,1)
    local weaponList=Instance.new("ScrollingFrame",weaponCard); weaponList.Size=UDim2.new(1,-20,0,103); weaponList.Position=UDim2.fromOffset(10,42); weaponList.BackgroundTransparency=1; weaponList.BorderSizePixel=0; weaponList.ScrollBarThickness=3; weaponList.ScrollBarImageColor3=hotColor
    local wgrid=Instance.new("UIGridLayout",weaponList); wgrid.CellPadding=UDim2.fromOffset(7,7); wgrid.CellSize=UDim2.new(.32,-5,0,38); wgrid.SortOrder=Enum.SortOrder.LayoutOrder
    wgrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() weaponList.CanvasSize=UDim2.new(0,0,0,wgrid.AbsoluteContentSize.Y+8) end)

    local skinCard=card(skinsPage,292)
    local skinsHeader=txt(skinCard,"Skins",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,textColor)
    local skinList=Instance.new("ScrollingFrame",skinCard); skinList.Size=UDim2.new(1,-20,1,-46); skinList.Position=UDim2.fromOffset(10,38); skinList.BackgroundTransparency=1; skinList.BorderSizePixel=0; skinList.ScrollBarThickness=3; skinList.ScrollBarImageColor3=hotColor
    local sgrid=Instance.new("UIGridLayout",skinList); sgrid.CellPadding=UDim2.fromOffset(7,7); sgrid.CellSize=UDim2.new(.32,-5,0,38); sgrid.SortOrder=Enum.SortOrder.LayoutOrder
    sgrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() skinList.CanvasSize=UDim2.new(0,0,0,sgrid.AbsoluteContentSize.Y+8) end)

    -- Static hover preview for the selected weapon's skins.
    -- No platform, no animation, no scripts: just the authored visual.
    local skinPreviewCard=card(skinsPage,230)
    skinPreviewCard.Name="KimqWeaponSkinHoverPreviewCard"
    local skinPreviewTitle=txt(
        skinPreviewCard,
        "Hover a skin to preview it",
        UDim2.new(1,-24,0,24),
        UDim2.fromOffset(12,7),
        Enum.Font.GothamBold,12,textColor
    )

    local skinPreviewBackdrop=Instance.new("Frame")
    skinPreviewBackdrop.Name="KimqWeaponSkinPreviewBackdrop"
    skinPreviewBackdrop.Parent=skinPreviewCard
    skinPreviewBackdrop.Position=UDim2.fromOffset(10,38)
    skinPreviewBackdrop.Size=UDim2.new(1,-20,1,-48)
    skinPreviewBackdrop.BackgroundColor3=lightColor
    skinPreviewBackdrop.BorderSizePixel=0
    corner(skinPreviewBackdrop,11)
    stroke(skinPreviewBackdrop,lineColor,.35,1)

    local skinPreviewGradient=Instance.new("UIGradient")
    skinPreviewGradient.Name="KimqWeaponSkinPreviewGradient"
    skinPreviewGradient.Parent=skinPreviewBackdrop
    skinPreviewGradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,lightColor),
        ColorSequenceKeypoint.new(.55,lightColor),
        ColorSequenceKeypoint.new(1,hotColor),
    })
    skinPreviewGradient.Rotation=90

    local skinPreviewGlow=Instance.new("Frame")
    skinPreviewGlow.Name="Glow"
    skinPreviewGlow.Parent=skinPreviewBackdrop
    skinPreviewGlow.AnchorPoint=Vector2.new(.5,.5)
    skinPreviewGlow.Position=UDim2.fromScale(.5,.53)
    skinPreviewGlow.Size=UDim2.fromOffset(154,154)
    skinPreviewGlow.BackgroundColor3=Color3.new(1,1,1)
    skinPreviewGlow.BackgroundTransparency=.88
    skinPreviewGlow.BorderSizePixel=0
    corner(skinPreviewGlow,999)

    local skinPreview=Instance.new("ViewportFrame")
    skinPreview.Name="KimqWeaponSkinHoverPreview"
    skinPreview.Parent=skinPreviewBackdrop
    skinPreview.Position=UDim2.fromOffset(0,0)
    skinPreview.Size=UDim2.fromScale(1,1)
    skinPreview.BackgroundTransparency=1
    skinPreview.BorderSizePixel=0
    skinPreview.Ambient=Color3.new(1,1,1)
    skinPreview.LightColor=Color3.new(1,1,1)
    skinPreview.LightDirection=Vector3.new(-1,-1,-1)
    corner(skinPreview,11)

    -- Live theme sync, local to this preview only.
    local skinPreviewThemeClock=0
    local skinPreviewThemeConn
    skinPreviewThemeConn=RunService.Heartbeat:Connect(function(dt)
        if not skinPreviewCard.Parent then
            pcall(function() skinPreviewThemeConn:Disconnect() end)
            return
        end

        skinPreviewThemeClock+=dt
        if skinPreviewThemeClock<.18 then return end
        skinPreviewThemeClock=0

        local p=_G.KimqThemeLivePalette or {}
        local soft=p.soft or p.bg2 or lightColor
        local mid=p.bg2 or p.panel or lightColor
        local hot=p.hot or hotColor
        local line=p.stroke or p.line or lineColor

        skinPreviewBackdrop.BackgroundColor3=mid
        skinPreviewGradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,soft),
            ColorSequenceKeypoint.new(.55,mid),
            ColorSequenceKeypoint.new(1,hot),
        })

        local st=skinPreviewBackdrop:FindFirstChildOfClass("UIStroke")
        if st then st.Color=line end
        skinPreviewTitle.TextColor3=p.text or textColor
    end)

    local skinPreviewToken=0

    local function clearSkinPreview()
        skinPreviewToken+=1
        for _,ch in ipairs(skinPreview:GetChildren()) do
            if ch:IsA("WorldModel") or ch:IsA("Camera") then
                pcall(function() ch:Destroy() end)
            end
        end
        skinPreview.CurrentCamera=nil
    end

    local function showSkinPreview(source)
        clearSkinPreview()
        if not source then
            skinPreviewTitle.Text="Hover a skin to preview it"
            return
        end

        skinPreviewToken+=1
        local token=skinPreviewToken
        skinPreviewTitle.Text=source.Name

        task.spawn(function()
            local ok,visual=pcall(function() return source:Clone() end)
            if not ok or not visual or token~=skinPreviewToken then
                if visual then pcall(function() visual:Destroy() end) end
                return
            end

            -- Preview is intentionally static. Remove code/animation drivers and
            -- disable moving emitters so nothing can affect the actual game/tool.
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("LocalScript") or d:IsA("Script") or d:IsA("ModuleScript")
                    or d:IsA("Humanoid") or d:IsA("AnimationController")
                    or d:IsA("Animator") or d:IsA("Animation")
                    or d:IsA("BodyMover")
                then
                    pcall(function() d:Destroy() end)
                elseif d:IsA("BasePart") then
                    d.Anchored=true
                    d.CanCollide=false
                    d.CanTouch=false
                    d.CanQuery=false
                    d.CastShadow=false
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
                    or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles")
                then
                    pcall(function() d.Enabled=false end)
                end
            end
            if visual:IsA("BasePart") then
                visual.Anchored=true
                visual.CanCollide=false
                visual.CanTouch=false
                visual.CanQuery=false
                visual.CastShadow=false
            end

            if token~=skinPreviewToken or not skinPreview.Parent then
                visual:Destroy()
                return
            end

            local world=Instance.new("WorldModel")
            world.Name="KimqWeaponSkinPreviewWorld"
            world.Parent=skinPreview
            visual.Parent=world

            local okBox,cf,size=pcall(function()
                if visual:IsA("Model") then
                    return visual:GetBoundingBox()
                end

                local parts={}
                if visual:IsA("BasePart") then table.insert(parts,visual) end
                for _,d in ipairs(visual:GetDescendants()) do
                    if d:IsA("BasePart") then table.insert(parts,d) end
                end
                if #parts==0 then error("no preview parts") end

                local minV=Vector3.new(math.huge,math.huge,math.huge)
                local maxV=Vector3.new(-math.huge,-math.huge,-math.huge)
                for _,p in ipairs(parts) do
                    local half=p.Size*.5
                    minV=Vector3.new(
                        math.min(minV.X,p.Position.X-half.X),
                        math.min(minV.Y,p.Position.Y-half.Y),
                        math.min(minV.Z,p.Position.Z-half.Z)
                    )
                    maxV=Vector3.new(
                        math.max(maxV.X,p.Position.X+half.X),
                        math.max(maxV.Y,p.Position.Y+half.Y),
                        math.max(maxV.Z,p.Position.Z+half.Z)
                    )
                end
                local center=(minV+maxV)*.5
                return CFrame.new(center),maxV-minV
            end)

            if not okBox then
                world:Destroy()
                return
            end

            -- Center the skin only. Do not animate or add a display stand.
            local pivot=nil
            pcall(function() pivot=visual:GetPivot() end)
            if pivot then
                pcall(function()
                    visual:PivotTo(CFrame.new(-cf.Position)*pivot*CFrame.Angles(0,math.rad(28),0))
                end)
            else
                for _,d in ipairs(visual:GetDescendants()) do
                    if d:IsA("BasePart") then
                        d.CFrame=CFrame.new(-cf.Position)*d.CFrame*CFrame.Angles(0,math.rad(28),0)
                    end
                end
            end

            local cam=Instance.new("Camera")
            cam.Name="KimqWeaponSkinPreviewCamera"
            cam.FieldOfView=28
            cam.Parent=skinPreview
            skinPreview.CurrentCamera=cam

            local abs=skinPreview.AbsoluteSize
            local aspect=math.max(abs.X/math.max(abs.Y,1),.55)
            local vfov=math.rad(cam.FieldOfView)
            local fitH=size.Y/(2*math.tan(vfov*.5))
            local fitW=size.X/(2*math.tan(vfov*.5)*aspect)
            local dist=math.clamp(math.max(fitH,fitW,size.Z*1.6)*1.35,2.5,40)

            cam.CFrame=CFrame.lookAt(
                Vector3.new(0,0,-dist),
                Vector3.zero,
                Vector3.new(0,1,0)
            )
        end)
    end

    local actions=card(skinsPage,54)
    local apply=Instance.new("TextButton",actions); apply.Size=UDim2.new(.68,-14,0,34); apply.Position=UDim2.new(0,10,.5,-17); apply.BackgroundColor3=hotColor; apply.BorderSizePixel=0; apply.Text="♥  Apply Skin"; apply.TextColor3=Color3.fromRGB(250,252,255); apply.Font=Enum.Font.GothamBold; apply.TextSize=13; corner(apply,10)
    local reset=Instance.new("TextButton",actions); reset.Size=UDim2.new(.32,-14,0,34); reset.Position=UDim2.new(.68,4,.5,-17); reset.BackgroundColor3=lightColor; reset.BorderSizePixel=0; reset.Text="Reset"; reset.TextColor3=textColor; reset.Font=Enum.Font.GothamBold; reset.TextSize=12; corner(reset,10); stroke(reset,lineColor,.3,1)
    local statusCard=card(skinsPage,48)
    local skinStatus=txt(statusCard,"Open this page or press Refresh to scan for weapons.",UDim2.new(1,-24,1,0),UDim2.fromOffset(12,0),Enum.Font.Gotham,12,subColor)

    _G.KimqV26WeaponSkins=_G.KimqV26WeaponSkins or {Selected={}}
    _G.KimqV26WeaponSkins.Selected=_G.KimqV26WeaponSkins.Selected or {}
    _G.KimqV26WeaponSkins.Mirrors=_G.KimqV26WeaponSkins.Mirrors or setmetatable({}, {__mode="k"})
    local selectedByWeapon=_G.KimqV26WeaponSkins.Selected
    local skinMirrors=_G.KimqV26WeaponSkins.Mirrors
    local wrapRoot=nil; local currentWeapon=nil; local selectedSkin=nil; local weaponFolders={}; local folderByName={}; local weaponButtons={}; local skinButtons={}

    local function setStatus(s,good) skinStatus.Text=s; skinStatus.TextColor3=good and hotColor or subColor end
    local function displayWeapon(n) return tostring(n or ""):gsub("%[",""):gsub("%]","") end
    local function locateWraps()
        local direct=workspace:FindFirstChild("Wraps")
        if direct then return direct end
        local recursive=workspace:FindFirstChild("Wraps",true)
        if recursive then return recursive end
        return ReplicatedStorage:FindFirstChild("Wraps",true)
    end
    local function findHandle(obj)
        if not obj then return nil end
        local h=obj:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then return h end
        for _,d in ipairs(obj:GetDescendants()) do if d.Name=="Handle" and d:IsA("BasePart") then return d end end
        return nil
    end
    local function findTool(name)
        local char=lp.Character; local bp=lp:FindFirstChildOfClass("Backpack")
        return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
    end
    local function clearVisual(tool)
        if not tool then return end
        local conn=skinMirrors[tool]
        if conn then pcall(function() conn:Disconnect() end); skinMirrors[tool]=nil end
        local h=tool:FindFirstChild("Handle"); if h and h:IsA("BasePart") then pcall(function() h.LocalTransparencyModifier=0 end) end
        for _,d in ipairs(tool:GetDescendants()) do
            if d.Name=="KimqV26SkinVisual" or d.Name=="KimqV21AnimatedSkinVisual" then pcall(function() d:Destroy() end) end
        end
    end
    local function sourceSkin(w,s)
        local wf=folderByName[w]
        local sf=wf and wf:FindFirstChild(s)
        return sf,findHandle(sf)
    end
    local function hasAnimatedVisuals(obj)
        if not obj then return false end
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Humanoid") or d:IsA("AnimationController") or d:IsA("Animator") or d:IsA("Animation") or d:IsA("Constraint") or d:IsA("BodyMover") or d:IsA("Motor6D") or d:IsA("Bone") or d:IsA("LocalScript") or d:IsA("Script") then return true end
        end
        return false
    end

    -- Pair a source skin with its clone without changing the game model.  We use
    -- name/class occurrence matching so animated source parts, bones and attachments
    -- can be mirrored into the equipped cosmetic when the game's own animation is
    -- happening on the source model.
    local function pairTrees(src,dst,out)
        out=out or {}
        if not src or not dst then return out end
        out[src]=dst
        local dchildren=dst:GetChildren()
        local used={}
        for _,sc in ipairs(src:GetChildren()) do
            local match=nil
            for _,dc in ipairs(dchildren) do
                if not used[dc] and dc.Name==sc.Name and dc.ClassName==sc.ClassName then match=dc; break end
            end
            if match then used[match]=true; pairTrees(sc,match,out) end
        end
        return out
    end

    local function startSourceMirror(tool,sourceContainer,sourceRoot,visual,cloneRoot,pairMap,mirrorParts)
        local old=skinMirrors[tool]
        if old then pcall(function() old:Disconnect() end) end
        local conn
        local mirrorAccumulator=0
        conn=RunService.Heartbeat:Connect(function(dt)
            mirrorAccumulator += dt
            if mirrorAccumulator < (1/30) then return end
            mirrorAccumulator = 0
            if not tool.Parent or not visual.Parent or not sourceContainer.Parent or not sourceRoot.Parent then
                pcall(function() conn:Disconnect() end); skinMirrors[tool]=nil; return
            end
            -- Backpack skins are not visible, so pause the expensive pose copy
            -- until that tool is actually equipped.
            if tool.Parent~=lp.Character then return end
            local target=tool:FindFirstChild("Handle")
            if not target or not target:IsA("BasePart") then return end
            local delta=target.CFrame*sourceRoot.CFrame:Inverse()
            for s,c in pairs(pairMap) do
                if s and c and s.Parent and c.Parent then
                    if mirrorParts and s:IsA("BasePart") and c:IsA("BasePart") then
                        pcall(function() c.CFrame=delta*s.CFrame end)
                    elseif s:IsA("Bone") and c:IsA("Bone") then
                        pcall(function() c.Transform=s.Transform end)
                    elseif s:IsA("Attachment") and c:IsA("Attachment") then
                        pcall(function() c.CFrame=s.CFrame end)
                    elseif s:IsA("SpecialMesh") and c:IsA("SpecialMesh") then
                        pcall(function() c.Scale=s.Scale; c.Offset=s.Offset end)
                    elseif (s:IsA("ParticleEmitter") and c:IsA("ParticleEmitter")) or (s:IsA("Trail") and c:IsA("Trail")) or (s:IsA("Beam") and c:IsA("Beam")) then
                        pcall(function() c.Enabled=s.Enabled end)
                    end
                end
            end
        end)
        skinMirrors[tool]=conn
        return conn
    end

    -- Animation support for Wraps. Most wrap folders are storage models, so their
    -- Animator has NO playing tracks to mirror. We therefore also load embedded
    -- loop/idle/effect Animation objects directly on the cloned visual.
    -- Animated wraps often ship a dedicated Humanoid (for example,
    -- "ANIMATE_HUMANOID") and their Animation is authored against that rig.
    -- Loading those tracks into a brand-new AnimationController changes the
    -- animation root and leaves the skin frozen. Prefer the skin's own Humanoid.
    local function ensureDriverAnimator(driver)
        if not driver then return nil,nil,"none" end
        if driver:IsA("Animator") then
            local host=driver.Parent
            if host and host:IsA("Humanoid") then return driver,host,"humanoid" end
            if host and host:IsA("AnimationController") then return driver,nil,"animation controller" end
            return driver,nil,"animator"
        end
        if driver:IsA("Humanoid") then
            pcall(function() driver.RequiresNeck=false end)
            pcall(function() driver.BreakJointsOnDeath=false end)
            pcall(function()
                if driver.MaxHealth<=0 then driver.MaxHealth=100 end
                driver.Health=driver.MaxHealth
            end)
            local animator=driver:FindFirstChildWhichIsA("Animator")
            if not animator then
                animator=Instance.new("Animator")
                animator.Name="KimqSkinAnimator"
                animator.Parent=driver
            end
            return animator,driver,"humanoid"
        end
        if driver:IsA("AnimationController") then
            local animator=driver:FindFirstChildWhichIsA("Animator")
            if not animator then
                animator=Instance.new("Animator")
                animator.Name="KimqSkinAnimator"
                animator.Parent=driver
            end
            return animator,nil,"animation controller"
        end
        return nil,nil,"none"
    end

    local function collectRigDrivers(root,createFallback)
        local out,seen={},{}
        if not root then return out end

        local function add(host)
            if not host or seen[host] then return end
            local animator,humanoid,mode=ensureDriverAnimator(host)
            if animator then
                seen[host]=true
                table.insert(out,{host=host,animator=animator,humanoid=humanoid,mode=mode})
            end
        end

        -- Humanoids first because many Wraps (including Ascension) are tiny authored
        -- humanoid rigs. Then AnimationControllers. Bare Animators are only added if
        -- they are not already owned by one of those drivers.
        for _,d in ipairs(root:GetDescendants()) do if d:IsA("Humanoid") then add(d) end end
        for _,d in ipairs(root:GetDescendants()) do if d:IsA("AnimationController") then add(d) end end
        for _,d in ipairs(root:GetDescendants()) do
            if d:IsA("Animator") then
                local par=d.Parent
                if not (par and (par:IsA("Humanoid") or par:IsA("AnimationController"))) then add(d) end
            end
        end

        if #out==0 and createFallback then
            local controller=Instance.new("AnimationController")
            controller.Name="KimqSkinAnimationController"
            controller.Parent=root
            add(controller)
        end
        return out
    end

    local function getOrCreateAnimator(root)
        local drivers=collectRigDrivers(root,true)
        local first=drivers[1]
        if not first then return nil,nil,"none" end
        return first.animator,first.humanoid,first.mode
    end

    local function collectSkinAnimations(obj)
        local found={}
        if not obj then return found end
        if obj:IsA("Animation") then table.insert(found,obj) end
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("Animation") and tostring(d.AnimationId or "")~="" and tostring(d.AnimationId or "")~="rbxassetid://0" then
                table.insert(found,d)
            end
        end
        return found
    end

    local function isActionAnimationName(name)
        name=tostring(name or ""):lower()
        return name:find("reload",1,true) or name:find("shoot",1,true) or name:find("fire",1,true)
            or name:find("equip",1,true) or name:find("unequip",1,true) or name:find("inspect",1,true)
            or name:find("attack",1,true) or name:find("melee",1,true)
    end

    local function nearestDriversForAnimation(anim,root,drivers)
        if #drivers<=1 then return drivers end
        local ranked={}
        for index,info in ipairs(drivers) do
            local score=9999
            local ancestor=anim.Parent
            local depth=0
            while ancestor and depth<64 do
                if info.host==ancestor or info.host:IsDescendantOf(ancestor) then
                    score=depth
                    break
                end
                if ancestor==root then break end
                ancestor=ancestor.Parent
                depth+=1
            end
            table.insert(ranked,{info=info,score=score,index=index})
        end
        table.sort(ranked,function(a,b)
            if a.score==b.score then
                -- Prefer Humanoid-authored rigs when equally close.
                if a.info.mode~=b.info.mode then return a.info.mode=="humanoid" end
                return a.index<b.index
            end
            return a.score<b.score
        end)
        local out={}
        for _,r in ipairs(ranked) do table.insert(out,r.info) end
        return out
    end

    local function playSkinAnimationsFromIds(sourceObj,cloneObj)
        if not cloneObj then return 0,"none",0 end

        -- Use the cloned Animation objects themselves. This keeps any attributes the
        -- skin author attached to the Animation while still letting us read its ID.
        local animations=collectSkinAnimations(cloneObj)
        if #animations==0 and sourceObj then
            -- Extremely defensive fallback in case an Animation was not Archivable.
            for _,src in ipairs(collectSkinAnimations(sourceObj)) do
                local copy=Instance.new("Animation")
                copy.Name=src.Name
                copy.AnimationId=src.AnimationId
                copy.Parent=cloneObj
                table.insert(animations,copy)
            end
        end
        if #animations==0 then return 0,"none",0 end

        local drivers=collectRigDrivers(cloneObj,true)
        if #drivers==0 then return 0,"none",#animations end

        local started=0
        local modes={}
        local playedIds={}
        for _,anim in ipairs(animations) do
            local id=tostring(anim.AnimationId or "")
            if id~="" and id~="rbxassetid://0" and not playedIds[id] and not isActionAnimationName(anim.Name) then
                local candidates=nearestDriversForAnimation(anim,cloneObj,drivers)
                local track=nil
                local used=nil
                for _,info in ipairs(candidates) do
                    -- Some authored mini-rigs only behave correctly through Humanoid:LoadAnimation;
                    -- others use AnimationController/Animator. Try the intended driver first,
                    -- then fall through to the other drivers in this skin.
                    if info.humanoid then
                        local ok,result=pcall(function() return info.humanoid:LoadAnimation(anim) end)
                        if ok and result then track=result end
                    end
                    if not track then
                        local ok,result=pcall(function() return info.animator:LoadAnimation(anim) end)
                        if ok and result then track=result end
                    end
                    if track then used=info break end
                end

                if track then
                    playedIds[id]=true
                    pcall(function() track.Priority=Enum.AnimationPriority.Action end)
                    pcall(function() track.Looped=true end)
                    pcall(function() track:Play(0.08,1,1) end)
                    pcall(function() track:AdjustSpeed(1) end)
                    started+=1
                    modes[used and used.mode or "animator"]=true
                end
            end
        end

        local modeList={}
        for mode in pairs(modes) do table.insert(modeList,mode) end
        table.sort(modeList)
        return started,(#modeList>0 and table.concat(modeList," + ") or "none"),#animations
    end

    local function mirrorPlayingAnimations(sourceObj,cloneObj)
        local cloneAnimator=cloneObj and getOrCreateAnimator(cloneObj)
        if not cloneAnimator then return 0 end
        local count=0
        for _,srcAnimator in ipairs(sourceObj:GetDescendants()) do
            if srcAnimator:IsA("Animator") then
                local ok,tracks=pcall(function() return srcAnimator:GetPlayingAnimationTracks() end)
                if ok and tracks then
                    for _,track in ipairs(tracks) do
                        local anim=nil
                        pcall(function() anim=track.Animation end)
                        if anim and anim:IsA("Animation") and anim.AnimationId~="" then
                            local copied=Instance.new("Animation")
                            copied.AnimationId=anim.AnimationId
                            copied.Name=anim.Name
                            local okLoad,newTrack=pcall(function() return cloneAnimator:LoadAnimation(copied) end)
                            if okLoad and newTrack then
                                pcall(function() newTrack.Priority=track.Priority end)
                                pcall(function() newTrack.Looped=track.Looped end)
                                pcall(function() newTrack:Play(.05,1,1) end)
                                pcall(function() newTrack.TimePosition=track.TimePosition end)
                                pcall(function() newTrack:AdjustSpeed(track.Speed) end)
                                count+=1
                            end
                            copied:Destroy()
                        end
                    end
                end
            end
        end
        return count
    end
    local function applySkin(w,s,tool,quiet)
        local gun=tool or findTool(w)
        if not gun then if not quiet then setStatus(displayWeapon(w).." is not in your Backpack / Character",false) end return false end
        local target=gun:FindFirstChild("Handle")
        local sourceContainer,sourceRoot=sourceSkin(w,s)
        if not target or not target:IsA("BasePart") or not sourceContainer or not sourceRoot then if not quiet then setStatus("That skin does not have a usable Handle",false) end return false end
        clearVisual(gun)

        -- Clone the WHOLE skin, not only its Handle. This keeps particles, beams,
        -- trails, attachments, extra meshes, bones/Motor6Ds and AnimationControllers.
        local visual=sourceContainer:Clone()
        visual.Name="KimqV21AnimatedSkinVisual"
        local cloneRoot=findHandle(visual)
        if not cloneRoot then visual:Destroy(); if not quiet then setStatus("That skin clone lost its Handle",false) end return false end
        local sourcePairs=pairTrees(sourceContainer,visual,{})

        -- Keep client-side animation code instead of deleting it.  Many wraps use a
        -- LocalScript + ModuleScript rather than an Animation object, and deleting
        -- those was why those skins could never animate. Server-only scripts are
        -- still removed because they cannot run in a local cosmetic clone.
        local clientScripts=0
        for _,d in ipairs(visual:GetDescendants()) do
            if d:IsA("LocalScript") then
                clientScripts+=1
                pcall(function() d.Disabled=false end)
                pcall(function() d.Enabled=true end)
            elseif d:IsA("ModuleScript") then
                -- Keep modules: cloned LocalScripts may require them.
            elseif d:IsA("Script") then
                local isClient=false
                pcall(function() isClient=(d.RunContext==Enum.RunContext.Client) end)
                if isClient then
                    clientScripts+=1
                    pcall(function() d.Disabled=false end)
                    pcall(function() d.Enabled=true end)
                else
                    d:Destroy()
                end
            elseif d:IsA("BasePart") then
                d.Anchored=false; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false; d.Massless=true
                pcall(function() d.AssemblyLinearVelocity=Vector3.zero; d.AssemblyAngularVelocity=Vector3.zero end)
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
                pcall(function() d.Enabled=true end)
            elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                pcall(function() d.Enabled=true end)
            elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
                pcall(function() d.Enabled=true end)
            end
        end
        if visual:IsA("BasePart") then
            visual.Anchored=false; visual.CanCollide=false; visual.CanTouch=false; visual.CanQuery=false; visual.Massless=true
        end

        -- Move every skin part by the same Handle->gun transform so multi-part skins
        -- keep their authored offsets instead of bunching up at the gun Handle.
        local delta=target.CFrame*sourceRoot.CFrame:Inverse()
        if visual:IsA("BasePart") then visual.CFrame=delta*visual.CFrame end
        for _,d in ipairs(visual:GetDescendants()) do if d:IsA("BasePart") then d.CFrame=delta*d.CFrame end end
        visual.Parent=gun

        -- Preserve authored animation rigs. Do NOT safety-weld parts that are already
        -- controlled by Motor6Ds, welds, hinges, springs, Align constraints,
        -- AngularVelocity/LinearVelocity, or legacy BodyMovers. Welding those parts
        -- rigidly was the reason animated wraps looked frozen.
        local jointed={}
        for _,j in ipairs(visual:GetDescendants()) do
            if j:IsA("JointInstance") then
                if j.Part0 then jointed[j.Part0]=true end; if j.Part1 then jointed[j.Part1]=true end
            elseif j:IsA("WeldConstraint") then
                if j.Part0 then jointed[j.Part0]=true end; if j.Part1 then jointed[j.Part1]=true end
            elseif j:IsA("Constraint") then
                local a0,a1=nil,nil
                pcall(function() a0=j.Attachment0 end)
                pcall(function() a1=j.Attachment1 end)
                if a0 and a0.Parent and a0.Parent:IsA("BasePart") then jointed[a0.Parent]=true end
                if a1 and a1.Parent and a1.Parent:IsA("BasePart") then jointed[a1.Parent]=true end
            elseif j:IsA("BodyMover") and j.Parent and j.Parent:IsA("BasePart") then
                jointed[j.Parent]=true
            end
        end
        local rootWeld=Instance.new("WeldConstraint",cloneRoot); rootWeld.Name="KimqV21SkinRootWeld"; rootWeld.Part0=cloneRoot; rootWeld.Part1=target
        for _,d in ipairs(visual:GetDescendants()) do
            if d:IsA("BasePart") and d~=cloneRoot and not jointed[d] then
                local wld=Instance.new("WeldConstraint",d); wld.Name="KimqV21LooseVisualWeld"; wld.Part0=d; wld.Part1=cloneRoot
            end
        end

        -- Storage models in Workspace.Wraps are usually idle, so there may be no
        -- currently-playing track to mirror. Start embedded cosmetic Animation
        -- objects first, then also mirror any preview track that actually is running.
        local embedded,embeddedDriver,animationIdsFound=playSkinAnimationsFromIds(sourceContainer,visual)
        local mirrored=mirrorPlayingAnimations(sourceContainer,visual)

        -- If the wrap is animated by the game's source model rather than an embedded
        -- Animation/LocalScript, mirror that live pose too.  Base-part CFrames are
        -- only mirrored when there is no cloned client script or animation track, so
        -- we do not fight the clone's own animation. Bones/attachments/VFX can still
        -- mirror safely and cover skinned meshes, beams and trails.
        local needsFallbackMirror=(clientScripts==0 and embedded==0 and mirrored==0)

        -- v2.62 stability rule:
        -- Never copy cosmetic BasePart CFrames from the storage model every frame.
        -- That world-space 30fps mirror visibly lagged/wobbled behind the player's
        -- moving gun. The clone now stays physically attached to the real Handle.
        --
        -- As a fallback we can still mirror Bones, Attachments, mesh offsets and VFX
        -- state; those do not fight the Handle weld.
        local mirrorParts=false
        if needsFallbackMirror then
            startSourceMirror(
                gun,
                sourceContainer,
                sourceRoot,
                visual,
                cloneRoot,
                sourcePairs,
                false
            )
        end

        pcall(function() target.LocalTransparencyModifier=1 end)
        selectedByWeapon[w]=s
        if not quiet then
            local animated=hasAnimatedVisuals(sourceContainer)
            local animCount=embedded+mirrored
            local detail=" • applied locally"
            if animCount>0 then detail=" • "..animCount.." animation"..(animCount==1 and "" or "s").." running from ID via "..tostring(embeddedDriver)
            elseif clientScripts>0 then detail=" • client animation script"..(clientScripts==1 and "" or "s").." kept"
            elseif animationIdsFound and animationIdsFound>0 then detail=" • animation ID found, but this rig could not play it"
            elseif animated then detail=needsFallbackMirror and " • stable attached fallback + effects preserved" or " • animated effects preserved" end
            setStatus(displayWeapon(w).." • "..s..detail,true)
        end
        return true
    end
    local function refreshWeaponStyle()
        for name,b in pairs(weaponButtons) do local on=name==currentWeapon; b.BackgroundColor3=on and hotColor or lightColor; b.TextColor3=on and Color3.fromRGB(250,252,255) or textColor end
    end
    local function refreshSkinStyle()
        for name,b in pairs(skinButtons) do local on=name==selectedSkin; b.BackgroundColor3=on and hotColor or lightColor; b.TextColor3=on and Color3.fromRGB(250,252,255) or textColor end
    end
    local function buildSkins()
        for _,ch in ipairs(skinList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        table.clear(skinButtons)
        if not currentWeapon or not folderByName[currentWeapon] then
            skinsHeader.Text="Skins"
            clearSkinPreview()
            skinPreviewTitle.Text="Hover a skin to preview it"
            setStatus("Choose a weapon first",false)
            return
        end
        skinsHeader.Text="Skins • "..displayWeapon(currentWeapon)
        local skins={}
        for _,sf in ipairs(folderByName[currentWeapon]:GetChildren()) do if findHandle(sf) then table.insert(skins,sf) end end
        table.sort(skins,function(a,b) return a.Name:lower()<b.Name:lower() end)
        selectedSkin=selectedByWeapon[currentWeapon]
        for i,sf in ipairs(skins) do
            local b=Instance.new("TextButton",skinList); b.LayoutOrder=i; b.BackgroundColor3=lightColor; b.BorderSizePixel=0; b.Text=sf.Name; b.TextColor3=textColor; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.AutoButtonColor=false; corner(b,10); stroke(b,lineColor,.35,1)
            b.MouseButton1Click:Connect(function()
                selectedSkin=sf.Name
                refreshSkinStyle()
                setStatus("Selected "..sf.Name.." • press Apply Skin",true)
                showSkinPreview(sf)
            end)
            b.MouseEnter:Connect(function()
                showSkinPreview(sf)
            end)
            b.MouseLeave:Connect(function()
                local keep=selectedSkin and folderByName[currentWeapon] and folderByName[currentWeapon]:FindFirstChild(selectedSkin)
                showSkinPreview(keep)
            end)
            skinButtons[sf.Name]=b
        end
        refreshSkinStyle()
        local selectedSource=selectedSkin and folderByName[currentWeapon]:FindFirstChild(selectedSkin)
        if selectedSource then
            showSkinPreview(selectedSource)
        else
            clearSkinPreview()
            skinPreviewTitle.Text="Hover a skin to preview it"
        end
        if #skins==0 then setStatus("No matching skins were found inside "..currentWeapon,false) else setStatus("Found "..#skins.." skins • choose one",true) end
    end
    local function scanWeapons()
        for _,ch in ipairs(weaponList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        table.clear(weaponButtons); table.clear(weaponFolders); table.clear(folderByName)
        wrapRoot=locateWraps()
        if not wrapRoot then setStatus("Could not find a Wraps folder • press refresh",false); return end
        for _,wf in ipairs(wrapRoot:GetChildren()) do
            if wf:IsA("Folder") or wf:IsA("Model") then table.insert(weaponFolders,wf); folderByName[wf.Name]=wf end
        end
        table.sort(weaponFolders,function(a,b) return a.Name:lower()<b.Name:lower() end)
        for i,wf in ipairs(weaponFolders) do
            local b=Instance.new("TextButton",weaponList); b.LayoutOrder=i; b.BackgroundColor3=lightColor; b.BorderSizePixel=0; b.Text=displayWeapon(wf.Name); b.TextColor3=textColor; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.AutoButtonColor=false; corner(b,10); stroke(b,lineColor,.35,1)
            b.MouseButton1Click:Connect(function() currentWeapon=wf.Name; selectedSkin=selectedByWeapon[currentWeapon]; refreshWeaponStyle(); buildSkins() end)
            weaponButtons[wf.Name]=b
        end
        if #weaponFolders==0 then setStatus("Wraps was found, but it has no weapon folders",false); return end
        if not currentWeapon or not folderByName[currentWeapon] then currentWeapon=weaponFolders[1].Name end
        refreshWeaponStyle(); buildSkins()
    end
    refresh.MouseButton1Click:Connect(scanWeapons)
    apply.MouseButton1Click:Connect(function()
        if not currentWeapon then setStatus("Choose a weapon first",false) elseif not selectedSkin then setStatus("Choose a skin first",false) else applySkin(currentWeapon,selectedSkin,nil,false) end
    end)
    reset.MouseButton1Click:Connect(function()
        if currentWeapon then
            selectedByWeapon[currentWeapon]=nil
            clearVisual(findTool(currentWeapon))
            selectedSkin=nil
            refreshSkinStyle()
            clearSkinPreview()
            skinPreviewTitle.Text="Hover a skin to preview it"
            setStatus(displayWeapon(currentWeapon).." reset",true)
        end
    end)

    local function hookContainer(container)
        if not container or container:GetAttribute("KimqV26SkinHook") then return end
        container:SetAttribute("KimqV26SkinHook",true)
        container.ChildAdded:Connect(function(ch)
            local s=selectedByWeapon[ch.Name]
            if s then task.delay(.12,function() applySkin(ch.Name,s,ch,true) end) end
        end)
    end
    hookContainer(lp:FindFirstChildOfClass("Backpack")); if lp.Character then hookContainer(lp.Character) end
    lp.CharacterAdded:Connect(function(char)
        hookContainer(char)
        task.delay(1,function()
            hookContainer(lp:FindFirstChildOfClass("Backpack"))
            for w,s in pairs(selectedByWeapon) do local tool=findTool(w); if tool then applySkin(w,s,tool,true) end end
        end)
    end)

    local function getWeaponSkinConfigState()
        local selections={}
        for weaponName,skinName in pairs(selectedByWeapon) do
            if type(weaponName)=="string" and type(skinName)=="string" then selections[weaponName]=skinName end
        end
        return {selected=selections,currentWeapon=currentWeapon,selectedSkin=selectedSkin}
    end
    local function setWeaponSkinConfigState(state)
        if type(state) ~= "table" then return end
        -- Clear visuals from selections that are about to be replaced.
        for weaponName in pairs(selectedByWeapon) do
            local tool=findTool(weaponName)
            if tool then clearVisual(tool) end
        end
        table.clear(selectedByWeapon)
        if type(state.selected)=="table" then
            for weaponName,skinName in pairs(state.selected) do
                if type(weaponName)=="string" and type(skinName)=="string" then
                    selectedByWeapon[weaponName]=skinName
                end
            end
        end
        currentWeapon = type(state.currentWeapon)=="string" and state.currentWeapon or currentWeapon
        selectedSkin = currentWeapon and selectedByWeapon[currentWeapon] or (type(state.selectedSkin)=="string" and state.selectedSkin or nil)
        task.defer(function()
            -- Build the Wraps lookup even if the Weapon Skins page is closed;
            -- otherwise a config loaded from another page would know the names but
            -- have no source folder to clone from.
            scanWeapons()
            for weaponName,skinName in pairs(selectedByWeapon) do
                local tool=findTool(weaponName)
                if tool then applySkin(weaponName,skinName,tool,true) end
            end
            refreshWeaponStyle(); refreshSkinStyle()
            setStatus("Restored saved weapon skins", true)
        end)
    end
    _G.KimqWeaponSkinController={GetState=getWeaponSkinConfigState,SetState=setWeaponSkinConfigState,Apply=applySkin}
    if type(_G.KimqRegisterConfigControl) == "function" then
        _G.KimqRegisterConfigControl("Weapon Skin Selections", "state", getWeaponSkinConfigState, setWeaponSkinConfigState)
    end


    -- Weapon extras -------------------------------------------------------
    -- Local cosmetic support for ReplicatedStorage.BulletBeams, Knives, and
    -- EquipableItem.  Everything here stays client-side and lives on the same
    -- Weapon Skins page.
    local function setupWeaponExtras()
        if _G.KimqWeaponExtrasInstalled then return end
        _G.KimqWeaponExtrasInstalled=true

        _G.KimqWeaponExtrasState=_G.KimqWeaponExtrasState or {
            BulletBeam="None",
            BulletColorMode="Preset",
            BulletColorHex="#FF69B4",
            BulletLightBrightness=0.65,
            KnifeSkin="None",
            KnifeAccentMode="Off",
            EquipableItem="None",
            DeathBlood=false,
            DeathHearts=false,
            GunKillEffect="Hearts",
        }
        _G.KimqBulletLightBrightness=math.clamp(
            tonumber(_G.KimqWeaponExtrasState.BulletLightBrightness)
            or tonumber(_G.KimqBulletLightBrightness)
            or 0.65, 0, 2.5
        )
        local extraState=_G.KimqWeaponExtrasState
        extraState.BulletBeam=tostring(extraState.BulletBeam or "None")
        extraState.BulletColorMode=tostring(extraState.BulletColorMode or "Preset")
        if extraState.BulletColorMode~="Preset" and extraState.BulletColorMode~="Custom" and extraState.BulletColorMode~="Rainbow" then extraState.BulletColorMode="Preset" end
        extraState.BulletColorHex=tostring(extraState.BulletColorHex or "#FF69B4")
        extraState.KnifeAccentMode=tostring(extraState.KnifeAccentMode or "Off")
        if extraState.KnifeAccentMode~="Off" and extraState.KnifeAccentMode~="Theme" and extraState.KnifeAccentMode~="Bullet" then extraState.KnifeAccentMode="Off" end
        extraState.DeathBlood=(extraState.DeathBlood==true)
        extraState.DeathHearts=(extraState.DeathHearts==true)
        extraState.GunKillEffect=tostring(extraState.GunKillEffect or "Hearts")
        if extraState.GunKillEffect~="Normal" and extraState.GunKillEffect~="Hearts" then extraState.GunKillEffect="Hearts" end

        -- v2.68: local death-blood VFX.
        -- Reuses the game's BloodSpark / BloodBurst particle textures and motion
        -- values found in the saved place, but is emitted locally so it does not
        -- touch server combat or other players' actual characters.
        local deathBloodHooks=setmetatable({}, {__mode="k"})

        local function spawnDeathBloodAt(position)
            if extraState.DeathBlood==false or typeof(position)~="Vector3" then return false end

            local holder=Instance.new("Part")
            holder.Name="KimqDeathBlood"
            holder.Anchored=true
            holder.CanCollide=false
            holder.CanTouch=false
            holder.CanQuery=false
            holder.CastShadow=false
            holder.Transparency=1
            holder.Size=Vector3.new(.25,.25,.25)
            holder.CFrame=CFrame.new(position)
            holder.Parent=workspace

            local att=Instance.new("Attachment")
            att.Name="BloodBurst"
            att.Parent=holder

            -- BloodSpark from the saved game (texture 419625073).
            local spray=Instance.new("ParticleEmitter")
            spray.Name="Blood"
            spray.Enabled=false
            spray.Texture="rbxassetid://419625073"
            spray.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(239,17,17)),
                ColorSequenceKeypoint.new(.56,Color3.fromRGB(98,7,7)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(85,6,6)),
            })
            spray.Lifetime=NumberRange.new(.35,.8)
            spray.Speed=NumberRange.new(8,18)
            spray.Rotation=NumberRange.new(90,90)
            spray.RotSpeed=NumberRange.new(-5,5)
            spray.SpreadAngle=Vector2.new(360,360)
            spray.Acceleration=Vector3.new(0,-35,0)
            spray.VelocityInheritance=.15
            spray.ZOffset=.3
            spray.LightEmission=0
            spray.Size=NumberSequence.new({
                NumberSequenceKeypoint.new(0,0),
                NumberSequenceKeypoint.new(.08,.50),
                NumberSequenceKeypoint.new(.42,.17),
                NumberSequenceKeypoint.new(1,0),
            })
            spray.Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,0),
                NumberSequenceKeypoint.new(.18,.15),
                NumberSequenceKeypoint.new(.68,.35),
                NumberSequenceKeypoint.new(1,1),
            })
            spray.Parent=att

            -- BloodBurst from the saved game (texture 241576804).
            local burst=Instance.new("ParticleEmitter")
            burst.Name="BloodSmoke"
            burst.Enabled=false
            burst.Texture="rbxassetid://241576804"
            burst.Color=ColorSequence.new(Color3.fromRGB(84,0,1))
            burst.Lifetime=NumberRange.new(.75,1.5)
            burst.Speed=NumberRange.new(30,60)
            burst.Rotation=NumberRange.new(-360,360)
            burst.RotSpeed=NumberRange.new(-80,80)
            burst.SpreadAngle=Vector2.new(30,360)
            burst.Acceleration=Vector3.new(0,-30,0)
            burst.Drag=10
            burst.LightEmission=.45
            burst.ZOffset=1.2
            burst.Size=NumberSequence.new({
                NumberSequenceKeypoint.new(0,2.5),
                NumberSequenceKeypoint.new(1,1.44),
            })
            burst.Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,1),
                NumberSequenceKeypoint.new(.19,.34),
                NumberSequenceKeypoint.new(.42,.14),
                NumberSequenceKeypoint.new(.53,.33),
                NumberSequenceKeypoint.new(1,1),
            })
            burst.Parent=att

            spray:Emit(34)
            burst:Emit(16)
            game:GetService("Debris"):AddItem(holder,2.5)
            return true
        end

        local TweenService=game:GetService("TweenService")
        local Debris=game:GetService("Debris")

        -- v2.69: captured Heart death effect.
        -- Visual values below come from the 2026-10-01 VFX scan: mesh 1717708486,
        -- trail lifetime/transparency/emission, exact attachment offsets, and the
        -- SWIRL particle texture 286708119. The original runtime motion is not stored
        -- in the scan, so the outward/rising motion is recreated locally while the
        -- captured Heart object itself is reproduced property-for-property.
        local HEART_MESH="rbxassetid://1717708486"
        local HEART_SWIRL="rbxassetid://286708119"
        local HEART_SIZE=Vector3.new(0.9722012281417847,0.9417980313301086,0.429999977350235)
        local HEART_COLORS={Color3.new(1,0.6666666865348816,1),Color3.new(1,0.3333333432674408,1)}
        local HEART_A0=Vector3.new(-0.4356907904148102,0.3930932581424713,0)
        local HEART_A1=Vector3.new(0.36197343468666077,-0.366097629070282,0)
        local HEART_SWIRL_POS=Vector3.new(-0.3172607421875,0,0)

        local lastGunHitHumanoid=nil
        local lastGunHitAt=0
        local recentBloodParts={}
        local seenBloodRoots=setmetatable({}, {__mode="k"})
        local suppressBloodUntil=0
        local suppressBloodPosition=nil

        local function makeCapturedHeart(position,index)
            local heart
            local okMesh,meshPart=pcall(function()
                local h=Instance.new("MeshPart")
                h.Name="Heart"
                h.MeshId=HEART_MESH
                pcall(function() h.TextureID="" end)
                return h
            end)
            if okMesh and meshPart then
                heart=meshPart
                heart.Size=HEART_SIZE
            else
                -- Some clients block writing MeshPart.MeshId at runtime. A FileMesh
                -- fallback keeps the captured asset usable instead of failing the effect.
                heart=Instance.new("Part")
                heart.Name="Heart"
                heart.Size=Vector3.new(1,1,1)
                local mesh=Instance.new("SpecialMesh")
                mesh.MeshType=Enum.MeshType.FileMesh
                mesh.MeshId=HEART_MESH
                mesh.Scale=HEART_SIZE
                mesh.Parent=heart
            end
            heart.Color=HEART_COLORS[((index-1)%2)+1]
            heart.Material=Enum.Material.SmoothPlastic
            heart.Transparency=0
            heart.Anchored=true
            heart.CanCollide=false
            heart.CanTouch=false
            heart.CanQuery=false
            heart.CastShadow=false
            heart.Massless=true
            heart.CFrame=CFrame.new(position)
                * CFrame.Angles(math.rad(math.random(-28,28)),math.rad(math.random(-180,180)),math.rad(math.random(-24,24)))

            local a0=Instance.new("Attachment")
            a0.Name="Attachment"
            a0.Position=HEART_A0
            a0.Parent=heart

            local a1=Instance.new("Attachment")
            a1.Name="Attachment"
            a1.Position=HEART_A1
            a1.Parent=heart

            local trail=Instance.new("Trail")
            trail.Name="Trail"
            trail.Attachment0=a0
            trail.Attachment1=a1
            trail.Color=ColorSequence.new(heart.Color)
            trail.Transparency=NumberSequence.new(0.5)
            trail.Lifetime=0.5
            trail.MinLength=0.10000000149011612
            trail.Texture=""
            trail.TextureLength=1
            trail.LightEmission=1
            trail.LightInfluence=1
            trail.Parent=heart

            local swirlAtt=Instance.new("Attachment")
            swirlAtt.Name="SWIRL_ATTACHMENT"
            swirlAtt.Position=HEART_SWIRL_POS
            swirlAtt.Parent=heart

            local swirl=Instance.new("ParticleEmitter")
            swirl.Name="ParticleEmitter"
            swirl.Texture=HEART_SWIRL
            swirl.Enabled=true
            swirl.Color=ColorSequence.new(Color3.new(1,0.3333333432674408,1))
            swirl.Lifetime=NumberRange.new(0.5,0.5)
            swirl.Speed=NumberRange.new(0,0)
            swirl.Rate=50
            swirl.Rotation=NumberRange.new(-50,50)
            swirl.RotSpeed=NumberRange.new(0,0)
            swirl.Acceleration=Vector3.zero
            swirl.Drag=0
            swirl.LockedToPart=false
            swirl.LightEmission=1
            swirl.LightInfluence=1
            swirl.Size=NumberSequence.new(0.5)
            swirl.Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,0.78125),
                NumberSequenceKeypoint.new(1,1),
            })
            swirl.SpreadAngle=Vector2.zero
            swirl.Parent=heart
            return heart
        end

        local function spawnDeathHeartsAt(position,force)
            if not force and extraState.GunKillEffect~="Hearts" then return false end
            if typeof(position)~="Vector3" then return false end

            local folder=Instance.new("Folder")
            folder.Name="KimqCapturedHeartDeathEffect"
            folder.Parent=workspace

            -- One scanned death produced a dense burst of Hearts. Use 40 so the
            -- replacement reads like the original rather than a tiny decorative burst.
            for i=1,40 do
                local startOffset=Vector3.new(math.random(-100,100)/70,math.random(-25,65)/85,math.random(-100,100)/70)
                local heart=makeCapturedHeart(position+startOffset,i)
                heart.Parent=folder

                -- Recreate the fast outward/upward release around the victim. The
                -- Heart/Trail/Particle object itself uses the exact captured values.
                local theta=(i/40)*math.pi*2 + math.random()*0.35
                local radius=2.4+math.random()*2.8
                local rise=2.2+math.random()*3.8
                local destination=position + Vector3.new(math.cos(theta)*radius,rise,math.sin(theta)*radius)
                local turn=CFrame.Angles(math.rad(math.random(-45,45)),math.rad(math.random(120,300)),math.rad(math.random(-45,45)))
                local travel=0.62+math.random()*0.42
                local tween=TweenService:Create(heart,TweenInfo.new(travel,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
                    CFrame=CFrame.new(destination)*turn,
                    Transparency=1,
                })
                tween:Play()
                Debris:AddItem(heart,travel+0.58)
            end
            Debris:AddItem(folder,1.8)
            return true
        end

        local function deathPosition(char)
            if not char then return nil end
            local part=char:FindFirstChild("HumanoidRootPart")
                or char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("Head")
            if part and part:IsA("BasePart") then return part.Position+Vector3.new(0,.7,0) end
            return nil
        end

        local function creatorIsLocal(hum)
            if not hum then return false end
            for _,name in ipairs({"creator","Creator","killer","Killer","lastHitBy","LastHitBy"}) do
                local tag=hum:FindFirstChild(name)
                if tag then
                    if tag:IsA("ObjectValue") and tag.Value==lp then return true end
                    if (tag:IsA("IntValue") or tag:IsA("NumberValue")) and tonumber(tag.Value)==lp.UserId then return true end
                    if tag:IsA("StringValue") and (tag.Value==lp.Name or tag.Value==lp.DisplayName or tonumber(tag.Value)==lp.UserId) then return true end
                end
                local attr=hum:GetAttribute(name)
                if attr==lp.UserId or attr==lp.Name or attr==lp.DisplayName then return true end
            end
            return false
        end

        local function closestHumanoidTo(position,maxDistance)
            local bestHum,bestDist=nil,maxDistance or 8
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=lp then
                    local char=plr.Character
                    local hum=char and char:FindFirstChildOfClass("Humanoid")
                    local root=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
                    if hum and root and root:IsA("BasePart") then
                        local d=(root.Position-position).Magnitude
                        if d<=bestDist then bestDist=d; bestHum=hum end
                    end
                end
            end
            return bestHum,bestDist
        end

        local function bloodRootOf(obj)
            local x=obj
            for _=1,5 do
                if not x then break end
                if tostring(x.Name):lower()=="bloodparticle" and x:IsA("BasePart") then return x end
                x=x.Parent
            end
            return nil
        end

        local function destroyBloodRoot(root)
            if not root or not root.Parent then return end
            pcall(function()
                for _,d in ipairs(root:GetDescendants()) do
                    if d:IsA("ParticleEmitter") then d.Enabled=false; d:Clear() end
                    if d:IsA("Trail") or d:IsA("Beam") then d.Enabled=false end
                end
                root:Destroy()
            end)
        end

        local function suppressRecentBloodFor(hum,position)
            local now=os.clock()
            suppressBloodUntil=now+0.45
            suppressBloodPosition=position
            for i=#recentBloodParts,1,-1 do
                local rec=recentBloodParts[i]
                if not rec.root or not rec.root.Parent or (now-rec.at)>1.2 then
                    table.remove(recentBloodParts,i)
                elseif rec.hum==hum then
                    destroyBloodRoot(rec.root)
                    table.remove(recentBloodParts,i)
                end
            end

            -- Also clear an already-emitted kill BloodParticle that existed before
            -- the Humanoid.Died callback ran. Keep this scoped to nearby top-level
            -- BloodParticle parts so other players' hit VFX are untouched.
            local ignored=workspace:FindFirstChild("Ignored") or workspace:FindFirstChild("ignored")
            if ignored then
                for _,d in ipairs(ignored:GetChildren()) do
                    if d:IsA("BasePart") and tostring(d.Name):lower()=="bloodparticle" and (d.Position-position).Magnitude<=9 then
                        destroyBloodRoot(d)
                    end
                end
            end
        end

        -- BloodParticle is the normal gun-hit blood package captured by the scan.
        -- Pair each one with the nearest victim only when it appears immediately
        -- after OUR Tool.Activated. This lets the death hook tell our kill from a
        -- random death without changing server damage or combat.
        workspace.DescendantAdded:Connect(function(obj)
            local root=bloodRootOf(obj)
            if not root or seenBloodRoots[root] then return end
            seenBloodRoots[root]=true
            local now=os.clock()
            if suppressBloodPosition and now<=suppressBloodUntil then
                if (root.Position-suppressBloodPosition).Magnitude<=9 then
                    task.defer(destroyBloodRoot,root)
                    return
                end
            end
            local shotAt=tonumber(rawget(_G,"KimqLastLocalShotAt")) or 0
            if shotAt<=0 or (now-shotAt)>.65 then return end
            local hum=closestHumanoidTo(root.Position,9)
            if hum then
                lastGunHitHumanoid=hum
                lastGunHitAt=now
                recentBloodParts[#recentBloodParts+1]={root=root,hum=hum,at=now}
            end
        end)

        local function wasMyGunKill(hum)
            if creatorIsLocal(hum) then return true end
            return hum~=nil and hum==lastGunHitHumanoid and (os.clock()-lastGunHitAt)<=1.8
        end

        local function hookDeathBloodCharacter(char)
            if not char or deathBloodHooks[char] then return end
            local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",8)
            if not hum then return end
            deathBloodHooks[char]=hum.Died:Connect(function()
                local pos=deathPosition(char)
                if not pos then return end
                if extraState.GunKillEffect=="Hearts" and wasMyGunKill(hum) then
                    suppressRecentBloodFor(hum,pos)
                    spawnDeathHeartsAt(pos,true)
                end
            end)
        end

        local function hookDeathBloodPlayer(plr)
            if not plr then return end
            if plr.Character then task.defer(hookDeathBloodCharacter,plr.Character) end
            plr.CharacterAdded:Connect(function(char)
                task.defer(hookDeathBloodCharacter,char)
            end)
        end

        for _,plr in ipairs(Players:GetPlayers()) do hookDeathBloodPlayer(plr) end
        Players.PlayerAdded:Connect(hookDeathBloodPlayer)

        local extraKnifeMirrors=setmetatable({}, {__mode="k"})
        local lastLocalShot=0

        local function palette()
            local p=_G.KimqThemeLivePalette
            if type(p)=="table" then return p end
            return {
                hot=hotColor, hot2=hotColor, bg=panelColor, bg2=panelColor,
                panel=panelColor, soft=lightColor, text=textColor, sub=subColor,
                line=lineColor, white=Color3.fromRGB(250,252,255)
            }
        end
        local function pcolor(key,fallback)
            local p=palette(); return p[key] or fallback
        end
        local function makeGridButton(parent,name)
            local p=palette()
            local b=Instance.new("TextButton",parent)
            b.BackgroundColor3=p.soft; b.BorderSizePixel=0; b.Text=name
            b.TextColor3=p.text; b.Font=Enum.Font.GothamSemibold; b.TextSize=11
            b.AutoButtonColor=false; corner(b,10); stroke(b,p.line,.35,1)
            return b
        end
        local function styleChoiceButtons(buttons,selected)
            local p=palette()
            for name,b in pairs(buttons) do
                if b and b.Parent then
                    local on=(name==selected)
                    b.BackgroundColor3=on and p.hot or p.soft
                    b.TextColor3=on and p.white or p.text
                    local st=b:FindFirstChildOfClass("UIStroke")
                    if st then st.Color=on and p.hot or p.line end
                end
            end
        end
        local function findFolder(names)
            for _,name in ipairs(names) do
                local direct=ReplicatedStorage:FindFirstChild(name)
                if direct then return direct end
            end
            for _,name in ipairs(names) do
                local recursive=ReplicatedStorage:FindFirstChild(name,true)
                if recursive then return recursive end
            end
            return nil
        end
        local function firstPart(obj)
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj end
            local h=obj:FindFirstChild("Handle",true)
            if h and h:IsA("BasePart") then return h end
            return obj:FindFirstChildWhichIsA("BasePart",true)
        end
        local function firstOfClass(obj,className)
            if not obj then return nil end
            if obj:IsA(className) then return obj end
            return obj:FindFirstChildWhichIsA(className,true)
        end
        local function safeCopy(dst,src,props)
            if not dst or not src then return end
            for _,prop in ipairs(props) do
                pcall(function() dst[prop]=src[prop] end)
            end
        end
        local function templateColor(root)
            local beam=firstOfClass(root,"Beam")
            if beam then
                local ok,v=pcall(function() return beam.Color.Keypoints[1].Value end)
                if ok and v then return v end
            end
            local trail=firstOfClass(root,"Trail")
            if trail then
                local ok,v=pcall(function() return trail.Color.Keypoints[1].Value end)
                if ok and v then return v end
            end
            local emitter=firstOfClass(root,"ParticleEmitter")
            if emitter then
                local ok,v=pcall(function() return emitter.Color.Keypoints[1].Value end)
                if ok and v then return v end
            end
            local part=firstPart(root)
            return part and part.Color or nil
        end
        local function copyBulletStyle(inst,root)
            if not inst or not root or extraState.BulletBeam=="None" then return end
            if inst:IsA("Beam") then
                local src=firstOfClass(root,"Beam")
                if src then
                    safeCopy(inst,src,{"Color","Transparency","Width0","Width1","CurveSize0","CurveSize1","FaceCamera","LightEmission","LightInfluence","Segments","Texture","TextureLength","TextureMode","TextureSpeed","ZOffset"})
                else
                    local c=templateColor(root); if c then pcall(function() inst.Color=ColorSequence.new(c) end) end
                end
            elseif inst:IsA("Trail") then
                local src=firstOfClass(root,"Trail")
                if src then
                    safeCopy(inst,src,{"Color","Transparency","Lifetime","MinLength","WidthScale","FaceCamera","LightEmission","LightInfluence","Texture","TextureLength","TextureMode"})
                else
                    local c=templateColor(root); if c then pcall(function() inst.Color=ColorSequence.new(c) end) end
                end
            elseif inst:IsA("ParticleEmitter") then
                local src=firstOfClass(root,"ParticleEmitter")
                if src then
                    safeCopy(inst,src,{"Color","Transparency","Texture","LightEmission","LightInfluence","Size","Lifetime","Speed","Rate","Rotation","RotSpeed","SpreadAngle","Acceleration","Drag","LockedToPart","Orientation","TimeScale","VelocityInheritance"})
                else
                    local c=templateColor(root); if c then pcall(function() inst.Color=ColorSequence.new(c) end) end
                end
            elseif inst:IsA("BasePart") then
                -- Only recolor an actual projectile/tracer part. Never recolor a gun Handle.
                local n=tostring(inst.Name):lower()
                local explicit=n:find("bullet",1,true) or n:find("tracer",1,true) or n:find("projectile",1,true) or n:find("laser",1,true)
                if explicit then
                    local c=templateColor(root); if c then pcall(function() inst.Color=c end) end
                end
            end
        end
        local function insideToolOrCharacter(obj)
            local x=obj
            while x do
                if x:IsA("Tool") then return true end
                if x==lp.Character then return true end
                x=x.Parent
            end
            return false
        end
        local function bulletish(obj)
            local x=obj
            for _=1,6 do
                if not x then break end
                if x:IsA("Tool") then return false end
                local n=tostring(x.Name):lower()
                if n:find("bullet",1,true) or n:find("beam",1,true) or n:find("tracer",1,true)
                    or n:find("projectile",1,true) or n:find("laser",1,true) then
                    return true
                end
                x=x.Parent
            end
            return false
        end
        local selectedBeamSource
        local function isInsideNamedVisual(d,name)
            local x=d
            while x and x~=workspace do
                if x.Name==name then return true end
                x=x.Parent
            end
            return false
        end
        local function styleToolShotVfx(tool)
            if not tool or not tool:IsA("Tool") then return end
            local src=selectedBeamSource()
            if not src then return end
            for _,d in ipairs(tool:GetDescendants()) do
                if not isInsideNamedVisual(d,"KimqSkinVisual") and not isInsideNamedVisual(d,"KimqKnifeSkinVisual") then
                    if d:IsA("Beam") or d:IsA("Trail") then
                        copyBulletStyle(d,src)
                    elseif d:IsA("ParticleEmitter") and bulletish(d) then
                        copyBulletStyle(d,src)
                    end
                end
            end
        end
        selectedBeamSource=function()
            if extraState.BulletBeam=="None" then return nil end
            local root=findFolder({"BulletBeams","Bullet Beams","BulletBeam"})
            return root and root:FindFirstChild(extraState.BulletBeam)
        end

        -- The game keeps its bullet presets in ReplicatedStorage.BulletBeams.
        -- Instead of guessing the name of the live projectile, patch the LOCAL
        -- templates themselves. Whichever preset the game's own shot code clones
        -- will therefore inherit the selected look. A pristine clone lets None
        -- restore every template exactly.
        local bulletBeamRoot=findFolder({"BulletBeams","Bullet Beams","BulletBeam"})
        local bulletBeamBackup=nil
        if bulletBeamRoot then pcall(function() bulletBeamBackup=bulletBeamRoot:Clone() end) end

        local function copyTemplateVisuals(targetRoot,sourceRoot)
            if not targetRoot or not sourceRoot then return end
            local srcBeam=firstOfClass(sourceRoot,"Beam")
            local srcTrail=firstOfClass(sourceRoot,"Trail")
            local srcEmitter=firstOfClass(sourceRoot,"ParticleEmitter")
            local srcPart=firstPart(sourceRoot)
            local srcColor=templateColor(sourceRoot)
            for _,d in ipairs(targetRoot:GetDescendants()) do
                if d:IsA("Beam") then
                    if srcBeam then safeCopy(d,srcBeam,{"Color","Transparency","Width0","Width1","CurveSize0","CurveSize1","FaceCamera","LightEmission","LightInfluence","Segments","Texture","TextureLength","TextureMode","TextureSpeed","ZOffset"})
                    elseif srcColor then pcall(function() d.Color=ColorSequence.new(srcColor) end) end
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("Trail") then
                    if srcTrail then safeCopy(d,srcTrail,{"Color","Transparency","Lifetime","MinLength","WidthScale","FaceCamera","LightEmission","LightInfluence","Texture","TextureLength","TextureMode"})
                    elseif srcColor then pcall(function() d.Color=ColorSequence.new(srcColor) end) end
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("ParticleEmitter") then
                    if srcEmitter then safeCopy(d,srcEmitter,{"Color","Transparency","Texture","LightEmission","LightInfluence","Size","Lifetime","Speed","Rate","Rotation","RotSpeed","SpreadAngle","Acceleration","Drag","LockedToPart","Orientation","TimeScale","VelocityInheritance"})
                    elseif srcColor then pcall(function() d.Color=ColorSequence.new(srcColor) end) end
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("Color3Value") and srcColor then
                    pcall(function() d.Value=srcColor end)
                elseif d:IsA("BasePart") and srcPart then
                    -- Safe here: these are ReplicatedStorage bullet templates, not guns.
                    safeCopy(d,srcPart,{"Color","Material","Transparency","Reflectance"})
                end
            end
            if targetRoot:IsA("BasePart") and srcPart then safeCopy(targetRoot,srcPart,{"Color","Material","Transparency","Reflectance"}) end
        end

        local function setLocalBeamSelectionHints(name)
            -- Some games read a local StringValue/attribute before cloning a preset.
            -- Only touch names that unambiguously describe bullet/tracer selection.
            local wanted={bulletbeam=true,bulletbeamcolor=true,bullettrail=true,tracer=true,tracerstyle=true}
            local function norm(x) return tostring(x):lower():gsub("[^%w]","") end
            local function scan(root)
                if not root then return end
                for _,d in ipairs(root:GetDescendants()) do
                    if d:IsA("StringValue") and wanted[norm(d.Name)] then pcall(function() d.Value=name end) end
                end
                for key,_ in pairs(root:GetAttributes()) do
                    if wanted[norm(key)] then pcall(function() root:SetAttribute(key,name) end) end
                end
            end
            scan(lp); scan(lp.Character); scan(lp:FindFirstChildOfClass("Backpack"))
        end

        local function applyBulletBeamOverride(name)
            -- v2.2: DO NOT rewrite ReplicatedStorage.BulletBeams. Doing that can recolor
            -- bullets belonging to other players on this client. We only remember the
            -- selected preset and copy it onto bullet_rays created during OUR shot window.
            name=tostring(name or "None")
            local root=findFolder({"BulletBeams","Bullet Beams","BulletBeam"})
            if name~="None" and (not root or not root:FindFirstChild(name)) then
                return false,"Bullet preset was not found"
            end
            setLocalBeamSelectionHints(name)
            if name=="None" then return true,"Bullet beam: None" end
            return true,"Bullet beam: "..name.."  •  local only"
        end

        -- Bullet-beam selector.
        local beamCard=card(skinsPage,205)
        beamCard.Name="KimqBulletBeamsCard"
        txt(beamCard,"Bullet Beams",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,pcolor("text",textColor))
        txt(beamCard,"Changes the look of your bullets when you shoot.",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,32),Enum.Font.Gotham,11,pcolor("sub",subColor))
        local beamList=Instance.new("ScrollingFrame",beamCard); beamList.Name="KimqBulletBeamList"; beamList.Size=UDim2.new(1,-20,0,105); beamList.Position=UDim2.fromOffset(10,62); beamList.BackgroundTransparency=1; beamList.BorderSizePixel=0; beamList.ScrollBarThickness=3; beamList.ScrollBarImageColor3=pcolor("hot",hotColor)
        local beamGrid=Instance.new("UIGridLayout",beamList); beamGrid.CellPadding=UDim2.fromOffset(7,7); beamGrid.CellSize=UDim2.new(.24,-5,0,34); beamGrid.SortOrder=Enum.SortOrder.LayoutOrder
        beamGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() beamList.CanvasSize=UDim2.new(0,0,0,beamGrid.AbsoluteContentSize.Y+7) end)
        local beamStatus=txt(beamCard,"Bullet beam: None",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,176),Enum.Font.GothamSemibold,11,pcolor("sub",subColor))
        local beamButtons={}
        local function refreshBeamStyle()
            styleChoiceButtons(beamButtons,extraState.BulletBeam)
            beamStatus.Text="Bullet beam: "..tostring(extraState.BulletBeam or "None")
            beamStatus.TextColor3=(extraState.BulletBeam~="None") and pcolor("hot",hotColor) or pcolor("sub",subColor)
        end
        local function scanBeams()
            for _,ch in ipairs(beamList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
            table.clear(beamButtons)
            local root=findFolder({"BulletBeams","Bullet Beams","BulletBeam"})
            local names={}
            if root then
                for _,ch in ipairs(root:GetChildren()) do
                    local hasVisual=ch.Name=="None" or firstOfClass(ch,"Beam") or firstOfClass(ch,"Trail") or firstOfClass(ch,"ParticleEmitter") or firstPart(ch)
                    if hasVisual and not ch:IsA("Sound") then table.insert(names,ch.Name) end
                end
            end
            if not table.find(names,"None") then table.insert(names,"None") end
            table.sort(names,function(a,b) if a=="None" then return true elseif b=="None" then return false else return a:lower()<b:lower() end end)
            for i,name in ipairs(names) do
                local b=makeGridButton(beamList,name); b.LayoutOrder=i; beamButtons[name]=b
                b.MouseButton1Click:Connect(function()
                    extraState.BulletBeam=name
                    local ok,msg=applyBulletBeamOverride(name)
                    refreshBeamStyle()
                    beamStatus.Text=msg
                    beamStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
                end)
            end
            refreshBeamStyle()
        end

        -- Custom bullet color + rainbow mode --------------------------------
        local function normalizeHex(s)
            s=tostring(s or ""):gsub("#",""):gsub("[^%x]",""):upper()
            if #s==3 then s=s:sub(1,1):rep(2)..s:sub(2,2):rep(2)..s:sub(3,3):rep(2) end
            if #s~=6 then return nil end
            return "#"..s
        end
        local function colorFromHex(s)
            local h=normalizeHex(s)
            if not h then return nil end
            return Color3.fromRGB(tonumber(h:sub(2,3),16),tonumber(h:sub(4,5),16),tonumber(h:sub(6,7),16))
        end
        local function hexFromColor(c)
            return string.format("#%02X%02X%02X",math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5))
        end
        local bulletCustomColor=colorFromHex(extraState.BulletColorHex) or Color3.fromRGB(255,105,180)
        extraState.BulletColorHex=hexFromColor(bulletCustomColor)
        local bulletHue,bulletSat,bulletVal=bulletCustomColor:ToHSV()

        local bulletColorCard=card(skinsPage,286)
        bulletColorCard.Name="KimqBulletColorCard"
        txt(bulletColorCard,"Bullet Color",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,pcolor("text",textColor))
        local bulletColorSub=txt(bulletColorCard,"Choose a custom or rainbow color for your bullets.",UDim2.new(1,-24,0,32),UDim2.fromOffset(12,30),Enum.Font.Gotham,11,pcolor("sub",subColor))
        bulletColorSub.TextWrapped=true

        local sv=Instance.new("Frame",bulletColorCard)
        sv.Name="BulletSV"; sv:SetAttribute("KimqThemePreview",true); sv.Size=UDim2.new(1,-190,0,142); sv.Position=UDim2.fromOffset(12,69); sv.BackgroundColor3=Color3.fromHSV(bulletHue,1,1); sv.BorderSizePixel=0; sv.Active=true; corner(sv,10); stroke(sv,pcolor("line",lineColor),.25,1)
        local white=Instance.new("Frame",sv); white.Size=UDim2.fromScale(1,1); white.BackgroundColor3=Color3.new(1,1,1); white.BorderSizePixel=0; white.Active=false; corner(white,10)
        local wg=Instance.new("UIGradient",white); wg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
        local black=Instance.new("Frame",sv); black.Size=UDim2.fromScale(1,1); black.BackgroundColor3=Color3.new(0,0,0); black.BorderSizePixel=0; black.Active=false; black.ZIndex=2; corner(black,10)
        local bg=Instance.new("UIGradient",black); bg.Rotation=90; bg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
        local svDot=Instance.new("Frame",sv); svDot.Size=UDim2.fromOffset(12,12); svDot.AnchorPoint=Vector2.new(.5,.5); svDot.BackgroundTransparency=1; svDot.ZIndex=5; corner(svDot,999)
        local svStroke=Instance.new("UIStroke",svDot); svStroke.Color=Color3.new(1,1,1); svStroke.Thickness=2
        local svHit=Instance.new("TextButton",sv); svHit.Size=UDim2.fromScale(1,1); svHit.BackgroundTransparency=1; svHit.Text=""; svHit.AutoButtonColor=false; svHit.ZIndex=10

        local hue=Instance.new("Frame",bulletColorCard)
        hue.Name="BulletHue"; hue:SetAttribute("KimqThemePreview",true); hue.Size=UDim2.fromOffset(22,142); hue.Position=UDim2.new(1,-166,0,69); hue.BorderSizePixel=0; hue.Active=true; corner(hue,11)
        local hg=Instance.new("UIGradient",hue); hg.Rotation=90; hg.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(1/6,Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(2/6,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(3/6,Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(4/6,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(5/6,Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
        local hueKnob=Instance.new("Frame",hue); hueKnob.Size=UDim2.fromOffset(30,8); hueKnob.AnchorPoint=Vector2.new(.5,.5); hueKnob.Position=UDim2.new(.5,0,bulletHue,0); hueKnob.BackgroundColor3=Color3.new(1,1,1); hueKnob.BorderSizePixel=0; hueKnob.ZIndex=5; corner(hueKnob,999); stroke(hueKnob,Color3.fromRGB(80,80,80),.15,1)
        local hueHit=Instance.new("TextButton",hue); hueHit.Size=UDim2.fromScale(1,1); hueHit.BackgroundTransparency=1; hueHit.Text=""; hueHit.AutoButtonColor=false; hueHit.ZIndex=10

        local preview=Instance.new("Frame",bulletColorCard); preview:SetAttribute("KimqThemePreview",true); preview.Size=UDim2.fromOffset(116,38); preview.Position=UDim2.new(1,-132,0,69); preview.BackgroundColor3=bulletCustomColor; preview.BorderSizePixel=0; corner(preview,10); stroke(preview,pcolor("line",lineColor),.2,1)
        local hexBox=Instance.new("TextBox",bulletColorCard); hexBox.Size=UDim2.fromOffset(116,32); hexBox.Position=UDim2.new(1,-132,0,115); hexBox.BackgroundColor3=pcolor("soft",lightColor); hexBox.BorderSizePixel=0; hexBox.Text=extraState.BulletColorHex; hexBox.PlaceholderText="#FF69B4"; hexBox.TextColor3=pcolor("text",textColor); hexBox.Font=Enum.Font.GothamSemibold; hexBox.TextSize=11; hexBox.ClearTextOnFocus=false; corner(hexBox,9); stroke(hexBox,pcolor("line",lineColor),.3,1)
        local customBtn=makeGridButton(bulletColorCard,"Custom Color"); customBtn.Size=UDim2.fromOffset(116,31); customBtn.Position=UDim2.new(1,-132,0,153)
        local rainbowBtn=makeGridButton(bulletColorCard,"Rainbow"); rainbowBtn.Size=UDim2.fromOffset(116,31); rainbowBtn.Position=UDim2.new(1,-132,0,190)
        local presetBtn=makeGridButton(bulletColorCard,"Preset Color"); presetBtn.Size=UDim2.new(.5,-15,0,34); presetBtn.Position=UDim2.fromOffset(12,225)
        local colorStatus=txt(bulletColorCard,"Mode: "..extraState.BulletColorMode,UDim2.new(.5,-15,0,34),UDim2.new(.5,3,0,225),Enum.Font.GothamSemibold,11,pcolor("sub",subColor),Enum.TextXAlignment.Center)

        local function refreshBulletColorUI()
            bulletCustomColor=Color3.fromHSV(bulletHue,bulletSat,bulletVal)
            extraState.BulletColorHex=hexFromColor(bulletCustomColor)
            preview.BackgroundColor3=bulletCustomColor; sv.BackgroundColor3=Color3.fromHSV(bulletHue,1,1)
            hexBox.Text=extraState.BulletColorHex
            svDot.Position=UDim2.new(bulletSat,0,1-bulletVal,0); hueKnob.Position=UDim2.new(.5,0,bulletHue,0)
            colorStatus.Text="Mode: "..tostring(extraState.BulletColorMode)
            local refreshTemplates=rawget(_G,"KimqRefreshBulletTemplates")
            if type(refreshTemplates)=="function" then pcall(refreshTemplates) end
            local p=palette()
            for name,b in pairs({Custom=customBtn,Rainbow=rainbowBtn,Preset=presetBtn}) do
                local on=extraState.BulletColorMode==name
                b.BackgroundColor3=on and p.hot or p.soft; b.TextColor3=on and p.white or p.text
            end
        end
        local function setCustomColor(c,activate)
            if not c then return end
            bulletCustomColor=c; bulletHue,bulletSat,bulletVal=c:ToHSV(); extraState.BulletColorHex=hexFromColor(c)
            if activate then extraState.BulletColorMode="Custom" end
            refreshBulletColorUI()
        end
        customBtn.MouseButton1Click:Connect(function() extraState.BulletColorMode="Custom"; refreshBulletColorUI() end)
        rainbowBtn.MouseButton1Click:Connect(function() extraState.BulletColorMode="Rainbow"; refreshBulletColorUI() end)
        presetBtn.MouseButton1Click:Connect(function() extraState.BulletColorMode="Preset"; refreshBulletColorUI() end)
        hexBox.FocusLost:Connect(function()
            local c=colorFromHex(hexBox.Text)
            if c then setCustomColor(c,true) else hexBox.Text=extraState.BulletColorHex end
        end)

        local pickerUIS=game:GetService("UserInputService")
        local draggingSV,draggingHue=false,false
        local function updateSV(pos)
            local p=sv.AbsolutePosition; local s=sv.AbsoluteSize
            bulletSat=math.clamp((pos.X-p.X)/math.max(s.X,1),0,1)
            bulletVal=1-math.clamp((pos.Y-p.Y)/math.max(s.Y,1),0,1)
            extraState.BulletColorMode="Custom"; refreshBulletColorUI()
        end
        local function updateHue(pos)
            local p=hue.AbsolutePosition; local s=hue.AbsoluteSize
            bulletHue=math.clamp((pos.Y-p.Y)/math.max(s.Y,1),0,1)
            extraState.BulletColorMode="Custom"; refreshBulletColorUI()
        end
        svHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingSV=true; updateSV(i.Position) end end)
        hueHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingHue=true; updateHue(i.Position) end end)
        pickerUIS.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                if draggingSV then updateSV(i.Position) elseif draggingHue then updateHue(i.Position) end
            end
        end)
        pickerUIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingSV=false; draggingHue=false end end)
        refreshBulletColorUI()

        -- Live bullet/tracer recolor -------------------------------------------------
        -- v2.8 persistent + low-lag path:
        --   * selected bullet color remains active across equip/unequip and gun replacement
        --   * local gun-side bullet templates are pre-colored so new shots start in the chosen color
        --   * only local shots are accepted (owner metadata first, muzzle-origin fallback second)
        --   * no per-effect PropertyChanged locks and no RenderStepped rescans
        --   * a few tiny delayed re-applies beat late game-side default-color writes without stutter
        local rainbowRoots=setmetatable({}, {__mode="k"})
        local localShotSerial=0
        local activeShotSerial=0
        local activeShotOrigin=nil
        local activeShotAt=0
        -- The first bullet_rays child that appears immediately after OUR Tool.Activated
        -- is claimed synchronously. This removes the one-frame default-color flash.
        local instantClaimSerial=0
        local instantClaimRoot=nil
        local claimedShotRoots=setmetatable({}, {__mode="k"})
        local bulletContainers=setmetatable({}, {__mode="k"})
        local hookedBulletContainers=setmetatable({}, {__mode="k"})
        local hookedShotTools=setmetatable({}, {__mode="k"})
        local hookedShotContainers=setmetatable({}, {__mode="k"})
        -- Birth time exists only for bullet_rays objects that appear after this script
        -- starts. A pre-existing shared holder has no birth stamp, so we never recolor
        -- the entire shared holder and accidentally touch somebody else's shot.
        local bulletRayBirth=setmetatable({}, {__mode="k"})
        local toolTemplateEffects=setmetatable({}, {__mode="k"})
        local templateRefreshQueued=false

        local function bulletEffectEnabled()
            return extraState.BulletColorMode=="Custom" or extraState.BulletColorMode=="Rainbow" or extraState.BulletBeam~="None"
        end

        local function currentBulletColor()
            if extraState.BulletColorMode=="Custom" then return bulletCustomColor end
            if extraState.BulletColorMode=="Rainbow" then return Color3.fromHSV((os.clock()*.45)%1,1,1) end
            return nil
        end

        local function isColorEffect(d)
            return d and (d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") or d:IsA("Color3Value") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") or d:IsA("BasePart"))
        end

        local function applyColorOnly(d,c)
            if not d or not d.Parent or not c then return end
            if d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") then
                pcall(function() d.Color=ColorSequence.new(c) end)
            elseif d:IsA("Color3Value") then
                pcall(function() d.Value=c end)
            elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") or d:IsA("BasePart") then
                pcall(function() d.Color=c end)
            end
        end

        -- Keep the selected tracer/bullet color, but stop the effect from blooming
        -- across the whole screen. This only runs on verified local bullet effects and
        -- local bullet templates; it does not dim the map, Lighting, or other players.
        local function softenBulletGlow(d)
            if not d or not d.Parent then return end
            local glow=math.clamp(tonumber(_G.KimqBulletLightBrightness) or 0.65,0,2.5)
            if d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                pcall(function() d.Brightness=glow end)
                pcall(function() d.Range=math.min(d.Range,8) end)
            elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") then
                pcall(function() d.LightEmission=math.clamp(glow/2.5,0,1) end)
                pcall(function() d.LightInfluence=math.clamp(1-(glow/3),0.15,1) end)
            end
        end

        local function applyBulletModeTo(d,cOverride)
            if not d or not d.Parent then return end
            local src=selectedBeamSource()
            if src and extraState.BulletBeam~="None" then
                if d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") then
                    copyBulletStyle(d,src)
                elseif d:IsA("BasePart") then
                    local c=templateColor(src); if c then applyColorOnly(d,c) end
                end
            end
            local c=cOverride or currentBulletColor()
            if c then applyColorOnly(d,c) end
            softenBulletGlow(d)
        end

        local function toolMuzzleOrigin(tool)
            if not tool or not tool.Parent then return nil end
            for _,name in ipairs({"Muzzle","MuzzleAttachment","GunMuzzle","FirePoint","FireAttachment","BarrelAttachment"}) do
                local a=tool:FindFirstChild(name,true)
                if a and a:IsA("Attachment") then return a.WorldPosition end
                if a and a:IsA("BasePart") then return a.Position end
            end
            local handle=tool:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then return handle.Position end
            local part=tool:FindFirstChildWhichIsA("BasePart",true)
            if part then return part.Position end
            local att=tool:FindFirstChildWhichIsA("Attachment",true)
            return att and att.WorldPosition or nil
        end

        local function ownerVerdict(obj)
            local keys={"OwnerUserId","ShooterUserId","PlayerUserId","UserId","ownerUserId","shooterUserId"}
            local x=obj
            for _=1,7 do
                if not x then break end
                for _,k in ipairs(keys) do
                    local ok,v=pcall(function() return x:GetAttribute(k) end)
                    if ok and v~=nil then
                        local n=tonumber(v)
                        if n then return n==lp.UserId end
                        local sv=tostring(v):lower()
                        if sv~="" then return sv==lp.Name:lower() or sv==lp.DisplayName:lower() end
                    end
                end
                for _,name in ipairs({"Owner","Shooter","Creator","Player"}) do
                    local ov=x:FindFirstChild(name)
                    if ov and ov:IsA("ObjectValue") and ov.Value then return ov.Value==lp end
                end
                x=x.Parent
            end
            return nil
        end

        local function bulletRayShotRoot(obj)
            local x=obj
            local child=obj
            for _=1,12 do
                if not x or x==workspace then break end
                if tostring(x.Name):lower()=="bullet_rays" then
                    if x==obj then return x end
                    return child
                end
                child=x
                x=x.Parent
            end
            return nil
        end

        local function rayStartsAtOrigin(root,origin)
            if not root or not origin then return false end
            local MAX_START_DISTANCE=8.5
            local function closePos(pos) return pos and (pos-origin).Magnitude<=MAX_START_DISTANCE end
            local function beamStartsClose(beam)
                local a0,a1=beam.Attachment0,beam.Attachment1
                return (a0 and closePos(a0.WorldPosition)) or (a1 and closePos(a1.WorldPosition))
            end
            local function partTouchesOrigin(part)
                if closePos(part.Position) then return true end
                local ok,p=pcall(function() return part.CFrame:PointToObjectSpace(origin) end)
                if not ok then return false end
                local half=part.Size*.5+Vector3.new(4,4,4)
                return math.abs(p.X)<=half.X and math.abs(p.Y)<=half.Y and math.abs(p.Z)<=half.Z
            end
            if root:IsA("Attachment") and closePos(root.WorldPosition) then return true end
            if root:IsA("Beam") and beamStartsClose(root) then return true end
            if root:IsA("BasePart") and partTouchesOrigin(root) then return true end
            local checked=0
            for _,d in ipairs(root:GetDescendants()) do
                checked+=1
                if d:IsA("Attachment") and closePos(d.WorldPosition) then return true end
                if d:IsA("Beam") and beamStartsClose(d) then return true end
                if d:IsA("BasePart") and partTouchesOrigin(d) then return true end
                if checked>=40 then break end
            end
            return false
        end

        local function styleRootPass(root,cOverride)
            if not root or not root.Parent then return nil end
            local effects={}
            if isColorEffect(root) then applyBulletModeTo(root,cOverride); effects[#effects+1]=root end
            for _,d in ipairs(root:GetDescendants()) do
                if isColorEffect(d) then applyBulletModeTo(d,cOverride); effects[#effects+1]=d end
            end
            return effects
        end

        local function styleVerifiedRoot(root,serial)
            if not root or not root.Parent then return end
            claimedShotRoots[root]=serial

            -- Apply synchronously first. If the game creates the root before adding its
            -- Beam/Trail/parts, briefly color new descendants as they arrive too.
            local effects=styleRootPass(root)
            local shortConn
            shortConn=root.DescendantAdded:Connect(function(d)
                if d and d.Parent and isColorEffect(d) then
                    applyBulletModeTo(d)
                    if extraState.BulletColorMode=="Rainbow" then
                        local list=rainbowRoots[root]
                        if list then list[#list+1]=d end
                    end
                end
            end)
            task.delay(.16,function()
                if shortConn then pcall(function() shortConn:Disconnect() end); shortConn=nil end
            end)

            pcall(function()
                root:SetAttribute("KimqLocalBulletStyled",true)
                root:SetAttribute("KimqLocalShotSerial",serial)
            end)
            if extraState.BulletColorMode=="Rainbow" then rainbowRoots[root]=effects or {} else rainbowRoots[root]=nil end

            -- The game can write its default color a moment after construction. These
            -- two tiny passes happen before/around the first visible frames without a
            -- per-frame scanner or PropertyChanged lock.
            for _,delayTime in ipairs({0.008,0.032}) do
                task.delay(delayTime,function()
                    if not root or not root.Parent then return end
                    local refreshed=styleRootPass(root)
                    if extraState.BulletColorMode=="Rainbow" and refreshed then rainbowRoots[root]=refreshed end
                end)
            end
        end

        local function instantClaimCandidate(obj,serial)
            if not bulletEffectEnabled() or serial~=activeShotSerial then return false end
            if (os.clock()-activeShotAt)>.24 then return false end
            local root=bulletRayShotRoot(obj)
            if not root or not root.Parent then return false end
            if claimedShotRoots[root]==serial then return true end

            -- Never touch a projectile explicitly owned by somebody else. When the
            -- game has not populated owner/origin metadata yet, only the FIRST new
            -- bullet root after our own Tool.Activated is provisionally ours.
            local verdict=ownerVerdict(root)
            if verdict==false then return false end
            if verdict==true or instantClaimSerial~=serial then
                instantClaimSerial=serial
                instantClaimRoot=root
                styleVerifiedRoot(root,serial)
                return true
            end
            return instantClaimRoot==root
        end

        local function tryCaptureCandidate(obj,serial)
            if not bulletEffectEnabled() or serial~=activeShotSerial then return false end
            if (os.clock()-activeShotAt)>.38 then return false end
            local root=bulletRayShotRoot(obj)
            if not root or not root.Parent then return false end
            if claimedShotRoots[root]==serial then return true end
            local verdict=ownerVerdict(root)
            if verdict==false then return false end
            if verdict~=true and not rayStartsAtOrigin(root,activeShotOrigin) then return false end
            styleVerifiedRoot(root,serial)
            return true
        end

        local function captureWithShortRetry(obj,serial)
            -- First try the synchronous shot claim so the bullet never renders in its
            -- default color. If metadata is already available, the normal verifier is
            -- still used; delayed retries are only a fallback for late-populated rays.
            if instantClaimCandidate(obj,serial) then return end
            if tryCaptureCandidate(obj,serial) then return end
            for _,delayTime in ipairs({0.012,0.045}) do
                task.delay(delayTime,function()
                    if serial~=activeShotSerial or not obj or not obj.Parent then return end
                    local root=bulletRayShotRoot(obj)
                    if root and claimedShotRoots[root]==serial then return end
                    if instantClaimCandidate(obj,serial) then return end
                    tryCaptureCandidate(obj,serial)
                end)
            end
        end

        local function hasBulletAncestorName(d)
            local x=d
            for _=1,6 do
                if not x then break end
                local n=tostring(x.Name or ""):lower()
                if n:find("bullet",1,true) or n:find("tracer",1,true) or n:find("projectile",1,true) or n:find("ray",1,true) or n:find("beam",1,true) then return true end
                x=x.Parent
            end
            return false
        end

        local function likelyBulletGun(tool)
            if not tool or not tool:IsA("Tool") then return false end
            local n=tostring(tool.Name or ""):lower()
            if n:find("knife",1,true) or n:find("blade",1,true) or n:find("wallet",1,true) or n:find("phone",1,true) then return false end
            local words={"revolver","shotgun","silencer","smg","pistol","rifle","gun","tactical","double","glock","uzi","ak"}
            for _,w in ipairs(words) do if n:find(w,1,true) then return true end end
            -- Unknown Tools are only treated as guns if they expose a typical muzzle/ammo marker.
            return tool:FindFirstChild("Muzzle",true)~=nil or tool:FindFirstChild("Ammo",true)~=nil or tool:FindFirstChild("Clip",true)~=nil
        end

        local function getToolTemplateEffects(tool)
            if not tool or not tool.Parent then return {} end
            local cached=toolTemplateEffects[tool]
            if cached then return cached end
            cached={}
            local touched=0
            for _,d in ipairs(tool:GetDescendants()) do
                if (d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") or d:IsA("Color3Value") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")) and hasBulletAncestorName(d) then
                    cached[#cached+1]=d
                    touched+=1
                    if touched>=48 then break end
                end
            end
            toolTemplateEffects[tool]=cached
            return cached
        end

        local function styleLocalToolTemplates(tool)
            if not tool or not tool.Parent then return end
            local c=currentBulletColor()
            if not c then return end
            for _,d in ipairs(getToolTemplateEffects(tool)) do
                if d and d.Parent then
                    applyColorOnly(d,c)
                    softenBulletGlow(d)
                end
            end
        end

        local function refreshAllLocalGunTemplates()
            if templateRefreshQueued then return end
            templateRefreshQueued=true
            task.defer(function()
                templateRefreshQueued=false
                -- Only the equipped gun needs immediate repainting. Backpack guns are
                -- recolored once when equipped, avoiding full inventory scans.
                if lp.Character then
                    for _,tool in ipairs(lp.Character:GetChildren()) do
                        if tool:IsA("Tool") and likelyBulletGun(tool) then styleLocalToolTemplates(tool) end
                    end
                end
            end)
        end
        _G.KimqRefreshBulletTemplates=refreshAllLocalGunTemplates

        local function hookBulletContainer(container)
            if not container or hookedBulletContainers[container] then return end
            hookedBulletContainers[container]=true
            bulletContainers[container]=true

            -- In this game bullet_rays can be either a shared folder OR the transient
            -- shot object itself. v2.14 assumed it was always a folder, which meant
            -- some guns never got recolored at all. During OUR short Tool.Activated
            -- window, try the bullet_rays object itself synchronously first.
            local serial=activeShotSerial
            local born=bulletRayBirth[container]
            if born and serial~=0 and (os.clock()-activeShotAt)<=.38 and math.abs(born-activeShotAt)<=.45 then
                captureWithShortRetry(container,serial)
            end

            container.ChildAdded:Connect(function(ch)
                local shotSerial=activeShotSerial
                if shotSerial==0 or (os.clock()-activeShotAt)>.38 then return end
                -- Handles the other layout where bullet_rays is a folder containing
                -- a fresh ray/model for each shot.
                captureWithShortRetry(ch,shotSerial)
            end)

            serial=activeShotSerial
            if serial~=0 and (os.clock()-activeShotAt)<=.38 then
                local children=container:GetChildren()
                local newest=children[#children]
                if newest then captureWithShortRetry(newest,serial) end
            end
        end

        -- bullet_rays are transient in this game, so avoid a full workspace scan.
        -- Catch an already-existing object cheaply, then color a newly-created
        -- bullet_rays synchronously when it appears during OUR own shot window.
        local existingBulletRays=workspace:FindFirstChild("bullet_rays",true)
        if existingBulletRays then hookBulletContainer(existingBulletRays) end
        workspace.DescendantAdded:Connect(function(d)
            if tostring(d.Name):lower()=="bullet_rays" then
                local now=os.clock()
                bulletRayBirth[d]=now
                local serial=activeShotSerial
                if serial~=0 and (now-activeShotAt)<=.38 then
                    -- A bullet_rays object born right beside our Tool.Activated is a
                    -- transient local-shot candidate. Style it immediately.
                    captureWithShortRetry(d,serial)
                end
                hookBulletContainer(d)
            end
        end)

        local function markLocalShot(tool)
            if not tool or tool.Parent~=lp.Character then return end
            local origin=toolMuzzleOrigin(tool)
            if not origin then return end
            -- Gun templates are already colored on equip; do not rescan the Tool on every shot.
            localShotSerial+=1
            activeShotSerial=localShotSerial
            activeShotAt=os.clock()
            activeShotOrigin=origin
            instantClaimSerial=0
            instantClaimRoot=nil
            lastLocalShot=activeShotAt
            _G.KimqLastLocalShotAt=activeShotAt
            local serial=activeShotSerial
            -- ChildAdded is the normal capture path. This one-item fallback handles
            -- a bullet created in the same scheduler slice without walking old rays.
            task.defer(function()
                for container,_ in pairs(bulletContainers) do
                    if container and container.Parent then
                        -- Claim bullet_rays itself only when it was newly born around
                        -- this shot. A pre-existing shared holder is never bulk-colored.
                        local born=bulletRayBirth[container]
                        if born and math.abs(born-activeShotAt)<=.45 then
                            captureWithShortRetry(container,serial)
                        end
                        -- If it is a shared holder, claim only its newest child.
                        local children=container:GetChildren()
                        local newest=children[#children]
                        if newest then captureWithShortRetry(newest,serial) end
                    end
                end
            end)
        end

        local function hookShotTool(tool)
            if not tool or not tool:IsA("Tool") or hookedShotTools[tool] then return end
            hookedShotTools[tool]=true

            -- Some guns rewrite/rebuild their local bullet template on equip. Repaint
            -- it a few times only around equip (not every frame), and color any newly
            -- inserted bullet/beam effect immediately. This keeps the selected color
            -- persistent after putting the gun away and taking it back out.
            tool.DescendantAdded:Connect(function(d)
                if bulletEffectEnabled() and isColorEffect(d) and hasBulletAncestorName(d) then
                    applyBulletModeTo(d)
                    toolTemplateEffects[tool]=nil
                end
            end)
            tool.Equipped:Connect(function()
                if not likelyBulletGun(tool) then return end
                toolTemplateEffects[tool]=nil
                styleLocalToolTemplates(tool)
                task.delay(.035,function() if tool and tool.Parent then toolTemplateEffects[tool]=nil; styleLocalToolTemplates(tool) end end)
                task.delay(.12,function() if tool and tool.Parent then toolTemplateEffects[tool]=nil; styleLocalToolTemplates(tool) end end)
            end)
            tool.Activated:Connect(function() markLocalShot(tool) end)
        end

        local function hookShotContainer(container)
            if not container or hookedShotContainers[container] then return end
            hookedShotContainers[container]=true
            for _,ch in ipairs(container:GetChildren()) do hookShotTool(ch) end
            container.ChildAdded:Connect(hookShotTool)
        end

        local function hookAllShotContainers()
            hookShotContainer(lp:FindFirstChildOfClass("Backpack"))
            if lp.Character then hookShotContainer(lp.Character) end
            refreshAllLocalGunTemplates()
        end
        hookAllShotContainers()
        lp.CharacterAdded:Connect(function()
            activeShotSerial=0; activeShotOrigin=nil; instantClaimSerial=0; instantClaimRoot=nil
            task.delay(.15,hookAllShotContainers)
        end)

        local rainbowAccumulator=0
        RunService.Heartbeat:Connect(function(dt)
            if extraState.BulletColorMode~="Rainbow" then
                if next(rainbowRoots)~=nil then table.clear(rainbowRoots) end
                return
            end
            rainbowAccumulator+=dt
            if rainbowAccumulator<0.05 then return end
            rainbowAccumulator=0
            local c=Color3.fromHSV((os.clock()*.45)%1,1,1)
            for root,effects in pairs(rainbowRoots) do
                if not root or not root.Parent then
                    rainbowRoots[root]=nil
                else
                    local alive=0
                    for _,d in ipairs(effects) do if d and d.Parent then applyColorOnly(d,c); alive+=1 end end
                    if alive==0 then rainbowRoots[root]=nil end
                end
            end
        end)

        refreshAllLocalGunTemplates()


        -- Shared animated cosmetic clone for knife skins. It uses the same animation
        -- ID/Humanoid/AnimationController logic that made Ascension work.
        local function sanitizeClone(root)
            local clientScripts=0
            for _,d in ipairs(root:GetDescendants()) do
                if d:IsA("LocalScript") then
                    -- Cosmetic clones do not need their own game scripts. Running cloned
                    -- scripts was a major knife-equip performance spike.
                    clientScripts+=1; pcall(function() d.Disabled=true end); pcall(function() d.Enabled=false end)
                elseif d:IsA("ModuleScript") then
                    -- Keep modules for local animation scripts.
                elseif d:IsA("Script") then
                    local isClient=false; pcall(function() isClient=(d.RunContext==Enum.RunContext.Client) end)
                    if isClient then clientScripts+=1; pcall(function() d.Disabled=true end); pcall(function() d.Enabled=false end) else d:Destroy() end
                elseif d:IsA("BasePart") then
                    d.Anchored=false; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false; d.Massless=true
                    pcall(function() d.AssemblyLinearVelocity=Vector3.zero; d.AssemblyAngularVelocity=Vector3.zero end)
                elseif d:IsA("ParticleEmitter") then
                    pcall(function() d.Enabled=true; d.Rate=math.min(d.Rate,45) end)
                elseif d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
                    pcall(function() d.Enabled=true end)
                end
            end
            if root:IsA("BasePart") then root.Anchored=false; root.CanCollide=false; root.CanTouch=false; root.CanQuery=false; root.Massless=true end
            return clientScripts
        end
        local knifeEquipHooks=setmetatable({}, {__mode="k"})
        local knifeClearing=setmetatable({}, {__mode="k"})
        local applyKnifeSkin

        local function clearKnifeVisual(tool,keepSelection)
            if not tool then return end
            knifeClearing[tool]=true
            for _,ch in ipairs(tool:GetChildren()) do
                if ch.Name=="KimqKnifeSkinVisual" then pcall(function() ch:Destroy() end) end
            end
            for _,d in ipairs(tool:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("KimqKnifeOriginalPart") then
                    pcall(function() d.LocalTransparencyModifier=d:GetAttribute("KimqKnifeOldLTM") or 0 end)
                    d:SetAttribute("KimqKnifeOriginalPart",nil); d:SetAttribute("KimqKnifeOldLTM",nil)
                end
            end
            knifeClearing[tool]=nil
        end
        local function findKnifeTool()
            local function scan(container)
                if not container then return nil end
                for _,ch in ipairs(container:GetChildren()) do
                    if ch:IsA("Tool") then
                        local n=ch.Name:lower():gsub("[%[%]]","")
                        if n=="knife" or n:find("knife",1,true) or n:find("blade",1,true) then return ch end
                    end
                end
                -- Some games wrap the Tool one level down.
                for _,ch in ipairs(container:GetDescendants()) do
                    if ch:IsA("Tool") then
                        local n=ch.Name:lower():gsub("[%[%]]","")
                        if n=="knife" or n:find("knife",1,true) or n:find("blade",1,true) then return ch end
                    end
                end
            end
            return scan(lp.Character) or scan(lp:FindFirstChildOfClass("Backpack"))
        end
        local function visibleKnifePart(part)
            local n=tostring(part.Name):upper()
            if n:find("HITBOX",1,true) or n=="HUMANOIDROOTPART" or n:find("PARTICLE_PART",1,true)
                or n:find("COLLIDER",1,true) or n:find("COLLISION",1,true) or n:find("HIT_PART",1,true) then
                return false
            end

            -- Plain Handle parts are commonly just weld/animation carriers. Keep them
            -- invisible so a grey rectangular block cannot surround the selected knife.
            -- A Handle with a SpecialMesh is real visible geometry and is kept.
            if part.Name=="Handle" and part:IsA("Part") and not part:FindFirstChildWhichIsA("SpecialMesh") then
                return false
            end
            if part:IsA("MeshPart") or part:IsA("UnionOperation") or part:FindFirstChildWhichIsA("SpecialMesh") then
                return true
            end

            -- Other plain BaseParts are visible only when the template intentionally made them visible.
            return part.Transparency < .95
        end
        local function ensureKnifeEquipHook(tool)
            if not tool or knifeEquipHooks[tool] then return end
            knifeEquipHooks[tool]=true
            tool.Equipped:Connect(function()
                task.delay(.08,function()
                    if tool.Parent==lp.Character and extraState.KnifeSkin and extraState.KnifeSkin~="None" and not tool:FindFirstChild("KimqKnifeSkinVisual") then
                        if applyKnifeSkin then applyKnifeSkin(extraState.KnifeSkin,true) end
                    end
                end)
            end)
            tool.ChildRemoved:Connect(function(ch)
                if ch.Name=="KimqKnifeSkinVisual" and not knifeClearing[tool] and extraState.KnifeSkin and extraState.KnifeSkin~="None" then
                    task.delay(.12,function()
                        if tool.Parent and not tool:FindFirstChild("KimqKnifeSkinVisual") and applyKnifeSkin then applyKnifeSkin(extraState.KnifeSkin,true) end
                    end)
                end
            end)
        end

        local knifeAccentButtons={}
        local function knifeAccentColor()
            if extraState.KnifeAccentMode=="Theme" then
                return pcolor("hot",hotColor)
            elseif extraState.KnifeAccentMode=="Bullet" then
                return currentBulletColor() or bulletCustomColor
            end
            return nil
        end
        local function knifeAccentCandidate(d)
            if d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") or d:IsA("Color3Value")
                or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                return true
            end
            if d:IsA("BasePart") then
                local n=d.Name:lower()
                return d.Material==Enum.Material.Neon
                    or n:find("glow",1,true) or n:find("effect",1,true) or n:find("aura",1,true)
                    or n:find("light",1,true) or n:find("neon",1,true) or n:find("energy",1,true)
                    or n:find("accent",1,true)
            end
            return false
        end
        local function applyKnifeAccentTo(root)
            local c=knifeAccentColor()
            if not root or not c then return end
            if knifeAccentCandidate(root) then applyColorOnly(root,c) end
            for _,d in ipairs(root:GetDescendants()) do
                if knifeAccentCandidate(d) then applyColorOnly(d,c) end
            end
        end
        local function refreshKnifeAccentStyle()
            local p=palette()
            for mode,b in pairs(knifeAccentButtons) do
                if b and b.Parent then
                    local on=mode==extraState.KnifeAccentMode
                    b.BackgroundColor3=on and p.hot or p.soft
                    b.TextColor3=on and (p.white or Color3.new(1,1,1)) or p.text
                    local st=b:FindFirstChildOfClass("UIStroke")
                    if st then st.Color=on and p.hot or p.line end
                end
            end
        end
        local function refreshKnifeAccentVisual()
            local t=findKnifeTool()
            local visual=t and t:FindFirstChild("KimqKnifeSkinVisual")
            if visual and extraState.KnifeAccentMode~="Off" then applyKnifeAccentTo(visual) end
        end
        _G.KimqRefreshKnifeAccentTheme=function()
            refreshKnifeAccentStyle()
            if extraState.KnifeAccentMode=="Theme" then refreshKnifeAccentVisual() end
        end

        applyKnifeSkin=function(name,quiet)
            name=tostring(name or "None")
            extraState.KnifeSkin=name
            local tool=findKnifeTool()
            if not tool then return false,"Knife is not in your Backpack / Character" end
            ensureKnifeEquipHook(tool)
            clearKnifeVisual(tool,true)
            if name=="None" then return true,"Knife skin reset" end
            local root=findFolder({"Knives","KnifeSkins","Knife Skins"})
            local source=root and root:FindFirstChild(name)
            if not source then return false,"Knife skin was not found" end
            local sourceRoot=source:FindFirstChild("Handle")
            if not (sourceRoot and sourceRoot:IsA("BasePart")) then sourceRoot=firstPart(source) end
            local target=tool:FindFirstChild("Handle")
            if not (target and target:IsA("BasePart")) then target=firstPart(tool) end
            if not sourceRoot then return false,"Selected knife has no Handle" end
            if not target then return false,"Your equipped Knife has no Handle" end

            -- Capture ORIGINAL tool visuals before parenting the clone so we never
            -- accidentally hide our own skin. This was the main reason some skins
            -- ended up completely invisible in the previous build.
            local originals={}
            for _,d in ipairs(tool:GetDescendants()) do
                if d:IsA("BasePart") then table.insert(originals,d) end
            end

            -- Clone the complete ReplicatedStorage.Knives model exactly. Beta/Bitcoin/
            -- Nightblade store the meshes, unions, trails and attachments under Handle;
            -- Fishbone can also include an AnimationController and extra rig parts.
            local visual=source:Clone()
            visual.Name="KimqKnifeSkinVisual"
            sanitizeClone(visual)
            local cloneRoot=visual:FindFirstChild("Handle")
            if not (cloneRoot and cloneRoot:IsA("BasePart")) then cloneRoot=firstPart(visual) end
            if not cloneRoot then visual:Destroy(); return false,"Knife clone lost its Handle" end

            -- Reveal authored display geometry only. Keep hitboxes/particle carriers hidden.
            local visibleCount=0
            local allParts={}
            if visual:IsA("BasePart") then table.insert(allParts,visual) end
            for _,d in ipairs(visual:GetDescendants()) do if d:IsA("BasePart") then table.insert(allParts,d) end end
            for _,part in ipairs(allParts) do
                part.Anchored=false; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.Massless=true
                part.LocalTransparencyModifier=0
                if visibleKnifePart(part) then
                    if part.Transparency>=.95 then pcall(function() part.Transparency=0 end) end
                    visibleCount+=1
                else
                    pcall(function() part.Transparency=1 end)
                end
            end

            -- Match the selected template Handle directly to the real Knife Handle.
            -- No auto-scaling: every skin keeps its authored proportions.
            local delta=target.CFrame*sourceRoot.CFrame:Inverse()
            if visual:IsA("BasePart") then visual.CFrame=delta*visual.CFrame end
            for _,d in ipairs(visual:GetDescendants()) do if d:IsA("BasePart") then d.CFrame=delta*d.CFrame end end
            visual.Parent=tool

            -- Preserve authored joints/constraints/AnimationController rigs, and only
            -- weld genuinely loose visual parts to the cloned Handle.
            local jointed={}
            for _,j in ipairs(visual:GetDescendants()) do
                if j:IsA("JointInstance") then
                    if j.Part0 then jointed[j.Part0]=true end; if j.Part1 then jointed[j.Part1]=true end
                elseif j:IsA("WeldConstraint") then
                    if j.Part0 then jointed[j.Part0]=true end; if j.Part1 then jointed[j.Part1]=true end
                elseif j:IsA("Constraint") then
                    local a0,a1=nil,nil; pcall(function() a0=j.Attachment0 end); pcall(function() a1=j.Attachment1 end)
                    if a0 and a0.Parent and a0.Parent:IsA("BasePart") then jointed[a0.Parent]=true end
                    if a1 and a1.Parent and a1.Parent:IsA("BasePart") then jointed[a1.Parent]=true end
                end
            end
            local rootWeld=Instance.new("WeldConstraint")
            rootWeld.Name="KimqKnifeRootWeld"; rootWeld.Part0=target; rootWeld.Part1=cloneRoot; rootWeld.Parent=cloneRoot
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("BasePart") and d~=cloneRoot and not jointed[d] then
                    local w=Instance.new("WeldConstraint"); w.Name="KimqKnifeLooseWeld"; w.Part0=cloneRoot; w.Part1=d; w.Parent=d
                end
            end

            -- Hide only ORIGINAL display geometry, never hitboxes and never the clone.
            for _,d in ipairs(originals) do
                if d.Parent and visibleKnifePart(d) then
                    d:SetAttribute("KimqKnifeOriginalPart",true)
                    d:SetAttribute("KimqKnifeOldLTM",d.LocalTransparencyModifier)
                    d.LocalTransparencyModifier=1
                end
            end

            applyKnifeAccentTo(visual)
            local embedded,driver,found=playSkinAnimationsFromIds(source,visual)
            local mirrored=mirrorPlayingAnimations(source,visual)
            local detail=""
            if embedded+mirrored>0 then detail="  •  animated"
            elseif found and found>0 then detail="  •  animation ready"
            elseif hasAnimatedVisuals(source) then detail="  •  VFX ready" end
            return true,"Knife skin: "..name..detail.."  •  "..tostring(visibleCount).." visible part(s)"
        end

        local knifeCard=card(skinsPage,205); knifeCard.Name="KimqKnifeSkinsCard"
        txt(knifeCard,"Knife Skins",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,pcolor("text",textColor))
        txt(knifeCard,"Choose the knife style you want to use.",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,32),Enum.Font.Gotham,11,pcolor("sub",subColor))
        local knifeList=Instance.new("ScrollingFrame",knifeCard); knifeList.Name="KimqKnifeList"; knifeList.Size=UDim2.new(1,-20,0,105); knifeList.Position=UDim2.fromOffset(10,62); knifeList.BackgroundTransparency=1; knifeList.BorderSizePixel=0; knifeList.ScrollBarThickness=3; knifeList.ScrollBarImageColor3=pcolor("hot",hotColor)
        local knifeGrid=Instance.new("UIGridLayout",knifeList); knifeGrid.CellPadding=UDim2.fromOffset(7,7); knifeGrid.CellSize=UDim2.new(.24,-5,0,34); knifeGrid.SortOrder=Enum.SortOrder.LayoutOrder
        knifeGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() knifeList.CanvasSize=UDim2.new(0,0,0,knifeGrid.AbsoluteContentSize.Y+7) end)
        local knifeStatus=txt(knifeCard,"Knife skin: None",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,176),Enum.Font.GothamSemibold,11,pcolor("sub",subColor))
        local knifeButtons={}
        local function refreshKnifeStyle() styleChoiceButtons(knifeButtons,extraState.KnifeSkin) end
        local function scanKnives()
            for _,ch in ipairs(knifeList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end; table.clear(knifeButtons)
            local root=findFolder({"Knives","KnifeSkins","Knife Skins"}); local names={"None"}
            if root then for _,ch in ipairs(root:GetChildren()) do if ch.Name~="None" and (firstPart(ch) or ch:IsA("Tool")) then table.insert(names,ch.Name) end end end
            table.sort(names,function(a,b) if a=="None" then return true elseif b=="None" then return false else return a:lower()<b:lower() end end)
            for i,name in ipairs(names) do
                local b=makeGridButton(knifeList,name); b.LayoutOrder=i; knifeButtons[name]=b
                b.MouseButton1Click:Connect(function()
                    local ok,msg=applyKnifeSkin(name,false); refreshKnifeStyle(); knifeStatus.Text=msg; knifeStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
                end)
            end
            refreshKnifeStyle()
        end

        local knifeAccentCard=card(skinsPage,94); knifeAccentCard.Name="KimqKnifeAccentCard"
        txt(knifeAccentCard,"Knife Accent Recolor",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,pcolor("text",textColor))
        txt(knifeAccentCard,"Optional: recolor knife glow/VFX + neon accent pieces, not the whole mesh.",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,31),Enum.Font.Gotham,10,pcolor("sub",subColor))
        for i,mode in ipairs({"Off","Theme","Bullet"}) do
            local b=makeGridButton(knifeAccentCard,mode)
            b.Size=UDim2.new(.333,-10,0,30)
            b.Position=UDim2.new((i-1)/3,8+(i-1)*2,0,56)
            knifeAccentButtons[mode]=b
            b.MouseButton1Click:Connect(function()
                extraState.KnifeAccentMode=mode
                refreshKnifeAccentStyle()
                local t=findKnifeTool()
                if t and extraState.KnifeSkin and extraState.KnifeSkin~="None" then
                    -- Reclone from the untouched template so switching Off restores authored colors.
                    applyKnifeSkin(extraState.KnifeSkin,true)
                end
            end)
        end
        refreshKnifeAccentStyle()

        -- Equippable local items.
        local equipCard=card(skinsPage,238); equipCard.Name="KimqEquipableItemsCard"
        txt(equipCard,"Equippable Items",UDim2.new(1,-24,0,22),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,pcolor("text",textColor))
        txt(equipCard,"Choose an item to wear or hold locally.",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,32),Enum.Font.Gotham,11,pcolor("sub",subColor))
        local equipList=Instance.new("ScrollingFrame",equipCard); equipList.Name="KimqEquipableList"; equipList.Size=UDim2.new(1,-20,0,112); equipList.Position=UDim2.fromOffset(10,62); equipList.BackgroundTransparency=1; equipList.BorderSizePixel=0; equipList.ScrollBarThickness=3; equipList.ScrollBarImageColor3=pcolor("hot",hotColor)
        local equipGrid=Instance.new("UIGridLayout",equipList); equipGrid.CellPadding=UDim2.fromOffset(7,7); equipGrid.CellSize=UDim2.new(.32,-5,0,34); equipGrid.SortOrder=Enum.SortOrder.LayoutOrder
        equipGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() equipList.CanvasSize=UDim2.new(0,0,0,equipGrid.AbsoluteContentSize.Y+7) end)
        local equipStatus=txt(equipCard,"Equippable: None",UDim2.new(1,-150,0,22),UDim2.fromOffset(12,184),Enum.Font.GothamSemibold,11,pcolor("sub",subColor))
        local removeEquip=Instance.new("TextButton",equipCard); removeEquip.Size=UDim2.fromOffset(126,32); removeEquip.Position=UDim2.new(1,-138,0,181); removeEquip.BackgroundColor3=pcolor("soft",lightColor); removeEquip.BorderSizePixel=0; removeEquip.Text="remove item"; removeEquip.TextColor3=pcolor("text",textColor); removeEquip.Font=Enum.Font.GothamSemibold; removeEquip.TextSize=11; corner(removeEquip,9); stroke(removeEquip,pcolor("line",lineColor),.35,1)
        local equipButtons={}
        local activeWornEquippable=nil

        local function clearWornEquippable()
            if activeWornEquippable and activeWornEquippable.Parent then
                pcall(function() activeWornEquippable:Destroy() end)
            end
            activeWornEquippable=nil
            local char=lp.Character
            if char then
                for _,ch in ipairs(char:GetChildren()) do
                    if ch:GetAttribute("KimqWornEquippable") then
                        pcall(function() ch:Destroy() end)
                    end
                end
            end
        end

        local function clearLocalEquippables()
            clearWornEquippable()
            local function clean(container)
                if not container then return end
                for _,ch in ipairs(container:GetChildren()) do
                    if ch:IsA("Tool") and ch:GetAttribute("KimqLocalEquippable") then
                        ch:Destroy()
                    end
                end
            end
            clean(lp.Character); clean(lp:FindFirstChildOfClass("Backpack"))
        end

        local function findMatchingBodyAttachment(handle,char)
            if not handle or not char then return nil,nil end
            -- Prefer a matching authored attachment when the model has one.
            for _,a in ipairs(handle:GetDescendants()) do
                if a:IsA("Attachment") then
                    local target=char:FindFirstChild(a.Name,true)
                    if target and target:IsA("Attachment") and target.Parent and target.Parent:IsA("BasePart") then
                        return a,target
                    end
                end
            end
            return nil,nil
        end

        -- Angel Wings fit only moves the ROOT Handle. The original Handle -> wing
        -- Motor6Ds (and their authored C0/C1 values) are never rewritten.
        local WING_FIT_PATH = "KimqetrasHC/angel_wings_fit.json"
        local wingFitDefault={X=0,Y=0.12,Z=0.30,RX=0,RY=0,RZ=0}
        local wingFit={X=wingFitDefault.X,Y=wingFitDefault.Y,Z=wingFitDefault.Z,RX=0,RY=0,RZ=0}

        local function wingFitCFrame()
            return CFrame.new(wingFit.X,wingFit.Y,wingFit.Z) * CFrame.Angles(math.rad(wingFit.RX),math.rad(wingFit.RY),math.rad(wingFit.RZ))
        end
        local function ensureWingFitFolder()
            if type(isfolder)~="function" or type(makefolder)~="function" then return false end
            pcall(function() if not isfolder("KimqetrasHC") then makefolder("KimqetrasHC") end end)
            local ok,v=pcall(isfolder,"KimqetrasHC")
            return ok and v==true
        end
        local function loadWingFitDisk()
            if type(isfile)~="function" or type(readfile)~="function" then return false end
            local okExists,exists=pcall(isfile,WING_FIT_PATH); if not okExists or not exists then return false end
            local okRaw,raw=pcall(readfile,WING_FIT_PATH); if not okRaw or type(raw)~="string" then return false end
            local okData,data=pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
            if not okData or type(data)~="table" then return false end
            for _,k in ipairs({"X","Y","Z","RX","RY","RZ"}) do
                local n=tonumber(data[k]); if n then wingFit[k]=n end
            end
            return true
        end
        local function saveWingFitDisk()
            if not ensureWingFitFolder() or type(writefile)~="function" then return false end
            local payload={X=wingFit.X,Y=wingFit.Y,Z=wingFit.Z,RX=wingFit.RX,RY=wingFit.RY,RZ=wingFit.RZ}
            local okJson,json=pcall(function() return game:GetService("HttpService"):JSONEncode(payload) end)
            if not okJson then return false end
            return pcall(writefile,WING_FIT_PATH,json)
        end
        loadWingFitDisk()

        local function prepareAngelWingsClone(visual)
            -- Preserve the full object hierarchy and every Motor6D/Animation/Humanoid.
            -- Scripts are kept in the clone (not destroyed) but disabled so a local cosmetic
            -- cannot start duplicate gameplay loops.
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("LocalScript") or d:IsA("Script") then
                    pcall(function() d.Disabled=true end); pcall(function() d.Enabled=false end)
                elseif d:IsA("BasePart") then
                    d.Anchored=false; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false; d.Massless=true
                    pcall(function() d.AssemblyLinearVelocity=Vector3.zero; d.AssemblyAngularVelocity=Vector3.zero end)
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
                    pcall(function() d.Enabled=true end)
                end
            end
        end

        local function applyWingFitToCurrent()
            local visual=activeWornEquippable
            if not visual or not visual.Parent then
                local char=lp.Character
                visual=char and char:FindFirstChild("KimqWornAngelWings")
            end
            if not visual then return false end
            local handle=visual:FindFirstChild("Handle",true)
            if not (handle and handle:IsA("BasePart")) then return false end
            local root=handle:FindFirstChild("KimqAngelWingsRoot")
            if root and root:IsA("Motor6D") then
                root.C0=wingFitCFrame(); root.C1=CFrame.new()
                return true
            end
            return false
        end

        local function markWingRigSafe(visual)
            -- Keep the mini-rig that ships with Angel Wings intact.  Its Humanoid / Animator
            -- is what drives the authored Motor6Ds, so deleting it makes some wing poses,
            -- halo effects, and animation tracks stop working.
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("Humanoid") then
                    pcall(function() d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end)
                    pcall(function() d.NameDisplayDistance=0 end)
                    pcall(function() d.HealthDisplayDistance=0 end)
                    pcall(function() d.BreakJointsOnDeath=false end)
                    pcall(function() d.RequiresNeck=false end)
                    pcall(function() d.AutoRotate=false end)
                elseif d:IsA("BasePart") then
                    d.Anchored=true
                    d.CanCollide=false
                    d.CanTouch=false
                    d.CanQuery=false
                    d.Massless=true
                    d.LocalTransparencyModifier=0
                    pcall(function()
                        d.AssemblyLinearVelocity=Vector3.zero
                        d.AssemblyAngularVelocity=Vector3.zero
                    end)
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
                    pcall(function() d.Enabled=true end)
                elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    pcall(function() d.Enabled=true end)
                end
            end
        end

        local function revealWingHalo(visual)
            -- Some versions of Angel Wings keep the halo/effect carrier almost transparent
            -- in storage and reveal it when equipped. Reveal only objects whose name/parent
            -- identifies them as halo visuals; the invisible body Handle stays hidden below.
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("BasePart") then
                    local n=tostring(d.Name):lower()
                    local par=tostring(d.Parent and d.Parent.Name or ""):lower()
                    if n:find("halo",1,true) or par:find("halo",1,true) then
                        d.LocalTransparencyModifier=0
                        if d.Transparency>=.95 then pcall(function() d.Transparency=0 end) end
                    end
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
                    local n=tostring(d.Name):lower()
                    local par=tostring(d.Parent and d.Parent.Name or ""):lower()
                    if n:find("halo",1,true) or par:find("halo",1,true) then
                        pcall(function() d.Enabled=true end)
                    end
                end
            end
        end

        local function attachNestedAccessoryToCharacter(acc,char)
            if not acc or not acc:IsA("Accessory") or not char then return false end
            local h=acc:FindFirstChild("Handle")
            if not (h and h:IsA("BasePart")) then return false end
            local bestBody,bestBodyAtt,bestHandleAtt=nil,nil,nil
            for _,a in ipairs(h:GetDescendants()) do
                if a:IsA("Attachment") then
                    local target=char:FindFirstChild(a.Name,true)
                    if target and target:IsA("Attachment") and target.Parent and target.Parent:IsA("BasePart") then
                        bestBody=target.Parent; bestBodyAtt=target; bestHandleAtt=a; break
                    end
                end
            end
            if not bestBody then
                local low=tostring(acc.Name):lower()
                if low:find("halo",1,true) then
                    bestBody=char:FindFirstChild("Head")
                    if bestBody and bestBody:IsA("BasePart") then
                        acc.Parent=char
                        h.CFrame=bestBody.CFrame*CFrame.new(0,0.85,0)
                        local w=Instance.new("WeldConstraint")
                        w.Name="KimqHaloWeld"; w.Part0=bestBody; w.Part1=h; w.Parent=h
                        acc:SetAttribute("KimqWornEquippable",true)
                        h.CanCollide=false; h.CanTouch=false; h.CanQuery=false; h.Massless=true; h.Anchored=false
                        return true
                    end
                end
                return false
            end
            acc.Parent=char
            h.CFrame=bestBody.CFrame*bestBodyAtt.CFrame*bestHandleAtt.CFrame:Inverse()
            local w=Instance.new("Weld")
            w.Name="KimqWingAccessoryWeld"; w.Part0=bestBody; w.Part1=h
            w.C0=bestBodyAtt.CFrame; w.C1=bestHandleAtt.CFrame; w.Parent=h
            acc:SetAttribute("KimqWornEquippable",true)
            h.CanCollide=false; h.CanTouch=false; h.CanQuery=false; h.Massless=true; h.Anchored=false
            return true
        end

        local function makeAngelWingsWearable(source,tool)
            local char=lp.Character
            if not char then return false,"Character was not ready" end

            clearWornEquippable()

            -- Clone the complete authored mini-rig and keep all original Motor6Ds intact.
            local visual=source:Clone()
            visual.Name="KimqWornAngelWings"
            visual:SetAttribute("KimqWornEquippable",true)
            prepareAngelWingsClone(visual)
            markWingRigSafe(visual)
            revealWingHalo(visual)

            local handle=visual:FindFirstChild("Handle",true)
            if not (handle and handle:IsA("BasePart")) then handle=firstPart(visual) end
            local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            if not handle or not torso or not torso:IsA("BasePart") then
                visual:Destroy()
                return false,"Angel Wings could not find a body attachment"
            end

            -- The rectangular Handle is only the rig carrier. The real wing meshes stay visible.
            pcall(function()
                handle.Transparency=1
                handle.LocalTransparencyModifier=1
                handle.CastShadow=false
                handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false; handle.Massless=true
            end)

            -- Place the whole assembly near its final location before unanchoring so there is
            -- no one-frame jump. This transformation does NOT touch any Motor6D C0/C1.
            local desiredHandle=torso.CFrame * wingFitCFrame()
            local delta=desiredHandle * handle.CFrame:Inverse()
            if visual:IsA("BasePart") then visual.CFrame=delta*visual.CFrame end
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("BasePart") then d.CFrame=delta*d.CFrame end
            end

            visual.Parent=char

            -- One root Motor6D is the only new rig joint. Everything below Handle is the
            -- game's original authored rig, so wing animation/spacing remains untouched.
            local bodyMotor=Instance.new("Motor6D")
            bodyMotor.Name="KimqAngelWingsRoot"
            bodyMotor.Part0=torso
            bodyMotor.Part1=handle
            bodyMotor.C0=wingFitCFrame()
            bodyMotor.C1=CFrame.new()
            bodyMotor.Parent=handle

            -- If a true nested Accessory exists (for example a halo in another asset revision),
            -- let Roblox-style attachment matching mount that piece to the correct body part.
            local nested={}
            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("Accessory") then table.insert(nested,d) end
            end
            for _,acc in ipairs(nested) do
                pcall(function() attachNestedAccessoryToCharacter(acc,char) end)
            end

            for _,d in ipairs(visual:GetDescendants()) do
                if d:IsA("BasePart") then d.Anchored=false end
            end
            revealWingHalo(visual)

            activeWornEquippable=visual
            if tool and tool.Parent then
                tool:SetAttribute("KimqAngelWingsWorn",true)
                tool.ToolTip="Click to remove Angel Wings"
            end

            -- Keep the original rig driver. If nothing is already playing, start any authored
            -- animation IDs without rebuilding or replacing the wing Motor6Ds.
            task.delay(.12,function()
                if not visual.Parent then return end
                local alreadyPlaying=false
                for _,d in ipairs(visual:GetDescendants()) do
                    if d:IsA("Animator") then
                        local ok,tracks=pcall(function() return d:GetPlayingAnimationTracks() end)
                        if ok and tracks and #tracks>0 then alreadyPlaying=true break end
                    end
                end
                if not alreadyPlaying then pcall(function() playSkinAnimationsFromIds(source,visual) end) end
                pcall(function() applyWingFitToCurrent() end)
                pcall(function() revealWingHalo(visual) end)
            end)
            return true,"Angel Wings are on ♡"
        end

        local function buildAngelWingsTool(source)
            local tool=Instance.new("Tool")
            tool.Name=source.Name
            tool.RequiresHandle=true
            tool.CanBeDropped=false
            tool.ToolTip="Equip, then click to wear Angel Wings"
            tool:SetAttribute("KimqLocalEquippable",true)
            tool:SetAttribute("KimqAngelWingsTool",true)

            local handle=Instance.new("Part")
            handle.Name="Handle"
            handle.Size=Vector3.new(.2,.2,.2)
            handle.Transparency=1
            handle.CanCollide=false
            handle.CanTouch=false
            handle.CanQuery=false
            handle.Massless=true
            handle.CastShadow=false
            handle.Parent=tool

            tool.Activated:Connect(function()
                if tool:GetAttribute("KimqAngelWingsWorn") then
                    clearWornEquippable()
                    tool:SetAttribute("KimqAngelWingsWorn",false)
                    tool.ToolTip="Click to wear Angel Wings"
                    if equipStatus and equipStatus.Parent then
                        equipStatus.Text="Angel Wings removed"
                        equipStatus.TextColor3=pcolor("sub",subColor)
                    end
                else
                    local ok,msg=makeAngelWingsWearable(source,tool)
                    if equipStatus and equipStatus.Parent then
                        equipStatus.Text=msg
                        equipStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
                    end
                    if ok then
                        -- Put the wearable tool back into the hotbar after the click so
                        -- the wings stay worn without leaving an invisible tool in-hand.
                        task.delay(.06,function()
                            local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                            if hum then pcall(function() hum:UnequipTools() end) end
                        end)
                    end
                end
            end)

            return tool
        end

        local function buildLocalEquippable(name)
            clearLocalEquippables()
            if name=="None" then extraState.EquipableItem="None"; return true,"Equippable removed" end
            local root=findFolder({"EquipableItem","EquippableItem","EquipableItems","EquippableItems"})
            local source=root and root:FindFirstChild(name)
            if not source then return false,"Equippable item was not found" end

            local isAngelWings=(source.Name:lower()=="angel wings" or source.Name:lower()=="angelwings")
            local tool

            if isAngelWings then
                -- Angel Wings behaves like a wearable: add the tool to Backpack,
                -- equip it from the Roblox hotbar, then click/tap once to wear it.
                tool=buildAngelWingsTool(source)
            elseif source:IsA("Tool") then
                tool=source:Clone()
            else
                tool=Instance.new("Tool"); tool.Name=source.Name; tool.RequiresHandle=false; tool.CanBeDropped=false
                local visual=source:Clone()
                if visual:IsA("Model") or visual:IsA("Folder") then
                    for _,ch in ipairs(visual:GetChildren()) do ch.Parent=tool end
                    visual:Destroy()
                else
                    visual.Parent=tool
                end
            end

            tool:SetAttribute("KimqLocalEquippable",true); tool.Name=source.Name

            if not isAngelWings then
                sanitizeClone(tool)
                local directHandle=tool:FindFirstChild("Handle")
                if not (directHandle and directHandle:IsA("BasePart")) then
                    local rootPart=firstPart(tool)
                    if rootPart then
                        local fake=Instance.new("Part"); fake.Name="Handle"; fake.Size=Vector3.new(.2,.2,.2); fake.Transparency=1; fake.CanCollide=false; fake.CanTouch=false; fake.CanQuery=false; fake.Massless=true; fake.CFrame=rootPart.CFrame; fake.Parent=tool
                        local w=Instance.new("WeldConstraint",fake); w.Part0=fake; w.Part1=rootPart
                        tool.RequiresHandle=true
                    else
                        tool.RequiresHandle=false
                    end
                else
                    tool.RequiresHandle=true
                end
            end

            local bp=lp:FindFirstChildOfClass("Backpack")
            if not bp then tool:Destroy(); return false,"Backpack was not ready" end
            tool.Parent=bp
            extraState.EquipableItem=name

            if isAngelWings then
                return true,"Angel Wings added — equip it from your inventory, then click to wear"
            end

            task.delay(.12,function()
                if not tool.Parent then return end
                local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(tool) end) end
                task.delay(.08,function()
                    if tool.Parent then pcall(function() playSkinAnimationsFromIds(source,tool) end) end
                end)
            end)
            return true,"Equipped locally: "..name
        end
        local function refreshEquipStyle() styleChoiceButtons(equipButtons,extraState.EquipableItem) end
        local function scanEquipables()
            for _,ch in ipairs(equipList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end; table.clear(equipButtons)
            local root=findFolder({"EquipableItem","EquippableItem","EquipableItems","EquippableItems"}); local names={"None"}
            if root then for _,ch in ipairs(root:GetChildren()) do if ch.Name~="None" then table.insert(names,ch.Name) end end end
            table.sort(names,function(a,b) if a=="None" then return true elseif b=="None" then return false else return a:lower()<b:lower() end end)
            for i,name in ipairs(names) do
                local b=makeGridButton(equipList,name); b.LayoutOrder=i; equipButtons[name]=b
                b.MouseButton1Click:Connect(function()
                    extraState.EquipableItem=name; refreshEquipStyle(); equipStatus.Text="Selected: "..name; equipStatus.TextColor3=pcolor("hot",hotColor)
                    if name=="None" then local ok,msg=buildLocalEquippable("None"); equipStatus.Text=msg; equipStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor) end
                end)
            end
            refreshEquipStyle()
        end
        removeEquip.MouseButton1Click:Connect(function()
            extraState.EquipableItem="None"; local ok,msg=buildLocalEquippable("None"); refreshEquipStyle(); equipStatus.Text=msg; equipStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
        end)
        -- Double-click is unreliable on Roblox buttons, so selecting an item equips it
        -- immediately on the second click while it is already selected.
        local lastEquipClick=nil; local lastEquipTime=0
        equipList.DescendantAdded:Connect(function(ch)
            if not ch:IsA("TextButton") then return end
            ch.MouseButton1Click:Connect(function()
                local name=ch.Text
                if extraState.EquipableItem==name and lastEquipClick==name and os.clock()-lastEquipTime<1.1 and name~="None" then
                    local ok,msg=buildLocalEquippable(name); refreshEquipStyle(); equipStatus.Text=msg; equipStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
                end
                lastEquipClick=name; lastEquipTime=os.clock()
            end)
        end)
        -- A clear explicit equip button is easier than needing the second click.
        local equipNow=Instance.new("TextButton",equipCard); equipNow.Size=UDim2.fromOffset(126,32); equipNow.Position=UDim2.new(1,-272,0,181); equipNow.BackgroundColor3=pcolor("hot",hotColor); equipNow.BorderSizePixel=0; equipNow.Text="equip selected"; equipNow.TextColor3=pcolor("white",Color3.new(1,1,1)); equipNow.Font=Enum.Font.GothamSemibold; equipNow.TextSize=11; corner(equipNow,9)
        equipNow.MouseButton1Click:Connect(function()
            local ok,msg=buildLocalEquippable(extraState.EquipableItem or "None"); refreshEquipStyle(); equipStatus.Text=msg; equipStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
        end)

        -- Angel Wings root-fit calibration. These controls only change the torso -> Handle
        -- Motor6D; they never alter the six original wing Motor6Ds.
        local wingFitCard=card(skinsPage,320); wingFitCard.Name="KimqAngelWingsFitCard"
        txt(wingFitCard,"♥  Angel Wings Fit",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,14,pcolor("text",textColor))
        local wingFitSub=txt(wingFitCard,"Fine-tune where the complete wing rig sits on your back.",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,31),Enum.Font.Gotham,11,pcolor("sub",subColor)); wingFitSub.TextWrapped=true

        local fitValueLabels={}
        local fitRows={
            {"Left / Right","X",.02,false},
            {"Up / Down","Y",.02,false},
            {"Back / Forward","Z",.02,false},
            {"Pitch","RX",2,true},
            {"Yaw","RY",2,true},
            {"Roll","RZ",2,true},
        }
        local function clampWingFit(k,v)
            if k=="X" or k=="Y" or k=="Z" then return math.clamp(v,-3,3) end
            return math.clamp(v,-180,180)
        end
        local function refreshWingFitLabels()
            for _,row in ipairs(fitRows) do
                local key=row[2]; local l=fitValueLabels[key]
                if l and l.Parent then
                    l.Text=row[4] and string.format("%.0f°",wingFit[key]) or string.format("%.2f",wingFit[key])
                end
            end
        end
        local function nudgeWingFit(key,amount)
            wingFit[key]=clampWingFit(key,(tonumber(wingFit[key]) or 0)+amount)
            refreshWingFitLabels()
            applyWingFitToCurrent()
        end
        local function fitButton(parent,textValue,pos)
            local b=Instance.new("TextButton",parent); b.Size=UDim2.fromOffset(30,24); b.Position=pos; b.BackgroundColor3=pcolor("soft",lightColor); b.BorderSizePixel=0; b.Text=textValue; b.TextColor3=pcolor("text",textColor); b.Font=Enum.Font.GothamBold; b.TextSize=14; corner(b,7); stroke(b,pcolor("line",lineColor),.28,1); return b
        end
        for i,row in ipairs(fitRows) do
            local y=58+(i-1)*32
            txt(wingFitCard,row[1],UDim2.new(.52,0,0,24),UDim2.fromOffset(12,y),Enum.Font.GothamSemibold,11,pcolor("text",textColor))
            local minus=fitButton(wingFitCard,"−",UDim2.new(1,-132,0,y))
            local value=txt(wingFitCard,"",UDim2.fromOffset(58,24),UDim2.new(1,-98,0,y),Enum.Font.GothamSemibold,11,pcolor("sub",subColor)); value.TextXAlignment=Enum.TextXAlignment.Center; fitValueLabels[row[2]]=value
            local plus=fitButton(wingFitCard,"+",UDim2.new(1,-38,0,y))
            minus.MouseButton1Click:Connect(function() nudgeWingFit(row[2],-row[3]) end)
            plus.MouseButton1Click:Connect(function() nudgeWingFit(row[2],row[3]) end)
        end
        refreshWingFitLabels()

        local saveFit=Instance.new("TextButton",wingFitCard); saveFit.Size=UDim2.new(.54,-14,0,32); saveFit.Position=UDim2.fromOffset(12,256); saveFit.BackgroundColor3=pcolor("hot",hotColor); saveFit.BorderSizePixel=0; saveFit.Text="♥  Save Wing Position"; saveFit.TextColor3=pcolor("white",Color3.new(1,1,1)); saveFit.Font=Enum.Font.GothamSemibold; saveFit.TextSize=11; corner(saveFit,9)
        local resetFit=Instance.new("TextButton",wingFitCard); resetFit.Size=UDim2.new(.46,-16,0,32); resetFit.Position=UDim2.new(.54,2,0,256); resetFit.BackgroundColor3=pcolor("soft",lightColor); resetFit.BorderSizePixel=0; resetFit.Text="Reset Fit"; resetFit.TextColor3=pcolor("text",textColor); resetFit.Font=Enum.Font.GothamSemibold; resetFit.TextSize=11; corner(resetFit,9); stroke(resetFit,pcolor("line",lineColor),.28,1)
        local fitStatus=txt(wingFitCard,"Saved fit is reused every time Angel Wings are worn.",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,294),Enum.Font.Gotham,10,pcolor("sub",subColor)); fitStatus.TextWrapped=true
        saveFit.MouseButton1Click:Connect(function()
            local ok=saveWingFitDisk()
            fitStatus.Text=ok and "Wing position saved ♡" or "Position applied for this session (file saving unavailable)"
            fitStatus.TextColor3=ok and pcolor("hot",hotColor) or pcolor("sub",subColor)
            applyWingFitToCurrent()
        end)
        resetFit.MouseButton1Click:Connect(function()
            for k,v in pairs(wingFitDefault) do wingFit[k]=v end
            refreshWingFitLabels(); applyWingFitToCurrent()
            fitStatus.Text="Fit reset — adjust it, then save when it looks right"; fitStatus.TextColor3=pcolor("sub",subColor)
        end)

        local function hookKnifeContainer(container)
            if not container or container:GetAttribute("KimqKnifeContainerHook") then return end
            container:SetAttribute("KimqKnifeContainerHook",true)
            container.ChildAdded:Connect(function(ch)
                hookShotTool(ch)
                if ch:IsA("Tool") and ch.Name:lower():find("knife",1,true) and extraState.KnifeSkin and extraState.KnifeSkin~="None" and not ch:FindFirstChild("KimqKnifeSkinVisual") then
                    task.delay(.18,function()
                        if ch.Parent and not ch:FindFirstChild("KimqKnifeSkinVisual") then applyKnifeSkin(extraState.KnifeSkin,true) end
                    end)
                end
            end)
        end
        hookKnifeContainer(lp:FindFirstChildOfClass("Backpack")); if lp.Character then hookKnifeContainer(lp.Character) end
        lp.CharacterAdded:Connect(function(char)
            hookShotContainer(char); hookKnifeContainer(char)
            task.delay(1,function()
                local bp=lp:FindFirstChildOfClass("Backpack"); hookShotContainer(bp); hookKnifeContainer(bp)
                if extraState.KnifeSkin and extraState.KnifeSkin~="None" then applyKnifeSkin(extraState.KnifeSkin,true) end
                if extraState.EquipableItem and extraState.EquipableItem~="None" then buildLocalEquippable(extraState.EquipableItem) end
            end)
        end)

        local function scanAllExtras()
            scanBeams(); scanKnives(); scanEquipables()
            beamList.ScrollBarImageColor3=pcolor("hot",hotColor); knifeList.ScrollBarImageColor3=pcolor("hot",hotColor); equipList.ScrollBarImageColor3=pcolor("hot",hotColor)
        end
        skinsPage:GetPropertyChangedSignal("Visible"):Connect(function() if skinsPage.Visible then task.defer(scanAllExtras) end end)
        task.defer(function()
            -- Lists are populated when Weapon Skins is opened. Avoid three storage scans at startup.
            applyBulletBeamOverride(extraState.BulletBeam or "None")
        end)

        local function getExtraState()
            return {
                BulletBeam=tostring(extraState.BulletBeam or "None"),
                BulletColorMode=tostring(extraState.BulletColorMode or "Preset"),
                BulletColorHex=tostring(extraState.BulletColorHex or "#FF69B4"),
                BulletLightBrightness=tonumber(_G.KimqBulletLightBrightness) or tonumber(extraState.BulletLightBrightness) or 0.65,
                KnifeSkin=tostring(extraState.KnifeSkin or "None"),
                KnifeAccentMode=tostring(extraState.KnifeAccentMode or "Off"),
                EquipableItem=tostring(extraState.EquipableItem or "None"),
                DeathBlood=(extraState.DeathBlood==true),
                DeathHearts=(extraState.DeathHearts==true),
                GunKillEffect=tostring(extraState.GunKillEffect or "Hearts"),
                WingFit={X=wingFit.X,Y=wingFit.Y,Z=wingFit.Z,RX=wingFit.RX,RY=wingFit.RY,RZ=wingFit.RZ},
            }
        end
        local function setExtraState(state)
            if type(state)~="table" then return end
            local oldKnife=tostring(extraState.KnifeSkin or "None")
            local oldKnifeAccent=tostring(extraState.KnifeAccentMode or "Off")
            local oldEquip=tostring(extraState.EquipableItem or "None")
            extraState.BulletBeam=type(state.BulletBeam)=="string" and state.BulletBeam or "None"
            extraState.BulletColorMode=type(state.BulletColorMode)=="string" and state.BulletColorMode or "Preset"
            if extraState.BulletColorMode~="Preset" and extraState.BulletColorMode~="Custom" and extraState.BulletColorMode~="Rainbow" then extraState.BulletColorMode="Preset" end
            local savedHex=type(state.BulletColorHex)=="string" and normalizeHex(state.BulletColorHex) or nil
            if savedHex then
                extraState.BulletColorHex=savedHex
                local c=colorFromHex(savedHex); if c then bulletCustomColor=c; bulletHue,bulletSat,bulletVal=c:ToHSV() end
            end
            local savedBrightness=tonumber(state.BulletLightBrightness)
            if savedBrightness then
                savedBrightness=math.clamp(savedBrightness,0,2.5)
                _G.KimqBulletLightBrightness=savedBrightness
                extraState.BulletLightBrightness=savedBrightness
                local setBrightness=rawget(_G,"KimqSetBulletLightBrightness")
                if type(setBrightness)=="function" then pcall(setBrightness,savedBrightness) end
            end
            extraState.KnifeSkin=type(state.KnifeSkin)=="string" and state.KnifeSkin or "None"
            extraState.KnifeAccentMode=type(state.KnifeAccentMode)=="string" and state.KnifeAccentMode or "Off"
            if extraState.KnifeAccentMode~="Off" and extraState.KnifeAccentMode~="Theme" and extraState.KnifeAccentMode~="Bullet" then extraState.KnifeAccentMode="Off" end
            extraState.EquipableItem=type(state.EquipableItem)=="string" and state.EquipableItem or "None"
            if state.DeathBlood~=nil then extraState.DeathBlood=(state.DeathBlood==true) end
            if state.DeathHearts~=nil then extraState.DeathHearts=(state.DeathHearts==true) end
            if state.GunKillEffect~=nil then
                local mode=tostring(state.GunKillEffect)
                if mode=="Normal" or mode=="Hearts" then extraState.GunKillEffect=mode end
            end
            if type(state.WingFit)=="table" then
                for _,k in ipairs({"X","Y","Z","RX","RY","RZ"}) do
                    local n=tonumber(state.WingFit[k]); if n then wingFit[k]=n end
                end
                if refreshWingFitLabels then pcall(refreshWingFitLabels) end
            end
            task.defer(function()
                if skinsPage.Visible then scanAllExtras() end
                refreshBeamStyle(); refreshKnifeStyle(); refreshKnifeAccentStyle(); refreshEquipStyle(); refreshBulletColorUI()
                applyBulletBeamOverride(extraState.BulletBeam or "None")
                local t=findKnifeTool()
                local needsKnife=(extraState.KnifeSkin~=oldKnife)
                    or (extraState.KnifeSkin~="None" and t and not t:FindFirstChild("KimqKnifeSkinVisual"))
                    or (extraState.KnifeAccentMode~=oldKnifeAccent and extraState.KnifeSkin~="None" and t)
                if needsKnife then
                    if extraState.KnifeSkin~="None" then applyKnifeSkin(extraState.KnifeSkin,true) elseif t then clearKnifeVisual(t) end
                end
                if extraState.EquipableItem~=oldEquip then
                    if extraState.EquipableItem~="None" then buildLocalEquippable(extraState.EquipableItem) else clearLocalEquippables() end
                end
                pcall(function() applyWingFitToCurrent() end)
            end)
        end
        _G.KimqWeaponExtrasController={
            GetState=getExtraState,
            SetState=setExtraState,
            Refresh=scanAllExtras,
            RefreshColor=refreshBulletColorUI,
            ApplyKnife=applyKnifeSkin,
            EquipItem=buildLocalEquippable,
            SpawnDeathBlood=spawnDeathBloodAt,
            SpawnDeathHearts=spawnDeathHeartsAt,
            TestDeathBlood=function()
                local char=lp.Character
                local pos=deathPosition(char)
                if not pos then return false,"Character position was not found" end
                local was=extraState.DeathBlood
                extraState.DeathBlood=true
                local ok=spawnDeathBloodAt(pos)
                extraState.DeathBlood=was
                return ok,ok and "Blood effect tested" or "Blood effect could not spawn"
            end,
            TestDeathHearts=function()
                local char=lp.Character
                local pos=deathPosition(char)
                if not pos then return false,"Character position was not found" end
                local ok=spawnDeathHeartsAt(pos,true)
                return ok,ok and "Heart effect tested" or "Heart effect could not spawn"
            end,
        }
        if type(_G.KimqRegisterConfigControl)=="function" then
            _G.KimqRegisterConfigControl("Weapon Extras", "state", getExtraState, setExtraState)
        end
    end
    local extrasOk,extrasErr=pcall(setupWeaponExtras)
    if not extrasOk then
        _G.KimqWeaponExtrasInstalled=false
        warn("[Kimqetras HC v2.63] restored v2.19 Weapon Extras: "..tostring(extrasErr))
        setStatus("Weapon extras error • "..tostring(extrasErr):sub(1,100),false)
    else
        pcall(function()
            if type(getgenv)=="function" then
                local e=getgenv()
                e.KimqWeaponExtrasInstalled=true
                e.KimqWeaponExtrasController=_G.KimqWeaponExtrasController
                e.KimqWeaponExtrasState=_G.KimqWeaponExtrasState
            end
        end)
    end


    -- v2.67 Weapon Skin Presets --------------------------------------------
    -- Saves/restores the entire local cosmetic setup without guessing any
    -- game-specific skin names: weapon wraps + bullet/beam + knife + equippable.
    local function setupWeaponPresetManager()
        if skinsPage:FindFirstChild("KimqWeaponPresetCard") then return end

        local HttpService=game:GetService("HttpService")
        local PRESET_DIR="KimqetrasHC/weapon_presets"
        _G.KimqWeaponPresetMemory=_G.KimqWeaponPresetMemory or {}
        local mem=_G.KimqWeaponPresetMemory
        local selectedPreset=nil

        local function cleanPresetName(v)
            v=tostring(v or ""):gsub("^%s+",""):gsub("%s+$","")
            v=v:gsub("[^%w%s_%-%(%)%[%]]","")
            v=v:gsub("%s+"," ")
            if v=="" then v="Angel" end
            return v:sub(1,42)
        end

        local function ensurePresetDir()
            if type(isfolder)=="function" and type(makefolder)=="function" then
                pcall(function()
                    if not isfolder("KimqetrasHC") then makefolder("KimqetrasHC") end
                    if not isfolder(PRESET_DIR) then makefolder(PRESET_DIR) end
                end)
            end
        end

        local function presetPath(name)
            return PRESET_DIR.."/"..cleanPresetName(name)..".json"
        end

        local function capturePreset()
            local skinsCtl=_G.KimqWeaponSkinController
            local extrasCtl=_G.KimqWeaponExtrasController
            return {
                version=1,
                skins=(skinsCtl and skinsCtl.GetState and skinsCtl.GetState()) or {},
                extras=(extrasCtl and extrasCtl.GetState and extrasCtl.GetState()) or {},
            }
        end

        local function savePreset(name)
            name=cleanPresetName(name)
            local ok,json=pcall(HttpService.JSONEncode,HttpService,capturePreset())
            if not ok then return false,"Could not encode preset" end

            ensurePresetDir()
            local wrote=false
            if type(writefile)=="function" then
                wrote=pcall(writefile,presetPath(name),json)
            end
            if not wrote then mem[name]=json end
            return true,"Saved ♥ "..name
        end

        local function readPreset(name)
            name=cleanPresetName(name)
            local p=presetPath(name)
            if type(isfile)=="function" and type(readfile)=="function" then
                local ok,exists=pcall(isfile,p)
                if ok and exists then
                    local okRead,data=pcall(readfile,p)
                    if okRead and data then return data end
                end
            end
            return mem[name]
        end

        local function loadPreset(name)
            name=cleanPresetName(name)
            local raw=readPreset(name)
            if not raw then return false,"Preset not found" end
            local ok,data=pcall(HttpService.JSONDecode,HttpService,raw)
            if not ok or type(data)~="table" then return false,"Preset could not be read" end

            local skinsCtl=_G.KimqWeaponSkinController
            local extrasCtl=_G.KimqWeaponExtrasController
            if skinsCtl and skinsCtl.SetState then pcall(skinsCtl.SetState,data.skins or {}) end
            if extrasCtl and extrasCtl.SetState then pcall(extrasCtl.SetState,data.extras or {}) end
            return true,"Loaded ♥ "..name
        end

        local function deletePreset(name)
            name=cleanPresetName(name)
            local removed=false
            local p=presetPath(name)
            if type(isfile)=="function" and type(delfile)=="function" then
                local ok,exists=pcall(isfile,p)
                if ok and exists then removed=pcall(delfile,p) or removed end
            end
            if mem[name] then mem[name]=nil; removed=true end
            return removed
        end

        local function listPresets()
            local seen,out={},{}
            local function add(name)
                name=cleanPresetName(name)
                if name~="" and not seen[name] then seen[name]=true; table.insert(out,name) end
            end
            ensurePresetDir()
            if type(listfiles)=="function" then
                local ok,files=pcall(listfiles,PRESET_DIR)
                if ok and type(files)=="table" then
                    for _,p in ipairs(files) do
                        local n=tostring(p):match("([^/\\]+)%.json$")
                        if n then add(n) end
                    end
                end
            end
            for n in pairs(mem) do add(n) end
            table.sort(out,function(a,b) return a:lower()<b:lower() end)
            return out
        end

        local p=_G.KimqThemeLivePalette or {}
        local presetCard=card(skinsPage,244)
        presetCard.Name="KimqWeaponPresetCard"

        local title=txt(presetCard,"♥  weapon skin presets",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,8),Enum.Font.GothamBold,18,p.hot or hotColor)
        local sub=txt(presetCard,"Save a whole cosmetic combo: wraps + bullets + beam + knife + equippable.",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,34),Enum.Font.Gotham,10,p.sub or subColor)

        local nameBox=Instance.new("TextBox",presetCard)
        nameBox.Name="KimqWeaponPresetName"
        nameBox.Size=UDim2.new(1,-24,0,32)
        nameBox.Position=UDim2.fromOffset(12,59)
        nameBox.BackgroundColor3=p.soft or lightColor
        nameBox.BorderSizePixel=0
        nameBox.PlaceholderText="preset name...  (ex: Angel)"
        nameBox.PlaceholderColor3=p.sub or subColor
        nameBox.Text=""
        nameBox.TextColor3=p.text or textColor
        nameBox.Font=Enum.Font.GothamSemibold
        nameBox.TextSize=11
        corner(nameBox,9)
        stroke(nameBox,p.line or lineColor,.30,1)

        local list=Instance.new("ScrollingFrame",presetCard)
        list.Name="KimqWeaponPresetList"
        list.Size=UDim2.new(1,-24,0,78)
        list.Position=UDim2.fromOffset(12,98)
        list.BackgroundTransparency=1
        list.BorderSizePixel=0
        list.ScrollBarThickness=3
        list.ScrollBarImageColor3=p.hot or hotColor
        local ll=Instance.new("UIListLayout",list)
        ll.Padding=UDim.new(0,5)
        ll.SortOrder=Enum.SortOrder.LayoutOrder
        ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+6)
        end)

        local status=txt(presetCard,"pick or save a preset ♡",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,216),Enum.Font.Gotham,9,p.sub or subColor)

        local saveBtn=Instance.new("TextButton",presetCard)
        saveBtn.Size=UDim2.new(.34,-10,0,30); saveBtn.Position=UDim2.fromOffset(12,181)
        local loadBtn=Instance.new("TextButton",presetCard)
        loadBtn.Size=UDim2.new(.33,-8,0,30); loadBtn.Position=UDim2.new(.34,4,0,181)
        local deleteBtn=Instance.new("TextButton",presetCard)
        deleteBtn.Size=UDim2.new(.33,-10,0,30); deleteBtn.Position=UDim2.new(.67,2,0,181)

        local presetButtons={}
        local function styleAction(b,text)
            local pp=_G.KimqThemeLivePalette or {}
            b.BackgroundColor3=pp.soft or lightColor
            b.BorderSizePixel=0
            b.Text=text
            b.TextColor3=pp.hot or hotColor
            b.Font=Enum.Font.GothamBold
            b.TextSize=10
            b.AutoButtonColor=false
            corner(b,9)
            stroke(b,pp.line or lineColor,.3,1)
        end
        styleAction(saveBtn,"♥ Save Current")
        styleAction(loadBtn,"Load")
        styleAction(deleteBtn,"Delete")

        local function refreshPresetTheme()
            local pp=_G.KimqThemeLivePalette or {}
            presetCard.BackgroundColor3=pp.panel or panelColor
            local st=presetCard:FindFirstChildOfClass("UIStroke"); if st then st.Color=pp.line or lineColor end
            title.TextColor3=pp.hot or hotColor
            sub.TextColor3=pp.sub or subColor
            nameBox.BackgroundColor3=pp.soft or lightColor
            nameBox.TextColor3=pp.text or textColor
            nameBox.PlaceholderColor3=pp.sub or subColor
            local nst=nameBox:FindFirstChildOfClass("UIStroke"); if nst then nst.Color=pp.line or lineColor end
            list.ScrollBarImageColor3=pp.hot or hotColor
            status.TextColor3=pp.sub or subColor
            for _,b in ipairs({saveBtn,loadBtn,deleteBtn}) do
                b.BackgroundColor3=pp.soft or lightColor
                b.TextColor3=pp.hot or hotColor
                local bst=b:FindFirstChildOfClass("UIStroke"); if bst then bst.Color=pp.line or lineColor end
            end
            for _,child in ipairs(list:GetChildren()) do
                if child:IsA("TextLabel") then child.TextColor3=pp.sub or subColor end
            end
            for name,b in pairs(presetButtons) do
                local on=name==selectedPreset
                b.BackgroundColor3=on and (pp.hot or hotColor) or (pp.soft or lightColor)
                b.TextColor3=on and (pp.white or Color3.new(1,1,1)) or (pp.text or textColor)
                local bst=b:FindFirstChildOfClass("UIStroke")
                if bst then bst.Color=on and (pp.hot or hotColor) or (pp.line or lineColor) end
            end
        end
        _G.KimqRefreshWeaponPresetTheme=refreshPresetTheme

        local refreshList
        refreshList=function()
            for _,ch in ipairs(list:GetChildren()) do
                if ch:IsA("TextButton") or ch:IsA("TextLabel") then ch:Destroy() end
            end
            table.clear(presetButtons)
            local names=listPresets()
            if #names==0 then
                local empty=txt(list,"no weapon presets yet ♡",UDim2.new(1,-4,0,28),UDim2.new(),Enum.Font.Gotham,9,(_G.KimqThemeLivePalette or {}).sub or subColor)
                empty.LayoutOrder=1
            else
                for i,name in ipairs(names) do
                    local b=Instance.new("TextButton",list)
                    b.LayoutOrder=i
                    b.Size=UDim2.new(1,-2,0,28)
                    b.BorderSizePixel=0
                    b.Text="♡  "..name
                    b.TextXAlignment=Enum.TextXAlignment.Left
                    b.Font=Enum.Font.GothamSemibold
                    b.TextSize=10
                    b.AutoButtonColor=false
                    corner(b,8)
                    stroke(b,(_G.KimqThemeLivePalette or {}).line or lineColor,.35,1)
                    local pad=Instance.new("UIPadding",b); pad.PaddingLeft=UDim.new(0,9)
                    b.MouseButton1Click:Connect(function()
                        selectedPreset=name
                        nameBox.Text=name
                        status.Text="selected ♥ "..name
                        refreshPresetTheme()
                    end)
                    presetButtons[name]=b
                end
            end
            refreshPresetTheme()
        end

        saveBtn.MouseButton1Click:Connect(function()
            local name=cleanPresetName(nameBox.Text)
            nameBox.Text=name
            local ok,msg=savePreset(name)
            status.Text=msg
            if ok then selectedPreset=name; refreshList() end
        end)
        loadBtn.MouseButton1Click:Connect(function()
            local name=selectedPreset or cleanPresetName(nameBox.Text)
            local ok,msg=loadPreset(name)
            status.Text=msg
            if ok then selectedPreset=name; nameBox.Text=name end
            refreshPresetTheme()
        end)
        deleteBtn.MouseButton1Click:Connect(function()
            local name=selectedPreset or cleanPresetName(nameBox.Text)
            if deletePreset(name) then
                status.Text="Deleted "..name
                if selectedPreset==name then selectedPreset=nil end
                refreshList()
            else
                status.Text="Preset not found"
            end
        end)

        refreshList()
    end
    local weaponPresetOK,weaponPresetERR=pcall(setupWeaponPresetManager)
    if not weaponPresetOK then warn("[Kimqetras HC v2.67 weapon presets] "..tostring(weaponPresetERR)) end

    local function installBulletBrightnessUI()
        local colorCard=skinsPage:FindFirstChild("KimqBulletColorCard")
        if not colorCard or colorCard:FindFirstChild("KimqBulletBrightnessUI") then return end

        local holder=Instance.new("Frame",colorCard)
        holder.Name="KimqBulletBrightnessUI"
        holder.Size=UDim2.new(1,-24,0,58)
        holder.Position=UDim2.fromOffset(12,264)
        holder.BackgroundTransparency=1
        colorCard.Size=UDim2.new(colorCard.Size.X.Scale,colorCard.Size.X.Offset,0,334)

        local p=_G.KimqThemeLivePalette or {}
        local label=Instance.new("TextLabel",holder)
        label.Size=UDim2.new(.72,0,0,22)
        label.BackgroundTransparency=1
        label.Text="Bullet Light Brightness"
        label.TextColor3=p.text or textColor
        label.Font=Enum.Font.GothamBold
        label.TextSize=11
        label.TextXAlignment=Enum.TextXAlignment.Left

        local value=Instance.new("TextLabel",holder)
        value.Size=UDim2.new(.28,-4,0,22)
        value.Position=UDim2.new(.72,4,0,0)
        value.BackgroundTransparency=1
        value.TextColor3=p.hot or hotColor
        value.Font=Enum.Font.GothamSemibold
        value.TextSize=11
        value.TextXAlignment=Enum.TextXAlignment.Right

        local bar=Instance.new("Frame",holder)
        bar.Name="BulletBrightnessBar"
        bar.Size=UDim2.new(1,0,0,10)
        bar.Position=UDim2.fromOffset(0,31)
        bar.BackgroundColor3=p.soft or lightColor
        bar.BorderSizePixel=0
        bar.Active=true
        corner(bar,999)
        stroke(bar,p.line or lineColor,.35,1)

        local fill=Instance.new("Frame",bar)
        fill.Name="BulletBrightnessFill"
        fill.Size=UDim2.new(0,0,1,0)
        fill.BackgroundColor3=p.hot or hotColor
        fill.BorderSizePixel=0
        corner(fill,999)

        local hit=Instance.new("TextButton",bar)
        hit.Size=UDim2.fromScale(1,1)
        hit.BackgroundTransparency=1
        hit.Text=""
        hit.ZIndex=5

        local function repaint()
            local pal=_G.KimqThemeLivePalette or {}
            label.TextColor3=pal.text or textColor
            value.TextColor3=pal.hot or hotColor
            bar.BackgroundColor3=pal.soft or lightColor
            fill.BackgroundColor3=pal.hot or hotColor
            local st=bar:FindFirstChildOfClass("UIStroke")
            if st then st.Color=pal.line or lineColor end
        end

        local function setGlow(v)
            v=math.clamp(tonumber(v) or 0.65,0,2.5)
            _G.KimqBulletLightBrightness=v
            if _G.KimqWeaponExtrasState then _G.KimqWeaponExtrasState.BulletLightBrightness=v end
            value.Text=tostring(math.floor(v*100+.5)).."%"
            fill.Size=UDim2.new(v/2.5,0,1,0)
            local refreshTemplates=rawget(_G,"KimqRefreshBulletTemplates")
            if type(refreshTemplates)=="function" then pcall(refreshTemplates) end
        end

        _G.KimqSetBulletLightBrightness=setGlow

        local dragging=false
        local UIS2=game:GetService("UserInputService")
        local function update(input)
            local x=math.clamp((input.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
            setGlow(x*2.5)
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; update(i)
            end
        end)
        UIS2.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i) end
        end)
        UIS2.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)

        if type(_G.KimqRegisterConfigControl)=="function" then
            _G.KimqRegisterConfigControl("Bullet Light Brightness","decimal",
                function() return tonumber(_G.KimqBulletLightBrightness) or 0.65 end,
                function(v) setGlow(v) end)
        end

        setGlow(_G.KimqBulletLightBrightness)
        repaint()
        local badgeNow=badge
        if badgeNow then
            badgeNow:GetPropertyChangedSignal("BackgroundColor3"):Connect(function() task.defer(repaint) end)
        end
    end
    pcall(installBulletBrightnessUI)

    -- ========================================================
    -- v2.62 ISOLATED ANGEL WINGS FLIGHT
    -- This is intentionally outside setupWeaponExtras().
    -- If flight/animation ever errors, Knives / Equippables / Bullet Beams
    -- have already been created by the restored v2.19 core.
    -- ========================================================
    task.spawn(function()
        local UIS2=game:GetService("UserInputService")
        local RunService2=game:GetService("RunService")
        local CoreGui2=game:GetService("CoreGui")
        local playerGui2=lp:FindFirstChildOfClass("PlayerGui")

        local flightEnabled=true
        local flightActive=false
        local flightSpeed=46
        local lastSpace=0
        local bv,bg,flightConn=nil,nil,nil
        local animTrack=nil
        local mini=nil

        local function livePalette()
            local p=_G.KimqThemeLivePalette
            if type(p)=="table" then return p end
            return {
                bg=panelColor,soft=lightColor,hot=hotColor,text=textColor,
                sub=subColor,line=lineColor,white=Color3.new(1,1,1)
            }
        end

        local function wingsModel()
            local char=lp.Character
            return char and char:FindFirstChild("KimqWornAngelWings")
        end

        local function stopAnim()
            if animTrack then pcall(function() animTrack:Stop(.12) end) end
            animTrack=nil
        end

        local function playFlightAnim()
            stopAnim()
            local char=lp.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            pcall(function()
                local ok,track=pcall(function()
                    return hum:PlayEmoteAndGetAnimTrackById(100607985396998)
                end)
                if ok and track then
                    animTrack=track
                    pcall(function() track.Looped=true; track:Play(.12,1,1) end)
                end
            end)
            if animTrack then return end

            local resolved="rbxassetid://100607985396998"
            pcall(function()
                local objs=game:GetObjects("rbxassetid://100607985396998")
                for _,obj in ipairs(objs) do
                    local a=obj:IsA("Animation") and obj or obj:FindFirstChildWhichIsA("Animation",true)
                    if a and tostring(a.AnimationId or "")~="" then
                        resolved=a.AnimationId
                        break
                    end
                end
                for _,obj in ipairs(objs) do pcall(function() obj:Destroy() end) end
            end)

            local animator=hum:FindFirstChildOfClass("Animator")
            if not animator then
                animator=Instance.new("Animator")
                animator.Parent=hum
            end
            local a=Instance.new("Animation")
            a.AnimationId=resolved
            local ok,track=pcall(function() return animator:LoadAnimation(a) end)
            a:Destroy()
            if ok and track then
                animTrack=track
                pcall(function()
                    track.Looped=true
                    track.Priority=Enum.AnimationPriority.Action
                    track:Play(.12,1,1)
                end)
            end
        end

        local function cleanupFlight()
            flightActive=false
            if flightConn then pcall(function() flightConn:Disconnect() end) end
            flightConn=nil
            if bv then pcall(function() bv:Destroy() end) end
            if bg then pcall(function() bg:Destroy() end) end
            bv=nil; bg=nil
            stopAnim()
            local char=lp.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.AutoRotate=true end) end
        end

        local function removeWingMini()
            if mini then pcall(function() mini:Destroy() end); mini=nil end
            for _,parent in ipairs({CoreGui2,playerGui2}) do
                if parent then
                    for _,old in ipairs(parent:GetChildren()) do
                        if old.Name=="KimqAngelWingsMini" then pcall(function() old:Destroy() end) end
                    end
                end
            end
        end

        local function updateMini()
            removeWingMini()
        end

        local function makeMini()
            removeWingMini()
        end

        local function startFlight()
            if not flightEnabled or not wingsModel() or flightActive then return end
            local char=lp.Character
            local root=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end

            flightActive=true
            hum.AutoRotate=false

            bv=Instance.new("BodyVelocity")
            bv.Name="KimqWingFlightVelocity"
            bv.MaxForce=Vector3.new(1e6,1e6,1e6)
            bv.P=15000
            bv.Velocity=Vector3.zero
            bv.Parent=root

            bg=Instance.new("BodyGyro")
            bg.Name="KimqWingFlightGyro"
            bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
            bg.P=18000
            bg.D=650
            bg.CFrame=root.CFrame
            bg.Parent=root

            playFlightAnim()

            flightConn=RunService2.RenderStepped:Connect(function()
                if not wingsModel() or not root.Parent or not hum.Parent then
                    cleanupFlight(); updateMini(); return
                end
                local cam=workspace.CurrentCamera
                local move=hum.MoveDirection
                local vertical=0
                if UIS2:IsKeyDown(Enum.KeyCode.Space) then vertical+=1 end
                if UIS2:IsKeyDown(Enum.KeyCode.LeftControl) or UIS2:IsKeyDown(Enum.KeyCode.C) then vertical-=1 end

                local planar=move
                if planar.Magnitude>1 then planar=planar.Unit end
                bv.Velocity=planar*flightSpeed + Vector3.new(0,vertical*flightSpeed*.65,0)

                if cam then
                    local look=cam.CFrame.LookVector
                    local flat=Vector3.new(look.X,0,look.Z)
                    if flat.Magnitude>.01 then
                        bg.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit)
                    end
                end
            end)
            updateMini()
        end

        local function toggleFlight()
            if flightActive then cleanupFlight() else startFlight() end
            updateMini()
        end

        UIS2.InputBegan:Connect(function(input,gpe)
            if gpe or input.KeyCode~=Enum.KeyCode.Space or not wingsModel() then return end
            local now=os.clock()
            if now-lastSpace<=.42 then
                lastSpace=0
                toggleFlight()
            else
                lastSpace=now
            end
        end)

        local function watchCharacter(char)
            cleanupFlight()
            if mini then pcall(function() mini:Destroy() end); mini=nil end

            local function check()
                if char~=lp.Character then return end
                if char:FindFirstChild("KimqWornAngelWings") then
                    makeMini()
                else
                    cleanupFlight()
                    if mini then pcall(function() mini:Destroy() end); mini=nil end
                end
            end

            char.ChildAdded:Connect(function(ch)
                if ch.Name=="KimqWornAngelWings" then task.defer(check) end
            end)
            char.ChildRemoved:Connect(function(ch)
                if ch.Name=="KimqWornAngelWings" then task.defer(check) end
            end)
            task.defer(check)
        end

        if lp.Character then watchCharacter(lp.Character) end
        lp.CharacterAdded:Connect(watchCharacter)

        _G.KimqRefreshWingMiniTheme=updateMini
    end)

    -- Canonical navigation owns page switching. Weapon discovery stays lazy and
    -- only runs when the user actually opens Weapon Skins.
    skinsBtn.MouseButton1Click:Connect(function()
        task.defer(function()
            scanWeapons()
            local extras=_G.KimqWeaponExtrasController
            if extras and type(extras.Refresh)=="function" then
                local ok,err=pcall(extras.Refresh)
                if not ok then
                    warn("[Kimqetras HC v2.63] extras refresh: "..tostring(err))
                    setStatus("Extras refresh failed • "..tostring(err):sub(1,90),false)
                end
            end
        end)
    end)

    local function syncTheme()
        panelColor,lineColor,hotColor,lightColor,textColor,subColor=sampleTheme()
        skinsPage.ScrollBarImageColor3=hotColor
        weaponList.ScrollBarImageColor3=hotColor
        skinList.ScrollBarImageColor3=hotColor
        wiTitle.TextColor3=hotColor
        wiSub.TextColor3=subColor
        for _,f in ipairs({wi,weaponCard,skinCard,actions,statusCard}) do
            f.BackgroundColor3=panelColor
            local s=f:FindFirstChildOfClass("UIStroke")
            if s then s.Color=lineColor end
        end
        refresh.BackgroundColor3=lightColor
        refresh.TextColor3=textColor
        apply.BackgroundColor3=hotColor
        reset.BackgroundColor3=lightColor
        reset.TextColor3=textColor
        refreshWeaponStyle()
        refreshSkinStyle()
        if _G.KimqWeaponExtrasController and _G.KimqWeaponExtrasController.RefreshColor then
            _G.KimqWeaponExtrasController.RefreshColor()
        end
    end
    if badge then badge:GetPropertyChangedSignal("BackgroundColor3"):Connect(function() task.defer(syncTheme) end) end
    syncTheme()

    -- Do not recursively scan the game at startup. Weapon folders are scanned when the page is opened or Refresh is pressed.
    setStatus("Open Weapon Skins to scan your Wraps folder", true)

    setProgress("ready ♡",1)
    _G.KimqV26FeaturesReady=true
end)




-- v2.1 final GUI: matcha + light pink + white, hearts only, no stitching.
task.spawn(function()
    local Players=game:GetService("Players")
    local CoreGui=game:GetService("CoreGui")
    local TweenService=game:GetService("TweenService")
    local lp=Players.LocalPlayer
    local pg=lp:WaitForChild("PlayerGui")

    local t0=tick()
    while (not _G.KimqV26FeaturesReady or not _G.KimqPageRepairReady) and tick()-t0<12 do
        task.wait(.03)
    end
    local root=CoreGui:FindFirstChild("KimpetrasHC") or pg:FindFirstChild("KimpetrasHC")
    local main=root and root:FindFirstChild("Main")
    local loader=_G.KimqV26Loader
    if not root or not main then
        _G.KimqV26Ready=true
        if loader and loader.Gui then pcall(function() loader.Gui:Destroy() end) end
        return
    end
    root.Enabled=false
    main.Visible=false

    if main:FindFirstChild("KimqV21SingleMarker") then
        _G.KimqV26Ready=true; main.Visible=(_G.KimqMainUserVisibleState~=false)
        if loader and loader.Gui then pcall(function() loader.Gui:Destroy() end) end
        return
    end
    local marker=Instance.new("BoolValue",main); marker.Name="KimqV21SingleMarker"

    local function norm(s)
        s=tostring(s or ""):lower()
        s=s:gsub("[♥♡✦✧◇◆♢⌂⌖⚡♧☁❄◉◎○□⚙✕♨↓◷]","")
        s=s:gsub("%s+"," ")
        return (s:gsub("^%s+",""):gsub("%s+$",""))
    end
    local function corner(o,r)
        local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner",o); c.CornerRadius=UDim.new(0,r or 10); return c
    end
    local function stroke(o,color,transparency,thickness)
        local s=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",o); s.Color=color; s.Transparency=transparency or .3; s.Thickness=thickness or 1; return s
    end
    local function role(o,r)
        if o then o:SetAttribute("KimqV26Role",r) end
        return o
    end
    local function label(parent,text,size,pos,font,sz,color,align)
        local l=Instance.new("TextLabel",parent); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=text; l.Font=font; l.TextSize=sz; l.TextColor3=color; l.TextWrapped=true; l.TextXAlignment=align or Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Center; return l
    end
    local function paw(parent,pos,size,color,rotation,z)
        -- Kept under the old helper name so legacy layout calls stay intact,
        -- but the visual motif is now a simple heart instead of a paw decal.
        local h=Instance.new("TextLabel",parent)
        h.Name="V26Heart"
        h.AnchorPoint=Vector2.new(.5,.5)
        h.Position=pos
        h.Size=UDim2.fromOffset(size,size)
        h.BackgroundTransparency=1
        h.Text="♥"
        h.TextColor3=color
        h.Font=Enum.Font.GothamBold
        h.TextSize=math.max(12,math.floor(size*.72))
        h.Rotation=rotation or 0
        h.ZIndex=z or parent.ZIndex+2
        role(h,"hotText")
        return h
    end
    local function stitches(parent,inset,P,name)
        -- V26 single build intentionally has no stitched-border overlay.
        local old=parent:FindFirstChild(name or "V26Stitches")
        if old then old:Destroy() end
        return nil
    end

    local badge
    for _,d in ipairs(main:GetDescendants()) do if d:IsA("TextLabel") and tostring(d.Text or ""):match("^[Vv]%d") then badge=d break end end
    local function forceBadge()
        for _,d in ipairs(main:GetDescendants()) do if d:IsA("TextLabel") and tostring(d.Text or ""):match("^[Vv]%d") then d.Text="v2.1 ♡" end end
    end
    forceBadge()

    local function palette()
        local hot=badge and badge.BackgroundColor3 or Color3.fromRGB(243,161,211)
        -- Default is Matcha + Light Pink. Other themes can still drive the badge color.
        local defaultHot=Color3.fromRGB(243,161,211)
        local isDefault=math.abs(hot.R-defaultHot.R)<.04 and math.abs(hot.G-defaultHot.G)<.04 and math.abs(hot.B-defaultHot.B)<.04
        return {
            hot=hot,
            hot2=isDefault and Color3.fromRGB(255,212,243) or hot:Lerp(Color3.new(1,1,1),.42),
            light=isDefault and Color3.fromRGB(246,255,250) or hot:Lerp(Color3.new(1,1,1),.90),
            line=isDefault and Color3.fromRGB(255,212,243) or hot:Lerp(Color3.new(1,1,1),.66),
            cream=isDefault and Color3.fromRGB(217,255,232) or hot:Lerp(Color3.new(1,1,1),.93),
            cream2=isDefault and Color3.fromRGB(236,255,243) or hot:Lerp(Color3.new(1,1,1),.96),
            panel=Color3.fromRGB(255,255,255),
            text=isDefault and Color3.fromRGB(82,116,94) or hot:Lerp(Color3.fromRGB(48,48,48),.28),
            sub=isDefault and Color3.fromRGB(122,153,133) or hot:Lerp(Color3.fromRGB(88,88,88),.42),
            white=Color3.fromRGB(255,255,255),
            defaultLime=isDefault,
        }
    end
    local P=palette()

    main.BackgroundColor3=P.cream
    corner(main,24); stroke(main,P.hot,.18,2.2); role(main,"cream")
    stitches(main,12,P,"V26MainStitches")

    local shell=main:FindFirstChild("CuteBlueShell")
    if not shell then
        for _,d in ipairs(main:GetChildren()) do
            if d:IsA("Frame") and d.Size.X.Scale==1 and d.Size.Y.Scale==1 then shell=d break end
        end
    end
    if not shell then _G.KimqV26Ready=true; main.Visible=(_G.KimqMainUserVisibleState~=false); if loader and loader.Gui then loader.Gui:Destroy() end; return end

    -- Remove only redesign decorations from V25 if the file was accidentally layered over it.
    for _,n in ipairs({"V25TopDecor"}) do local x=shell:FindFirstChild(n,true); if x then x:Destroy() end end

    -- Find sidebar, header, profile and pages.
    local nav,pageTitle,pageDesc,pageHead,topProfile
    local pages={}
    for _,d in ipairs(shell:GetDescendants()) do
        if d:IsA("ScrollingFrame") then
            if d:FindFirstChildOfClass("UIListLayout") and d.AbsoluteSize.X<260 and d.AbsoluteSize.Y>240 then nav=d end
            if tostring(d.Name):lower():find("page",1,true) then table.insert(pages,d) end
        end
        if d:IsA("TextLabel") then
            if norm(d.Text)=="overview" and d.TextSize>=18 then pageTitle=d end
            if tostring(d.Text or ""):lower():find("your account",1,true) then pageDesc=d end
        end
        if d:IsA("Frame") and d.AbsoluteSize.X>=180 and d.AbsoluteSize.X<=290 and d.AbsoluteSize.Y>=40 and d.AbsoluteSize.Y<=70 then
            local hasImage=false; for _,c in ipairs(d:GetChildren()) do if c:IsA("ImageLabel") then hasImage=true break end end
            if hasImage and d.AbsolutePosition.Y<main.AbsolutePosition.Y+120 then topProfile=d end
        end
    end
    if pageTitle and pageTitle.Parent and pageTitle.Parent:IsA("Frame") then pageHead=pageTitle.Parent end

    -- v2.1 branding: no mascots, just clean lime/pink/white text.
    local oldMascot=shell:FindFirstChild("V26TopMascot"); if oldMascot then oldMascot:Destroy() end
    for _,d in ipairs(shell:GetDescendants()) do
        if d:IsA("TextLabel") then
            local n=norm(d.Text)
            if n=="kimqetras hc" and d.AbsolutePosition.Y<main.AbsolutePosition.Y+105 then d.Visible=false
            elseif tostring(d.Text or ""):lower():find("cute controls, clean pages",1,true) then d.Visible=false end
        elseif d:IsA("ImageLabel") and (d.Name=="V26TitleDecal" or d.Name=="V26SubtitleDecal" or d.Name=="V26Mascot") then
            d:Destroy()
        end
    end
    local brandTitle=label(shell,"Kimqetras HC",UDim2.fromOffset(280,38),UDim2.fromOffset(24,8),Enum.Font.GothamBold,29,P.hot); brandTitle.ZIndex=24; role(brandTitle,"hotText")
    local brandSub=label(shell,"silent hc  ♡",UDim2.fromOffset(200,24),UDim2.fromOffset(28,45),Enum.Font.GothamBold,16,Color3.fromRGB(82,116,94)); brandSub.ZIndex=24; role(brandSub,"limeText")

    if topProfile then
        topProfile.BackgroundColor3=P.panel; topProfile.BackgroundTransparency=0; corner(topProfile,15); stroke(topProfile,P.line,.35,1); role(topProfile,"panel")
    end

    -- Sidebar becomes a stitched cream section.
    local navButtons={}
    if nav then
        nav.BackgroundColor3=P.cream2; nav.BackgroundTransparency=0; nav.BorderSizePixel=0; nav.ScrollBarImageColor3=P.hot; corner(nav,18); stroke(nav,P.line,.32,1); role(nav,"cream2")
        local parent=nav.Parent
        if parent and parent:IsA("Frame") then parent.BackgroundColor3=P.cream2; parent.BorderSizePixel=0; corner(parent,18); stroke(parent,P.line,.30,1); role(parent,"cream2"); stitches(parent,8,P,"V26SidebarStitches") end
        for _,d in ipairs(nav:GetChildren()) do
            if d:IsA("TextButton") then table.insert(navButtons,d) end
        end
    end
    -- Sidebar heading and paw header.
    if shell then
        for _,d in ipairs(shell:GetDescendants()) do
            if d:IsA("TextLabel") and norm(d.Text)=="features" then
                d.Text="FEATURES"; d.Font=Enum.Font.GothamBold; d.TextSize=16; role(d,"hotText")
                if not d.Parent:FindFirstChild("V26FeaturePawL") then
                    local p1=paw(d.Parent,UDim2.new(0,24,.5,0),21,P.hot,-10,d.ZIndex+1); p1.Name="V26FeaturePawL"
                end
            end
        end
    end

    local function colorDistance(a,b)
        return math.abs(a.R-b.R)+math.abs(a.G-b.G)+math.abs(a.B-b.B)
    end
    local function styleNav()
        -- Never use the startup Matcha palette after a theme has been selected.
        -- This legacy nav callback used to be the piece that repainted the sidebar
        -- back to Matcha/Pink whenever a different section was opened.
        local live=_G.KimqThemeLivePalette
        local hot=(live and live.hot) or P.hot
        local panel=(live and live.panel) or P.panel
        local text=(live and live.text) or P.text
        local white=(live and live.white) or P.white
        local line=(live and live.line) or P.line
        for _,b in ipairs(navButtons) do
            local selected=(colorDistance(b.BackgroundColor3,hot)<.28) or (b.TextColor3.R>.83 and b.TextColor3.G>.83 and b.TextColor3.B>.83)
            b.BackgroundColor3=selected and hot or panel
            b.TextColor3=selected and white or text
            b.Font=Enum.Font.GothamBold; b.TextSize=13; b.TextXAlignment=Enum.TextXAlignment.Left; b.AutoButtonColor=false; corner(b,11); stroke(b,selected and hot or line,selected and .05 or .45,1)
            local pad=b:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding",b); pad.PaddingLeft=UDim.new(0,28); pad.PaddingRight=UDim.new(0,8)
        end
    end
    styleNav()
    for _,b in ipairs(navButtons) do
        b.MouseButton1Click:Connect(function() task.defer(styleNav) end)
    end

    -- Page header: paw print + stitched divider, like the reference section headers.
    if pageHead then
        pageHead.BackgroundColor3=P.panel; pageHead.BorderSizePixel=0; corner(pageHead,15); stroke(pageHead,P.line,.35,1); role(pageHead,"panel")
        if not pageHead:FindFirstChild("V26HeaderPaw") then local p=paw(pageHead,UDim2.new(0,24,.35,0),24,P.hot,-9,pageHead.ZIndex+3); p.Name="V26HeaderPaw" end
        if pageTitle then pageTitle.Font=Enum.Font.GothamBold; pageTitle.TextSize=22; pageTitle.Position=UDim2.new(pageTitle.Position.X.Scale,pageTitle.Position.X.Offset+24,pageTitle.Position.Y.Scale,pageTitle.Position.Y.Offset); role(pageTitle,"hotText") end
        if pageDesc then pageDesc.Font=Enum.Font.GothamSemibold; pageDesc.TextSize=12; role(pageDesc,"subText") end
    end

    -- Style direct card/row content across every feature page, while leaving actual rainbow picker visuals untouched.
    local function stylePage(page)
        page.BackgroundColor3=P.cream; page.BackgroundTransparency=0; page.BorderSizePixel=0; page.ScrollBarImageColor3=P.hot; role(page,"cream")
        local list=page:FindFirstChildOfClass("UIListLayout"); if list then list.Padding=UDim.new(0,9) end
        for _,ch in ipairs(page:GetChildren()) do
            if ch:IsA("Frame") then
                ch.BackgroundColor3=P.panel; ch.BackgroundTransparency=0; ch.BorderSizePixel=0; corner(ch,11); stroke(ch,P.line,.40,1); role(ch,"panel")
                for _,d in ipairs(ch:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        d.TextColor3=P.text
                        if d.TextSize<=11 then d.TextSize=12 end
                        if d.TextSize>=18 then d.Font=Enum.Font.GothamBold; d.TextColor3=P.hot else d.Font=Enum.Font.GothamSemibold end
                        d.TextWrapped=true
                    elseif d:IsA("TextButton") then
                        d.Font=Enum.Font.GothamBold; if d.TextSize<12 then d.TextSize=12 end; d.AutoButtonColor=false
                        -- preserve selected/highlighted buttons; otherwise use cream panel look.
                        local on=colorDistance(d.BackgroundColor3,P.hot)<.32 or (d.TextColor3.R>.85 and d.TextColor3.G>.85 and d.TextColor3.B>.85 and d.BackgroundTransparency<.5)
                        d.BackgroundColor3=on and P.hot or P.light; d.TextColor3=on and P.white or P.text; corner(d,9); stroke(d,on and P.hot or P.line,on and .05 or .48,1)
                    elseif d:IsA("TextBox") then
                        d.Font=Enum.Font.GothamSemibold; if d.TextSize<12 then d.TextSize=12 end; d.BackgroundColor3=P.light; d.TextColor3=P.text; d.PlaceholderColor3=P.sub; corner(d,8); stroke(d,P.line,.45,1)
                    elseif d:IsA("ScrollingFrame") then
                        d.ScrollBarImageColor3=P.hot
                    end
                end
            end
        end
    end
    for _,p in ipairs(pages) do pcall(function() stylePage(p) end) end

    -- Rebuild Overview cleanly with the banner the user liked, now using the stitched/paw style.
    local overview=shell:FindFirstChild("overviewPage",true)
    if overview and overview:IsA("ScrollingFrame") then
        for _,ch in ipairs(overview:GetChildren()) do if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end end
        local list=overview:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",overview); list.Padding=UDim.new(0,10); list.SortOrder=Enum.SortOrder.LayoutOrder
        local pad=overview:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding",overview); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() overview.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y+18) end)

        local function card(h,name)
            local f=Instance.new("Frame",overview); f.Name=name; f.Size=UDim2.new(1,-8,0,h); f.BackgroundColor3=P.panel; f.BorderSizePixel=0; corner(f,12); stroke(f,P.line,.35,1); role(f,"panel"); return f
        end
        local hero=card(138,"V26BannerCard")
        local banner=Instance.new("Frame",hero); banner.Size=UDim2.new(1,-18,1,-18); banner.Position=UDim2.fromOffset(9,9); banner.BackgroundColor3=P.hot; banner.BorderSizePixel=0; corner(banner,12); role(banner,"hotBg")
        local grad=Instance.new("UIGradient",banner); grad.Name="V26BannerGradient"; grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,P.hot2),ColorSequenceKeypoint.new(.52,P.hot),ColorSequenceKeypoint.new(1,P.hot:Lerp(Color3.new(1,1,1),.16))}); grad.Rotation=8
        for _,d in ipairs({{.03,.80,94,.10},{.11,.70,70,.16},{.91,.80,98,.10},{.82,.68,72,.16}}) do local c=Instance.new("Frame",banner); c.AnchorPoint=Vector2.new(.5,.5); c.Position=UDim2.new(d[1],0,d[2],0); c.Size=UDim2.fromOffset(d[3],d[3]); c.BackgroundColor3=P.white; c.BackgroundTransparency=d[4]; c.BorderSizePixel=0; corner(c,999); role(c,"whiteBg") end
        local bt=label(banner,"Kimqetras HC",UDim2.new(1,-30,0,48),UDim2.new(0,15,.5,-33),Enum.Font.GothamBold,35,P.white,Enum.TextXAlignment.Center); role(bt,"whiteText")
        local bs=label(banner,"made with love for you ♡",UDim2.new(1,-30,0,22),UDim2.new(0,15,.5,15),Enum.Font.GothamBold,12,P.white,Enum.TextXAlignment.Center); role(bs,"whiteText")

        local welcome=card(144,"V26Welcome")
        local av=Instance.new("ImageLabel",welcome); av.Size=UDim2.fromOffset(78,78); av.Position=UDim2.fromOffset(18,38); av.BackgroundColor3=P.light; av.BorderSizePixel=0; corner(av,999); stroke(av,P.line,.35,1); role(av,"lightBg"); task.spawn(function()
            local ok,img=pcall(function() return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180) end)
            if ok and av and av.Parent then av.Image=img end
        end)
        local wt=label(welcome,"welcome, "..lp.DisplayName:lower().." ♡",UDim2.new(1,-215,0,34),UDim2.fromOffset(112,24),Enum.Font.GothamBold,25,P.hot); role(wt,"hotText")
        local wu=label(welcome,"@"..lp.Name.."  •  Kimqetras HC",UDim2.new(1,-215,0,20),UDim2.fromOffset(112,57),Enum.Font.GothamSemibold,11,P.sub); role(wu,"subText")
        local l1=label(welcome,"Everything is separated into its own feature page.",UDim2.new(1,-215,0,20),UDim2.fromOffset(112,82),Enum.Font.GothamSemibold,12,P.text); role(l1,"textText")
        local l2=label(welcome,"Pick a tool on the left, or press F1 to hide / reopen the GUI.",UDim2.new(1,-215,0,20),UDim2.fromOffset(112,104),Enum.Font.GothamSemibold,12,P.text); role(l2,"textText")
        local wh=label(welcome,"♡",UDim2.fromOffset(48,48),UDim2.new(1,-64,.5,-24),Enum.Font.GothamBold,34,P.hot,Enum.TextXAlignment.Center); role(wh,"hotText")

        local about=card(126,"V26About")
        local at=label(about,"about",UDim2.new(1,-100,0,28),UDim2.fromOffset(18,8),Enum.Font.GothamBold,21,P.hot); role(at,"hotText")
        local div=label(about,"",UDim2.new(1,-110,0,16),UDim2.fromOffset(18,34),Enum.Font.GothamBold,11,P.line); role(div,"lineText")
        local a1=label(about,"Every feature has its own clean page.",UDim2.new(1,-110,0,18),UDim2.fromOffset(18,57),Enum.Font.GothamSemibold,12,P.text); role(a1,"textText")
        local a2=label(about,"Switch between aiming, movement, visuals, avatar tools, and utilities.",UDim2.new(1,-110,0,18),UDim2.fromOffset(18,78),Enum.Font.GothamSemibold,12,P.text); role(a2,"textText")
        local a3=label(about,"Pick a theme whenever you want the interface to match your style.",UDim2.new(1,-110,0,18),UDim2.fromOffset(18,99),Enum.Font.GothamSemibold,12,P.text); role(a3,"textText")

        local controls=card(82,"V26Controls")
        local ct=label(controls,"controls",UDim2.new(0,160,0,28),UDim2.fromOffset(18,9),Enum.Font.GothamBold,20,P.hot); role(ct,"hotText")
        local cd=label(controls,"F1 = hide / show  •  drag ↘ to resize",UDim2.new(1,-80,0,24),UDim2.fromOffset(18,43),Enum.Font.GothamSemibold,12,P.text); role(cd,"textText")
    end


    -- Remove all V26 stitch decorations; keep the rounded borders/cards from the original V26.
    for _,d in ipairs(main:GetDescendants()) do
        if tostring(d.Name):find("Stitch",1,true) then
            pcall(function() d:Destroy() end)
        end
    end

    local syncing=false
    local function sync()
        -- The final v2.1 theme pass owns colors after startup. Without this guard,
        -- this legacy badge listener repaints parts of the GUI and leaves old colors behind.
        if _G.KimqV21FullThemeActive then return end
        if syncing then return end; syncing=true
        P=palette(); forceBadge()
        main.BackgroundColor3=P.cream; local ms=main:FindFirstChildOfClass("UIStroke"); if ms then ms.Color=P.hot end
        for _,d in ipairs(main:GetDescendants()) do
            local r=d:GetAttribute("KimqV26Role")
            if r then
                if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextBox") or d:IsA("ImageLabel") then
                    if r=="cream" then d.BackgroundColor3=P.cream elseif r=="cream2" then d.BackgroundColor3=P.cream2 elseif r=="panel" then d.BackgroundColor3=P.panel elseif r=="lightBg" then d.BackgroundColor3=P.light elseif r=="hotBg" then d.BackgroundColor3=P.hot elseif r=="whiteBg" then d.BackgroundColor3=P.white end
                end
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    if r=="hotText" then d.TextColor3=P.hot elseif r=="subText" then d.TextColor3=P.sub elseif r=="textText" then d.TextColor3=P.text elseif r=="lineText" then d.TextColor3=P.line elseif r=="whiteText" then d.TextColor3=P.white elseif r=="limeText" then d.TextColor3=(P.defaultLime and Color3.fromRGB(82,116,94) or P.hot2) end
                end
                if r=="stitch" and d:IsA("Frame") then d.Visible=false end
                if (r=="pawImage") and d:IsA("ImageLabel") then
                    local isBlueTheme=(P.hot.B>P.hot.R and P.hot.B>P.hot.G)
                    d.ImageColor3=isBlueTheme and Color3.new(1,1,1) or P.hot:Lerp(Color3.new(1,1,1),.18)
                end
                local s=d:FindFirstChildOfClass("UIStroke"); if s and r~="hotBg" then s.Color=P.line end
            end
            if d:IsA("UIGradient") and d.Name=="V26BannerGradient" then d.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,P.hot2),ColorSequenceKeypoint.new(.52,P.hot),ColorSequenceKeypoint.new(1,P.hot:Lerp(Color3.new(1,1,1),.16))}) end
        end
        for _,p in ipairs(main:GetDescendants()) do
            if p.Name=="V26Paw" and p:IsA("ImageLabel") then
                local isBlueTheme=(P.hot.B>P.hot.R and P.hot.B>P.hot.G)
                p.ImageColor3=isBlueTheme and Color3.new(1,1,1) or P.hot:Lerp(Color3.new(1,1,1),.18)
            end
        end
        if nav then nav.ScrollBarImageColor3=P.hot end
        for _,p in ipairs(pages) do p.ScrollBarImageColor3=P.hot end
        styleNav()
        syncing=false
    end
    -- One startup sync only. The performance theme engine below owns all later recolors.
    sync()

    _G.KimqV26Ready=true
    forceBadge()
end)


-- ========================================================
-- ========================================================
-- v2.1 AUTHORITATIVE THEME ENGINE
-- This replaces the previous exact-color registry.  Every visible GUI object is
-- classified once by what it is (heading, body text, card, action, toggle, etc.)
-- and every theme applies those semantic roles.  Theme preview swatches and
-- true color-picker visuals are intentionally left alone.
-- One full cached repaint per theme click; no frame loops and no delayed repaint stacks.
-- ========================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local UIS = game:GetService("UserInputService")
    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")

    local t0 = tick()
    while not _G.KimqV26Ready and tick() - t0 < 20 do task.wait(.08) end

    local root = CoreGui:FindFirstChild("KimpetrasHC") or pg:FindFirstChild("KimpetrasHC")
    local main = root and root:FindFirstChild("Main")
    if not main then return end
    local shell = main:FindFirstChild("CuteBlueShell") or main:FindFirstChildWhichIsA("Frame")
    if not shell then return end

    local THEMES = {
        ["Matcha Pink"]={hot=Color3.fromRGB(243,161,211),hot2=Color3.fromRGB(255,212,243),bg=Color3.fromRGB(217,255,232),bg2=Color3.fromRGB(236,255,243),panel=Color3.fromRGB(255,255,255),soft=Color3.fromRGB(246,255,250),text=Color3.fromRGB(82,116,94),sub=Color3.fromRGB(122,153,133),line=Color3.fromRGB(255,212,243),white=Color3.new(1,1,1)},
        ["Lavender Blue"]={hot=Color3.fromRGB(132,151,239),hot2=Color3.fromRGB(220,225,255),bg=Color3.fromRGB(244,241,255),bg2=Color3.fromRGB(249,247,255),panel=Color3.new(1,1,1),soft=Color3.fromRGB(252,250,255),text=Color3.fromRGB(91,91,133),sub=Color3.fromRGB(132,130,169),line=Color3.fromRGB(216,211,244),white=Color3.new(1,1,1)},
        ["Baby Blue"]={hot=Color3.fromRGB(111,181,241),hot2=Color3.fromRGB(215,237,255),bg=Color3.fromRGB(238,248,255),bg2=Color3.fromRGB(247,252,255),panel=Color3.new(1,1,1),soft=Color3.fromRGB(250,253,255),text=Color3.fromRGB(72,112,146),sub=Color3.fromRGB(114,150,180),line=Color3.fromRGB(202,228,248),white=Color3.new(1,1,1)},
        ["Sky Lilac"]={hot=Color3.fromRGB(150,139,235),hot2=Color3.fromRGB(219,223,255),bg=Color3.fromRGB(239,247,255),bg2=Color3.fromRGB(248,250,255),panel=Color3.new(1,1,1),soft=Color3.fromRGB(251,252,255),text=Color3.fromRGB(91,91,137),sub=Color3.fromRGB(131,131,174),line=Color3.fromRGB(211,217,246),white=Color3.new(1,1,1)},
        ["Lilac Pink"]={hot=Color3.fromRGB(205,137,224),hot2=Color3.fromRGB(243,214,248),bg=Color3.fromRGB(252,241,255),bg2=Color3.fromRGB(255,248,255),panel=Color3.new(1,1,1),soft=Color3.fromRGB(255,251,255),text=Color3.fromRGB(126,84,137),sub=Color3.fromRGB(164,125,173),line=Color3.fromRGB(238,208,242),white=Color3.new(1,1,1)},
        ["Rose Cream"]={hot=Color3.fromRGB(225,142,166),hot2=Color3.fromRGB(251,217,227),bg=Color3.fromRGB(255,246,243),bg2=Color3.fromRGB(255,251,249),panel=Color3.new(1,1,1),soft=Color3.fromRGB(255,252,251),text=Color3.fromRGB(132,91,96),sub=Color3.fromRGB(171,128,133),line=Color3.fromRGB(244,211,216),white=Color3.new(1,1,1)},
        ["Peach Cream"]={hot=Color3.fromRGB(238,164,133),hot2=Color3.fromRGB(255,224,207),bg=Color3.fromRGB(255,245,235),bg2=Color3.fromRGB(255,250,245),panel=Color3.new(1,1,1),soft=Color3.fromRGB(255,252,248),text=Color3.fromRGB(132,96,80),sub=Color3.fromRGB(174,135,117),line=Color3.fromRGB(247,216,201),white=Color3.new(1,1,1)},
        ["Butter Pink"]={hot=Color3.fromRGB(238,153,192),hot2=Color3.fromRGB(255,219,235),bg=Color3.fromRGB(255,251,221),bg2=Color3.fromRGB(255,253,239),panel=Color3.new(1,1,1),soft=Color3.fromRGB(255,254,247),text=Color3.fromRGB(125,112,78),sub=Color3.fromRGB(166,149,111),line=Color3.fromRGB(246,221,224),white=Color3.new(1,1,1)},
        ["Mint Aqua"]={hot=Color3.fromRGB(96,193,183),hot2=Color3.fromRGB(205,242,236),bg=Color3.fromRGB(232,252,245),bg2=Color3.fromRGB(246,255,251),panel=Color3.new(1,1,1),soft=Color3.fromRGB(250,255,253),text=Color3.fromRGB(68,123,117),sub=Color3.fromRGB(109,159,153),line=Color3.fromRGB(194,233,226),white=Color3.new(1,1,1)},
        ["Grey Pink"]={hot=Color3.fromRGB(232,145,188),hot2=Color3.fromRGB(255,218,238),bg=Color3.fromRGB(244,245,249),bg2=Color3.fromRGB(249,250,252),panel=Color3.new(1,1,1),soft=Color3.fromRGB(252,252,254),text=Color3.fromRGB(92,92,105),sub=Color3.fromRGB(136,135,149),line=Color3.fromRGB(228,214,226),white=Color3.new(1,1,1)},
        ["Black Pink"]={hot=Color3.fromRGB(242,151,197),hot2=Color3.fromRGB(255,205,230),bg=Color3.fromRGB(28,29,34),bg2=Color3.fromRGB(37,38,45),panel=Color3.fromRGB(47,48,57),soft=Color3.fromRGB(56,57,67),text=Color3.fromRGB(255,221,238),sub=Color3.fromRGB(218,185,202),line=Color3.fromRGB(233,150,192),white=Color3.fromRGB(255,248,252)},
        Purple={hot=Color3.fromRGB(169,116,235),hot2=Color3.fromRGB(229,210,251),bg=Color3.fromRGB(246,239,255),bg2=Color3.fromRGB(251,247,255),panel=Color3.new(1,1,1),soft=Color3.fromRGB(252,249,255),text=Color3.fromRGB(102,77,126),sub=Color3.fromRGB(143,119,164),line=Color3.fromRGB(226,208,244),white=Color3.new(1,1,1)},
        Red={hot=Color3.fromRGB(236,111,132),hot2=Color3.fromRGB(255,205,215),bg=Color3.fromRGB(255,239,243),bg2=Color3.fromRGB(255,248,250),panel=Color3.new(1,1,1),soft=Color3.fromRGB(255,250,251),text=Color3.fromRGB(139,77,87),sub=Color3.fromRGB(174,116,126),line=Color3.fromRGB(247,202,210),white=Color3.new(1,1,1)},
        Pink={hot=Color3.fromRGB(238,131,190),hot2=Color3.fromRGB(255,212,243),bg=Color3.fromRGB(255,241,250),bg2=Color3.fromRGB(255,248,253),panel=Color3.new(1,1,1),soft=Color3.fromRGB(255,251,254),text=Color3.fromRGB(146,84,116),sub=Color3.fromRGB(181,125,153),line=Color3.fromRGB(248,208,232),white=Color3.new(1,1,1)},
        Aqua={hot=Color3.fromRGB(84,190,211),hot2=Color3.fromRGB(199,239,247),bg=Color3.fromRGB(233,251,254),bg2=Color3.fromRGB(245,254,255),panel=Color3.new(1,1,1),soft=Color3.fromRGB(249,254,255),text=Color3.fromRGB(67,120,131),sub=Color3.fromRGB(110,155,165),line=Color3.fromRGB(191,229,237),white=Color3.new(1,1,1)},
        Green={hot=Color3.fromRGB(100,185,135),hot2=Color3.fromRGB(205,240,219),bg=Color3.fromRGB(235,252,242),bg2=Color3.fromRGB(246,254,249),panel=Color3.new(1,1,1),soft=Color3.fromRGB(250,255,252),text=Color3.fromRGB(72,122,91),sub=Color3.fromRGB(112,158,129),line=Color3.fromRGB(198,232,211),white=Color3.new(1,1,1)},
    }
    local order={"Matcha Pink","Lavender Blue","Baby Blue","Sky Lilac","Lilac Pink","Rose Cream","Peach Cream","Butter Pink","Mint Aqua","Grey Pink","Black Pink","Purple","Red","Pink","Aqua","Green"}
    local labels={
        ["Matcha Pink"]="Matcha + Pink",["Lavender Blue"]="Lavender + Blue",["Baby Blue"]="Baby Blue",["Sky Lilac"]="Sky + Lilac",["Lilac Pink"]="Lilac + Pink",["Rose Cream"]="Rose + Cream",["Peach Cream"]="Peach + Cream",["Butter Pink"]="Butter + Pink",["Mint Aqua"]="Mint + Aqua",["Grey Pink"]="Grey + Pink",["Black Pink"]="Black + Light Pink",Purple="Purple Theme",Red="Red Theme",Pink="Pink Theme",Aqua="Aqua Theme",Green="Green Theme"
    }

    local currentName = _G.KimqCuteTheme or "Purple"
    if not THEMES[currentName] then currentName = "Purple" end
    _G.KimqCuteTheme = currentName

    local function clean(s)
        s=tostring(s or ""):lower():gsub("[♥♡❤]",""):gsub("%s+"," ")
        return (s:gsub("^%s+",""):gsub("%s+$",""))
    end
    local function corner(o,r)
        local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner",o)
        c.CornerRadius=UDim.new(0,r or 10)
        return c
    end
    local function outline(o,c,tr,th)
        local st=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",o)
        st.Color=c; st.Transparency=tr or .42; st.Thickness=th or 1
        return st
    end
    local function colorDistance(a,b)
        local dr=a.R-b.R; local dg=a.G-b.G; local db=a.B-b.B
        return math.sqrt(dr*dr+dg*dg+db*db)
    end
    local function brightness(c) return (c.R+c.G+c.B)/3 end
    local function saturation(c)
        local mx=math.max(c.R,c.G,c.B); local mn=math.min(c.R,c.G,c.B)
        return mx-mn
    end
    local function whiteish(c) return c.R>.90 and c.G>.90 and c.B>.90 end

    local function hasPreviewAncestor(o)
        local x=o
        while x and x~=main do
            if x:GetAttribute("KimqThemePreview") then return true end
            x=x.Parent
        end
        return false
    end
    local function isTrueColorVisual(o)
        local n=tostring(o.Name):lower()
        return n:find("fogsquare",1,true) or n:find("fogpreview",1,true) or n:find("foghue",1,true)
            or n:find("rainbow",1,true) or n:find("espcolor",1,true) or n:find("colorwheel",1,true)
    end

    local pageNames={overview=true,["silent aim"]=true,macro=true,whitelist=true,protection=true,["anti fall"]=true,["delay changer"]=true,esp=true,avatar=true,["fog / atmosphere"]=true,environment=true,["weapon skins"]=true,["hc silent aim"]=true,["force hit"]=true,["hitbox expander"]=true,flamelock=true,camlock=true,headless=true,["anti mod"]=true,["spawn point"]=true,["rage camlock"]=true,["target orbit"]=true,["rage combat"]=true,settings=true,theme=true,information=true}
    local function findNav()
        local best,bestScore=nil,0
        for _,d in ipairs(main:GetDescendants()) do
            if d:IsA("ScrollingFrame") then
                local score=0
                for _,b in ipairs(d:GetChildren()) do
                    if b:IsA("TextButton") and pageNames[clean(b.Text)] then score+=1 end
                end
                if score>bestScore then best,bestScore=d,score end
            end
        end
        return best
    end
    local nav=findNav()
    local themePage=shell:FindFirstChild("themePage",true)

    -- v2.62: preserve the grouped sidebar order from pageDefs.
    -- Do NOT alphabetize/rewrite LayoutOrder after HOME / COMBAT / VISUALS /
    -- PLAYER / SETUP labels have been created.
    if nav then
        local layout=nav:FindFirstChildOfClass("UIListLayout")
        if layout then layout.SortOrder=Enum.SortOrder.LayoutOrder end
        nav.CanvasPosition=Vector2.zero
    end

    local BASE=THEMES["Matcha Pink"]
    local function nearestBaseRole(c)
        local choices={{BASE.bg,"bg"},{BASE.bg2,"bg2"},{BASE.panel,"panel"},{BASE.soft,"soft"},{BASE.hot,"hot"},{BASE.hot2,"hot2"}}
        local bestRole,best= nil,math.huge
        for _,v in ipairs(choices) do
            local d=colorDistance(c,v[1]); if d<best then best,bestRole=d,v[2] end
        end
        if best<.24 then return bestRole end
        return nil
    end

    local function isToggleButton(o)
        if not o:IsA("TextButton") or o.Text~="" then return false end
        if o.AbsoluteSize.X<28 or o.AbsoluteSize.X>70 or o.AbsoluteSize.Y<14 or o.AbsoluteSize.Y>34 then return false end
        for _,c in ipairs(o:GetChildren()) do
            if c:IsA("Frame") and c.AbsoluteSize.X<=24 and c.AbsoluteSize.Y<=24 then return true,c end
        end
        return false,nil
    end

    -- Semantic entries are cached once.  This is deliberately broader than exact RGB
    -- matching so the old pink/green/blue leftovers all get absorbed into the theme.
    local entries={}
    local seen={}
    local function addEntry(o,data)
        if not o or seen[o] or hasPreviewAncestor(o) then return end
        seen[o]=true; data.o=o; table.insert(entries,data)
    end

    local roleMap={cream="bg",cream2="bg2",panel="panel",lightBg="soft",hotBg="hot",whiteBg="panel",hotText="hotText",subText="subText",textText="textText",lineText="lineText",whiteText="whiteText",limeText="textText"}

    local function classify(o)
        if not o or hasPreviewAncestor(o) then return end
        if o:IsA("UIStroke") then
            addEntry(o,{stroke=true}); return
        end
        if o:IsA("UIGradient") then
            if o.Name=="V26BannerGradient" then
                addEntry(o,{gradient=true})
            elseif o.Name=="KimqProfileAvatarGradient" then
                addEntry(o,{profileGradient=true})
            end
            return
        end
        if not (o:IsA("GuiObject") or o:IsA("UIBase")) then return end

        local data={}
        if o:IsA("ScrollingFrame") then data.scroll=true end
        if o:IsA("GuiObject") then o.BorderSizePixel=0 end

        local attr=o:GetAttribute("KimqV26Role")
        if attr and roleMap[attr] then
            local r=roleMap[attr]
            if r=="bg" or r=="bg2" or r=="panel" or r=="soft" or r=="hot" then data.bgRole=r else data.textRole=r end
        end

        if o==main then data.bgRole="bg" end
        if nav and (o==nav or o==nav.Parent) then data.bgRole="bg2" end

        if o:IsA("ScrollingFrame") and o~=nav and o.BackgroundTransparency<.98 then
            local low=tostring(o.Name):lower()
            if low:match("page$") then data.bgRole="bg" end
        end

        if o:IsA("TextButton") then
            local toggle,circle=isToggleButton(o)
            if toggle then data.toggle=true; data.toggleCircle=circle end
        end

        if o:IsA("GuiObject") and o.BackgroundTransparency<.98 and not isTrueColorVisual(o) and not data.toggle then
            if not data.bgRole then
                local r=nearestBaseRole(o.BackgroundColor3)
                if r then data.bgRole=r else
                    local br=brightness(o.BackgroundColor3); local sat=saturation(o.BackgroundColor3)
                    if whiteish(o.BackgroundColor3) then data.bgRole="panel"
                    elseif br>.89 then data.bgRole=(sat>.08 and "soft" or "panel")
                    elseif sat>.18 then data.bgRole="hot"
                    else data.bgRole="soft" end
                end
            end
        end

        if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
            local txt=tostring(o.Text or "")
            local low=clean(txt)
            local c=o.TextColor3
            local sat=saturation(c); local br=brightness(c)
            if not data.textRole then
                if whiteish(c) then data.textRole="whiteText"
                elseif low:match("^v2%.") or low:find("kimqetras hc",1,true) or o.Font==Enum.Font.GothamBold or o.TextSize>=17 then data.textRole="hotText"
                elseif sat>.17 then data.textRole="hotText"
                elseif br>.57 then data.textRole="subText"
                else data.textRole="textText" end
            end
            if o:IsA("TextBox") then data.placeholderRole="subText" end
        end

        if o:IsA("ImageLabel") or o:IsA("ImageButton") then
            local n=tostring(o.Name):lower()
            if not n:find("avatar",1,true) and not n:find("profile",1,true) and not isTrueColorVisual(o) then
                if not whiteish(o.ImageColor3) and saturation(o.ImageColor3)>.10 then data.imageRole="hot" end
            end
        end

        if next(data) then addEntry(o,data) end
    end

    for _,d in ipairs(main:GetDescendants()) do classify(d) end
    classify(main)

    -- v2.3: recognize colors from ANY theme (plus older hard-coded GUI colors),
    -- not only the original Matcha palette. This lets a full repaint absorb buttons
    -- that a callback may have put back to an older pink/purple/green value.
    local legacyRoleColors={
        {Color3.fromRGB(255,190,220),"hot"},
        {Color3.fromRGB(230,40,135),"hot"},
        {Color3.fromRGB(225,55,135),"hot"},
        {Color3.fromRGB(220,45,125),"hot"},
        {Color3.fromRGB(255,245,250),"soft"},
        {Color3.fromRGB(246,255,250),"soft"},
        {Color3.fromRGB(236,255,243),"bg2"},
        {Color3.fromRGB(217,255,232),"bg"},
        {Color3.fromRGB(255,255,255),"panel"},
    }
    local function nearestAnyThemeRole(c)
        local bestRole,best=nil,math.huge
        for _,p in pairs(THEMES) do
            for _,rv in ipairs({
                {"bg",p.bg},{"bg2",p.bg2},{"panel",p.panel},{"soft",p.soft},
                {"hot",p.hot},{"hot2",p.hot2}
            }) do
                local dist=colorDistance(c,rv[2])
                if dist<best then best,bestRole=dist,rv[1] end
            end
        end
        for _,rv in ipairs(legacyRoleColors) do
            local dist=colorDistance(c,rv[1])
            if dist<best then best,bestRole=dist,rv[2] end
        end
        if best<.30 then return bestRole end

        local br=brightness(c); local sat=saturation(c)
        if whiteish(c) then return "panel" end
        if br>.90 then return sat>.07 and "soft" or "panel" end
        if sat>.16 then return "hot" end
        return "soft"
    end

    local function activePageName()
        local map={antifall="anti fall",antimod="anti mod",delay="delay changer",fog="fog / atmosphere",forcehit="hc silent aim",hcsilent="hc silent aim",hitbox="hitbox expander",info="information",weaponskins="weapon skins",silent="silent aim"}
        for _,d in ipairs(main:GetDescendants()) do
            if d:IsA("ScrollingFrame") and d.Visible and d~=nav and d.Name:lower():match("page$") then
                local n=d.Name:lower():gsub("page$","")
                return map[n] or n
            end
        end
        return "overview"
    end

    local function applyBackground(o,role,p)
        if role=="bg" then o.BackgroundColor3=p.bg
        elseif role=="bg2" then o.BackgroundColor3=p.bg2
        elseif role=="panel" then o.BackgroundColor3=p.panel
        elseif role=="soft" then o.BackgroundColor3=p.soft
        elseif role=="hot" then o.BackgroundColor3=p.hot
        elseif role=="hot2" then o.BackgroundColor3=p.hot2 end
    end
    local function applyText(o,role,p)
        if role=="hotText" then o.TextColor3=p.hot
        elseif role=="subText" then o.TextColor3=p.sub
        elseif role=="whiteText" then o.TextColor3=p.white
        elseif role=="lineText" then o.TextColor3=p.hot2
        else o.TextColor3=p.text end
    end

    local function styleNav(p)
        if not nav then return end
        nav.BackgroundColor3=p.bg2; nav.ScrollBarImageColor3=p.hot
        if nav.Parent and nav.Parent:IsA("GuiObject") then
            nav.Parent.BackgroundColor3=p.bg2
            local st=nav.Parent:FindFirstChildOfClass("UIStroke"); if st then st.Color=p.line end
        end
        local active=activePageName()
        for _,b in ipairs(nav:GetChildren()) do
            if b:IsA("TextButton") and pageNames[clean(b.Text)] then
                local selected=clean(b.Text)==active
                b:SetAttribute("KimqSelected",selected)
                b.BackgroundColor3=selected and p.hot or p.panel
                b.TextColor3=selected and p.white or p.text
                local st=b:FindFirstChildOfClass("UIStroke")
                if st then st.Color=selected and p.hot or p.line; st.Transparency=selected and .05 or .58 end
                for _,c in ipairs(b:GetChildren()) do
                    if c:IsA("TextLabel") and (c.Text=="♡" or c.Text=="♥") then c.TextColor3=selected and p.white or p.hot end
                end
            end
        end
    end

    local function applyTheme(name,settlePass)
        local p=THEMES[name]; if not p then return end
        currentName=name; _G.KimqCuteTheme=name; _G.KimqThemeLivePalette=p
        if type(_G.KimqRefreshWingMiniTheme)=="function" then pcall(_G.KimqRefreshWingMiniTheme) end
        if type(_G.KimqRefreshRageMiniTheme)=="function" then pcall(_G.KimqRefreshRageMiniTheme) end
        if type(_G.KimqRefreshWeaponPresetTheme)=="function" then pcall(_G.KimqRefreshWeaponPresetTheme) end
        if type(_G.KimqRefreshKnifeAccentTheme)=="function" then pcall(_G.KimqRefreshKnifeAccentTheme) end
        if type(_G.KimqRefreshAvatarAccessoryTheme)=="function" then pcall(_G.KimqRefreshAvatarAccessoryTheme) end

        -- Snapshot each opaque object's CURRENT semantic color role before painting.
        -- That preserves selected/unselected states while still translating every old
        -- palette color into the newly chosen theme.
        local liveBgRoles={}
        for _,d in ipairs(main:GetDescendants()) do
            if d:IsA("GuiObject") and d.BackgroundTransparency<.98
                and not hasPreviewAncestor(d) and not isTrueColorVisual(d) then
                liveBgRoles[d]=nearestAnyThemeRole(d.BackgroundColor3)
            end
        end
        if main.BackgroundTransparency<.98 then liveBgRoles[main]="bg" end

        -- Pick up controls that were created after startup (weapon/skin buttons,
        -- dropdown rows, etc.) so they cannot keep the original Matcha colors.
        for _,d in ipairs(main:GetDescendants()) do
            if not seen[d] and not hasPreviewAncestor(d) then classify(d) end
        end

        -- Update every live palette table used by the original control callbacks.
        for _,T in ipairs(_G.KimqThemePaletteRefs or {}) do
            if type(T)=="table" then
                T.bg=p.bg; T.bg2=p.bg2; T.panel=p.panel; T.card=p.panel; T.card2=p.soft
                T.hot=p.hot; T.hot2=p.hot2; T.text=p.text; T.sub=p.sub; T.stroke=p.line; T.white=p.white
            end
        end

        for _,e in ipairs(entries) do
            local o=e.o
            if o and o.Parent and not hasPreviewAncestor(o) then
                if o:IsA("GuiObject") then
                    local liveRole=liveBgRoles[o] or e.bgRole
                    if liveRole then applyBackground(o,liveRole,p) end
                end
                if e.toggle and o:IsA("TextButton") then
                    local c=e.toggleCircle
                    local on=c and c.Parent and c.Position.X.Scale>.5
                    o.BackgroundColor3=on and p.hot or p.soft
                    if c and c.Parent then c.BackgroundColor3=p.white end
                end
                if e.textRole and (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) then applyText(o,e.textRole,p) end
                if e.placeholderRole and o:IsA("TextBox") then o.PlaceholderColor3=p.sub end
                if e.imageRole and (o:IsA("ImageLabel") or o:IsA("ImageButton")) then o.ImageColor3=p.hot end
                if e.scroll and o:IsA("ScrollingFrame") then o.ScrollBarImageColor3=p.hot end
                if e.stroke and o:IsA("UIStroke") then o.Color=p.line end
                if e.gradient and o:IsA("UIGradient") then
                    o.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,p.hot2),ColorSequenceKeypoint.new(.52,p.hot),ColorSequenceKeypoint.new(1,p.hot:Lerp(p.white,.12))})
                end
                if e.profileGradient and o:IsA("UIGradient") then
                    o.Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,p.hot),
                        ColorSequenceKeypoint.new(1,p.white)
                    })
                end
            end
        end

        -- Full-surface sweep: anything opaque that survived a legacy callback is
        -- translated from its live role as well, even if it was never in the cached
        -- semantic-entry table. Color pickers and theme-preview swatches stay untouched.
        for _,d in ipairs(main:GetDescendants()) do
            if not hasPreviewAncestor(d) then
                if d:IsA("GuiObject") and d.BackgroundTransparency<.98 and not isTrueColorVisual(d) then
                    local role=liveBgRoles[d]
                    if role then applyBackground(d,role,p) end
                end
                if d:IsA("ScrollingFrame") then d.ScrollBarImageColor3=p.hot end
                if d:IsA("UIStroke") then d.Color=p.line end
            end
        end

        -- Action buttons and special branding need deterministic roles regardless of their old RGB.
        for _,d in ipairs(main:GetDescendants()) do
            if not hasPreviewAncestor(d) then
                if d:IsA("TextButton") then
                    local low=clean(d.Text)
                    if d.Name=="KimqResizeGrip" or d:GetAttribute("KimqResizeControl") then
                        d.BackgroundColor3=p.hot; d.TextColor3=p.white
                        local st=d:FindFirstChildOfClass("UIStroke"); if st then st.Color=p.line end
                    elseif low:find("apply",1,true) or low:find("selected",1,true) then
                        d.BackgroundColor3=p.hot; d.TextColor3=p.white
                        local st=d:FindFirstChildOfClass("UIStroke"); if st then st.Color=p.hot end
                    end
                elseif d:IsA("TextLabel") then
                    local low=clean(d.Text)
                    if low:match("^v2%.") then
                        d.BackgroundTransparency=0; d.BackgroundColor3=p.hot; d.TextColor3=p.white
                        local st=d:FindFirstChildOfClass("UIStroke"); if st then st.Color=p.hot end
                    elseif low:find("kimqetras hc",1,true) and d.BackgroundTransparency>.8 then
                        d.TextColor3=p.hot
                    end
                end
            end
        end

        -- v2.62 hard guarantee: old controls created with literal pink/yellow
        -- values are translated too. This catches Avatar, old section controls,
        -- late weapon UI, config buttons, etc. True color pickers/previews are excluded.
        local legacyHot={
            Color3.fromRGB(243,161,211),Color3.fromRGB(255,20,147),
            Color3.fromRGB(255,105,180),Color3.fromRGB(255,190,220),
            Color3.fromRGB(230,40,135),Color3.fromRGB(225,55,135),
            Color3.fromRGB(225,73,140),Color3.fromRGB(220,45,125),
            Color3.fromRGB(212,105,169)
        }
        local legacySoft={
            Color3.fromRGB(255,225,238),Color3.fromRGB(255,205,228),
            Color3.fromRGB(255,236,190),Color3.fromRGB(255,242,206),
            Color3.fromRGB(236,255,243)
        }
        local legacySub={
            Color3.fromRGB(197,112,145),Color3.fromRGB(184,100,125),
            Color3.fromRGB(176,99,122)
        }
        local function nearAny(c,list,tol)
            for _,x in ipairs(list) do
                if colorDistance(c,x)<=tol then return true end
            end
            return false
        end
        for _,d in ipairs(main:GetDescendants()) do
            if not hasPreviewAncestor(d) and not isTrueColorVisual(d) then
                if d:IsA("GuiObject") and d.BackgroundTransparency<.98 then
                    if nearAny(d.BackgroundColor3,legacyHot,.13) then
                        d.BackgroundColor3=p.hot
                    elseif nearAny(d.BackgroundColor3,legacySoft,.13) then
                        d.BackgroundColor3=p.soft
                    end
                end
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    if nearAny(d.TextColor3,legacyHot,.16) then
                        d.TextColor3=p.hot
                    elseif nearAny(d.TextColor3,legacySub,.16) then
                        d.TextColor3=p.sub
                    end
                    if d:IsA("TextBox") and nearAny(d.PlaceholderColor3,legacySub,.16) then
                        d.PlaceholderColor3=p.sub
                    end
                end
                if d:IsA("UIStroke") and nearAny(d.Color,legacyHot,.18) then
                    d.Color=p.line
                end
            end
        end

        if themePage then themePage.BackgroundColor3=p.bg end
        styleNav(p)

        -- Some old control callbacks repaint themselves a fraction of a second after
        -- a theme click. Two bounded settle passes catch those leftovers without a
        -- permanent frame loop.
        if not settlePass then
            -- One short settle is enough; repeated full-GUI sweeps were a major source of stutter.
            task.delay(.08,function()
                if main.Parent and currentName==name then applyTheme(name,true) end
            end)
        end
    end
    _G.KimqApplyTheme=applyTheme

    -- v2.9: do not repaint the entire GUI after every mouse click. Controls already
    -- use the live theme palette and page/theme changes have their own refresh hooks.
    -- The old global click repaint walked the full GUI several times per interaction.

    -- Rebuild the Theme page once.  These rows are previews, so their swatches keep
    -- their own palette even while the rest of the GUI changes.
    if themePage then
        for _,ch in ipairs(themePage:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end
        end
        themePage.BackgroundTransparency=0
        local layout=themePage:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",themePage)
        layout.Padding=UDim.new(0,8); layout.SortOrder=Enum.SortOrder.LayoutOrder
        local pad=themePage:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding",themePage)
        pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,10); pad.PaddingLeft=UDim.new(0,5); pad.PaddingRight=UDim.new(0,5)
        local function makeRow(name,index)
            local t=THEMES[name]
            local f=Instance.new("Frame",themePage); f.Name="ThemeChoiceClean"; f:SetAttribute("KimqThemePreview",true); f.LayoutOrder=index; f.Size=UDim2.new(1,-10,0,54); f.BackgroundColor3=t.panel; f.BorderSizePixel=0; corner(f,11); outline(f,t.line,.12,1)
            local l=Instance.new("TextLabel",f); l.BackgroundTransparency=1; l.Position=UDim2.fromOffset(14,0); l.Size=UDim2.new(1,-175,1,0); l.Text=labels[name] or name; l.Font=Enum.Font.GothamSemibold; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextColor3=t.text
            local a=Instance.new("Frame",f); a.Size=UDim2.fromOffset(32,32); a.Position=UDim2.new(1,-145,.5,-16); a.BackgroundColor3=t.bg; a.BorderSizePixel=0; corner(a,9); outline(a,t.line,.1,1)
            local b=Instance.new("Frame",f); b.Size=UDim2.fromOffset(32,32); b.Position=UDim2.new(1,-105,.5,-16); b.BackgroundColor3=t.hot; b.BorderSizePixel=0; corner(b,9); outline(b,t.hot,.05,1)
            local btn=Instance.new("TextButton",f); btn.Size=UDim2.fromOffset(56,32); btn.Position=UDim2.new(1,-65,.5,-16); btn.BackgroundColor3=t.hot; btn.BorderSizePixel=0; btn.Text="Use"; btn.TextColor3=t.white; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=11; btn.AutoButtonColor=false; corner(btn,9)
            btn.MouseButton1Click:Connect(function() applyTheme(name) end)
        end
        for i,name in ipairs(order) do makeRow(name,i) end
        local function resizeThemeCanvas() themePage.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+18) end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeThemeCanvas)
        resizeThemeCanvas()
    end

    -- v2.62: section navigation does not repaint/rescan the entire GUI.
    -- The page builder's live theme palette already keeps nav colors current.

    -- Newly generated controls are classified immediately. Their first paint uses
    -- the current palette, so opening Weapon Skins does not introduce old colors.
    main.DescendantAdded:Connect(function(d)
        if hasPreviewAncestor(d) then return end
        task.defer(function()
            if d.Parent and not seen[d] then
                classify(d)
                local p=THEMES[currentName]
                local e=nil
                for i=#entries,1,-1 do if entries[i].o==d then e=entries[i]; break end end
                if e and p then
                    if e.bgRole and d:IsA("GuiObject") then applyBackground(d,e.bgRole,p) end
                    if e.textRole and (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) then applyText(d,e.textRole,p) end
                    if e.placeholderRole and d:IsA("TextBox") then d.PlaceholderColor3=p.sub end
                    if e.imageRole and (d:IsA("ImageLabel") or d:IsA("ImageButton")) then d.ImageColor3=p.hot end
                    if e.scroll and d:IsA("ScrollingFrame") then d.ScrollBarImageColor3=p.hot end
                    if e.stroke and d:IsA("UIStroke") then d.Color=p.line end
                end
            end
        end)
    end)

    -- Bottom-right resize grip. Drag it to make the whole window smaller or larger.
    -- This only changes the final v2.1 Main size; it does not create another GUI layer.
    do
        local oldGrip=main:FindFirstChild("KimqResizeGrip")
        if oldGrip then oldGrip:Destroy() end

        local grip=Instance.new("TextButton")
        grip.Name="KimqResizeGrip"
        grip.Parent=main
        grip.AnchorPoint=Vector2.new(1,1)
        grip.Position=UDim2.new(1,-8,1,-8)
        grip.Size=UDim2.fromOffset(30,30)
        grip.BackgroundColor3=THEMES[currentName].hot
        grip.BackgroundTransparency=.05
        grip.BorderSizePixel=0
        grip.Text="↘"
        grip.TextColor3=THEMES[currentName].white
        grip.Font=Enum.Font.GothamBold
        grip.TextSize=16
        grip.AutoButtonColor=false
        grip.Active=true
        grip.ZIndex=250
        grip:SetAttribute("KimqResizeControl",true)
        corner(grip,9)
        outline(grip,THEMES[currentName].line,.18,1)

        local resizing=false
        local dragInput=nil
        local startMouse=nil
        local startSize=nil
        local MIN_W,MIN_H=720,460

        local function updateResize(input)
            if not resizing or not startMouse or not startSize then return end
            local delta=input.Position-startMouse
            local cam=workspace.CurrentCamera
            local viewport=cam and cam.ViewportSize or Vector2.new(1920,1080)
            local pos=main.AbsolutePosition
            local maxW=math.max(MIN_W,viewport.X-pos.X-10)
            local maxH=math.max(MIN_H,viewport.Y-pos.Y-10)
            local w=math.clamp(startSize.X+delta.X,MIN_W,maxW)
            local h=math.clamp(startSize.Y+delta.Y,MIN_H,maxH)
            main.Size=UDim2.fromOffset(math.floor(w+.5),math.floor(h+.5))
        end

        grip.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                resizing=true
                dragInput=input
                startMouse=input.Position
                startSize=main.AbsoluteSize
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then
                        resizing=false
                        dragInput=nil
                    end
                end)
            end
        end)
        grip.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
                dragInput=input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if resizing and (input==dragInput or input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                updateResize(input)
            end
        end)
    end

    applyTheme(currentName)
    _G.KimqV21FullThemeActive=true
    _G.KimqThemeEngineReady=true

    -- v2.62 reveal happens only after this initial theme pass is complete.
end)


-- v2.62: delayed post-show cleanup passes removed.
-- All essential routing/styling is completed before reveal.

-- ========================================================
-- v2.6 selected-config update + exact Fog / Atmosphere restore
-- ========================================================


-- ========================================================
-- v2.62 branding is deterministic at construction time; no delayed scrub pass.

-- v2.69 BOOT WATCHDOG -------------------------------------------------
-- If an optional late UI pass stalls, never leave the successfully-created
-- Kimqetras ScreenGui disabled forever. This only reveals existing UI; it does
-- not rebuild or restart any feature section.
task.delay(12,function()
    pcall(function()
        local PlayersW=game:GetService("Players")
        local CoreGuiW=game:GetService("CoreGui")
        local lpW=PlayersW.LocalPlayer
        local pgW=lpW and lpW:FindFirstChildOfClass("PlayerGui")
        local rootW=CoreGuiW:FindFirstChild("KimpetrasHC") or (pgW and pgW:FindFirstChild("KimpetrasHC"))
        if rootW then
            rootW.Enabled=false
            local mainW=rootW:FindFirstChild("Main")
            if mainW and _G.KimqMainUserVisibleState~=false then
                mainW.Visible=true
            end
        end
    end)
end)

-- ========================================================
-- v2.62 DETERMINISTIC REVEAL
-- Reveal the Lasion interface once its backend is constructed.
-- ========================================================
task.spawn(function()
    local Players=game:GetService("Players")
    local CoreGui=game:GetService("CoreGui")
    local lp=Players.LocalPlayer
    local pg=lp and lp:FindFirstChildOfClass("PlayerGui")

    local t0=tick()
    while (not _G.KimqThemeEngineReady
        or not _G.KimqV26FeaturesReady
        or not _G.KimqAccessoryUIReady)
        and tick()-t0<15 do
        task.wait(.03)
    end

    local root=CoreGui:FindFirstChild("KimpetrasHC") or (pg and pg:FindFirstChild("KimpetrasHC"))
    local main=root and root:FindFirstChild("Main")

    -- v2.62: remove the old one-page section divider labels from the
    -- actual content pages. The large page header already shows the name.
    if main then
        local pageHost=main:FindFirstChild("PageHost",true)
        local legacyHeaders={
            ["silent aim"]=true,["macro"]=true,["whitelist"]=true,
            ["protection"]=true,["anti fall"]=true,["delay changer"]=true,
            ["esp"]=true,["avatar"]=true,["combat"]=true,["force hit"]=true,
            ["hitbox expander"]=true,["flamelock"]=true,["camlock"]=true,
            ["visuals"]=true,["headless"]=true,["protection + anti mod"]=true,
            ["settings"]=true,["credits"]=true,["information"]=true,
            ["environment"]=true,["weapon skins"]=true,["fog / atmosphere"]=true,
            ["spawn point"]=true,
        }

        local function cleanLegacyHeader(text)
            text=tostring(text or ""):gsub("^%s+","")
            local first=text:sub(1,1)
            if first~="♥" and first~="♡" then return nil end
            text=text:gsub("^[♥♡]%s*","")
            text=text:gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$","")
            return text:lower()
        end

        if pageHost then
            for _,page in ipairs(pageHost:GetChildren()) do
                if page:IsA("ScrollingFrame") then
                    for _,obj in ipairs(page:GetDescendants()) do
                        if obj:IsA("TextLabel") then
                            local header=cleanLegacyHeader(obj.Text)
                            if header and legacyHeaders[header] then
                                -- Direct-child divider labels should vanish entirely.
                                -- Labels inside useful cards are removed without
                                -- deleting the rest of that card's controls/text.
                                pcall(function() obj:Destroy() end)
                            end
                        end
                    end
                end
            end
        end
    end

    -- ========================================================
    -- v2.62 FINAL SECTION OWNERSHIP GUARD
    --
    -- The rest of the script is already working, so do not "rediscover"
    -- feature locations from button text.  Seal the layout that survived
    -- the canonical routing pass and use creation-time KimqSection stamps
    -- whenever one exists.
    -- ========================================================
    if main then
        pcall(function()
            local pageHost=main:FindFirstChild("PageHost",true)
            if pageHost then
                local pagesByKey={}
                local pageKeyByInstance=setmetatable({}, {__mode="k"})

                for _,page in ipairs(pageHost:GetChildren()) do
                    if page:IsA("ScrollingFrame") and page.Name:match("Page$") then
                        local key=page.Name:gsub("Page$",""):lower()
                        pagesByKey[key]=page
                        pageKeyByInstance[page]=key
                    end
                end

                local function normalizeSection(section)
                    section=tostring(section or ""):lower()
                    if section=="forcehit" then return "hcsilent" end
                    if section=="headless" then return "avatar" end
                    return section
                end

                local guardBusy=false

                local function enforceDirectChild(page,child)
                    if guardBusy
                        or not page
                        or not child
                        or not child.Parent
                        or child:IsA("UIListLayout")
                        or child:IsA("UIPadding")
                    then
                        return
                    end

                    local currentKey=pageKeyByInstance[page]
                    if not currentKey then return end

                    local stamped=normalizeSection(child:GetAttribute("KimqSection"))

                    if stamped~="" and pagesByKey[stamped] then
                        local owner=pagesByKey[stamped]
                        if child.Parent~=owner then
                            guardBusy=true
                            child.Parent=owner
                            guardBusy=false
                        end
                    else
                        -- No ownership metadata: the card is already in a canonical
                        -- page at this late stage.  Preserve it exactly where it is.
                        child:SetAttribute("KimqSection",currentKey)
                    end
                end

                -- First seal every feature currently in the GUI.
                for _,page in pairs(pagesByKey) do
                    for _,child in ipairs(page:GetChildren()) do
                        enforceDirectChild(page,child)
                    end
                end

                -- Then protect dynamically-created cards (Whitelist entries,
                -- future refreshed cards, etc.) without using visual heuristics.
                for _,page in pairs(pagesByKey) do
                    page.ChildAdded:Connect(function(child)
                        task.defer(function()
                            if child and child.Parent then
                                enforceDirectChild(page,child)
                            end
                        end)
                    end)
                end

                _G.KimqSectionOwnershipReady=true
            end
        end)
    end

    if root then root.Enabled=false end
    if _G.KimqMainUserVisibleState==nil then _G.KimqMainUserVisibleState=true end
    pcall(function() if type(getgenv)=="function" then getgenv().KimqMainUserVisibleState=_G.KimqMainUserVisibleState end end)
    if main then main.Visible=(_G.KimqMainUserVisibleState~=false) end

    _G[KIMQ_SINGLE_KEY]=true
    _G.KimqHC_v21_PerformanceLoaded=true
    _G.KimqHC_CurrentBuild=KIMQ_BUILD
    _G.KimqHC_RuntimeState="ready"
    pcall(function()
        if type(getgenv)=="function" then
            local e=getgenv()
            e[KIMQ_SINGLE_KEY]=true
            e.KimqHC_v21_PerformanceLoaded=true
            e.KimqHC_CurrentBuild=KIMQ_BUILD
            e.KimqHC_RuntimeState="ready"
        end
    end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="Kimqetras HC",
            Text="v2.108 ACTIVE ♡ • RAGE now shoots through normal Silent Aim",
            Duration=7,
        })
    end)

    local boot=CoreGui:FindFirstChild("KimpetrasHC_Boot") or (pg and pg:FindFirstChild("KimpetrasHC_Boot"))
    if boot then pcall(function() boot:Destroy() end) end

end)



-- ========================================================
-- v2.107 COMPACT FEATURE PAGE ORGANIZER (VISUAL ONLY)
-- Disabled in v2.108. Replaced by page-specific labeled groups below.
-- ========================================================
task.spawn(function()
    if true then return end
    local Players=game:GetService("Players")
    local CoreGui=game:GetService("CoreGui")
    local lp=Players.LocalPlayer
    local pg=lp and lp:WaitForChild("PlayerGui",8)
    local t0=os.clock()
    while not _G.KimqSectionOwnershipReady and os.clock()-t0<12 do task.wait(.08) end

    local root=CoreGui:FindFirstChild("KimpetrasHC") or (pg and pg:FindFirstChild("KimpetrasHC"))
    local main=root and root:FindFirstChild("Main")
    local pageHost=main and main:FindFirstChild("PageHost",true)
    if not pageHost then return end

    local excluded={overview=true,settings=true,theme=true,info=true}
    local primary={
        avatar={"apply user avatar","reset to my avatar","keep avatar"},
        ragecam={"target queue","current target","select all","clear + stop"},
        rageorbit={"target orbit master","orbit target"},
        ragecombat={"rage combat master","auto shoot current target","auto stomp with e","lock on top while stomping"},
        ragepresets={"op rage presets","op all targets","op solo"},
        esp={"esp","enable"},macro={"macro","enable"},fog={"fog","atmosphere"},environment={"environment preset"},
        weaponskins={"weapon skin","apply"},whitelist={"whitelist"},protection={"protection"},
        antifall={"anti fall"},antimod={"anti mod"},spawn={"spawn"},delay={"delay"},
        camlock={"camlock"},flamelock={"flamelock"},hitbox={"hitbox"},silent={"silent aim"},hcsilent={"silent aim","hc"}
    }
    local optionWords={"auto ","wall check","knock check","stickiness","prediction","priority","skip ","whitelist","respawn","headless","accessor","anti lock","evasive","reload","stomp","advance","camera","view","orbit","queue","persist","keep ","mode","preset","light","shadow","day / night","color"}
    local tuningWords={"speed","radius","height","distance","smooth","strength","delay","interval","burst","chance","fov","size","density","power","attempt","repeat"," min"," max","frequency","scale","offset","rotation","softness","brightness","glow","darkness"}

    local function palette()
        local p=_G.KimqThemeLivePalette
        return type(p)=="table" and p or {soft=Color3.fromRGB(246,255,250),hot=Color3.fromRGB(243,161,211),text=Color3.fromRGB(82,116,94),line=Color3.fromRGB(255,212,243)}
    end
    local function rounded(o,r)
        local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner",o)
        c.CornerRadius=UDim.new(0,r or 10)
    end
    local function outlined(o,c,t)
        local st=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",o)
        st.Color=c; st.Transparency=t or .4; st.Thickness=1
    end
    local function allText(o)
        local out={}
        if (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and tostring(o.Text or "")~="" then table.insert(out,string.lower(tostring(o.Text))) end
        for _,d in ipairs(o:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and tostring(d.Text or "")~="" then table.insert(out,string.lower(tostring(d.Text))) end
        end
        return table.concat(out,"  ")
    end
    local function hasAny(txt,arr)
        for _,v in ipairs(arr or {}) do if txt:find(v,1,true) then return true end end
        return false
    end
    local function groupFor(key,txt)
        if hasAny(txt,primary[key]) or txt:find("master",1,true) then return 1 end
        if hasAny(txt,tuningWords) then return 3 end
        return 2
    end

    _G.KimqCompactGroups=_G.KimqCompactGroups or {}

    for _,page in ipairs(pageHost:GetChildren()) do
        if page:IsA("ScrollingFrame") and page.Name:match("Page$") then
            local key=page.Name:gsub("Page$",""):lower()
            if not excluded[key] then
                local list=page:FindFirstChildOfClass("UIListLayout")
                if list then list.Padding=UDim.new(0,6); list.SortOrder=Enum.SortOrder.LayoutOrder end

                -- Remove only organizer decorations from older builds.
                for _,ch in ipairs(page:GetChildren()) do
                    if ch:GetAttribute("KimqOrganizerDecor") then pcall(function() ch:Destroy() end) end
                end

                local groups={[1]={},[2]={},[3]={}}
                local cards={}
                for _,ch in ipairs(page:GetChildren()) do
                    if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                        local g=groupFor(key,allText(ch))
                        local e={obj=ch,old=ch.LayoutOrder,group=g,baseVisible=ch.Visible}
                        table.insert(cards,e); table.insert(groups[g],e)
                        if ch:IsA("Frame") then
                            local p=palette(); rounded(ch,12); outlined(ch,p.line,.42)
                        end
                    end
                end

                table.sort(cards,function(a,b)
                    if a.group~=b.group then return a.group<b.group end
                    if a.old~=b.old then return a.old<b.old end
                    return a.obj.Name<b.obj.Name
                end)
                for i,e in ipairs(cards) do e.obj.LayoutOrder=e.group*1000+i*10 end

                local names={[1]="CORE",[2]="OPTIONS",[3]="TUNING"}
                for g=1,3 do
                    if #groups[g]>0 then
                        local stateKey=key..":"..g
                        if _G.KimqCompactGroups[stateKey]==nil then
                            -- Keep important controls visible; collapse dense numeric
                            -- tuning by default. One click opens it instantly.
                            _G.KimqCompactGroups[stateKey]=(g==3 and key~="environment")
                        end
                        local collapsed=_G.KimqCompactGroups[stateKey]
                        local p=palette()
                        local bar=Instance.new("TextButton",page)
                        bar.Name="KimqCompactGroup"..g; bar:SetAttribute("KimqOrganizerDecor",true); bar:SetAttribute("KimqV26Role","lightBg")
                        bar.LayoutOrder=g*1000-10; bar.Size=UDim2.new(1,-6,0,26); bar.BackgroundColor3=p.soft; bar.BorderSizePixel=0
                        bar.AutoButtonColor=false; bar.Font=Enum.Font.GothamBold; bar.TextSize=9; bar.TextColor3=p.hot; bar.TextXAlignment=Enum.TextXAlignment.Left
                        rounded(bar,9); outlined(bar,p.line,.5)
                        local arrow=Instance.new("TextLabel",bar); arrow.Name="Arrow"; arrow.BackgroundTransparency=1; arrow.Size=UDim2.fromOffset(30,26); arrow.Position=UDim2.new(1,-34,0,0); arrow.Font=Enum.Font.GothamBold; arrow.TextSize=11; arrow.TextColor3=p.hot; arrow:SetAttribute("KimqV26Role","hotText")

                        local function applyGroup()
                            collapsed=_G.KimqCompactGroups[stateKey]==true
                            bar.Text="   "..names[g].."   ·   "..tostring(#groups[g])
                            arrow.Text=collapsed and "+" or "–"
                            for _,e in ipairs(groups[g]) do
                                e.obj.Visible=(not collapsed) and e.baseVisible or false
                            end
                        end
                        bar.MouseButton1Click:Connect(function()
                            _G.KimqCompactGroups[stateKey]=not (_G.KimqCompactGroups[stateKey]==true)
                            applyGroup()
                        end)
                        applyGroup()
                    end
                end
            end
        end
    end
end)


-- ================================================================
-- v2.108 PAGE-SPECIFIC FEATURE GROUPS
-- Adds real little category headers + explanations INSIDE each page.
-- Feature cards are never recreated, so their callbacks/config stay intact.
-- =====================================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")

    local t0 = tick()
    while (not _G.KimqV26Ready or not _G.KimqThemeEngineReady) and tick() - t0 < 24 do
        task.wait(.08)
    end

    local root = CoreGui:FindFirstChild("KimpetrasHC") or pg:FindFirstChild("KimpetrasHC")
    local main = root and root:FindFirstChild("Main")
    local pageHost = main and main:FindFirstChild("PageHost", true)
    if not main or not pageHost or main:FindFirstChild("KimqDetailedGroupsV108") then return end

    local mark = Instance.new("BoolValue")
    mark.Name = "KimqDetailedGroupsV108"
    mark.Parent = main

    local function P()
        return _G.KimqThemeLivePalette or {
            hot=Color3.fromRGB(169,116,235),
            hot2=Color3.fromRGB(229,210,251),
            bg=Color3.fromRGB(246,239,255),
            bg2=Color3.fromRGB(251,247,255),
            panel=Color3.new(1,1,1),
            soft=Color3.fromRGB(252,249,255),
            text=Color3.fromRGB(102,77,126),
            sub=Color3.fromRGB(143,119,164),
            line=Color3.fromRGB(226,208,244),
            white=Color3.new(1,1,1),
        }
    end

    local function corner(o,r)
        local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner",o)
        c.CornerRadius=UDim.new(0,r or 8)
        return c
    end

    local function stroke(o,c,tr)
        local s=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",o)
        s.Color=c
        s.Transparency=tr or .48
        s.Thickness=1
        return s
    end

    local function lower(s)
        return tostring(s or ""):lower()
    end

    local function objectText(o)
        local parts={}
        if (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and tostring(o.Text or "")~="" then
            table.insert(parts,lower(o.Text))
        end
        for _,d in ipairs(o:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and tostring(d.Text or "")~="" then
                table.insert(parts,lower(d.Text))
            end
        end
        return table.concat(parts,"  ")
    end

    local function any(txt, words)
        for _,w in ipairs(words or {}) do
            if txt:find(w,1,true) then return true end
        end
        return false
    end

    -- Each page gets human-readable little categories instead of one long wall
    -- of controls. Match order matters: more specific groups come first.
    local GROUPS = {
        hcsilent = {
            {title="MAIN AIM", desc="Turn HC aim behavior on and choose the safety checks.", words={"hc silent aim","revolver bypass","wall check","knock check"}},
            {title="TARGET AREA", desc="Choose where the shot aims and how large the targeting area is.", words={"fov","hit part","closest part","priority","max distance","stickiness"}},
            {title="PREDICTION", desc="Fine-tune lead and movement prediction for moving targets.", words={"prediction","pred x","pred y","auto prediction","strength"}},
            {title="ADVANCED", desc="Extra HC aim behavior and fine adjustments.", fallback=true},
        },
        silent = {
            {title="TARGETING", desc="Main Silent Aim target selection and hit settings.", words={"silent aim","hit chance","hit part","closest part","priority"}},
            {title="FOV & CHECKS", desc="Control the target area and which players are considered valid.", words={"fov","wall check","knock check","team check","max distance","stickiness"}},
            {title="PREDICTION", desc="Adjust aim lead for player movement and ping.", words={"prediction","pred x","pred y","auto prediction","strength"}},
            {title="EXTRAS", desc="Additional Silent Aim options.", fallback=true},
        },
        camlock = {
            {title="CAMLOCK", desc="Main camera-lock controls and target behavior.", words={"camlock","enable","keybind","target"}},
            {title="SMOOTHING", desc="Control how quickly and smoothly the camera follows.", words={"smooth","speed","lerp"}},
            {title="CHECKS", desc="Choose when a target should or should not be locked.", words={"wall","knock","team","distance","health"}},
            {title="OFFSETS", desc="Fine-tune camera position and prediction.", fallback=true},
        },
        flamelock = {
            {title="FLAMELOCK", desc="Main lock controls and target selection.", words={"flamelock","enable","target","keybind"}},
            {title="AIM FEEL", desc="Smoothing, prediction, and movement behavior.", words={"smooth","prediction","strength","speed"}},
            {title="OFFSETS", desc="Fine-tune horizontal and vertical aim placement.", words={"offset","x ","y ","horizontal","vertical"}},
            {title="CHECKS", desc="Extra conditions used while locking.", fallback=true},
        },
        hitbox = {
            {title="HITBOX", desc="Turn the hitbox expander on and choose what it affects.", words={"hitbox","enable","part"}},
            {title="SIZE", desc="Adjust hitbox dimensions and range.", words={"size","scale","radius","height","width"}},
            {title="VISUALS", desc="Control visibility and appearance of expanded hitboxes.", fallback=true},
        },
        delay = {
            {title="DELAY", desc="Change weapon timing and cooldown behavior.", words={"delay","cooldown","interval"}},
            {title="WEAPON OPTIONS", desc="Extra timing settings for supported weapons.", fallback=true},
        },
        fog = {
            {title="FOG", desc="Control fog distance, density, and overall visibility.", words={"fog","density","distance","start","end"}},
            {title="ATMOSPHERE", desc="Adjust atmosphere strength and environmental feel.", words={"atmosphere","haze","glare"}},
            {title="COLORS", desc="Pick the fog and atmosphere colors you want.", words={"color","saturation","tint"}},
            {title="EXTRAS", desc="Additional visual environment controls.", fallback=true},
        },
        environment = {
            {title="TIME", desc="Choose day, night, or the normal game time.", words={"day","night","time","clock"}},
            {title="SEASONS", desc="Apply seasonal map styles and effects.", words={"normal","halloween","christmas","season","snow"}},
            {title="LIGHTING", desc="Fine-tune brightness, shadows, and environmental lighting.", fallback=true},
        },
        esp = {
            {title="ESP", desc="Turn player ESP elements on or off.", words={"esp","enable","boxes","names","health","tracers"}},
            {title="APPEARANCE", desc="Choose how ESP looks on your screen.", words={"color","thickness","opacity","filled"}},
            {title="RANGE", desc="Adjust ESP distance and visibility rules.", fallback=true},
        },
        avatar = {
            {title="AVATAR COPY", desc="Copy or reset an avatar using player or asset information.", words={"avatar","copy","user","reset"}},
            {title="ACCESSORIES", desc="Wear local accessories and catalog items.", words={"accessor","asset","wear","head accessory"}},
            {title="HEADLESS", desc="Client-side headless and related character visuals.", words={"headless"}},
            {title="EXTRAS", desc="Additional avatar options.", fallback=true},
        },
        weaponskins = {
            {title="WEAPON", desc="Choose the weapon you want to customize.", words={"weapon","select weapon"}},
            {title="SKIN", desc="Browse and apply a client-side weapon skin.", words={"skin","wrap","apply"}},
            {title="BULLETS & KNIVES", desc="Customize supported bullet and knife visuals.", words={"bullet","knife","ray"}},
            {title="EXTRAS", desc="Other weapon visual options.", fallback=true},
        },
        whitelist = {
            {title="PLAYERS", desc="Choose players that targeting and ESP should ignore.", words={"whitelist","player","username","user"}},
            {title="WHITELIST", desc="Add, remove, and review ignored players.", fallback=true},
        },
        protection = {
            {title="PROTECTION", desc="Main defensive and anti-aim-view controls.", words={"protection","anti aim","anti-aim","view"}},
            {title="BEHAVIOR", desc="Adjust how protection reacts while enabled.", fallback=true},
        },
        antifall = {
            {title="ANTI FALL", desc="Prevent unwanted falling or recover from fall states.", words={"anti fall","fall"}},
            {title="RECOVERY", desc="Adjust recovery behavior and timing.", fallback=true},
        },
        antimod = {
            {title="ANTI MOD", desc="Detect moderation-related players or conditions.", words={"anti mod","mod","staff"}},
            {title="ACTION", desc="Choose what the script does after a detection.", words={"kick","leave","notify","action"}},
            {title="EXTRAS", desc="Additional anti-mod behavior.", fallback=true},
        },
        spawn = {
            {title="SPAWN POINT", desc="Choose and save where you return after respawning.", words={"spawn","save","position"}},
            {title="RESPAWN", desc="Control how the saved spawn point is used.", fallback=true},
        },
        macro = {
            {title="MACRO", desc="Turn the movement macro on and choose how it behaves.", words={"macro","enable","toggle"}},
            {title="SPEED", desc="Adjust movement speed and macro timing.", words={"speed","delay","interval"}},
            {title="EXTRAS", desc="Additional macro controls.", fallback=true},
        },
        ragecam = {
            {title="TARGET QUEUE", desc="Choose who RAGE should target and manage the queue.", words={"target queue","current target","select all","clear"}},
            {title="LOCK", desc="Control target lock and persistence through respawns.", words={"lock","respawn","persist"}},
            {title="EXTRAS", desc="Additional RAGE camlock controls.", fallback=true},
        },
        rageorbit = {
            {title="ORBIT", desc="Turn target orbit on and control how it moves.", words={"orbit","master","enable"}},
            {title="MOVEMENT", desc="Adjust orbit speed, radius, height, and direction.", words={"speed","radius","height","distance","rotation"}},
            {title="EXTRAS", desc="Additional orbit behavior.", fallback=true},
        },
        ragecombat = {
            {title="RAGE COMBAT", desc="Main combat automation controls.", words={"rage combat master","auto shoot","attack"}},
            {title="STOMP", desc="Control finishing behavior after a target is downed.", words={"stomp","finish","e"}},
            {title="QUEUE FLOW", desc="Choose how RAGE moves to the next target.", words={"advance","queue","next target"}},
            {title="TIMING", desc="Fine-tune attack timing and repeat behavior.", fallback=true},
        },
        ragepresets = {
            {title="PRESETS", desc="One-click RAGE setups for different situations.", words={"preset","op all","op solo","calm"}},
            {title="PRESET OPTIONS", desc="Extra settings used by the selected preset.", fallback=true},
        },
    }

    local excluded = {overview=true,theme=true,settings=true,info=true}

    local function clearOldHeaders(page)
        for _,ch in ipairs(page:GetChildren()) do
            if ch:GetAttribute("KimqDetailedGroupHeader")==true then
                ch:Destroy()
            end
        end
    end

    local function makeHeader(page,title,desc,order)
        local p=P()
        local f=Instance.new("Frame")
        f.Name="KimqFeatureGroupHeader"
        f:SetAttribute("KimqDetailedGroupHeader",true)
        f:SetAttribute("KimqThemeSkip",true)
        f.LayoutOrder=order
        f.Size=UDim2.new(1,-6,0,46)
        f.BackgroundColor3=p.bg2
        f.BorderSizePixel=0
        f.Parent=page
        corner(f,8)
        stroke(f,p.line,.30)

        local accent=Instance.new("Frame")
        accent.Name="Accent"
        accent.Size=UDim2.fromOffset(4,26)
        accent.Position=UDim2.fromOffset(10,10)
        accent.BackgroundColor3=p.hot
        accent.BorderSizePixel=0
        accent.Parent=f
        corner(accent,99)

        local titleLabel=Instance.new("TextLabel")
        titleLabel.Name="GroupTitle"
        titleLabel.BackgroundTransparency=1
        titleLabel.Position=UDim2.fromOffset(24,6)
        titleLabel.Size=UDim2.new(1,-34,0,17)
        titleLabel.Text=title
        titleLabel.Font=Enum.Font.GothamBold
        titleLabel.TextSize=11
        titleLabel.TextColor3=p.text
        titleLabel.TextXAlignment=Enum.TextXAlignment.Left
        titleLabel.Parent=f

        local descLabel=Instance.new("TextLabel")
        descLabel.Name="GroupDescription"
        descLabel.BackgroundTransparency=1
        descLabel.Position=UDim2.fromOffset(24,23)
        descLabel.Size=UDim2.new(1,-34,0,16)
        descLabel.Text=desc
        descLabel.Font=Enum.Font.Gotham
        descLabel.TextSize=9
        descLabel.TextColor3=p.sub
        descLabel.TextXAlignment=Enum.TextXAlignment.Left
        descLabel.TextTruncate=Enum.TextTruncate.AtEnd
        descLabel.Parent=f

        return f
    end

    local function chooseGroup(groups,txt)
        local fallback=#groups
        for i,g in ipairs(groups) do
            if g.fallback then
                fallback=i
            elseif any(txt,g.words) then
                return i
            end
        end
        return fallback
    end

    local groupedPages={}

    local function organizePage(page)
        if not page or not page:IsA("ScrollingFrame") then return end

        local key=page.Name:gsub("Page$",""):lower()
        local groups=GROUPS[key]
        if excluded[key] or not groups then return end

        clearOldHeaders(page)

        local list=page:FindFirstChildOfClass("UIListLayout")
        if list then
            list.SortOrder=Enum.SortOrder.LayoutOrder
            list.Padding=UDim.new(0,7)
        end

        local buckets={}
        for i=1,#groups do buckets[i]={} end

        -- Only real existing feature rows/cards are reorganized.
        local original={}
        for _,ch in ipairs(page:GetChildren()) do
            if ch:IsA("GuiObject")
                and not ch:IsA("UIListLayout")
                and not ch:IsA("UIPadding")
                and ch:GetAttribute("KimqDetailedGroupHeader")~=true
                and ch:GetAttribute("KimqOrganizerDecor")~=true then

                table.insert(original,{
                    obj=ch,
                    old=tonumber(ch.LayoutOrder) or 0,
                    txt=objectText(ch),
                })
            end
        end

        table.sort(original,function(a,b)
            if a.old~=b.old then return a.old<b.old end
            return a.obj.Name<b.obj.Name
        end)

        for _,entry in ipairs(original) do
            local gi=chooseGroup(groups,entry.txt)
            table.insert(buckets[gi],entry)
        end

        local order=0
        for gi,g in ipairs(groups) do
            if #buckets[gi]>0 then
                order+=100
                makeHeader(page,g.title,g.desc,order)

                for _,entry in ipairs(buckets[gi]) do
                    order+=1
                    entry.obj.LayoutOrder=order
                    entry.obj.Visible=true
                end
            end
        end

        groupedPages[page]=true
    end

    local function refreshHeaderColors()
        local p=P()
        for page in pairs(groupedPages) do
            if page and page.Parent then
                for _,f in ipairs(page:GetChildren()) do
                    if f:GetAttribute("KimqDetailedGroupHeader")==true then
                        f.BackgroundColor3=p.bg2
                        local st=f:FindFirstChildOfClass("UIStroke")
                        if st then st.Color=p.line end
                        local accent=f:FindFirstChild("Accent")
                        if accent then accent.BackgroundColor3=p.hot end
                        local tl=f:FindFirstChild("GroupTitle")
                        if tl then tl.TextColor3=p.text end
                        local dl=f:FindFirstChild("GroupDescription")
                        if dl then dl.TextColor3=p.sub end
                    end
                end
            end
        end
    end

    -- Wait one extra beat so all late section repair moves are finished.
    task.wait(.35)

    for _,page in ipairs(pageHost:GetChildren()) do
        if page:IsA("ScrollingFrame") and page.Name:match("Page$") then
            organizePage(page)
        end
    end

    -- If a feature page receives a late-created control, regroup that ONE page only.
    for page in pairs(groupedPages) do
        page.ChildAdded:Connect(function(ch)
            if ch:GetAttribute("KimqDetailedGroupHeader")==true then return end
            if ch:IsA("GuiObject") then
                task.delay(.10,function()
                    if page.Parent then organizePage(page) end
                end)
            end
        end)
    end

    -- Recolor the little headers after a theme choice without rescanning the GUI.
    local themePage=pageHost:FindFirstChild("themePage")
    if themePage then
        for _,b in ipairs(themePage:GetDescendants()) do
            if b:IsA("TextButton") then
                b.MouseButton1Click:Connect(function()
                    task.delay(.12,refreshHeaderColors)
                end)
            end
        end
    end

    refreshHeaderColors()
end)




end -- backend boot / existing backend reuse

-- =====================================================================
-- =====================================================================
-- KIMQETRAS HC x LASION
-- Lightweight rebuild using Lasion's recovered measurements/colors/fonts.
-- NO legacy Kimqetras GUI is used visually.
-- =====================================================================
task.spawn(function()
    pcall(function()
        if type(_G.KimqBootSetStatus)=="function" then
            _G.KimqBootSetStatus("Opening interface...")
        end
    end)
    local Players=game:GetService("Players")
    local CoreGui=game:GetService("CoreGui")
    local UIS=game:GetService("UserInputService")
    local RS=game:GetService("ReplicatedStorage")
    local lp=Players.LocalPlayer
    local pg=lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui")

    -- v6.10: show immediate feedback so a slow backend never looks like a dead execute.
    local bootGui=Instance.new("ScreenGui")
    bootGui.Name="KimqetrasHC_Startup"
    bootGui.ResetOnSpawn=false
    bootGui.IgnoreGuiInset=false
    local bootParentOk=pcall(function() bootGui.Parent=CoreGui end)
    if not bootParentOk or not bootGui.Parent then bootGui.Parent=pg end
    local bootFrame=Instance.new("Frame")
    bootFrame.Size=UDim2.fromOffset(280,58)
    bootFrame.Position=UDim2.new(.5,-140,.08,0)
    bootFrame.BackgroundColor3=Color3.fromRGB(22,22,28)
    bootFrame.BorderSizePixel=0
    bootFrame.Parent=bootGui
    local bootCorner=Instance.new("UICorner")
    bootCorner.CornerRadius=UDim.new(0,10)
    bootCorner.Parent=bootFrame
    local bootStroke=Instance.new("UIStroke")
    bootStroke.Color=Color3.fromRGB(169,116,235)
    bootStroke.Transparency=.15
    bootStroke.Parent=bootFrame
    local bootText=Instance.new("TextLabel")
    bootText.BackgroundTransparency=1
    bootText.Size=UDim2.new(1,-20,1,-12)
    bootText.Position=UDim2.fromOffset(10,6)
    bootText.Font=Enum.Font.GothamSemibold
    bootText.TextSize=14
    bootText.TextColor3=Color3.fromRGB(245,238,255)
    bootText.TextWrapped=true
    bootText.Text="Kimqetras HC loading..."
    bootText.Parent=bootFrame

    local t0=os.clock()
    repeat
        task.wait(.05)
    until (
        type(_G.KimqConfigControls)=="table"
        and next(_G.KimqConfigControls)~=nil
        and type(_G.KimpetrasKIMBackend)=="table"
        and (
            _G.KimqHC_RuntimeState=="ready"
            or _G.KimqV26FeaturesReady==true
        )
    ) or os.clock()-t0>10
    local backendReady = type(_G.KimqConfigControls)=="table"
        and next(_G.KimqConfigControls)~=nil
        and type(_G.KimpetrasKIMBackend)=="table"
        and (_G.KimqHC_RuntimeState=="ready" or _G.KimqV26FeaturesReady==true)
    if not backendReady then
        _G.KimqLasionLastError="Backend did not become ready within 10 seconds; the interface will still open so you can see the error"
        warn("[Kimqetras HC / Lasion] ".._G.KimqLasionLastError)
        if bootText and bootText.Parent then bootText.Text="Kimqetras HC backend issue - opening UI..." end
    else
        if bootText and bootText.Parent then bootText.Text="Kimqetras HC ready..." end
    end

    -- Keep the legacy interface permanently invisible. Its callbacks/controllers remain alive.
    local function hideLegacy()
        for _,parent in ipairs({CoreGui,pg}) do
            local g=parent and parent:FindFirstChild("KimpetrasHC")
            if g then
                pcall(function() g.Enabled=false end)
                local m=g:FindFirstChild("Main")
                if m then pcall(function() m.Visible=false end) end
            end
        end
    end
    hideLegacy()
    task.spawn(function()
        for _=1,50 do hideLegacy(); task.wait(.1) end
    end)

    for _,parent in ipairs({CoreGui,pg}) do
        local old=parent and parent:FindFirstChild("KimqetrasHC_Lasion")
        if old then pcall(function() old:Destroy() end) end
        local oldW=parent and parent:FindFirstChild("KimqetrasHC_LasionWatermark")
        if oldW then pcall(function() oldW:Destroy() end) end
        local oldS=parent and parent:FindFirstChild("KimqetrasHC_Startup")
        if oldS then pcall(function() oldS:Destroy() end) end
        local oldI=parent and parent:FindFirstChild("KimqetrasHC_ImmediateBoot")
        if oldI then pcall(function() oldI:Destroy() end) end
    end

    ----------------------------------------------------------------------
    -- EXACT LASION VISUAL CONSTANTS FROM THE RECOVERED LIVE GUI
    ----------------------------------------------------------------------
    local COL={
        main=Color3.fromRGB(22,22,28),
        main2=Color3.fromRGB(28,28,35),
        main3=Color3.fromRGB(20,20,26),
        section=Color3.fromRGB(30,30,38),
        field=Color3.fromRGB(28,28,36),
        field2=Color3.fromRGB(24,24,30),
        track=Color3.fromRGB(38,38,48),
        stroke=Color3.fromRGB(55,55,68),
        accent=Color3.fromRGB(200,40,40),
        accentFill=Color3.fromRGB(210,45,45),
        accentStroke=Color3.fromRGB(230,70,70),
        accentDark=Color3.fromRGB(80,10,15),
        text=Color3.fromRGB(255,255,255),
        sub=Color3.fromRGB(160,160,175),
        dim=Color3.fromRGB(150,150,150),
        tab=Color3.fromRGB(195,195,195),
        title=Color3.fromRGB(168,168,168),
        subtitle=Color3.fromRGB(100,100,115),
        value=Color3.fromRGB(220,220,220),
    }

    local Gotham=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    local GothamBold=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
    local Source=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)

    local function corner(o,r)
        local c=Instance.new("UICorner")
        c.CornerRadius=UDim.new(0,r)
        c.Parent=o
        return c
    end
    local function stroke(o,color,trans,thickness)
        local s=Instance.new("UIStroke")
        s.Color=color or COL.stroke
        s.Transparency=trans or 0
        s.Thickness=thickness or 1
        s.LineJoinMode=Enum.LineJoinMode.Round
        s.Parent=o
        return s
    end
    local function pad(o,l,r,t,b)
        local p=Instance.new("UIPadding")
        p.PaddingLeft=UDim.new(0,l or 0)
        p.PaddingRight=UDim.new(0,r or 0)
        p.PaddingTop=UDim.new(0,t or 0)
        p.PaddingBottom=UDim.new(0,b or 0)
        p.Parent=o
        return p
    end
    local function text(parent,txt,size,pos,textSize,color,font,xalign)
        local l=Instance.new("TextLabel")
        l.BackgroundTransparency=1
        l.BorderSizePixel=0
        l.Text=tostring(txt or "")
        l.Size=size
        l.Position=pos or UDim2.new()
        l.TextSize=textSize or 12
        l.TextColor3=color or COL.text
        l.TextTransparency=0
        l.TextXAlignment=xalign or Enum.TextXAlignment.Left
        l.TextYAlignment=Enum.TextYAlignment.Center
        l.FontFace=font or Gotham
        l.Parent=parent
        return l
    end

    ----------------------------------------------------------------------
    -- ROOT + MAIN WINDOW: recovered Lasion geometry
    ----------------------------------------------------------------------
    local gui=Instance.new("ScreenGui")
    gui.Name="KimqetrasHC_Lasion"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=false
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent=CoreGui end)
    if not gui.Parent then gui.Parent=pg end
    task.delay(.35,function() if bootGui and bootGui.Parent then pcall(function() bootGui:Destroy() end) end end)

    local main=Instance.new("Frame")
    main.Name="Frame"
    main.AnchorPoint=Vector2.new(.5,.5)
    main.Position=UDim2.fromScale(.5,.5)
    main.Size=UDim2.fromOffset(550,600)
    main.BackgroundColor3=COL.main
    main.BackgroundTransparency=.2
    main.BorderSizePixel=0
    main.Active=true
    main.Parent=gui
    corner(main,12)
    stroke(main,COL.accent,.4,1.5)

    local mg=Instance.new("UIGradient")
    mg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(28,28,35)),
        ColorSequenceKeypoint.new(.5,Color3.fromRGB(24,24,30)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(20,20,26))
    })
    mg.Rotation=45
    mg.Parent=main

    -- Lasion uses a second full-size translucent glass layer over the main frame.
    local glass=Instance.new("Frame")
    glass.Name="Frame"
    glass.Position=UDim2.new(0,0,0,0)
    glass.Size=UDim2.new(1,0,1,0)
    glass.BackgroundColor3=Color3.fromRGB(22,22,28)
    glass.BackgroundTransparency=.25
    glass.BorderSizePixel=0
    glass.Parent=main
    corner(glass,12)
    local glassGradient=Instance.new("UIGradient")
    glassGradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
    glassGradient.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.15),
        NumberSequenceKeypoint.new(.5,.25),
        NumberSequenceKeypoint.new(1,.35)
    })
    glassGradient.Rotation=135
    glassGradient.Parent=glass

    local header=Instance.new("Frame")
    header.Name="Header"
    header.Size=UDim2.new(1,0,0,48)
    header.BackgroundTransparency=1
    header.Active=true
    header.ZIndex=2
    header.Parent=main

    text(header,"Kimqetras HC",UDim2.new(1,-30,1,0),UDim2.fromOffset(15,0),20,COL.title,Gotham,Enum.TextXAlignment.Center)

    -- Dragging.
    do
        local drag=false
        local startMouse,startPos
        header.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true; startMouse=i.Position; startPos=main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-startMouse
                main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
        end)
    end

    ----------------------------------------------------------------------
    -- EXACT LASION TOP TAB BAR
    ----------------------------------------------------------------------
    local tabBar=Instance.new("Frame")
    tabBar.Name="Tabs"
    tabBar.Position=UDim2.fromOffset(15,58)
    tabBar.Size=UDim2.new(1,-30,0,35)
    tabBar.BackgroundColor3=COL.main
    tabBar.BackgroundTransparency=.5
    tabBar.BorderSizePixel=0
    tabBar.ZIndex=2
    tabBar.Parent=main
    corner(tabBar,6)
    stroke(tabBar,COL.stroke,.6,1)
    local tgrad=Instance.new("UIGradient")
    tgrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.4),
        NumberSequenceKeypoint.new(.5,.5),
        NumberSequenceKeypoint.new(1,.6)
    })
    tgrad.Rotation=90
    tgrad.Parent=tabBar
    pad(tabBar,7,7,4,0)

    local tl=Instance.new("UIListLayout")
    tl.FillDirection=Enum.FillDirection.Horizontal
    tl.Padding=UDim.new(0,8)
    tl.VerticalAlignment=Enum.VerticalAlignment.Top
    tl.SortOrder=Enum.SortOrder.LayoutOrder
    tl.Parent=tabBar

    local host=Instance.new("Frame")
    host.Position=UDim2.fromOffset(15,103)
    host.Size=UDim2.new(1,-30,1,-108)
    host.BackgroundTransparency=1
    host.ZIndex=2
    host.Parent=main

    local TAB_NAMES={"Player","Visuals","Atmosphere","Combat","Utilities","Settings"}
    local pages={}
    local tabButtons={}

    local function page(name)
        local root=Instance.new("Frame")
        root.Name=name.."Page"
        root.Size=UDim2.fromScale(1,1)
        root.BackgroundColor3=COL.main
        root.BackgroundTransparency=.5
        root.BorderSizePixel=0
        root.Visible=false
        root.Parent=host
        corner(root,8)
        stroke(root,COL.stroke,.6,1)
        local g=Instance.new("UIGradient")
        g.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.45),
            NumberSequenceKeypoint.new(.5,.5),
            NumberSequenceKeypoint.new(1,.55)
        })
        g.Rotation=135
        g.Parent=root

        local columns=Instance.new("Frame")
        columns.Size=UDim2.fromScale(1,1)
        columns.BackgroundTransparency=1
        columns.Parent=root

        local function col(side)
            local c=Instance.new("ScrollingFrame")
            c.Name=side
            if side=="left" then
                c.Position=UDim2.new(0,0,0,0)
                c.Size=UDim2.new(.5,-5,1,0)
            else
                c.Position=UDim2.new(.5,5,0,0)
                c.Size=UDim2.new(.5,-5,1,0)
            end
            c.BackgroundTransparency=1
            c.BorderSizePixel=0
            c.ClipsDescendants=true
            c.AutomaticCanvasSize=Enum.AutomaticSize.Y
            c.CanvasSize=UDim2.new(0,0,2,0)
            c.ScrollBarThickness=0
            c.ScrollBarImageColor3=Color3.new(1,1,1)
            c.ScrollBarImageTransparency=0
            c.ScrollingDirection=Enum.ScrollingDirection.XY
            c.Parent=columns

            local l=Instance.new("UIListLayout")
            l.Padding=UDim.new(0,8)
            l.SortOrder=Enum.SortOrder.LayoutOrder
            l.Parent=c
            if side=="left" then pad(c,10,5,10,10) else pad(c,5,10,10,10) end
            return c
        end

        pages[name]={root=root,left=col("left"),right=col("right"),sections={}}
    end

    for _,n in ipairs(TAB_NAMES) do page(n) end

    ----------------------------------------------------------------------
    local function showPage(name)
        for _,n in ipairs(TAB_NAMES) do
            pages[n].root.Visible=(n==name)
            local b=tabButtons[n]
            if b then b.TextTransparency=(n==name) and 0 or .5 end
        end
    end

    for i,n in ipairs(TAB_NAMES) do
        local b=Instance.new("TextButton")
        b.Name=n
        b.AutomaticSize=Enum.AutomaticSize.X
        b.Size=UDim2.fromOffset(10,24)
        b.BackgroundTransparency=1
        b.BorderSizePixel=0
        b.Text=n
        b.TextColor3=COL.tab
        b.TextTransparency=(i==1) and 0 or .5
        b.TextSize=13
        b.FontFace=Gotham
        b.AutoButtonColor=true
        b.LayoutOrder=i
        b.Parent=tabBar
        b.MouseButton1Click:Connect(function()
            showPage(n)
        end)
        tabButtons[n]=b
    end

    ----------------------------------------------------------------------
    -- LASION SECTION + CONTROL BUILDERS
    ----------------------------------------------------------------------
    local refreshers={}
    local keybindListening=nil
    local toggleKeyActions={}
    local runtimeStatus=nil
    local function reportControlIssue(name,err)
        local message=tostring(name or "Control")..": "..tostring(err or "did not apply")
        _G.KimqLasionLastError=message
        warn("[Kimqetras HC / Lasion] "..message)
        if runtimeStatus and runtimeStatus.Parent then
            runtimeStatus.Text="Issue: "..message:sub(1,160)
            runtimeStatus.TextColor3=Color3.fromRGB(255,155,155)
        end
    end

    UIS.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        if keybindListening and input.UserInputType==Enum.UserInputType.Keyboard then
            local rec=keybindListening
            keybindListening=nil
            if rec.old then toggleKeyActions[rec.old]=nil end
            rec.old=input.KeyCode
            rec.label.Text=input.KeyCode.Name
            toggleKeyActions[input.KeyCode]=rec.action
            return
        end
        local action=toggleKeyActions[input.KeyCode]
        if action then pcall(action) end
    end)

    local function section(tab,title,side)
        local pgx=pages[tab]
        if pgx.sections[title] then return pgx.sections[title] end
        local parent=(side=="right") and pgx.right or pgx.left

        local s=Instance.new("Frame")
        s.Name=title.."Section"
        s.Size=UDim2.new(1,0,0,40)
        s.BackgroundColor3=COL.section
        s.BackgroundTransparency=.4
        s.BorderSizePixel=0
        s.Parent=parent
        corner(s,8)
        stroke(s,COL.stroke,.6,1)
        local sg=Instance.new("UIGradient")
        sg.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.3),
            NumberSequenceKeypoint.new(.5,.4),
            NumberSequenceKeypoint.new(1,.5)
        })
        sg.Rotation=45
        sg.Parent=s

        text(s,title,UDim2.new(1,-16,0,20),UDim2.fromOffset(8,6),12,COL.text,Gotham,Enum.TextXAlignment.Left)

        local body=Instance.new("Frame")
        body.Name="Body"
        body.Position=UDim2.fromOffset(0,28)
        body.Size=UDim2.new(1,0,0,0)
        body.BackgroundTransparency=1
        body.Parent=s
        pad(body,8,0,4,8)

        local layout=Instance.new("UIListLayout")
        layout.Padding=UDim.new(0,4)
        layout.SortOrder=Enum.SortOrder.LayoutOrder
        layout.Parent=body

        local order=0
        local function resize()
            local h=layout.AbsoluteContentSize.Y+12
            body.Size=UDim2.new(1,0,0,h)
            s.Size=UDim2.new(1,0,0,28+h)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
        task.defer(resize)

        local api={frame=s,body=body}
        function api:add(obj)
            order+=1
            obj.LayoutOrder=order
            obj.Parent=body
            return obj
        end
        pgx.sections[title]=api
        return api
    end

    local function safeGet(e,default)
        if type(e)=="table" and type(e.get)=="function" then
            local ok,v=pcall(e.get)
            if ok and v~=nil then return v end
            if not ok then reportControlIssue("Reading a setting",v) end
        end
        return default
    end
    local function safeSet(e,v,name)
        if type(e)~="table" or type(e.set)~="function" then
            reportControlIssue(name,"feature backend is unavailable")
            return false
        end
        local ok,result=pcall(e.set,v)
        if not ok or result==false then
            reportControlIssue(name,ok and "setting was rejected" or result)
            return false
        end
        return true
    end

    local function toggle(sec,name,entry)
        local row=Instance.new("TextButton")
        row.Name=name.."Toggle"
        row.Size=UDim2.new(1,-10,0,16)
        row.BackgroundTransparency=1
        row.BorderSizePixel=0
        row.Text=""
        row.AutoButtonColor=false
        sec:add(row)

        local leaf=text(row,"🍁",UDim2.fromOffset(14,14),UDim2.new(0,0,.5,-7),13,Color3.fromRGB(38,38,46),GothamBold,Enum.TextXAlignment.Center)
        local lg=Instance.new("UIGradient")
        lg.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,COL.accentDark),
            ColorSequenceKeypoint.new(.35,COL.accentDark),
            ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,40,60)),
            ColorSequenceKeypoint.new(.65,COL.accentDark),
            ColorSequenceKeypoint.new(1,COL.accentDark)
        })
        lg.Offset=Vector2.new(-1,0)
        lg.Rotation=15
        lg.Enabled=false
        lg.Parent=leaf

        text(row,name,UDim2.new(1,-60,1,0),UDim2.fromOffset(18,-1),13,COL.text,Source,Enum.TextXAlignment.Left)

        local key=Instance.new("TextButton")
        key.Position=UDim2.new(1,-36,0,0)
        key.Size=UDim2.fromOffset(36,16)
        key.BackgroundTransparency=1
        key.BorderSizePixel=0
        key.Text=""
        key.AutoButtonColor=false
        key.Parent=row
        local keyText=text(key,"None",UDim2.fromScale(1,1),UDim2.new(),11,COL.text,Source,Enum.TextXAlignment.Center)

        local function refresh()
            local on=not not safeGet(entry,false)
            leaf.TextColor3=on and Color3.fromRGB(255,40,60) or Color3.fromRGB(38,38,46)
            leaf.TextTransparency=on and 0 or .4
            lg.Enabled=on
        end
        local function flip()
            safeSet(entry,not safeGet(entry,false),name)
            refresh()
        end
        row.MouseButton1Click:Connect(flip)
        key.MouseButton1Click:Connect(function()
            keyText.Text="..."
            keybindListening={label=keyText,action=flip,old=nil}
        end)
        table.insert(refreshers,refresh)
        refresh()
    end

    local function slider(sec,name,entry,override)
        local meta=override or entry.meta or META[name] or {}
        local min=tonumber(meta.min) or 0
        local max=tonumber(meta.max) or 100
        if max<=min then max=min+1 end
        local dec=tonumber(meta.decimals)
        if dec==nil then dec=(entry.kind=="decimal") and 2 or 0 end

        local row=Instance.new("Frame")
        row.Name=name.."Slider"
        row.Size=UDim2.new(1,-10,0,30)
        row.BackgroundColor3=Color3.fromRGB(163,162,165)
        row.BackgroundTransparency=1
        row.BorderSizePixel=0
        sec:add(row)

        local list=Instance.new("UIListLayout")
        list.Padding=UDim.new(0,0)
        list.FillDirection=Enum.FillDirection.Vertical
        list.HorizontalAlignment=Enum.HorizontalAlignment.Left
        list.VerticalAlignment=Enum.VerticalAlignment.Top
        list.SortOrder=Enum.SortOrder.LayoutOrder
        list.Parent=row

        local title=text(
            row,name,
            UDim2.new(1,0,0,12),
            UDim2.new(),
            11,
            Color3.fromRGB(160,160,175),
            Gotham,
            Enum.TextXAlignment.Left
        )
        title.LayoutOrder=0

        local valueHolder=Instance.new("Frame")
        valueHolder.Size=UDim2.new(1,0,0,10)
        valueHolder.BackgroundTransparency=1
        valueHolder.LayoutOrder=1
        valueHolder.Parent=row

        local value=text(
            valueHolder,"",
            UDim2.fromScale(1,1),
            UDim2.new(),
            10,
            Color3.fromRGB(220,220,220),
            Gotham,
            Enum.TextXAlignment.Right
        )

        local track=Instance.new("Frame")
        track.Size=UDim2.new(1,0,0,8)
        track.BackgroundColor3=Color3.fromRGB(38,38,48)
        track.BackgroundTransparency=.3
        track.BorderSizePixel=0
        track.Active=true
        track.LayoutOrder=2
        track.Parent=row
        corner(track,4)
        stroke(track,Color3.fromRGB(55,55,68),.5,1)

        local fill=Instance.new("TextButton")
        fill.Position=UDim2.fromOffset(1,1)
        fill.Size=UDim2.new(0,-2,1,-2)
        fill.BackgroundColor3=Color3.fromRGB(210,45,45)
        fill.BackgroundTransparency=.35
        fill.BorderSizePixel=0
        fill.Text=""
        fill.TextSize=8
        fill.FontFace=Font.new("rbxasset://fonts/families/LegacyArial.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
        fill.AutoButtonColor=true
        fill.Parent=track
        corner(fill,3)
        stroke(fill,Color3.fromRGB(230,70,70),.3,1)

        local dragging=false
        local function fmt(v)
            if dec<=0 then return tostring(math.floor(v+.5)) end
            return string.format("%."..dec.."f",v)
        end
        local function refresh()
            local v=math.clamp(tonumber(safeGet(entry,min)) or min,min,max)
            value.Text=fmt(v)
            fill.Size=UDim2.new((v-min)/(max-min),-2,1,-2)
        end
        local function setX(x)
            local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
            local v=min+(max-min)*a
            if dec<=0 then v=math.floor(v+.5) end
            safeSet(entry,v,name)
            refresh()
        end

        fill.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                setX(i.Position.X)
            end
        end)
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                setX(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                setX(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)

        table.insert(refreshers,refresh)
        refresh()
    end

    local openedDropdown=nil
    local function closeDropdown()
        if openedDropdown and openedDropdown.Parent then
            openedDropdown.Visible=false
            local row=openedDropdown.Parent
            if row then row.Size=UDim2.new(1,-10,0,36) end
        end
        openedDropdown=nil
    end

    local function dropdown(sec,name,entry,optionsOverride)
        local row=Instance.new("Frame")
        row.Name=name.."DropdownRow"
        row.Size=UDim2.new(1,-10,0,36)
        row.BackgroundColor3=Color3.fromRGB(163,162,165)
        row.BackgroundTransparency=1
        row.BorderSizePixel=0
        sec:add(row)

        local rowList=Instance.new("UIListLayout")
        rowList.Padding=UDim.new(0,0)
        rowList.FillDirection=Enum.FillDirection.Vertical
        rowList.HorizontalAlignment=Enum.HorizontalAlignment.Left
        rowList.VerticalAlignment=Enum.VerticalAlignment.Top
        rowList.SortOrder=Enum.SortOrder.LayoutOrder
        rowList.Parent=row

        local title=text(
            row,name,
            UDim2.new(1,0,0,12),
            UDim2.new(),
            11,
            Color3.fromRGB(160,160,175),
            Gotham,
            Enum.TextXAlignment.Left
        )
        title.LayoutOrder=0

        local mainButton=Instance.new("TextButton")
        mainButton.Name=name.."Dropdown"
        mainButton.Size=UDim2.new(1,0,0,24)
        mainButton.BackgroundColor3=Color3.fromRGB(28,28,36)
        mainButton.BackgroundTransparency=.2
        mainButton.BorderSizePixel=0
        mainButton.TextColor3=Color3.new(1,1,1)
        mainButton.TextSize=11
        mainButton.TextXAlignment=Enum.TextXAlignment.Left
        mainButton.TextYAlignment=Enum.TextYAlignment.Center
        mainButton.FontFace=Gotham
        mainButton.AutoButtonColor=false
        mainButton.LayoutOrder=1
        mainButton.Parent=row
        pad(mainButton,8,8,0,0)
        corner(mainButton,4)
        stroke(mainButton,Color3.fromRGB(55,55,68),.5,1)

        local panel=Instance.new("Frame")
        panel.Size=UDim2.new(1,0,0,0)
        panel.BackgroundTransparency=1
        panel.Visible=false
        panel.LayoutOrder=2
        panel.Parent=row

        local inner=Instance.new("Frame")
        inner.Size=UDim2.new(1,0,0,0)
        inner.BackgroundColor3=Color3.fromRGB(28,28,36)
        inner.BackgroundTransparency=.15
        inner.BorderSizePixel=0
        inner.Parent=panel
        corner(inner,0)
        stroke(inner,Color3.fromRGB(55,55,68),.5,1)

        -- Keep search fixed while a long set of skins/configs scrolls below it.
        local optionScroll=Instance.new("ScrollingFrame")
        optionScroll.Name="Options"
        optionScroll.Position=UDim2.fromOffset(0,26)
        optionScroll.Size=UDim2.new(1,-2,0,0)
        optionScroll.BackgroundTransparency=1
        optionScroll.BorderSizePixel=0
        optionScroll.ScrollingDirection=Enum.ScrollingDirection.Y
        optionScroll.ScrollBarThickness=4
        optionScroll.ScrollBarImageColor3=COL.accentFill
        optionScroll.ClipsDescendants=true
        optionScroll.Parent=inner

        local il=Instance.new("UIListLayout")
        il.Padding=UDim.new(0,1)
        il.FillDirection=Enum.FillDirection.Vertical
        il.HorizontalAlignment=Enum.HorizontalAlignment.Left
        il.VerticalAlignment=Enum.VerticalAlignment.Top
        il.SortOrder=Enum.SortOrder.LayoutOrder
        il.Parent=optionScroll
        pad(inner,1,1,1,1)
        pad(optionScroll,1,6,1,1)

        local search=Instance.new("TextBox")
        search.Size=UDim2.new(1,0,0,24)
        search.BackgroundColor3=Color3.fromRGB(24,24,30)
        search.BackgroundTransparency=.1
        search.BorderSizePixel=0
        search.PlaceholderText="Search..."
        search.PlaceholderColor3=Color3.fromRGB(150,150,150)
        search.Text=""
        search.TextColor3=Color3.new(1,1,1)
        search.TextSize=11
        search.TextXAlignment=Enum.TextXAlignment.Left
        search.TextYAlignment=Enum.TextYAlignment.Center
        search.FontFace=Gotham
        search.ClearTextOnFocus=false
        search.LayoutOrder=0
        search.Parent=inner
        pad(search,8,8,0,0)

        local optionObjects={}

        local function options()
            if type(optionsOverride)=="function" then
                local ok,v=pcall(optionsOverride)
                if ok and type(v)=="table" then return v end
            elseif type(optionsOverride)=="table" then
                return optionsOverride
            end

            local fm=META[name]
            if entry.meta and type(entry.meta.options)=="table" then return entry.meta.options end
            if fm and type(fm.options)=="table" then return fm.options end
            return {}
        end

        local function refresh()
            mainButton.Text=tostring(safeGet(entry,"None"))
        end

        local function rebuild()
            for _,o in ipairs(optionObjects) do
                pcall(function() o:Destroy() end)
            end
            table.clear(optionObjects)

            local filter=search.Text:lower()
            local shown=0

            for _,v in ipairs(options()) do
                local optionName=tostring(v)
                if filter=="" or optionName:lower():find(filter,1,true) then
                    shown+=1
                    local b=Instance.new("TextButton")
                    b.Size=UDim2.new(1,0,0,24)
                    b.BackgroundColor3=Color3.fromRGB(24,24,30)
                    b.BackgroundTransparency=.2
                    b.BorderSizePixel=0
                    b.Text=optionName
                    b.TextColor3=Color3.new(1,1,1)
                    b.TextSize=11
                    b.TextXAlignment=Enum.TextXAlignment.Left
                    b.TextYAlignment=Enum.TextYAlignment.Center
                    b.FontFace=Gotham
                    b.AutoButtonColor=false
                    b.LayoutOrder=shown
                    b.Parent=optionScroll
                    pad(b,8,8,0,0)
                    corner(b,0)
                    table.insert(optionObjects,b)

                    b.MouseButton1Click:Connect(function()
                        if safeSet(entry,v,name) then
                            refresh()
                            closeDropdown()
                        end
                    end)
                end
            end

            local h=math.min(194,28+math.max(shown,1)*25)
            inner.Size=UDim2.new(1,0,0,h)
            optionScroll.Size=UDim2.new(1,-2,0,h-27)
            optionScroll.CanvasSize=UDim2.new(0,0,0,shown*25+3)
            optionScroll.CanvasPosition=Vector2.zero
            panel.Size=UDim2.new(1,0,0,h)
            row.Size=UDim2.new(1,-10,0,36+h)
        end

        search:GetPropertyChangedSignal("Text"):Connect(function()
            if panel.Visible then rebuild() end
        end)

        mainButton.MouseButton1Click:Connect(function()
            if openedDropdown==panel then
                closeDropdown()
            else
                closeDropdown()
                panel.Visible=true
                openedDropdown=panel
                rebuild()
            end
        end)

        table.insert(refreshers,refresh)
        refresh()
    end

    local function pushButton(sec,name,fn)
        local b=Instance.new("TextButton")
        b.Name=name.."Button"
        b.Size=UDim2.new(1,-10,0,24)
        b.BackgroundColor3=COL.track
        b.BackgroundTransparency=0
        b.BorderSizePixel=0
        b.Text=name
        b.TextColor3=COL.text
        b.TextSize=12
        b.FontFace=Gotham
        b.AutoButtonColor=false
        sec:add(b)
        corner(b,4)
        stroke(b,COL.stroke,.3,1)
        b.MouseButton1Click:Connect(function()
            local ok,err=pcall(fn)
            if not ok then reportControlIssue(name,err) end
        end)
    end

    local function textbox(sec,name,entry,placeholder)
        local box=Instance.new("TextBox")
        box.Name=name.."TextBox"
        box.Size=UDim2.new(1,-10,0,22)
        box.BackgroundColor3=Color3.fromRGB(28,28,36)
        box.BackgroundTransparency=.2
        box.BorderSizePixel=0
        box.Text=tostring(safeGet(entry,""))
        box.PlaceholderText=placeholder or name
        box.PlaceholderColor3=Color3.fromRGB(150,150,150)
        box.TextColor3=Color3.new(1,1,1)
        box.TextSize=11
        box.TextXAlignment=Enum.TextXAlignment.Left
        box.TextYAlignment=Enum.TextYAlignment.Center
        box.FontFace=Gotham
        box.ClearTextOnFocus=false
        box.MultiLine=false
        box.TextEditable=true
        sec:add(box)
        pad(box,6,0,0,0)
        corner(box,4)
        stroke(box,Color3.fromRGB(55,55,68),.5,1)

        box.FocusLost:Connect(function()
            safeSet(entry,box.Text,name)
        end)

        local function refresh()
            local v=tostring(safeGet(entry,box.Text))
            if not box:IsFocused() then box.Text=v end
        end
        table.insert(refreshers,refresh)
        return box
    end

    local function keybind(sec,name,entry)
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-10,0,24)
        row.BackgroundTransparency=1
        sec:add(row)
        text(row,name,UDim2.new(.62,0,1,0),UDim2.new(),11,COL.sub,Gotham,Enum.TextXAlignment.Left)
        local b=Instance.new("TextButton")
        b.Position=UDim2.new(.62,0,0,0)
        b.Size=UDim2.new(.38,0,1,0)
        b.BackgroundColor3=COL.field
        b.BackgroundTransparency=.2
        b.BorderSizePixel=0
        b.TextColor3=COL.text
        b.TextSize=11
        b.FontFace=Gotham
        b.AutoButtonColor=false
        b.Parent=row
        corner(b,4); stroke(b,COL.stroke,.5,1)
        local waiting=false
        local function refresh()
            if not waiting then b.Text=tostring(safeGet(entry,"None")) end
        end
        b.MouseButton1Click:Connect(function() waiting=true; b.Text="..." end)
        UIS.InputBegan:Connect(function(i,gpe)
            if waiting and not gpe and i.UserInputType==Enum.UserInputType.Keyboard then
                waiting=false
                safeSet(entry,i.KeyCode.Name,name)
                refresh()
            end
        end)
        table.insert(refreshers,refresh)
        refresh()
    end

    local function refreshAll()
        for _,f in ipairs(refreshers) do pcall(f) end
    end

    ----------------------------------------------------------------------
    -- WHERE KIMQETRAS FEATURES GO INSIDE THE LASION TABS
    ----------------------------------------------------------------------
    local PAGE_MAP={
        hcsilent={"Combat","HC Silent Aim","left"},
        silent={"Combat","Silent Aim","left"},
        camlock={"Combat","Camlock","right"},
        flamelock={"Combat","Flamelock","right"},
        hitbox={"Combat","Hitbox","right"},
        delay={"Combat","Delay Changer","right"},
        ragecam={"Combat","RAGE Camlock","left"},
        rageorbit={"Combat","Target Orbit","right"},
        ragecombat={"Combat","RAGE Combat","left"},
        ragepresets={"Combat","RAGE Presets","right"},

        esp={"Visuals","ESP","left"},
        weaponskins={"Visuals","Weapon Skins","right"},

        fog={"Atmosphere","Fog / Atmosphere","left"},
        environment={"Atmosphere","Environment","right"},

        avatar={"Player","Avatar","left"},
        macro={"Player","Macro","right"},
        whitelist={"Player","Whitelist","left"},
        protection={"Player","Protection","right"},
        antifall={"Player","Anti Fall","right"},
        antimod={"Player","Anti Mod","right"},
        spawn={"Player","Spawn Point","left"},
    }

    local SPECIAL={
        ["Random Camera Zoom"]={"Visuals","Camera Effects","right"},
        ["Shot Camera Swap"]={"Visuals","Camera Effects","right"},
        ["Zoom Speed"]={"Visuals","Camera Effects","right"},
        ["Zoom Min"]={"Visuals","Camera Effects","right"},
        ["Zoom Max"]={"Visuals","Camera Effects","right"},
        ["Stay Min"]={"Visuals","Camera Effects","right"},
        ["Stay Max"]={"Visuals","Camera Effects","right"},
        ["Frequency"]={"Visuals","Camera Effects","right"},

        ["Atmosphere Preset"]={"Atmosphere","Atmosphere","left"},
        ["Reset Atmosphere"]={"Atmosphere","Atmosphere","left"},
        ["Color Correction"]={"Atmosphere","Atmosphere","left"},
        ["Saturation"]={"Atmosphere","Atmosphere","left"},

        ["KIM Anti Aim View"]={"Player","Protection","right"},
        ["Anti Mod Notify"]={"Player","Anti Mod","right"},
        ["Anti Mod Kick"]={"Player","Anti Mod","right"},
        ["Anti Mod Kick Delay"]={"Player","Anti Mod","right"},

        ["FPS Unlocker"]={"Utilities","Performance","left"},
        ["Target FPS"]={"Utilities","Performance","left"},

        ["Custom Cursor"]={"Visuals","Custom Cursor","right"},
        ["Cursor Style"]={"Visuals","Custom Cursor","right"},
        ["Cursor Size"]={"Visuals","Custom Cursor","right"},

        ["Environment Preset"]={"Atmosphere","Environment","right"},
        ["Time of Day"]={"Atmosphere","Environment","right"},
        ["Night Lights"]={"Atmosphere","Environment","right"},
        ["Enhanced Lights"]={"Atmosphere","Environment","right"},
        ["Light Brightness"]={"Atmosphere","Environment","right"},
        ["Light Glow"]={"Atmosphere","Environment","right"},
        ["Corner / Contact Shadows"]={"Atmosphere","Environment","right"},
        ["Corner Darkness"]={"Atmosphere","Environment","right"},
        ["Shadow Edge Softness"]={"Atmosphere","Environment","right"},
        ["Bullet Light Brightness"]={"Visuals","Weapon Extras","right"},
        ["Gun Kill Effect"]={"Visuals","Death Effects","right"},
    }

    local META={
        ["Activation Mode"]={options={"Hold","Toggle"}},
        ["Anti Mod Kick Delay"]={min=1,max=10},
        ["Atmosphere Preset"]={options={"Pink","Hot Pink","Yellow","Blue","Purple","Red","Green","Cyan"}},
        ["Auto Prediction Strength"]={min=.25,max=2.5,decimals=2},
        ["Bullet Light Brightness"]={min=0,max=2.5,decimals=2},
        ["Camlock FOV"]={min=0,max=1000},
        ["Camlock Hit Part"]={options={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot","LeftHand","RightHand","Closest Point"}},
        ["Camlock Mode"]={options={"Hold","Toggle"}},
        ["Camlock Smoothness"]={min=0,max=1,decimals=3},
        ["Closest Point Mode"]={options={"Default","Basic"}},
        ["Closest Point Scale"]={min=0,max=1,decimals=2},
        ["Corner Darkness"]={min=0,max=150},
        ["Cursor Size"]={min=12,max=52},
        ["Cursor Style"]={options={"Default","Heart","Dot","Cross","Ring","Custom Image"}},
        ["ESP Blue"]={min=0,max=255},
        ["ESP Green"]={min=0,max=255},
        ["ESP Red"]={min=0,max=255},
        ["Easing Direction"]={options={"In","Out","InOut"}},
        ["Easing Style"]={options={"Linear","Quad","Sine","Back","Elastic","Bounce"}},
        ["Environment Preset"]={options={"Normal","Christmas","Halloween"}},
        ["FOV Opacity"]={min=5,max=100},
        ["FOV Size"]={min=10,max=1000},
        ["Flame Hit Part"]={options={"HumanoidRootPart","Head","UpperTorso","LowerTorso"}},
        ["Flame Left Offset"]={min=-5,max=5,decimals=2},
        ["Flame Prediction"]={min=0,max=0.5,decimals=3},
        ["Flame Smoothness"]={min=0,max=1,decimals=2},
        ["Flame Up Offset"]={min=-20,max=5,decimals=2},
        ["Force Hit FOV"]={min=10,max=1000},
        ["Force Hit Finish Shots"]={min=2,max=10},
        ["Force Hit Fire Rate"]={min=0.01,max=0.5,decimals=3},
        ["Force Hit Mode"]={options={"Fov","Manual"}},
        ["Frequency"]={min=0.25,max=8,decimals=3},
        ["HC FOV Radius"]={min=10,max=1000},
        ["HC Hit Part"]={options={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot","LeftHand","RightHand","Closest Point"}},
        ["HC Prediction Amount"]={min=0,max=0.5,decimals=3},
        ["Hit Chance"]={min=1,max=100},
        ["Hit Part"]={options={"Head","UpperTorso","LowerTorso","HumanoidRootPart","Closest Point"}},
        ["Hitbox Size"]={min=1,max=20},
        ["Hitbox Visibility"]={min=0,max=1,decimals=2},
        ["Light Brightness"]={min=100,max=400},
        ["Light Glow"]={min=0,max=100},
        ["Macro Speed"]={min=16,max=1000},
        ["Max Distance"]={min=0,max=100000},
        ["Max Target Distance"]={min=50,max=5000},
        ["Others Delay"]={min=0,max=0.5,decimals=3},
        ["Pull Base Value"]={min=0.001,max=0.2,decimals=3},
        ["Pull Move Value"]={min=0.001,max=0.2,decimals=3},
        ["Saturation"]={min=0,max=2,decimals=2},
        ["Shadow Edge Softness"]={min=0,max=100},
        ["Silent Prediction X"]={min=0,max=0.5,decimals=3},
        ["Silent Prediction Y"]={min=0,max=0.5,decimals=3},
        ["Stay Max"]={min=0,max=2,decimals=3},
        ["Stay Min"]={min=0,max=2,decimals=3},
        ["Target FPS"]={min=240,max=1000},
        ["Target Priority"]={options={"Closest Cursor","Closest Distance","Lowest Health"}},
        ["Target Stickiness"]={min=0,max=80},
        ["Time of Day"]={options={"Game Default","Day","Night"}},
        ["Zoom Max"]={min=5,max=50},
        ["Zoom Min"]={min=1,max=30},
        ["Zoom Speed"]={min=1,max=20},
        ["[Double-Barrel SG] Delay"]={min=0,max=0.5,decimals=3},
        ["[Revolver] Delay"]={min=0,max=0.5,decimals=3},
        ["[TacticalShotgun] Delay"]={min=0,max=0.5,decimals=3},
    }

    local legacy=CoreGui:FindFirstChild("KimpetrasHC") or pg:FindFirstChild("KimpetrasHC")
    local function legacyPageFor(name)
        if not legacy then return nil end
        for _,obj in ipairs(legacy:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
                and tostring(obj.Text)==name
            then
                local p=obj.Parent
                while p and p~=legacy do
                    if p:IsA("ScrollingFrame") and p.Name:match("Page$") then
                        return p.Name:gsub("Page$",""):lower()
                    end
                    p=p.Parent
                end
            end
        end
    end

    local function destination(name)
        if SPECIAL[name] then return SPECIAL[name] end
        local p=legacyPageFor(name)
        if p and PAGE_MAP[p] then return PAGE_MAP[p] end

        -- Fallbacks if a late control's old page cannot be discovered.
        if name:find("^HC ") or name:find("^Force Hit") then return {"Combat","HC Silent Aim","left"} end
        if name:find("Camlock") or name=="Prediction X" or name=="Prediction Y" or name=="Prediction Z" then return {"Combat","Camlock","right"} end
        if name:find("Flame") or name=="Right Click Lock" or name=="Activation Mode" then return {"Combat","Flamelock","right"} end
        if name:find("Hitbox") then return {"Combat","Hitbox","right"} end
        if name:find("Delay") then return {"Combat","Delay Changer","right"} end
        if name:find("ESP") or name=="Box" or name=="Name" or name=="Distance" or name=="Health" or name=="Snapline" or name=="Skeleton" then return {"Visuals","ESP","left"} end
        if name:find("Macro") then return {"Player","Macro","right"} end
        return nil
    end

    local registry=_G.KimqConfigControls or {}
    local entries={}
    for name,e in pairs(registry) do
        if type(name)=="string" and type(e)=="table" and e.kind~="state" then
            local dest=destination(name)
            if dest then table.insert(entries,{name=name,e=e,d=dest}) end
        end
    end
    table.sort(entries,function(a,b)
        if a.d[1]~=b.d[1] then return a.d[1]<b.d[1] end
        if a.d[2]~=b.d[2] then return a.d[2]<b.d[2] end
        return a.name:lower()<b.name:lower()
    end)

    for _,rec in ipairs(entries) do
        local sec=section(rec.d[1],rec.d[2],rec.d[3])
        local e=rec.e
        if e.kind=="toggle" then toggle(sec,rec.name,e)
        elseif e.kind=="slider" or e.kind=="decimal" then slider(sec,rec.name,e,META[rec.name])
        elseif e.kind=="dropdown" then dropdown(sec,rec.name,e,(META[rec.name] and META[rec.name].options))
        elseif e.kind=="keybind" then keybind(sec,rec.name,e)
        elseif e.kind=="text" then textbox(sec,rec.name,e)
        elseif e.kind=="button" then pushButton(sec,rec.name,function() safeSet(e,true,rec.name) end)
        end
    end

    ----------------------------------------------------------------------
    -- CONTROLLER-BASED KIMQETRAS FEATURES
    ----------------------------------------------------------------------

    -- Avatar / accessory try-on.
    do
        local sec=section("Player","Avatar","left")
        local ctl=_G.KimqAvatarController
        if type(ctl)=="table" then
            local target={
                get=function()
                    if ctl.GetTarget then return ctl.GetTarget() end
                    return ""
                end,
                set=function(v) if ctl.SetTarget then return ctl.SetTarget(tostring(v)) end return false end
            }
            textbox(sec,"Avatar Target",target,"username / user id")
            pushButton(sec,"Apply Avatar",function()
                if not ctl.Apply then error("avatar controller is unavailable") end
                if ctl.Apply(target.get())==false then error("avatar could not be applied") end
            end)
            pushButton(sec,"Reset Avatar",function()
                if not ctl.Reset then error("avatar controller is unavailable") end
                if ctl.Reset()==false then error("avatar could not be reset") end
            end)
        end

        local acc=_G.KimqAccessoryController
        if type(acc)=="table" then
            local accessoryId=""
            textbox(sec,"Accessory ID",{
                get=function() return accessoryId end,
                set=function(v) accessoryId=tostring(v or "") end
            },"catalog asset id")
            pushButton(sec,"Wear Accessory",function()
                local id=tonumber(accessoryId)
                if not id then error("enter a numeric accessory ID") end
                if not acc.Equip or not lp.Character then error("accessory controller or character is unavailable") end
                if acc.Equip(id,lp.Character,false)==false then error("accessory could not be equipped") end
            end)
            pushButton(sec,"Clear Accessories",function()
                if not acc.RemoveAll then error("accessory controller is unavailable") end
                if acc.RemoveAll()==false then error("accessories could not be cleared") end
            end)
        end
    end

    -- Whitelist.
    do
        local sec=section("Player","Whitelist","left")
        local selected="None"
        local function names()
            local out={}
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=lp then table.insert(out,p.Name) end
            end
            table.sort(out,function(a,b) return a:lower()<b:lower() end)
            return out
        end
        dropdown(sec,"Player",{
            get=function() return selected end,
            set=function(v) selected=tostring(v) end,
            meta={}
        },names)
        pushButton(sec,"Toggle Whitelist",function()
            local p=Players:FindFirstChild(selected)
            if not p then return end
            _G.KHWhitelist=_G.KHWhitelist or {}
            _G.Whitelist=_G.Whitelist or {}
            local on=not ((_G.KHWhitelist[p.UserId]==true) or (_G.Whitelist[p.UserId]==true))
            _G.KHWhitelist[p.UserId]=on
            _G.Whitelist[p.UserId]=on
        end)
        pushButton(sec,"Clear Whitelist",function()
            if type(_G.KHWhitelist)=="table" then table.clear(_G.KHWhitelist) end
            if type(_G.Whitelist)=="table" then table.clear(_G.Whitelist) end
        end)
    end

    -- Spawn point actions.
    do
        local ctl=_G.KimqSpawnPointController
        if type(ctl)=="table" then
            local sec=section("Player","Spawn Point","left")
            pushButton(sec,"Refresh Spawn Points",function() if ctl.Refresh then ctl.Refresh() end end)
            pushButton(sec,"Spawn Now",function() if ctl.SpawnNow then ctl.SpawnNow() end end)
        end
    end

    -- Weapon skins.
    --
    -- The UI scans the real Wraps folder for dropdown contents, but applying and
    -- resetting are delegated to KimqWeaponSkinController.SetState(). That path is
    -- the same one used by Kimq's config restore and it rebuilds the backend's
    -- private Wraps lookup before cloning the skin. It also keeps the selection
    -- across Backpack/equip/respawn through the original backend hooks.
    do
        local ctl=_G.KimqWeaponSkinController
        if type(ctl)=="table" and type(ctl.GetState)=="function" and type(ctl.SetState)=="function" then
            local sec=section("Visuals","Weapon Skins","right")
            local weapon="None"
            local skin="None"
            local folders={}
            local wrapRoot=nil

            local function locateWraps()
                local direct=workspace:FindFirstChild("Wraps")
                if direct then return direct end
                local recursive=workspace:FindFirstChild("Wraps",true)
                if recursive then return recursive end
                return RS:FindFirstChild("Wraps",true)
            end

            local function findHandle(obj)
                if not obj then return nil end
                local direct=obj:FindFirstChild("Handle")
                if direct and direct:IsA("BasePart") then return direct end
                for _,d in ipairs(obj:GetDescendants()) do
                    if d.Name=="Handle" and d:IsA("BasePart") then return d end
                end
                return nil
            end

            local function displayWeapon(name)
                return tostring(name or ""):gsub("%[",""):gsub("%]","")
            end

            local function weapons()
                table.clear(folders)
                wrapRoot=locateWraps()
                local out={}
                if wrapRoot then
                    for _,f in ipairs(wrapRoot:GetChildren()) do
                        if f:IsA("Folder") or f:IsA("Model") then
                            folders[f.Name]=f
                            table.insert(out,f.Name)
                        end
                    end
                end
                table.sort(out,function(a,b)
                    return displayWeapon(a):lower()<displayWeapon(b):lower()
                end)

                if weapon=="None" or not folders[weapon] then
                    local ok,state=pcall(ctl.GetState)
                    if ok and type(state)=="table" and type(state.currentWeapon)=="string" and folders[state.currentWeapon] then
                        weapon=state.currentWeapon
                    elseif out[1] then
                        weapon=out[1]
                    end
                end
                return out
            end

            local function skins()
                weapons()
                local out={}
                local folder=folders[weapon]
                if folder then
                    for _,item in ipairs(folder:GetChildren()) do
                        if findHandle(item) then table.insert(out,item.Name) end
                    end
                end
                table.sort(out,function(a,b) return a:lower()<b:lower() end)

                local ok,state=pcall(ctl.GetState)
                if ok and type(state)=="table" and type(state.selected)=="table" then
                    local saved=state.selected[weapon]
                    if type(saved)=="string" and table.find(out,saved) then skin=saved end
                end
                if skin=="None" or not table.find(out,skin) then skin=out[1] or "None" end
                return out
            end

            local weaponEntry={
                get=function() return displayWeapon(weapon) end,
                set=function(v)
                    -- Dropdown values are raw folder names. Keep the raw value for
                    -- the backend but only strip brackets for display elsewhere.
                    weapon=tostring(v)
                    skin="None"
                    skins()
                end,
                meta={}
            }
            local skinEntry={
                get=function() return skin end,
                set=function(v) skin=tostring(v) end,
                meta={}
            }

            dropdown(sec,"Weapon",weaponEntry,weapons)
            dropdown(sec,"Skin",skinEntry,skins)

            pushButton(sec,"Refresh Skins",function()
                weapons()
                skins()
            end)

            pushButton(sec,"Apply Skin",function()
                if weapon=="None" or skin=="None" then error("choose a weapon and skin first") end

                local ok,state=pcall(ctl.GetState)
                if not ok or type(state)~="table" then state={} end
                state.selected=type(state.selected)=="table" and state.selected or {}
                state.selected[weapon]=skin
                state.currentWeapon=weapon
                state.selectedSkin=skin

                -- This invokes the backend's own scanWeapons() + applySkin()
                -- asynchronously and therefore works even though its old GUI is hidden.
                if ctl.SetState(state)==false then error("skin selection was rejected") end
            end)

            pushButton(sec,"Reset Skin",function()
                if weapon=="None" then error("choose a weapon first") end
                local ok,state=pcall(ctl.GetState)
                if not ok or type(state)~="table" then state={} end
                state.selected=type(state.selected)=="table" and state.selected or {}
                state.selected[weapon]=nil
                state.currentWeapon=weapon
                state.selectedSkin=nil
                skin="None"
                if ctl.SetState(state)==false then error("skin reset was rejected") end
            end)

            -- Knife skins are part of the skin changer again instead of being hidden
            -- behind a free-typed Weapon Extras box.
            local extraCtl=_G.KimqWeaponExtrasController
            if type(extraCtl)=="table" and extraCtl.GetState and extraCtl.SetState then
                local function knifeRoot()
                    return RS:FindFirstChild("Knives")
                        or RS:FindFirstChild("KnifeSkins")
                        or RS:FindFirstChild("Knife Skins")
                        or RS:FindFirstChild("Knives",true)
                        or RS:FindFirstChild("KnifeSkins",true)
                        or RS:FindFirstChild("Knife Skins",true)
                end

                local function knifeOptions()
                    local out={"None"}
                    local seen={None=true}
                    local root=knifeRoot()
                    if root then
                        for _,item in ipairs(root:GetChildren()) do
                            if item.Name~="None" and findHandle(item) and not seen[item.Name] then
                                seen[item.Name]=true
                                table.insert(out,item.Name)
                            end
                        end
                    end
                    table.sort(out,function(a,b)
                        if a=="None" then return true end
                        if b=="None" then return false end
                        return a:lower()<b:lower()
                    end)
                    return out
                end

                local knifeEntry={
                    get=function()
                        local ok,state=pcall(extraCtl.GetState)
                        return ok and type(state)=="table" and tostring(state.KnifeSkin or "None") or "None"
                    end,
                    set=function(v)
                        local ok,state=pcall(extraCtl.GetState)
                        if not ok or type(state)~="table" then state={} end
                        state.KnifeSkin=tostring(v or "None")
                        return extraCtl.SetState(state)
                    end,
                    meta={}
                }

                dropdown(sec,"Knife Skin",knifeEntry,knifeOptions)
                pushButton(sec,"Apply Knife Skin",function()
                    local name=knifeEntry.get()
                    if not extraCtl.ApplyKnife then error("knife skin controller is unavailable") end
                    local ok,msg=extraCtl.ApplyKnife(name,false)
                    if ok==false then error(msg or "knife skin could not be applied") end
                end)
            end

            -- Restore the currently selected weapon/skin into the replacement UI.
            task.defer(function()
                weapons()
                skins()
            end)
        end
    end

    -- Weapon extras.
    do
        local ctl=_G.KimqWeaponExtrasController
        if type(ctl)=="table" and ctl.GetState and ctl.SetState then
            local sec=section("Visuals","Weapon Extras","right")
            local fields={
                {"Bullet Beam","BulletBeam"},
                {"Bullet Color","BulletColorHex"},
                {"Equip Item","EquipableItem"},
            }
            for _,pair in ipairs(fields) do
                local label,key=pair[1],pair[2]
                textbox(sec,label,{
                    get=function()
                        local ok,s=pcall(ctl.GetState)
                        return ok and type(s)=="table" and tostring(s[key] or "") or ""
                    end,
                    set=function(v)
                        local ok,s=pcall(ctl.GetState)
                        if not ok or type(s)~="table" then s={} end
                        s[key]=tostring(v or "")
                        return ctl.SetState(s)
                    end
                })
            end

            dropdown(sec,"Knife Accent",{
                get=function()
                    local ok,s=pcall(ctl.GetState)
                    return ok and type(s)=="table" and tostring(s.KnifeAccentMode or "Off") or "Off"
                end,
                set=function(v)
                    local ok,s=pcall(ctl.GetState)
                    if not ok or type(s)~="table" then s={} end
                    s.KnifeAccentMode=tostring(v or "Off")
                    return ctl.SetState(s)
                end,
                meta={}
            },{"Off","Theme","Bullet"})


            pushButton(sec,"Refresh Weapon Extras",function()
                if not ctl.Refresh then error("weapon extras controller is unavailable") end
                if ctl.Refresh()==false then error("weapon extras could not refresh") end
            end)
        end
    end

    -- Dedicated death effects section.
    do
        local ctl=_G.KimqWeaponExtrasController
        if type(ctl)=="table" and ctl.GetState and ctl.SetState then
            local sec=section("Visuals","Death Effects","right")

            dropdown(sec,"Gun Kill Effect",{
                get=function()
                    local ok,state=pcall(ctl.GetState)
                    return ok and type(state)=="table" and tostring(state.GunKillEffect or "Hearts") or "Hearts"
                end,
                set=function(v)
                    local ok,state=pcall(ctl.GetState)
                    if not ok or type(state)~="table" then state={} end
                    state.GunKillEffect=tostring(v or "Hearts")
                    return ctl.SetState(state)
                end,
                meta={}
            },{"Hearts","Normal"})

            pushButton(sec,"Test Hearts",function()
                if not ctl.TestDeathHearts then error("heart effect controller is unavailable") end
                local ok,msg=ctl.TestDeathHearts()
                if ok==false then error(msg or "heart effect could not be tested") end
            end)
        end
    end

    -- Custom cursor image ID (the toggle/style/size controls come from registry).
    do
        local Ctx=_G.KimpetrasCtx
        local cfg=Ctx and Ctx.cfg
        if type(cfg)=="table" then
            local sec=section("Visuals","Custom Cursor","right")
            textbox(sec,"Custom Cursor Asset ID",{
                get=function() return tostring(cfg.customCursorAsset or "") end,
                set=function(v)
                    cfg.customCursorAsset=tostring(v or "")
                    if type(_G.KimqRefreshCustomCursor)=="function" then return _G.KimqRefreshCustomCursor() end
                end
            },"image / decal asset id")
        end
    end

    -- Environment / atmosphere reset actions.
    do
        local env=_G.KimqEnvironmentController
        if type(env)=="table" then
            local sec=section("Atmosphere","Environment","right")
            pushButton(sec,"Restore Environment",function()
                if not env.Restore then error("environment controller is unavailable") end
                if env.Restore()==false then error("environment could not be restored") end
            end)
        end
    end

    -- Existing RAGE engine.
    do
        local rage=_G.KimqRageV3
        if type(rage)=="table" and type(rage.GetState)=="function" then
            local function re(key,meta)
                return {
                    kind=meta and meta.decimals and "decimal" or "toggle",
                    meta=meta or {},
                    get=function()
                        local ok,s=pcall(rage.GetState)
                        return ok and s and s[key]
                    end,
                    set=function(v)
                        if rage.SetControl then return rage.SetControl(key,v) end
                        return false
                    end
                }
            end

            local s1=section("Combat","RAGE Camlock","left")
            dropdown(s1,"Queue Order",re("queueOrder"),{"Manual","Closest","Lowest Health","Random"})
            toggle(s1,"Skip Downed / Dead Targets",re("skipDown"))
            toggle(s1,"Skip Whitelisted Targets",re("skipWL"))
            toggle(s1,"RAGE Target Camera",re("camLock"))
            pushButton(s1,"Select All Targets",function() if rage.SelectAll then rage.SelectAll() end end)
            pushButton(s1,"Clear Queue",function() if rage.ClearQueue then rage.ClearQueue() end end)

            local s2=section("Combat","Target Orbit","right")
            toggle(s2,"Target Orbit Master",re("orbit"))
            toggle(s2,"Anti Lock / Evasive Orbit",re("antiLock"))
            toggle(s2,"Use Angel Wings While Orbiting",re("wings"))
            slider(s2,"Orbit Speed",re("orbitSpeed",{min=.5,max=20,decimals=1}),{min=.5,max=20,decimals=1})
            slider(s2,"Orbit Radius",re("orbitRadius",{min=2.5,max=18,decimals=1}),{min=2.5,max=18,decimals=1})
            slider(s2,"Orbit Height",re("orbitHeight",{min=-1,max=12,decimals=1}),{min=-1,max=12,decimals=1})

            local s3=section("Combat","RAGE Combat","left")
            toggle(s3,"Rage Combat Master",re("master"))
            toggle(s3,"Auto Shoot Current Target",re("autoShoot"))
            toggle(s3,"Auto Reload When Empty",re("autoReload"))
            toggle(s3,"Auto Stomp With E",re("autoStomp"))
            toggle(s3,"Lock On Top While Stomping",re("stompLock"))
            toggle(s3,"Auto Advance After Finish",re("autoAdvance"))
            dropdown(s3,"RAGE Camera Focus",re("hitPart"),{"Head","UpperTorso","HumanoidRootPart","Closest Part"})
            slider(s3,"Weapon Fire Interval",re("fireDelay",{min=.02,max=.5,decimals=3}),{min=.02,max=.5,decimals=3})
            slider(s3,"Stomp Attempts",re("stompAttempts",{min=1,max=2,decimals=0}),{min=1,max=2,decimals=0})

            local s4=section("Combat","RAGE Presets","right")
            pushButton(s4,"OP All Targets",function() if rage.StartAll then rage.StartAll() end end)
            pushButton(s4,"OP Solo",function() if rage.StartSolo then rage.StartSolo() end end)
            pushButton(s4,"Stop RAGE",function() if rage.Stop then rage.Stop() end end)
        end
    end

    ----------------------------------------------------------------------
    -- LASION-STYLE CONFIGS, USING KIMQETRAS' EXISTING CONFIG BACKEND
    ----------------------------------------------------------------------
    do
        local sec=section("Settings","Configs","right")
        local selected="None"
        local configName=""
        local configBox=textbox(sec,"Config Name",{
            get=function() return configName end,
            set=function(v) configName=tostring(v or "") end
        },"config name")

        local function configs()
            local out={}
            local b=_G.KimpetrasKIMBackend
            if b and type(b.GetConfigs)=="function" then
                local ok,list=pcall(b.GetConfigs)
                if ok and type(list)=="table" then
                    for _,n in ipairs(list) do
                        n=tostring(n)
                        if n~="WholeDifferentAnimal" then table.insert(out,n) end
                    end
                end
            end
            table.sort(out,function(a,b) return a:lower()<b:lower() end)
            return out
        end

        dropdown(sec,"Saved Config",{
            get=function() return selected end,
            set=function(v) selected=tostring(v); configName=selected; configBox.Text=selected end,
            meta={}
        },configs)

        local function current()
            local n=tostring(configBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
            if n=="" then n=selected end
            return n
        end

        pushButton(sec,"Save",function()
            local b=_G.KimpetrasKIMBackend
            local n=current()
            if not b or type(b.SaveConfig)~="function" then error("config backend is unavailable") end
            if n=="" or n=="None" then error("enter a config name") end
            if b.SaveConfig(n)==false then error("config could not be saved") end
            selected=n
            configName=n
        end)
        pushButton(sec,"Load",function()
            local b=_G.KimpetrasKIMBackend
            local n=current()
            if not b or type(b.LoadConfig)~="function" then error("config backend is unavailable") end
            if n=="" or n=="None" then error("choose a config to load") end
            if b.LoadConfig(n)==false then error("config could not be loaded") end
            selected=n
            configName=n
            task.delay(.2,refreshAll)
        end)
        pushButton(sec,"Overwrite",function()
            local b=_G.KimpetrasKIMBackend
            local n=current()
            if not b or type(b.SaveConfig)~="function" then error("config backend is unavailable") end
            if n=="" or n=="None" then error("choose a config to overwrite") end
            if b.SaveConfig(n)==false then error("config could not be overwritten") end
            selected=n
            configName=n
        end)
        pushButton(sec,"Delete",function()
            local b=_G.KimpetrasKIMBackend
            local n=current()
            if not b or type(b.DeleteConfig)~="function" then error("config backend is unavailable") end
            if n=="" or n=="None" then error("choose a config to delete") end
            if b.DeleteConfig(n)==false then error("config could not be deleted") end
            selected="None"
            configName=""
            configBox.Text=""
        end)
    end


    ----------------------------------------------------------------------
    -- Settings: no filler, just actual GUI controls.
    do
        local sec=section("Settings","Toggle Gui","left")
        pushButton(sec,"RightShift",function()
            main.Visible=not main.Visible
        end)

        local sec2=section("Settings","Runtime","left")
        pushButton(sec2,"Refresh Controls",refreshAll)
        runtimeStatus=Instance.new("TextLabel")
        runtimeStatus.Name="FeatureStatus"
        runtimeStatus.Size=UDim2.new(1,-10,0,48)
        runtimeStatus.BackgroundTransparency=1
        runtimeStatus.TextWrapped=true
        runtimeStatus.TextXAlignment=Enum.TextXAlignment.Left
        runtimeStatus.TextYAlignment=Enum.TextYAlignment.Top
        runtimeStatus.FontFace=Gotham
        runtimeStatus.TextSize=11
        runtimeStatus.TextColor3=COL.sub
        runtimeStatus.Text="Feature controls: "..tostring(#entries).." registered. Errors appear here and in the console."
        sec2:add(runtimeStatus)
        if _G.KimqLasionLastError then
            runtimeStatus.Text="Issue: "..tostring(_G.KimqLasionLastError):sub(1,160)
            runtimeStatus.TextColor3=Color3.fromRGB(255,155,155)
        end
    end

    ----------------------------------------------------------------------
    -- SMALL LASION-STYLE WATERMARK
    ----------------------------------------------------------------------
    local watermarkGui=Instance.new("ScreenGui")
    watermarkGui.Name="KimqetrasHC_LasionWatermark"
    watermarkGui.ResetOnSpawn=false
    watermarkGui.IgnoreGuiInset=false
    pcall(function() watermarkGui.Parent=CoreGui end)
    if not watermarkGui.Parent then watermarkGui.Parent=pg end

    local watermark=Instance.new("Frame")
    watermark.Position=UDim2.fromOffset(10,10)
    watermark.Size=UDim2.fromOffset(229,30)
    watermark.BackgroundColor3=COL.main
    watermark.BackgroundTransparency=.1
    watermark.BorderSizePixel=0
    watermark.Parent=watermarkGui
    corner(watermark,6)
    stroke(watermark,COL.accent,.4,1)
    local wg=Instance.new("UIGradient")
    wg.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.05),
        NumberSequenceKeypoint.new(1,.2)
    })
    wg.Rotation=90
    wg.Parent=watermark
    local watermarkText="Kimqetras HC | "..lp.Name.." | "..os.date("%m/%d/%Y")
    text(watermark,watermarkText,UDim2.new(1,-16,1,0),UDim2.fromOffset(8,0),12,Color3.fromRGB(220,220,230),Gotham,Enum.TextXAlignment.Left)

    ----------------------------------------------------------------------
    -- RIGHT SHIFT
    ----------------------------------------------------------------------
    UIS.InputBegan:Connect(function(i,gpe)
        if not gpe and i.KeyCode==Enum.KeyCode.RightShift then
            main.Visible=not main.Visible
        end
    end)

    showPage("Player")
    refreshAll()

    _G.KimqLasionGUI=gui
    _G.KimqLasionMain=main
end)
