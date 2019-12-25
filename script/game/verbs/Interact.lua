-------------------------------------------------------------------------------------
-- Wraps an interaction with an Aspect.Interaction

local Interact = class( "Verb.Interact", Verb )

function Interact:init( actor, aspect )
	assert( is_instance( aspect, Aspect.Interaction ))
	Verb.init( self, actor, actor:GetFocus() )
	self.interaction = aspect
end

function Interact:GetDesc()
	return tostring(self.interaction)
end

function Interact:RenderTooltip( ui, viewer )
	self.interaction:RenderTooltip( ui, viewer )
end

function Interact.CollectVerbs( verbs, actor, obj )
	local focus = actor:GetFocus()
	if focus and focus == obj then
		for i, aspect in focus:Aspects() do
			if is_instance( aspect, Aspect.Interaction ) then
				local ok, reason = true
				if aspect.CanInteract then
					ok, reason = aspect:CanInteract( actor )
				end
				if ok or reason then
					verbs:AddVerb( Verb.Interact( actor, aspect ))
				end
			end
		end
	end
end

function Interact:CanInteract( actor, ... )
	local ok, reason = self.interaction:CanInteract( actor )
	if not ok then
		return false, reason
	end

	return Verb.CanInteract( self, actor, ... )
end

function Interact:Interact( actor )
	self.interaction:SatisfyReqs( actor )
	self.interaction:Interact( actor )
end

function Interact:__tostring()
	return string.format( "Interact: %s", tostring(self.interaction))
end
