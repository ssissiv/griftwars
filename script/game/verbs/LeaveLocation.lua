local LeaveLocation = class( "Verb.LeaveLocation", Verb )

LeaveLocation.COLOUR = constants.colours.MAGENTA

LeaveLocation.FLAGS = VERB_FLAGS.MOVEMENT

LeaveLocation.ACT_DESC =
{
	"You are travelling through here.",	
	nil,
	"{1.Id} is heading towards {2.title}.",
}

LeaveLocation.EXIT_STRINGS =
{
	nil, --"You leave {2.title}.",
	nil,
	"{1.Id} leaves to {2.title}.",
}

function LeaveLocation:init( dest, reqs )
	Verb.init( self, nil, dest )
	self.reqs = reqs
end

function LeaveLocation:GetShortDesc( viewer )
	if self.obj then
		local dest
		if is_instance( self.obj, Aspect.Portal ) then
			dest = self.obj:GetDest()
		else
			dest = self.obj
		end

		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ), dest:LocTable( viewer ))
		else
			return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), dest:LocTable( viewer ))
		end
	else
		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ) )
		else
			return loc.format( "{1.Id} is here, leaving.", self.actor:LocTable( viewer ) )
		end
	end
end

function LeaveLocation:GetDesc()
	if is_instance( self.obj, Location ) then
		return loc.format( "Leave to {1}", self.obj:GetTitle() )
	elseif is_instance( self.obj, Aspect.Portal ) then
		return loc.format( "Leave to {1}", self.obj:GetDest():GetTitle() )
	else
		return "Leave somewhere"
	end
end

function LeaveLocation:CanInteract( actor )
	for i, verb in actor:Verbs() do
		if verb ~= self and verb:HasBusyFlag( VERB_FLAGS.MOVEMENT ) then
			return false, "Moving"
		end
	end

	if self.reqs then
		local ok, details = self.reqs:IsSatisfied( actor )
		if not ok then
			return false, details
		end
	end
	
	return self._base.CanInteract( self, actor )
end

function LeaveLocation:PathToPortal( actor, portal )
	-- Path tiles to dest.
	local pather = TilePathFinder( actor, actor, portal.owner:GetTile() )
	while actor:GetTile() ~= pather:GetEndRoom() do
		--
		self:YieldForTime( WALK_TIME, 1.0 )

		if self:IsCancelled() then
			break
		end

		local path = pather:CalculatePath()
		if path then
			local x1, y1 = path[1]:GetCoordinate()
			local x2, y2 = path[2]:GetCoordinate()
			local exit = OffsetToExit( x1, y1, x2, y2 )
			actor:Walk( exit )

		else
			-- print( "no path!", self, actor, portal )
			self:YieldForTime( ONE_MINUTE )
		end
	end
end

function LeaveLocation:Interact( actor, target )
	target = target or self:GetTarget()

	local dest, destx, desty
	local portal

	if target == nil then
		-- Chose a random accessible portal out of here.
		local portals = {}
		for i, portal in actor.location:Portals() do
			if portal:GetDest() and portal:GetDest() ~= actor.location then
				table.insert( portals, portal )
			end
		end

		portal = table.arraypick( portals )
		if portal == nil then
			-- No such portal, guess we're done.
			return
		else
			dest, destx, desty = portal:GetDest()
		end

	elseif is_instance( target, Aspect.Portal ) then
		dest, destx, desty = target:GetDest()
		portal = target

	elseif is_instance( target, Location ) then
		dest = target

	else
		error(tostring(target))
	end

	-- If we have a specific Portal, path to it.
	if actor:GetLocation().map and portal then
		self:PathToPortal( actor, portal )
	
		self:YieldForTime( portal:GetTravelTime() )

		if self:IsCancelled() then
			return
		end		
	end

	-- Warp to dest Location.
	Msg:Action( self.EXIT_STRINGS, actor, dest )

	actor:DeltaStat( STAT.FATIGUE, 5 )
	local entry_tile = dest:FindPassableTile( destx, desty, actor )
	if entry_tile then
		actor:WarpToLocation( dest, entry_tile:GetCoordinate() )

		Msg:Echo( actor, "You enter {1}.", dest:GetTitle() )
		Msg:ActToRoom( "{1.Id} enters.", actor )
	else
		Msg:Echo( actor, "The other side seems to be blocked!" )
		print( actor, "couldn't leave to", dest )
		DBG( dest:GetTileAt( destx, desty ))
	end
end

---------------------------------------------------------------

