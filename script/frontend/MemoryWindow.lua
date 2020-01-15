local MemoryWindow = class( "MemoryWindow" )

function MemoryWindow:init( agent )
	assert( agent )
	self.agent = agent
end

function MemoryWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

	local txt = loc.format( "{1.Id}'s Knowledge", self.agent:LocTable() )
	if self.agent:IsPuppet() then
		txt = txt .. " (YOU)"
	end

    local shown, close, c = ui.Begin( txt, false, flags )
    if shown then
    	local count = 0
		for i, engram in self.agent:GetMemory():Engrams() do
			ui.Bullet()
			engram:RenderImGuiWindow( ui, screen, self.agent )
			ui.SameLine( 0, 10 )
			if ui.SmallButton( "?" ) then
				DBG( engram )
			end
			ui.Indent( 20 )
			ui.TextColored( 0.8, 0.8, 0.8, 1.0, loc.format( "({1} ago)", Calendar.FormatDuration( engram:GetAge( self.agent ))))
			for i, action in ipairs( engram.ACTIONS or table.empty ) do
				if i > 1 then
					ui.SameLine( 0, 10 )
				end
				if ui.Button( action.name ) then
					action.verb( engram, self.agent )
				end
			end
			ui.Unindent( 20 )
			count = count + 1
		end
		if count == 0 then
			ui.TextColored( 0.5, 0.5, 0.5, 1, "You have no knowledge of importance." )
		end

		ui.Separator()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
	end

    ui.End()
end
