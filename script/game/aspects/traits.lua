local Trait = class( "Trait", Aspect )

---------------------------------------------------------------

local Cowardly = class( "Trait.Cowardly", Aspect )

---------------------------------------------------------------

local Poor = class( "Trait.Poor", Aspect )

---------------------------------------------------------------

local Memory = class( "Trait.Memory", Aspect )

function Memory:init()
	self.engram = {}
end

function Memory:AddEngram( engram )
	table.insert( self.engrams, engram )
end

function Memory:Engrams()
	return pairs( self.engrams )
end

function Memory:CheckPrivacy( target, flag )
	local pr_flags = 0
	for i, engram in ipairs( self.engrams ) do
		if engram.pr_flags and target:MatchTarget( engram.target ) then
			pr_flags = SetBits( pr_flags, engram.pr_flags )
		end
	end

	if flag then
		return CheckBits( pr_flags, flag )
	else
		return pr_flags
	end
end
