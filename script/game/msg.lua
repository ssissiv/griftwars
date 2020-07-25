local Msg = class( "Msg" )

function Msg:SetWorld( world )
	self.world = world
end

function Msg:LocTable( ent )
	return ent:LocTable( self.world:GetPuppet() )
end

function Msg:Act( msgs, actor, target, ... )
	local location = actor:GetLocation()
	if not location then
		return
	end
	for i, obj in location:Contents() do
		if obj.Sense then
			if obj == actor and msgs[1] then
				-- This message goes to the actor 
				local txt = loc.format( msgs[1], self:LocTable( actor ), target and self:LocTable( target ), ... )
				obj:Sense( txt )

			elseif obj == target and msgs[2] then
				-- This message goes to the target 
				local txt = loc.format( msgs[2], self:LocTable( actor ), self:LocTable( target ), ... )
				obj:Sense( txt )

			elseif obj ~= actor and obj ~= target and msgs[3] then
				-- This message goes to everybody else
				local txt = loc.format( msgs[3], self:LocTable( actor ), target and self:LocTable( target ), ... )
				obj:Sense( txt )
			end
		end
	end
end

Msg.Action = Msg.Act

function Msg:EchoAround( actor, msg, ... )
	-- This message goes to everybody else
	local location = actor:GetLocation()
	if not location then
		return
	end
	local txt = loc.format( msg, ... )
	for i, obj in location:Contents() do
		if obj.Sense and obj ~= actor then
			obj:Sense( txt )
		end
	end
end

function Msg:EchoAround2( actor, other, msg, ... )
	-- This message goes to everybody else
	local location = actor:GetLocation()
	if not location then
		return
	end
	local txt = loc.format( msg, ... )
	for i, obj in location:Contents() do
		if obj.Sense and obj ~= actor and obj ~= other then
			obj:Sense( txt )
		end
	end
end

function Msg:Echo( location, msg, ... )
	-- This message goes to everybody
	local txt = loc.format( msg, ... )
	for i, obj in location:Contents() do
		if obj.Sense then
			obj:Sense( txt )
		end
	end
end

function Msg:Speak( actor, msg, ... )
	assert( is_instance( actor, Agent ))
	local location = actor:GetLocation()
	if not location then
		return
	end
	for i, obj in location:Contents() do
		if obj.Sense then
			if obj == actor then
				if actor:CanSpeak() then
					-- This message goes to the actor 
					local txt = loc.format( "You say, '{1}'", msg )
					txt = loc.format( txt, self:LocTable( actor ), ... )
					actor:Sense( txt )
				else
					local txt = loc.format( "You think '{1}' -- but can't speak!", msg )
					txt = loc.format( txt, self:LocTable( actor ), ... )
					actor:Sense( txt )
				end

			else
				if actor:CanSpeak() then
					msg = loc.format( msg, ... )
					local txt = loc.format( "{1.Id} says, '{2}'", self:LocTable( actor ), msg )
					obj:Sense( txt )
				else
					local txt = loc.format( "{1.Id} mumbles something you cant understand.", self:LocTable( actor ) )
					obj:Sense( txt )
				end
			end
		end
	end
end

function Msg:SpeakTo( actor, target, msg, ... )
	assert( is_instance( actor, Agent ))
	assert( is_instance( target, Agent ))

	local location = actor:GetLocation()
	if not location then
		return
	end
	for i, obj in location:Contents() do
		if obj.Sense then
			if obj == actor then
				-- This message goes to the actor 
				local txt = loc.format( "You say, '{1}'", msg )
				txt = loc.format( txt, self:LocTable( actor ), ... )
				actor:Sense( txt )

			elseif obj == target then
				-- This message is directed to the target 
				local txt = loc.format( "{1.Id} says to you, '{2}'", self:LocTable( actor ), msg )
				txt = loc.format( txt, self:LocTable( actor ), ... )
				target:Sense( txt )
			end
		end
	end
end

function Msg:EchoTo( actor, format, ... )
	if actor.Echo then
		local txt = loc.format( format, ... )
		actor:Echo( txt )
	end
end

