--[[
	@Dummy
	
	A basic Object Class for Pets
	
	@usage
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local ServerStorage = game:GetService("ServerStorage")

	local Pet = require(ReplicatedStorage.Pet)

	Players.PlayerAdded:Wait()

	local ConstructedPet = Pet.new(game.Players:GetPlayers()[1],ServerStorage.PART_TO_ATTACH) 
	-- its must be a part to a better replication

	ConstructedPet:FollowOwner({
		parent = ConstructedPet.__Owner.Character.PrimaryPart, -- "HumanoidRootPart" from player.Character
		name = "TestAttach", -- Name of the Motor6D
		part = ConstructedPet.__Pet, -- This is the attached part e.g ServerStorage.PART_TO_ATTACH
		c0 = CFrame.new(5,1,-3) -- the default c0 of the part
	})

	ConstructedPet:RenderModel(workspace.Pets["Purple Puyopaca"]) 
	-- Model to render ex a model that contain mesh
]]

local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attach = require(script.Attach)
local Types = require(script.Types)
local Settings = require(script.Settings)

local PetTbl = {}
PetTbl.__index = PetTbl

--//Constructor

local Constructor = {}
Constructor.__index = Constructor

--[[
	@desc: Creates a new pet object
	@param: Player,
	@param: BasePart
]]
function Constructor.new<PetConstructor>(AttachToPlayer : Player, Pet : Model | BasePart) : Types.PetConstructor 
	local self = setmetatable({
		__Pet = Pet:Clone(),
		__Owner = AttachToPlayer,
		__FollowingPart = "None",
		__ModelRendered = false,
		__HeartConnectionForModelRendered = false,
	},PetTbl)
	self.__Pet.Parent = AttachToPlayer.Character or AttachToPlayer.CharacterAdded:Wait()
	return self
end

--//Methods

--[[
	@desc: Destroy the current pet object
]]
function PetTbl:Destroy()
	if(not self) then return end
	if(Settings.RenderReplication == "Client") then
		script.RE.StopRender:FireAllClients(self.__Pet)
	end
	if(self.__HeartConnectionForModelRendered) then 
		self.__HeartConnectionForModelRendered:Disconnect()
	end
	if(typeof(self.__ModelRendered) == "Instance") then self.__ModelRendered:Destroy() end
	if(type(self.__FollowingPart) ~= "string") then
		Attach.DestroyAttach(self.__FollowingPart)
	end	
	self.__FollowingPart = "None"
	self.__Pet:Destroy()
	table.clear(self)
	setmetatable(self,nil)
end

--//Methods

--[[
	@desc
	Make the current .__Pet follow your character
]]
function PetTbl:FollowOwner(AttachArgs : Attach.AttachSettings)
	if(not self or not self.__Pet or not self.__Owner) then return end
	if(type(self.__FollowingPart) ~= "string") then return end
	self.__FollowingPart = Attach.CreateAttach(self.__Owner.Character,AttachArgs)
	return self.__FollowingPart
end

--[[
	@desc
	Render a model that follow the .__Pet CFrame
	@param : Model
	@return : RBXScriptConnection
]]
function PetTbl:RenderModel(Model : Model)
	if(not Model) then return end
	if(typeof(self.__ModelRendered) == "Instance") then return end
	if(type(self.__FollowingPart) == "string") then
		warn("Please call :FollowOwner first before rendering any model.")
		return
	end
	self.__ModelRendered = Model:Clone()
	for i,basePart in pairs(self.__ModelRendered:GetDescendants()) do
		if(basePart.ClassName == "BillboardGui") then
			basePart.PetOwner.Text = self.__Owner.Name..Settings.PetOwnerNameSuffix
		end
		if(not basePart:IsA("BasePart")) then continue end
		basePart.CanCollide = false
	end
	self.__ModelRendered.Parent = self.__Pet.Parent
	self.__HeartConnectionForModelRendered = Attach.AttachWithHeartbeat(self.__Pet,self.__ModelRendered)
	return self.__HeartConnectionForModelRendered
end

--[[
	@desc
	Stop the actual rendered model usefull for quick change :RenderModel can be called just after
]]
function PetTbl:StopRendering()
	if(typeof(self.__ModelRendered) ~= "Instance") then 
		warn("No model is rendering actually make sure you called :RenderModel(Model) before calling this one.")
		return 
	end
	if(type(self.__FollowingPart) == "string") then
		warn("Please call :FollowOwner first before rendering any model.")
		return
	end
	if(Settings.RenderReplication == "Client") then
		script.RE.StopRender:FireAllClients(self.__Pet)
	end
	if(self.__HeartConnectionForModelRendered) then 
		self.__HeartConnectionForModelRendered:Disconnect()
		self.__HeartConnectionForModelRendered = false
	end
	if(self.__ModelRendered) then
		self.__ModelRendered:Destroy()
		self.__ModelRendered = false
	end
end

--[[
	@desc
	Change the C0 of the motor used to follow the player
]]
function PetTbl:ChangeC0(c0 : CFrame)
	if(type(self.__FollowingPart) == "string") then
		warn("Please call :FollowOwner first before rendering any model.")
		return
	end
	if(not c0) then c0 = CFrame.new(0,0,0) end
	self.__FollowingPart.C0 = c0
end

--[[
	@desc
	Change the C1 of the motor used to follow the player
]]
function PetTbl:ChangeC1(c1 : CFrame)
	if(type(self.__FollowingPart) == "string") then
		warn("Please call :FollowOwner first before rendering any model.")
		return
	end
	if(not c1) then c1 = CFrame.new(0,0,0) end
	self.__FollowingPart.C0 = c1
end

return table.freeze(Constructor)
