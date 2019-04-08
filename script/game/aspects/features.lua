local Feature = class( "Feature", Aspect )

function Feature:OnGainAspect( obj )
	assert( is_instance( obj, Location ))
	self.location = obj
end

---------------------------------------------------------------

local Portal = class( "Feature.Portal", Feature )

function Portal:init( dest_location )
	self.dest_location = dest_location
end

function Portal:CollectInteractions( actor, obj, verbs )
	if actor:GetLocation() == self.location and obj == nil then
		if verbs then
			table.insert( verbs, self:CreateVerb( Verb.UsePortal, actor, self.dest_location ))
		end
		return true
	end
end
