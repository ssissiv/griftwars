
function Location:FloodFindLocalTavern()
	local dest
	local function IsLocalTavern( x, depth )
		if x:HasAspect( Feature.Tavern ) then
			dest = x
		end
		return depth < 6, dest ~= nil
	end

	self:Flood( IsLocalTavern )
	return dest
end