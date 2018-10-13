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
