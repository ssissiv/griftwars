local Portal = class( "Object.Portal", Object )

function Portal:init( worldgen_tag )
	self.portal = self:GainAspect( Aspect.Portal() )
	self.portal:SetWorldGenTag( worldgen_tag )
end

function Portal:GetShortDesc( viewer )
	return nil
end

function Portal:GetDest()
	return self.portal:GetDest()
end

function Portal:GetMapChar()
	if self.portal:GetDest() then
		return "^"
	else
		return "^", constants.colours.BLACK
	end
end

function Portal:GetName()
	if self.portal == nil or self.portal:GetDest() == nil then
		return "Portal to nowhere!"
	else
		return loc.format( "Portal to {1}", self.portal:GetDest() )
	end
end
