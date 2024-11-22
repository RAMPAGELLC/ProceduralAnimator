-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- License: MIT

local AnimationBase = {}
AnimationBase.__index = AnimationBase

function AnimationBase.new()
	local self = setmetatable({}, AnimationBase)
	self.Running = false
	self.Paused = false
	self.Connections = {}
	return self
end

-- Base Play (override in child classes)
function AnimationBase:Play(config, model, state)
	error("Play must be implemented by an child class.")
end

-- Pause functionality
function AnimationBase:Pause(state)
	state.Paused = true
end

-- Resume functionality
function AnimationBase:Resume(state)
	state.Paused = false
end

-- Stop functionality
function AnimationBase:Stop(state)
	state.Running = false
	
	for _, conn in ipairs(self.Connections or {}) do
		if typeof(conn) == "RBXScriptConnection" or typeof(conn) == "table" and conn.Disconnect ~= nil then
			conn:Disconnect()
		elseif typeof(conn) == "thread" then
			task.cancel(conn)
		end
	end
	
	self.Connections = {}
end

return AnimationBase