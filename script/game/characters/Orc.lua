
---------------------------------------------------------------------

local Orc = class( "Agent.Orc", Agent )
Orc.unfamiliar_desc = "wild orc"
Orc.image = assets.TILE_IMG.ORC
Orc.max_health = 16
Orc.level = 2

function Orc:init()
	Agent.init( self )

	Agent.MakeOrc( self )

	self:SetFlags( EF.AGGRO_OTHER_CLASS )
	self:DeltaLevel( 4 )
end

function Orc:GetMapChar()
	return "o", constants.colours.GREEN
end

function Orc:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A pretty feral beast.", GENDER.MALE )

	self.inventory:AddItem( Object.Jerky() )
end

