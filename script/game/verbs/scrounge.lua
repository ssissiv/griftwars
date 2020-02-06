local ScroungeTarget = class( "Aspect.ScroungeTarget", Aspect )

function ScroungeTarget:init( quality )
	assert( quality )
	self.quality = quality
end

function ScroungeTarget:CollectVerbs( verbs, actor, obj )
	local scrounge = actor:GetAspect( Verb.Scrounge )
	if scrounge and obj == self.owner then
		verbs:AddVerb( scrounge )
	end
end

function ScroungeTarget:RenderDetailsUI( ui, screen )
	ui.Text( loc.format( "Can scrounge: {1}", QUALITY_STRINGS[ self.quality ] ))
end

-------------------------------------------------------------------------

local Scrounge = class( "Verb.Scrounge", Verb )

Scrounge.ACT_DESC =
{
	"You are scrounging for some useful things.",
	nil,
	"{1.Id} is here rummaging around.",
}

Scrounge.ACT_RATE = 8.0

Scrounge.FLAGS = VERB_FLAGS.HANDS

function Scrounge:CalculateDC( mods )
	return 10
end

function Scrounge:GetDesc()
	return "Scrounge"
end

function Scrounge:GetDetailsDesc( viewer )
	if viewer:CanSee( self.owner ) then
		return "Busy scrounging"
	end
end


function Scrounge:GetShortDesc( viewer )
	if viewer == self.actor then
		return loc.format( self.ACT_DESC[1] )
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ) )
	end
end

function Scrounge:FindTarget( actor )
	local targets = {}
	for i, obj in actor:GetLocation():Contents() do
		if self:CanInteract( actor, obj ) then
			table.insert( targets, obj )
		end
	end
	return table.arraypick( targets )
end

function Scrounge:CanInteract( actor, target )
	if not self:IsDoing() then
		if actor:IsBusy( self.FLAGS ) then
			return false, "Busy"
		end
	end

	if target == nil then
		if not self:FindTarget( actor ) then
			return false, "No targets"
		end

	elseif not target:GetAspect( Aspect.ScroungeTarget ) then
		return false, "Can't scrounge " ..tostring(target)
	end
	
	return self._base.CanInteract( self, actor )
end

function Scrounge:Interact( actor, target )
	if target == nil then
		target = self:FindTarget( actor )
	end

	Msg:ActToRoom( "{1.Id} begins rummaging around in {2.Id}.", actor, target )
	Msg:Echo( actor, "You begin to rummage around in {1.Id}", target:LocTable( actor ) )

	while true do
		self:YieldForTime( 30 * ONE_MINUTE )
		actor:DeltaStat( STAT.FATIGUE, 5 )

		if self:IsCancelled() then
			break
		end

		local finder = self:GetRandomActor()
		if self:CheckDC() then
			local coins = math.random( 1, 3 )
			Msg:Echo( finder, "You find {1#money}!", coins )
			Msg:ActToRoom( "{1.Id} finds {3#money}!", finder, nil, coins )
			finder.world.nexus:LootMoney( finder, coins )
		else
			Msg:Echo( finder, "You don't find anything useful." )
			Msg:ActToRoom( "{1.Id} mutters something unhappily.", finder )
		end

		actor:GainXP( 1 )
		
		if math.random() < 0.5 then
			break
		end
	end
end
