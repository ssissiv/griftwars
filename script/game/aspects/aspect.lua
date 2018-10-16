local Aspect = class( "Aspect" )

function Aspect:OnGainAspect( obj )
	if is_instance( obj, Agent ) then
		self.agent = obj
	else
		self.owner = obj
	end
end

function Aspect:OnLoseAspect( obj )
	self.agent = nil
	self.owner = nil
end
