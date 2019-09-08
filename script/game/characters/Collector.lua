local function ManageScavengers( leader )
	for i, member in ipairs( leader ) do
		
	end
end


function Agent.Collector()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	ch:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
	ch:GainAspect( Trait.Leader( ManageScavengers ))
	-- controls Scavengers.
	return ch
end

