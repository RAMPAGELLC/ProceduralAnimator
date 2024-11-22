-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- License: MIT

local TweenService = game:GetService("TweenService")
local AnimationBase = require(script.Parent.Parent.AnimationBase)

local ExplosionAnimation = {}
ExplosionAnimation.__index = ExplosionAnimation
setmetatable(ExplosionAnimation, AnimationBase)

function ExplosionAnimation.new()
	local self = AnimationBase.new()
	setmetatable(self, ExplosionAnimation)
	return self
end

function ExplosionAnimation:Play(config, model, state)
	state.Running = true

	local originPosition = config.Origin or Vector3.new(0, 50, 0)
	local parts = model:GetDescendants()

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			-- Compute explosion offsets
			config.explosionOffset = config.explosionOffset
				or Vector3.new(
					math.random(-100, 100) / 100, -- Normalize between -1 and 1
					math.random(50, 100) / 100, -- Upward bias for shrapnel motion
					math.random(-100, 100) / 100
				)
			config.explosionDistance = config.explosionDistance or math.random(30, 60) -- Randomized explosion distance
			config.explosionHeight = config.explosionHeight or math.random(50, 100) -- Randomized height boost

			-- Set the part's position at the explosion origin
			part.Position = originPosition

			-- Create a tween for outward motion
			local outwardTween = TweenService:Create(
				part,
				TweenInfo.new(
					1 / config.Speed, -- Duration inversely proportional to Speed
					Enum.EasingStyle.Linear, -- Linear motion outward
					Enum.EasingDirection.Out -- Motion fades out
				),
				{
					Position = originPosition + (config.explosionOffset.Unit * config.explosionDistance + Vector3.new(
						0,
						config.explosionHeight,
						0
					)),
				}
			)

			-- Play the tween
			outwardTween:Play()

			-- Store the tween connection for management
			table.insert(self.Connections, outwardTween)
		end
	end
end

return ExplosionAnimation
