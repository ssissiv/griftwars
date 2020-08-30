local FindActivity = class( "Verb.FindActivity", Verb )

function FindActivity:init( actor, location_class )
	Verb.init( self, actor )
	self.location_class = location_class
end

function FindActivity:GetName()
	return self.activity:GetName()
end

function FindActivity:CalculateUtility()
	return UTILITY.HABIT
end

function FindActivity:FindDest()
	local dest
	local function IsLocationClass( x, depth )
		if is_instance( x, self.location_class ) and x:GetAspect( Verb.Activity ) then
			dest = x
		end
		return depth < 6, dest ~= nil
	end

	self.actor:GetLocation():Flood( IsLocationClass )

	return dest
end

function FindActivity:CanInteract()
	self.dest = self:FindDest()
	
	local activity = (self.dest or self.actor:GetLocation()):GetAspect( Verb.Activity )
	if not activity then
		return false, "No dest or activity"
	end

	self.activity = activity:Clone( self.actor )
	local ok, reason = self.activity:CanDo()
	if not ok then
		return false, string.format( "Cant do %s: %s", activity, reason )
	end

	return Verb.CanInteract( self )
end

function FindActivity:Interact()
	assert( self.actor:GetLocation() )
	assert( self.activity )

	if self.dest then
		local travel = Verb.Travel( self.actor )
		travel:SetDest( self.dest )

		if not self:DoChildVerb( travel ) then
			print( "Can't quite travel...", self.actor, self.dest )
			self:YieldForTime( ONE_MINUTE )

		elseif not self:IsCancelled() then
			self:DoChildVerb( self.activity )
		end
	else
		-- Just do the thing at our current location.
		self:DoChildVerb( self.activity )
	end
end

