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
		ui.Selectable( tostring(obj) )
	end

    ui.End()
end
