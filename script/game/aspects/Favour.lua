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
	local enabled, reasons = self.reqs:IsSatisfied( viewer )
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
	if ui.Button( "Call In" ) and enabled then
		self:UseFavour( viewer )
	end
	if ui.IsItemHovered() then
		ui.BeginTooltip()
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
	Msg:Echo( agent, "{1.Id} shows you the ropes.", self.owner:LocTable( agent ))
	agent:GainXP( self.xp )
	self.owner:LoseAspect( self )
end

------------------

local BoostTrust = class( "Favour.BoostTrust", Favour )

function BoostTrust:init( trust )
	Favour.init( self )
	self.trust = trust
end

function BoostTrust:GetName()
	return loc.format( "Gain {1} Trust with a {2}", self.trust, self.category:GetAgentClass()._classname )
end

function BoostTrust:OnSpawn( world )
	Favour.OnSpawn( self, world )
	self.reqs:AddReq( Req.Acquainted( self.owner ))
	self.category = world:WeightedPick( self.owner:GetRelationshipAffinities() )
end

function BoostTrust:OnUseFavour( agent )
	local other = self.category:GenerateAgent( self:GetWorld() )
	other:DeltaTrust( self.trust, agent )

	Msg:Speak( self.owner, "{1.name}'s a {1.udesc} friend of mine. Pay {1.himher} a visit.", other:LocTable( agent ))
	if not agent:IsAcquainted( other ) then
		agent:Acquaint( other )
	end
	Msg:Echo( agent, "You gain {1} trust with {2.desc}.", self.trust, other:LocTable( agent ))
end





