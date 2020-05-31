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
	ui.Columns( 3 )
	ui.Text( self:GetName() )	

	local enabled = self.reqs:IsSatisfied( viewer )
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

function GainXP:OnUseFavour( agent )
	Msg:Echo( agent, "{1.Id} shows you the ropes.", self.owner:LocTable( agent ))
	agent:GainXP( self.xp )
	self.owner:LoseAspect( self )
end


