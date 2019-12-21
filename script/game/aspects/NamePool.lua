local NamePool = class( "Aspect.NamePool", Aspect )

function NamePool:init()
	self.names = LoadLinesFromFile( "data/names.txt" )
end

function NamePool:PickName()
	return table.remove( self.names, math.random( #self.names ))
end

