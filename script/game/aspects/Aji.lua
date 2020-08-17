local Aji = class( "Aspect.Aji", Aspect )

function Aji:init( source )
	self.source = source
end

function Aji:RenderMapTile( screen, self, x1, y1, x2, y2 )
	-- screen:SetColour( 0xFF00FFFF )
	-- screen:Rectangle( x1 + 3, y1 + 3, 6, 6 )
	screen:SetColour( 0xFF0000AA )
	screen:Rectangle( x1 + 2, y1 + 2, x2 - x1 - 4, y2 - y1 - 4 )
end

function Aji:TallyUp()
	self.tally = (self.tally or 0) + 1
end

function Aji:TallyDown()
	self.tally = self.tally - 1
	if self.tally <= 0 then
		self.owner:LoseAspect( self )
	end
end

