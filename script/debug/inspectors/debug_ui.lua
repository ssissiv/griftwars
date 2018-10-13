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

	if ui.TreeNode( "Layout Trace" ) then
		for i = 1, #self.gui.layout_trace do
			local bb = self.gui.layout_trace[i]
			if ui.Selectable( string.format( "%d) %.1f, %.1f, %.1f, %.1f", i, bb.xmin, bb.ymin, bb.xmax, bb.ymax ), self.gui.debug_trace == i ) then
				self.gui.debug_trace = i
			end
			-- if self.gui.debug_trace == i then
			-- 	ui.Indent( 20 )
			-- 	local xs = self:SearchXs( bb.ymin, bb.ymax )
			-- 	ui.Text( tostr(xs) )
			-- 	ui.Unindent( 20 )
			-- end
		end
		ui.TreePop()
	end

	for i, batch in ipairs( self.gui.render_batches ) do
		if ui.TreeNode( string.format( "Render Batch %d", i )) then
			for i, v in ipairs( batch ) do
				ui.Text( tostring(v) )
			end
			ui.TreePop()
		end
	end

	local bb = self.gui.layout_trace[ self.gui.debug_trace ]
	if bb then
		love.graphics.setColor( 0, 255, 0 )
		local x, y = bb.xmin + 1, bb.ymin + 1
		local w, h = bb.xmax - bb.xmin - 2, bb.ymax - bb.ymin - 2
		love.graphics.rectangle( "line", x, y, w, h )
	end
end

