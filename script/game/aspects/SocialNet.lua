
local UPDATE_RATE = 0.1 -- period for dialog update ()

local SocialNet = class( "Aspect.SocialNet", Aspect )

function SocialNet:init()
	self.relationships = {} -- Map of Agent -> {}
end

function SocialNet:OnGainAspect( owner )
	Aspect.OnGainAspect( self, owner )
	assert( owner.social == nil )
	owner.social = self
end

function SocialNet:OnLoseAspect()
	Aspect.OnLoseAspect( self )

	assert( self.owner.social == self )
	self.owner.social = nil
end

function SocialNet:CreateRelationship( other )
	assert( other ~= self.owner )
	if self.relationships[ other ] == nil then
		self.relationships[ other ] = {}
		other.social:CreateRelationship( self.owner )
	end

	return self.relationships[ other ]
end

function SocialNet:DeltaOpinion( other, op, delta )
	local t = self.relationships[ other ] or self:CreateRelationship( other )
	local value = (t[ op ] or 0) + delta

	t[ op ] = value
	if t.max_op == nil or value > self:GetOpinionValue( t.max_op ) then
		t.max_op = op
	end

	Msg:Echo( other, OPINION_STRINGS[ op ][1], self.owner )
	Msg:Echo( self.ownerag, OPINION_STRINGS[ op ][2], other )
end

function SocialNet:GetOpinionValue( other, op )
	local t = self.relationships[ other ]
	return t and t[ op ] or 0
end

function SocialNet:GetOpinion( other )
	local t = self.relationships[ other ]
	return t and t.max_op or OPINION.NEUTRAL
end

function SocialNet:IsFriendly( other )
	return self:GetOpinion( other ) == OPINION.LIKE
end

function SocialNet:IsNeutral( other )
	return self:GetOpinion( other ) == OPINION.NEUTRAL
end

function SocialNet:IsUnfriendly( other )
	return self:GetOpinion( other ) == OPINION.DISLIKE
end
