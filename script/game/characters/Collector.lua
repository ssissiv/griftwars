
local Collector = class( "Behaviour.Collector", Aspect.Behaviour )

function Collector:init()
	Aspect.Behaviour.init( self )
end

function Collector:OnTickBehaviour()
	Collector._base.OnTickBehaviour( self )
	
	if self.deliver then
		if not self.deliver.removed then
			return -- Still delivering
		end
		self.deliver = nil
	end

	-- Find a subordinate and give them a Deliver behaviour.
	local subordinates = ObtainWorkTable()
	for i, r in self.owner:Relationships() do
		if is_instance( r, Relationship.Subordinate ) and r.boss == self.owner and r.subordinate:HasAspect( Aspect.Behaviour ) then
			table.insert( subordinates, r.subordinate )
		end
	end

	local subordinate = table.arraypick( subordinates )
	if subordinate then
		self.deliver = Verb.Deliver( subordinate, self.owner )
		subordinate:GetAspect( Aspect.Behaviour ):RegisterVerb( self.deliver )
	end

	ReleaseWorkTable( subordinates )
end

--------------------------------------------------------------------------------

local Collector = class( "Agent.Collector", Agent )

function Collector:init()
	Agent.init( self )
	self:GainAspect( Behaviour.Collector() )
end

function Collector:OnSpawn( world )
	Agent.OnSpawn( self, world )
	local name = world:GetAspect( Aspect.NamePool ):PickName()
	self:SetDetails( name, "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
end


