local Eat = class( "Verb.Eat", Verb )
Eat.act_desc = "Eat"

function Eat:init( actor, obj )
	Verb.init( self, actor )
	self.obj = obj
end

function Eat:GetDesc()
	local edible = self.obj:GetAspect( Aspect.Edible )
	return loc.format( "Eat {1} (restore {2} fatigue)", tostring(self.obj), edible:GetEnergyGain() )
end

function Eat:CanInteract()
	local edible = self.obj:GetAspect( Aspect.Edible )
	if not edible then
		return false, "Not edible"
	end
	return Verb.CanInteract( self )
end

function Eat:Interact()
	local edible = self.obj:GetAspect( Aspect.Edible )
	Msg:EchoTo( self.actor, "You eat {1}. You restore {2} fatigue.", self.obj, edible:GetEnergyGain() )
	self.actor:GetStat( STAT.FATIGUE ):DeltaValue( -edible:GetEnergyGain() )
	self.actor.world:DespawnEntity( self.obj )
end
