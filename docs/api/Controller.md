# Controller

Initialized/created with `AccessoryReanimate.new(id, params)`
Creates the rig and handles accessories for it.

## Summary

- Properties
 - ghost: [Model](https://create.roblox.com/docs/reference/engine/classes/Model)
 - ghrp: [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart)
 - ghum: [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid)
 - params: [table](https://www.lua.org/pil/2.5.html)
 - parts: [table](https://www.lua.org/pil/2.5.html)
 - ~~limbs: [table](https://www.lua.org/pil/2.5.html)~~
- Methods
 - :BuildBody(character: [Model](https://create.roblox.com/docs/reference/engine/classes/Model)): ()
 - :WeldToLimb(part: [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart), limbName: [string](https://create.roblox.com/docs/luau/strings), offset: [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame)): [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection)
 - :MotorToLimb(part: [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart), limbName: [string](https://create.roblox.com/docs/luau/strings), C0: [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame), C1: [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame)): [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D), [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection)

## Properties

### ghost
**Type:** [Model](https://create.roblox.com/docs/reference/engine/classes/Model)

The "Ghost" character model created by the controller. This acts as the invisible or client-side rig that dictates where accessories should be positioned during the reanimation process.

### ghrp
**Type:** [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart)

The **GhostHumanoidRootPart**. This is the primary root component of the ghost rig, used for movement calculation and as the primary CFrame reference for the assembly.

### ghum
**Type:** [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid)

The Humanoid instance belonging to the ghost rig. This is used to play animations, monitor health states, and manage physical properties like `HipHeight`.

### params
**Type:** [table](https://www.lua.org/pil/2.5.html)

A table containing the configuration data passed through the constructor. This typically includes settings like `Netless`, `Fling`, or specific rig offsets.

### parts
**Type:** [table](https://www.lua.org/pil/2.5.html)

A dictionary containing references to all active BaseParts managed by the controller, indexed by their specific role or limb name.

---

## Methods

### :BuildBody(character)
**Parameters:**
- `character`: [Model](https://create.roblox.com/docs/reference/engine/classes/Model) — The source character model to replicate.

Initializes the internal ghost rig. It maps the source character's proportions and hierarchy to create a functional reanimation base.

### :WeldToLimb(part, limbName, offset)
**Parameters:**
- `part`: [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart) — The part to be attached.
- `limbName`: [string](https://create.roblox.com/docs/luau/strings) — The name of the limb on the ghost rig (e.g., "RightArm").
- `offset`: [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame) — The positional and rotational offset.

**Returns:** [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection)

Rigidly attaches a part to a ghost limb. This method uses a `RunService` connection to update the CFrame manually.

### :MotorToLimb(part, limbName, C0, C1)
**Parameters:**
- `part`: [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart) — The part to be attached.
- `limbName`: [string](https://create.roblox.com/docs/luau/strings) — The target limb.
- `C0`: [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame) — The joint's primary offset.
- `C1`: [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame) — The joint's secondary offset.

**Returns:** [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D), [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection)

Creates a `Motor6D` joint between a new part and the limb, then attaching the part to the invisible new part/limb, allowing for animated movement. Returns both the created joint and the connection used to attach the part to the created new limb.