local Aspect = class( "Aspect" )

function Aspect:GetID()
	return self._classname
end

function Aspect:GetWorld()
	local owner = self.owner
	while owner do
		if owner.world then
			return owner.world
		end
		owner = owner.owner
	end
end

function Aspect:OnGainAspect( owner )
	self.owner = owner
	if self.event_handlers then
		for event, fn in pairs( self.event_handlers ) do
			if not IsEnum( event, WORLD_EVENT ) then
				owner:ListenForEvent( event, self, fn )
			end
		end
	end
end

function Aspect:OnSpawn( world )
	if self.event_handlers then
		for event, fn in pairs( self.event_handlers ) do
			if IsEnum( event, WORLD_EVENT ) then
				self.owner.world:ListenForEvent( event, self, fn )
			end
		end
	end
end

function Aspect:OnLoseAspect( owner )
	self.owner:RemoveListener( self )
	self.owner = nil
end

function Aspect:OnDespawn()
	self.owner.world:RemoveListener( self )
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
