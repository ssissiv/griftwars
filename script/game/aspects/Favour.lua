local Favour = class( "Aspect.Favour", Aspect )

function Favour.GainFavours( agent, t )
	for i, v in ipairs( t ) do
		local favour, trust = v[1], v[2]
		favour.reqs:AddReq( Req.Trust( agent, trust ))
		agent:GainAspect( favour )
	end
end

function Favour:init()
	self.reqs = Aspect.Requirements()
	self.used = {} -- Table of [agent] -> use info
end

function Favour:GetName()
	return self.name or self._classname
end

function Favour:GetTimesUsed( agent )
	return self.used[ agent ] and self.used[ agent ].count or 0
end

function Favour:GetRequiredTrust()
	local req = self.reqs:HasReqByClass( Req.Trust )
	return req and req.trust or 0
end

function Favour:CanUseFavour( viewer )
	local enabled, reasons = self.reqs:IsSatisfied( viewer )
	if not enabled then
		return false, reasons
	end

	return true
end

function Favour:UseFavour( agent )
	local used = self.used[ agent ]
	if used == nil then
		used = {}
	end

	used.count = (used.count or 0) + 1
	used.last_time = self:GetWorld():GetDateTime()

	self:OnUseFavour( agent )
end

function Favour:RenderAgentDetails( ui, panel, viewer )
	local enabled, reasons = self:CanUseFavour( viewer )
	if not enabled and not reasons then
		return
	end

	ui.PushID( rawstring(self) )
	ui.Columns( 3 )
	ui.TextWrapped( self:GetName() )	

	if enabled then
		ui.PushStyleColor( "Button", 0, 0.8, 0, 1 )
	else
		ui.PushStyleColor( "Button", 0.3, 0.3, 0.3, 1 )
	end

	ui.NextColumn()
	ui.Text( tostring(self:GetRequiredTrust()) )

	ui.NextColumn()
	if self.OnUseFavour == nil then
		ui.Button( "Passive" )
	elseif ui.Button( "Call In" ) and enabled then
		self:UseFavour( viewer )
	end

	if ui.IsItemHovered() then
		ui.BeginTooltip()
		if reasons then
			ui.TextColored( 1, 0, 0, 1, tostring(reasons))
		end
		self.reqs:RenderDebugPanel( ui, panel, GetDbg(), viewer )
		ui.EndTooltip()
	end

	ui.PopStyleColor()
	ui.Columns( 1 )
	ui.PopID()
end

------------------

local Acquaint = class( "Favour.Acquaint", Favour )

function Acquaint:GetName()
	return "Get acquainted"
end

function Acquaint:OnSpawn( world )
	Favour.OnSpawn( self, world )
	self.reqs:AddReq( Req.NotAcquainted( self.owner ))
end

function Acquaint:OnUseFavour( agent )
	self.owner:Acquaint( agent )
end

------------------

local GainXP = class( "Favour.GainXP", Favour )

function GainXP:init( xp )
	Favour.init( self )
	self.xp = xp
end

function GainXP:GetName()
	return loc.format( "Gain {1} XP", self.xp )
end

function GainXP:OnSpawn( world )
	Favour.OnSpawn( self, world )
	self.reqs:AddReq( Req.Acquainted( self.owner ))
end

function GainXP:OnUseFavour( agent )
	Msg:EchoTo( agent, "{1.Id} shows you the ropes.", self.owner:LocTable( agent ))
	agent:GainXP( self.xp )
	self.owner:LoseAspect( self )
end

------------------

local BoostTrustWithClass = class( "Favour.BoostTrustWithClass", Favour )

function BoostTrustWithClass:init( trust )
	Favour.init( self )
	self.trust = trust
end

function BoostTrustWithClass:GetName()
	return loc.format( "Gain {1} Trust with a {2}", self.trust, self.category:GetAgentClass()._classname )
end

function BoostTrustWithClass:OnSpawn( world )
	Favour.OnSpawn( self, world )
	self.reqs:AddReq( Req.Acquainted( self.owner ))
	self.category = world:WeightedPick( self.owner:GetRelationshipAffinities() )
end

function BoostTrustWithClass:OnUseFavour( agent )
	local other = self.category:GenerateAgent( self:GetWorld() )
	other:DeltaTrust( self.trust, agent )

	Msg:Speak( self.owner, "{1.name}'s a {1.udesc} friend of mine. Pay {1.himher} a visit.", other:LocTable( agent ))
	if not agent:IsAcquainted( other ) then
		agent:Acquaint( other )
	end
	Msg:EchoTo( agent, "You gain {1} trust with {2.desc}.", self.trust, other:LocTable( agent ))
end



------------------

local Gift = class( "Favour.Gift", Favour )

function Gift:init( loot_table )
	Favour.init( self )
	self.loot_table = loot_table
end

function Gift:GetName()
	return loc.format( "Receive a gift ({1})", self.loot_table.name )
end

function Gift:OnSpawn( world )
	Favour.OnSpawn( self, world )
	self.reqs:AddReq( Req.Acquainted( self.owner ))
	self.gifts = self.loot_table:GenerateLoot( world.rng )
end

function Gift:OnUseFavour( agent )
	self.owner:GetInventory():AddItems( self.gifts )
	self.owner:DoVerbAsync( Verb.GiveAll(), agent )
end



------------------

local LearnIntel = class( "Favour.LearnIntel", Favour )

function LearnIntel:GetName()
	return loc.format( "Learn some intel" )
end

function LearnIntel:OnUseFavour( agent )
	-- Search intel
	local intels = agent.world:CollectIntel()
	-- Gain Engram.
	local engram = table.arraypick( intels )
	Msg:EchoTo( agent, "Learned: {1}", engram:GetDesc() )
	agent:GetMemory():AddEngram( engram )
end


------------------

local NonAggression = class( "Favour.NonAggression", Favour )

NonAggression.event_handlers =
{
	[ CALC_EVENT.IS_ALLY ] = function( self, event_name, agent, acc, other )
		if self.reqs:IsSatisfied( other ) then
			acc:SetValue( true, self )
		end
	end,
}

function NonAggression:GetName()
	return loc.format( "Non-aggression" )
end



------------------

local JoinParty = class( "Favour.JoinParty", Favour )

function JoinParty:GetName()
	return loc.format( "Join party" )
end

function JoinParty:CanUseFavour( actor )
	if self.owner:GetLeader() == actor then
		return false, "Already following"
	end

	return Favour.CanUseFavour( self, actor )
end

function JoinParty:OnUseFavour( agent )
	Msg:Speak( agent, "Let's go!" )
	self.owner:SetLeader( agent )
end

