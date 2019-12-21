--------------------------------------------------------------------
-- A debug root level node.

local DebugWorld = class( "DebugWorld", DebugTable )
DebugWorld.REGISTERED_CLASS = World

function DebugWorld:init( world )
	DebugTable.init( self, world )
    self.world = world
end

function DebugWorld:RenderPanel( ui, panel, dbg )
    if ui.Button( "+One Hour" ) then
        self.world:AdvanceTime( ONE_HOUR )
    end

    if ui.TreeNode( "Scheduled Events" ) then
    	for i, ev in ipairs( self.world.scheduled_events ) do
    		local txt = string.format( "%.2f - %s", ev.when - self.world.datetime, tostring(ev[1]))
    		ui.Text( txt )
    		for i = 1, #ev do
    			ui.Text( "  "..tostring(ev[i]))    			
    		end
    	end
    	ui.TreePop()
    end
   	ui.Separator()

    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 