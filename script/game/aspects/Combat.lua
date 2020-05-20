local Combat = class( "Aspect.Combat", Aspect )

Combat.TABLE_KEY = "combat"

Combat.event_handlers =
{
	[ AGENT_EVENT.KILLED ] = function( self, event_name, agent, ... )
		agent:LoseAspect( self )
	end,
}

function Combat:init()
	self.targets = {}
end

function Combat:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	self:EvaluateTargets()
end

function Combat:OnLoseAspect()
	if self.owner.location then
		self.owner.location:RemoveListener( self )
	end
	self:ClearTargets()
	Combat._base.OnLoseAspect( self )
end

function Combat:CollectVerbs( verbs, actor, target )
	if self.owner == actor then --and self:IsTarget( target ) then
		verbs:AddVerb( Attack.Punch( nil, target ) )
	end
end

function Combat:OnLocationChanged( prev_location, location )
	if prev_location then
		prev_location:RemoveListener( self )
	end
	if location then
		location:ListenForAny( self, self.OnLocationEvent )
	end
	self:EvaluateTargets()
end

function Combat:GetCurrentAttack()
	return self.current_attack
end

function Combat:SetCurrentAttack( current_attack )
	self.current_attack = current_attack
end

function Combat:OnTargetEvent( event_name, target, ... )
	assert( self:IsTarget( target ))
	if event_name == AGENT_EVENT.KILLED then
		self:EvaluateTargets()
	end
end

function Combat:OnLocationEvent( event_name, location, ... )
	if event_name == LOCATION_EVENT.AGENT_ADDED then
		local agent = ...
		if not self:IsTarget( agent ) then
			local ok, reason = self:EvaluateTarget( agent )
			if ok then
				self:AddTarget( agent )
			end
		end
	elseif event_name == LOCATION_EVENT.AGENT_REMOVED then
		local agent = ...
		if self:IsTarget( agent ) then
			self:RemoveTarget( agent )
		end
	end
end

function Combat:IsTarget( target )
	return table.contains( self.targets, target )
end

function Combat:HasTargets()
	return #self.targets > 0
end

function Combat:EvaluateTarget( target )
	if target == self.owner then
		return false, "self"
	end
	if not is_instance( target, Agent ) then
		return false, "not agent"
	end
	if target:GetLocation() ~= self.owner:GetLocation() then
		return false, "not in location"
	end
	local combat = target:GetAspect( Aspect.Combat )
	if not combat then
		return false, "no combat"
	end
	if not combat:IsTarget( self.owner ) then
		-- TEMP. orcs attacksssss
		if not self.owner:IsEnemy( target ) then
			return false, "not enemy"
		end
	end
	return true
end

function Combat:EvaluateTargets()
	if self.owner.location then
		for i, obj in self.owner.location:Contents() do
			if not self:IsTarget( obj ) and self:EvaluateTarget( obj ) then
				self:AddTarget( obj )
			end
		end
	end

	for i, target in ipairs( self.targets ) do
		if not self:EvaluateTarget( target ) then
			self:RemoveTarget( target )
		end
	end
end

function Combat:AddTarget( target )
	assert( not table.contains( self.targets, target ))
	table.insert( self.targets, target )

	if #self.targets == 1 then
		Msg:Echo( target, loc.format( "{1.Id} charges you!", self.owner:LocTable( target )))
		Msg:Echo( self.owner, loc.format( "You charge {1.Id}!", target:LocTable( self.owner )))
	end

	if not self.attack then
		assert( not self.owner:HasAspect( Verb.HostileCombat ))
		self.attack = self.owner:GainAspect( Verb.HostileCombat( target ))
	end

	self.owner:RegenVerbs()
	self.owner:CancelInvalidVerbs()
	target:ListenForAny( self, self.OnTargetEvent )

	local combat = target:GetAspect( Aspect.Combat )
	if not combat:IsTarget( self.owner ) then
		combat:AddTarget( self.owner )
	end
end

function Combat:ClearTargets()
	while #self.targets > 0 do
		self:RemoveTarget( self.targets[ #self.targets ] )
	end
end

function Combat:RemoveTarget( target )
	assert( table.contains( self.targets, target ))
	table.arrayremove( self.targets, target )

	target:RemoveListener( self )

	if #self.targets == 0 and self.attack then
		self.owner:LoseAspect( self.attack )
		self.attack = nil
	end

	self.owner:RegenVerbs()
end

function Combat:PickTarget()
	return table.arraypick( self.targets )
end

function Combat:Targets()
	return ipairs( self.targets )
end

