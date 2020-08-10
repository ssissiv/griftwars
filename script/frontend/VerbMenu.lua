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
    UIHelpers.RenderSelectedEntity( ui, screen, ent, self.actor )
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

        local target_ent
        for i, verb in ipairs( self.shown_verbs ) do
            local ent = AccessEntity( verb:GetTarget() )
            if target_ent ~= ent then
                target_ent = ent
                if ent then
                    self:RenderSelectedEntity( ui, screen, ent )
                end
            end

            UIHelpers.RenderPotentialVerb( ui, verb, i, self.actor )
        end
    end

    ui.End()
end

function VerbMenu:KeyPressed( key, screen )
    if key == "/" then -- and Input.IsShift() then
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
            self.actor:DoVerbAsync( verb )
            return true
        end
    end
end

