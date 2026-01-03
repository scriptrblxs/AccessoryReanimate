# Getting Started

To start, you should have already loaded the reanimator thru the small guide in `README.md`.

```lua
-- Method 1
local AccessoryReanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptrblxs/AccessoryReanimate/refs/heads/main/AccessoryReanimate.lua"))()

-- Method 2
local AccessoryReanimate = loadfile("AccessoryReanimate.lua")()
```

## Loading the character

To create a new rig, you initialize one with `AccessoryReanimate.new(id, params)`.
You can use a custom rig (thru model id) with the `id` parameter.

```lua
local Controller = AccessoryReanimate.new() -- Load a default R6 rig

local rig = Controller.ghost
local humanoid = Controller.ghum
local rootPart = Controller.ghrp
```

## Making the character visible

This is the point we have to use accessories!
`Controller:BuildBody(character)` goes through the children in the character model provided and checks for 1x1x2 size handle accessories.
It also checks for accessories with a specific mesh id for the rig's head.
You can use `Controller:WeldToLimb(part, limbName, offsetCFrame)` to weld a different part/accessory to the head if you don't have the accessory.
More information on it in [the api ref.](api/Controller.md#weldtolimbpartlimbnameoffset)

```lua
Controller:BuildBody(game.Players.LocalPlayer.Character)
Controller:WeldToLimb(headPart, "Head", CFrame.new(0,0,0))
```

## Finishing touches

You have now created an FE accessory-based rig!
You can add new limbs by using `Controller:MotorToLimb(part, limbName, c0, c1)`.
More information on it in [the api ref.](api/Controller.md#motortolimbpartlimbnamec0c1)