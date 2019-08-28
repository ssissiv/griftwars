local Location = class( "Location", Entity )

function Location:init()
	Entity.init( self )
	self.exits = {}
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
	self.contents = {}
end

function Location:AddAgent( agent )
	assert( is_instance( agent, Agent ))
	assert( table.arrayfind( self.contents, agent ) == nil )

	table.insert( self.contents, agent )
end

function Location:RemoveAgent( agent )
	assert( is_instance( agent, Agent ))

	local idx = table.arrayfind( self.contents, agent )
	table.remove( self.contents, idx )
end

function Location:IsConnected( other )
	for i, exit in ipairs( self.exits ) do
		if exit:GetDest( self ) == other then
			return true, exit
		end
	end

	return false
end

function Location:Connect( other )
	assert( is_instance( other, Location ))
	assert( not self:IsConnected( other ))
	assert( not other:IsConnected( self ))

	local exit = Exit()
	exit:Connect( self, other )

	table.insert( self.exits, exit )
	table.insert( other.exits, exit )

	if not self:IsSpawned() and other:IsSpawned() then
		other.world:SpawnLocation( self )
	elseif self:IsSpawned() and not other:IsSpawned() then
		self.world:SpawnLocation( other )
	end
end

function Location:Exits()
	return ipairs( self.exits )
end

function Location:Contents()
	return ipairs( self.contents )
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


