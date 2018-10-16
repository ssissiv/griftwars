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

	if ui.TreeNode( "Verbs" ) then
		if self.verbs == nil then
			self.verbs = self.agent:CollectAllInteractions( {} )
		end
		for i, verb in ipairs( self.verbs ) do
			panel:AppendTable( ui, verb )
		end
		ui.TreePop()
	end
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 