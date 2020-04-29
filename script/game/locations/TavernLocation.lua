----------------------------------------------------------------------------------------------

local TavernLocation = class( "Location.Tavern", Location )

TavernLocation.WORLDGEN_TAGS = { "tavern exit" }

function TavernLocation:init()
	Location.init( self )
	local shop = self:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
	local tavern = self:GainAspect( Feature.Tavern())
end


function TavernLocation:OnSpawn( world )
	Location.OnSpawn( self, world )

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
		self:SetWaypoint( WAYPOINT.KEEPER, Waypoint( self, 5, 2 ))
	end
end

