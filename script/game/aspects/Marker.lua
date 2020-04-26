MARK = MakeEnum
{
	"SHOPKEEP",
}

local Marker = class( "Aspect.Marker", Aspect )

function Marker:init( mark )
	self.mark = mark
end

function Marker:SetMark( mark )
	assert( IsEnum( mark, MARK ))
	self.mark = mark
end

function Marker:GetMark()
	return self.mark
end

function Marker:RenderMapTile( screen, self, x1, y1, x2, y2 )
	screen:SetColour( 0xFF00FFFF )
	screen:Rectangle( x1 + 3, y1 + 3, 6, 6 )
end

function Marker:__tostring()
	return string.format( "%s(%s)", self._classname, tostring(self.mark))
end
