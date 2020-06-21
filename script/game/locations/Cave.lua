
-----------------------------------------------------------------------

local Cave = class( "Location.Cave", Location )

Cave.WORLDGEN_TAGS = { "cave exit" }

function Cave:init( ...)
	Location.init( self, ... )
	self:SetDetails( "Cave", "A dark cave." )

	self:GainAspect( Feature.Home() )

	Portal.CaveEntrance( "cave exit"):WarpToLocation( self )
end

function Cave:OnSpawn( world )
	Location.OnSpawn( self, world )
	
	local chest = Object.Chest()
	chest:WarpToLocation( self )
	chest:SpawnLoot( LOOT_JUNK_T3 )

	world:ListenForEvent( CALC_EVENT.COLLECT_INTEL, self, self.OnCollectIntel )
end

function Cave:OnCollectIntel( event_name, world, acc )
	local exit = self:FindPortalWithTag( "exit" )
	acc:AppendValue( Engram.Discovered( exit:GetDest() ))
end

function Cave:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			return Tile.DirtFloor( x, y )
		end )
	end
end
