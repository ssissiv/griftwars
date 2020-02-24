local DebugFaction = class( "DebugFaction", DebugTable )
DebugFaction.REGISTERED_CLASS = FactionData

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
end
