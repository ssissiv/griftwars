
---------------------------------------------------------------------

local HillGiant = class( "Agent.HillGiant", Agent )
HillGiant.unfamiliar_desc = "hill giant"
HillGiant.image = assets.TILE_IMG.HILL_GIANT

HillGiant.max_health = 82
HillGiant.strength = 14

function HillGiant:init()
	Agent.init( self )

	Agent.MakeHillGiant( self )

	self:SetFlags( EF.AGGRO_ALL )

	self:GainAspect( Verb.GrabNearbyBoulders( self ) )
	self:DeltaLevel( 9 )
end

function HillGiant:CollectVerbs( verbs, actor, target )
	if verbs.id == "attacks" and self == actor and actor:GetHeldObject() then
		verbs:AddVerb( Verb.ThrowObject( actor, target, actor:GetHeldObject() ) )
	end
end

function HillGiant:GetMapChar()
	return "H", constants.colours.YELLOW
end
