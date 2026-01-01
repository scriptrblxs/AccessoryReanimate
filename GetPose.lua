local lplr = game.Players.LocalPlayer
local targetPlaceId = 99976961339475

-- Place check
if game.PlaceId ~= targetPlaceId then
    warn("Incorrect PlaceID. Exporter disabled.")
    return
end

-- Locate the rig
local rigValue = lplr:FindFirstChild("Rig")
if not rigValue or not rigValue.Value then
    warn("Rig Value not found in LocalPlayer.")
    return
end

local rigName = rigValue.Value
local rig

for _, Rig in ipairs(workspace.Rigs:GetChildren()) do
    if Rig == rigName then
        rig = Rig
    end
end

if not rig then
    warn("Target Rig '" .. tostring(rigName) .. "' not found in workspace.Rigs.")
    return
end

-- Extract pose
local function exportPose()
    local output = "local Pose = {\n"
    
    -- Map your animator names to the Rig's Motor6Ds
    local motorMap = {
        ["Torso"] = rig:FindFirstChild("HumanoidRootPart") and rig.HumanoidRootPart:FindFirstChild("RootJoint"),
        ["Head"] = rig:FindFirstChild("Torso") and rig.Torso:FindFirstChild("Neck"),
        ["Left Arm"] = rig:FindFirstChild("Torso") and rig.Torso:FindFirstChild("Left Shoulder"),
        ["Right Arm"] = rig:FindFirstChild("Torso") and rig.Torso:FindFirstChild("Right Shoulder"),
        ["Left Leg"] = rig:FindFirstChild("Torso") and rig.Torso:FindFirstChild("Left Hip"),
        ["Right Leg"] = rig:FindFirstChild("Torso") and rig.Torso:FindFirstChild("Right Hip"),
    }

    for limbName, motor in pairs(motorMap) do
        if motor then
            local cf = motor.Transform
            -- Format the CFrame components to 3 decimal places for cleanliness
            local components = {cf:GetComponents()}
            for i, v in ipairs(components) do
                components[i] = math.floor(v * 1000 + 0.5) / 1000
            end
            
            output = output .. string.format("    [\"%s\"] = CFrame.new(%s),\n", limbName, table.concat(components, ", "))
        else
            warn("Missing Motor6D for: " .. limbName)
        end
    end

    output = output .. "}"
    
    -- Output to Console
    print("\n--- EXPORTED POSE ---")
    print(output)
    print("---------------------\n")
    
    -- Copy to clipboard
    if setclipboard then
        setclipboard(output)
        print("Pose copied to clipboard!")
    end
end

exportPose()