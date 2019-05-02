local Aspect = class( "Aspect" )


function Aspect:GetID()
	return self._classname
end

function Aspect:OnGainAspect( obj )
	self.owner = obj
end

function Aspect:OnLoseAspect( obj )
	self.owner = nil
end

function Aspect:__tostring()
	return self._classname
end
