require "game/aspects/features"

function Agent:GetHome()
	return self.home and self.home:GetLocation()
end

--------------------------------------------------------------
--

local Home = class( "Feature.Home", Feature )

function Home:init( home_owner )
	Feature.init( self )
	assert( home_owner == nil )
	self.residents = {}
end

function Home:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	world:RegisterToBucket( self._class, self )
	self.owner.map_colour = constants.colours.HOME_TILE
end

function Home:OnDespawn()
	self:GetWorld():UnregisterFromBucket( self._class, self )
end

function Home:AddResident( agent )
	assert( is_instance( agent, Agent ))
	agent.home = self

	table.insert( self.residents, agent )
	return self
end

function Home:IsResident( agent )
	return table.contains( self.residents, agent )
end

function Home:CountResidents()
	return #self.residents
end

function Home:__tostring()
	if self.owner then
		return string.format( "[%s: %s]", self._classname, self.owner:GetTitle() )
	else
		return string.format( "[%s]", self._classname )
	end
end


