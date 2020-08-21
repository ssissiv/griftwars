local OpenHills = class( "Location.OpenHills", Location )

OpenHills.WORLDGEN_TAGS = { "boundary east", "boundary west", "boundary south", "boundary north",
	"hills east", "hills west", "hills south", "hills north", }

function OpenHills:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SetDetails( "Open Hills", "Rolling hills. Travel is inconsistent.")
	assert( self.map )
	self:SpawnPerimeterPortals( "hills" )

end

function OpenHills:GenerateOpenMap()
	self.map:FillTiles( 12, 12, function( x, y )
		if self.world:Random() < 0.05 then
			return Tile.Tree( x, y )
		else
			return Tile.Grass( x, y )
		end
	end )
end

function OpenHills:GenerateHillGiant()
	for i = 3, 10 do
		local x, y = self.world:Random( 12 ), self.world:Random( 12 )
		if self.map:LookupTile( x, y ):IsEmpty() then
			Object.Boulder():WarpToLocation( self, x, y )
		end
	end

	local giant = Agent.HillGiant()
	giant:WarpToLocation( self )
end


function OpenHills:GenerateGnolls()
	local curs = self.map:CreateCursor( 0, 0 )
	curs:SetTile( Tile.Grass )

	curs:Box( self.world:Random( 2, 4 ), self.world:Random( 2, 4 ))

	local home = self:GainAspect( Feature.Home() )
	for i = 4, 8 do
		local dx, dy = math.random( 6, 10 ) * (math.random( 3 ) - 2), math.random( 6, 10 ) * (math.random( 3 ) - 2)
		curs:ThickLine( 3, dx, dy )

		curs:SpawnEntity( Object.Bed() )

		local gnoll = Agent.Gnoll()
		gnoll:WarpToLocation( self, curs:GetCoordinate() )
		home:AddResident( gnoll )
	end
end

function OpenHills:GenerateTileMap( world )
	assert( self.map == nil )
	self.map = self:GainAspect( Aspect.TileMap())

	local n = world:Random( 1, 6 )
	if n == 1 then
		self:GenerateGnolls()
	elseif n == 2 then
		self:GenerateOpenMap()
		self:GenerateHillGiant()
	else
		self:GenerateOpenMap()
	end

	-- These could be different Locations, but there is some overhead in managing multiple
	-- Locations atm so this is more convenient.
	local feature = world:Random()
	if feature < 0.1 then
		Portal.CaveEntrance( "cave entry" ):WarpToLocation( self )
	elseif feature < 0.05 then
		Portal.AbandonedWell():WarpToLocation( self )
	end
end


