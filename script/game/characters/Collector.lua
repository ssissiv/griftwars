
local Collector = class( "Behaviour.Collector", Aspect.Behaviour )

function Collector:init()
	Aspect.Behaviour.init( self )
end

function Collector:RunBehaviour()
	if self.deliver_behaviour then
		if self.deliver_behaviour.owner then
			return -- Still delivering
		end
		self.deliver_behaviour = nil
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
		self.deliver_behaviour = Behaviour.Deliver( subordinate, self.owner )
		subordinate:GetAspect( Aspect.Behaviour ):AddBehaviour( self.deliver_behaviour )
	end

	ReleaseWorkTable( subordinates )
end

--------------------------------------------------------------------------------

function Agent.Collector()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	ch:GainAspect( Behaviour.Collector() )
 	return ch
end

