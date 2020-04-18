function AccessCoordinate( obj )
	if obj.GetCoordinate then
		return obj:GetCoordinate()
	elseif is_instance( obj, Aspect ) then
		if obj.owner then
			return obj.owner:GetCoordinate()
		end
	end
end

