local DebugLocation = class( "DebugLocation", DebugTable )
DebugLocation.REGISTERED_CLASS = Location

function DebugLocation:init( location )
	DebugTable.init( self, location )
    self.location = location
end

function DebugLocation:RenderPanel( ui, panel, dbg )
	if ui.Button( "Warp To" ) then
		self.location.world:GetPlayer():MoveToLocation( self.location )
	end
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 