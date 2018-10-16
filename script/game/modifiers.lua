local Modifiers = class( "Modifiers" )

function Modifiers:init()
	self.mods = {}
	self.value = 0
end

function Modifiers:AddModifier( x, txt )
	self.value = self.value + x
	table.insert( self.mods, { delta = x, txt = txt })
end

function Modifiers:GetValue()
	return self.value
end
