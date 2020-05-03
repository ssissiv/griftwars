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
