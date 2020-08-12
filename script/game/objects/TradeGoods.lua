local TradeGoods = class( "Object.TradeGoods", Object )
TradeGoods.name = "trade goods"
TradeGoods.value = 30

function TradeGoods:init()
	Object.init( self )
	self:GainAspect( Aspect.Carryable() )
end

function TradeGoods:GetModifiedValue()
	local location = self:GetLocation()
	if location then
		local zone_dist = nil
		local function IsSource( x, depth )
			local gen = x:GetAspect( Aspect.ResourceGenerator )
			if gen and gen:IsGenerator( self._class ) then
				zone_dist = math.abs( x:GetZone():GetZoneDepth() - location:GetZone():GetZoneDepth() )
				return false, true
			end

			return depth < 16
		end
		location:Flood( IsSource )

		if zone_dist then
			return math.floor( self:GetValue() * (1.0 + zone_dist) )
		end
	end

	return self:GetValue()
end
