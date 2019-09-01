
class( "DialogNode" )

DialogNode.update_rate = 0.1

function DialogNode:init( parent )
	self.parent = parent
	self.visit_count = 0
	self.elapsed_time = 0 -- elapsed_time is wall time
end

function DialogNode:GetName()
	return self.name or self._classname
end

function DialogNode:ActivateNode()
	local parent = self.parent
	while not is_instance( parent, Agent ) do
		parent = parent.parent
	end
	self.owner = parent
	self.world = parent.world
	self.update_ev = self.world:SchedulePeriodicEvent( self.update_rate * WALL_TO_GAME_TIME, self.UpdateDialog, self )

	self.visit_count = self.visit_count + 1
	self.elapsed_time = 0
end

function DialogNode:IsActive()
	return self.update_ev ~= nil
end

function DialogNode:DeactivateNode()
	if self.world then
		self.world:UnscheduleEvent( self.update_ev )
		self.update_ev = nil
		self.owner = nil
		self.world = nil
	end
end

 -- to: DialogNode
 function DialogNode:AddEdge( to )
	if self.edges == nil then
		self.edges = {}
	end

	local edge = DialogEdge( self, to )
	table.insert( self.edges, edge )

	return edge
end

function DialogNode:Edges()
	return ipairs( self.edges )
end

function DialogNode:SetTimer( duration )
	self.timer_duration = duration
end

function DialogNode:IsTimerDone()
	return self.elapsed_time >= self.timer_duration
end

function DialogNode:UpdateDialog()
	local dt = self.update_rate
	self.elapsed_time = self.elapsed_time + dt -- elapsed_time is wall time

	if self.timer_duration and self.elapsed_time >= self.timer_duration and self.elapsed_time - dt < self.timer_duration then
		if self.OnTimeout then
			self:OnTimeout()
		end
	end

	if self.edges then
		for i, edge in ipairs( self.edges ) do
			edge:UpdateDialog( dt )
		end
	end
end

function DialogNode:RenderObject( ui, viewer )
	if self:IsActive() then
		ui.Text( loc.format( "{1} - {2%.1f}", self:GetName(), self.elapsed_time ))

		for i, edge in ipairs( self.edges ) do
			edge:RenderObject( ui, viewer )
		end
	end
end

--------------------------------------------------

local FirstContact = class( "DialogNode.FirstContact", DialogNode )
FirstContact.name = "First Contact"

function FirstContact:init( owner )
	DialogNode.init( self, owner )
	self:AddEdge( DialogNode.Chat( owner ) ):ReqFace( DIE_FACE.DIPLOMACY, 4 )
	self:SetTimer( 2.0 )
end

function FirstContact:ActivateNode()
	FirstContact._base.ActivateNode( self )

	if self.visit_count > 1 then
		Msg:Speak( "I'm not interested in chatting.", self.owner, self.owner:GetFocus() )
		self.owner:SetFocus()
	else
		Msg:Speak( "Hey there, how's it going?", self.owner, self.owner:GetFocus() )
	end
end

function FirstContact:OnTimeout()
	Msg:Speak( "Guess I'll just mind my own business then.", self.owner, self.owner:GetFocus() )
	self.owner:SetFocus( nil )
end

--------------------------------------------------

local Chat = class( "DialogNode.Chat", DialogNode )
Chat.name = "Chat"

function Chat:init( owner )
	DialogNode.init( self, owner )
end



