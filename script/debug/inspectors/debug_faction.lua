local DebugFaction = class( "DebugFaction", DebugTable )
DebugFaction.REGISTERED_CLASS = Faction

function DebugFaction:init( faction )
	DebugTable.init( self, faction )
	self.faction = faction
end

function DebugFaction:RenderPanel( ui, panel, dbg )
	ui.Text( tostring(self.faction) )

	ui.TextColored( 0, 255, 255, 255, self.faction.name )

	ui.Columns( 2 )
	for i, f, tags in sorted_pairs( self.faction.tags ) do
		panel:AppendTable( ui, f )
		ui.NextColumn()

		ui.Text( tostr(tags) )
		ui.NextColumn()
	end
	ui.Columns( 1 )

	ui.Spacing()
	ui.Text( "Members:" )
	for role, agents in pairs( self.faction.members ) do
		for i, agent in ipairs( agents ) do
			ui.Text( string.format( "%d) %s", i, role ))
			ui.SameLine( 100 )
			panel:AppendTable( ui, agent )
		end
	end

end
