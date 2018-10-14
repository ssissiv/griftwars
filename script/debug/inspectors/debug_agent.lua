local DebugAgent = class( "DebugAgent", DebugTable )
DebugAgent.REGISTERED_CLASS = Agent

function DebugAgent:init( agent )
	DebugTable.init( self, agent )
    self.agent = agent
end

function DebugAgent:RenderPanel( ui, panel, dbg )
	if not self.agent:IsPlayer() and self.agent:GetLocation() then
		if ui.Button( "Warp To" ) then
			self.agent.world:GetPlayer():MoveToAgent( self.agent )
		end
	end
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 