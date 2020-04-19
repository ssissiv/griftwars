local Door = class( "Object.Door", Object )

Door.image = assets.TILE_IMG.DOOR

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


function Door:CollectVerbs( verbs, agent )
	-- if agent:GetTile() == self:GetTile() then
	if self.portal then
		verbs:AddVerb( Verb.LeaveLocation( self.portal ))
	end
	-- end
end

function Door:RenderMapTile( screen, tile, x1, y1, x2, y2 )
	local sx, sy = (x2 - x1) / self.image:getWidth(), (y2 - y1) / self.image:getHeight()
	love.graphics.setColor( 255, 255, 255, 255 )
	screen:Image( self.image, x1, y1, sx, sy )
end
