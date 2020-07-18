local OpenHills = class( "Location.OpenHills", Location )

OpenHills.WORLDGEN_TAGS = { "boundary east", "boundary west", "boundary south", "boundary north",
	"hills east", "hills west", "hills south", "hills north", }

function OpenHills:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SetDetails( "Open Hills", "Rolling hills. Travel is inconsistent.")
	self:SpawnPerimeterPortals( "hills" )

	-- These could be different Locations, but there is some overhead in managing multiple
	-- Locations atm so this is more convenient.
	local feature = world:Random()
	if feature < 0.1 then
		Portal.CaveEntrance( "cave entry" ):WarpToLocation( self )
	elseif feature < 0.05 then
		Portal.AbandonedWell():WarpToLocation( self )
	end
end

function OpenHills:GenerateTileMap()
	if self.map == nil then
		local w, h = 12, 12
		self.map = self:GainAspect( Aspect.TileMap( w, h ))
		self.map:FillTiles( function( x, y )
			if self.world:Random() < 0.05 then
				return Tile.Tree( x, y )
			else
				return Tile.Grass( x, y )
			end
		end )

		for i = 3, 10 do
			local x, y = self.world:Random( w ), self.world:Random( h )
			if self.map:LookupTile( x, y ):IsEmpty() then
				Object.Boulder():WarpToLocation( self, x, y )
			end
		end
	end
end


