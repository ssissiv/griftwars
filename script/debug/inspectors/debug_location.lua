local DebugLocation = class( "DebugLocation", DebugTable )
DebugLocation.REGISTERED_CLASS = Location

function DebugLocation:init( location )
	DebugTable.init( self, location )
    self.location = location
end

function DebugLocation:RenderPanel( ui, panel, dbg )
    local faction = self.location:GetAspect( Aspect.FactionMember )
    if faction then
        ui.Text( "Faction:" )
        ui.SameLine( 0, 10 )
        panel:AppendTable( ui, faction.faction )
    end

    local puppet = self.location.world and self.location.world:GetPuppet()
    if puppet then
    	if ui.Button( "Warp To" ) then
    		self.location.world:DoAsync( function( world ) puppet:WarpToLocation( self.location ) end )
    	end
        
        ui.SameLine( 0, 10 )
        if ui.Button( "Travel To" ) then
            puppet:DoVerbAsync( Verb.Travel(), self.location )
        end
    end
    ui.Separator()

    ui.Text( "Zone:" )
    ui.SameLine( 0, 5 )
    local zone, location_depth = self.location:GetZone(), self.location:GetLocationDepth()
    panel:AppendTable( ui, self.location:GetZone() )
    ui.Text( loc.format( "Depth: {1}-{2}", self.location:GetZone():GetZoneDepth(), location_depth ))
    local wx, wy, wz = self.location:GetCoordinate()
    if wx and wy then
        ui.Text( loc.format( "<{1}, {2}> Layer {3}", wx, wy, wz ))
    end

    for i, obj in self.location:Contents() do
        panel:AppendTable( ui, obj )
    end

    ui.NewLine()
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 