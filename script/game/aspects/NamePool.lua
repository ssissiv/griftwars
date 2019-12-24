local NamePool = class( "Aspect.NamePool", Aspect )

function NamePool:init( filename )
	assert( filename )
	self.names = LoadLinesFromFile( filename )
end

function NamePool:PickName()
	return table.remove( self.names, math.random( #self.names ))
end

