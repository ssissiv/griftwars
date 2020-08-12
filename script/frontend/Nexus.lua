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

	return window:ChooseBuyItem( self.world )
end

function WorldNexus:Sleep( agent )
	if not agent:IsPuppet() then
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

function WorldNexus:LootInventory( agent, inventory )
	if agent ~= self.world:GetPuppet() then
		return
	end
	
	local window = InventoryWindow( agent.world, agent, inventory )
	window:SetTitle( "Loot!" )
	self.screen:AddWindow( window )

	self.world:TogglePause( PAUSE_TYPE.NEXUS )

	window:DoLoot()

	self.world:TogglePause( PAUSE_TYPE.NEXUS )
end

function WorldNexus:Inspect( viewer, ent )
	if viewer ~= self.world:GetPuppet() then
		return
	end

	if is_instance( ent, Agent ) then
		local window = self.screen:FindWindow( AgentDetailsWindow ) or AgentDetailsWindow( viewer, ent )
		window:Refresh( ent )
		self.screen:AddWindow( window )
	elseif is_instance( ent, Aspect ) then
		self:Inspect( viewer, ent.owner )
	elseif is_instance( ent, Object ) then
		local window = self.screen:FindWindow( ObjectDetailsWindow ) or ObjectDetailsWindow( viewer, ent )
		window:Refresh( ent )
		self.screen:AddWindow( window )
	end
end

function WorldNexus:ShowAffinityChanged( affinity )
	local window = AffinityChangedWindow( affinity )
	self.screen:AddWindow( window )

	self.world:TogglePause( PAUSE_TYPE.NEXUS )

	window:Show()

	self.world:TogglePause( PAUSE_TYPE.NEXUS )
end

function WorldNexus:DoChallenge( challenge )
	local window = ChallengeWindow( challenge )
	self.screen:AddWindow( window )

	return window:Show()
end

function WorldNexus:ConfirmChoice( title, body )
	local window = ChoiceWindow( title, body )
	self.screen:AddWindow( window )

	return window:Show( self.world )
end

function WorldNexus:AddTileFloater( txt, tile )
	self.screen:AddTileFloater( txt, tile )
end
