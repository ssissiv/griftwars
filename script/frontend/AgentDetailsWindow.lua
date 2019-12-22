local AgentDetailsWindow = class( "AgentDetailsWindow" )

function AgentDetailsWindow:init( viewer, agent )
	assert( agent )
	self.viewer = viewer
	self.agent = agent
end

function AgentDetailsWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 500,300 )

	local txt = loc.format( "{1.Id}", self.agent:LocTable() )
    local shown, close, c = ui.Begin( txt, false, flags )
    if shown then
		ui.Text( self.agent:GetShortDesc( self.viewer ))
		ui.Text( "Gender:" )
		ui.SameLine( 0, 5 )
		ui.TextColored( 0, 1, 1, 1, tostring(self.agent.gender) )

		local job = self.agent:GetAspect( Job )
		if job then
			ui.Text( "Job:" )
			ui.SameLine( 0, 5 )
			ui.Text( loc.format( "{1} for {2.Id}", job:GetName(), job.employer:LocTable( self.viewer )))
		end

		ui.Text( "Doing:" )
		ui.Indent( 20 )
		for i, verb in self.agent:Verbs() do
			local desc = verb:GetDetailsDesc( self.viewer )
			if desc then
				ui.Bullet()
				ui.Text( tostring(desc) )
			end
		end
		ui.Unindent( 20 )

		ui:NewLine()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
	end

    ui.End()
end
