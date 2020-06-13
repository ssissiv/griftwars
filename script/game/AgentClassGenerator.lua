local AgentClassGenerator = class( "AgentClassGenerator" )

function AgentClassGenerator:init( class )
	assert( is_class( class, Agent ))
	self.class = class
end

function AgentClassGenerator:GetAgentClass()
	return self.class
end

function AgentClassGenerator:GenerateAgent( world )
	local bucket = world:GetBucketByClass( self.class )
	local agent = world:ArrayPick( bucket )
	if agent == nil then
		-- Gotsa immigrate someone!
		error( "Immigration error: " ..self.class._classname )
	end
	
	return agent
end

