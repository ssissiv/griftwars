local NamePool = class( "Aspect.NamePool", Aspect )

function NamePool:init( filename )
	assert( filename )
	self.names = LoadLinesFromFile( filename )
	self.filename = filename
end

function NamePool:PickName()
	if #self.names == 1 then
		print( "NO MORE NAMES", self.filename )
	end
	return table.remove( self.names, math.random( #self.names ))
end

function NamePool:AddName( name )
	table.insert( self.names, name )
end

-----------------------------------------------
--

local CityNamePool = class( "Aspect.CityNamePool", NamePool )
