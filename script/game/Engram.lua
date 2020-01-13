local Engram = class( "Engram" )

function Engram:init()
end

function Engram:MakeLocalNews()
	-- Find piece of info to reveal about a public agent in the region.

end


-- You "know" the specific flags about 'agent'.
function Engram.MakeKnown( agent, pr_flags )
	assert( is_instance( agent, Agent ))
	local engram = Engram()
	engram.pr_flags = pr_flags
	engram.obj = agent
	return engram
end

-- You've "unfriended" them, preventing further associations.
function Engram.Unfriend( agent )
	assert( is_instance( agent, Agent ))
	local engram = Engram()
	engram.obj = agent
	engram.unfriend = true
	return engram
end

function Engram.IsUnfriended( engram )
	return engram.unfriend == true
end

