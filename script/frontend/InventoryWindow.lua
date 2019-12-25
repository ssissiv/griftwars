local InventoryWindow = class( "InventoryWindow" )

function InventoryWindow:init( viewer, agent )
	assert( agent )
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
        local txt
        if obj:IsEquipped() then
            txt = loc.format( "[E] {1}", obj:GetName() )
        else
            txt = obj:GetName()
        end

		if ui.Selectable( txt, self.selected_obj == obj ) then
            self.selected_obj = obj
            self.viewer:RegenVerbs( "object" )
        end
        if self.selected_obj == obj then
            screen:RenderPotentialVerbs( ui, self.viewer, "object", obj )
        end
	end

    ui.End()
end
