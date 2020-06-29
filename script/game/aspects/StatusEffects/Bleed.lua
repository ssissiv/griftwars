local Bleed = class( "StatusEffect.Bleed", Aspect.StatusEffect )

Bleed.tick_duration = ONE_MINUTE
Bleed.max_ticks = 3
Bleed.name = "Bleeding"

function Bleed:OnTickStatusEffect()
	Msg:Echo( self.owner, "Your life bleeds out of you!" )
	self.owner:DeltaHealth( -1 )
	self.owner:Interrupt( "Bleeding" )
end

function Bleed:OnExpireStatusEffect()
	Msg:Echo( self.owner, "Your bleeding seems to stop." )
end
