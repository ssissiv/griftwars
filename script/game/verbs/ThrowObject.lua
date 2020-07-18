local ThrowObject = class( "Verb.ThrowObject", Verb.RangeAttack )

ThrowObject.INTENT_FLAGS = INTENT.HOSTILE
ThrowObject.act_desc = "Throw"

function ThrowObject:init( thrown )
	Verb.RangeAttack.init( self )
	self:SetThrown( thrown )
end

function ThrowObject:SetThrown( obj )
	self.thrown = obj
	self.fatigue_cost = obj.mass
end

function ThrowObject:GetDesc( viewer )
	return loc.format( "Throwing {1.desc}", self.thrown )
end

function ThrowObject:GetActDesc( actor )
	return loc.format( "Throw {1.desc} for {2} damage", self.thrown, self:CalculateDamage( self.obj ))
end	

function ThrowObject:CalculateDC()
	return 2
end
