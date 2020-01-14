

local Memory = class( "Trait.Memory", Trait )

function Memory:init()
	self.engrams = {}
end

function Memory:OnGainAspect( owner )
	Trait.OnGainAspect( self, owner )
	assert( owner.memory == nil )
	owner.memory = self
end

function Memory:OnLoseAspect()
	Trait.OnLoseAspect( self )

	assert( self.owner.memory == self )
	self.owner.memory = nil
end

function Memory:OnSpawn( world )
	Trait.OnSpawn( self, world )
	for i, engram in ipairs( self.engrams ) do
		engram:StampTime( self.owner )
	end
end

function Memory:AddEngram( engram )
	engram:StampTime( self.owner )
	table.insert( self.engrams, engram )
end

function Memory:Engrams()
	return pairs( self.engrams )
end

function Memory:HasEngram( pred )
	for i, engram in ipairs( self.engrams ) do
		if pred( engram ) then
			return true
		end
	end
end

function Memory:CheckPrivacy( target, flag )
	local pr_flags = 0
	for i, engram in ipairs( self.engrams ) do
		if engram.pr_flags and target == engram.obj then
			pr_flags = SetBits( pr_flags, engram.pr_flags )
		end
	end

	if flag then
		return CheckBits( pr_flags, flag )
	else
		return pr_flags
	end
end

