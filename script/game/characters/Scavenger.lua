function Agent.Scavenger()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Here's a guy.", GENDER.MALE )
	ch:GainAspect( Trait.Cowardly() )
	ch:GainAspect( Trait.Poor() )
	ch:GainAspect( Aspect.Behaviour() )
	ch:GainAspect( Skill.Scrounge() )
	ch:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
	ch:GainAspect( Interaction.Acquaint() )
	ch:GainAspect( Interaction.Chat() )

	return ch
end