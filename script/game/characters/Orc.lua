
---------------------------------------------------------------------

local Orc = class( "Agent.Orc", Agent )
Orc.unfamiliar_desc = "wild orc"
Orc.image = assets.TILE_IMG.ORC

function Orc:init()
	Agent.init( self )

	Agent.MakeOrc( self )

	self:GainAspect( Aspect.Behaviour() )

	self:SetFlags( EF.AGGRO_OTHER_CLASS )
end

function Orc:GetMapChar()
	return "o", constants.colours.GREEN
end

function Orc:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A pretty feral beast.", GENDER.MALE )

	self.inventory:AddItem( Object.Jerky() )
end

