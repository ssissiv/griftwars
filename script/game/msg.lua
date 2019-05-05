local Msg = class( "Msg" )

function Msg:Action( msgs, actor, target, ... )
	local location = actor:GetLocation()
	for i, obj in location:Contents() do
		if obj == actor and msgs[1] then
			-- This message goes to the actor 
			local txt = loc.format( msgs[1], actor:LocTable( actor ), target:LocTable( actor ), ... )
			obj:Sense( txt )

		elseif obj == target and msgs[2] then
			-- This message goes to the target 
			local txt = loc.format( msgs[2], actor:LocTable( target ), target:LocTable( target ), ... )
			obj:Sense( txt )

		elseif msgs[3] then
			-- This message goes to everybody else
			local txt = loc.format( msgs[3], actor:LocTable( obj ), target:LocTable( obj ), ... )
			obj:Sense( txt )
		end
	end
end

function Msg:Speak( msgs, actor, target, ... )
	local location = actor:GetLocation()
	for i, obj in location:Contents() do
		if obj == actor and msgs[1] then
			-- This message goes to the actor 
			local txt = loc.format( "You say, '{1}'", msgs[1] )
			txt = loc.format( txt, actor, target, ... )
			actor:Sense( txt )

		elseif obj == target and msgs[2] then
			-- This message goes to the target 
			local txt = loc.format( "{1.Id} says, '{2}'", actor:LocTable( target ), msgs[2] )
			txt = loc.format( txt, actor, target, ... )
			target:Sense( txt )

		elseif msgs[3] then
			local txt = loc.format( "{1.Id} says, '{2}'", actor:LocTable( obj ), msgs[3] )
			txt = loc.format( txt, actor, target, ... )
			obj:Sense( txt )
		end
	end
end

function Msg:Echo( actor, format, ... )
	assert( actor.Echo, tostring(actor))
	local txt = loc.format( format, ... )
	actor:Echo( txt )
end

