local Hobbled = class( "StatusEffect.Hobbled", Aspect.StatusEffect )

Hobbled.tick_duration = ONE_MINUTE
Hobbled.name = "Hobbled"

Hobbled.event_handlers =
{
	[ CALC_EVENT.MOVE_SPEED ] = function( self, event_name, agent, acc )
		acc:MultiplyValue( 2, self, self:GetDesc() )
	end
}

function Hobbled:TickStatusEffect()
	self:LoseStacks( 1 )
end

function Hobbled:OnGainStatusEffect()
	Msg:EchoTo( self.owner, "Your movement is crippled." )
end

function Hobbled:OnExpireStatusEffect()
	Msg:EchoTo( self.owner, "You can move normally again." )
end
