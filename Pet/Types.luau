--[[
	Type instruction
]]

local Attach = require(script.Parent.Attach)

export type PetConstructor = {
	__Pet : Model | BasePart,
	__Owner : Player,
	__FollowingPart : string | Instance,
	__ModelRendered : unknown | Model,
	__HeartConnectionForModelRendered : unknown | RBXScriptConnection,
	FollowOwner : (self : PetConstructor,AttachArgs : Attach.AttachSettings) -> Motor6D | unknown,
	RenderModel : (self : PetConstructor,Model : Model) -> RBXScriptConnection | unknown,
	StopRendering : (self : PetConstructor) -> ();
	ChangeC0 : (self : PetConstructor,C0 : CFrame) -> ();
	ChangeC1 : (self : PetConstructor,C1 : CFrame) -> ();
	Destroy : (self : PetConstructor) -> ();
}

return nil
