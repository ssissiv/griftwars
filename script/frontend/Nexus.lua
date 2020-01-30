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

function WorldNexus:LootMoney( agent, money )
	if not agent:IsPuppet() then
		agent:GetInventory():DeltaMoney( money )
	else
		local window = LootWindow( agent )
		window:AddMoney( money )
		self.screen:AddWindow( window )

		self.world:TogglePause( PAUSE_TYPE.NEXUS )

		window:DoLoot()

		self.world:TogglePause( PAUSE_TYPE.NEXUS )
	end
end

function WorldNexus:Inspect( viewer, ent )
	if viewer ~= self.world:GetPuppet() then
		return
	end

	if is_instance( ent, Agent ) then
		local window = AgentDetailsWindow( viewer, ent )
		self.screen:AddWindow( window )
	else
		local window = ObjectDetailsWindow( viewer, ent )
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

