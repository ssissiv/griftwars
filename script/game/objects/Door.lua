local Door = class( "Object.Door", Object )

Door.image = assets.TILE_IMG.DOOR

function Door:init( worldgen_tag )
	self.portal = self:GainAspect( Aspect.Portal() )
	self.portal:SetWorldGenTag( worldgen_tag )
end

function Door:GetName()
	if self.portal == nil or self.portal:GetDest() == nil then
		return "Door to nowhere!"
	else
		return loc.format( "Door to {1}", self.portal:GetDest() )
	end
end

function Door:Open()
	self:LoseAspect( self:GetAspect( Aspect.Impass ))
end

function Door:Close()
	self:GainAspect( Aspect.Impass() )
end
