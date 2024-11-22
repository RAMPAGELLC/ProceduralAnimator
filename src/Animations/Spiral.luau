-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- License: MIT

local TweenService = game:GetService("TweenService")
local AnimationBase = require(script.Parent.Parent.AnimationBase)

local SpiralAnimation = {}
SpiralAnimation.__index = SpiralAnimation
setmetatable(SpiralAnimation, AnimationBase)

function SpiralAnimation.new()
	local self = AnimationBase.new()
	setmetatable(self, SpiralAnimation)
	return self
end

function SpiralAnimation:Play(config, model, state)
	state.Running = true
	local originPosition = config.Origin or Vector3.new(0, 50, 0)
	local goalCFrame = config.Goal or model:GetPivot()
	local parts = model:GetDescendants()

	for i, part in ipairs(parts) do
		if part:IsA("BasePart") then
			local localOffset = goalCFrame:PointToObjectSpace(part.Position)

			-- Set part's starting position in a spiral pattern
			local angle = i * math.pi * 0.25 -- Adjust spacing between parts
			local radius = 10 + (i * 2) -- Gradually increase radius
			local startX = originPosition.X + radius * math.cos(angle)
			local startZ = originPosition.Z + radius * math.sin(angle)
			part.Position = Vector3.new(startX, originPosition.Y, startZ)

			local tween = TweenService:Create(part, config.TweenInfo, {
				Position = goalCFrame:PointToWorldSpace(localOffset),
			})

			-- Delayed sequential effect
			local connection = task.delay(i * (config.PartDelay or 0.05), function()
				if state.Running and not state.Paused then
					tween:Play()
				end
			end)

			table.insert(self.Connections, connection)
		end
	end
end

return SpiralAnimation