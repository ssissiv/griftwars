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
            local tx, ty = AccessCoordinate( verb:GetTarget() or verb:GetActor() )
            if tx == tx0 and ty == ty0 then
                local txt = tostring(verb)
                if verb == self.current_verb then
                    ui.TextColored( 255, 255, 0, 255, "> "..txt )
                else
            		ui.Text( txt )
                end
            end
    	end
    end

    ui.End()
end
