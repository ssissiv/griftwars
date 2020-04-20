local Impass = class( "Aspect.Impass", Aspect )

function Impass:IsPassable( obj )
	if self.wall then
		return false
	end
	if obj:GetAspect( Impass ) then
		return false -- could compare impass types
	end
	return true
end

function Impass:SetWall( wall )
	self.wall = wall
end
