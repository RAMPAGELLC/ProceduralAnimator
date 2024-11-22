--!strict

--[[
 ____                                 __                         ___       ______                                    __                   
/\  _`\                              /\ \                       /\_ \     /\  _  \          __                      /\ \__                
\ \ \L\ \_ __   ___     ___     __   \_\ \  __  __  _ __    __  \//\ \    \ \ \L\ \    ___ /\_\    ___ ___      __  \ \ ,_\   ___   _ __  
 \ \ ,__/\`'__\/ __`\  /'___\ /'__`\ /'_` \/\ \/\ \/\`'__\/'__`\  \ \ \    \ \  __ \ /' _ `\/\ \ /' __` __`\  /'__`\ \ \ \/  / __`\/\`'__\
  \ \ \/\ \ \//\ \L\ \/\ \__//\  __//\ \L\ \ \ \_\ \ \ \//\ \L\.\_ \_\ \_   \ \ \/\ \/\ \/\ \ \ \/\ \/\ \/\ \/\ \L\.\_\ \ \_/\ \L\ \ \ \/ 
   \ \_\ \ \_\\ \____/\ \____\ \____\ \___,_\ \____/\ \_\\ \__/.\_\/\____\   \ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \__/.\_\\ \__\ \____/\ \_\ 
    \/_/  \/_/ \/___/  \/____/\/____/\/__,_ /\/___/  \/_/ \/__/\/_/\/____/    \/_/\/_/\/_/\/_/\/_/\/_/\/_/\/_/\/__/\/_/ \/__/\/___/  \/_/ 
                                                                                                                                          
	Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
	License: MIT
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local FastSignal = require(game.ReplicatedStorage.FastSignal)

local AnimationType = {
	LegoBuilding = "LegoBuilding",
	Wave = "Wave",
	Bounce = "Bounce",
	Spiral = "Spiral",
	Explosion = "Explosion",
}

export type AnimationType = typeof(AnimationType)

export type ProceduralAnimatorConfig = {
	Origin: Vector3?, -- Starting position of the animation
	Goal: CFrame?, -- Final position of the model
	AnimationType: string, -- Type of animation: "Wave", "Bounce", "LegoBuilding", etc.
	Speed: number, -- Speed of the animation; affects TweenInfo.Time
	EasingStyle: Enum.EasingStyle, -- Easing style for TweenInfo
	EasingDirection: Enum.EasingDirection, -- Easing direction for TweenInfo
	Amplitude: number?, -- Height of wave or bounce (for applicable animations)
	Frequency: number?, -- Density of wave (for "Wave" animation)
	PartDelay: number?, -- Delay between parts for sequential animations (e.g., LegoBuilding)
	RandomizeStart: boolean?, -- Randomize the starting position of parts (for applicable animations)

	TweenInfo: TweenInfo?; -- Do not define; Automatically set!
	
	explosionOffset: Vector3?; -- Specifically for the "Explosion" AnimationType.
	explosionDistance: number?;
	explosionHeight: number?;
}

export type ProceduralAnimatorState = {
	Running: boolean,
	Paused: boolean,
}

export type ProceduralAnimatorEvents = {
	Started: typeof(FastSignal.new()),
	Paused: typeof(FastSignal.new()),
	Resumed: typeof(FastSignal.new()),
	Completed: typeof(FastSignal.new()),
}

export type ProceduralAnimatorModule = {
	Play: (self: ProceduralAnimatorModule, config: ProceduralAnimatorConfig, model: Model, state: ProceduralAnimatorState) -> (),
	Stop: (self: ProceduralAnimatorModule, state: ProceduralAnimatorState) -> (),
	Pause: (self: ProceduralAnimatorModule, state: ProceduralAnimatorState) -> (),
	Resume: (self: ProceduralAnimatorModule, state: ProceduralAnimatorState) -> (),
}

export type ProceduralAnimator = {
	Model: Model,
	Config: ProceduralAnimatorConfig,
	Events: ProceduralAnimatorEvents,
	State: ProceduralAnimatorState,
	Animation: {[string]: ProceduralAnimatorModule}, -- Animations stored by type
	TweenInfo: TweenInfo,
	Connection: typeof(FastSignal.new())?,
	Play: (self: ProceduralAnimator) -> (),
	Stop: (self: ProceduralAnimator, forceToGoal: boolean?) -> (),
	Pause: (self: ProceduralAnimator) -> (),
	Resume: (self: ProceduralAnimator) -> (),
	AnimateToGoal: (self: ProceduralAnimator) -> Tween,
	SetToOrigin: (self: ProceduralAnimator) -> (),
	AutoSetPrimaryPart: (self: ProceduralAnimator) -> (),
}

local ProceduralAnimator = {}
ProceduralAnimator.__index = ProceduralAnimator
ProceduralAnimator.AnimationType = AnimationType

-- Constructor
function ProceduralAnimator.new(model: Model, config: ProceduralAnimatorConfig?): ProceduralAnimator
	assert(model:IsA("Model"), "ProceduralAnimator requires a valid Model")

	-- Default configuration
	local defaultConfig: ProceduralAnimatorConfig = {
		Origin = Vector3.new(0, 50, 0),
		Speed = 1, -- Default speed
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
		AnimationType = "LegoBuilding", -- Default animation type
		Goal = model:GetPivot(),
		Amplitude = 5,
		Frequency = 2,
		PartDelay = 0.05,
		RandomizeStart = false,
	}

	-- Merge custom config with defaults
	if config then
		for key, value in pairs(config) do
			defaultConfig[key] = value
		end
	end

	-- Calculate TweenInfo dynamically based on Speed
	local tweenDuration = 1 / defaultConfig.Speed -- Inverse relationship: Higher speed = shorter time
	local tweenInfo = TweenInfo.new(
		tweenDuration, -- Duration based on speed
		defaultConfig.EasingStyle, -- User-provided EasingStyle
		defaultConfig.EasingDirection -- User-provided EasingDirection
	)

	-- Initialize the ProceduralAnimator object
	local self = setmetatable({}, ProceduralAnimator) :: ProceduralAnimator
	self.Model = model
	self.Config = defaultConfig
	self.Config.TweenInfo = tweenInfo
	self.Events = {
		Started = FastSignal.new(),
		Paused = FastSignal.new(),
		Resumed = FastSignal.new(),
		Completed = FastSignal.new(),
	}
	self.State = {Running = false, Paused = false}
	self.Connection = nil
	self.Animation = {}

	-- Auto-set PrimaryPart if missing
	if not model.PrimaryPart then
		self:AutoSetPrimaryPart()
	end

	-- Load animation modules based on AnimationType
	for _, v: ModuleScript in pairs(script.Animations:GetChildren()) do
		if v:IsA("ModuleScript") then
			local module = require(v)
			assert(module.new, "Animation module must implement a `new` constructor.")
			self.Animation[v.Name] = module.new()
		end
	end

	return self
end

-- Auto-set PrimaryPart based on bounding box
function ProceduralAnimator:AutoSetPrimaryPart()
	local parts = self.Model:GetDescendants()
	local largestPart: BasePart? = nil
	local largestVolume: number = 0

	for _, part: Instance in ipairs(parts) do
		if part:IsA("BasePart") then
			local size: Vector3 = part.Size
			local volume: number = size.X * size.Y * size.Z

			if volume > largestVolume then
				largestVolume = volume
				largestPart = part
			end
		end
	end

	if largestPart then
		self.Model.PrimaryPart = largestPart
	else
		error("ProceduralAnimator: Model has no BasePart to set as PrimaryPart!")
	end
end

-- Set model to the origin position
function ProceduralAnimator:SetToOrigin()
	local primaryPart: BasePart = self.Model.PrimaryPart
	local pivotOffset: Vector3 = primaryPart.Position - self.Model:GetPivot().Position
	local origin: Vector3 = self.Config.Origin or Vector3.new(0, 50, 0)

	self.Model:PivotTo(CFrame.new(origin + pivotOffset))
end

-- Tween the model to the goal position
function ProceduralAnimator:AnimateToGoal(): Tween
	local primaryPart: BasePart = self.Model.PrimaryPart
	assert(primaryPart, "ProceduralAnimator: No PrimaryPart set for the model.")
	local tween = TweenService:Create(primaryPart, self.Config.TweenInfo, {CFrame = self.Config.Goal})
	tween:Play()
	return tween
end

-- Play animation
function ProceduralAnimator:Play()
	if self.State.Running then return end

	self.State.Running = true
	self.State.Paused = false
	self.Events.Started:Fire()

	local animationModule = self.Animation[self.Config.AnimationType]

	if animationModule then
		animationModule:Play(self.Config, self.Model, self.State)
	else
		error("Invalid AnimationType: " .. tostring(self.Config.AnimationType))
	end
end

-- Stop animation
-- @param forceToGoal (boolean?): If true, all parts will immediately snap to their goal positions.
function ProceduralAnimator:Stop(forceToGoal: boolean?)
	if not self.State.Running then return end

	if self.Connection then
		self.Connection:Disconnect()
	end

	self.State.Running = false
	self.State.Paused = false

	local animationModule = self.Animation[self.Config.AnimationType]

	if animationModule then
		-- Stop the specific animation
		animationModule:Stop(self.State)

		-- If forceToGoal is true, move all parts to their Goal position
		if forceToGoal then
			local goalCFrame = self.Config.Goal or self.Model:GetPivot()
			
			for _, part in ipairs(self.Model:GetDescendants()) do
				if part:IsA("BasePart") then
					local localOffset = goalCFrame:PointToObjectSpace(part.Position)
					part.Position = goalCFrame:PointToWorldSpace(localOffset)
				end
			end
		end
	else
		error("Invalid AnimationType: " .. tostring(self.Config.AnimationType))
	end
end

-- Pause animation
function ProceduralAnimator:Pause()
	if not self.State.Running or self.State.Paused then return end

	self.State.Paused = true
	self.Events.Paused:Fire()

	local animationModule = self.Animation[self.Config.AnimationType]

	if animationModule then
		animationModule:Pause(self.State)
	else
		error("Invalid AnimationType: " .. tostring(self.Config.AnimationType))
	end
end

-- Resume animation
function ProceduralAnimator:Resume()
	if not self.State.Running or not self.State.Paused then return end

	self.State.Paused = false
	self.Events.Resumed:Fire()

	local animationModule = self.Animation[self.Config.AnimationType]

	if animationModule then
		animationModule:Resume(self.State)
	else
		error("Invalid AnimationType: " .. tostring(self.Config.AnimationType))
	end
end

return ProceduralAnimator