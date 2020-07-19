local ThrowObject = class( "Verb.ThrowObject", Verb.RangeAttack )

ThrowObject.INTENT_FLAGS = INTENT.HOSTILE
ThrowObject.act_desc = "Throw"

function ThrowObject:init( thrown )
	Verb.RangeAttack.init( self )
	self:SetThrown( thrown )
end

function ThrowObject:CanInteract( actor, target )
	if self.thrown == nil then
		self:SetThrown( actor:GetHeldObject())
	end
	return Verb.RangeAttack.CanInteract( self, actor, target )
end

function ThrowObject:SetThrown( obj )
	self.thrown = obj
	self.fatigue_cost = obj and obj.mass
end

function ThrowObject:GetDesc( viewer )
	return loc.format( "Throwing {1.desc}", self.thrown )
end

function ThrowObject:GetActDesc( actor )
	return loc.format( "Throw {1.desc} for {2} damage", self.thrown, self:CalculateDamage( self.obj ))
end	

function ThrowObject:CollectVerbs( verbs, actor, target )
	if verbs.id == "attacks" and actor:GetHeldObject() then
		verbs:AddVerb( Verb.ThrowObject():SetTarget( target ) )
	end
end

function ThrowObject:CalculateDC()
	return 2
end

function ThrowObject:Interact( actor, target )
	if self.thrown == nil then
		self:SetThrown( actor:GetHeldObject())
	end

	Msg:Speak( actor, "{1.desc}!", self.thrown )	
	Verb.RangeAttack.Interact( self, actor, target )
end
