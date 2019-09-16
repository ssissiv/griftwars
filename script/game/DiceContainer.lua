class( "DiceContainer" )

function DiceContainer:init( owner )
	self.owner = owner
	self.dice = {}
	self.committed_dice = {}
end

function DiceContainer:GetAgent()
	local owner = self.owner
	while owner and not is_instance( owner, Agent ) do
		owner = owner.owner
	end
	return owner
end

function DiceContainer:AddDie( die )
	assert( is_instance( die, ActionDie ))
	table.insert( self.dice, die )
	die:SetOwner( self )
end

function DiceContainer:GetDice()
	return self.dice
end

function DiceContainer:Dice()
	return ipairs( self.dice )
end

function DiceContainer:CommitDice( dice, agent )
	assert( table.contains( self.dice, dice ))
	table.arrayremove( self.dice, dice )

	local t = self.committed_dice[ agent ]
	if t == nil then
		t = {}
		self.committed_dice[ agent ] = t
	end
	assert( not table.contains( t, dice ))
	table.insert( t, dice )
end

function DiceContainer:UncommitDice( dice )
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

function DiceContainer:GetCommittedDice( agent )
	if agent == nil then
		return self.committed_dice
	else
		return self.committed_dice[ agent ] or table.empty
	end
end

