function AccessCoordinate( obj )
	if obj.GetCoordinate then
		return obj:GetCoordinate()
	elseif is_instance( obj, Aspect ) then
		if obj.owner then
			return obj.owner:GetCoordinate()
		end
	elseif is_instance( obj, Verb ) then
		if obj:GetTarget() then
			return obj:GetTarget():GetCoordinate()
		elseif obj:GetActor() then
			return obj:GetActor():GetCoordinate()
		else
			print( "NO COORD:", obj )
		end
	end
end

function AccessEntity( obj )
    if is_instance( obj, Entity ) then
        return obj
    elseif is_instance( obj, Aspect ) then
        return obj.owner
    end
end