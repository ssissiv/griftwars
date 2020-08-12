local dist = 16
local zone_dist = nil
local function IsSource( x, depth )
	local gen = x:GetAspect( Aspect.ResourceGenerator )
	if gen and gen:IsGenerator( Object.TradeGoods ) then
		dist = depth
		zone_dist = math.abs( x:GetZone():GetZoneDepth() - location:GetZone():GetZoneDepth() )

		return false, true
	end

	return depth < dist
end
location:Flood( IsSource )

print( dist, zone_dist )
