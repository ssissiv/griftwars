local DebugLocation = class( "DebugLocation", DebugTable )
DebugLocation.REGISTERED_CLASS = Location

function DebugLocation:init( location )
	DebugTable.init( self, location )
    self.location = location
end

function DebugLocation:RenderPanel( ui, panel, dbg )
    local faction = self.location:GetAspect( Aspect.Faction )
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

    ui.Text( "Exits:" )
    ui.Columns( 2 )
    local count = 0
    for i, portal in self.location:Portals() do
        local dest, x, y = portal:GetDest()
        if x then
            ui.Text( loc.format( "{1} ({2}, {3})", dest, x, y ))
        else
            ui.Text( tostring(dest))
        end
        ui.NextColumn()

    	panel:AppendTable( ui, dest )
        ui.NextColumn()
        count = count + 1
    end

    ui.Columns( 1 )

    if count > 0 then
        ui.Separator()
    end

    for i, obj in self.location:Contents() do
        panel:AppendTable( ui, obj )
    end

    ui.NewLine()
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 