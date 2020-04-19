local VerbMenu = class( "VerbMenu", NexusWindow )

function VerbMenu:RefreshContents( actor, current_verb, verbs )
    self.actor = actor
    self.current_verb = current_verb
	self.verbs = verbs
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

    	for i, verb in self.verbs:Verbs() do
            local tx, ty = AccessCoordinate( verb:GetTarget() or verb:GetActor() or self.verbs.actor )
            if tx == tx0 and ty == ty0 then
                assert( self.verbs.actor )
                local ok, details = verb:CanDo( self.verbs.actor )
                local txt = loc.format( "{1}] {2}", i, verb:GetRoomDesc() )
                if verb == self.current_verb then
                    txt = "> "..txt
                end

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

    ui.End()
end

