local ScroungeTarget = class( "Aspect.ScroungeTarget", Aspect )

ScroungeTarget.event_handlers =
{
	[ CALC_EVENT.DC ] = function( self, verb, event_name, acc )
		if is_instance( verb, Verb.Scrounge ) and self.scrounge_count then
			acc:AddValue( self.scrounge_count * 2, "Already searched through" )
		end
	end,
}

function ScroungeTarget:SetLootTable( t )
	self.loot_table = t
end

function ScroungeTarget:CollectVerbs( verbs, actor, obj )
	local scrounge = true --actor:GetAspect( Verb.Scrounge )
	if scrounge and obj == self.owner then
		verbs:AddVerb( Verb.Scrounge( nil, self.owner ) )
	end
end

function ScroungeTarget:GenerateLoot( inventory )
	if self.loot_table then
		self.loot_table:SpawnLoot( inventory, self:GetWorld().rng )
	end
	self.scrounge_count = (self.scrounge_count or 0) + 1
end


function ScroungeTarget:RenderDetailsUI( ui, screen )
	ui.Text( loc.format( "This {1} has been rummaged in {2} times.", self.owner, self.scrounge_count or 0))
end

-------------------------------------------------------------------------

AppendEnum( AGENT_EVENT, "SCROUNGE" )

local Scrounge = class( "Verb.Scrounge", Verb )

Scrounge.ACT_DESC =
{
	"You are scrounging for some useful things.",
	nil,
	"{1.Id} is here rummaging around.",
}

Scrounge.FLAGS = VERB_FLAGS.HANDS
Scrounge.DC = 10
Scrounge.act_desc = "Scrounge"

function Scrounge:GetDesc( viewer )
	return "Scrounging for valuables"
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
		target = self:FindTarget( actor )
	end

	if target == nil then
		return false, "No targets"

	elseif not target:GetAspect( Aspect.ScroungeTarget ) then
		return false, "Can't scrounge " ..tostring(target)

	elseif not actor:CanReach( target ) then
		return false, "Can't reach"
	end
	
	return self._base.CanInteract( self, actor )
end

function Scrounge:Interact( actor, target )
	if target == nil then
		target = self:FindTarget( actor )
	end

	Msg:ActToRoom( "{1.Id} begins rummaging around in {2.Id}.", actor, target )
	Msg:Echo( actor, "You begin to rummage around in {1.Id}", target:LocTable( actor ) )

	-- while true do
		self:YieldForTime( 30 * ONE_MINUTE, "rate", 8.0 )
		actor:DeltaStat( STAT.FATIGUE, 5 )

		if self:IsCancelled() then
			return
		end

		local finder = self:GetRandomActor()
		local inv = target:GetAspect( Aspect.Inventory )

		-- Check to generate
		local ok, result_str = self:CheckDC( actor, target )
		if ok then
			target:GetAspect( Aspect.ScroungeTarget ):GenerateLoot( inv )
		end

		if not inv:IsEmpty() then
			if ok then
				Msg:Echo( finder, "You scrounge and find something... ({1})", result_str )
			else
				Msg:Echo( finder, "You don't find anything new. ({1})", result_str )
			end
			actor.world.nexus:LootInventory( actor, inv )
			Msg:ActToRoom( "{1.Id} scrounges about and finds something.", finder )
		else
			Msg:Echo( finder, "You fail to find anything of use. ({1})", result_str )
			Msg:ActToRoom( "{1.Id} mutters something unhappily.", finder )
		end

		actor:GainXP( 1 )

		
		finder:BroadcastEvent( AGENT_EVENT.SCROUNGE, actor )
		
	-- 	if math.random() < 0.5 then
	-- 		break
	-- 	end
	-- end
end
