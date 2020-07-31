
---------------------------------------------------------------------

local Bandit = class( "Agent.Bandit", Agent )

Bandit.unfamiliar_desc = "bandit"
Bandit.image = assets.TILE_IMG.BANDIT
Bandit.role_images =
{
	[ FACTION_ROLE.CAPTAIN ] = assets.TILE_IMG.BANDIT_CAPTAIN
}

Bandit.max_health = 14
Bandit.entity_tags = { "bandit" }

function Bandit:GetMapChar()
	return "b", constants.colours.RED
end

function Bandit:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Skill.Fighting() )
	self:EquipItem( Weapon.Dirk() )

	-- Aspect.Favour.GainFavours( self,
	-- {
	-- 	{ Favour.Acquaint(), 10 },
	-- 	{ Favour.NonAggression( 100 ), 20 },
	-- 	{ Favour.JoinParty(), 80 },
	-- })
end
