local Impass = class( "Aspect.Impass", Aspect )

function Impass:init( pass_type )
	assert( pass_type )
	self.pass_type = pass_type
end

function Impass:IsPassable( what )
	if is_instance( what, Entity ) then
		local impass = what:GetAspect( Impass )
		if impass and bit.band( self.pass_type, impass.pass_type ) ~= 0 then
			return false -- could compare impass types
		end

	elseif type(what) == "number" then
		if bit.band( self.pass_type, what ) ~= 0 then
			return false
		end
	end
	return true
end

function Impass:SetWall( wall )
	self.wall = wall
end
