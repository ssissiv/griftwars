local Req = class( "Req" )

function Req:__tostring()
	return self._classname
end

function Req:GetDesc( viewer )
	return self._classname
end

----------------------------------------------------

local FaceReq = class( "Req.Face", Req )

function FaceReq:init( face, max_count )
	self.face = face
	self.max_count = max_count
end

function FaceReq:IsSatisfied( viewer )
	local tokens = viewer:GetAspect( Aspect.TokenHolder )
	local count = tokens and tokens:GetFaceCount( self.face )
	if count and count < self.max_count then
		return false, loc.format( "Requires {1} (x{2}) (have {3})", tostring(self.face), self.max_count, count )
	end

	return true
end


----------------------------------------------------

local TrustReq = class( "Req.Trust", Req )

function TrustReq:init( agent, trust )
	assert( trust > 0 )
	self.agent = agent
	self.trust = trust
end

function TrustReq:GetDesc( viewer )
	return loc.format( "Requires {1} Trust (have {2})", self.trust, self.agent:GetTrust( viewer ))
end

function TrustReq:IsSatisfied( viewer )
	local trust = self.agent:GetTrust( viewer )
	if trust < self.trust then
		return false, loc.format( "Not enough trust ({1}/{2})", trust, self.trust )
	end

	return true
end

----------------------------------------------------

local NotAcquaintedReq = class( "Req.NotAcquainted", Req )

function NotAcquaintedReq:init( agent )
	self.agent = agent
end

function NotAcquaintedReq:IsSatisfied( viewer )
	return not self.agent:IsAcquainted( viewer )
end

----------------------------------------------------

local AcquaintedReq = class( "Req.Acquainted", Req )

function AcquaintedReq:init( agent )
	self.agent = agent
end

function AcquaintedReq:IsSatisfied( viewer )
	return self.agent:IsAcquainted( viewer )
end

----------------------------------------------------

local StatReq = class( "Req.Stat", Req )

function StatReq:init( stat, value )
	self.stat = stat
	self.value = value
end

function StatReq:GetDesc( viewer )
	return loc.format( "Requires {1} {2} (have {3})", self.value, self.stat, viewer:GetStatValue( self.stat ))
end


function StatReq:IsSatisfied( viewer )
	local value = viewer:CalculateStat( self.stat )
	if value < self.value then
		return false, loc.format( "Not enough {1} ({2}/{3})", self.stat, value, self.value )
	end

	return true
end

