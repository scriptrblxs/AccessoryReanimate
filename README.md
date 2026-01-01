# AccessoryReanimate
A stupidly simple yet "flexible" Reanimate script for exploiting on Roblox.

## Pros and Cons
Pros:
- Simple and flexible
- Custom rigs
- Uses accessories

Cons:
- Does not get the player's avatar with it
- Can break sometimes

## Installation

### Method 1
For Method 1, you load it normally thru `loadstring` and `game:HttpGet`
```lua
local AccessoryReanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptrblxs/AccessoryReanimate/refs/heads/main/AccessoryReanimate.lua"))()
```

### Method 2
For Method 2, instead of using HTTP, you download the `AccessoryReanimate.lua` file of any version and put it inside your executor's workspace, (for example `storage/emulated/0/Delta/Workspace` if you use Delta.) and can be loaded with loadfile.
```
local AccessoryReanimate = loadfile("AccessoryReanimate.lua")()
```

## Getting Started
