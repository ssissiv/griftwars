function Agent:IsEnemy( other )
	if self:HasFlag( EF.AGGRO_NONE ) then
		return false
	end
	if self:HasFlag( EF.AGGRO_ALL ) then
		return true
	end
	if self:HasFlag( EF.AGGRO_OTHER_CLASS ) and not is_instance( other, self._class ) then
		return true
	end

	local function HasAttacked( engram )
		if is_instance( engram, Engram.HasAttacked ) then
			return engram.agent == other
		end
	end
	-- they attacked us!
	if self:GetMemory():HasEngram( HasAttacked ) then
		return true
	end

	local f1 = self:GetAspect( Aspect.FactionMember )
	local f2 = other:GetAspect( Aspect.FactionMember )
	if self:HasFlag( EF.AGGRO_OTHER_FACTION ) then
		if (f1 and f1.faction) ~= (f2 and f2.faction) then
			return true
		end
	end

	return f1 and f2 and f1:IsEnemy( f2 )
end

function Agent:IsAlly( other )
	if self:HasFlag( EF.AGGRO_OTHER_CLASS ) and is_instance( other, self._class ) then
		return true
	end

	local f1 = self:GetAspect( Aspect.FactionMember )
	local f2 = other:GetAspect( Aspect.FactionMember )
	return f1 and f2 and f1:IsAlly( f2 )
end

function Agent:GetWeapon()
    return self.inventory:AccessSlot( EQ_SLOT.WEAPON )
end

function Agent:CalculateAttackPower()
	self.acc:InitializeValue( 0 )

	local wpn = self:GetWeapon()
	if wpn and wpn.attack_power then
		self.acc:AddValue( wpn.attack_power, wpn )
	end
	return self.acc:CalculateValueFromSources( CALC_EVENT.ATTACK_POWER )
end

function Agent:CalculateStat( stat )
	return self.acc:CalculateValue( CALC_EVENT.STAT, self:GetStatValue( stat ), stat )
end

function Agent:CalculateDC( value, verb )
	return self.acc:CalculateValue( CALC_EVENT.DC, value, verb )
end

function Agent:CanSee( obj )
	if obj.location ~= self.location then
		return false
	end

	if is_instance( obj, Object.Portal ) and obj:GetDest() == nil then
		return false
	end

	if not obj:GetCoordinate() or not self:GetCoordinate() then
		return false
	end

	return true
end

function Agent:CanLearnSkill( skill )
	assert( is_class( skill ))
	local owned_skill = self:GetAspect( skill )
	if owned_skill then
		return owned_skill:CanLearn( self )
	else
		return skill.CanLearn( nil, self )
	end
end

function Agent:InCombat()
	local combat = self:GetAspect( Aspect.Combat )
	return combat and combat:HasTargets()
end

function Agent:InCombatWith( target )
	local combat = self:GetAspect( Aspect.Combat )
	return combat and combat:IsTarget( target )
end

function Agent:IsEmployed()
	return self:HasAspect( Job )
end

function Agent:IsRunning()
	return self:InCombat()
end

function Agent:GetVisibleObjectsByDistance()
	if self.location == nil then
		return
	end

	local x, y = self:GetCoordinate()

	local function SortByDistance( obj1, obj2 )
		local x1, y1 = obj1:GetCoordinate()
		local x2, y2 = obj2:GetCoordinate()
		return distance( x, y, x1, y1 ) < distance( x, y, x2, y2 )
	end
	local contents = {}
	for i, obj in self.location:Contents() do
		if self:CanSee( obj ) then
			table.insert( contents, obj )
		end
	end

	table.sort( contents, SortByDistance )
	return contents
end

function Agent:GetRelationshipAffinities()
	-- Todo, dynamic table of these cross-generated by Agent._class and Faction, perhaps others.
	return table.empty
end


