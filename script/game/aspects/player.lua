---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Aspect.Player", Aspect )

function Player:init()
	-- self.dice = DiceContainer( self )
end

function Player:AddDefaultDice()
	self.dice:AddDie( ActionDie.MakeHostileDie() )
	self.dice:AddDie( ActionDie.MakeDiplomacyDie() )
	self.dice:AddDie( ActionDie.MakeDiplomacyDie() )
end

function Player:GetDice()
	return self.dice
end

