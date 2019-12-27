local Creds = class( "Object.Creds", Object )

function Creds:GetName()
	return loc.format( "{1} {1:Credit|Credits}", self.value )
end

function Creds:__tostring()
	return string.format( "[%s: %d]", self:GetName(), self.value )
end