local DebugLocation = class( "DebugLocation", DebugTable )
DebugLocation.REGISTERED_CLASS = Location

function DebugLocation:init( location )
	DebugTable.init( self, location )
    self.location = location
end

function DebugLocation:RenderScreen()
    local screen = GetGUI():GetTopScreen()
    if is_instance( screen, GameScreen ) then
        screen:SetColour( 0xFFFFFFFF )
        for i, wp in self.location:Waypoints() do
            local x, y = wp:GetCoordinate()
            local x1, y1 = screen.camera:WorldToScreen( x, y )
            local x2, y2 = screen.camera:WorldToScreen( x + 1, y + 1 )
            screen:Box( x1, y1, x2 - x1, y2 - y1 )
            screen:DebugText( x1, y1, wp.tag or "Waypoint" )
        end
    end
end

function DebugLocation:RenderPanel( ui, panel, dbg )
    ui.Text( self.location:GetTitle() )
    
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
            puppet:DoVerbAsync( Verb.Travel( puppet, self.location ))
        end
    end
    ui.Separator()

    ui.Text( "Zone:" )
    ui.SameLine( 0, 5 )
    local zone, location_depth = self.location:GetZone(), self.location:GetLocationDepth()
    panel:AppendTable( ui, self.location:GetZone() )
    ui.Text( loc.format( "Depth: {1}-{2}", zone and zone:GetZoneDepth(), location_depth ))
    local wx, wy, wz = self.location:GetCoordinate()
    if wx and wy then
        ui.Text( loc.format( "<{1}, {2}> Layer {3}", wx, wy, wz ))
    end

    for i, obj in self.location:Contents() do
        panel:AppendTable( ui, obj )
    end

    ui.NewLine()

    DebugTable.RenderPanel( self, ui, panel, dbg )

    self:RenderScreen()
end

 