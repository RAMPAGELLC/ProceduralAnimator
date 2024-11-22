-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- License: MIT

local TweenService = game:GetService("TweenService")
local AnimationBase = require(script.Parent.Parent.AnimationBase)

local BounceAnimation = {}
BounceAnimation.__index = BounceAnimation
setmetatable(BounceAnimation, AnimationBase)

function BounceAnimation.new()
	local self = AnimationBase.new()
	setmetatable(self, BounceAnimation)
	return self
end

function BounceAnimation:Play(config, model, state)
	state.Running = true
	
	local originPosition = config.Origin or Vector3.new(0, 50, 0)
	local goalCFrame = config.Goal or model:GetPivot()
	local parts = model:GetDescendants()

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			local localOffset = goalCFrame:PointToObjectSpace(part.Position)
			part.Position = originPosition

			local tween = TweenService:Create(part, config.TweenInfo, {
				Position = goalCFrame:PointToWorldSpace(localOffset),
			})

			tween:Play()
			table.insert(self.Connections, tween)
		end
	end
end

return BounceAnimation
