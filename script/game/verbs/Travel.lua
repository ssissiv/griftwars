local Travel = class( "Verb.Travel", Verb )

-- Travel.FLAGS = VERB_FLAGS.MOVEMENT


Travel.EXIT_STRINGS =
{
	"You leave {2.title}.",
	nil,
	"{1.Id} leaves.",
}

Travel.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.Id} enters."
}

function Travel:GetDesc()
	return loc.format( "Travel to {1}", tostring(self.obj) )
end

function Travel:RenderAgentDetails( ui, screen, viewer )
	if viewer:CanSee( self.owner ) then
		ui.Bullet()
		ui.Text( loc.format( "Traveling to {1}", tostring(self.obj) ))
	end
end

function Travel:CanInteract( actor )
	if not actor:IsAlert() then
		return false, "Not Alert"
	end
	if not actor:IsSpawned() then
		return false
	end
	if actor:InCombat() then
		return false, "In combat"
	end
	return true
end

function Travel:Interact( actor, dest )
	if dest then
		self.obj = dest
	end
	local pather = PathFinder( actor, self.obj )
	while actor:GetLocation() ~= pather:GetEndRoom() do

		self:YieldForTime( 2 * ONE_MINUTE )

		if self:IsCancelled() then
			break
		end

		local path = pather:CalculatePath()
		if path and not actor:IsBusy( VERB_FLAGS.MOVEMENT ) then
			Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )
			actor:WarpToLocation( path[2] )
			Msg:Action( self.ENTER_STRINGS, actor, path[2] )
		end
	end
end


function Travel:Interact( actor, dest )
	if dest then
		self.obj = dest
	end
	local pather = PathFinder( actor, self.obj )
	while actor:GetLocation() ~= pather:GetEndRoom() do

		self:YieldForTime( 2 * ONE_MINUTE )

		if self:IsCancelled() then
			break
		end

		local path = pather:CalculatePath()
		if path and not actor:IsBusy( VERB_FLAGS.MOVEMENT ) then
			Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )
			actor:WarpToLocation( path[2] )
			Msg:Action( self.ENTER_STRINGS, actor, path[2] )
		end
	end
end

---------------------------------------------------------------

