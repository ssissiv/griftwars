require "game/aspects/statvalue"

local HealthValue = class( "Aspect.HealthValue", Aspect.StatValue )

function HealthValue:init( value, max_value )
	HealthValue._base.init( self, STAT.HEALTH, value, max_value )
end

function HealthValue:DeltaValue( value, max_value )
	HealthValue._base.DeltaValue( self, value, max_value )
	if self.value <= 0 and not self.owner:IsDead() then
		self.owner:Kill()
	end
end

function HealthValue:RenderAgentDetails( ui, screen, viewer )
	ui.Text( "Health:" )
	ui.SameLine( 0, 5 )
	local txt = loc.format( "{1}/{2}", self.value, self.max_value )
	ui.TextColored( 0, 1, 0, 1, txt )
end