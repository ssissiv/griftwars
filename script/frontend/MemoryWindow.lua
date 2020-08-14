local MemoryWindow = class( "MemoryWindow" )

function MemoryWindow:init( agent )
	assert( agent )
	self.agent = agent

	-- Hm, mutator on world state.
	agent.memory:RefreshEngrams()
end

function MemoryWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

	local txt = loc.format( "{1.Id}'s Knowledge", self.agent:LocTable() )
	if self.agent:IsPuppet() then
		txt = txt .. " (YOU)"
	end

    local visible, show = ui.Begin( txt, true, flags )
    if visible and show then
    	local count = 0
		for i, engram in self.agent:GetMemory():Engrams() do
			ui.PushID( rawstring(engram) )

			local desc = engram:GetDesc()
			if ui.TreeNode( tostring(desc) ) then
				ui.PushID( rawstring(engram) )
				ui.TextColored( 0.8, 0.8, 0.8, 1.0, loc.format( "({1} ago)", Calendar.FormatDuration( engram:GetAge( self.agent ))))

				local duration = engram:GetLifetime()
				if duration then
					local time_left = duration - engram:GetAge( self.agent )
					ui.Text( loc.format( "Expires in: {1}", Calendar.FormatDuration( time_left )))
				end

				if engram.RenderImGuiWindow then
					engram:RenderImGuiWindow( ui, screen, self.agent )
				end

				ui.PopID()
				ui.TreePop()
			end
			ui.PopID()

			ui.SameLine( 0, 10 )
			if ui.SmallButton( "?" ) then
				DBG( engram )
			end
			count = count + 1
		end
		if count == 0 then
			ui.TextColored( 0.5, 0.5, 0.5, 1, "You have no knowledge of importance." )
		end

		ui.Separator()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
		
	elseif not show then
		screen:RemoveWindow( self )
	end

    ui.End()
end
