local Trait = class( "Trait", Aspect )

---------------------------------------------------------------

local Cowardly = class( "Trait.Cowardly", Aspect )
Cowardly.STRINGS =
{
	"You push {2.name} around and enjoy it.",
	"{1.name} pushes you around roughly. Jerk.",
	"{1.name} pushes {2.name} around.",
}

function Cowardly:GetDesc()
	return "Intimidate"
end

function Cowardly:CanInteract( actor, obj )
	if actor ~= self.agent and obj == self.agent then
		return true
	end
	return false
end

function Cowardly:Interact( actor, obj )
	obj.intimidated = true
	
	Msg:Action( self.STRINGS, actor, obj )
end

---------------------------------------------------------------

---------------------------------------------------------------

local Poor = class( "Trait.Poor", Aspect )
Poor.STRINGS =
{
	"You give {2.name} {3#money}.",
	"{1.name} gives you {3#money}. Wonderful!",
	"{1.name} gives {2.name} some money.",
}

function Poor:GetDesc()
	return "Give some money"
end

function Poor:CanInteract( actor, obj )
	if actor ~= self.agent and obj == self.agent then
		if actor:GetInventory():GetMoney() < obj:GetPrestige() then
			return false, loc.format( "Requires at least {1#money}.", obj:GetPrestige() )
		else
			return true
		end
	end
	return false
end

function Poor:Interact( actor, obj )
	local delta = obj:GetPrestige()
	actor:GetInventory():DeltaMoney( -delta )
	obj:GetInventory():DeltaMoney( delta )

	Msg:Action( self.STRINGS, actor, obj, delta )
end

