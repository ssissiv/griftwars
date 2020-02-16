local CityRoad = class( "WorldGen.CityRoad", WorldGen.Zone )

function CityRoad:init( x, y )
	CityRoad._base.init( self )
	self.growth = 0
	self.x, self.y = x, y
end

function CityRoad:Grow( growth )
	self.growth = (self.growth or 0) + growth

	while self.growth > 0 do
		if not self:Split() then
		end
	end
end

function CityRoad:Split()
	local exit = self:RandomAvailableExit()
	if exit == nil then
		-- Where does our growth go?
	else
		if self.growth > 1 and math.random() < 0.5 then
			-- Split off half.
			local adj = CityRoad( math.ceil( self.growth / 2 ))
			self:Connect( exit, adj )
			self.growth = math.floor( self.growth / 2 ))

		else
			-- Split off entire growth.
			local adj = CityRoad( self.growth - 1 )
			self:Connect( exit, adj )
			self.growth = 0
			adj:Split()
		end
	end
end


