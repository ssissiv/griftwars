local Door = class( "Object.Door", Object )

Door.image = assets.TILE_IMG.DOOR

function Door:init( worldgen_tag )
	self.portal = self:GainAspect( Aspect.Portal() )
	self.portal:SetWorldGenTag( worldgen_tag )
end

function Door:Connect( dest )
	local portal = self:GetAspect( Aspect.Portal )
	if portal == nil then
		portal = self:GainAspect( Aspect.Portal() )
	end

	portal:Connect( dest )
	self.portal = portal
end

function Door:GetName()
	if self.portal == nil or self.portal.location == nil then
		return "Door to nowhere!"
	else
		return loc.format( "Door to {1}", self.portal.location )
	end
end

function Door:Open()
	self:LoseAspect( self:GetAspect( Aspect.Impass ))
end

function Door:Close()
	self:GainAspect( Aspect.Impass() )
end
