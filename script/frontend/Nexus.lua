-- Implementation of the presentation layer for the world.
-- This includes UI, game rendering, etc.
-- Any information between the world and user comes through here.

local WorldNexus = class( "WorldNexus" )

function WorldNexus:init( world, screen )
	self.world = world
	self.screen = screen
end

function WorldNexus:ChooseBuyItem( owner, buyer )
	assert( is_instance( owner, Agent ), tostring(owner))
	assert( is_instance( buyer, Agent ), tostring(buyer))
	local window = ShopWindow( owner, buyer )
	assert( window.owner )
	self.screen:AddWindow( window )

	return window:ChooseBuyItem()
end


