local DebugLocation = class( "DebugLocation", DebugTable )
DebugLocation.REGISTERED_CLASS = Location

function DebugLocation:init( location )
	DebugTable.init( self, location )
    self.location = location
end

function DebugLocation:RenderPanel( ui, panel, dbg )
	if ui.Button( "Warp To" ) then
		self.location.world:DoAsync( function( world ) world:GetPuppet():WarpToLocation( self.location ) end )
	end
    
    ui.Separator()

    for exit, dest in self.location:Exits() do
        ui.Text( tostring(exit) )
        ui.SameLine( 100 )
    	panel:AppendTable( ui, dest )
    end

    ui.Separator()

    for i, obj in self.location:Contents() do
        panel:AppendTable( ui, obj )
    end

    ui.NewLine()
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 