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

    local count = 0
    for i, exit in self.location:Exits() do
        local dest, addr = exit:GetDest( self.location )
        ui.Text( tostring(addr) )
        ui.SameLine( 200 )
    	panel:AppendTable( ui, dest )
        count = count + 1
    end

    if count > 0 then
        ui.Separator()
    end

    for i, obj in self.location:Contents() do
        panel:AppendTable( ui, obj )
    end

    ui.NewLine()
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 