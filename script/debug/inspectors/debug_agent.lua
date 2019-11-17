local DebugAgent = class( "DebugAgent", DebugTable )
DebugAgent.REGISTERED_CLASS = Agent

function DebugAgent:init( agent )
	DebugTable.init( self, agent )
	self.agent = agent
end

function DebugAgent:RenderPanel( ui, panel, dbg )
	if not self.agent:IsPuppet() then
		if self.agent:GetLocation() then
			if ui.Button( "Warp To" ) then
				self.agent.world:GetPuppet():MoveToAgent( self.agent )
			end
		end

		ui.SameLine( 0, 10 )
		if ui.Button( "Switch To" ) then
			self.agent.world:SetPuppet( self.agent )
		end
	end

	local puppet = self.agent.world:GetPuppet()
	if not puppet:IsAcquainted( self.agent ) and ui.Button( "Acquaint" ) then
		puppet:Acquaint( self.agent )
	end

	if ui.CollapsingHeader( "Potential Verbs" ) then
		for i, verb in self.agent:PotentialVerbs() do
			panel:AppendTable( ui, verb )
		end
	end

	if ui.CollapsingHeader( "Actions" ) then
		ui.Columns( 2 )
		for i, action in self.agent:Verbs() do
			panel:AppendTable( ui, action.verb )
			ui.NextColumn()

			panel:AppendTable( ui, action.coro )
			ui.NextColumn()
		end
		ui.Columns( 1 )
	end

	if ui.CollapsingHeader( "Inventory" ) then
		self.agent:GetInventory():RenderDebugPanel( ui, panel, dbg )
	end

	if ui.CollapsingHeader( "Stats" ) then
		for stat, aspect in puppet:Stats() do
			aspect:RenderDebugPanel( ui, panel, dbg )
		end
	end

	local behaviour = self.agent:GetAspect( Aspect.Behaviour )
	if behaviour and ui.CollapsingHeader( "Behaviour", "DefaultOpen" ) then
		behaviour:RenderDebugPanel( ui, panel, dbg )
	end
	
	DebugTable.RenderPanel( self, ui, panel, dbg )
end

 