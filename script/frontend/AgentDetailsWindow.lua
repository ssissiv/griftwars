local AgentDetailsWindow = class( "AgentDetailsWindow" )

function AgentDetailsWindow:init( viewer, agent )
	assert( agent )
	self.viewer = viewer
	self.agent = agent
	self.view_fn = self.RenderStats
	self.tab_buttons =
	{
		{ name = "Stats", fn = self.RenderStats },
		{ name = "Skills", fn = self.RenderSkills },
		{ name = "Equipment", fn = self.RenderEquipment },
	}

	if self.agent == self.viewer then
		table.insert( self.tab_buttons, { name = "Relationships", fn = self.RenderAllRelationships })
	else
		table.insert( self.tab_buttons, { name = "Favours", fn = self.RenderFavours })
	end
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

function AgentDetailsWindow:RenderStats( ui, screen )
	self:RenderAspects( "Stats:", ui, screen, Aspect.StatValue )
	self:RenderAspects( "Combat:", ui, screen, Verb.Combat )
	self:RenderAspects( "Job:", ui, screen, Job )
end

function AgentDetailsWindow:RenderEquipment( ui, screen )
	if self.inventory_window == nil then
		self.inventory_window = InventoryWindow( self.agent.world, self.viewer, self.agent:GetInventory() )
	end

	ui.Spacing()
	ui.Indent( 20 )
	self.inventory_window:RenderInventory( ui, screen )
	ui.Unindent( 20 )
	ui.Spacing()

	-- for i, slot in ipairs( EQ_SLOT_ARRAY ) do
	-- 	local obj = self.agent:GetInventory():AccessSlot( slot )
	-- 	if obj then
	-- 		ui.Text( loc.format( "<{1}>", EQ_SLOT_NAMES[ slot ] ))
	-- 		ui.SameLine( 80 )
	-- 		ui.Text( obj:GetName( self.viewer ))
	-- 	end
	-- end
end

function AgentDetailsWindow:RenderSkills( ui, screen )
	self:RenderAspects( "Skills:", ui, screen, Aspect.Skill )
end

function AgentDetailsWindow:RenderFavours( ui, screen )
	self:RenderAspects( "Favours:", ui, screen, Aspect.Favour )
end

function AgentDetailsWindow:RenderTabButton( ui, idx, txt, fn )
	if idx > 1 then
		ui.SameLine( 0, 10 )
	end
	local active = fn == self.view_fn
	if active then
		ui.PushStyleColor( "Button", 0, 0.4, 0.5, 1 )
	end

	if ui.Button( txt ) then
		self.view_fn = fn
	end

	if active then
		ui.PopStyleColor()
	end
end

function AgentDetailsWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

	local txt = loc.format( "{1.Id}", self.agent:LocTable() )
	if self.agent:IsPuppet() then
		txt = txt .. " (YOU)"
	end

    local visible, show = ui.Begin( txt, true, flags )
    if visible and show then
		UIHelpers.RenderSelectedEntity( ui, screen, self.agent, self.viewer )
		ui.Dummy( 400, 0 )

		ui.Spacing()

		for i, t in ipairs( self.tab_buttons ) do
			self:RenderTabButton( ui, i, t.name, t.fn )
		end
	
		-- Render Current Tab
		if self.view_fn then
			ui.Separator()
			self.view_fn( self, ui, screen )
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

function AgentDetailsWindow:KeyPressed( key, screen )
	if key == "return" or key == "escape" then
		screen:RemoveWindow( self )
		return true

	elseif key == "tab" then
		for i, t in ipairs( self.tab_buttons ) do
			if t.fn == self.view_fn then
				self.view_fn = self.tab_buttons[ (i % #self.tab_buttons) + 1 ].fn
				break
			end
		end
		return true
	end

	if self.inventory_window and self.inventory_window:KeyPressed( key, screen ) then
		return true
	end
end
