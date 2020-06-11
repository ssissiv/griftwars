local Rng = class( "Aspect.Rng", Aspect )

function Rng:init( seed1, seed2 )
	assert( seed1 == nil or type(seed1) == "number" )
	assert( seed2 == nil or type(seed2) == "number" )
	self.seed1, self.seed2 = seed1, seed2
end

function Rng:OnSpawn( world )
	Aspect.OnSpawn( self, world )

	if self.seed1 == nil and self.seed2 == nil then
		-- Get a determinsitic seed from the world.
		self.seed1, self.seed2 = world:Random( 2^32 ), world:Random( 2^32 )
	end

	self:InitRng( self.seed1, self.seed2 )
end

function Rng:InitRng( seed1, seed2 )
	self.rng = love.math.newRandomGenerator( seed1, seed2 )
end

function Rng:RollDice( num, size, bonus )
	for i = 1, num do
		bonus = (bonus or 0) + self:Random( 1, size )
	end
	return bonus
end

function Rng:Random( a, b )
	if a == nil and b == nil then
		return self.rng:random()
	elseif b == nil then
		return self.rng:random( a )
	else
		return self.rng:random( a, b )
	end
end

function Rng:RandomGauss( mean, stddev, min_clamp, max_clamp )
	return math.randomGauss( mean, stddev, min_clamp, max_clamp, function() return self:Random() end )
end

function Rng:ArrayPick( t )
	return t[ self:Random( #t ) ]
end

function Rng:WeightedPick( options )
    local total = 0
    for i = 2, #options, 2 do
        total = total + options[i]
    end
    local rand = self:Random()*total
    
    for i = 1, #options, 2 do
    	local option, wt = options[i], options[i+1]
        rand = rand - wt
        if rand <= 0 then
            return option
        end
    end
    -- assert(option, "weighted random is messed up")
end

function Rng:Shuffle( t, start_index, end_index )
	return table.shuffle( t, start_index, end_index, function(...) return self:Random(...) end )
end

function Rng:GetSeed()
	return self.rng:getSeed()
end

function Rng:__serialize()
	local seed1, seed2 = self:GetSeed()
	return
	{
		_classname = self._classname,
		seed1 = seed1,
		seed2 = seed2,
	}
end

function Rng:PostLoad()
	assert( self.rng == nil )
	self:InitRng( self.seed1, self.seed2 )
end


