--[[
	Basic way to attach two parts together
]]

local RunService = game:GetService("RunService")

local Settings = require(script.Parent.Settings)

export type AttachSettings = {
	c0 : CFrame | unknown,
	c1: CFrame | unknown,
	parent : BasePart,
	name : string,
	part : BasePart
}

local function Attach(AttachArgs : AttachSettings)
	local Motor6D = Instance.new("Motor6D",AttachArgs.parent)
	Motor6D.Name = "Attachment::" .. AttachArgs.name
	Motor6D.Part0 = AttachArgs.part
	Motor6D.Part1 = AttachArgs.parent
	if(AttachArgs.c0) then Motor6D.C0 = AttachArgs.c0 end
	if(AttachArgs.c1) then Motor6D.C1 = AttachArgs.c1 end
	return Motor6D
end

local module = {}

module.CreateAttach = function(Character : Model,AttachArgs : AttachSettings)
	if(not Character) then return end
	if(not Character.PrimaryPart) then return end
	local attach = Attach(AttachArgs)
	return attach
end

module.AttachWithHeartbeat = function(partToFollow : Part,Model : Instance)
	if(not Model or not partToFollow) then return end
	repeat
		task.wait()
	until Model ~= nil or partToFollow ~= nil
	if(Settings.RenderReplication == "Client") then
		script.Parent.RE.InitRender:FireAllClients(partToFollow,Model)
		return
	elseif(Settings.RenderReplication == "Server/Client") then
		script.Parent.RE.InitRender:FireAllClients(partToFollow,Model)
		return
	end
	return RunService.Heartbeat:Connect(function(deltaTime: number)
		if(Model.PivotTo) then
			Model:PivotTo(partToFollow.CFrame)
		else
			Model.CFrame = partToFollow.CFrame
		end		
	end)
end

module.DestroyAttach = function(Attach : Motor6D)
	if(not Attach) then return end
	Attach:Destroy()
end

return module
