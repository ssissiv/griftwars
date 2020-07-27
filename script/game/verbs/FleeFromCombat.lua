local FleeFromCombat = class( "Verb.FleeFromCombat", Verb )

function FleeFromCombat:GetDesc( viewer )
	return "Fleeing!"
end

function FleeFromCombat:CalculateUtility( actor )
	if self:IsCornered() then
		return UTILITY.COMBAT - 1
	else
		return UTILITY.EMERGENCY
	end
end

function FleeFromCombat:IsCornered()
	return (self.cornered or 0) > 1
end

function FleeFromCombat:CanInteract( actor )
	if not actor:InCombat() then
		return false, "Not in combat"
	end
	if not actor.combat:HasTargets() then
		return false, "No targets"
	end

	return true
end

function FleeFromCombat:ClearCornered()
	self.cornered = nil
	print ("CLEARED CORNERED" )
end

function FleeFromCombat:Interact( actor )
	-- Move away from the 2 closest targets.
	while not self:IsCancelled() do
		local targets = actor.combat:GetTargetsByDistance()
		local x0, y0 = actor:GetCoordinate()
		local target_dist = EntityDistance( actor, targets[1] )
		local dir
		if targets[2] then
			local x1, y1 = targets[1]:GetCoordinate()
			local x2, y2 = targets[2]:GetCoordinate()
			local dx1, dy1 = x0 - x1, y0 - y1
			local dx2, dy2 = x0 - x2, y0 - y2
			local dx, dy = math.round( (dx1 + dx2) / 2 ), math.round( (dy1 + dy2) / 2 )
			dir = VectorToDir( dx, dy )
			target_dist = math.min( target_dist, EntityDistance( actor, targets[2] ))

		elseif targets[1] then
			local x1, y1 = targets[1]:GetCoordinate()
			local dx, dy = x0 - x1, y0 - y1
			dir = VectorToDir( dx, dy )
		end

		local ok, reason = self:DoChildVerb( Verb.Walk( dir ))
		if not ok then
			-- Try an adjacent direction.
			dir = table.arraypick( ADJACENT_DIR[ dir ] )
			ok, reason = self:DoChildVerb( Verb.Walk( dir ))

			if not ok then
				if target_dist <= 1.5 then
					self.cornered = (self.cornered or 0) + 1
				end
			else
				self.cornered = nil
			end
		end
		if not ok then
			-- Wait a little.  Fleeing, so need to be responsive.
			self:YieldForTime( WALK_TIME )
			actor.behaviour:ScheduleNextTick( 0 )
		end
	end

	if self.cornered then
		self:ScheduleFunction( ONE_MINUTE, self.ClearCornered, self )
	end
end
