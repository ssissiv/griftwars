local Aspect = class( "Aspect" )


function Aspect:GetID()
	return self._classname
end

function Aspect:OnGainAspect( owner )
	self.owner = owner
	if self.event_handlers then
		for event, fn in pairs( self.event_handlers ) do
			owner:ListenForEvent( event, self, fn )
		end
	end
end

function Aspect:OnLoseAspect( owner )
	self.owner:RemoveListener( self )
	self.owner = nil
end

function Aspect:RegisterHandler( event, fn )
	assert( type(fn) == "function", event )

	if self.event_handlers == nil then
		self.event_handlers = {}
	end
	self.event_handlers[ event ] = fn
end


function Aspect:__tostring()
	return self._classname
end
