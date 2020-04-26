local Portal = class( "Object.Portal", Object )

Portal.MAP_CHAR = "^"

function Portal:init( worldgen_tag )
	self.portal = self:GainAspect( Aspect.Portal() )
	self.portal:SetWorldGenTag( worldgen_tag )
end

function Portal:GetName()
	if self.portal == nil or self.portal:GetDest() == nil then
		return "Portal to nowhere!"
	else
		return loc.format( "Portal to {1}", self.portal:GetDest() )
	end
end
