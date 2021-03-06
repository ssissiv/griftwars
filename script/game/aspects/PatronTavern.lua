local PatronTavern = class( "Activity.PatronTavern", Verb.Activity )
PatronTavern.name = "Drinking ale"

function PatronTavern:FindAvailablePatronWaypoint()
	for i, wp in self.owner:Waypoints() do
		if wp:MatchTag( WAYPOINT_PATRON ) and (not wp:IsOccupied() or wp:GetOccupied() == self.actor) then
			return wp
		end
	end	
end

function PatronTavern:CanInteract()
	if not self:FindAvailablePatronWaypoint() then
		return false, "No spots available"
	end

	local ok, reason = self.owner:GetAspect( Feature.Tavern ):IsOpenForBusiness()
	if not ok then
		return ok, reason
	end

	return PatronTavern._base.CanInteract( self )
end

function PatronTavern:Interact()
	local wp = self:FindAvailablePatronWaypoint()
	wp:OccupyWaypoint( self.actor )

	local travel = Verb.Travel( self.actor ):SetDest( wp )
	while self:DoChildVerb( travel ) do
		self:Idle( math.random() * ONE_HOUR )
		Msg:Speak( self.actor, "Another beer, keeper!" )
	end

	wp:UnoccupyWaypoint( self.actor )
end
