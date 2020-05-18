
---------------------------------------------------------------------

local Orc = class( "Agent.Orc", Agent )

function Orc:init()
	Agent.init( self )

	Agent.MakeOrc( self )

	self:GainAspect( Aspect.Behaviour() )

	self:SetFeral( true )
end

function Orc:GetShortDesc()
	return "wild orc"
end

function Orc:GetMapChar()
	return "o", constants.colours.GREEN
end

function Orc:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A pretty feral beast.", GENDER.MALE )

	self.inventory:AddItem( Object.Jerky() )
end

