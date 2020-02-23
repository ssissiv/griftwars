function Agent:IsEnemy( other )
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
		return owned_skill:CanLearn()
	else
		
	end
end

function Agent:IsEmployed()
	return self:HasAspect( Job )
end
