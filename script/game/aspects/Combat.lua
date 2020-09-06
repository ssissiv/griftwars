local CombatPolicy = class( "Verb.CombatPolicy", Verb )

------------------------------------------------------

local Combat = class( "Verb.Combat", Verb )

Combat.TABLE_KEY = "combat"

Combat.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		agent:LoseAspect( self )
	end,
}

function Combat:init( actor )
	Verb.init( self, actor )
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
	if self.owner == actor and target ~= actor and is_instance( target, Agent ) and not target:IsDead() then --and self:IsTarget( target ) then
		verbs:AddVerb( Verb.MeleeAttack( actor, target ) )
	end
end

function Combat:CalculateUtility()
	return UTILITY.COMBAT
end

function Combat:CanInteract()
	if not self:HasTargets() then
		return false, "No targets"
	end

	return true
end

function Combat:FindCombatPolicy()
	local best_policy, best_utility
	for i, aspect in self.owner:Aspects() do
		if is_instance( aspect, Verb.CombatPolicy ) then
			local utility = aspect:CalculateUtility()
			if best_utility == nil or utility > best_utility then
				best_policy, best_utility = aspect, utility
			end
		end
	end
	return best_policy
end

function Combat:Interact()
	while true do
		local policy = self:FindCombatPolicy()
		if policy then
			self:DoChildVerb( policy )
		else
			self:YieldForTime( ONE_MINUTE ) -- ???
		end
	end
end

function Combat:OnLocationChanged( prev_location, location )
	if prev_location then
		prev_location:RemoveListener( self )
	end
	if location then
		location:ListenForAny( self, self.OnLocationEvent )
	end
	-- self.owner.behaviour:ScheduleNextTick( 0, "location_changed" )
end

function Combat:GetCurrentAttack()
	return self.current_attack
end

function Combat:SetCurrentAttack( current_attack )
	self.current_attack = current_attack
end

function Combat:GetTargetsByDistance()
	local function SortByDistance( e1, e2 )
		return EntityDistance( self.owner, e1 ) < EntityDistance( self.owner, e2 )
	end
	local targets = table.shallowcopy( self.targets )
	table.sort( targets, SortByDistance )
	return targets
end

function Combat:OnTargetEvent( event_name, target, ... )
	assert( self:IsTarget( target ))
	if event_name == AGENT_EVENT.DIED then
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

	elseif event_name == AGENT_EVENT.ATTACKED then
		local victim, attacker, attack = ...
		if victim ~= self.owner and not self:IsTarget( attacker ) and self.owner:CanSee( victim ) then
			self:OnNoticedAttack( victim, attacker, attack )
		end
	end
end

function Combat:OnNoticedAttack( victim, attacker, attack )
	if self.owner:IsAlly( victim ) and not self.owner:IsAlly( attacker ) then
		Msg:Speak( self.owner, "Banzaii!", victim:LocTable())

		if self.owner:CanSee( attacker ) then
			self.owner:GetMemory():AddEngram( Engram.HasAttacked( attacker ))
			self:AddTarget( attacker )
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
	local combat = target:GetAspect( Verb.Combat )
	if not combat then
		return false, "no combat"
	end
	local ok, reason = self.owner:CanSee( target )
	if not ok then
		return false, reason or "not visible"
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
		Msg:EchoTo( target, loc.format( "{1.Id} charges you!", self.owner:LocTable( target )))
		-- Msg:EchoTo( self.owner, loc.format( "You charge {1.Id}!", target:LocTable( self.owner )))
		self.owner:BroadcastEvent( ENTITY_EVENT.COMBAT_STARTED, self )
	end

	self.owner:RegenVerbs()
	self.owner:CancelInvalidVerbs()
	self.owner.behaviour:ScheduleNextTick( 0, "new combat target" )
	
	target:ListenForAny( self, self.OnTargetEvent )

	local combat = target:GetAspect( Verb.Combat )
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

	if #self.targets == 0 then
		self.owner:BroadcastEvent( ENTITY_EVENT.COMBAT_ENDED, self )
	end

	self.owner:RegenVerbs()
	self.owner:CancelInvalidVerbs()
end

function Combat:PickTarget()
	return table.arraypick( self.targets )
end

function Combat:Targets()
	return ipairs( self.targets )
end

function Combat:RenderAgentDetails( ui, screen, viewer )
	local atk, details = self.owner:CalculateAttackPower()
	local wpn = self.owner:GetInventory():AccessSlot( EQ_SLOT.WEAPON )

	ui.Text( "Attack Power:" )
	ui.SameLine( 0, 5 )
	ui.TextColored( 0, 1, 1, 1, tostring(atk) )
	if ui.IsItemHovered() and details then
		ui.SetTooltip( details )
	end
	ui.SameLine( 0, 10 )
	ui.Text( loc.format( "({1})", wpn and wpn:GetName( viewer ) or "Unarmed" ))

	ui.Text( "AC:" )
	ui.SameLine( 0, 10 )
	ui.TextColored( 0, 1, 1, 1, "0" )
end

