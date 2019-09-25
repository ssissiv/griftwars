local Inventory = class( "Inventory" )

function Inventory:init( owner )
	self.owner = owner
	self.money = Object()
	self.items = {}
end

function Inventory:GetMoney()
	return self.money:GetValue()
end

function Inventory:DeltaMoney( delta )
	self.money:DeltaValue( delta )
	if self.money:GetValue() == 0 then
		table.arrayremove( self.items, self.money )
	else
		table.insert_unique( self.items, self.money )
	end
end

function Inventory:CalculateValue()
	local value = 0
	for i, item in ipairs( self.items ) do
		value = value + item:GetValue()
	end
	return value
end

function Inventory:Items()
	return ipairs( self.items )
end
