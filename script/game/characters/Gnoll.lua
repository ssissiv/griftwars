
---------------------------------------------------------------------

local Gnoll = class( "Agent.Gnoll", Agent )
Gnoll.unfamiliar_desc = "mangy gnoll"
Gnoll.image = assets.TILE_IMG.ORC
Gnoll.max_health = 25

function Gnoll:init()
	Agent.init( self )

	Agent.MakeGnoll( self )

	self:SetFlags( EF.AGGRO_OTHER_CLASS )
	self:DeltaLevel( 2 )
end

function Gnoll:GetMapChar()
	return "g", constants.colours.ORANGE
end

function Gnoll:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A pretty feral beast.", GENDER.MALE )

	self.inventory:AddItem( Object.Jerky() )
end

