local NamePool = class( "Aspect.NamePool", Aspect )

function NamePool:init( filename )
	assert( filename )
	self.names = LoadLinesFromFile( filename )
	self.filename = filename
end

function NamePool:GetID()
	return string.format( "%s(%s)", self._classname, self.filename )
end

function NamePool:PickName()
	if #self.names == 1 then
		print( "NO MORE NAMES", self.filename )
	end
	return self:GetWorld():ArrayPick( self.names )
end

function NamePool:ConsumeName()
	if #self.names == 1 then
		print( "NO MORE NAMES", self.filename )
	end
	local idx = self:GetWorld():Random( #self.names )
	return table.remove( self.names, idx )
end

function NamePool:AddName( name )
	table.insert( self.names, name )
end

-----------------------------------------------
--

local CityNamePool = class( "Aspect.CityNamePool", NamePool )
