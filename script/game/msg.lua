local Msg = class( "Msg" )

function Msg:Action( msgs, actor, target, ... )
	local location = actor:GetLocation()
	for i, obj in location:Contents() do
		if obj == actor and msgs[1] then
			local txt = loc.format( msgs[1], actor, target, ... )
			obj:Sense( txt )
		elseif obj == target and msgs[2] then
			local txt = loc.format( msgs[2], actor, target, ... )
			obj:Sense( txt )
		elseif msgs[3] then
			local txt = loc.format( msgs[3], actor, target, ... )
			obj:Sense( txt )
		end
	end
end

function Msg:Speak( msgs, actor, target, ... )
	local location = actor:GetLocation()
	for i, obj in location:Contents() do
		if obj == actor and msgs[1] then
			local txt = loc.format( "You say, '{1}'", msgs[1] )
			txt = loc.format( txt, actor, target, ... )
			actor:Sense( txt )
		elseif obj == target and msgs[2] then
			local txt = loc.format( "{1} says, '{2}'", actor, msgs[2] )
			txt = loc.format( txt, actor, target, ... )
			target:Sense( txt )
		elseif msgs[3] then
			local txt = loc.format( "{1} says, '{2}'", actor, msgs[3] )
			txt = loc.format( txt, actor, target, ... )
			obj:Sense( txt )
		end
	end
end

function Msg:Echo( actor, format, ... )
	local txt = loc.format( format, ... )
	actor:Echo( txt )
end

