
---------------------------------------------------------------------

local CityGuard = class( "Agent.CityGuard", Agent )

CityGuard.MAP_CHAR = "g"
CityGuard.unfamiliar_desc = "city guard"
CityGuard.max_health = 20

function CityGuard:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Skill.Fighting() )

	self:EquipItem( Weapon.LongSword() )

	if math.random() < 0.2 then
		local want = self:GainAspect( Want.Money( 500 ))
		want:AddReq( Req.Trust( self, 20 ))
	end

	Aspect.Favour.GainFavours( self,
	{
		{ Favour.Acquaint(), 10 },
		{ Favour.NonAggression( 100 ), 20 },
		{ Favour.JoinParty(), 80 },
	})
end
