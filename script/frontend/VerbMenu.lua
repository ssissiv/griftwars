local VerbMenu = class( "VerbMenu", NexusWindow )

function VerbMenu:init( world )
    self.world = world
    self.shown_verbs = {}
end

function VerbMenu:RefreshContents( actor, focus )
    self.actor = actor
    self.focus = focus
    table.clear( self.shown_verbs )

    if focus then
        self.actor:RegenVerbs()
        local verbs = self.actor:GetPotentialVerbs( nil, focus )            
        for j, verb in verbs:Verbs() do
            table.insert( self.shown_verbs, verb )
        end
    end
end

function VerbMenu:IsEmpty()
    return self.focus == nil --#self.shown_verbs == 0
end

function VerbMenu:RenderSelectedEntity( ui, screen, ent )
    assert( ent.GetShortDesc, tostring(ent))
    ui.Text( tostring(ent:GetShortDesc( self.actor )))

    local behaviour = ent:GetAspect( Aspect.Behaviour )
    if behaviour then
        local verb = behaviour:GetHighestPriorityVerb()
        if verb then
            ui.SameLine( 0, 10 )
            ui.Text( " - " .. verb:GetDesc( self.actor ))
        end
    end

    ui.SameLine( 0, 10 )
    if ui.SmallButton( "?" ) then
        self.world.nexus:Inspect( self.actor, ent )
    end

    -- If has trust, show it.
    if is_instance( ent, Agent ) then
        local aff = ent:GetAffinities()[ self.actor ]
        if aff and aff:GetTrust() > 0 then
            ui.Text( loc.format( "Affinity: {1}", aff:GetAffinity() ))
            ui.SameLine( 0, 20 )
            ui.Text( loc.format( "Trust: {1}", aff:GetTrust() ))
        end
    end
    ui.Separator()
end

function VerbMenu:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 400, 150 )
	ui.SetNextWindowPos( (love.graphics.getWidth() - 400) / 2, love.graphics.getHeight() - 150 )

    local shown, close, c = ui.Begin( "Actions", false, flags )
    if shown and self.focus then
        if #self.shown_verbs == 0 then
            local ent = AccessEntity( self.focus )
            if ent then
                self:RenderSelectedEntity( ui, screen, ent )
            end
        end

        local target
        for i, verb in ipairs( self.shown_verbs ) do
            if target ~= verb:GetTarget() then
                target = verb:GetTarget()
                
                local ent = AccessEntity( target )
                if ent then
                    self:RenderSelectedEntity( ui, screen, ent )
                end
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

                local dc, details = verb:CalculateDC( self.actor, verb:GetTarget() )
                if dc ~= nil then
                    ui.Indent( 20 )
                    ui.Text( loc.format( "DC: {1}", tostring(dc) ))
                    if ui.IsItemHovered() and details then
                        ui.SetTooltip( tostring(details) )
                    end
                    ui.Unindent( 20 )
                end

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
        for i, verb in ipairs( self.shown_verbs ) do
            local ent = AccessEntity( verb:GetTarget() )
            if ent then
                self.world.nexus:Inspect( self.actor, ent )
            end
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

