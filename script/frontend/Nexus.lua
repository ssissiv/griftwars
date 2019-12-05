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

function WorldNexus:Sleep( agent )
	if agent ~= self.world:GetPuppet() then
		return
	end
	
	assert( is_instance( agent, Agent ))

	local window = SleepWindow( agent )
	self.screen:AddWindow( window )

	self.world:TogglePause( PAUSE_TYPE.NEXUS )

	local stat_xp = window:DoSleep()

	self.world:TogglePause( PAUSE_TYPE.NEXUS )

	return stat_xp
end

function WorldNexus:ShowAgentDetails( viewer, agent )
	if viewer ~= self.world:GetPuppet() then
		return
	end

	local window = AgentDetailsWindow( viewer, agent )
	self.screen:AddWindow( window )
end


