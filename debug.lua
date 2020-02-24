local pts = {}
local function IsStrategicPoint( location, depth )
	print( location, depth, rawstring(location))
	if location:HasAspect( Feature.StrategicPoint ) then
	end
	return depth < 4
end

puppet.location:Flood( IsStrategicPoint )	