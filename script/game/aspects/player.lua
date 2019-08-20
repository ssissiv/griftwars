---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Trait.Player", Aspect )

function Player:init()
	self.dice = {}
end

function Player:AddDie( die )
	table.insert( self.dice, die )
end

function Player:AddDefaultDice()
	self:AddDie( ActionDie.MakeHostileDie() )
	self:AddDie( ActionDie.MakeDiplomacyDie() )
	self:AddDie( ActionDie.MakeDiplomacyDie() )
end

function Player:GetDice()
	return self.dice
end

function Player:HasDieWithFace( face )
	for i, die in ipairs( self.dice ) do
		if die:HasFace( face ) then
			return true
		end
	end
end

function Player:ResetDieRolls()
	for i, die in ipairs( self.dice ) do
		die:ResetRoll()
	end
end
