local Portal = class( "Aspect.Portal", Aspect )

function Portal:init( location, x, y )
	self:Connect( location, x, y )
	self.leave_verb = Verb.LeaveLocation( self )
end

function Portal:Connect( location, x, y )
	self.location, self.x, self.y = location, x, y
end

function Portal:GetDest()
	return self.location, self.x, self.y
end

function Portal:OnLocationChanged( prev_location, location )
	if prev_location then
		prev_location:RemovePortal( self )
	end
	if location then
		location:AddPortal( self )
	end
end

function Portal:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	if self.owner.location then
		self.owner.location:AddPortal( self )
	end
end

function Portal:OnDespawn( )
	if self.owner.location then
		self.owner.location:RemovePortal( self )
	end
end

