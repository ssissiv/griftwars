
local ResidenceTileMap = class( "Aspect.ResidenceTileMap", Aspect.TileMap )

function ResidenceTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		if x == 1 or y == 1 or x == self.w or y == self.h then
			return Tile.StoneWall( x, y )
		else
			return Tile.WoodenFloor( x, y )
		end
	end )
end

-----------------------------------------------------------------------

local Residence = class( "Location.Residence", Location )

function Residence:init()
	Location.init( self )
	self:SetDetails( "Residence", "This is somebody's residence." )
	self:SetImage( assets.LOCATION_BGS.INSIDE )
	self:GainAspect( Aspect.ResidenceTileMap( 8, 8 ))

	self:GainAspect( Feature.Home() )

	Object.Bed():WarpToLocation( self )
end

function Residence:SetResident( resident )
	if resident then
		self:GetAspect( Feature.Home ):AddResident( resident )
	end
end
