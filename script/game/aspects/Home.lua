-- Find a home with no home owner assigned
function World:FindVacantHome()
	local homes = ObtainWorkTable()
	for i, home in self:Bucket( Feature.Home ) do
		if home:GetHomeOwner() == nil then
			table.insert( homes, home )
		end
	end

	local home = table.arraypick( homes )
	ReleaseWorkTable( homes )
	return home
end

--------------------------------------------------------------
--

function Agent:GetHome()
	return self.home and self.home:GetLocation()
end

--------------------------------------------------------------
--

local Home = class( "Feature.Home", Feature )

function Home:init( home_owner )
	Feature.init( self )
	self.home_owner = home_owner
end

function Home:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	world:RegisterToBucket( self._class, self )
end

function Home:OnDespawn()
	self:GetWorld():UnregisterFromBucket( self._class, self )
end

function Home:SetHomeOwner( agent )
	assert( self.home_owner == nil )
	assert( is_instance( agent, Agent ))
	self.home_owner = agent
	agent.home = self
end

function Home:GetHomeOwner()
	return self.home_owner
end

function Home:__tostring()
	if self.owner then
		return string.format( "[%s: %s]", self._classname, self.owner:GetTitle() )
	else
		return string.format( "[%s]", self._classname )
	end
end


