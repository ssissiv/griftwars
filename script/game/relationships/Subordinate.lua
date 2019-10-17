local Subordinate = class( "Relationship.Subordinate", Relationship )

function Subordinate:init( boss, subordinate )
	Relationship.init( self )

	self.boss = self:AddAgent( boss )
	self.subordinate = self:AddAgent( subordinate )
end
