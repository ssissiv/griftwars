local Location = class( "Location", Entity )

function Location:init()
	Entity.init( self )
	self.exits = {}
end

function Location:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.contents then
		for i, v in ipairs( self.contents ) do
			world:SpawnAgent( v )
		end
	end
end

function Location:LocTable()
	return self
end

function Location:SetCoordinate( x, y, z )
	self.x = x
	self.y = y
	self.z = z
end

function Location:GetCoordinate()
	return self.x, self.y, self.z
end

function Location:SetImage( image )
	self.image = image
end

function Location:GetImage( image )
	return self.image
end

function Location:SetDetails( title, desc )
	self.title = title
	self.desc = desc
end

function Location:SpawnAgent( agent )
	self.world:SpawnAgent( agent, self )
end

function Location:AddAgent( agent )
	assert( is_instance( agent, Agent ))
	assert( self.contents == nil or table.arrayfind( self.contents, agent ) == nil )
	assert( agent.world == self.world, tostring(agent.world))
	assert( agent.location == self )
	
	if self.contents == nil then
		self.contents = {}
	end

	table.insert( self.contents, agent )
	agent:ListenForEvent( AGENT_EVENT.COLLECT_VERBS, self, self.OnCollectVerbs )

	self:BroadcastEvent( LOCATION_EVENT.AGENT_ADDED, agent )
end

function Location:RemoveAgent( agent )
	assert( is_instance( agent, Agent ))

	agent:RemoveListener( self )
	local idx = table.arrayfind( self.contents, agent )
	table.remove( self.contents, idx )

	self:BroadcastEvent( LOCATION_EVENT.AGENT_REMOVED, agent )
end

function Location:OnCollectVerbs( event_name, actor, verbs, ... )
	if select( "#", ... ) == 0 then
		for i, exit in ipairs( self.exits ) do
			verbs:AddVerb( Verb.LeaveLocation( actor, exit:GetDest( self )))
		end
	end
end

function Location:IsConnected( other )
	for i, exit in ipairs( self.exits ) do
		if exit:GetDest( self ) == other then
			return true, exit
		end
	end

	return false
end

local function SpawnLocation( location, world )
	if location:IsSpawned() then
		return false
	else
		world:SpawnLocation( location )
		return true
	end
end

function Location:Connect( other )
	assert( other ~= nil )
	assert( is_instance( other, Location ))
	assert( not self:IsConnected( other ))
	assert( not other:IsConnected( self ))

	local exit = Exit()
	exit:Connect( self, other )

	table.insert( self.exits, exit )
	table.insert( other.exits, exit )

	if not self:IsSpawned() and other:IsSpawned() then
		self:Visit( SpawnLocation, other.world )
	elseif self:IsSpawned() and not other:IsSpawned() then
		other:Visit( SpawnLocation, self.world )
	end
end

function Location:Exits()
	return ipairs( self.exits )
end

local function VisitInternal( visited, location, fn, ... )
	visited[ location ] = true
	if not fn( location, ... ) then
		return
	end

	for i, exit in ipairs( location.exits ) do
		local dest = exit:GetDest( location )
		if visited[ dest ] == nil then
			VisitInternal( visited, dest, fn, ... )
		end
	end
end

function Location:Visit( fn, ... )
	VisitInternal( {}, self, fn, ... )
end

function Location:Contents()
	return ipairs( self.contents or table.empty )
end

function Location:GetTitle()
	return self.title or "No Title"
end

function Location:GetDesc()
	return self.desc or "No Desc"
end

function Location:__tostring()
	return self:GetTitle()
end


