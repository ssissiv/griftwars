local DebugUI = class( "DebugUI", DebugNode )

function DebugUI:init( gui )
	self.gui = gui
end

function DebugUI:RenderPanel( ui, panel )
 	ui.Text( string.format( "%d screens", #self.gui.screens ))
    ui.Text( string.format( "Mouse: %d, %d", self.gui.input.mx or 0, self.gui.input.my or 0 ))
    ui.Text( string.format( "Hover: %s", tostring(self.gui.hover_uid )))
    ui.Text( string.format( "Active: %s", tostring(self.gui.active_uid )))

    ui.Text( tostr( self.gui.input.keys_pressed ))
    ui.Text( tostr( self.gui.input.btns ))

    if ui.TreeNode( "Log" ) then
    	for i = #self.gui.log, 1, -1 do
	    	ui.Text( self.gui.log[i] )
	    end
	    ui.TreePop()
	end
end

