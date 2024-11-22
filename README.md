# Procedural Animator Module for Roblox
                                                                         
## Overview
The Procedural Animator module provides a versatile and modular system to animate Roblox models procedurally. It supports multiple animation types, offering full control over playback, pausing, resuming, and stopping animations.

## Features
- **Supported Animation Types**:
  - `LegoBuilding`: Sequential "building" effect.
  - `Wave`: Smooth oscillating motion.
  - `Bounce`: Adds a bouncing effect.
  - `Spiral`: Spiral-like movement toward the goal.
  - `Explosion`: Parts "explode" outward and regroup at the goal.
- **Dynamic Speed Control**: Animation duration is calculated based on the `Speed` parameter.
- **Event-driven Design**: Emits events for `Started`, `Paused`, `Resumed`, and `Completed` states.
- **PrimaryPart Auto-Setting**: Automatically sets the `PrimaryPart` if not defined.
- **Force-to-Goal Functionality**: Snaps parts to their final positions when stopped.

## Configuration
The module uses a flexible configuration structure:

| **Parameter**     | **Type**                | **Description**                                                       |
|--------------------|-------------------------|------------------------------------------------------------------------|
| `Origin`          | `Vector3?`             | Starting position for the animation.                                  |
| `Goal`            | `CFrame?`              | Final position of the model.                                          |
| `AnimationType`   | `string`               | Type of animation (e.g., "Wave", "Bounce").                           |
| `Speed`           | `number`               | Speed of the animation; inversely affects tween duration.             |
| `EasingStyle`     | `Enum.EasingStyle`     | Easing style for the animation.                                       |
| `EasingDirection` | `Enum.EasingDirection` | Easing direction for the animation.                                   |
| `Amplitude`       | `number?`              | Height of wave-like animations.                                       |
| `Frequency`       | `number?`              | Density of wave oscillations.                                         |
| `PartDelay`       | `number?`              | Delay between parts in sequential animations.                         |
| `RandomizeStart`  | `boolean?`             | Enables randomized starting positions for parts.                      |

## Usage Examples
### 1. LegoBuilding Animation
Creates a sequential "building" effect where parts animate into place one after the other.

```lua
local ProceduralAnimator = require(game.ReplicatedStorage.ProceduralAnimatorModule)
local config = {
    Origin = Vector3.new(0, 100, 0),
    Goal = workspace.Model:GetPivot(),
    AnimationType = "LegoBuilding",
    Speed = 1,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
    PartDelay = 0.1,
    RandomizeStart = false,
}
local animation = ProceduralAnimator.new(workspace.Model, config)
animation:Play()
```

### 2. Wave Animation
Adds a sinusoidal oscillation as parts animate to the goal.

```lua
local ProceduralAnimator = require(game.ReplicatedStorage.ProceduralAnimatorModule)
local config = {
    Origin = Vector3.new(0, 50, 0),
    Goal = workspace.Model:GetPivot(),
    AnimationType = "Wave",
    Speed = 2,
    Amplitude = 10,
    Frequency = 3,
    EasingStyle = Enum.EasingStyle.Sine,
    EasingDirection = Enum.EasingDirection.InOut,
}
local animation = ProceduralAnimator.new(workspace.Model, config)
animation:Play()
```

### 3. Bounce Animation
Adds a bouncing effect as parts animate to the goal position.

```lua
local ProceduralAnimator = require(game.ReplicatedStorage.ProceduralAnimatorModule)
local config = {
    Origin = Vector3.new(0, 50, 0),
    Goal = workspace.Model:GetPivot(),
    AnimationType = "Bounce",
    Speed = 1.5,
    Amplitude = 8,
    EasingStyle = Enum.EasingStyle.Elastic,
    EasingDirection = Enum.EasingDirection.Out,
}
local animation = ProceduralAnimator.new(workspace.Model, config)
animation:Play()
```

### 4. Spiral Animation
Parts animate in a spiral motion toward the goal.

```lua
local ProceduralAnimator = require(game.ReplicatedStorage.ProceduralAnimatorModule)
local config = {
    Origin = Vector3.new(0, 50, 0),
    Goal = workspace.Model:GetPivot(),
    AnimationType = "Spiral",
    Speed = 1,
    Amplitude = 12,
    Frequency = 2,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
}
local animation = ProceduralAnimator.new(workspace.Model, config)
animation:Play()
```

### 5. Explosion Animation
Parts "explode" outward and regroup at the goal position.

```lua
local ProceduralAnimator = require(game.ReplicatedStorage.ProceduralAnimatorModule)
local config = {
    Origin = Vector3.new(0, 50, 0),
    Goal = workspace.Model:GetPivot(),
    AnimationType = "Explosion",
    Speed = 1,
    explosionOffset = Vector3.new(10, 10, 10),
    explosionDistance = 20,
    explosionHeight = 5,
    EasingStyle = Enum.EasingStyle.Back,
    EasingDirection = Enum.EasingDirection.In,
}
local animation = ProceduralAnimator.new(workspace.Model, config)
animation:Play()
```

---

### Using Animation Module Methods

#### Play Animation
Starts the animation process.

```lua
animation:Play()
```

#### Stop Animation
Stops the animation. Use `forceToGoal` to snap all parts to the final position.

```lua
animation:Stop(true) -- Snaps parts to their goal position.
```

#### Pause Animation
Pauses the current animation.

```lua
animation:Pause()
```

#### Resume Animation
Resumes the animation from where it was paused.

```lua
animation:Resume()
```

#### Set to Origin
Resets the model to its starting position.

```lua
animation:SetToOrigin()
```

#### Animate to Goal
Animates the entire model to the goal position directly.

```lua
animation:AnimateToGoal()
```

---

### Adding New Animation Types
To create a new animation type:
1. Create a module inside the `Animations` directory.
2. Implement the following methods:
   - `Play(config: ProceduralAnimatorConfig, model: Model, state: ProceduralAnimatorState)`
   - `Stop(state: ProceduralAnimatorState)`
   - `Pause(state: ProceduralAnimatorState)`
   - `Resume(state: ProceduralAnimatorState)`
3. Register the module in the `Animations` folder. Example:

```lua
local CustomAnimation = {}
CustomAnimation.__index = CustomAnimation

function CustomAnimation.new()
    local self = setmetatable({}, CustomAnimation)
    return self
end

function CustomAnimation:Play(config, model, state)
    -- Implement animation logic here.
end

function CustomAnimation:Stop(state)
    -- Implement stopping logic here.
end

function CustomAnimation:Pause(state)
    -- Implement pause logic here.
end

function CustomAnimation:Resume(state)
    -- Implement resume logic here.
end

return CustomAnimation
```

## Adding New Animation Types
To add a new animation type:
1. Create a new module in the `Animations` directory.
2. Implement the `Play`, `Stop`, `Pause`, and `Resume` methods.
3. Register the module by placing it in the `Animations` folder.

## Dependencies
- **[FastSignal](https://github.com/fastrun1/FastSignal)**: For managing animation events.
- **ProceduralAnimators' Animation Modules**: Custom modules for each animation type.

---

### Contributing
Contributions are welcome! If you would like to contribute to this project:
1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`.
3. Commit your changes: `git commit -m "Add your feature"`.
4. Push to the branch: `git push origin feature/your-feature-name`.
5. Open a pull request describing your changes.

Make sure to follow these guidelines:
- Write clear and concise commit messages.
- Test your changes to ensure they do not break existing functionality.
- Document any new features or changes in the `README.md`.

---

### Issues
If you encounter any bugs or have feature requests, please open an issue in the [Issues](https://github.com/RAMPAGELLC/ProceduralAnimator/issues) tab of this repository. When submitting an issue:
- Provide a detailed description of the problem or request.
- Include steps to reproduce the bug, if applicable.
- Add any relevant screenshots or error logs.
- Specify your environment (e.g., Roblox (Studio/Client) version, Is this studio or client?, ProceduralAnimator version, etc.).

---

### License
This project is licensed under the MIT License. You are free to use, modify, and distribute this software, provided that the original copyright notice and license terms are included.

For more details, see the [LICENSE](./LICENSE) file.

Copyright © 2024 RAMPAGE Interactive. All rights reserved.
