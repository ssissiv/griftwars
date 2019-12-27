local UncleTrainer = class( "Relationship.UncleTrainer", Relationship )

function UncleTrainer:init( uncle, nephew )
	Relationship.init( self )

	self.uncle = self:AddAgent( uncle )
	self.newphew = self:AddAgent( nephew )
end

function UncleTrainer:GetDesc()
	return loc.format( "{1.Id} is {2.Id}'s last surviving uncle, who taught {2.Id} all {2.heshe} knows about using keen edges to defend oneself from trouble. {1.Id} left mysteriously during {2.Id}'s teenage years, but returned later to help care for the family. The reason {1.heshe} left was never spoken.",
		self.uncle, self.nephew )
end

local function Check( uncle, nephew )
	if nephew:GetGeneration() >= 2 and uncle:GetGeneration() ~= newphew:GetGeneration() + 1 then
		return false
	end
end

function UncleTrainer.MatchRelationship( world )
	world:SearchAgent( 2, Check )
end
