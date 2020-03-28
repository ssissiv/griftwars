local Portal = class( "Aspect.Portal", Aspect )

function Portal:init( location, x, y )
	self.location, self.x, self.y = location, x, y
end

function Portal:GetDest()
	return self.location, self.x, self.y
end
