local VerbMenu = class( "VerbMenu", NexusWindow )

function VerbMenu:RefreshContents( current_verb, verbs )
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
            tx0, ty0 = AccessCoordinate( self.current_verb:GetTarget() or self.current_verb:GetActor() )
        end

    	for i, verb in self.verbs:Verbs() do
            assert(verb:GetTarget() or verb:GetActor(), tostring(verb))
            local tx, ty = AccessCoordinate( verb:GetTarget() or verb:GetActor() )
            if tx == tx0 and ty == ty0 then

                local ok, details = verb:CanDo()
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

                if ui.IsItemHovered() and (details or verb.RenderTooltip) then
                    ui.BeginTooltip()
                    if verb.RenderTooltip then
                        verb:RenderTooltip( ui, verb.actor )
                    end
                    if details then
                        ui.TextColored( 1, 1, 0.5, 1, details )
                    end
                    ui.EndTooltip()
                end
            end
    	end
    end

    ui.End()
end

