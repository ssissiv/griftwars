local History = class( "Aspect.History", Aspect )

function History:init()
	self.items = {}
end

function History:Log( fmt, ... )
	table.insert( self.items, { fmt, ... } )

	-- TODO: Fix this shitty ring
	while #self.items > 1024 * 32 do
		table.remove( self.items, 1 )
	end
end

function History:Items()
	return ipairs( self.items )
end

