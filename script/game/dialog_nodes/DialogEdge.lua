require "game/dialog_nodes/DialogBase"

class( "DialogEdge", DialogBase )

function DialogEdge:SetDirectional( from, to )
	self.from = from
	self.to = to
end
