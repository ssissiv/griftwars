local function GetObjectDesc( obj )
    local txt
    local wearable = obj:GetAspect( Aspect.Wearable )
    if wearable and wearable:IsEquipped() then
        local slot = wearable:GetEqSlot()
        txt = loc.format( "{1} <{2}>", obj:GetName(), EQ_SLOT_NAMES[ slot ] )
    else
        txt = obj:GetName()
    end
    return txt
end

------------------------------------------------------

local InventoryWindow = class( "InventoryWindow" )

function InventoryWindow:init( world, viewer, agent )
	assert( agent )
    self.world = world
	self.viewer = viewer
	self.agent = agent
end

function InventoryWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

	ui.SetNextWindowSize( 400,300 )

    ui.Begin( "Inventory", false, flags )

    local rumours = self.agent:GetAspect( Skill.RumourMonger )
    if rumours and ui.TreeNodeEx( "Knowledge", "DefaultOpen" ) then
    	for e_info, count in rumours:Info() do
    		local txt = loc.format( "{1}: {2}", e_info, count )
    		if ui.Button( txt ) then
    		end
    	end

		ui.TreePop()
	end

	for i, obj in self.agent:GetInventory():Items() do 
        local txt = GetObjectDesc( obj )

		if ui.Selectable( txt, self.selected_obj == obj ) then
            self.selected_obj = obj
            self.viewer:RegenVerbs( "object" )
        end
        if self.selected_obj == obj then
            ui.SameLine( 0, 10 )
            if ui.SmallButton( "?" ) then
                self.world:GetNexus():Inspect( self.viewer, obj )
            end
            screen:RenderPotentialVerbs( ui, self.viewer, "object", obj )
            self.shown_verbs = self.viewer:GetPotentialVerbs( "object", obj )
        end
	end

    ui.End()
end

function InventoryWindow:SelectObject( obj )
    self.selected_obj = obj
    self.viewer:RegenVerbs( "object" )
end

function InventoryWindow:KeyPressed( key, screen )
    if key == "/" and Input.IsShift() then
        if self.selected_obj then
            self.world.nexus:Inspect( self.viewer, self.selected_obj )
            return true
        end

    elseif key == "tab" then
        local items = self.viewer:GetInventory():GetItems()
        local idx = table.arrayfind( items, self.selected_obj ) or 0
        self:SelectObject( items[ (idx % #items) + 1 ] )
        return true

    elseif key == "up" then
        local items = self.viewer:GetInventory():GetItems()
        local idx = table.arrayfind( items, self.selected_obj ) or 0
        self:SelectObject( items[ math.max( 1, idx - 1 ) ])
        return true

    elseif key == "down" then
        local items = self.viewer:GetInventory():GetItems()
        local idx = table.arrayfind( items, self.selected_obj ) or 0
        self:SelectObject( items[ math.min( #items, idx + 1 ) ])
        return true

    elseif key == "left" or key == "right" then
        return true

    elseif self.shown_verbs then
        local idx = tonumber(key)
        local verb = self.shown_verbs:VerbAt( idx )
        if verb then
            self.viewer:DoVerbAsync( verb, self.selected_obj )
            return true
        end
    end
end


