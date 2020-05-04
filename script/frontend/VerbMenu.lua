local VerbMenu = class( "VerbMenu", NexusWindow )

function VerbMenu:init( world )
    self.world = world
end

function VerbMenu:RefreshContents( actor, focus )
    self.actor = actor
    self.focus = focus
    self.shown_verbs = {}


    for i, obj in self.focus:Contents() do
        self.actor:RegenVerbs()
        local verbs = self.actor:GetPotentialVerbs( nil, obj )            
        for j, verb in verbs:Verbs() do
            table.insert( self.shown_verbs, verb )
        end
    end
end

function VerbMenu:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 400, 150 )
	ui.SetNextWindowPos( (love.graphics.getWidth() - 400) / 2, love.graphics.getHeight() - 150 )

    local shown, close, c = ui.Begin( "Actions", false, flags )
    if shown and self.focus then
        local tx0, ty0 = AccessCoordinate( self.focus )
        local target

        for i, verb in ipairs( self.shown_verbs ) do
            if target ~= verb:GetTarget() then
                target = verb:GetTarget()
                
                local ent = AccessEntity( target )

                ui.Text( ent:GetShortDesc( self.actor ))
                ui.SameLine( 0, 10 )
                if ui.SmallButton( "?" ) then
                    self.world.nexus:Inspect( self.actor, ent )
                end
                ui.Separator()
            end

            local ok, details = verb:CanDo( self.actor, verb:GetTarget() )
            local txt = loc.format( "{1}] {2}", i, verb:GetRoomDesc( self.actor ) )

            if not ok then
                ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
                details = details or "Can't do."

            else
                if verb.COLOUR then
                    ui.PushStyleColor( "Text", Colour4( verb.COLOUR) )
                else
                    ui.PushStyleColor( "Text", 1, 1, 0, 1 )
                end

        		ui.Text( txt )

                ui.PopStyleColor()
            end

            if details or verb.RenderTooltip then
                ui.Indent( 20 )
                if verb.RenderTooltip then
                    verb:RenderTooltip( ui, verb.actor )
                end
                if details then
                    ui.TextColored( 1, 0, 0, 1, details )
                end
                ui.Unindent( 20 )
            end
        end
    end

    ui.End()
end

function VerbMenu:KeyPressed( key, screen )
    if key == "/" and Input.IsShift() then
        for i, target in ipairs( self.verb_targets ) do
            self.world.nexus:Inspect( self.actor, target )
            return true
        end

    else
        local idx = tonumber(key)
        local verb = self.shown_verbs[ idx ]
        if verb then
            self.actor:DoVerbAsync( verb, verb:GetTarget() )
            return true
        end
    end
end

