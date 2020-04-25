local Portal = class( "Object.Portal", Object )

Portal.MAP_CHAR = "^"

function Portal:init( worldgen_tag )
	self.portal = self:GainAspect( Aspect.Portal() )
	self.portal:SetWorldGenTag( worldgen_tag )
end

function Portal:Connect( dest )
	local portal = self:GetAspect( Aspect.Portal )
	if portal == nil then
		portal = self:GainAspect( Aspect.Portal() )
	end

	portal:Connect( dest )
	self.portal = portal
end

function Portal:GetName()
	if self.portal == nil or self.portal.location == nil then
		return "Portal to nowhere!"
	else
		return loc.format( "Portal to {1}", self.portal.location )
	end
end
