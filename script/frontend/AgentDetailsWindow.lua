local AgentDetailsWindow = class( "AgentDetailsWindow" )

function AgentDetailsWindow:init( viewer, agent )
	assert( agent )
	self.viewer = viewer
	self.agent = agent
end

function AgentDetailsWindow:Refresh( agent )
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

function AgentDetailsWindow:RenderAspects( txt, ui, screen, class )
	if self.agent:HasAspect( class ) then
		ui.Bullet()
		ui.Text( txt )
		ui.Indent( 20 )
		for i, aspect in self.agent:Aspects() do
			if is_instance( aspect, class ) then
				aspect:RenderAgentDetails( ui, screen, self.viewer )
			end
		end
		ui.Unindent ( 20 )
	end
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
						ui.PushStyleColor( "Button", 1, 0, 0, 1 )
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
		ui.Text( "Description: " .. self.agent:GetLongDesc( self.viewer ))
		ui.SameLine( 0, 10 )
		if ui.SmallButton( "?" ) then
			DBG( self.agent )
		end

		ui.Text( "Gender:" )
		ui.SameLine( 0, 5 )
		ui.TextColored( 0, 1, 1, 1, tostring(self.agent.gender) )

		if self.agent ~= self.viewer then
			local affinity, trust = self.agent:GetAffinity( self.viewer ), self.agent:GetTrust( self.viewer )
			ui.Text( "Relationship:" )
			ui.SameLine( 0, 5 )
			ui.TextColored( 1, 1, 0, 1, tostring(affinity))
			ui.SameLine( 0, 20 )
			ui.Text( loc.format( "Trust: {1}", trust ))
		end

		-- ASPECTS
		ui.Separator()
		for id, aspect in self.agent:Aspects() do
			if aspect.RenderAgentDetails and not is_instance( aspect, Aspect.Favour ) and not is_instance( aspect, Aspect.Skill ) then
				aspect:RenderAgentDetails( ui, screen, self.viewer )
			end
		end
		
		self:RenderAspects( "Favours:", ui, screen, Aspect.Favour )
		self:RenderAspects( "Skills:", ui, screen, Aspect.Skill )

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

function AgentDetailsWindow:KeyPressed( key, screen )
	if key == "return" or key == "escape" then
		screen:RemoveWindow( self )
		return true
	end
end
