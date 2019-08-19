require "game/dialog_nodes/DialogBase"


class( "DialogNode", DialogBase )


function DialogNode:AddEdge( edge )
	if self.edges == nil then
		self.edges = {}
	end

	table.insert( self.edges, edge )
end


function DialogNode:AddDirectionalEdge( to, edge )
	edge:SetDirectional( self, to )
	self:AddEdge( edge )
end

function DialogNode:UpdateNode( tick, dt )
	if not self:UpdateBase( tick, dt ) then
		return false
	end
	
	if self.edges then
		for i, edge in ipairs( self.edges ) do
			edge:UpdateNode( dt )
		end
	end
end
