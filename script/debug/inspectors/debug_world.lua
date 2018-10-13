--------------------------------------------------------------------
-- A debug root level node.

local DebugWorld = class( "DebugWorld", DebugTable )
DebugWorld.REGISTERED_CLASS = World

function DebugWorld:init( world )
	DebugTable.init( self, world )
    self.world = world
end

function DebugWorld:RenderPanel( ui, panel, dbg )
    ui.Text( string.format( "Time: %.2f, Tick: %d", self.world:GetDateTime(), self.world:GetUpdateTick() ))

    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 