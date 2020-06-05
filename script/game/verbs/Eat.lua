local Eat = class( "Verb.Eat", Verb )

function Eat:GetDesc()
	local edible = self.obj:GetAspect( Aspect.Edible )
	return loc.format( "Eat {1} (restore {2} fatigue)", tostring(self.obj), edible:GetEnergyGain() )
end

function Eat:CanInteract( actor, obj )
	local edible = obj:GetAspect( Aspect.Edible )
	if not edible then
		return false, "Not edible"
	end
	return true
end

function Eat:Interact( actor, obj )	
	local edible = obj:GetAspect( Aspect.Edible )
	Msg:Echo( actor, "You eat {1}. You restore {2} fatigue.", obj, edible:GetEnergyGain() )
	actor:GetStat( STAT.FATIGUE ):DeltaValue( -edible:GetEnergyGain() )
	actor.world:DespawnEntity( obj )
end
