local Creds = class( "Object.Creds", Object )

function Creds:GetName()
	return "Credits"
end

function Creds:__tostring()
	return string.format( "[%s: %d]", self:GetName(), self.value )
end