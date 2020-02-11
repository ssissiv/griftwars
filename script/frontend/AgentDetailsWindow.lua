local AgentDetailsWindow = class( "AgentDetailsWindow" )

function AgentDetailsWindow:init( viewer, agent )
	assert( agent )
	self.viewer = viewer
	self.agent = agent
end

function AgentDetailsWindow:RenderAllRelationships( ui, screen )
	ui.Bullet()
	local count = self.agent:CountAffinities( AFFINITY.FRIEND )
	ui.Text( loc.format( "Friends: {1}/{2}", count, self.agent:GetMaxFriends() ))	
	self:RenderRelationships( ui, screen, AFFINITY.FRIEND )

	ui.Spacing()
	ui.Bullet()
	ui.Text( "Known" )
	self:RenderRelationships( ui, screen, AFFINITY.KNOWN )
end

function AgentDetailsWindow:RenderRelationships( ui, screen, affinity )

	local affinity_count = self.agent:CountAffinities( affinity )
	if affinity_count > 0 then
		ui.Columns( affinity_count )
		for i, rel in self.agent:Relationships() do
			if is_instance( rel, Relationship.Affinity ) and rel:GetAffinity() == affinity then
				if assets.AFFINITY_IMG[ affinity ] then
					local other = rel:GetOther( self.agent )
					ui.PushID( rawstring(other) )
					ui.Image( assets.AFFINITY_IMG[ affinity ], 48, 48 )
					ui.TextColored( 0, 1, 1, 1, loc.format( "{1} - {2}", other:GetName(), affinity ))
					if ui.IsItemHovered() then
						ui.SetTooltip( Calendar.FormatDuration( rel:GetAge() ))
					end

					if affinity == AFFINITY.FRIEND then
						ui.SameLine( 0, 5 )
						ui.PushStyleColor( ui.Style_Button, 1, 0, 0, 1 )
						if ui.SmallButton( "X" ) then
							self.agent:Unfriend( other )
						end
						ui.PopStyleColor()
					end

					ui.SameLine( 0, 5 )
					if ui.SmallButton( "?" ) then
						DBG( other )
					end

					if affinity == AFFINITY.FRIEND then
						local trust = rel:GetTrust()
						ui.TextColored( 0, 1, 1, 1, loc.format( "{1}/{2} Trust", trust, 100 ))
					end

					ui.NextColumn()
					ui.PopID()
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

		ui.Text( "Actions:" )
		for i, verb in self.agent:Verbs() do
			local desc = verb:GetDetailsDesc( self.viewer )
			if desc then
				ui.Bullet()
				ui.Text( tostring(desc) )
			end
		end

		ui.NewLine()

		if self.agent == self.viewer then
			self:RenderAllRelationships( ui, screen )
		end

		ui.Separator()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
	end

    ui.End()
end
