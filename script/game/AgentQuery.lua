function Agent:IsEnemy( other )
	if is_instance( other, Agent ) then
		if self:IsFeral() or other:IsFeral() then
			return true
		end
	end

	local f1 = self:GetAspect( Aspect.Faction )
	local f2 = other:GetAspect( Aspect.Faction )
	return f1 and f2 and f1:IsEnemy( f2 )
end

function Agent:IsAlly( other )
	local f1 = self:GetAspect( Aspect.Faction )
	local f2 = other:GetAspect( Aspect.Faction )
	return f1 and f2 and f1:IsAlly( f2 )
end

function Agent:CalculateAttackDamage()
	return self.acc:CalculateValue( CALC_EVENT.ATTACK_DAMAGE, 1 )
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

function Agent:IsEmployed()
	return self:HasAspect( Job )
end


function Agent:IsFeral()
	return self.feral == true
end

function Agent:SetFeral( feral )
	self.feral = feral
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
