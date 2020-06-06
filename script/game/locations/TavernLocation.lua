----------------------------------------------------------------------------------------------

local TavernLocation = class( "Location.Tavern", Location )

TavernLocation.WORLDGEN_TAGS = { "tavern exit" }

function TavernLocation:init()
	Location.init( self )
	local tavern = self:GainAspect( Feature.Tavern())
end


function TavernLocation:OnSpawn( world )
	Location.OnSpawn( self, world )

	local adj = world.adjectives:PickName()
	local noun = world.nouns:PickName()
	local name = loc.format( "The {1} {2} Tavern", adj, noun )
	self:SetDetails( name )

	Object.Door( "tavern exit" ):WarpToLocation( self )
	local barkeep = self:GetAspect( Feature.Tavern ):SpawnBarkeep()
	-- local home = self:SpawnHome( barkeep )
end

function TavernLocation:GenerateTileMap()
	if self.map == nil then
		local w, h = 10, 8
		self.map = self:GainAspect( Aspect.TileMap( w, h ))
		self.map:FillTiles( function( x, y )
			if x == 1 or y == 1 or x == w or y == h then
				return Tile.StoneWall( x, y )
			else
				return Tile.WoodenFloor( x, y )
			end
		end )

		-- Hallway w/ rooms
		local cursor = self.map:CreateCursor( 2, 1 )
		cursor:SetTile( Tile.WoodenFloor ):Paint()
		cursor:Line( 0, -5 )
		-- Room West
		cursor:Line( -1, 0 ):SpawnEntity( Object.Door():Inscribe( "ROOM1" ):Close():Lock() ):Move( -5, 1 )
		cursor:Box( 5, -3 ):SpawnEntity( Object.Bed() ):Move( 5, -1 )

		-- Room East
		cursor:Line( 2, 0 ):SpawnEntity( Object.Door():Inscribe( "ROOM2" ):Close():Lock() ):Move( 1, 1 )
		cursor:Box( 5, -3 ):SpawnEntity( Object.Bed() ):Move( -1, -1 )

		self:SetWaypoint( WAYPOINT.KEEPER, Waypoint( self, 5, 2 ))
	end
end

