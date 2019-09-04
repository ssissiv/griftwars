
local UPDATE_RATE = 0.1 -- period for dialog update ()

local SocialNode = class( "SocialNode" )

function SocialNode:init( agent )
	assert( is_instance( agent, Agent ))
	self.agent = agent
	self.relationships = {} -- Map of Agent -> {}
end

function SocialNode:BeginDialog()
	if self.dialog_root == nil then
		self.dialog_root = Personality.MakeSimpleton( self.agent )
		self.dialog_root:ActivateNode()
	end

	assert( self.update_ev == nil )
	self.update_ev = self.agent.world:SchedulePeriodicFunction( UPDATE_RATE * WALL_TO_GAME_TIME, self.UpdateDialog, self )
end

function SocialNode:EndDialog()
	if self.update_ev then
		self.agent.world:UnscheduleEvent( self.update_ev )
		self.update_ev = nil
	end
end

function SocialNode:AddActivatedNode( node )
	if self.active_dialog == nil then
		self.active_dialog = {}
	end
	assert( not table.contains( self.active_dialog, node ))
	table.insert( self.active_dialog, node )
end

function SocialNode:RemoveActivatedNode( node )
	table.arrayremove( self.active_dialog, node )
end

function SocialNode:CreateRelationship( other )
	assert( other ~= self.agent )
	if self.relationships[ other ] == nil then
		self.relationships[ other ] = {}
		other:GetSocialNode():CreateRelationship( self.agent )
	end

	return self.relationships[ other ]
end

function SocialNode:DeltaOpinion( other, op, delta )
	local t = self.relationships[ other ] or self:CreateRelationship( other )
	local value = (t[ op ] or 0) + delta

	t[ op ] = value
	if t.max_op == nil or value > self:GetOpinionValue( t.max_op ) then
		t.max_op = op
	end

	Msg:Echo( other, OPINION_STRINGS[ op ][1], self.agent )
	Msg:Echo( self.agent, OPINION_STRINGS[ op ][2], other )
end

function SocialNode:GetOpinionValue( other, op )
	local t = self.relationships[ other ]
	return t and t[ op ] or 0
end

function SocialNode:GetOpinion( other )
	local t = self.relationships[ other ]
	return t and t.max_op or OPINION.NEUTRAL
end

function SocialNode:IsFriendly( other )
	return self:GetOpinion( other ) == OPINION.LIKE
end

function SocialNode:IsNeutral( other )
	return self:GetOpinion( other ) == OPINION.NEUTRAL
end

function SocialNode:IsUnfriendly( other )
	return self:GetOpinion( other ) == OPINION.DISLIKE
end

function SocialNode:UpdateDialog()
	for i, node in ipairs( self.active_dialog ) do
		node:UpdateDialog( UPDATE_RATE )
	end
end

function SocialNode:RenderObject( ui, viewer )
	for i, node in ipairs( self.active_dialog or table.empty ) do
		node:RenderObject( ui, viewer )
	end
end


