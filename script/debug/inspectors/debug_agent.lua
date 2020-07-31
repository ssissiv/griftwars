local DebugAgent = class( "DebugAgent", DebugTable )
DebugAgent.REGISTERED_CLASS = Agent

DebugAgent.MENU_BINDINGS =
{
	{
		name = "Agent",
		{
			Text = "Trace",
			Enabled = function( self, agent )
				return not agent:HasAspect( Aspect.History )
			end,
			Do = function( self, agent )
				agent:GainAspect( Aspect.History() )
			end
		}
	},
}

function DebugAgent:init( agent )
	DebugTable.init( self, agent )
	self.agent = agent
	DBSET( "agent", agent )
end

function DebugAgent:RenderPanel( ui, panel, dbg )
	ui.Text( tostring(self.agent) )
	
	ui.TextColored( 0, 0.8, 0.8, 1, table.concat( self.agent.tags, " " ))

	local faction = self.agent:GetAspect( Aspect.FactionMember )
	if faction then
		ui.Text( "Faction:" )
		ui.SameLine( 0, 5 )
		panel:AppendTable( ui, faction.faction )
	end

	if not self.agent:IsPuppet() then
		if self.agent:GetLocation() then
			if ui.Button( loc.format( "Warp To {1}", self.agent:GetLocation()) ) then
				self.agent.world:DoAsync( function( world )
					world:GetPuppet():WarpToAgent( self.agent )
				end )
			end
		end

		ui.SameLine( 0, 10 )
		if ui.Button( "Switch To" ) then
			self.agent.world:SetPuppet( self.agent )
		end
	else
		if self.agent:GetLocation() then
			panel:AppendTable( ui, self.agent:GetLocation() )
		end

		ui.SameLine( 0, 10 )
		if not self.agent:IsPlayer() and ui.Button( "Switch To Player" ) then
			self.agent.world:SetPuppet( self.agent.world:GetPlayer() )
		end
	end

	ui.Text( "Home:" )
	ui.SameLine( 0, 10 )
	local home = self.agent:GetHome()
	if home then
		panel:AppendTable( ui, home )
	else
		ui.TextColored( 1, 0, 0, 1, "Homeless!" )
	end
	
	local puppet = self.agent.world:GetPuppet()
	if puppet ~= self.agent then
		if not puppet:IsAcquainted( self.agent ) and ui.Button( "Acquaint" ) then
			puppet:Acquaint( self.agent )
		end

		ui.SameLine( 0, 10 )

		local trust = self.agent:GetTrust( puppet )
		local _, new_trust = ui.SliderInt( "Trust", trust, 0, 100 )
		if new_trust and new_trust ~= trust then
			local delta = new_trust - trust
			self.agent:DeltaTrust( delta, puppet )
		end
	end

	if self.agent:HasAspect( Aspect.StatusEffect ) and ui.CollapsingHeader( "Status Effects" ) then
		for i, aspect in self.agent:Aspects() do
			if is_instance( aspect, Aspect.StatusEffect ) then
				aspect:RenderDebugPanel( ui, panel, dbg )
			end
		end
	end

	if ui.CollapsingHeader( "Verbs" ) then
		for i, verb in self.agent:Verbs() do
			verb:RenderDebugPanel( ui, panel, dbg )
		end
	end

	if puppet == self.agent and ui.CollapsingHeader( "Potential Verbs" ) then
		for id, verbs in pairs( self.agent.potential_verbs ) do
			if ui.TreeNode( id ) then				
				for j, verb in verbs:Verbs() do
					verb:RenderDebugPanel( ui, panel, dbg )
				end
				if ui.Button( "Refresh" ) then
					self.agent:RegenVerbs( id )
					self.agent:CollectPotentialVerbs( id )
				end
				ui.TreePop()
			end
		end
	end

	local combat = self.agent:GetAspect( Aspect.Combat )
	if combat and ui.CollapsingHeader( "Combat" ) then
		if combat.current_attack then
			ui.Text( "Current attack: " )
			ui.SameLine( 0, 10 )
			panel:AppendTable( ui, combat.current_attack )
		end
		local hcombat = self.agent:GetAspect( Verb.HostileCombat )
		if hcombat and hcombat.attacks then
			ui.Text( "Attacks:" )
			ui.Indent( 20 )
			ui.Columns( 2 )
			for i, attack in ipairs( hcombat.attacks ) do
				ui.TextColored( 0, 1, 1, 1, tostring(attack:GetUtility()))
				ui.NextColumn()

				panel:AppendTable( ui, attack )
				ui.NextColumn()
			end
			ui.Columns( 1 )
			ui.Unindent( 20 )
		end
		ui.Text( "Targets:" )
		for i, target in combat:Targets() do
			ui.SameLine( 0, 10 )
			panel:AppendTable( ui, target )
		end
		if combat.attack then
			panel:AppendTable( ui, combat.attack )
		end
	end

	if ui.CollapsingHeader( "Inventory" ) then
		self.agent:GetInventory():RenderDebugPanel( ui, panel, dbg )
	end

	if self.agent:CountRelationships() > 0 and ui.CollapsingHeader( "Relationships" ) then
		ui.Columns( 2 )
		for i, rel in self.agent:Relationships() do
			ui.Text( tostring(rel) )
			ui.NextColumn()

			for k, v in pairs( rel ) do
				if is_instance( v, Agent ) then
					ui.TextColored( 0.2, 1, 1, 1, tostring(k) )
					ui.SameLine( 0, 5 )
					panel:AppendTable( ui, v )
				elseif type(v) ~= "table" then
					ui.Text( tostring(k) )
					ui.SameLine( 0, 5 )
					ui.Text( tostring(v) )
				end
			end
			ui.NextColumn()
		end
		ui.Columns( 1 )
	end

	if ui.CollapsingHeader( "Stats" ) then
		for stat, aspect in self.agent:Stats() do
			aspect:RenderDebugPanel( ui, panel, dbg )
		end
	end

	local behaviour = self.agent:GetAspect( Aspect.Behaviour )
	if behaviour and ui.CollapsingHeader( "Behaviour", "DefaultOpen" ) then
		behaviour:RenderDebugPanel( ui, panel, dbg )
	end

    if ui.CollapsingHeader( "History" ) then
        local changed, filter = ui.InputText( "Filter", self.history_filter or "", 512 )
        if filter and filter ~= self.history_filter then
            self.history_filter = filter
        end
        ui.Indent( 10 )
        for i, v in self.agent.world:GetAspect( Aspect.History ):Items() do
            if table.contains( v, self.agent ) then
                local txt = loc.format( table.unpack( v, 1, table.maxn( v ) ))
                if (self.history_filter == nil or txt:find( self.history_filter )) and ui.Selectable( txt ) then
                    DBG(v)
                end
            end
        end
        ui.Unindent( 10 )
    end

	DebugTable.RenderPanel( self, ui, panel, dbg )
end

 