local Agent = class( "Agent" )

Agent.FLAGS = MakeEnum{
	"PLAYER"
}

function Agent:init()
	self.flags = {}
end

function Agent:SetFlags( ... )
	for i, flag in ipairs({...}) do
		self.flags[ flag ] = true
	end
end

function Agent:HasFlag( flag )
	return self.flags[ flag ] == true
end

function Agent:GetName()
	return self.name or "No Name"
end

function Agent:SetDetails( name )
	self.name = name
end

function Agent:ExitLocation()
	self.location = nil
end

function Agent:EnterLocation( location )
	assert( is_instance( location, Location ))
	self.location = location
end

function Agent:GetLocation()
	return self.location
end
