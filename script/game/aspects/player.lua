---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Trait.Player", Aspect )

function Player:init()
	self.dice = {}
end

function Player:AddDie( die )
	assert( is_instance( die, ActionDie ))
	table.insert( self.dice, die )
end

function Player:AddDefaultDice()
	self:AddDie( ActionDie.MakeHostileDie( self.owner ) )
	self:AddDie( ActionDie.MakeDiplomacyDie( self.owner ) )
	self:AddDie( ActionDie.MakeDiplomacyDie( self.owner ) )
end

function Player:GetDice()
	return self.dice
end

function Player:CollectDiceWithFace( face, t )
	t = t or {}
	for i, die in ipairs( self.dice ) do
		if die:HasFace( face ) then
			table.insert_unique( t, die )
		end
	end

	return t
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
