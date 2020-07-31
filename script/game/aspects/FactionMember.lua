
local FactionMember = class( "Aspect.FactionMember", Aspect )

FactionMember.TABLE_KEY = "faction"

function FactionMember:init( faction, role, role_title )
	assert( is_instance( faction, Faction ))
	assert( role == nil or IsEnum( role, FACTION_ROLE ))
	self.faction = faction
	self.role = role
	if role then
		self.entity_tags = { role:lower() }
	end
	self.role_title = role_title
end

function FactionMember:GetName()
	return self.faction:GetFactionName()
end

function FactionMember:GetRoleTitle()
	return self.role_title
end

function FactionMember:GetRole()
	return self.role
end

function FactionMember:GetSuperiors()
	if self.role then
		return self.faction:GetSuperiorsByRole( self.role )
	else
		return table.empty
	end
end

function FactionMember:GetSubordinates()
	if self.role then
		return self.faction:GetSubordinatesByRole( self.role )
	else
		return table.empty
	end
end

function FactionMember:IsEnemy( other )
	assert( is_instance( other, FactionMember ))
	return self.faction:HasTag( other.faction, FACTION_TAG.ENEMY )
end

function FactionMember:IsAlly( other )
	assert( is_instance( other, FactionMember ))
	return self.faction == other.faction or	self.faction:HasTag( other, FACTION_TAG.ALLY )
end

function FactionMember:AddEnemy( other )
	assert( is_instance( other, FactionMember ))
	self.faction:AddTag( other.faction, FACTION_TAG.ENEMY )
end

-- Assign our faction to agent's.
function FactionMember:AssignFaction( agent )
	local faction = agent:GetAspect( Aspect.FactionMember )
	if faction then
		faction.faction = self.faction
	else
		faction = agent:GainAspect( Aspect.FactionMember( self.faction ))
	end

	return faction -- return agent's Aspect.Faction
end


function FactionMember:__tostring()
	return string.format( "%s [%s]", self._classname, tostring(self.faction))
end

