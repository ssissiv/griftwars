local Door = class( "Object.Door", Object )

Door.image = assets.TILE_IMG.DOOR

function Door:init( worldgen_tag )
	if worldgen_tag then
		self.portal = self:GainAspect( Aspect.Portal( WALK_TIME ) )
		self.portal:SetWorldGenTag( worldgen_tag )
	end
	self:Close()
end

function Door:OnConnected( ent )
	if self:IsClosed() and ent.Close then
		ent:Close()
	end
	if self:IsLocked() and ent.Lock then
		ent:Lock()
	end
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

		local ent = self.portal and self.portal:GetDestEntity()
		if ent and ent.Lock then
			ent:Lock()
		end
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

		local ent = self.portal and self.portal:GetDestEntity()
		if ent and ent.Open then
			ent:Open()
		end
	end
	return self
end

function Door:Close()
	if not self:IsClosed() then
		self:GainAspect( Aspect.Impass( IMPASS.STATIC ) )
		self.image = nil

		local ent = self.portal and self.portal:GetDestEntity()
		if ent and ent.Close then
			ent:Close()
		end
	end
	return self
end

function Door:IsClosed()
	return self:GetAspect( Aspect.Impass ) ~= nil
end

function Door:CanUsePortal( actor )
	-- TODO: see if actor can unlock it
	return not self:IsLocked(), "Locked"
end

function Door:OnActivatePortal( portal, verb )
	if self:IsLocked() then
		return true
	end

	local was_closed = self:IsClosed()
	if was_closed then
		if not verb:DoChildVerb( Verb.OpenObject( self ), self ) then
			return true
		end
	end

	verb:YieldForTime( portal.travel_time )

	if verb:IsCancelled() then
		return true
	end		

	portal:WarpToDest( verb.actor )

	if was_closed then
		-- Free close?
		self:Close()
	end

	return true
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

