
local Discovered = class( "Feature.Discovered", Feature )

function Discovered:Discover( agent )
	if self.seen_by == nil then
		self.seen_by = {}
	end
	if self.seen_by[ agent ] == nil then
		self.seen_by[ agent ] = self:GetWorld():GetDateTime()

		agent:RewardXP( self.location:GetLocationDepth(), loc.format( "Discovered {1}", self.owner:GetTitle()) )
	end
end

function Discovered:IsDiscovered( agent )
	return self.seen_by[ agent ] ~= nil
end

