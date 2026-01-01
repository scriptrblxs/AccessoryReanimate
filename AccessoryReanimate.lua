local Reanim = {}
Reanim.__index = Reanim

local rs = game:GetService("RunService")
local NETLESS_VEL = Vector3.new(0, 24.1, 0)

function Reanim.new(ghostId, params)
    local self = setmetatable({}, Reanim)
    
    self.params = params or {
        DisableCharacterByCFrame = false,
    }
    
    -- Ghost Rig (or you may call a fake rig)
    self.ghost = game:GetObjects("rbxassetid://" .. (ghostId or 8246626421))[1]
    self.ghost.Parent = workspace
    self.ghrp = self.ghost:WaitForChild("HumanoidRootPart")
    self.ghum = self.ghost:WaitForChild("Humanoid")
    
    -- Make the ghost invisible
    for _, p in ipairs(self.ghost:GetDescendants()) do
        if p:IsA("BasePart") then 
            p.Transparency = 1 
            p.Anchored = false
        elseif p:IsA("Decal") then 
            p:Destroy() 
        end
    end
    
    -- Switch camera subject
    workspace.CurrentCamera.CameraSubject = self.ghum
    
    self.limbs = {}
    self.parts = {}
    return self
end

-- Modular method to weld ANY part to a ghost limb
function Reanim:WeldToLimb(part, limbName, offset)
    local target = self.ghost:FindFirstChild(limbName)
    if not target then return warn("Limb " .. limbName .. " not found!") end
    
    part:BreakJoints()
    local connection = rs.PostSimulation:Connect(function()
        if part and target and part.Parent then
            part.CFrame = target.CFrame * (offset or CFrame.new())
            part.Velocity = NETLESS_VEL
        end
    end)
    
    return connection
end

-- Faster method to create a Motor6D to make it animatable
function Reanim:MotorToLimb(part, limbName, offset0, offset1)
    local target = self.ghost:FindFirstChild(limbName)
    if not target then return warn("Limb " .. limbName .. " not found!") end
    
    part:BreakJoints()
    part.CanCollide = false
    
    local newPart = Instance.new("Part")
    newPart.Name = part.Name
    newPart.Transparency = 1
    newPart.CanCollide = false
    newPart.Anchored = false
    newPart.Massless = true
    newPart.Parent = self.ghost
    
    print("start motor")
    local motor = Instance.new("Motor6D")
    motor.C0 = offset0
    motor.C1 = offset1
    motor.Part0 = target
    motor.Part1 = newPart
    motor.Parent = target
    
    local connection = rs.PostSimulation:Connect(function()
        if part and target and part.Parent then
            part.CFrame = newPart.CFrame
            part.Velocity = NETLESS_VEL
        end
    end)
    
    return motor
end

-- Automatically collects 1x1x2 parts and welds to the character to make it visible for other players
-- If you don't have the same accessory for the head, you can weld another part to the head instead
-- You can also build the body manually
function Reanim:BuildBody(character)
    -- Limbs and offsets for the 1x1x2 parts
    local limbTargets = {"Torso", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    local limbOffsets = {
        CFrame.new(-0.5, 0, 0) * CFrame.Angles(math.rad(90), 0, 0),
        CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(90), 0, 0),
        CFrame.Angles(math.rad(90), 0, 0),
        CFrame.Angles(math.rad(90), 0, 0),
        CFrame.Angles(math.rad(90), 0, 0),
        CFrame.Angles(math.rad(90), 0, 0)
    }
    
    local foundLimbs = 0
    for _, acc in ipairs(character:GetChildren()) do
        if acc:IsA("Accessory") and acc.Handle.Size == Vector3.new(1, 1, 2) then
            foundLimbs = foundLimbs + 1
            local handle = acc:FindFirstChildWhichIsA("BasePart")
            print(handle:GetFullName())
            
            if foundLimbs <= 6 then
                -- Strip the mesh to make it a block
                local mesh = handle:FindFirstChildWhichIsA("SpecialMesh", true)
                if mesh then mesh:Destroy() end
                
                self:WeldToLimb(handle, limbTargets[foundLimbs], limbOffsets[foundLimbs])
            end
            table.insert(self.parts, acc.Handle)
        elseif acc:IsA("Accessory") and acc.Handle.Size == Vector3.one and acc.Handle:FindFirstChildWhichIsA("SpecialMesh") and acc.Handle:FindFirstChildWhichIsA("SpecialMesh").MeshId == "rbxassetid://13953094351" then
            self:WeldToLimb(acc.Handle, "Head", CFrame.new(0,0,0))
        end
    end
    
    self.ghrp.CFrame = character.HumanoidRootPart.CFrame
    
    -- Duplicate original character rotation to fake rig to make things like shiftlock work
    local originalPosition = character:FindFirstChild("HumanoidRootPart").Position
    rs.PreSimulation:Connect(function()
        local torso = character:FindFirstChild("Torso")
        local head = character:FindFirstChild("Head")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChildWhichIsA("Humanoid")
        
        -- "Disable" the character
        if not self.params.DisableCharacterByCFrame and hum then
            hum.WalkSpeed = 1
            hum.UseJumpPower = true
            hum.JumpPower = 5
        elseif self.params.DisableCharacterByCFrame and hrp then
            hrp.CFrame = CFrame.new(originalPosition) * hrp.CFrame.Rotation
        end
        
        self.ghrp.CFrame = CFrame.new(self.ghrp.Position) * character.HumanoidRootPart.CFrame.Rotation
    end)
    
    -- Duplicate state
    rs.PostSimulation:Connect(function()
        local hum = character:FindFirstChildWhichIsA("Humanoid")
        
        if hum then
            self.ghum:Move(hum.MoveDirection)
            self.ghum.Jump = hum.Jump
        end
    end)
end

-- Reanimate the fake rig
local Animator = {}
Animator.__index = Animator

local rs = game:GetService("RunService")

function Animator.new(ghostRig)
    local self = setmetatable({}, Animator)
    self.ghost = ghostRig
    self.LerpSpeed = 0.2
    self.activeLayers = {}
    self.motors = {}

    -- Automatically find every Motor6D in the rig
    -- This captures standard limbs AND custom limbs added via MotorToLimb
    for _, motor in ipairs(ghostRig:GetDescendants()) do
        if motor:IsA("Motor6D") then
            if motor.Part1 then
                self.motors[motor.Part1.Name] = motor
            end
        end
    end
    
    return self
end

-- Play a temporary "Overlay" pose (like shooting)
function Animator:PlayTrack(poseTable, duration, priority)
    priority = priority or 1
    self.activeLayers[poseTable] = {
        start = tick(),
        duration = duration,
        priority = priority
    }
end

-- Returns a list of all current timed poses
function Animator:GetAllPlayingTracks()
    local tracks = {}
    for pose, _ in pairs(self.activeLayers) do
        table.insert(tracks, pose)
    end
    return tracks
end

-- Hard reset: Stops everything and snaps motors to neutral
function Animator:StopAllTracks()
    self.activeLayers = {} -- Wipe the timed layers
    
    -- Optional: Snap motors back to identity to prevent "ghost" posing
    for _, motor in pairs(self.motors) do
        motor.Transform = CFrame.new()
    end
end

-- 3. Force Play: Stops others and plays a specific one
function Animator:ForcePlayTrack(poseTable, duration, priority)
    self:StopAllTracks()
    self:PlayTrack(poseTable, duration, priority)
end

function Animator:Update(basePose)
    local finalTransforms = {}
    
    -- Initialize with base pose (Idle/Run)
    for limb, cf in pairs(basePose) do
        finalTransforms[limb] = cf
    end
    
    -- Overlay the timed layers
    for pose, data in pairs(self.activeLayers) do
        local elapsed = tick() - data.start
        
        if elapsed >= data.duration then
            self.activeLayers[pose] = nil -- Expired
        else
            -- Calculate weight based on time remaining (fade out)
            local weight = 1 - (elapsed / data.duration)
            
            for limb, cf in pairs(pose) do
                if finalTransforms[limb] then
                    -- Blend the layer on top of the base pose
                    finalTransforms[limb] = finalTransforms[limb]:Lerp(cf, weight)
                end
            end
        end
    end
    
    -- Apply to motors
    for limb, cf in pairs(finalTransforms) do
        if self.motors[limb] then
            self.motors[limb].Transform = self.motors[limb].Transform:Lerp(cf, self.LerpSpeed)
        end
    end
end

Reanim.Animator = Animator

return Reanim