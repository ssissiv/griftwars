local SocialNode = class( "SocialNode" )

function SocialNode:init( agent )
	assert( is_instance( agent, Agent ))
	self.agent = agent
	self.relationships = {} -- Map of Agent -> {}
end

function SocialNode:CreateRelationship( other )
	assert( other ~= self.agent )
	if self.relationships[ other ] == nil then
		self.relationships[ other ] = {}
		other:GetSocialNode():CreateRelationship( self.agent )
	end

	return self.relationships[ other ]
end

function SocialNode:ImproveRelationship( other )
	local t = self.relationships[ other ] or self:CreateRelationship( other )
	if t.opinion == OPINION.UNFRIENDLY then
		t.opinion = OPINION.NEUTRAL
	elseif (t.opinion or OPINION.NEUTRAL) == OPINION.NEUTRAL then
		t.opinion = OPINION.FRIENDLY
	end

	Msg:Echo( other, "{1.name} likes you a little more.", self.agent )
	Msg:Echo( self.agent, "You like {1.name} a little more!", other )
end

function SocialNode:DegradeRelationship( other )
	local t = self.relationships[ other ] or self:CreateRelationship( other )
	if t.opinion == OPINION.FRIENDLY then
		t.opinion = OPINION.NEUTRAL
	elseif (t.opinion or OPINION.NEUTRAL) == OPINION.NEUTRAL then
		t.opinion = OPINION.UNFRIENDLY
	end

	Msg:Echo( other, "{1.name} likes you a little less.", self.agent )
	Msg:Echo( self.agent, "You like {1.name} a little less.", other )
end

function SocialNode:IsFriendly( other )
	local t = self.relationships[ other ]
	return t and t.opinion == OPINION.FRIENDLY
end

function SocialNode:IsNeutral( other )
	local t = self.relationships[ other ]
	return t and t.opinion == OPINION.NEUTRAL
end

function SocialNode:IsUnfriendly( other )
	local t = self.relationships[ other ]
	return t and t.opinion == OPINION.UNFRIENDLY
end


