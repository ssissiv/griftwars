local Req = class( "Req" )

function Req:__tostring()
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

function TrustReq:init( trust )
	assert( trust > 0 )
	self.trust = trust
end

function TrustReq:IsSatisfied( viewer )
	local aff = viewer:GetAspect( Relationship.Affinity )
	if aff == nil or aff:GetTrust() < self.trust then
		return false, loc.format( "Not enough trust ({1}/{2})", aff and aff:GetTrust() or 0, self.trust )
	end

	return true
end



----------------------------------------------------

local StatReq = class( "Req.Stat", Req )

function StatReq:init( stat, value )
	assert( IsEnum( stat, STAT ))
	self.stat = stat
	self.value = value
end

function StatReq:IsSatisfied( viewer )
	local value = viewer:GetStatValue( self.stat )
	if value < self.value then
		return false, loc.format( "Not enough {1} ({2}/{3})", self.stat, value, self.value )
	end

	return true
end

