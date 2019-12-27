local DebugAgent = class( "DebugAgent", DebugTable )
DebugAgent.REGISTERED_CLASS = Agent

function DebugAgent:init( agent )
	DebugTable.init( self, agent )
	self.agent = agent
end

function DebugAgent:RenderPanel( ui, panel, dbg )
	ui.Text( tostring(self.agent) )
	
	if not self.agent:IsPuppet() then
		if self.agent:GetLocation() then
			if ui.Button( loc.format( "Warp To {1}", self.agent:GetLocation()) ) then
				self.agent.world:GetPuppet():MoveToAgent( self.agent )
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
	end

	local home = self.agent:GetHome()
	if home then
		panel:AppendTable( ui, home )
	end
	
	local puppet = self.agent.world:GetPuppet()
	if not puppet:IsAcquainted( self.agent ) and ui.Button( "Acquaint" ) then
		puppet:Acquaint( self.agent )
	end

	if ui.CollapsingHeader( "Verbs" ) then
		for i, verb in self.agent:Verbs() do
			verb:RenderDebugPanel( ui, panel, dbg )
		end
	end

	if ui.CollapsingHeader( "Potential Verbs" ) then
		for id, verbs in pairs( self.agent.potential_verbs ) do
			ui.Bullet( id )
			ui.Text( id )
			
			for j, verb in verbs:Verbs() do
				verb:RenderDebugPanel( ui, panel, dbg )
			end
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
	
	DebugTable.RenderPanel( self, ui, panel, dbg )
end

 