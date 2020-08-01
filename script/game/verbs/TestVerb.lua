local TestVerb = class ("Verb.Test", Verb )

function TestVerb:CalculateUtility()
	return 100
end

function TestVerb:Interact( actor )
	print( loc.format( "It is {1#time}", actor.world:GetDateTime() ))
	-- self:YieldForTime( ONE_SECOND )
	error( "Oh..." )
	
end
