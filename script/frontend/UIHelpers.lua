local UIHelpers = class( "UIHelpers" )

function UIHelpers.RenderSelectedEntity( ui, screen, ent, viewer )
    assert( ent.GetShortDesc, tostring(ent))
    ui.TextWrapped( tostring(ent:GetShortDesc( viewer )))

    ui.SameLine( 0, 10 )
    if ui.SmallButton( "?" ) then
        if Input.IsControl() then
            DBG( ent )
        else
            viewer.world.nexus:Inspect( viewer, ent )
        end
    end

    if ent.Verbs then
        -- local behaviour = ent:GetAspect( Aspect.Behaviour )
        -- if behaviour then
        --     local verb = behaviour:GetHighestPriorityVerb()
        --     if verb then
        --         ui.SameLine( 0, 10 )
        --         ui.Text( " - " .. verb:GetDesc( viewer ))
        --     end
        -- end
        for i, verb in ent:Verbs() do
            if verb.RenderAgentDetails then
                verb:RenderAgentDetails( ui, screen, viewer )
            end
        end
    end

    -- If has trust, show it.
    if is_instance( ent, Agent ) then
        local aff = ent:GetAffinities()[ viewer ]
        if aff and (aff:GetTrust() > 0 or aff:GetAffinity() ~= AFFINITY.STRANGER) then
            ui.TextColored( 1, 1, 0, 1, "*" )
            ui.SameLine( 0, 10 )
            ui.Text( tostring(aff:GetAffinity() ))
            ui.SameLine( 0, 20 )
            ui.Text( loc.format( "Trust: {1}", aff:GetTrust() ))
        end
    end
end
