local Engram = class( "Engram" )

function Engram:init()
end

function Engram:MakeLocalNews()
	-- Find piece of info to reveal about a public agent in the region.

end

function Engram.MakeKnown( pr_flags, target )
	local engram = Engram()
	engram.pr_flags = pr_flags
	engrma.target = target
	return engram
end
