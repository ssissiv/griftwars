--[[
  A second in command in the militia.
  - Has command over MilitiaSoldiers, MilitiaQuarterMasters
  - Takes orders from MilitiaGeneral.

  - Values: Military, Power, Rumours, Defeating Enemies
  - Verbs: OrderAttackTeam, use Intel to invade enemy's Interaction??
  
--]]

---------------------------------------------------------------------


function Agent.MilitiaCaptain()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Commander of the militia.", GENDER.MALE )
	ch:GainAspect( Aspect.Behaviour() ):RegisterVerbs{
		Verb.Strategize( ch )
	}
	ch:GainAspect( Interaction.Acquaint( CR1 ) )
	ch:GainAspect( Interaction.Chat() )

	return ch
end
