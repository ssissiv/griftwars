local AgentDetailsWindow = class( "AgentDetailsWindow" )

function AgentDetailsWindow:init( viewer, agent )
	assert( agent )
	self.viewer = viewer
	self.agent = agent
end

function AgentDetailsWindow:RenderRelationships( ui, screen )
	ui.Text( "Relationships:" )
	ui.Bullet()
	ui.Text( loc.format( "Friends: {1}/{2}", self.agent:CountAffinities( AFFINITY.FRIEND ), self.agent:GetMaxFriends() ))

	local affinity_count = self.agent.affinities and table.count( self.agent.affinities ) or 0
	if affinity_count > 0 then
		ui.Columns( affinity_count )
		for i, rel in self.agent:Relationships() do
			if is_instance( rel, Relationship.Affinity ) then
				local affinity = rel:GetAffinity()
				if assets.AFFINITY_IMG[ affinity ] then
					local other = rel:GetOther( self.agent )
					ui.Image( assets.AFFINITY_IMG[ affinity ], 48, 48 )
					ui.TextColored( 0, 1, 1, 1, loc.format( "{1} - {2}", other:GetName(), affinity ))
					ui.Text( Calendar.FormatDuration( rel:GetAge() ))
					ui.SameLine( 0, 5 )
					if affinity == AFFINITY.FRIEND then
						ui.PushStyleColor( ui.Style_Button, 1, 0, 0, 1 )
						if ui.SmallButton( "X" ) then
							self.agent:Unfriend( other )
						end
						ui.PopStyleColor()
					end
					ui.NextColumn()
				end
			end
		end
		ui.Columns( 1 )
	end
end

function AgentDetailsWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

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

		for i, verb in self.agent:Verbs() do
			local desc = verb:GetDetailsDesc( self.viewer )
			if desc then
				ui.Bullet()
				ui.Text( tostring(desc) )
			end
		end

		ui.NewLine()

		self:RenderRelationships( ui, screen )

		ui.Separator()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
	end

    ui.End()
end
