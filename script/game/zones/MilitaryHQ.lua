local MilitaryHQ = class( "Location.MilitaryHQ", Location )

function MilitaryHQ:OnSpawn( world )
	local function GetName( room )
		return loc.format( "War Chambers of {1}", room:GetAspect( Aspect.Faction ):GetName() )
	end

	self:SetDetails( GetName, "An open room crammed with old tech and metal debris.")
	self:GainAspect( Feature.StrategicPoint() )
	self:GainAspect( Aspect.Faction( self.faction ))
	self:GainAspect( Aspect.BuildingTileMap( 16, 16 ))

	local commander = Agent.Captain()
	commander:GainAspect( Aspect.Faction( self.faction ))
	commander:WarpToLocation( self )
end
