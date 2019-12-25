local Skill = class( "Skill", Aspect )

function Skill:init()
	self:RegisterHandler( AGENT_EVENT.COLLECT_VERBS, self.OnCollectVerbs )
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

function Skill:Clone()
	local clone = setmetatable( table.shallowcopy( self ), self._class )
	clone.owner = nil -- Not transferrable.
	return clone
end

function Skill:GetName()
	return self.name or self._classname
end

---------------------------------------------------------------

local Scrounge = class( "Skill.Scrounge", Skill )

function Scrounge:init()
	self._base.init( self )
	self:AddTrainingReq( Req.MakeFaceReq( DIE_FACE.STEALTH, 1 ))
	self:AddTrainingReq( Req.MakeFaceReq( DIE_FACE.POWER, 1 ))
end

function Scrounge:OnCollectVerbs( event_name, actor, verbs )
	-- if working...
	verbs:AddVerb( Verb.Scrounge( actor ) )
end


---------------------------------------------------------------

local RumourMonger = class( "Skill.RumourMonger", Skill )

function RumourMonger:init()
	self.info = {}
	self:AddTrainingReq( Req.MakeFaceReq( DIE_FACE.STEALTH, 2 ))
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

