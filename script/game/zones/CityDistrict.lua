local District = class( "Location.CityDistrict", Location )

function District:init( zone, portal )
	Location.init( self )
	self:SetDetails( loc.format( "District of {1}{2}", zone.name, math.random(1,9999)), "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	self.gen_portal = portal
end

function District:OnSpawn( world )
	Location.OnSpawn( self, world )

	local w, h = self.map:GetExtents()

	local districts = table.shuffle{ "east", "west", "north", "south" }
	local n = math.random( 1, 4 )
	local m = math.random( 0, 4 - n )
	for i = 1, 4 do
		local tag = districts[i]
		local portal
		if self.gen_portal and self.gen_portal:MatchWorldGenTag( "district "..tag ) then
			portal = Object.Portal( "district "..tag )
		elseif i <= n then
			portal = Object.Portal( "district "..tag )
		elseif i <= n + m then
			portal = Object.Portal( "outskirts "..tag )
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

	if math.random() < 0.5 then
		local scavenger = world:SpawnAgent( Agent.Scavenger(), self )
	end

	if math.random() < 0.2 then
		local snoop = world:SpawnAgent( Agent.Snoop(), self )
	end
end

function District:SpawnDoor( tags )
	local door = Object.Door( tags )
	local w, h = self.map:GetExtents()
	local tile = self:FindPassableTile( math.random( 2, w - 1 ), math.random( 2, h - 1 ), door )
	door:WarpToLocation( self, tile:GetCoordinate() )
end

function District:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( math.random( 6, 12 ), math.random( 6, 12 ) ))
		self.map:FillTiles( function( x, y )
			return Tile.StoneFloor( x, y )
		end )
	end
end

---------------------------------------------------

local District1 = class( "Location.CityDistrict1", District )

District1.WORLDGEN_TAGS = { "district west", "district east", "district north", "district south", "shop entry", "tavern entry" }

function District1:OnSpawn( world )
	District.OnSpawn( self, world )

	self:SpawnDoor( "shop entry" )
	self:SpawnDoor( "shop entry" )
	self:SpawnDoor( "tavern entry" )
end

---------------------------------------------------

local District2 = class( "Location.CityDistrict2", District )

District2.WORLDGEN_TAGS = { "district west", "district east", "district north", "district south", "residence entry" }

function District2:OnSpawn( world )
	District.OnSpawn( self, world )

	self:SpawnDoor( "residence entry" )
	self:SpawnDoor( "residence entry" )
end
