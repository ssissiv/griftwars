
class( "DialogNode" )

function DialogNode:init( parent )
	self.parent = parent
	self.visit_count = 0
	self.elapsed_time = 0 -- elapsed_time is wall time
	self.face_count = {} -- map of DIE_FACE -> count (tracks how many rolls have been submitted)
	self.edges = {}
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

	self.visit_count = self.visit_count + 1
	self.activate_time = self.world:GetDateTime()
	self.elapsed_time = 0

	self.owner:GetSocialNode():AddActivatedNode( self )
end

function DialogNode:IsActive()
	return self.world ~= nil
end

function DialogNode:DeactivateNode()
	if self.world then
		self.owner:GetSocialNode():RemoveActivatedNode( self )
		self.owner = nil
		self.world = nil
	end
end

 -- to: DialogNode
 function DialogNode:AddEdge( to )
	local edge = DialogEdge( self, to )
	table.insert( self.edges, edge )

	return edge
end

function DialogNode:Edges()
	return ipairs( self.edges )
end

function DialogNode:GetFaceCount( face )
	return self.face_count[ face ] or 0
end

function DialogNode:ModifyFaceCount( face, delta )
	self.face_count[ face ] = (self.face_count[ face ] or 0) + delta
end

function DialogNode:SetTimer( duration )
	self.timer_duration = duration
end

function DialogNode:IsTimerDone()
	return self.elapsed_time >= self.timer_duration
end

function DialogNode:UpdateDialog( dt )
	self.elapsed_time = self.elapsed_time + dt

	if self.timer_duration and self.elapsed_time >= self.timer_duration and self.elapsed_time - dt < self.timer_duration then
		if self.OnTimeout then
			self:OnTimeout()
		end
	end
end

function DialogNode:RenderObject( ui, viewer )
	if not self:IsActive() then
		ui.TextColored( 0.5, 0.5, 0.5, 1, "INACTIVE" )
	end

	if self.timer_duration then
		local p = math.max( 0, self.timer_duration - self.elapsed_time ) / self.timer_duration
		ui.Text( loc.format( "{1} - {2#percent}", self:GetName(), p ))
	else
		ui.Text( loc.format( "{1}", self:GetName() ))
	end

	ui.Indent( 10 )
	for face, count in pairs( self.face_count ) do
		ui.Text( loc.format( "{1} - {2}", face, count ))
	end
	ui.Unindent( 10 )

	for i, edge in ipairs( self.edges ) do
		edge:RenderObject( ui, viewer )
	end

	local dice = {}
	local player = viewer:GetPlayer()
	if player then
		for i, edge in ipairs( self.edges ) do
			for j, req in edge:Reqs() do
				if req.face then
					player:CollectDiceWithFace( req.face, dice )
				end
			end
		end

		for i, die in ipairs( dice ) do
			if die:CanRoll() then
				die:RenderObject( ui, viewer )

				local roll = die:GetRoll()
				if roll and roll ~= DIE_FACE.NULL then
					self:ModifyFaceCount( roll, 1 )
				end
			end
		end
	end
end

--------------------------------------------------

local FirstContact = class( "DialogNode.FirstContact", DialogNode )
FirstContact.name = "First Contact"

function FirstContact:init( owner )
	DialogNode.init( self, owner )
	self:AddEdge( DialogNode.Chat( owner ) ):ReqFace( DIE_FACE.DIPLOMACY, 1 )
	self:SetTimer( 10.0 )
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



