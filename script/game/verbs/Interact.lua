-------------------------------------------------------------------------------------
-- Wraps an interaction with an Aspect.Interaction

local Interact = class( "Verb.Interact", Verb )

function Interact:init( actor, aspect )
	assert( is_instance( aspect, Aspect.Interaction ))
	Verb.init( self, actor )
	self.interaction = aspect
end

function Interact:EqualVerb( verb )
	return is_instance( verb, Interact ) and self.actor == verb.actor and self.interaction == verb.interaction
end

function Interact:GetTarget()
	return self.interaction.owner
end

function Interact:GetDesc( viewer )
	return self.interaction:GetDesc( viewer )
end

function Interact:RenderTooltip( ui, viewer )
	self.interaction:RenderTooltip( ui, viewer )
end

function Interact:CanInteract()
	local ok, reason = self.interaction:CanInteract( self.actor )
	if not ok then
		return false, reason
	end

	return Verb.CanInteract( self )
end

function Interact:Interact()
	self.interaction:Interact( self.actor )
end

function Interact:__tostring()
	return string.format( "[Interact: %s]", tostring(self.interaction))
end
