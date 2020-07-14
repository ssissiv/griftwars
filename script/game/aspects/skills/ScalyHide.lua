
local ScalyHide = class( "Skill.ScalyHide", Aspect.Skill )

ScalyHide.desc = "Attacks require Piercing I to do any damage."
ScalyHide.name = "scaly hide"

ScalyHide.event_priorities =
{
	[ CALC_EVENT.DAMAGE ] = CALC_PRIORITY_SET
}

ScalyHide.event_handlers =
{
 	[ CALC_EVENT.DAMAGE ] = function( self, event_name, agent, acc, actor, target )
 		if target == self.owner then
 			acc:ReqPiercing( self )
	    end
    end,
}

function ScalyHide:init()
	Aspect.Skill.init( self, self._classname, 1, 1 )
end
