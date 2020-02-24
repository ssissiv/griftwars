local TileMap = class( "Aspect.TileMap", Aspect )

function TileMap:init()
	self.grid = {} -- array of arrays.
end

function TileMap:AssignToGrid( location )
	local x, y = location:GetCoordinate()

	local row = self.grid[ y ]
	if row == nil then
		row = {}
		self.grid[ y ] = row
	end

	if row[ x ] == nil then
		row[ x ] = location
	elseif is_instance( row[ x ], Location ) then
		row[ x ] = { row[ x ], location }
	else
		table.insert( row[ x ], location )
	end
end

function TileMap:UnassignFromGrid( location )
	local x, y = location:GetCoordinate()
	local t = self.row[ y ][ x ]
	if t == location then
		self.row[ y ][ x ] = nil
	elseif t then
		table.arrayremove( t, location )
		if #t == 1 then
			self.row[ y ][ x ] = t[ 1 ]
		elseif #t == 0 then
			self.row[ y ][ x ] = nil
		end
	else
		error( location )
	end
end

function TileMap:LookupGrid( x, y )
	local row = self.grid[ y ]
	if row then
		local t = row [ x ]
		if is_instance( t, Location ) then
			return t
		elseif t then
			return t[1]
		end
	end
end

