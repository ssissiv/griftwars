local Bleed = class( "StatusEffect.Bleed", Aspect.StatusEffect )

Bleed.tick_duration = ONE_MINUTE
Bleed.name = "Bleeding"

function Bleed:TickStatusEffect()
	Msg:EchoTo( self.owner, "Your life bleeds out of you! ({1} damage)", self.stacks )
	Msg:EchoAround( self.owner, "{1.Id} is bleeding! (Suffers {3} damage)", self.owner, nil, self.stacks )
	self.owner:DeltaHealth( -self.stacks )
	if self.owner == nil then
		return -- killed our owner
	end

	self.owner:Interrupt( "Bleeding" )
	self:LoseStacks( 1 )
end

function Bleed:OnExpireStatusEffect()
	Msg:EchoTo( self.owner, "Your bleeding seems to stop." )
end
