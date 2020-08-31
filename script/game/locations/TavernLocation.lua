----------------------------------------------------------------------------------------------

local TavernLocation = class( "Location.Tavern", Location )

TavernLocation.WORLDGEN_TAGS = { "tavern exit" }

function TavernLocation:init()
	Location.init( self )
	local tavern = self:GainAspect( Feature.Tavern())

	self:GainAspect( Activity.PatronTavern() )
end


function TavernLocation:OnSpawn( world )
	Location.OnSpawn( self, world )

	local adj = world.adjectives:PickName()
	local noun = world.nouns:PickName()
	local name = loc.format( "The {1} {2} Tavern", adj, noun )
	self:SetDetails( name )

	Object.Door( "tavern exit" ):WarpToLocation( self, 6, 7 )

	local function IsPatronSpot( tile )
		return tile:IsPassable( IMPASS.DYNAMIC ) and
				tile:GetRegionID() == RGN_SERVING_AREA and
				self:GetWaypointByCoordinate( tile.x, tile.y ) == nil
	end

	-- Spawn some tables.
	for i = 1, 3 do
		local table = Object.WoodTable()
		table:WarpToLocationRegion( self, RGN_SERVING_AREA )
		assert( table:GetTile():GetRegionID() == RGN_SERVING_AREA )
		local neighbours = self.map:GetNeighbours( table:GetTile(), IsPatronSpot )
		local tile = world:ArrayPick( neighbours )
		if tile then
			self:AddWaypoint( Waypoint( self, tile.x, tile.y ):SetTag( WAYPOINT_PATRON ))
		end
	end

	local barkeep = self:GetAspect( Feature.Tavern ):SpawnBarkeep()
	-- local home = self:SpawnHome( barkeep )
end

function TavernLocation:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap())

		local cursor = self.map:CreateCursor( 0, 0 )
		cursor:FillTiles( 10, 8, function( x, y, w, h )
			if x == 1 or y == 1 or x == w or y == h then
				return Tile.StoneWall( x, y )
			else
				return Tile.WoodenFloor( x, y ):AssignRegionID( RGN_SERVING_AREA )
			end
		end )

		-- Hallway w/ rooms
		cursor:MoveTo( 2, 1 )
		cursor:SetTile( Tile.WoodenFloor ):Paint()
		cursor:Line( 0, -5 )
		-- Room West
		cursor:Line( -1, 0 ):SpawnEntity( Object.Door():Inscribe( "ROOM1" ):Close():Lock() ):Move( -5, 1 )
		cursor:Box( 5, -3 ):SpawnEntity( Object.Bed() ):Move( 5, -1 )

		-- Room East
		cursor:Line( 2, 0 ):SpawnEntity( Object.Door():Inscribe( "ROOM2" ):Close():Lock() ):Move( 1, 1 )
		cursor:Box( 5, -3 ):SpawnEntity( Object.Bed() ):Move( -1, -1 )

		self:AddWaypoint( Waypoint( self, 5, 2 ):SetTag( WAYPOINT.KEEPER ))
	end
end

