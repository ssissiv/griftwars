local Thicket = class( "Location.Thicket", Location )

Thicket.WORLDGEN_TAGS = { "outskirts east", "outskirts west", "outskirts south", "outskirts north" }

function Thicket:init( zone, portal )
	Location.init( self )
	self:SetDetails( loc.format( "Thicket", zone.name), "Trees everywhere!")
	self.gen_portal = portal
end

function Thicket:OnSpawn( world )
	Location.OnSpawn( self, world )

	local w, h = self.map:GetExtents()

	local districts = table.shuffle{ "east", "west", "north", "south" }
	local n = math.random( 1, 4 )
	for i = 1, 4 do
		local tag = districts[i]
		local portal
		if self.gen_portal and self.gen_portal:MatchWorldGenTag( "outskirts "..tag ) then
			portal = Object.Portal( "outskirts "..tag )
		elseif i <= n then
			portal = Object.Portal( "forest "..tag )
		end

		if portal then
			if tag == "east" then
				portal:WarpToLocation( self, w, math.floor(h/2) )
			elseif tag == "west" then
				portal:WarpToLocation( self, 1, math.floor(h/2) )
			elseif tag == "south" then
				portal:WarpToLocation( self, math.floor(w/2), h )
			elseif tag == "north" then
				portal:WarpToLocation( self, math.floor(w/2), 1 )
			end
		end
	end
end


function Thicket:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			if math.random() < 0.2 then
				return Tile.Tree( x, y )
			else
				return Tile.Grass( x, y )
			end
		end )
	end
end

