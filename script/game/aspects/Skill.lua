local Skill = class( "Aspect.Skill", Aspect.StatValue )

function Skill:SetSkillRank( rank )
	self:SetValue( rank )
	return self
end

function Skill:GetSkillRank()
	return self:GetValue()
end

function Skill:TrainingReqs()
	return pairs( self.training_reqs or table.empty )
end

function Skill:AddTrainingReq( req )
	if self.training_reqs == nil then
		self.training_reqs = {}
	end
	table.insert( self.training_reqs, req )
end

function Skill:CanLearn( actor )
	if self == nil then
		return true

	else
		for i, req in ipairs( self.training_reqs ) do
			local ok, reason = req:IsSatisfied( actor )
			if not ok then
				return false, reason
			end
		end
	end

	return true
end

function Skill:Clone()
	local clone = setmetatable( table.shallowcopy( self ), self._class )
	clone.owner = nil -- Not transferrable.
	return clone
end

function Skill:RenderAgentDetails( ui, screen, viewer )
	ui.Text( loc.format( "{1} (Rank {2}) -- XP: {3}", self:GetName(), self:GetValue(), self:GetGrowth() ))
end

function Skill:GetName()
	return self.name or self._classname
end

---------------------------------------------------------------

local RumourMonger = class( "Skill.RumourMonger", Skill )

function RumourMonger:init()
	self.info = {}
	self:AddTrainingReq( Req.Face( DIE_FACE.STEALTH, 2 ))
end

function RumourMonger:GainInfo( e_info, delta )
	self.info[ e_info ] = (self.info[ e_info ] or 0) + delta
end

function RumourMonger:Info()
	return pairs( self.info )
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

