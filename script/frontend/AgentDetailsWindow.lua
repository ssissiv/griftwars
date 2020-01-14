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
	if self.agent:IsPuppet() then
		txt = txt .. " (YOU)"
	end

    local shown, close, c = ui.Begin( txt, false, flags )
    if shown then
		ui.Text( "Description: " .. self.agent:GetShortDesc( self.viewer ))
		ui.Text( "Gender:" )
		ui.SameLine( 0, 5 )
		ui.TextColored( 0, 1, 1, 1, tostring(self.agent.gender) )

		local job = self.agent:GetAspect( Job )
		if job then
			ui.Text( "Job:" )
			ui.SameLine( 0, 5 )
			ui.Text( job:GetName() )

			local salary = job:GetSalary()
			if salary then
				ui.Text( "  Salary:" )
				ui.SameLine( 0, 5 )
				ui.TextColored( 0, 1, 0, 1, loc.format( "{1} credits/day", salary ))
			end
			local hire_time = job:GetHireTime()
			if hire_time then
				local now = self.agent.world:GetDateTime()
				ui.Text( loc.format( "  Hired for: {1}", Calendar.FormatDuration( now - hire_time )))
			end
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

		if self.agent == self.viewer and self.agent:GetMemory() then
			if ui.TreeNode( "Engrams" ) then
				for i, engram in self.agent:GetMemory():Engrams() do
					ui.Bullet()
					engram:RenderImGuiWindow( ui, screen, self.agent )
					ui.SameLine( 0, 10 )
					if ui.SmallButton( "?" ) then
						DBG( engram )
					end
					ui.TextColored( 0.8, 0.8, 0.8, 1.0, loc.format( "({1} ago)", Calendar.FormatDuration( engram:GetAge( self.agent ))))
				end
				ui.TreePop()
			end
		end

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
	end

    ui.End()
end
