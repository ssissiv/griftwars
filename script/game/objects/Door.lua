local Door = class( "Object.Door", Object )

Door.image = assets.TILE_IMG.DOOR

function Door:init( worldgen_tag )
	if worldgen_tag then
		self.portal = self:GainAspect( Aspect.Portal( WALK_TIME ) )
		self.portal:SetWorldGenTag( worldgen_tag )
	end
	self:Close()
end

function Door:GetName()
	local name
	if self.portal == nil or self.portal:GetDest() == nil then
		name = "Door"
	else
		name = loc.format( "Door to {1}", self.portal:GetDest() )
	end

	if self:IsClosed() then
		name = name .. " (Closed)"
	end
	if self:IsLocked() then
		name = name .. " (Locked)"
	end
	return name
end

function Door:Lock()
	local lock = self:GetAspect( Aspect.Lock ) or self:GainAspect( Aspect.Lock() )
	if lock then
		lock:Lock()
	end
	return self
end

function Door:Unlock()
	local lock = self:GetAspect( Aspect.Lock )
	if lock then
		lock:Unlock()
	end
end

function Door:IsLocked()
	local lock = self:GetAspect( Aspect.Lock )
	return lock and lock:IsLocked()	
end

function Door:Open()
	if self:IsClosed() and not self:IsLocked() then
		self:LoseAspect( self:GetAspect( Aspect.Impass ))
		self.image = assets.TILE_IMG.DOOR_OPEN
	end
	return self
end

function Door:Close()
	if not self:IsClosed() then
		self:GainAspect( Aspect.Impass( IMPASS.STATIC ) )
		self.image = nil
	end
	return self
end

function Door:IsClosed()
	return self:GetAspect( Aspect.Impass ) ~= nil
end

function Door:CollectVerbs( verbs, actor, target )
	if target == self then
		if self:IsClosed() then
			verbs:AddVerb( Verb.OpenObject( self ))
		else
			verbs:AddVerb( Verb.CloseObject( self ))
		end
	end
end

