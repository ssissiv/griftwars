local Bleed = class( "StatusEffect.Bleed", Aspect.StatusEffect )

Bleed.tick_duration = ONE_MINUTE
Bleed.max_ticks = 3
Bleed.name = "Bleeding"

function Bleed:TickStatusEffect()
	Msg:Echo( self.owner, "Your life bleeds out of you! ({1} damage)", self.stacks )
	Msg:ActToRoom( "{1.Id} is bleeding! (Suffers {3} damage)", self.owner, nil, self.stacks )
	self.owner:DeltaHealth( -self.stacks )
	if self.owner == nil then
		return -- killed our owner
	end

	self.owner:Interrupt( "Bleeding" )
	self:LoseStacks( 1 )
end

function Bleed:OnExpireStatusEffect()
	Msg:Echo( self.owner, "Your bleeding seems to stop." )
end
