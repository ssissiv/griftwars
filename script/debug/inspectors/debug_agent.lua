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

	if ui.CollapsingHeader( "Inventory" ) then
		self.agent:GetInventory():RenderDebugPanel( ui, panel, dbg )
	end

	local agenda = self.agent:GetAspect( Aspect.Agenda )
	if agenda and ui.CollapsingHeader( "Agenda", "DefaultOpen" ) then
		ui.Columns( 3 )
		for i, task in ipairs( agenda.tasks ) do
			if self.agent:IsDoing( task.verb ) then
				ui.TextColored( 0, 1, 1, 1, tostring(task.verb) )
			else
				ui.TextColored( 0.5, 0.5, 0.5, 1, tostring(task.verb) )
			end
			ui.NextColumn()

			ui.Text( tostring(task.start_time) )
			ui.NextColumn()

			ui.Text( tostring(task.end_time) )
			ui.NextColumn()
		end
		ui.Columns( 1 )
		ui.Text( string.format( "Last Agenda: %s", Calendar.FormatTime( agenda.last_agenda )))
	end
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 