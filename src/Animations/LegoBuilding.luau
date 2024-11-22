-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- License: MIT

local TweenService = game:GetService("TweenService")
local AnimationBase = require(script.Parent.Parent.AnimationBase)

local LegoBuildingAnimation = {}
LegoBuildingAnimation.__index = LegoBuildingAnimation
setmetatable(LegoBuildingAnimation, AnimationBase)

function LegoBuildingAnimation.new()
	local self = AnimationBase.new()
	setmetatable(self, LegoBuildingAnimation)
	return self
end

function LegoBuildingAnimation:Play(config, model, state)
	state.Running = true
	
	local originPosition = config.Origin or Vector3.new(0, 50, 0)
	local goalCFrame = config.Goal or model:GetPivot()
	local parts = model:GetDescendants()

	for i, part in ipairs(parts) do
		if part:IsA("BasePart") then
			local localOffset = goalCFrame:PointToObjectSpace(part.Position)
			local startPosition = originPosition
			if config.RandomizeStart then
				startPosition += Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
			end

			part.Position = startPosition

			local tween = TweenService:Create(part, config.TweenInfo, {
				Position = goalCFrame:PointToWorldSpace(localOffset),
			})

			local connection = task.delay(i * (config.PartDelay or 0.05), function()
				if state.Running and not state.Paused then
					tween:Play()
				end
			end)

			table.insert(self.Connections, connection)
		end
	end
end

return LegoBuildingAnimation