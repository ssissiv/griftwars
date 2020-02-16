
local function SpawnLocation( location, world )
	if location:IsSpawned() then
		return false
	else
		world:SpawnLocation( location )
		return true
	end
end


local Location = class( "Location", Entity )

function Location:init()
	Entity.init( self )
	self.exits = {}
	self.available_exits = { EXIT.NORTH, EXIT.EAST, EXIT.SOUTH, EXIT.WEST }
	self.map_colour = constants.colours.DEFAULT_TILE
end

function Location:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.contents then
		for i, v in ipairs( self.contents ) do
			if not v:IsSpawned() then
				world:SpawnEntity( v )
			end
		end
	end

	for exit, adj in pairs( self.exits ) do
		if exit == EXIT.NORTH then
			if self.y == nil then
				self.x, self.y = adj.x, adj.y - 1
			else
				assert( self.x == adj.x and self.y == adj.y - 1 )
			end
		elseif exit == EXIT.EAST then
			if self.x == nil then
				self.x, self.y = adj.x - 1, adj.y
			else
				assert( self.x == adj.x - 1 and self.y == adj.y )
			end
		elseif exit == EXIT.SOUTH then
			if self.y == nil then
				self.x, self.y = adj.x, adj.y + 1
			else
				assert( self.x == adj.x and self.y == adj.y + 1 )
			end
		elseif exit == EXIT.WEST then
			if self.x == nil then
				self.x, self.y = adj.x + 1, adj.y
			else
				assert( self.x == adj.x + 1 and self.y == adj.y )
			end
		end
	end

	if self.x and self.y then
		world:GetAspect( Aspect.WorldMap ):AssignToGrid( self )
	end
end

function Location:OnDespawn()
	Entity.OnDespawn( self )

	if self.x and self.y then
		self.world:GetAspect( Aspect.WorldMap ):UnassignFromGrid( self )
	end
end


function Location:LocTable()
	return self
end

function Location:SetCoordinate( x, y, z )
	if self.x then
		world:GetAspect( Aspect.WorldMap ):UnassignFromGrid( self )
	end

	self.x = x
	self.y = y
	self.z = z

	if self.world and self.x and self.y then
		world:GetAspect( Aspect.WorldMap ):AssignToGrid( self )
	end		
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


function Location:AddEntity( entity )
	assert( is_instance( entity, Entity ))
	assert( self.contents == nil or table.arrayfind( self.contents, entity ) == nil )
	assert( entity.location == self )
	
	if self.contents == nil then
		self.contents = {}
	end

	table.insert( self.contents, entity )

	if is_instance( entity, Agent ) then
		self:BroadcastEvent( LOCATION_EVENT.AGENT_ADDED, entity )
	end

	-- Spawn entity or self, if needed.
	if entity.world == nil and self.world then
		self.world:SpawnEntity( entity )		
	elseif entity.world and self.world == nil then
		SpawnLocation( self, entity.world )
	end

	entity:ListenForAny( self, self.OnEntityEvent )
end

function Location:RemoveEntity( entity )
	local idx = table.arrayfind( self.contents, entity )
	table.remove( self.contents, idx )

	entity:RemoveListener( self )

	if is_instance( entity, Agent ) then
		self:BroadcastEvent( LOCATION_EVENT.AGENT_REMOVED, entity )
	end
end

function Location:AddAgent( agent )
	assert( is_instance( agent, Agent ))
	self:AddEntity( agent )
end

function Location:RemoveAgent( agent )
	assert( is_instance( agent, Agent ))
	self:RemoveEntity( agent )
end

function Location:CollectVerbs( verbs, actor, obj )
	if verbs.id == "room" then
		for i, exit in ipairs( self.exits ) do
			verbs:AddVerb( Verb.LeaveLocation( actor, exit:GetDest( self )))
		end
	end
end

function Location:HasEntity( ent )
	for i, obj in ipairs( self.contents ) do
		if obj == ent then
			return true
		end
		if is_class( ent ) and is_instance( obj, ent ) then
			return true
		end
	end
	return false
end

function Location:OnEntityEvent( event_name, entity, ... )
	for i, obj in ipairs( self.contents ) do
		if entity ~= obj and obj.OnLocationEntityEvent then
			obj:OnLocationEntityEvent( event_name, entity, ... )
		end
	end
end


function Location:IsConnected( other )
	return table.find( self.exits, other ) ~= nil
end


function Location:Connect( other, exit )
	assert( other ~= nil )
	assert( is_instance( other, Location ))

	if exit == nil then
		local choices = {}
		for i, exit in ipairs( self.available_exits ) do
			if table.contains( other.available_exits, REXIT[ exit ] ) then
				table.insert( choices, exit )
			end
		end
		exit = table.arraypick( choices )
		assert( exit )
	end
	
	assert( IsEnum( exit, EXIT ))
	assert( self.exits[ exit ] == nil or error(exit))

	local rexit = REXIT[ exit ]
	assert( other.exits[ rexit ] == nil, tostr(other.exits) )

	self.exits[ exit ] = other
	table.arrayremove( self.available_exits, exit )

	other.exits[ rexit ] = self
	table.arrayremove( other.available_exits, rexit )

	if not self:IsSpawned() and other:IsSpawned() then
		self:Visit( SpawnLocation, other.world, self )
	elseif self:IsSpawned() and not other:IsSpawned() then
		other:Visit( SpawnLocation, self.world, self )
	end
end

function Location:CountAvailableExits()
	return #self.available_exits
end

function Location:Exits()
	return pairs( self.exits )
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

-- Depth-first traversal applying fn().
function Location:Visit( fn, ... )
	VisitInternal( {}, self, fn, ... )
end

-- Breadth-first traversal applying fn().
function Location:Flood( fn, ... )
	local open, closed = { self, 0 }, {}

	while #open > 0 do
		local x = table.remove( open, 1 )
		local depth = table.remove( open, 1 )

		table.insert( closed, open )
		if #closed > 999 then
			break
		end

		local continue, stop = fn( x, depth, ... )
		if stop then
			break
		elseif continue then
			for i, exit in ipairs( x.exits ) do
				local dest = exit:GetDest( x )
				if not table.contains( open, dest ) and not table.contains( closed, dest ) then
					table.insert( open, dest )
					table.insert( open, depth + 1 )
				end
			end
		end
	end

	assert_warning( #closed <= 99, "Floodings lots of rooms!", #closed )
end

function Location:SearchObject( fn, max_depth )
	local candidates = {}
	local open, closed = { self }, { [self] = 0 }
	local depth = 0

	max_depth = max_depth or math.huge

	while depth <= max_depth and #open > 0 do

		local x = table.remove( open )
		depth = closed[ x ]

		-- search contents
		if x.contents then
			for i, obj in ipairs( x.contents ) do
				if fn( obj ) then
					table.insert( candidates, obj )
				end
			end
		end

		if depth < max_depth then
			-- recurse
			for i, exit in ipairs( x.exits ) do
				local dest = exit:GetDest( x )
				if not table.contains( open, dest ) and not closed[ dest ] then
					table.insert( open, dest )
					closed[ dest ] = depth + 1
				end
			end
		end
	end

	return candidates
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

function Location:RenderMapTile( screen, x1, y1, x2, y2 )
	love.graphics.setColor( table.unpack( self.map_colour ))
	screen:Rectangle( x1 + 4, y1 + 4, x2 - x1 - 8, y2 - y1 - 8 )
end

function Location:__tostring()
	return self:GetTitle()
end


