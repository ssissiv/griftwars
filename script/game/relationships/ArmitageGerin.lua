local ArmitageGerin = class( "Relationship.ArmitageGerin", Relationship )

function ArmitageGerin:init( shopkeep, collector )
	Relationship.init( self )

	self.shopkeep = shopkeep
	self.collector = collector

	self:AddAgent( shopkeep )
	self:AddAgent( collector )
end
