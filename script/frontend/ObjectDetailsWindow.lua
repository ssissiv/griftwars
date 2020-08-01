local ObjectDetailsWindow = class( "ObjectDetailsWindow" )

function ObjectDetailsWindow:init( viewer, obj )
	assert( is_instance( obj, Object ))
	self.viewer = viewer
	self.obj = obj
end

function ObjectDetailsWindow:Refresh( obj )
    self.obj = obj
end

function ObjectDetailsWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	local txt = self.obj:GetName()
    local visible, show = ui.Begin( txt, true, flags )
    if visible and show then
    	ui.Text( txt )
    	ui.Dummy( 300, 00 )
    	ui.Text( loc.format( "Value: {1}", self.obj:GetValue() ))

    	ui.NewLine()
    	ui.Separator()

        for i, aspect in self.obj:Aspects() do
            if aspect.RenderDetailsUI then
                aspect:RenderDetailsUI( ui, screen )
            end
        end

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
        
    elseif not show then
        screen:RemoveWindow( self )
	end

    ui.End()
end

function ObjectDetailsWindow:KeyPressed( key, screen )
    if key == "return" or key == "escape" then
        screen:RemoveWindow( self )
        return true
    end
end

