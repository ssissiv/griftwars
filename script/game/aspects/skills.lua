local Skill = class( "Skill", Aspect )

---------------------------------------------------------------

local Scrounge = class( "Skill.Scrounge", Skill )

---------------------------------------------------------------

local Socialize = class( "Skill.Socialize", Skill )

---------------------------------------------------------------

local RumourMonger = class( "Skill.RumourMonger", Skill )

function RumourMonger:init()
	self.info = {}
end

function RumourMonger:GainInfo( e_info, delta )
	self.info[ e_info ] = (self.info[ e_info ] or 0) + delta
end

function RumourMonger:GetInfo( e_info )
	return (self.info[ e_info ] or 0)
end

function RumourMonger:CopyInfo( other, results )
	local total_exch = 0
	for e_info, value in pairs( self.info ) do
		local delta = value - other:GetInfo( e_info )
		if delta > 0 then
			delta = 1
			other:GainInfo( e_info, delta )

			total_exch = total_exch + delta

			if results then
				table.insert( results, e_info )
				table.insert( results, delta )
			end
		end
	end
	return total_exch
end

function RumourMonger:ExchangeInfo( obj, learned, revealed )
	local other = obj:GetAspect( Skill.RumourMonger )
	local total_exch = 0

	-- Copy our info to obj.
	total_exch = total_exch + self:CopyInfo( other, revealed )

	-- Copy obj info to us.
	total_exch = total_exch + other:CopyInfo( self, learned )

	return total_exch > 0
end

