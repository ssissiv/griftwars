local VerbMenu = class( "VerbMenu", NexusWindow )

function VerbMenu:init( world )
    self.world = world
end

function VerbMenu:RefreshContents( actor, current_verb, verbs )
    self.actor = actor
    self.current_verb = current_verb
	self.verbs = verbs
    self.shown_verbs = {}
    self.verb_targets = {}
end

function VerbMenu:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	ui.SetNextWindowSize( 400, 150 )
	ui.SetNextWindowPos( (love.graphics.getWidth() - 400) / 2, love.graphics.getHeight() - 150 )

    local shown, close, c = ui.Begin( "Actions", false, flags )
    if shown and self.verbs then
        local tx0, ty0
        if self.current_verb then
            tx0, ty0 = AccessCoordinate( self.current_verb:GetTarget() or self.actor )
        end

        table.clear( self.shown_verbs )
        table.clear( self.verb_targets )

    	for i, verb in self.verbs:Verbs() do
            local tx, ty = AccessCoordinate( verb:GetTarget() or self.actor )
            if tx == tx0 and ty == ty0 then
                -- Track shown verbs for hotkey access.
                table.insert( self.shown_verbs, verb )

                -- Track targets for grouping.
                table.insert_unique( self.verb_targets, verb:GetTarget() or self.actor )
            end
        end

        for i, target in ipairs( self.verb_targets ) do
            local ent
            if is_instance( target, Aspect ) then
                ent = target.owner
            else
                ent = target
            end

            ui.Text( ent:GetShortDesc( self.actor ))
            ui.SameLine( 0, 10 )
            if ui.SmallButton( "?" ) then
                self.world.nexus:Inspect( self.actor, ent )
            end
            ui.Separator()

            for j, verb in ipairs( self.shown_verbs ) do
                if verb:GetTarget() == target then
                    local ok, details = verb:CanDo( self.actor )
                    local txt = loc.format( "{1}] {2}", #self.shown_verbs, verb:GetRoomDesc( self.actor ) )

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
        if verb and verb:CanDo( self.actor ) then
            self.actor:DoVerbAsync( verb )
            return true
        end
    end
end

