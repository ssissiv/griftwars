local UIHelpers = class( "UIHelpers" )

function UIHelpers.RenderSelectedEntity( ui, screen, ent, viewer )
    assert( ent.GetShortDesc, tostring(ent))
    ui.TextWrapped( tostring(ent:GetShortDesc( viewer )))

    if is_instance( ent, Agent ) then
        ui.SameLine( 0, 10 )
        ui.Text( loc.format( "{1} {2}", ent.species, ent.gender ))
    end

    ui.SameLine( 0, 10 )
    if ui.SmallButton( "?" ) then
        if Input.IsModifierDown() then
            DBG( ent )
        else
            viewer.world.nexus:Inspect( viewer, ent )
        end
    end

    ui.SameLine( 0, 5 )
    local marked = viewer:IsMarked( ent, "ui" )
    if marked then
        ui.PushStyleColor( "Button", 0.85, 0.2, 0.2, 1 )
    end
    if ui.SmallButton( "!") then
        if marked then
            viewer:Unmark( ent, "ui" )
        else
            viewer:Mark( ent, "ui" )
        end
    end
    if marked then
        ui.PopStyleColor()
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
            while verb do
                local desc = verb:GetDesc( viewer )
                if desc then
                    ui.Bullet()
                    ui.Text( desc )
                end
                verb = verb.child
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


function UIHelpers.RenderPotentialVerb( ui, verb, i, agent, ... )
    local ok, details = verb:CanDo( agent, ... )

    local desc
    if verb.GetDuration then
        desc = loc.format( "{1} ({2#duration})", verb:GetRoomDesc( agent ), verb:GetDuration() )
    else
        desc = verb:GetRoomDesc( agent )
    end

    local txt = loc.format( "{1}] {2}", i, desc )

    if not ok then
        ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
        details = details or "Can't do."

    else
        if verb.COLOUR then
            ui.PushStyleColor( "Text", Colour4( verb.COLOUR) )
        else
            ui.PushStyleColor( "Text", 1, 1, 0, 1 )
        end

        if ui.Selectable( txt ) then
            agent:DoVerbAsync( verb, ... )
        end

        ui.PopStyleColor()
    end

    if ui.IsItemHovered() and (details or verb.RenderTooltip) then
        ui.BeginTooltip()
        if verb.RenderTooltip then
            verb:RenderTooltip( ui, agent )
        end
        if details then
            ui.TextColored( 1, 1, 0.5, 1, details )
        end
        ui.EndTooltip()
    end
end
