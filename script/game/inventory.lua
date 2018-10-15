local Inventory = class( "Inventory" )

function Inventory:init()
	self.money = 0
end

function Inventory:GetMoney()
	return self.money
end

function Inventory:DeltaMoney( delta )
	self.money = math.max( self.money + delta, 0 )
end
