local ObjectDetailsWindow = class( "ObjectDetailsWindow" )

function ObjectDetailsWindow:init( viewer, obj )
	assert( is_instance( obj, Object ))
	self.viewer = viewer
	self.obj = obj
end

function ObjectDetailsWindow:RenderImGuiWindow( ui, screen )
    local flags = { "AlwaysAutoResize", "NoScrollBar" }
	local txt = self.obj:GetName()
    local shown, close, c = ui.Begin( txt, false, flags )
    if shown then
    	ui.Text( txt )
    	ui.Dummy( 300, 00 )
    	ui.Text( loc.format( "Value: {1}", self.obj:GetValue() ))

    	ui.NewLine()
    	ui.Separator()

		if ui.Button( "Close" ) then
			screen:RemoveWindow( self )
		end
	end

    ui.End()
end
