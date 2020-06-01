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

function EntityDistance( e1, e2 )
	local x1, y1 = e1:GetCoordinate()
	local x2, y2 = e2:GetCoordinate()
	if x1 == nil or x2 == nil then
		return math.huge
	else
		return distance( x1, y1, x2, y2 )
	end
end
