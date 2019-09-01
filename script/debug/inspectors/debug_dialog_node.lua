local DebugDialogNode = class( "DebugDialogNode", DebugTable )
DebugDialogNode.REGISTERED_CLASS = DialogNode

function DebugDialogNode:init( node )
	DebugTable.init( self, node )
    self.node = node
end

function DebugDialogNode:RenderPanel( ui, panel, dbg )
	if ui.TreeNode( "Edges" ) then
		for i, edge in ipairs( node.edges or table.empty ) do
			panel:AppendTable( ui, edge )
		end
		ui.TreePop()
	end
    
    DebugTable.RenderPanel( self, ui, panel, dbg )
end

 