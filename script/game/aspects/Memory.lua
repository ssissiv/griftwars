
local Memory = class( "Aspect.Memory", Aspect )

function Memory:init()
	self.engrams = {}
end

function Memory:OnGainAspect( owner )
	Aspect.OnGainAspect( self, owner )
	assert( owner.memory == nil )
	owner.memory = self
end

function Memory:OnLoseAspect()
	Aspect.OnLoseAspect( self )

	assert( self.owner.memory == self )
	self.owner.memory = nil
end

function Memory:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	for i, engram in ipairs( self.engrams ) do
		engram:StampTime( self.owner )
	end

	self:SchedulePeriodicFunction( ONE_DAY, ONE_DAY, self.RefreshEngrams )
end

function Memory:RefreshEngrams()
	for i = #self.engrams, 1, -1 do
		local engram = self.engrams[ i ]
		local duration = engram:GetDuration()
		if duration and duration < engram:GetAge( self.owner ) then
			table.remove( self.engrams, i )
		end
	end
end

function Memory:AddEngram( engram )
	engram:StampTime( self.owner )

	for i, v in ipairs( self.engrams ) do
		if v:MergeEngram( engram ) then
			return
		end
	end

	table.insert( self.engrams, engram )
end

function Memory:RemoveEngram( engram )
	table.arrayremove( self.engrams, engram )
end

function Memory:Engrams()
	return pairs( self.engrams )
end

function Memory:HasEngram( pred, ... )
	return self:FindEngram( pred, ... ) ~= nil
end

function Memory:FindEngram( pred, ... )
	for i, engram in ipairs( self.engrams ) do
		if pred( engram, ... ) then
			return engram
		end
	end
end

function Memory:CountEngrams( pred, ... )
	local count = 0
	for i, engram in ipairs( self.engrams ) do
		if pred( engram, ... ) then
			count = count + 1
		end
	end
	return count
end

function Memory:FindEngramAge( pred, ... )
	local engram = self:FindEngram( pred, ... )
	if engram then
		return engram:GetAge( self.owner )
	end
end

function Memory:CheckPrivacy( target, flag )
	local pr_flags = 0
	for i, engram in ipairs( self.engrams ) do
		if engram.CheckPrivacy then
			pr_flags = engram:CheckPrivacy( target, pr_flags )
		end
	end

	if flag then
		return CheckBits( pr_flags, flag )
	else
		return pr_flags
	end
end

