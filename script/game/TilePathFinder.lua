
--------------------------------------------------------------------
-- Tile-based path-find through a TileMap.

local TilePathFinder = class( "TilePathFinder" )

function TilePathFinder:init( actor, source, target, approach_dist )
	assert( actor.location, tostring(actor) )
	self.map = actor.location.map
	assert( is_instance( self.map, Aspect.TileMap ), tostring(actor.location))
	self.actor = actor
	self.history = actor:GetAspect( Aspect.History )
	self.source = source
	self.target = target
	self.approach_dist = approach_dist
	self.query_count = 0
end

function TilePathFinder:GetApproachDist()
	if self.approach_dist then
		return self.approach_dist
	end

	local end_impass = self.target.GetAspect and self.target:GetAspect( Aspect.Impass )
	if end_impass and not end_impass:IsPassable( self.source ) then
		-- If the end point is not passable, we approach within 1 tile.
		return 1
	end

	return 0
end

function TilePathFinder:CreateAStar()
	if self.astar then
		return self.astar
	end

	local function DistFn( t1, t2 )
		return distance( t1.x, t1.y, t2.x, t2.y )
	end

	local function HeuristicFn( t1, end_tile )
		local dx = end_tile.x - t1.x
		local dy = end_tile.y - t1.y
		return math.sqrt( dx * dx + dy * dy )
	end

	local neighbours = {}
	local function NeighbourFn( tile )
		table.clear( neighbours )
		local end_room = self:GetEndRoom()
		for i, dest in self.map:Neighbours( tile ) do
			if self.actor == nil or dest:IsConditionallyPassable( self.actor ) then
				table.insert( neighbours, dest )
			elseif dest == end_room then
				-- A tile occupied by a hostile agent is not passable but we still need to path to it.
				table.insert( neighbours, dest )
			end
		end	
		return ipairs( neighbours )
	end

	self.astar = AStarSearcher( DistFn, HeuristicFn, NeighbourFn )
	return self.astar
end

function TilePathFinder:RasterLine( start_room, end_room, plot )
	local x0, y0 = start_room:GetCoordinate()
	local x1, y1 = end_room:GetCoordinate()
    local dx = math.abs( x1 - x0 )
   	local sx = x0 < x1 and 1 or -1
	local dy = -math.abs( y1 - y0 )
    local sy = y0 < y1 and 1 or -1
    local err = dx + dy
    local path = {}
    while true do
		local tile = self.map:LookupTile( x0, y0 )
		if not tile or not tile:IsConditionallyPassable( self.actor ) then
			return
		else
			table.insert( path, tile )
		end

		if x0 == x1 and y0 == y1 then
			break
		end

        local e2 = 2*err
        if e2 >= dy then
            err = err + dy
            x0 = x0 + sx
		end
        if e2 <= dx then
        	err = err + dx
        	y0 = y0 + sy
        end
    end

    return path
end

-- Generate a path from start_room -> end_room.
-- returns nil if no path can be found (or end_room == start_room),
-- or an array of rooms leading from [start_room, end_room], inclusive.
function TilePathFinder:CalculatePath()
	local start_room = self:GetStartRoom()
	local end_room = self:GetEndRoom()
	assert( start_room )

	if end_room == nil then
		-- An extant target may have left the current location.
		return
	end

	if self:AtGoal() then
		return
	end

	self.start_room, self.end_room = start_room, end_room

	local path = self:RasterLine( start_room, end_room )
	if path then
		self.path = path
		self.rastered = true
	else
		self.rastered = nil
		local astar = self:CreateAStar()
		self.astar.no_clear = (self.history ~= nil)
		self.astar:StartSearch( start_room, end_room )
		self.astar:RunToCompletion()
		if self.astar:FoundPath() then
			self.path = self.astar:GetPath()
		else
			self.path = nil
		end
	end

	if self.path then
		for i = 1, self:GetApproachDist() do
			table.remove( self.path )
		end
	end

	if self.history then
		DBG( self )
	end

	return self.path
end

function TilePathFinder:ResetPath()
	self.path = nil
end

function TilePathFinder:GetPath()
	if self.path == nil then
		self.path = self:CalculatePath()

	elseif self.end_room ~= self:GetEndRoom() then
		-- Target moved, just recalc.
		-- if the target is still on the path, we could reuse it, but then we need to maintain the full path and
		-- handle approach dist one level up.
		self.path = self:CalculatePath()
	else
		local idx = table.find( self.path, self:GetStartRoom() )
		if idx then
			for i = idx - 1, 1, -1 do
				table.remove( self.path, i )
			end
		else
			-- NO LONGER ON PATH!
			self.path = self:CalculatePath()
		end
	end

	return self.path
end

function TilePathFinder:AtGoal()
	local start_room = self:GetStartRoom()
	local end_room = self:GetEndRoom()

	if self.path and #self.path == 1 then
		-- If the generated path only has our tile, then we are where we want to be.
		-- Note that this doesn't imply start_room == end_room in general, if approach dist > 0.
		return true

	elseif self:GetApproachDist() == 0 then
		return start_room == end_room

	else
		-- Technically, we don't know until we do a pathfind.
		-- self:CalculatePath()
		-- return self.path and #self.path == 1
		return false
	end
end

function TilePathFinder:GetStartRoom()
	if is_instance( self.source, Agent ) then
		return self.source:GetTile()
	else
		assert( is_instance( self.source, Tile ))
		return self.source
	end
end


function TilePathFinder:GetEndRoom()
	if is_instance( self.target, Tile ) then
		return self.target
	else
		local x, y = AccessCoordinate( self.target )
		return self.map:LookupTile( x, y )
	end
end

function TilePathFinder:RenderDebugPanel( ui, panel )
	ui.Text( "Source:" )
	ui.SameLine( 0, 5 )
	panel:AppendTable( ui, self.source )
	ui.SameLine( 0, 10 )
	panel:AppendTable( ui, self:GetStartRoom() )

	ui.Text( "Target:" )
	ui.SameLine( 0, 5 )
	panel:AppendTable( ui, self.target )
	ui.SameLine( 0, 10 )
	panel:AppendTable( ui, self:GetEndRoom() )

	ui.Separator()

	ui.Text( loc.format( "Queries: {1}", self.query_count ))
	ui.Text( loc.format( "Path: {1}", self.path and #self.path ))

	local game = GetGUI():FindScreen( GameScreen )
	if game and self.start_room then
		local x0, y0 = self.start_room:GetCoordinate()
		local xt, yt = self.end_room:GetCoordinate()
		local max_dist = distance( x0, y0, xt, yt )

		if self.astar.open_set then
			for tile in pairs( self.astar.open_set ) do
				local x1, y1 = game.camera:WorldToScreen( tile.x, tile.y )
				local x2, y2 = game.camera:WorldToScreen( tile.x + 1, tile.y + 1 )
				game:SetColour( 0xFFFFFFAA )
				game:Box( x1 + 4, y1 + 4, (x2 - x1) - 8, (y2 - y1) - 8 )
			end
		end

		if self.astar.closed_set then
			for tile in pairs( self.astar.closed_set ) do
				local x1, y1 = game.camera:WorldToScreen( tile.x, tile.y )
				local x2, y2 = game.camera:WorldToScreen( tile.x + 1, tile.y + 1 )
				local dist = distance( tile.x, tile.y, self.astar.start_node:GetCoordinate() )
				local r, g, b, a = 0.8, 0, 0, clamp( dist / max_dist, 0, 1.0 )
				game:SetColour( MakeHexColour( r, g, b, a ) )
				game:Rectangle( x1 + 6, y1 + 6, (x2 - x1) - 12, (y2 - y1) - 12 )
			end
		end

		if self.path then
			for i, tile in ipairs( self.path ) do
				local x1, y1 = game.camera:WorldToScreen( tile.x, tile.y )
				local x2, y2 = game.camera:WorldToScreen( tile.x + 1, tile.y + 1 )
				local dist = distance( tile.x, tile.y, self.start_room:GetCoordinate() )
				local r, g, b, a = 1, 1, 0, clamp( dist / max_dist, 0, 1.0 )
				game:SetColour( MakeHexColour( r, g, b, a ) )
				game:Box( x1 + 4, y1 + 4, (x2 - x1) - 8, (y2 - y1) - 8 )
			end
		end
	end
end
