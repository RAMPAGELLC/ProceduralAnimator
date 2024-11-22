-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- License: MIT

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local AnimationBase = require(script.Parent.Parent.AnimationBase)

local WaveAnimation = {}
WaveAnimation.__index = WaveAnimation
setmetatable(WaveAnimation, AnimationBase)

function WaveAnimation.new()
	local self = AnimationBase.new()
	setmetatable(self, WaveAnimation)
	return self
end

function WaveAnimation:Play(config, model, state)
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

			local connection = (RunService:IsServer() and RunService.Heartbeat or RunService.RenderStepped):Connect(function(deltaTime)
				if state.Running and not state.Paused then
					local timeElapsed = tick()
					local waveOffset = math.sin(timeElapsed * (config.Speed or 1)) * (config.Amplitude or 5)
					part.Position += Vector3.new(0, waveOffset, 0)
				end
			end)

			tween:Play()
			table.insert(self.Connections, connection)
		end
	end
end

return WaveAnimation
