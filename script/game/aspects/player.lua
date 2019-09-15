---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Trait.Player", Aspect )

function Player:init()
	self.dice = {} -- Free dice.
	self.committed_dice = {} -- Map of Agent -> dice
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

function Player:Dice()
	return ipairs( self.dice )
end

function Player:CommitDice( dice, agent )
	assert( table.contains( self.dice, dice ))
	table.arrayremove( self.dice, dice )

	local t = self.committed_dice[ agent ]
	if t == nil then
		t = {}
		self.committed_dice[ agent ] = t
	end
	assert( not table.contains( t, dice ))
	table.insert( t, dice )

	dice:Roll()
end

function Player:UncommitDice( dice )
	for agent, t in pairs( self.committed_dice ) do
		local idx = table.find( t, dice )
		if idx then
			table.remove( t, idx )
			table.insert( self.dice, dice )
		end
		if #t == 0 then
			self.committed_dice[ agent ] = nil
		end
	end
end

function Player:GetCommittedDice( agent )
	return self.committed_dice[ agent ] or table.empty
end

